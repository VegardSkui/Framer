//
//  main.swift
//  Framer
//
//  Created by Vegard Skui on 16/12/2020.
//  Copyright © 2020 Vegard Skui. All rights reserved.
//

import ArgumentParser

struct Framer: ParsableCommand {
    static var configuration = CommandConfiguration(
        version: "0.2",
        subcommands: [Frame.self, ListDevices.self],
        defaultSubcommand: Frame.self
    )
}

Framer.main()
