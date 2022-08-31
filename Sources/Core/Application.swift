//
//  Application.swift
//  KuditFrameworks
//
//  Created by Ben Ku on 6/30/16.
//  Copyright © 2016 Kudit. All rights reserved.
//

import Foundation

// TODO: add functions for sorting versions?  Major, Minor, Something?  Make enum or other struct that can be converted to/from String?

public class Application: CustomStringConvertible {
	public static let KuditFrameworksBundle = Bundle(identifier: "com.kudit.KuditFrameworks")
	public static let KuditFrameworksVersion = (KuditFrameworksBundle?.infoDictionary?["CFBundleShortVersionString"] as? String ?? "KuditFrameworks not loaded as bundle.") + " (" + (KuditFrameworksBundle?.infoDictionary?["CFBundleVersion"] as? String ?? "?.?") + ")"

	/// Place `Application.track()` in `application(_:didFinishLaunchingWithOptions:)` to enable version tracking.
	public static func track() {
		print("Kudit Application Tracking:\n\(Application.main)")
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
	public let name = Bundle.main.infoDictionary?["CFBundleName"] as? String ?? "Unknown Application Name"

	/// Name that appears on the Home Screen
	public let appName = Bundle.main.infoDictionary?["CFBundleExecutable"] as? String ?? "Unknown"

	/// The last . component of Bundle.main.bundleIdentifier
	public let appIdentifier = Bundle.main.bundleIdentifier?.components(separatedBy: ".").last ?? "unknown"

	private init() {
		if isFirstRun { // make sure to call before tracking or this won't ever be false
			print("First Run!")
		}
		var versionsRun = self.versionsRun
		versionsRun.appendUnique(version)
		UserDefaults.standard.set(versionsRun, forKey: "kuditVersions")
		UserDefaults.standard.removeObject(forKey: "last_run_version")
		// UserDefaults.synchronize // don't track in case launch issue
	}
	
	public var description: String {
		let initial = versionsRun.first!
		var description = "\(name) (\(version))"
		if isFirstRun {
			description += " **First Run!**"
		}
		if initial != version {
			description += "\nPreviously run: \(versionsRun.filter{ $0 != version }.joined(separator: ", "))"
		}
		if Application.KuditFrameworksBundle != nil {
			description += "\nKudit Framework Version: \(Application.KuditFrameworksVersion)"
		}
		description += "\niCloud Status: \(iCloudIsEnabled ? "enabled" : "unavailable")"
		return description
	}
	
	// MARK: - Version information
	// NOTE: in Objective C, the key was kCFBundleVersionKey, but that returns the build number in Swift.
	// TODO: this gets the FRAMEWORK version, not the current APP version.  Use Bundle.main. for app version, but need to do something different for XCTests since there is no main bundle in that case
	/// Current app version string (not including build)
	public let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "?.?"
	/// Current framework version string (not including build)
	public let frameworkVersion = Bundle(for: Application.self).infoDictionary!["CFBundleShortVersionString"] as! String
	
	/// `true`  if this is the first time the app has been run, `false` otherwise
	// NOTE: should only be mutable by the reset function above.
	public var isFirstRun =
		UserDefaults.standard.object(forKey: "last_run_version") == nil // legacy support
		&& UserDefaults.standard.object(forKey: "kuditVersions") == nil // modern support
	
		
	/// List of all versions that have been run since install.
	public var versionsRun: [String] {
		var versionsRun: [String] = (UserDefaults.standard.object(forKey: "kuditVersions") as? [String] ?? [])
		// if last_run_version set, add that to preserve legacy format
		if let lastRunVersion = UserDefaults.standard.object(forKey: "last_run_version") as? String {
			versionsRun = [lastRunVersion] + versionsRun // make sure that legacy last_run_version comes before new versions
		}
		// ensure uniqueness without changing order
		versionsRun.removeDuplicates()
		return versionsRun
	}
	
	public func hasRunVersion(before testVersion: String) -> Bool {
		for versionRun in versionsRun {
			if versionRun.compare(testVersion) == .orderedAscending {
				return true
			}
		}
		return false
	}
	
	// MARK: - Entitlements Information
	public var iCloudIsEnabled: Bool {
		guard let token = FileManager.default.ubiquityIdentityToken else {
//			print("iCloud not available")
			return false
		}
		_ = token // suppress unused warning
//		print("iCloud logged in with token `\(token)`")
		return true
	}

	/// Vendor ID (may not be used anywhere since not very helpful)
//	public var vendorID = UIDevice.current.identifierForVendor.UUIDString
}
