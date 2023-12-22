//
//  Application.swift
//  KuditFrameworks
//
//  Created by Ben Ku on 6/30/16.
//  Copyright © 2016 Kudit. All rights reserved.
//

import Foundation

// TODO: add functions for sorting versions?  Major, Minor, Something?  Make enum or other struct that can be converted to/from String?
// TODO: See if we can deprecate this if there are better swifty equivalents.  Doesn't seem to be currently.  Used in KuditConnect.
public class Application: CustomStringConvertible {
//    public static let KuditFrameworksBundle = Bundle(identifier: "com.kudit.KuditFrameworks")
// use Bundle.kuditFrameworks instead
//    public static let KuditFrameworksVersion = (KuditFrameworksBundle?.infoDictionary?["CFBundleShortVersionString"] as? String ?? "KuditFrameworks not loaded as bundle.") + " (" + (KuditFrameworksBundle?.infoDictionary?["CFBundleVersion"] as? String ?? "?.?") + ")"
    // use Bundle.kuditFrameworks.version instead

    /// Place `Application.track()` in `application(_:didFinishLaunchingWithOptions:)` or @main struct init() function to enable version tracking.
    public static func track(file: String = #file, function: String = #function, line: Int = #line, column: Int = #column) {
        debug("Kudit Application Tracking:\n\(Application.main)", level: .NOTICE, file: file, function: function, line: line, column: column)
    }
    
    /// for resetting version tracking for unit tests only (done here because different domain than the test user defaults)
    public static func resetWithData(_ dictionary: [String: Any]) {
        UserDefaults.standard.removePersistentDomain(forName: "xctest")
        print("NOTE: This should only be called from an XCTest file")
        UserDefaults.standard.removeObject(forKey: "last_run_version")
        UserDefaults.standard.removeObject(forKey: "kuditVersions")
        for (key, value) in dictionary {
            UserDefaults.standard.set(value, forKey: key)
        }
        UserDefaults.standard.synchronize()
        UserDefaults.resetStandardUserDefaults()
        // re-assign since this should change UserDefaults and pretend like new launch for tests
        Application.main.isFirstRun =
            UserDefaults.standard.object(forKey: "last_run_version") == nil // legacy support
                && UserDefaults.standard.object(forKey: "kuditVersions") == nil // modern support
    }

    // MARK: - Application information
    public static let main = Application()
    /// Human readable display name for the application.
    public let name = {
        var name = Bundle.main.name
        if Application.inPlayground {
            name += " (Playground)"
        }
        if Application.inPreview {
            name += " (#Preview)"
        }
        return name
    }()

    /// Name that appears on the Home Screen
    public let appName = Bundle.main.appName

    /// The fully qualified reverse dot notation from Bundle.main.bundleIdentifier like com.kudit.frameworks
    public let appIdentifier = Bundle.main.bundleIdentifier ?? "com.unknown.unknown"

    private init() {
        if isFirstRun { // make sure to call before tracking or this won't ever be false
            debug("First Run!", level: .NOTICE)
        }
        var versionsRun = self.versionsRun
        versionsRun.appendUnique(version)
        UserDefaults.standard.set(versionsRun.asStringArray, forKey: "kuditVersions")
        // remove any previous compatibility formats
        UserDefaults.standard.removeObject(forKey: "last_run_version")
        // UserDefaults.synchronize // don't save in case launch issue where it will crash on launch
    }
    
    public var description: String {
        let initial = versionsRun.first!
        var description = "\(name) (v\(version))"
        if isFirstRun {
            description += " **First Run!**"
        }
        if initial != version {
            description += "\nPreviously run: \(versionsRun.filter{ $0 != version }.joined(separator: ", "))"
        }
        if let kf = Bundle.kuditFrameworks {
            description += "\nKudit Framework Version: \(kf.version)"
        }
        description += "\niCloud Status: \(iCloudIsEnabled ? "enabled" : "unavailable")"
        return description
    }
    
    // MARK: - Environment information
    // In macOS Playgrounds Preview: swift-playgrounds-dev-previews.swift-playgrounds-app.hdqfptjlmwifrrakcettacbhdkhn.501.KuditFramework
    // In macOS Playgrounds Running: swift-playgrounds-dev-run.swift-playgrounds-app.hdqfptjlmwifrrakcettacbhdkhn.501.KuditFrameworksApp
    // In iPad Playgrounds Preview: swift-playgrounds-dev-previews.swift-playgrounds-app.agxhnwfqkxciovauscbmuhqswxkm.501.KuditFramework
    // In iPad Playgrounds Running: swift-playgrounds-dev-run.swift-playgrounds-app.agxhnwfqkxciovauscbmuhqswxkm.501.KuditFrameworksApp
    public static var inPlayground: Bool {
        debug("Testing inPlayground: Bundles: \(Bundle.allBundles.map { $0.bundleIdentifier }.description)", level: .SILENT)
        if Bundle.allBundles.contains(where: { ($0.bundleIdentifier ?? "").contains("swift-playgrounds") }) {
            //print("in playground")
            return true
        } else {
            //print("not in playground")
            return false
        }
    }
    
    public static var inPreview: Bool {
        ProcessInfo.processInfo.environment["XCODE_RUNNING_FOR_PREVIEWS"] == "1"
    }
    
    // MARK: - Version information
    // NOTE: in Objective C, the key was kCFBundleVersionKey, but that returns the build number in Swift.
    /// Current app version string (not including build)
    public let version = Bundle.main.version

    // TODO: this gets the APP version, not the current APP version.  Use Bundle.main. for app version, but need to do something different for XCTests since there is no main bundle in that case
/// Current framework version string (not including build)
    public let frameworkVersion = Bundle(for: Application.self).version
    
    /// `true`  if this is the first time the app has been run, `false` otherwise
    // NOTE: should only be mutable by the reset function above.
    public var isFirstRun =
        UserDefaults.standard.object(forKey: "last_run_version") == nil // legacy support
        && UserDefaults.standard.object(forKey: "kuditVersions") == nil // modern support
    
        
    /// List of all versions that have been run since install.  Local only and doesn't count versions run on other devices.  Perhaps in the future that will change?
    public var versionsRun: [Version] {
        var versionsRun: [String] = (UserDefaults.standard.object(forKey: "kuditVersions") as? [String] ?? [])
        // if last_run_version set, add that to preserve legacy format
        if let lastRunVersion = UserDefaults.standard.object(forKey: "last_run_version") as? String {
            versionsRun = [lastRunVersion] + versionsRun // make sure that legacy last_run_version comes before new versions
        }
        // ensure uniqueness without changing order
        versionsRun.removeDuplicates()
        return versionsRun.map { Version(rawValue: $0) }
    }
    
    public func hasRunVersion(before testVersion: Version) -> Bool {
        for versionRun in versionsRun {
            if versionRun < testVersion {
                return true
            }
        }
        return false
    }
    
    // MARK: - Entitlements Information
    public var iCloudIsEnabled: Bool {
        guard let token = FileManager.default.ubiquityIdentityToken else {
            debug("iCloud not available", level: .SILENT)
            return false
        }
        _ = token // suppress unused warning
        debug("iCloud logged in", level: .SILENT)
        debug("iCloud token: `\(token)`", level: .SILENT)
        return true
    }

    /// Vendor ID (may not be used anywhere since not very helpful)
//    public var vendorID = UIDevice.current.identifierForVendor.UUIDString
}


// get current version:
// Bundle.main.version
public extension Bundle {
    static let kuditFrameworks = Bundle(identifier: "com.kudit.KuditFrameworks")
    
    /// A user-visible short name for the bundle.
    var name: String { getInfo("CFBundleName") ?? "Unknown App Name" }
    
    /// The user-visible name for the bundle, used by Siri and visible on the iOS Home screen.
    var displayName: String { getInfo("CFBundleDisplayName") ?? "⚠️" }
    
    /// The name of the bundle’s executable file.
    var appName: String { getInfo("CFBundleExecutable") ?? "⚠️" }
    
    /// The default language and region for the bundle, as a language ID.
    var language: String { getInfo("CFBundleDevelopmentRegion") ?? "en" }
    
    /** A unique identifier for a bundle.
     A bundle ID uniquely identifies a single app throughout the system. The bundle ID string must contain only alphanumeric characters (A–Z, a–z, and 0–9), hyphens (-), and periods (.). Typically, you use a reverse-DNS format for bundle ID strings. Bundle IDs are case-insensitive.
**/
    var identifier: String { getInfo("CFBundleIdentifier") ?? "unknown.bundle.identifier"}

    /// A human-readable copyright notice for the bundle.
    var copyright: String { getInfo("NSHumanReadableCopyright")?.replacingOccurrences(of: "\\\\n", with: "\n") ?? "©⚠️" }
    
    /// The version of the build that identifies an iteration of the bundle. (1-3 period separated integer notation.  only integers and periods supported).  In Swift, this may return the build number.
    var build: String { getInfo("CFBundleVersion") ?? "⚠️"}
    /// The version of the build that identifies an iteration of the bundle. (1-3 period separated integer notation.  only integers and periods supported)
    var version: Version { Version(getInfo("CFBundleShortVersionString") ?? "⚠️.⚠️") }
    //public var appVersionShort: String { getInfo("CFBundleShortVersion") }
    
    fileprivate func getInfo(_ str: String) -> String? { infoDictionary?[str] as? String }
}

#if canImport(SwiftUI)
import SwiftUI
#Preview("Preview Check") {
    VStack {
        Text("Application: \(Application.main.name)")
        if Application.inPlayground {
            Text("In Playground")
        }
        if Application.inPreview {
            Text("In Preview")
        }
        Spacer()
    }
}
#endif
