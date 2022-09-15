//
//  Menu.swift
//  KuditFrameworks
//
//  Created by Ben Ku on 5/20/16.
//  Copyright © 2016 Kudit. All rights reserved.
//
/*
Something that exposes all the NSUserDefaults?

Make Menu factory that takes a dictionary and creates controls that modify said dictionary (like NSUserDefaults)

NOTE: Make sure you don't try to change the field's value in the action or you may end up with an infinite loop!

 
 TODO: REMOVE ALL THIS CODE (SwiftUI essentially does all this but better and more supported).
 Figure out how to replicate KuditConnect functions without any of this code.
 
*/

import Foundation

public typealias Menu = [MenuItem]

/// indicates what should happen when an action is invoked
public enum MenuReturnAction {
    case doNothing
    case pop
    case dismiss
    case dismissThen(() -> Void)
}


/// Class for use in testing renderers
public class MenuTest {
    public static var switchOn = false
    public static var buttonPresses = 0
    public static var colorIndex = 2
    public static var email = "nobody@nowhere.com"
    public static var container = 0
    public static var flavors = [0]
    
    public static func generate() -> MenuGroup {
        return MenuGroup(title: "Settings", userInfo: [MIDetailKey: "v1.0"], items: [
            MenuLabel(title: "Simple Controls"), // section header
            MenuSwitch(title:"Switch", on: switchOn) {
                field in
                print("\tToggled \(field.title).")
                switchOn = field.on
            },
            MenuButton(title:"Button", style: .plain) {
                field in
                buttonPresses += 1
                print("\t\(field.title) clicked \(buttonPresses) times.")
                return .doNothing
            },
            MenuChoice(title: "Color", options: ["Red","Green","Blue"], selectedIndex: colorIndex) {
                field in
                colorIndex = field.selectedIndex
                print("\t\(field.title) changed to \(field.selectedValue)")
                return .pop
            },
            MenuLabel(title: "Advanced Controls"), // section header
            MenuText(title:"Email", text: email) {
                field in
                email = field.text
                field.valid = field.text.isEmail
                print("\t\(field.title) changed to: \(field.text)")
            },
            // sub-menu
            MenuGroup(title: "Ice Cream Favorites", items: [
                MenuChoice(title: "Container", options:["Waffle Cone","Cup","Sugar Cone"], selectedIndex: container) {
                    field in
                    container = field.selectedIndex
                    print("\t\(field.title) changed to \(field.selectedValue)")
                    return .pop
                },
                MenuOptions(title: "Flavor(s)", options:["Strawberry","Vanilla","Chocolate","Mango","Cotton Candy"], selectedIndexes: flavors) {
                    field in
                    flavors = field.selectedIndexes
                    print("\t\(field.title) now: \(field.selectedValues)")
                },
                ]),
            ])
    }
}
