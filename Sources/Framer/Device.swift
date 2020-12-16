//
//  Device.swift
//  Framer
//
//  Created by Vegard Skui on 16/12/2020.
//  Copyright © 2020 Vegard Skui. All rights reserved.
//

import Foundation

enum Devices: Device, CaseIterable {
    case iphone12pro
    case iphone12promax
    
    var name: String {
        switch self {
        case .iphone12pro:
            return "iPhone 12 Pro"
        case .iphone12promax:
            return "iPhone 12 Pro Max"
        }
    }
    
    var screen: CGRect {
        switch self {
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
}

protocol Device {
    /// The device's name.
    var name: String { get }
    
    /// The rectangle describing the size and position of the device's screen in
    /// pixels (not points).
    var screen: CGRect { get }
}
