# KuditFrameworks

Additional components, simpler, and convenience code for Kudit projects.

Edited on Xcode.  Edited on iPad

v1.0.1 8/8/2022 initial commit
v1.0.2 8/8/2022 fixing compile
v1.0.3 8/9/2022 adding in KuditFrameworks shared libraries and adapting to new Swift and iOS models.  Will not be backwards compatible but should work in Swift Playgrounds.  Still has a lot of legacy code that probably isn't needed and will need to be pruned.  Fixed all compile warnings.
v1.0.4 8/10/2022 Fixed extract(from:to:) to return nil if start or end not found to make it easier to determine if a tag was scraped successfully or not.  Could have done via error throw but it's not really an error so optional makes more sense since the action could fail.  Also removed all Window dependencies (which probably breaks some of the Kudit Connect functionality but that does need to be tested...need to bring in tests from library project).
v1.0.5 8/10/2022 Fixed WebView internal permissions (hopefully for real this time?).  Added KuError.custom(String,DebugLevel). Moved data model and asset libraries to Resources to allow compilation and running on iPad.  Moved Compatibility, Debug, and Test frameworks into separate files.
v1.0.6 8/10/2022 Fixed PHP.time() not being public.  Fixed recursive sleep and just eliminated PHP.sleep().  Made Test() init public.  Made TestUI public.
v1.0.7 8/10/2022 Made additional fields for Tests public.
v1.0.8 8/10/2022 Manually created initializers for SwiftUI views to prevent internal protection errors.
v1.0.9 8/10/2022 Fixed tests to run in Xcode.  Added watchOS and tvOS support.
v1.0.10 8/11/2022 Removed a bunch of KuditConnect and non-critical code since those should be completely re-thought and added in a modern way and there is too much legacy code.
v1.0.11 8/11/2022 Removed unnecessary KuditFrameworks import from Image.swift.
v1.0.12 8/12/2022 changed String.contains() to String.containsAny() to be more clear.  Modified KuError to include public initializer and automatic Debug print.
v1.0.13 8/12/2022 Added File and Date and URL comparable code.  Need to migrate NSDate to Date.  
v1.0.14 8/24/2022 Added RingedText, ShareSheet, and Graphics code from old Swift Frameworks.
v1.0.15 8/25/2022 Checked added frameworks to make sure everything is marked public so usable by ouside code.

