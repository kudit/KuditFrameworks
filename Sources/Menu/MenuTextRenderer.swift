//
//  MenuTextRenderer.swift
//  KuditFrameworks
//
//  Created by Ben Ku on 9/18/16.
//  Copyright © 2016 Kudit. All rights reserved.
//

import Foundation

public struct MenuTextRenderer {
	private var _map = [Int: MenuItem]()
	private var _stack = [MenuGroup]() {
		// anytime the stack is updated, update the map so even if we don't draw the interface, the actions can be chosen
		didSet {
			_remap()
		}
	}
	private mutating func _remap() {
		// reset map
		_map.removeAll()
		guard let group = _stack.last else {
			return
		}
		let items = group.items
		// start numbering at 1 because humans using (plus 0 signifies back)
		var option = 1
		for item in items {
			if !(item is MenuLabel) {
				_map[option] = item
				option += 1
			}
		}
	}
	
	public init(root: MenuGroup) {
		_stack.append(root)
		_remap() // since didSet not called during init
	}
	public mutating func draw() {
		print("------------------------------")
		guard let group = _stack.last else {
			print("Should not get empty menu!")
			return
		}
		print(group)
		print("------------------------------")
		if _stack.count > 1 {
			print("0) < Back")
		}
		let items = group.items
		// start numbering at 1 because humans using (plus 0 signifies back)
		for item in items {
			var line = ""
			if let option = _map.key(for: item) {
				line = "\(option)) "
			}
			switch item {
			case let textItem as MenuText:
				line += "\(item.description)"
				if !textItem.valid {
					line += " << PROBLEM"
				}
			case is MenuGroup, is MenuOptions:
				line += "\(item.description)…"
			default:
				line += item.description
			}
			print(line)
		}
	}
	
	/// helper function for popping out of stack or "exiting"
	private mutating func _handle(returnAction: MenuReturnAction) {
		if case .doNothing = returnAction { } else {
			_optionsItem = nil
		}
		switch returnAction {
		case .dismissThen(let block):
			_stack.removeAll()
			block()
		case .dismiss:
			_stack.removeAll()
		case .pop:
			_ = _stack.popLast()
		default:
			break
		}
	}
	/// temporary value when showing a temporary options menu
	private var _optionsItem: MenuOptions?
	
	/// TODO: perform the action specified.  Parse the string to get the menu number or use the text.
	public mutating func action(_ text: String = "") {
		if text.isNumeric {
			
		}
	}
	/// perform the action currently indicated by the index.  If there is a text change, provide the text.
	public mutating func action(_ option: Int, text: String = "") {
		if option == 0 {
			_handle(returnAction: .pop)
			return
		}
		guard let item = _map[option] else {
			print("••Invalid Selection••")
			return
		}
		print("\n> Selecting action \(option)")
		switch item {
		case let button as MenuButton:
			_handle(returnAction: button.trigger())
		case let switchItem as MenuSwitch:
			switchItem.on = !switchItem.on
		case let textItem as MenuText:
			textItem.text = text
		case let groupItem as MenuGroup:
			// show submenu
			_stack += [groupItem]
		case let optionsItem as MenuOptions:
			_stack += [optionsItem.asGroup()]
		default:
			print("Unsupported menu options item!")
		}
	}
}
