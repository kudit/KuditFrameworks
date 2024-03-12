# KuditFrameworks

Several bits of universal code used in Kudit apps.

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
