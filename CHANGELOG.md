# ChangeLog

v4.2.7 3/11/2024 Fixed KuditConnectMenu (for real this time).  Added tests to verify.
v4.2.6 3/11/2024 Fixed issue with blurred not being able to be type checked in reasonable time.
v4.2.5 3/11/2024 Updated documentation.  Fixed so that KuditConnectMenu can be invoked without a label as before.  Updated debug so that we can add breakpoints in code.  Added color convenience for autocomplete from a color set.
v4.2.4 3/8/2024 Changed from DeviceKit to new Device framework for easier maintenance and usage.  Improved KuditConnectMenu to work just like SwiftUI Menu.  Updated KuditConnect for use on visionOS.  Added ability to pass custom label to KuditConnectMenu.  Added visionOS Icon asset.
v4.2.3 2/10/2024 Added Application.iCloudSupported = false as option to prevent hanging on simple visionOS apps that don't really care about iCloud.  Re-worked Application description to be more consistent with the support email.
v4.2.2 2/4/2024 Consolidated Package.swift files so that we only need to maintain one version that works in both Playgrounds and as a package.  Changed framework color to Red.  Moved test files out of unnecessary wrapper folder.  Added Development folder for example app code.  Updated TestView to use standard Test list.  Moved CHANGELOG.md to root.
v4.2.1 1/31/2024 Fixed shadow Package files to update swift version to 5.9. Updated colors to include named lightGray and darkGray and changed order from black to white to white to black.
v4.2 1/31/2024 Added legal notice to the bottom of the FAQ section including links to privacy policy and terms of use for App Store subscription compliance.  Added attribution credit to included packages.  Updated swift tools version to 5.9 to support visionOS.  Added support for macOS and visionOS.  Fixed ColorBarView not being public (also renamed from ColorBar).  Updating DeviceKit to support visionOS.  Updated vibration code to make sure uses simple audio feedback on visionOS.
v4.1.2 1/21/2024 Fixed missing public initializer for RadialStack.
v4.1.1 1/21/2024 Added public to optional nil coalescing that was missing in previous version.  Added tests for operations mixing Double and Int.  Updated package dependencies.  Fixed public missing to initializers for OverlappingHStack.  Fixed so RadialStack works since RadialLayout seems to not work in framework.  Updated version of Kudit's version of DeviceKit to make sure included.  Updated dependency.
v4.1.0 1/19/2024 Fixed line break issues with the app info section.  Removed KuditConnect version from menu.  Made app version smaller and grouped with KuditConnect info via section Header.  Made `Testable` framework public so we can include in apps.  Added division and multiplication functions and `doubleValue` for `Int` to support double and float returns when dividing by an `Int`.  Added `average()` and `sum()` functions for numeric collections.  Support displaying string as an alternative in nil coalescing.  Added Color Groups to `KuColor` arrays of colors for easy usage (improved over previous implementation which may require code updates).  Added `RadialLayout`.  Added `OverlappingHStack` and `OverlappingVStack` (fixed so the layout doesn't have a fixed overlap and doesn't scale contents).
v4.0.24 12/22/2023 Updated Application.main.name to include a parenthetical if running in Playground or #Preview.  Added in better loggging level to Application.track() to be clearer where tracked.  Added string literal initialization and assignment of Version.  Removed unnecessary rotate() function since we already have that in ++ function on CaseIterable (made sure that was public as well).
v4.0.23 12/14/2023 Fixed permissions for Array sorting.  Removed unnecessary iCloud logging.
v4.0.22 12/13/2023 Fixed so DebugLevel defaults to .DEBUG and if a message is set to .SILENT it will never print.  Added .SILENT level.  Added colors.  Added emoji for color in console.  Added basic colors to KuColor.  Added rotate() function to DebugLevel for testing and made CaseIterable.  Added array sorting by KeyPath.  Added DebugLevel.colorLogging to KuColor methods so that parsing a string that fails (which might be intentional) doesn't log unnecessarily. Changes merged.
v4.0.21 11/11/2023 Added conditional compiler directives to remove code when importing in watchOS, tvOS, or macOS (non-catalyst) projects.  Updated dependencies to use patched versions.  Ensured compatibility by also using forked versions of projects.
v4.0.20 11/8/2023 Added description to DebugLevels and .isAtLeast() test.  Added additional color logging when conversions don't work.  Replaced several print statements with debugs.  Added inPlayground check.  Added DataStore code.  Added embossed view modifier.
v4.0.19 10/30/2023 Changed Color coding to use .pretty format.
v4.0.18 10/27/2023 Fixed ExternalDisplayManager.shared.orientationPicker not being public.
v4.0.17 10/27/2023 Fixed ExternalDisplayManager.shared not being public.
v4.0.16 10/27/2023 Fixed onRotate not being public.
v4.0.15 10/27/2023 Tried adding public init methods to KuditLogo to allow public init.  Added ExternalDisplayManager code to simplify use in Shout It and Score.  Updated trimming code to be more compatible.  Added pretty version of KuColor for better output.  Fixed HEX output of color to go to FF rather than FE.  Enabled KuditConnectMenu() with no parameters.  Added alpha support for SwiftUI colors now that it's supported (iOS 13+).  Will need to find another way to extract values from SwiftUI color now that cgColor view is deprecated.
v4.0.14 10/27/2023 Fixed so KuditLogo could be public. (didn't work)
v4.0.13 10/27/2023 Fix for missing comma in package causing it not to update.
v4.0.12 10/15/2023 Fixed bug where debug message was showing up in web view FAQ answers.  Default DebugLevel.currentLevel to .DEBUG when DEBUG flag is set and .NOTICE when not (for distribution).  Updated padding and default system font style for FAQ items.  Added Ink dependency for markdown parsing (and support markdown in FAQ items).
v4.0.11 10/13/2023 Previous comment containing HTML seems to break Xcodes ability to include.
v4.0.10 10/13/2023 Added <meta name="viewport" content="width=device-width" /> to FAQ HTML views to make layout and sized better for devices.
v4.0.9 10/12/2023 Truncated Kudit API calls to prevent long URL issues.  Added public visibility for HTMLView.  Re-worked to allow opening URLs in app/external app.  Fixed testing navigation styles to .stack for iPad views.  Deleted WebView since we're not really using that for anything.  Can look through history if you ever need a WebView.  Added HTML cleaning for strings.
v4.0.8 10/11/2023 Added encoding/decoding strategies to dictionary coding.  Added Debug message to KuditConnect for reminder to set DebugLevel.current = .NOTICE (or higher for production).  Re-worked FAQ rendering to use new HTMLView which works better with images and layout.  Added LosslessStringConvertible and KuColor default value constructors to work with possibly empty values to guarantee a return so we don't have to do an optionals dance.
v4.0.7 10/11/2023 Fixed non-public access for KuditConnect.shared to support customizeMessageBody handler.
v4.0.6 10/11/2023 Fixed versioning numbering to support swift package updates.
v4.0.5.1 10/11/2023 Fixed problem with KuditConnect API loader not calling appropriate API (causing Kudos to fail).  Added additional check in Tests to silence warning in Xcode.  Added .build parameter for versioning so development checkins are incrementing the build number, not the patch value.  Fixed byteString to be available on Int64 as well as UInt64.  Fixed issues with KuditConnectMenu initialization setting a value.  Will need to assign separately from now on.  Fixed FAQ animations (were disabled due to Kudos transactions)
v4.0.5 10/10/2023 Shifted the update of FAQs to force on the main thread.  Enabled FAQs to filter by version.  Added Array.pad function.  Created Version struct that is RawRepresentable. Completely shifted Version from String type to custom Version type that will have to be converted to/from String.  Codable conformance SHOULD work.
v4.0.4 10/10/2023 Made coding parameters align with the dictionary and JSON encoders and decoders for easier consistency.  Made sure to add public init functions to allow consistent use.  Fixed frameworks app testing code for FAQs.  Added pull to refresh for FAQs.
v4.0.3 10/10/2023 Made dictionary coding functions public.  Made ParameterEncoding public and static functions.  Included asBool function on String.  Added ability to get Dictionary from a query string.
v4.0.2 10/9/2023 Changing Application.main.appIdentifier to include the full identifier rather than just the last path component.  Not sure why that was like that.  Hopefully doesn't break anything.  Adding debug for additional info when generating mail link so more human readable.  Added appIdentifier to app info. Added appInfo to KuditFrameworksTestView.  Added KuditLogo to view and added color parameter for better sizing and styling.
v4.0.1 10/9/2023 Added additional Date.mysqlDateTimeFormat and Date().mysqlDateTime functions.  Added FAQ feature back to Kudit Connect.  Enabled ability to provide custom Menu code injected into KuditConnect menu.  Added capabilities flag for testing server connections from framework.  Added public modifiers to KuColor functions.  Fixed typo with ParameterEncoding.  Extracted KuditConnect functions from the Views to improve MVC separation.  Added debug code to support mailto link creation.
v4.0.0 10/5/2023 Requires iOS 15 as a base requirement to remove compatibility warnings. Added OffsetObservingScrollView (code only since doesn't appear to be used).  Added in additional code developed for Shout It: Possible breaking change: changed KuColor save format to rgba() format String so that we can include alpha value and increased color ranges.  Generally should still be backwards compatible since this should be able to be converted from String.  Added .contrastingColor and .luminence values to KuColor and added better documentation for redComponent values.  Added device rotation monitoring .onRotate() view modifier.  Added KuditConnect (including KudosView requiring EffectsLibrary and DeviceKit).  Added DictionaryCoding.  Removed JSONOptional since current JSON encoder should be fine.  Updated format of size to W×H.  Removed Hardware and HardwareMap files since we now have DeviceKit.  Re-worked KuColor protocols so that they gain conformance to Codable and have better encoding/decoding methods.  Cleaned up Application class to have less redundancy by using Bundle extensions.  Added parameter encoding.  Added some test code for Date.
v1.0.52 9/10/2023 Added availability checks for URL downloading and image recognizer code.
v1.0.51 8/30/2023 Added ability to include line information when batching and ordering recognized text.
v1.0.50 8/29/2023 Added securing of URL to ensure that images are using HTTPS particularly when downloading.  Fixed line ordering for case where a height might return as 0 so that we always have a minimum non-zero height.
v1.0.49 8/29/2023 Re-worked so that the delta for height is based off of the smallest text block rather than off of the image size for large images and to better match alignment.
v1.0.48 8/28/2023 Fixed debug statements.
v1.0.47 8/28/2023 Re-worked code to be in the proper places with proper public accessibility.  Tweaked download code to throw errors instead of returning optional.
v1.0.46 8/28/2023 Added ImageTextRecognizer code for use in TwoHunts, and Family Feud scraping code (possibly could be used for Deckmaster or other tools in the future).
v1.0.45 7/14/2023 Added additional debug formatting for easier reading in large amounts of debug statements.  Added ability to remove debug output context info.
v1.0.44 7/13/2023 Added default debug level and changed default to .ERROR so that we can set DebugLevel.currentLevel = .ERROR and only get actual errors or debug items that have the default assignement (to force us to include the proper level but allow quick adding of debug code while developing which will show up).
v1.0.43 7/10/2023 Removed snapshot since causes build issues in visionOS.  Added CaseIterable++ function for enums.
v1.0.42 6/13/2023 Restored UIImage functions for Viewer and made WebData JSON class initializers public for Viewer.
v1.0.41 10/29/2022 Tweaked Bundle information to be simpler.  Re-worked testing code.
v1.0.40 10/24/2022 Added Bundle extension for app information.
v1.0.39 9/30/2022 Added -- operator.
v1.0.38 9/22/2022 Made DebugLevel.currentLevel explicitly public to allow setting.
v1.0.37 9/21/2022 Changed DebugLevel.currentLevel to a var instead of let so that it can be changed by apps.
v1.0.36 9/19/2022 Added check for UIKit in share sheet (iMac was unable to build...odd since should support catalyst)
v1.0.35 9/16/2022 Added debugging line info to call site of CustomError to get better reporting of when the error was thrown. Added Codable support to Color.  Added Color documentation and documentation template to Debug.
v1.0.34 9/15/2022 Added credit for the RGB to HSV code.
v1.0.33 9/15/2022 Missed one of the @available(iOS 15.0, \*)
v1.0.32 9/15/2022 Certain colors only available with iOS 15+ so set that as the minimum target for all KuColor stuff.
v1.0.31 9/14/2022 Updated KuColor protocol to apply to SwiftUI Color.  Removed old UIImage code that could cause crashes.  Added .frame(size:) method.  Fixed issue with RGBA parsing and HSV calculations.  Re-worked SwiftUI color conformance to KuColor protocols to simplify.  Added some test methods.  Reversed order of versioning to make easier to find changes.  macOS can use UIKit via Catalyst or SwiftUI so no need to support NSColor.
v1.0.30 9/14/2022 Fixed issue where last two updates were the wrong major version number!
v1.0.29 9/14/2022 Fixed problem with Readme comments continually reverting.  Added @available modifiers to code.  Restored mistakenly uploaded Package file.  Moved some TODOs around.
v1.0.28 9/14/2022 Added signing capabilities for macOS network connections and added note about future dependency on DeviceKit project (replace any usage in KuditHardware since DeviceKit will be more likely updated regularly.)
v1.0.27 9/14/2022 Fixed permissions on methods.  Fixed package versioning and synced package.txt files.
v1.0.26 9/14/2022 Added additional documentation to KuditFrameworks Threading.  Renamed KuError to CustomError.  Added ++ operator.  Added Date.pretty formatter. Added Image(data:Data) import extensions.  Added padding(size:) extension.  Added Color: Codable extensions.  Added Int.ordinal function.  Included deprecated message for KuError.  Added PlusPlus test.  Fixed Playgrounds test with #if canImport(PreviewProvider) to #if canImport(SwiftUI).  Fixed/Added App Icon.
v1.0.25 9/8/2022 Tweaked KuditLogo with some previews that have examples of how it might be used.
v1.0.24 9/8/2022 Removed conditions from ShareSheet as it prevents access on iOS for some reason.
v1.0.23 9/8/2022 Added KuditLogo to framework from Tracker (not perfected yet).  Added preview to KuditFrameworksApp.  Fixed UIActivity missing from Mac (non-catalyst) build.
v1.0.22 8/31/2022 Rearranged test order and shorted sleep test.
v1.0.21 8/31/2022 Moved folders for KuditFrameworks into Sources folder since we already know this is for KuditFrameworks and removes unnecessary nesting.
v1.0.20 8/30/2022 Removed shuffle and random since built-in as part of native Array functions.
v1.0.19 8/29/2022 Re-worked testing framework to be more robust and to allow code coverage tests in Xcode.
v1.0.18 8/26/2022 Added String.sentenceCapitalization.
v1.0.17 8/26/2022 Added public init to ShareSheet.  Added Coding framework. 
v1.0.16 8/25/2022 Made let properties on ShareSheet struct public vars hopefully to silence private init warning. 
v1.0.15 8/25/2022 Checked added frameworks to make sure everything is marked public so usable by ouside code.
v1.0.14 8/24/2022 Added RingedText, ShareSheet, and Graphics code from old Swift Frameworks.
v1.0.13 8/12/2022 Added File and Date and URL comparable code.  Need to migrate NSDate to Date.  
v1.0.12 8/12/2022 changed String.contains() to String.containsAny() to be more clear.  Modified KuError to include public initializer and automatic Debug print.
v1.0.11 8/11/2022 Removed unnecessary KuditFrameworks import from Image.swift.
v1.0.10 8/11/2022 Removed a bunch of KuditConnect and non-critical code since those should be completely re-thought and added in a modern way and there is too much legacy code.
v1.0.9 8/10/2022 Fixed tests to run in Xcode.  Added watchOS and tvOS support.
v1.0.8 8/10/2022 Manually created initializers for SwiftUI views to prevent internal protection errors.
v1.0.7 8/10/2022 Made additional fields for Tests public.
v1.0.6 8/10/2022 Fixed PHP.time() not being public.  Fixed recursive sleep and just eliminated PHP.sleep().  Made Test() init public.  Made TestUI public.
v1.0.5 8/10/2022 Fixed WebView internal permissions (hopefully for real this time?).  Added KuError.custom(String,DebugLevel). Moved data model and asset libraries to Resources to allow compilation and running on iPad.  Moved Compatibility, Debug, and Test frameworks into separate files.
v1.0.4 8/10/2022 Fixed extract(from:to:) to return nil if start or end not found to make it easier to determine if a tag was scraped successfully or not.  Could have done via error throw but it's not really an error so optional makes more sense since the action could fail.  Also removed all Window dependencies (which probably breaks some of the Kudit Connect functionality but that does need to be tested...need to bring in tests from library project).
v1.0.3 8/9/2022 adding in KuditFrameworks shared libraries and adapting to new Swift and iOS models.  Will not be backwards compatible but should work in Swift Playgrounds.  Still has a lot of legacy code that probably isn't needed and will need to be pruned.  Fixed all compile warnings.
v1.0.2 8/8/2022 fixing compile
v1.0.1 8/8/2022 initial commit

v3 was the iOS 13 compatible version (listed as v1.0.x above)
v2 was the original SwiftUI port
v1 Realistically was the original Objective-C Kudit Frameworks

## Ways to generate compiler warnings in code:
```Swift
#warning("message")
#error("message")
```

NOTE: any lines like this need a blank line before it.
```Swift
#if os(visionOS)
```

## Bugs to fix:
Known issues that need to be addressed.

[ ] Remove KuditConnect linkage from Application to make more generic (move back to KuditConnect support email rather than Application.description)
[ ] Update ShoutIt to use KuditFrameworks DataStore
[ ] Fix Kudos display to be larger and not crop when rating screen comes up in visionOS!  In visionOS, create particle effect outside of window in a reality view so can pop out of window?  ParticleEmitterComponent  Model3D?


## Roadmap:
Planned features and anticipated API changes.  If you want to contribute, this is a great place to start.

[ ] See where we can use @autoclosure in Kudit Frameworks to delay execution (particularly in test frameworks!)
[ ] Add .rotated(n) function on arrays for cycling things like the .rainbow array.
[ ] Add screenshot functionality.
[ ] KuditConnect automatic screenshot when tapping menu.
[ ] Improve test app user interface/layout.
[ ] Add tests to complete code coverage.
[ ] Create tests in such a way that they can be run in Previews and in the example App (may require a project dependency).

## Proposals:
This is where proposals can be discussed for potential movement to the roadmap.

[ ] In tracking checks, look for DebugLevel set to debug and if so, add #warning to ensure compiler warning? Is this even possible?
[ ] Should failed parsing color throw rather than just returning `nil` so we can get the message if we want and ignore otherwise?  
[ ] Package Debug, KuColor, Application & Version, Test Frameworks, Layouts, Foundation improvements, etc into separate packages that can be separate active open source projects like Device?  Submit some of the foundation packages to Foundation open source projects.
