//
//  Device.swift
//  FramerLib
//
//  Created by Vegard Skui on 16/12/2020.
//  Copyright © 2020 Vegard Skui. All rights reserved.
//

import Foundation

public enum Devices: Device, CaseIterable {
    case iphone12
    case iphone12mini
    case iphone12pro
    case iphone12promax

    case watch6_44mm

    public var name: String {
        switch self {
        case .iphone12:
            return "iPhone 12"
        case .iphone12mini:
            return "iPhone 12 mini"
        case .iphone12pro:
            return "iPhone 12 Pro"
        case .iphone12promax:
            return "iPhone 12 Pro Max"
        case .watch6_44mm:
            return "Apple Watch Series 6 44mm"
        }
    }

    public var supportedOrientations: [DeviceOrientation] {
        switch self {
        case .iphone12:
            return [.portrait]
        case .iphone12mini:
            return [.portrait]
        case .iphone12pro:
            return [.portrait]
        case .iphone12promax:
            return [.portrait, .landscapeLeft]
        case .watch6_44mm:
            return [.standard]
        }
    }

    public var screen: [DeviceOrientation: CGRect] {
        switch self {
        case .iphone12:
            return [.portrait: CGRect(x: 100, y: 90, width: 1170, height: 2532)]
        case .iphone12mini:
            return [.portrait: CGRect(x: 100, y: 90, width: 1125, height: 2436)]
        case .iphone12pro:
            return [.portrait: CGRect(x: 100, y: 90, width: 1170, height: 2532)]
        case .iphone12promax:
            return [.portrait: CGRect(x: 100, y: 100, width: 1284, height: 2778),
                    .landscapeLeft: CGRect(x: 100, y: 100, width: 2778, height: 1284)]
        case .watch6_44mm:
            return [.standard: CGRect(x: 56, y: 205, width: 368, height: 448)]
        }
    }

    public var frame: [DeviceOrientation: CGImage?] {
        switch self {
        case .iphone12:
            return [.portrait: getDeviceFrame(name)]
        case .iphone12mini:
            return [.portrait: getDeviceFrame(name)]
        case .iphone12pro:
            return [.portrait: getDeviceFrame(name)]
        case .iphone12promax:
            return [.portrait: getDeviceFrame(name),
                    .landscapeLeft: getDeviceFrame(name, rotation: .left)]
        case .watch6_44mm:
            return [.standard: getDeviceFrame(name)]
        }
    }
}

// MARK: - Lookup Helpers

extension Devices {
    public static func findBy(name: String) -> Device? {
        Devices.allCases.first { device in
            device.name == name
        }
    }

    public static func findBy(screenSize: CGSize) -> (Device, DeviceOrientation)? {
        for device in Devices.allCases {
            for (orientation, rect) in device.screen {
                if rect.size == screenSize {
                    return (device, orientation)
                }
            }
        }
        return nil
    }
}

// MARK: - Internal Helpers

extension Devices {
    /// Loads a device frame image with optional rotation.
    ///
    /// - Parameter name: Filename without extension (assumed to be png).
    /// - Parameter rotation: Rotation to be applied after loading.
    private func getDeviceFrame(_ name: String, rotation: Rotation = .up) -> CGImage? {
        guard let frameURL = Bundle.module.url(forResource: name, withExtension: "png") else {
            return nil
        }

        guard let provider = CGDataProvider(url: frameURL as CFURL) else {
            return nil
        }

        guard let image = CGImage(pngDataProviderSource: provider,
                                  decode: nil,
                                  shouldInterpolate: false,
                                  intent: .defaultIntent) else {
            return nil
        }

        return rotate(image, rotation)
    }

    private func rotate(_ image: CGImage, _ rotation: Rotation) -> CGImage? {
        let swapWidthAndHeight = [.left, .right].contains(rotation)
        let angle = CGFloat(rotation.rawValue)*0.5*CGFloat.pi

        let width: Int
        let height: Int
        if swapWidthAndHeight {
            width = image.height
            height = image.width
        } else {
            width = image.width
            height = image.height
        }

        guard let colorSpace = CGColorSpace(name: CGColorSpace.sRGB) else {
            return nil
        }

        let bitmapInfo = CGBitmapInfo.alphaInfoMask.rawValue & CGImageAlphaInfo.premultipliedLast.rawValue

        guard let context = CGContext(data: nil,
                                      width: width,
                                      height: height,
                                      bitsPerComponent: 8,
                                      bytesPerRow: 4*width,
                                      space: colorSpace,
                                      bitmapInfo: bitmapInfo) else {
            return nil
        }

        // Move the origin to the center
        context.translateBy(x: CGFloat(width)/2, y: CGFloat(height)/2)

        context.rotate(by: angle)

        if swapWidthAndHeight {
            context.translateBy(x: -CGFloat(height)/2, y: -CGFloat(width)/2)
        } else {
            context.translateBy(x: -CGFloat(width)/2, y: -CGFloat(height)/2)
        }

        context.draw(image, in: CGRect(x: 0, y: 0, width: image.width, height: image.height))

        return context.makeImage()
    }

    private enum Rotation: Int {
        // The backing int value is used to calculate the angle, see `rotate`.
        case up = 0
        case left = 1
        case down = 2
        case right = 3
    }
}

// MARK: - Device Protocol and Orientation Enum

public protocol Device {
    /// The device's name.
    var name: String { get }

    /// The orientations supported by the device.
    var supportedOrientations: [DeviceOrientation] { get }

    /// The rectangle describing the size and position of the device's screen in
    /// pixels (not points) for each orientation.
    var screen: [DeviceOrientation: CGRect] { get }

    /// Image of the device's frame for each supported orientation.
    var frame: [DeviceOrientation: CGImage?] { get }
}

public enum DeviceOrientation {
    case portrait
    case landscapeLeft

    /// Standard orientation for devices where only one orientation is supported.
    case standard
}
