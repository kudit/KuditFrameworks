//
//  MenuTableViewRenderer.swift
//  KuditFrameworks
//
//  Created by Ben Ku on 9/18/16.
//  Copyright © 2016 Kudit. All rights reserved.
//

#if canImport(UIKit)
import Foundation

import UIKit

public extension UIViewController {
    @objc func simplyDismiss() {
        self.dismiss(animated: true)
    }
}


public extension MenuGroup {
    var navigationController: UINavigationController {
        let navigationController = UINavigationController()
        let menuController = MenuTableViewController(self)
        navigationController.pushViewController(menuController, animated: false)
        menuController.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .done, target: menuController.view.window?.rootViewController, action: #selector(UIViewController.simplyDismiss))
        return navigationController
        // KuditConnect.keyWindow?
    }
}

extension UIControl {
    func removeAllTargetActions() {
        // TODO: clean out block runners
        self.removeTarget(nil, action: nil, for: .allEvents)
    }
    class KuditBlockRunner {
        var block: () -> Void
        init(_ block: @escaping () -> Void) {
            self.block = block
        }
        @objc func runBlock() {
            block()
        }
    }
    func addHandler(_ controlEvents: UIControl.Event, block: @escaping () -> Void) {
        let runner = KuditBlockRunner(block) // TODO: may need somethign to keep this around (perhaps a static array?)
        self.addTarget(runner, action: #selector(KuditBlockRunner.runBlock), for: controlEvents)
        setAssociatedObject(runner, forKey: "runner"); // only allows one, but that's okay for now
    }
}

fileprivate enum CellIdentifier: String {
    case cell = "Cell", valueCell = "ValueCell"
}
fileprivate extension MenuItem {
    /// Helper for getting identifiers below
    var cellIdentifier: CellIdentifier {
        if self is MenuLabel || self is MenuButton || self is MenuText {
            return CellIdentifier.cell
        } else {
            return CellIdentifier.valueCell
        }
    }
}

/// UITableViewController-based renderer
public class MenuTableViewController: UITableViewController {
    // TODO: add inline picker option?  date picker option?
    class MenuTableViewCell: UITableViewCell, UITextFieldDelegate {
        class func _style() -> UITableViewCell.CellStyle { return .default }
        var textField: UITextField?
        fileprivate func _configure() {
            textLabel?.text = menuItem.title
            detailTextLabel?.text = nil
            if let image = menuItem.userInfo[MIIconKey] as? UIImage {
                imageView?.image = image.scaledToSize(CGSize(width: 30, height: 30)).asTemplate
            } else if let imageName = menuItem.userInfo[MIIconKey] as? String {
                imageView?.image = KuImage.named(imageName)?.scaledToSize(CGSize(width: 30, height: 30)).asTemplate
            } else {
                imageView?.image = nil
            }
            accessoryType = .none
            selectionStyle = .none
            accessoryView = nil
            if let alignment = menuItem.userInfo[MITextAlignmentKey] as? NSTextAlignment {
                textLabel?.textAlignment = alignment
            } else if menuItem is MenuButton {
                // default style for buttons should be centered
                textLabel?.textAlignment = .center
            } else {
                textLabel?.textAlignment = .natural
            }
            switch menuItem {
            case let buttonItem as MenuButton:
                if buttonItem.style == .highlighted {
                    accessoryType = .checkmark
                }
                selectionStyle = .blue
            case let mi as MenuText:
                if textField == nil {
                    textField = UITextField(frame: CGRect(x: 0, y: 0, width: 1000.0, height: 30.0));
                    textField!.translatesAutoresizingMaskIntoConstraints = false
                    textField!.clearButtonMode = .whileEditing
                    textField!.contentVerticalAlignment = .center
                    textField!.setContentCompressionResistancePriority(UILayoutPriority.defaultHigh, for: .horizontal)
                    self.contentView.addSubview(textField!)
                    let views = ["textField": textField!] as [String : Any]
                    self.contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-[textField]-|", options: .alignAllCenterY, metrics: [:], views: views))
                    self.contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-[textField]-|", options: .alignAllCenterX, metrics: [:], views: views))
                    textField!.delegate = self
                }
                textLabel?.text = nil // hide main label so accessory view can take up full width
                textField!.text = mi.text
                // assume initial text is valid
                textField!.placeholder = mi.text
                // pre-configure
                if mi.userInfo[MITextNormalColorKey] == nil {
                    mi.userInfo[MITextNormalColorKey] = textLabel?.textColor
                }
                if mi.userInfo[MITextInvalidColorKey] == nil {
                    mi.userInfo[MITextInvalidColorKey] = UIColor.red
                }
                if let handler = mi.userInfo[MIConfigurationHandlerKey] as? MIConfigurationHandler {
                    handler(textField!)
                }
                // make sure text is colored appropriately
                _updateTextValue(textField: textField!, text: mi.text)
            default:
                break
            }
        }
        var menuItem = MenuItem(title: "Placeholder") {
            didSet {
                _configure()
            }
        }
        
        // set default style
        override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
            super.init(style: type(of: self)._style(), reuseIdentifier: reuseIdentifier)
        }
        
        // required so just pass on up
        required init?(coder aDecoder: NSCoder) {
            super.init(coder: aDecoder)
        }

        // handle text field return button and updating the model
        func textFieldShouldReturn(_ textField: UITextField) -> Bool {
            textField.resignFirstResponder()
            return false
        }
        private func _updateTextValue(textField: UITextField, text: String) {
            let textItem = menuItem as! MenuText // if this isn't a text item, then we should crash
            // initial value of empty is
            textItem.text = text
            if !textItem.valid {
                textField.textColor = textItem.userInfo[MITextInvalidColorKey] as? UIColor
            } else {
                textField.textColor = textItem.userInfo[MITextNormalColorKey] as? UIColor
            }
        }
        func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
            let newText = textField.text!.replacingCharacters(in: range, with: string)
            _updateTextValue(textField: textField, text: newText)
            return true
        }
        private var _dismissing = false
        func textFieldDidEndEditing(_ textField: UITextField) {
            // trigger value changed
            _updateTextValue(textField: textField, text: textField.text!)
//            if let textItem = menuItem as? MenuText { // causes problems when hitting the back button with invalid text.  Should propmpt for option?
//                if !textItem.valid && !_dismissing {
//                    textField.becomeFirstResponder() // don't let end editing if invalid
//                    // TODO: shake head animation?
//                }
//            }
        }
        deinit {
            if textField != nil {
                _dismissing = true
                self.becomeFirstResponder() // dismiss any text fields and trigger end editing
            }
        }
    }
    class MenuTableViewValueCell: MenuTableViewCell {
        override class func _style() -> UITableViewCell.CellStyle { return .value1 }
        var switchControl: UISwitch?
        override func _configure() {
            super._configure()
            switch menuItem {
            case let switchItem as MenuSwitch:
                // add in switch control
                if self.switchControl == nil {
                    self.switchControl = UISwitch()
                }
                let switchControl = self.switchControl!
                switchControl.onTintColor = self.tintColor
                self.accessoryView = switchControl
                switchControl.removeAllTargetActions()
                // TODO: replace on with isOn for consistency
                switchControl.isOn = switchItem.on
                switchControl.addHandler(.valueChanged) {
                    switchItem.on = switchControl.isOn
                }
            case let mi as MenuOptions:
                accessoryType = .disclosureIndicator
                detailTextLabel!.text = mi.selectedValues.joined(separator: ", ")
                selectionStyle = .blue
            case let mi as MenuChoice:
                accessoryType = .disclosureIndicator
                detailTextLabel!.text = mi.selectedValue
                selectionStyle = .blue
            case let group as MenuGroup:
                if group.userInfo[MITextGroupValueKey] != nil {
                    detailTextLabel!.text = group.userInfo[MITextGroupValueKey] as? String
                }
                accessoryType = .disclosureIndicator
                selectionStyle = .blue
            default:
                break
            }
        }
    }
    
    /// The data model for the controller.
    var menuGroup = MenuGroup(title: "Placeholder", items: [])
    public init(_ menuGroup: MenuGroup) {
        // move text items into it's own sub-group by itself like Settings app
        self.menuGroup = menuGroup.encapsulatingTextItems
        super.init(style: .grouped)
    }
    
    // required to override init
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    // register the table cell class
    override public func viewDidLoad() {
        super.viewDidLoad()
        tableView.register(MenuTableViewCell.self, forCellReuseIdentifier: CellIdentifier.cell.rawValue)
        tableView.register(MenuTableViewValueCell.self, forCellReuseIdentifier: CellIdentifier.valueCell.rawValue)
        self.title = menuGroup.title
        if let info = menuGroup.userInfo[MIDetailKey] as? String {
            self.navigationItem.leftBarButtonItem = UIBarButtonItem(title: info, style: .plain, target: nil, action: nil)
            self.navigationItem.leftBarButtonItem?.isEnabled = false
        }
    }
    
    public override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tableView.reloadData()
    }
    
    public override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        // make sure keyboard comes up automatically
        for cell in self.tableView.visibleCells {
            if let textField = (cell as! MenuTableViewCell).textField {
                textField.becomeFirstResponder()
                break
            }
        }
    }
    
    // reset the cell value to the initial value if we're cancelling and the value is empty.  Do on willDisappear because we need to set the value of the group before the view is rendered.
    public override func viewWillDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        // make sure keyboard comes up automatically
        for cell in self.tableView.visibleCells {
            let menuCell = cell as! MenuTableViewCell // okay since MenuTableViewValueCell is subclass of MenuTableViewCell
            if let textField = menuCell.textField, textField.text == "", let textItem = menuCell.menuItem as? MenuText {
                textField.text = textField.placeholder ?? ""
                // will likely set on resigning first responder, but we can assign here too just in case
                textItem.text = textField.text ?? ""
            }
        }
    }
    
    // MARK: - Table View Data Source
    override public func numberOfSections(in tableView: UITableView) -> Int {
        // Return the number of sections.
        return menuGroup.numberOfSections
    }
    
    override public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // Return the number of rows in the section.
        return menuGroup.numberOfItems(inSection: section)
    }
    
    override public func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return menuGroup.sectionTitles[section]
    }
    
    override public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // get menu item
        let item = menuGroup.item(at: indexPath)
        
        let cell = tableView.dequeueReusableCell(withIdentifier: item.cellIdentifier.rawValue, for: indexPath) as! MenuTableViewCell
        
        // Configure the cell...
        cell.menuItem = item
        
        return cell
    }
    
    private func _dismiss(block: (() -> Void)? = nil) {
        self.navigationController?.presentingViewController?.dismiss(animated: true, completion: block)
    }

    private func _pop() {
        if self == self.navigationController?.viewControllers[0] {
            _dismiss()
        } else {
            _ = self.navigationController?.popViewController(animated: true)
        }
    }
    
    // MARK: - Table view delegate
    override public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // Navigation logic may go here. Create and push another view controller.
        // get menu item
        let item = menuGroup.item(at: indexPath)
        if let buttonItem = item as? MenuButton {
            switch buttonItem.trigger() {
            case .dismissThen(let block):
                _dismiss(block: block)
            case .dismiss:
                _dismiss()
            case .pop:
                _pop()
            default:
                tableView.reloadRows(at: [indexPath], with: .fade)
                break
            }
            return
        }
        var groupItem: MenuGroup
        if let optionsItem = item as? MenuOptions { // (MenuChoice is MenuOptions)
            groupItem = optionsItem.asGroup()
        } else if item is MenuGroup {
            groupItem = item as! MenuGroup
        } else { // TODO: WebViewController for FAQ or other things?
            return // do nothing
        }
        // Pass the selected object to the new view controller.
        let detailViewController = MenuTableViewController(groupItem)
        self.navigationController!.pushViewController(detailViewController, animated:true)
    }
}
#endif
