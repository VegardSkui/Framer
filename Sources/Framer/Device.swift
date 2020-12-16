//
//  Device.swift
//  Framer
//
//  Created by Vegard Skui on 16/12/2020.
//  Copyright © 2020 Vegard Skui. All rights reserved.
//

import Foundation

enum Devices: Device, CaseIterable {
    case iphone12
    case iphone12mini
    case iphone12pro
    case iphone12promax
    
    var name: String {
        switch self {
        case .iphone12:
            return "iPhone 12"
        case .iphone12mini:
            return "iPhone 12 mini"
        case .iphone12pro:
            return "iPhone 12 Pro"
        case .iphone12promax:
            return "iPhone 12 Pro Max"
        }
    }
    
    var screen: CGRect {
        switch self {
        case .iphone12:
            return CGRect(x: 100, y: 90, width: 1170, height: 2532)
        case .iphone12mini:
            return CGRect(x: 100, y: 90, width: 1125, height: 2436)
        case .iphone12pro:
            return CGRect(x: 100, y: 90, width: 1170, height: 2532)
        case .iphone12promax:
            return CGRect(x: 100, y: 100, width: 1284, height: 2778)
        }
    }
    
    static func findBy(name: String) -> Device? {
        Devices.allCases.first { device in
            device.name == name
        }
    }
    
    static func findBy(screenSize: CGSize) -> Device? {
        Devices.allCases.first { device in
            device.screen.size == screenSize
        }
    }
}

protocol Device {
    /// The device's name.
    var name: String { get }
    
    /// The rectangle describing the size and position of the device's screen in
    /// pixels (not points).
    var screen: CGRect { get }
}
