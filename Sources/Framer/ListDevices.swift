//
//  ListDevices.swift
//  Framer
//
//  Created by Vegard Skui on 19/12/2020.
//  Copyright © 2020 Vegard Skui. All rights reserved.
//

import ArgumentParser
import FramerLib

struct ListDevices: ParsableCommand {
    static var configuration = CommandConfiguration(
        abstract: "List available devices."
    )

    @Flag(name: .customShort("r"), help: "Show supported orientations for each device.")
    var showOrientations: Bool = false

    func run() {
        if showOrientations {
            Devices.allCases.forEach { device in
                let orientations = device.supportedOrientations.map({ $0.rawValue }).joined(separator: ", ")
                print("\(device.name) - \(orientations)")
            }
        } else {
            Devices.allCases.forEach { device in
                print(device.name)
            }
        }
    }
}
