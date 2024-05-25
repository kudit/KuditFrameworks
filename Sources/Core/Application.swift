//
//  Application.swift
//  KuditFrameworks
//
//  Created by Ben Ku on 6/30/16.
//  Copyright © 2016 Kudit. All rights reserved.
//

import Foundation

public enum CloudStatus: CustomStringConvertible {
    case notSupported, available, unavailable
    public var description: String {
        switch self {
        case .notSupported:
            "Not Supported"
        case .available:
            "Available"
        case .unavailable:
            "Unavailable"
        }
    }
}

public class Application: CustomStringConvertible {
//    public static let KuditFrameworksBundle = Bundle(identifier: "com.kudit.KuditFrameworks")
// use Bundle.kuditFrameworks instead
//    public static let KuditFrameworksVersion = (KuditFrameworksBundle?.infoDictionary?["CFBundleShortVersionString"] as? String ?? "KuditFrameworks not loaded as bundle.") + " (" + (KuditFrameworksBundle?.infoDictionary?["CFBundleVersion"] as? String ?? "?.?") + ")"
    // use Bundle.kuditFrameworks.version instead

    /// Use before tracking to disable iCloud checks to prevent crashes if we don't want to check for iCloud.
    public static var iCloudSupported = true
    
    /**
     Defaults to true so application will need to call a function during init/launch:
     
     ```swift
     if false { // this will generate a warning if left as false
         DebugLevel.currentLevel = .NOTICE
     }
     Application.track()
     ```
     */
    public static var DEBUG: Bool {
        return DebugLevel.currentLevel == .DEBUG
    }
    
    /// Place `Application.track()` in `application(_:didFinishLaunchingWithOptions:)` or @main struct init() function to enable version tracking.
    public static func track(file: String = #file, function: String = #function, line: Int = #line, column: Int = #column) {
        // Calling Application.main is what initializes the application and does the tracking.  This really should only be called once.  TODO: Should we check to make sure this isn't called twice??  Application.main singleton should only be inited once.
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
    public let name = Bundle.main.name

    /// Name that appears on the Home Screen
    public let appName = Bundle.main.appName

    public static let unknownAppIdentifier = "com.unknown.unknown"
    /// The fully qualified reverse dot notation from Bundle.main.bundleIdentifier like com.kudit.frameworks
    public let appIdentifier = {
        guard var identifier = Bundle.main.bundleIdentifier else {
            return Application.unknownAppIdentifier
        }
        // when running in preview, identifier may be: swift-playgrounds-dev-previews.swift-playgrounds-app.hdqfptjlmwifrrakcettacbhdkhn.501.KuditFramework
        // convert to normal identifier (assumes com.kudit.lastcomponent
        // for testing, if this is KuditFrameworks, we should pull the unknown identifier FAQs
        let lastComponent = identifier.components(separatedBy: ".").last // should never really be nil
        if let lastComponent, identifier.contains("swift-playgrounds-dev-previews.swift-playgrounds-app") {
            identifier = "com.kudit.\(lastComponent)"
        }
        if lastComponent == "KuditFramework" || identifier.contains("com.kudit.KuditFrameworksTest") {
            return Application.unknownAppIdentifier
        }
        return identifier
    }()

    private init() {
        // this actually does the tracking
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
        var description = "\(name) (v\(version))"
        if isFirstRun {
            description += " **First Run!**"
        }
        if versionsRun.count > 1 { // don't count on this being ordered
            description += "\nPreviously run versions: \(versionsRun.filter{ $0 != version }.map { "v\($0)" }.joined(separator: ", "))"
        }
        description += "\nIdentifier: \(Application.main.appIdentifier)"
        // TODO: Is there a point to this check?  Won't it always be true here?
        if let kf = Bundle.kuditFrameworks {
            description += "\nKudit Framework Version: \(kf.version)"
            description += "\nKuditConnect Version: \(KuditConnect.version)"
        }
        // so we can disable on simple apps and still do tracking without issues.
        description += "\niCloud Status: \(iCloudStatus)"
        return description
    }
        
    // MARK: - Version information
    // NOTE: in Objective C, the key was kCFBundleVersionKey, but that returns the build number in Swift.
    /// Current app version string (not including build)
    public let version = Bundle.main.version
    
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
    
    /// List of all versions that have been run since install (in order of running).  Local only and doesn't count versions run on other devices.  Perhaps in the future that will change?
    public var previouslyRunVersions: [Version] {
        var versionsRun = versionsRun
        versionsRun.remove(version)
        return versionsRun
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
        guard Self.iCloudSupported else {
            debug("iCloud is not supported by this app.", level: .SILENT)
            return false
        }
        guard let token = FileManager.default.ubiquityIdentityToken else {
            debug("iCloud not available", level: .SILENT)
            return false
        }
        debug("iCloud logged in with token `\(token)`", level: .SILENT)
        return true
    }
    
    public var iCloudStatus: CloudStatus {
        guard Self.iCloudSupported else {
            return .notSupported
        }
        if iCloudIsEnabled {
            return .available
        } else {
            return .unavailable
        }
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
#Preview("Application View") {
    ApplicationInfoView()
        .padding()
}
#endif
