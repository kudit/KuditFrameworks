<img src="/Development/Resources/Assets.xcassets/AppIcon.appiconset/AppIcon.png" height="128">

# KuditFrameworks

Several bits of universal code used in Kudit apps.

## Features

- [x] Debug function and features to quickly turn things on and off.
- [x] Many string and array functions to make things easier.
- [x] Entire Color framework for using and accessing colors in a standard way to wrap NSColor/UIColor and SwiftUI Color in a standard compatible syntax so more generic code can be written about colors without having to delve into OS specifics with multiple features:
    - [x] Ability to create colors based off of CSS strings (hex or RGB/RGBA) or using named HTML colors.
    - [x] Consistent color names across platforms and versions.
    - [x] Ability to get lighter or darker colors or determine if colors are "light" or "dark" to ensure contrasting colors are used.
    - [x] Standard color names for DOT signage colors.
    - [x] Convenient color sets for testing.

## Requirements

- iOS 15.2+ (minimum required for Swift Playgrounds support but able to be run on iPhone 7)
- tvOS 17.0+ (minimum required for Menu)
- watchOS 6.0+ (7.0 minimum required for Label, but may not need)
- macOS 12.0+ (minimum for foregroundStyle (Touchbook running Monterey), also minimum for MotionEffects)
- macCatalyst 14.0+
- visionOS 1.0+

## Known Issues
Known Issues with Device Library.

## Usage

### Debug functions

```Swift
debug("Debug message") // similar to print("Debug message")

debug("Warning message", level: .WARNING)

debug("This message is diabled and won't be printed or logged but may be here to provide a comment or to allow quickly disabling a debug statement without deleting it.", level: .SILENT)
```

### Initialization and version tracking

Add these to the init of your app for enabling test features:

```Swift
// Remove before launch.  This allows a warning to be generated during debugging to help remind the developer to remove before releasing.  Set to false during debugging and true for launch.
if false {
    DebugLevel.currentLevel = .NOTICE
}
Application.track() // make sure version is captured
```

If you have a feature you want to only show in debugging, you can add the following:
```Swift
if DebugLevel.currentLevel == .DEBUG {
    // execute test/debug-only code.  If you have the above check and switch the debug level to something other than .DEBUG, this will be disabled.
}
```

## Installation

### Swift Package Manager

Add package `https://github.com/kudit/KuditFrameworks`

## Attribution

This project may become open source but for now it is the property of Kudit LLC.  Please let us know if you need this in your own project.

## Contributors
The complete list of people who contributed to this project is available [here](https://github.com/kudit/KuditFrameworks/graphs/contributors).
