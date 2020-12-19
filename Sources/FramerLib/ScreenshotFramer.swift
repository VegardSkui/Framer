//
//  ScreenshotFramer.swift
//  FramerLib
//
//  Created by Vegard Skui on 16/12/2020.
//  Copyright © 2020 Vegard Skui. All rights reserved.
//

import Foundation

enum FramingError: Error, CustomStringConvertible {
    case internalError(String)

    var description: String {
        switch self {
        case .internalError(let error):
            return "Internal framing error: \(error)"
        }
    }
}

public class ScreenshotFramer {
    let device: Device

    let frame: CGImage

    public init?(for device: Device) {
        guard let frameURL = Bundle.module.url(forResource: device.name,
                                               withExtension: "png") else {
            return nil
        }

        guard let provider = CGDataProvider(url: frameURL as CFURL) else {
            return nil
        }
        guard let frame = CGImage(pngDataProviderSource: provider,
                                  decode: nil,
                                  shouldInterpolate: false,
                                  intent: .defaultIntent) else {
            return nil
        }

        self.device = device
        self.frame = frame
    }

    public func frame(_ screenshot: CGImage) throws -> CGImage {
        // Warn the user if the screenshot dimensions don't match the device's
        // screen size
        if screenshot.width != Int(device.screen.width) || screenshot.height != Int(device.screen.height) {
            print("Warning: Screenshot dimensions do not match device screen size.")
        }

        guard let colorSpace = CGColorSpace(name: CGColorSpace.sRGB) else {
            throw FramingError.internalError("Could not initialize color space.")
        }

        let bitmapInfo = CGImageAlphaInfo.premultipliedLast.rawValue & CGBitmapInfo.alphaInfoMask.rawValue

        guard let context = CGContext(data: nil,
                                      width: frame.width,
                                      height: frame.height,
                                      bitsPerComponent: frame.bitsPerComponent,
                                      bytesPerRow: frame.bytesPerRow,
                                      space: colorSpace,
                                      bitmapInfo: bitmapInfo) else {
            throw FramingError.internalError("Could not create CGContext.")
        }

        guard let clipped = clip(screenshot: screenshot) else {
            throw FramingError.internalError("Could not clip screenshot.")
        }

        let frameRect = CGRect(x: 0, y: 0, width: frame.width, height: frame.height)

        // Draw the screenshot first to make sure it's underneath the frame
        context.draw(clipped, in: frameRect)
        context.draw(frame, in: frameRect)

        guard let result = context.makeImage() else {
            throw FramingError.internalError("makeImage() failed.")
        }
        return result
    }

    /// Creates a mask to be applied to screenshots to remove pixels outside
    /// the device frame.
    func makeScreenMask() -> CGImage? {
        // Draw the frame in an alpha-only context with the raw pixel data
        // available. When using the masking image later, pixels masked with
        // 0xFF will be removed and 0x00 will be retained.
        var pixelData = [UInt8](repeating: 0, count: frame.width * frame.height)

        guard let colorSpace = CGColorSpace(name: CGColorSpace.linearGray) else {
            return nil
        }

        guard let context = CGContext(data: &pixelData,
                                      width: frame.width,
                                      height: frame.height,
                                      bitsPerComponent: 8,
                                      bytesPerRow: frame.width,
                                      space: colorSpace,
                                      bitmapInfo: CGImageAlphaInfo.alphaOnly.rawValue) else {
            return nil
        }

        let rect = CGRect(x: 0, y: 0, width: frame.width, height: frame.height)
        context.draw(frame, in: rect)

        // Process the frame image line by line
        let group = DispatchGroup()
        let queue = DispatchQueue.global(qos: .userInitiated)

        pixelData.withUnsafeMutableBufferPointer { pixelDataMemory in
            for y in 0..<frame.height {
                queue.async(group: group, execute: { [pixelDataMemory] in
                    let base = self.frame.width*y

                    // Mask out pixels to the left of the frame (including
                    // semi-transparent)
                    var i = base
                    while i < base+self.frame.width && pixelDataMemory[i] != 0xFF {
                        pixelDataMemory[i] = 0xFF
                        i += 1
                    }

                    // Mask out pixels to the right of the frame (including
                    // semi-transparent)
                    var j = base+self.frame.width-1
                    while j >= base && pixelDataMemory[j] != 0xFF {
                        pixelDataMemory[j] = 0xFF
                        j -= 1
                    }

                    // Now, i is the leftmost pixel we can keep (it's an opaque
                    // frame pixel), and likewise for j being the rightmost.
                    // This means that [i, j] gives every pixel not outside the
                    // frame, which we make sure to keep.
                    while i < j {
                        pixelDataMemory[i] = 0x00
                        i += 1
                    }

                    // Note that we can't simply use the transparent pixels on
                    // the inside of the frame since the inside border also has
                    // semi-transparent pixels which we have to include
                })
            }
        }

        group.wait()

        // After processing is complete, create a masking image from the data in
        // the context
        guard let provider = context.makeImage()?.dataProvider else {
            return nil
        }

        return CGImage(maskWidth: frame.width,
                       height: frame.height,
                       bitsPerComponent: 8,
                       bitsPerPixel: 8,
                       bytesPerRow: frame.width,
                       provider: provider,
                       decode: nil,
                       shouldInterpolate: false)
    }

    /// Removes pixels which would be outside the device frame.
    ///
    /// Applies the mask from `makeScreenMask()`.
    func clip(screenshot: CGImage) -> CGImage? {
        let screenMask = makeScreenMask()!

        guard let colorSpace = CGColorSpace(name: CGColorSpace.sRGB) else {
            return nil
        }

        let bitmapInfo = CGBitmapInfo.alphaInfoMask.rawValue & CGImageAlphaInfo.premultipliedLast.rawValue

        guard let context = CGContext(data: nil,
                                      width: frame.width,
                                      height: frame.height,
                                      bitsPerComponent: frame.bitsPerComponent,
                                      bytesPerRow: frame.bytesPerRow,
                                      space: colorSpace,
                                      bitmapInfo: bitmapInfo) else {
            return nil
        }

        let frameRect = CGRect(x: 0, y: 0, width: frame.width, height: frame.height)
        context.clip(to: frameRect, mask: screenMask)
        context.draw(screenshot, in: device.screen)

        return context.makeImage()
    }
}
