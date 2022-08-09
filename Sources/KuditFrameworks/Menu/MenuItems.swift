//
//  MenuItems.swift
//  KuditFrameworks
//
//  Created by Ben Ku on 5/20/16.
//  Copyright © 2016 Kudit. All rights reserved.
//

import Foundation

/// Use to add some detail or alternate text to an item.
public let MIDetailKey = "detail"
/// Use to store an icon image.
public let MIIconKey = "icon"
/// used to signify the group is a temporary group for a text group.
public let MITextGroupValueKey = "textGroupValue"
/// used to align buttons
public let MITextAlignmentKey = "alignment"

#if canImport(UIKit)
import UIKit
    public typealias MIConfigurationHandler = ((UITextField) -> Void)
    /// Use to add a configuration handler to text fields to configure the text field.  Should be of type MIConfigurationHandler.
    public let MIConfigurationHandlerKey = "configurationHandler"
    public let MITextNormalColorKey = "normalColor"
    public let MITextInvalidColorKey = "invalidColor"
    public typealias MITextAlignment = NSTextAlignment
#else
    public enum MITextAlignment: Int {
        case left = 0, center = 1, right = 2, justified = 3, natural = 4
    }
#endif

open class MenuItem: CustomStringConvertible {
    /// a title or primary text for the item.
    open var title: String
    /// Can assign additional options, like a detail label, alternate text, or icons for use in various display.  Common keys are `detail` and `icon`.
    open var userInfo: [String: Any]
    public init(
        title: String,
        userInfo: [String: Any] = [String: Any]()
    ) {
        self.title = title
        self.userInfo = userInfo
    }
    public var description: String {
        return "\(title)" + (userInfo[MIDetailKey] == nil ? "" : " (\(userInfo[MIDetailKey]!))")
    }
}

open class MenuLabel: MenuItem {
}

public enum MenuButtonStyle {
    case plain // NOTE: default is okay as enum label but it must be escaped to avoid conflicting with keyword.
    case highlighted
    case cancel
    case destructive
}

open class MenuButton: MenuItem {
    public typealias ButtonAction = (MenuButton) -> MenuReturnAction
    public static let _DEFAULT_ACTION: ButtonAction = {_ in return .dismiss }
    private var _action: ButtonAction
    open var style: MenuButtonStyle
    public init(
        title: String,
        style: MenuButtonStyle = .plain,
        userInfo: [String: Any] = [String: Any](),
        action: @escaping ButtonAction = _DEFAULT_ACTION
    ) {
        _action = action
        self.style = style
        super.init(title: title, userInfo: userInfo)
    }
    /// Use to signal a registered push of the button.  Returns the behavior that should happen after pressing.
    open func trigger() -> MenuReturnAction {
        return _action(self)
    }
    public override var description: String {
        let label = super.description
        switch style {
        case .destructive:
            return "<<\(label)>>"
        case .highlighted:
            return "[[\(label)]]"
        case .cancel:
            return "{{\(label)}}"
        default:
            return "((\(label)))"
        }
    }
}
/// class to hack the function of a button with a separate class for identification/layout purposes.
public class MenuOptionItem: MenuButton {
    public override var description: String {
        if style == .highlighted {
            return "✓ \(title)"
        } else {
            return "  \(title)"
        }
    }
}

open class MenuText: MenuItem {
    public typealias TextAction = (MenuText) -> Void
    private var _action: TextAction
    
    /// for validation
    open var valid = true
    
    private var _text: String

    public init(
        title: String,
        text: String,
        userInfo: [String: Any] = [String: Any](),
        action: @escaping TextAction
    ) {
        _text = text
        _action = action
        super.init(title: title, userInfo: userInfo)
    }
    open var text: String {
        get {
            return _text
        }
        set {
            _text = newValue
            _action(self)
        }
    }
    /// UITextField onchange should set MenuText.text and then check valid to update display.
    public override var description: String {
        return "\(super.description): [\(text)]" + (valid ? "" : "*")
    }
}

open class MenuSwitch: MenuItem {
    public typealias SwitchAction = (MenuSwitch) -> Void
    private var _action: SwitchAction
    private var _on: Bool
    
    public init(
        title: String,
        on: Bool,
        userInfo: [String: Any] = [String: Any](),
        action: @escaping SwitchAction
    ) {
        _on = on
        _action = action
        super.init(title: title, userInfo: userInfo)
    }
    /// Use to set or view the state of the switch.
    open var on: Bool {
        get {
            return _on
        }
        set {
            _on = newValue
            _action(self)
        }
    }
    public override var description: String {
        return "\(super.description) [\(on ? "ON" : "OFF")]"
    }
}

/// submenu
open class MenuGroup: MenuItem {
    open var items = [MenuItem]() {
        didSet {
            _sectionMapVariable = nil
        }
    }
    private var _sectionMapVariable: [MenuGroup]?
    private var _sectionMap: [MenuGroup] {
        if _sectionMapVariable != nil {
            return _sectionMapVariable!
        }
        // build internal map (use MenuGroup class objects to store sections)
        var internalMapping = [MenuGroup(title: "", items: [])] // start with empty section and no items
        for (index, item) in items.enumerated() {
            if item is MenuLabel {
                if index == 0 {
                    internalMapping[0].title = item.title
                } else {
                    internalMapping.append(MenuGroup(title: item.title, items:[]))
                }
            } else {
                internalMapping.last!.items.append(item)
            }
        }
        _sectionMapVariable = internalMapping
        return internalMapping
    }
    
    public init(
        title: String,
        userInfo: [String: Any] = [String: Any](),
        items: [MenuItem]
    ) {
        self.items = items
        super.init(title: title, userInfo: userInfo)
    }
    
    // Table View sectioning of items.  Also, good for creating sub-alert dialogs.
    public var sectionTitles: [String] { // TODO: make sure this is lazilly executed only whenever items changes
        return _sectionMap.map { $0.title }
    }
    
    public var numberOfSections: Int {
        return _sectionMap.count
    }
    
    public func numberOfItems(inSection section: Int) -> Int {
        return _sectionMap[safe: section]?.items.count ?? 0
    }
    
    /// Returns the item at the specified index path.
    /// NOTE: Will crash if index path is invalid.
    public func item(at indexPath: IndexPath) -> MenuItem {
        return _sectionMap[indexPath.section].items[indexPath.item]
    }
    
    public var encapsulatingTextItems: MenuGroup {
        guard self.userInfo[MITextGroupValueKey] == nil else {
            return self
        }
        let newGroup = MenuGroup(title: title, userInfo: userInfo, items: items)
        for (index, item) in newGroup.items.enumerated() {
            switch item {
            case let group as MenuGroup:
                newGroup.items[index] = group.encapsulatingTextItems
            case let text as MenuText:
                // create temporary group wrapper to keep as subitem
                var info = text.userInfo
                info[MITextGroupValueKey] = text.text
                let group = MenuGroup(title: text.title, userInfo: info, items: [])
                let newText = MenuText(title: text.title, text: text.text, userInfo: text.userInfo) {
                    textItem in
                    text.text = textItem.text
                    // back propagate valid value after processing
                    textItem.valid = text.valid
                    // update parent group
                    group.userInfo[MITextGroupValueKey] = textItem.text
                }
                group.items.append(newText)
                newGroup.items[index] = group
            default:
                break
            }
        }
        return newGroup
    }
}

open class MenuOptions: MenuItem {
    public typealias OptionsAction = (MenuOptions) -> Void
    private var _action: OptionsAction
    fileprivate var _returnAction = MenuReturnAction.doNothing

    open var options = [String]()
    
    public init(
        title: String,
        options: [String],
        selectedIndexes: [Int],
        userInfo: [String: Any] = [String: Any](),
        action: @escaping OptionsAction
    ) {
        self.options = options
        self.selectedIndexes = selectedIndexes
        _action = action
        super.init(title: title, userInfo: userInfo)
    }
    open var selectedIndexes = [Int]() {
        didSet {
            _action(self)
        }
    }
    open var selectedValues: [String] {
        return selectedIndexes.map{options[$0]}
    }
    
    /// toggle the selected value at the specified index and triggers any action
    // will trigger action by way of didSet above
    open func toggle(index: Int) {
        if selectedIndexes.contains(index) {
            selectedIndexes.remove(index)
            //selectedIndexes.remove(at: selectedIndexes.index(of: index)!)
        } else {
            selectedIndexes += [index]
        }
    }
    
    /// Create a MenuGroup for this control with the appropriate callbacks and settings
    public func asGroup() -> MenuGroup {
        var items = [MenuItem]()
        for (index, value) in options.enumerated() {
            let selected = selectedIndexes.contains(index)
            items.append(MenuOptionItem(title: value, style: (selected ? .highlighted : .plain), userInfo: [MITextAlignmentKey: MITextAlignment.natural]) {
                field in
                self.toggle(index: index)
                field.style = (field.style == .highlighted ? .plain : .highlighted) // make sure this button still reflects the state of the world.
                return self._returnAction
            })
        }
        return MenuGroup(title: title, userInfo: userInfo, items: items)
    }
    
    public override var description: String {
        var labels = selectedValues
        if labels.count == 0 {
            labels.append("NOTHING SELECTED")
        }
        return "\(super.description): \(labels.joined(separator: ", "))"
    }
}

open class MenuChoice: MenuOptions {
    public typealias ChoiceAction = (MenuChoice) -> MenuReturnAction
    public static let _DEFAULT_ACTION: ChoiceAction = {_ in return .pop }
    private func _perform(action: ChoiceAction) {
        _returnAction = action(self)
    }

    public static let NothingSelected = -1

    public init(
        title: String,
        options: [String],
        selectedIndex: Int,
        userInfo: [String: Any] = [String: Any](),
        action: @escaping ChoiceAction = _DEFAULT_ACTION
    ) {
        var selectedIndexes = [Int]()
        if selectedIndex != MenuChoice.NothingSelected {
            selectedIndexes = [selectedIndex]
        }
        let actionWrapper: OptionsAction = { menuOptions in
            let field = menuOptions as! MenuChoice
            field._perform(action: action)
        }
        super.init(title: title, options: options, selectedIndexes: selectedIndexes, userInfo: userInfo, action: actionWrapper)
    }
    open var selectedIndex: Int {
        get {
            if selectedIndexes.count == 0 {
                return MenuChoice.NothingSelected
            } else {
                return selectedIndexes[0]
            }
        }
        set {
            if newValue == MenuChoice.NothingSelected {
                selectedIndexes = []
            } else {
                selectedIndexes = [newValue]
            }
        }
    }
    open var selectedValue: String {
        return options[selectedIndex]
    }
    open func choose(index: Int) -> MenuReturnAction {
        self.selectedIndex = index
        return _returnAction // saved during wrapped action
    }
    override open func toggle(index: Int) {
        // for use when exporting as group
        _ = choose(index: index) // return action will be set so no need to keep
    }
    // super description works here as there will always be exactly 1 item
}

open class MenuHTML: MenuItem {
    open var html = "<p>Blank</p>"
    public init(
        title: String,
        html: String,
        userInfo: [String: Any] = [String: Any]()
        ) {
        self.html = html
        super.init(title: title, userInfo: userInfo)
    }
}
