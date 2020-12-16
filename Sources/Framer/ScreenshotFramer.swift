//
//  ScreenshotFramer.swift
//  Framer
//
//  Created by Vegard Skui on 16/12/2020.
//  Copyright © 2020 Vegard Skui. All rights reserved.
//

import Foundation

enum FramingError: Error, CustomStringConvertible {
    case internalError(String)
    case wrongDimensions

    var description: String {
        switch self {
        case .internalError(let error):
            return "Internal framing error: \(error)"
        case .wrongDimensions:
            return "Wrong dimensions."
        }
    }
}

class ScreenshotFramer {
    let device: Device

    let frame: CGImage

    init?(for device: Device) {
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

    func frame(_ screenshot: CGImage) throws -> CGImage {
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

        // Draw the screenshot first to make sure it's underneath any notch
        context.draw(screenshot, in: device.screen)

        // The corner radius of the iPhone 12 Pro Max is big enough that the
        // corners of the screenshots protrudes outside the device frame, we
        // therefore have to clear them manually
        if device.name == Devices.iphone12promax.name {
            context.clear(CGRect(x: device.screen.minX, y: device.screen.minY, width: 5, height: 5))
            context.clear(CGRect(x: device.screen.maxX - 5, y: device.screen.minY, width: 5, height: 5))
            context.clear(CGRect(x: device.screen.minX, y: device.screen.maxY - 5, width: 5, height: 5))
            context.clear(CGRect(x: device.screen.maxX - 5, y: device.screen.maxY - 5, width: 5, height: 5))
        }

        let frameRect = CGRect(x: 0, y: 0, width: frame.width, height: frame.height)
        context.draw(frame, in: frameRect)

        guard let result = context.makeImage() else {
            throw FramingError.internalError("makeImage() failed.")
        }
        return result
    }
}
