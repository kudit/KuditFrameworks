//
//  MenuAlertRenderer.swift
//  KuditFrameworks
//
//  Created by Ben Ku on 9/18/16.
//  Copyright © 2016 Kudit. All rights reserved.
//

#if canImport(UIKit) && !os(watchOS) && !os(tvOS)
import Foundation

import UIKit

public extension MenuButtonStyle {
    var alertActionStyle: UIAlertAction.Style {
        switch self {
        case .plain, .highlighted:
            return .default
        case .cancel:
            return .cancel
        case .destructive:
            return .destructive
        }
    }
}

/// Alert-based renderer
public extension UIViewController {
    func alert(_ group: MenuGroup) {
        MenuAlertRenderer.present(group, from: self) // creates and presents group
    }
}

fileprivate class MenuAlertRenderer {
    private static let shared = MenuAlertRenderer() // hold on to reference so it doesn't go away
    private typealias UIAlertActionAction = ((UIAlertAction) -> MenuReturnAction)
    private var _stack = [MenuGroup]()
    private var _presentingController: UIViewController?

    init() {}
    
    fileprivate static func present(_ group: MenuGroup, from: UIViewController) {
        // Add to the stack to allow for unwinding through the menus and re-displaying menus as needed.
        shared._stack = [group.encapsulatingTextItems] // make sure stack is clear other than this
        shared._presentingController = from
        shared.alert()
    }

    private func alert(animated: Bool = true) {
        guard let group = _stack.last else {
            // Stack is empty!  Must be done!
            return
        }
        // check to see if this can be or needs to be an alert style
        var hasText = false
        var numButtons = 0
        var description = group.userInfo[MIDetailKey] as? String ?? ""
        /// NOTE: labels are added to the description in this style
        for child in group.items {
            switch child {
            case is MenuText:
                hasText = true
            case let c as MenuLabel:
                description += (description.isEmpty ? "" : "\n") + c.description
            default:
                numButtons += 1
            }
        }
        // determine the appropriate style
        let alertStyle: UIAlertController.Style
        if hasText || numButtons < 4 {
            alertStyle = .alert
        } else {
            alertStyle = .actionSheet
        }
        // create the controller
        let alertController = UIAlertController(
            title: group.title,
            message: description,
            preferredStyle: alertStyle)
        
        let items = group.items + [MenuButton(title: "Done", style: .cancel) { _ in return .pop }]
        
        var textItems = [MenuText]() // text items are forced to the end
        
        for child in items {
            var style = UIAlertAction.Style.default
            var action: UIAlertActionAction
            var title = child.description
            switch child {
            // TODO: check for other advanced controls like switches?
            case let button as MenuButton:
                action = {_ in return button.trigger() }
                style = button.style.alertActionStyle
                title = (button.style == .highlighted ? "✔ \(child.title)" : child.title)
            case let switchItem as MenuSwitch:
                action = {_ in
                    switchItem.on = !switchItem.on
                    return .doNothing
                }
                title = child.title + (switchItem.on ? "☑︎" : "☐")
            case is MenuOptions, is MenuGroup:
                // get group (no need to modify labels as the highlighted style will suffice)
                let group: MenuGroup
                if let options = child as? MenuOptions {
                    group = options.asGroup()
                } else {
                    group = child as! MenuGroup
                }
                action = {_ in
                    self._stack.append(group)
                    self.alert()
                    return .dismiss
                }
                title += "…"
            case let textItem as MenuText:
                alertController.addTextField {
                    textField in
                    textField.text = textItem.text + (textItem.valid ? "" : "*invalid*")
                    if let handler = textItem.userInfo[MIConfigurationHandlerKey] as? MIConfigurationHandler {
                        handler(textField)
                    }
                }
                textItems.append(textItem)
                continue
            case is MenuLabel:
                continue // ignore labels
            default:
                print("MenuItem type found that was not handled. \(child)")
                continue // Breakpoint to catch any class types we may have missed.
            }
            alertController.addAction(UIAlertAction(title: title, style: style) {
                alertAction in
                for index in 0..<textItems.count {
                    // set text to trigger any actions before passing through
                    if let text = alertController.textFields?[index].text {
                        textItems[index].text = text
                    }
                }
                switch action(alertAction) {
                case .pop:
                    _ = self._stack.popLast()
                    self.alert()
                case .doNothing:
                    self.alert(animated: false) // should show menu again but no need to animate to prevent odd visuals
                case .dismiss:
                    return
                    // do nothing and let the alerts go away
                case .dismissThen(let block):
                    block()
                    return
                }
            })
        }
        _presentingController!.present(alertController, animated: animated, completion: nil)
    }
}
#endif
