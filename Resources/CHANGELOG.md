# KuditFrameworks

Additional components, simpler, and convenience code for Kudit projects.

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
v1.0.33 9/15/2022 Missed one of the @available(iOS 15.0, *)
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

// TODO: Go through and add more tests for better code coverage!