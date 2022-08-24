//
//  Graphics.swift
//  Tracker
//
//  Created by Ben Ku on 10/29/20.
//

import Foundation
import CoreGraphics

extension CGRect {
    var center: CGPoint { return CGPoint(x: midX, y: midY) }
}

import SwiftUI

extension CGRect {
    /// Take point from a 0-1 scale in percent to the actual coordinate system specified by the rect
    func adjust(_ unitPoint: UnitPoint) -> CGPoint {
        adjust(x: unitPoint.x, y: unitPoint.y)
    }
    func adjust(x: CGFloat, y: CGFloat) -> CGPoint {
        let adjustedX = x * width
        let adjustedY = y * height
        return CGPoint(x: adjustedX, y: adjustedY)
    }
    /// Take point from a 0-1 scale in percent to the square that fits in this rectangle
    func squaring(_ unitPoint: UnitPoint) -> CGPoint {
        let xorigin = (size.width - squareSize) / 2
        let yorigin = (size.height - squareSize) / 2
        let adjustedX = unitPoint.x * squareSize + xorigin
        let adjustedY = unitPoint.y * squareSize + yorigin
        return CGPoint(x: adjustedX, y: adjustedY)
    }
    var squareSize: CGFloat {
        min(size.width, size.height)
    }
}
