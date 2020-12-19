//
//  CGImage-Extensions.swift
//  FramerLib
//
//  Created by Vegard Skui on 19/12/2020.
//  Copyright © 2020 Vegard Skui. All rights reserved.
//

import Foundation

extension CGImage {
    func rotate(_ rotation: Rotation) -> CGImage? {
        let swapWidthAndHeight = [.left, .right].contains(rotation)
        let angle = CGFloat(rotation.rawValue)*0.5*CGFloat.pi

        let width: Int
        let height: Int
        if swapWidthAndHeight {
            width = self.height
            height = self.width
        } else {
            width = self.width
            height = self.height
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

        // Move the origin to the center such that the rotation is around the center
        context.translateBy(x: CGFloat(width)/2, y: CGFloat(height)/2)

        context.rotate(by: angle)

        // Move the origin back before drawing the image to fill
        if swapWidthAndHeight {
            context.translateBy(x: -CGFloat(height)/2, y: -CGFloat(width)/2)
        } else {
            context.translateBy(x: -CGFloat(width)/2, y: -CGFloat(height)/2)
        }

        context.draw(self, in: CGRect(x: 0, y: 0, width: self.width, height: self.height))

        return context.makeImage()
    }
}

enum Rotation: Int {
    // The backing int value is used to calculate the angle, see `CGImage.rotate`.
    case up = 0
    case left = 1
    case down = 2
    case right = 3
}
