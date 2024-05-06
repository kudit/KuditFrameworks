//
//  UIView.swift
//  KuditFrameworks
//
//  Created by Ben Ku on 10/11/16.
//  Copyright © 2016 Kudit. All rights reserved.
//
// TODO: perhaps remove from code since not available in visionOS?
// TODO: Perhaps make a SwiftUI method that is `.screenshottable()` that would allow KuditFrameworks to get screenshot.  Do at Window level??

#if canImport(UIScreen)
import UIKit

extension UIView {
    /// render the view and subviews into a UIImage
    func snapshot() -> UIImage {
        UIGraphicsBeginImageContextWithOptions(self.layer.frame.size, false, UIScreen.main.scale) // contentDeviceScale is often 1.0 for primary UIViews
        self.layer.render(in: UIGraphicsGetCurrentContext()!)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image!
    }
}
#endif
