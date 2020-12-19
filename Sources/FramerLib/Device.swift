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
            return [.portrait, .upsideDown, .landscapeLeft, .landscapeRight]
        case .iphone12mini:
            return [.portrait, .upsideDown, .landscapeLeft, .landscapeRight]
        case .iphone12pro:
            return [.portrait, .upsideDown, .landscapeLeft, .landscapeRight]
        case .iphone12promax:
            return [.portrait, .upsideDown, .landscapeLeft, .landscapeRight]
        case .watch6_44mm:
            return [.standard]
        }
    }

    public var screen: [DeviceOrientation: CGRect] {
        switch self {
        case .iphone12:
            return [.portrait: CGRect(x: 100, y: 90, width: 1170, height: 2532),
                    .upsideDown: CGRect(x: 100, y: 90, width: 1170, height: 2532),
                    .landscapeLeft: CGRect(x: 90, y: 100, width: 2532, height: 1170),
                    .landscapeRight: CGRect(x: 90, y: 100, width: 2532, height: 1170)]
        case .iphone12mini:
            return [.portrait: CGRect(x: 100, y: 90, width: 1125, height: 2436),
                    .upsideDown: CGRect(x: 100, y: 90, width: 1125, height: 2436),
                    .landscapeLeft: CGRect(x: 90, y: 100, width: 2436, height: 1125),
                    .landscapeRight: CGRect(x: 90, y: 100, width: 2436, height: 1125)]
        case .iphone12pro:
            return [.portrait: CGRect(x: 100, y: 90, width: 1170, height: 2532),
                    .upsideDown: CGRect(x: 100, y: 90, width: 1170, height: 2532),
                    .landscapeLeft: CGRect(x: 90, y: 100, width: 2532, height: 1170),
                    .landscapeRight: CGRect(x: 90, y: 100, width: 2532, height: 1170)]
        case .iphone12promax:
            return [.portrait: CGRect(x: 100, y: 100, width: 1284, height: 2778),
                    .upsideDown: CGRect(x: 100, y: 100, width: 1284, height: 2778),
                    .landscapeLeft: CGRect(x: 100, y: 100, width: 2778, height: 1284),
                    .landscapeRight: CGRect(x: 100, y: 100, width: 2778, height: 1284)]
        case .watch6_44mm:
            return [.standard: CGRect(x: 56, y: 205, width: 368, height: 448)]
        }
    }

    public var frame: [DeviceOrientation: CGImage?] {
        switch self {
        case .iphone12:
            return [.portrait: getDeviceFrame(name),
                    .upsideDown: getDeviceFrame(name, rotation: .down),
                    .landscapeLeft: getDeviceFrame(name, rotation: .left),
                    .landscapeRight: getDeviceFrame(name, rotation: .right)]
        case .iphone12mini:
            return [.portrait: getDeviceFrame(name),
                    .upsideDown: getDeviceFrame(name, rotation: .down),
                    .landscapeLeft: getDeviceFrame(name, rotation: .left),
                    .landscapeRight: getDeviceFrame(name, rotation: .right)]
        case .iphone12pro:
            return [.portrait: getDeviceFrame(name),
                    .upsideDown: getDeviceFrame(name, rotation: .down),
                    .landscapeLeft: getDeviceFrame(name, rotation: .left),
                    .landscapeRight: getDeviceFrame(name, rotation: .right)]
        case .iphone12promax:
            return [.portrait: getDeviceFrame(name),
                    .upsideDown: getDeviceFrame(name, rotation: .down),
                    .landscapeLeft: getDeviceFrame(name, rotation: .left),
                    .landscapeRight: getDeviceFrame(name, rotation: .right)]
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

        return image.rotate(rotation)
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

extension Device {
    public func findOrientationBy(screenSize: CGSize) -> DeviceOrientation? {
        for orientation in supportedOrientations {
            if screen[orientation]?.size == screenSize {
                return orientation
            }
        }
        return nil
    }
}

public enum DeviceOrientation: String {
    case portrait
    case upsideDown
    case landscapeLeft
    case landscapeRight

    /// Standard orientation for devices where only one orientation is supported.
    case standard
}
