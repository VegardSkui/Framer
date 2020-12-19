//
//  FramerTests.swift
//  FramerTests
//
//  Created by Vegard Skui on 19/12/2020.
//  Copyright © 2020 Vegard Skui. All rights reserved.
//

import XCTest
@testable import FramerLib

final class FramerTests: XCTestCase {
    func testFindDeviceByName() throws {
        let result = Devices.findBy(name: "iPhone 12")
        XCTAssertNotNil(result)
        XCTAssertEqual(result?.screen, Devices.iphone12.screen)
    }

    func testFindDeviceBySizePortrait() throws {
        let result = Devices.findBy(screenSize: CGSize(width: 1284, height: 2778))
        XCTAssertNotNil(result)
        XCTAssertEqual(result?.0.name, "iPhone 12 Pro Max")
        XCTAssertEqual(result?.1, .portrait)
    }

    func testFindDeviceBySizeLandscape() throws {
        let result = Devices.findBy(screenSize: CGSize(width: 2778, height: 1284))
        XCTAssertNotNil(result)
        XCTAssertEqual(result?.1, .landscapeLeft)
    }
}
