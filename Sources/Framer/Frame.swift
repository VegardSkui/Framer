//
//  Frame.swift
//  Framer
//
//  Created by Vegard Skui on 19/12/2020.
//  Copyright © 2020 Vegard Skui. All rights reserved.
//

import Foundation
import ArgumentParser
import FramerLib

struct Frame: ParsableCommand {
    static var configuration = CommandConfiguration(
        abstract: "Add device frames to screenshots.",
        discussion: """
        If not specified manually, the program tries to detect the correct device and
        orientation automatically based on the dimensions of the input image.
        Use 'framer list-devices -r' to list all available devices and orientations.
        """
    )

    @Option(name: .shortAndLong, transform: { argument in
        guard let device = Devices.findBy(name: argument) else {
            throw ValidationError("Device not found.")
        }
        return device
    })
    var device: Device?

    @Option(name: [.customShort("r"), .long])
    var orientation: DeviceOrientation?

    @Option(name: .shortAndLong, help: "Override default output path.")
    var output: String?

    @Argument(help: "PNG screenshot to frame.")
    var path: String

    func run() throws {
        guard let screenshot = loadImage(at: path) else {
            print("Could not load image.")
            throw ExitCode.failure
        }

        // Automatically detect the correct device based on the screenshot's
        // size, if not provided by the user
        let device: Device
        let orientation: DeviceOrientation
        if self.device == nil {
            if self.orientation != nil {
                print("Warning: --orientation option is ignored since --device is not set.")
            }

            let screenshotSize = CGSize(width: screenshot.width, height: screenshot.height)
            guard let detectedDevice = Devices.findBy(screenSize: screenshotSize) else {
                print("Could not detect device based on screenshot size.")
                throw ExitCode.failure
            }
            device = detectedDevice.0
            orientation = detectedDevice.1
        } else {
            device = self.device!

            if self.orientation == nil {
                let screenshotSize = CGSize(width: screenshot.width, height: screenshot.height)
                if let detectedOrientation = device.findOrientationBy(screenSize: screenshotSize) {
                    orientation = detectedOrientation
                } else {
                    print("Warning: Could not detect orientation based on screenshot size, result may be wrong.")
                    orientation = self.device!.supportedOrientations.first!
                }
            } else {
                orientation = self.orientation!
                if !device.supportedOrientations.contains(orientation) {
                    print("Error: Orientation '\(orientation)' is not supported for '\(device.name)'.")
                    throw ExitCode.validationFailure
                }
            }
        }

        guard let framer = ScreenshotFramer(for: device, orientation: orientation) else {
            print("Could not create screenshot framer.")
            throw ExitCode.failure
        }

        let result = try framer.frame(screenshot)

        let destinationPath = getDestinationPath()

        try save(image: result, to: destinationPath)

        print("Framed '\(device.name)' (\(orientation)) screenshot saved to '\(destinationPath)'.")
    }

    func loadImage(at path: String) -> CGImage? {
        guard let provider = CGDataProvider(filename: path) else {
            return nil
        }

        guard let image = CGImage(pngDataProviderSource: provider,
                                  decode: nil,
                                  shouldInterpolate: false,
                                  intent: .defaultIntent) else {
            return nil
        }

        return image
    }

    func save(image: CGImage, to path: String) throws {
        let url = URL(fileURLWithPath: path)

        guard let destination = CGImageDestinationCreateWithURL(url as CFURL, kUTTypePNG, 1, nil) else {
            print("Could not create destination.")
            throw ExitCode.failure
        }
        CGImageDestinationAddImage(destination, image, nil)
        let success = CGImageDestinationFinalize(destination)

        if !success {
            print("Could not save image.")
            throw ExitCode.failure
        }
    }

    func getDestinationPath() -> String {
        let filename: String
        if path.lowercased().hasSuffix(".png") {
            filename = "\(path.dropLast(4))-framed.png"
        } else {
            filename = "\(path)-framed.png"
        }

        if let output = output {
            var url = URL(fileURLWithPath: output)

            // If the user manually pointed to a directory, append the generated
            // filename, if not, just use the path provided
            if url.hasDirectoryPath {
                url.appendPathComponent(filename)
            }
            return url.path
        } else {
            // Use the generated filename and place the file in the same
            // directory if the user did not specify an output
            return filename
        }
    }
}

extension DeviceOrientation: ExpressibleByArgument {}
