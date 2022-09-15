//
//  Hardware.swift
//  KuditFrameworks
//
//  Created by Ben Ku on 5/6/2016.
//  Copyright © 2016 Kudit. All rights reserved.
//

/*
 TODO: add DeviceKit as dependency and remove Hardware and Hardware Map
 dependencies: [
 .package(url: "https://github.com/devicekit/DeviceKit.git", from: "4.0.0"),
 ]
 See if there's anything this did that DeviceKit does not.  If there is, see about adding this to DeviceKit repo (add to GITHUB on computer and check out to test and update)
 */
// Subscribe to projects with UIDevice and see which is updated with new iPhone versions.  Keep KuditVersion to support.  Base off one with string mappings to be easier.

// https://github.com/syui/json-script/blob/11d7b9a5ad1dadde0d04e33a1fbfb96f21e8d82e/json/macbook-model.json



import Foundation
#if canImport(IOKit)
import SystemConfiguration
import IOKit
#elseif os(watchOS)
import WatchKit
#elseif canImport(UIKit)
import UIKit
#elseif os(Linux)
#endif

public extension UInt64 {
    // http://stackoverflow.com/questions/7846495/how-to-get-file-size-properly-and-convert-it-to-mb-gb-in-cocoa
    // TODO: use Swift 3 measurement features to create UnitData with bytes, megabytes, kilobytes, etc.
    func bytes(marketing: Bool = false) -> String {
        // return NSByteCountFormatter().stringFromByteCount(Int64(self)) // reports 16GB as 17.18
        let units = ["bytes", "KB", "MB", "GB", "TB", "PB", "EB", "ZB", "YB"]
        var index = 0
        var bytes = Double(self)
        let divisor = Double(marketing ? 1000 : 1024)
        while bytes > divisor && index < units.count - 1 {
            bytes /= divisor
            index += 1
        }
        // round appropriately
        bytes *= 100
        bytes = round(bytes)
        bytes /= 100
        return "\(bytes) \(units[index])"
    }
}

public class Hardware: CustomStringConvertible {
    public struct Size: CustomStringConvertible {
        var width: Int
        var height: Int
        init(width: Int, height: Int) {
            self.width = width
            self.height = height
        }
        init(size: CGSize) {
            width = Int(size.width)
            height = Int(size.height)
        }
        public var description: String {
            return "\(width)×\(height)"
        }
    }
    
    private static let UNKNOWN_MODEL_NAME = "Unknown"

    public static let currentDevice = Hardware()

    public enum HardwareType: Equatable {
        case other, desktop, laptop, handheld, tablet, tv, dashboard, watch
    }
    public enum BatteryState: CustomStringConvertible {
        case unknown // also for not available like AppleTV or desktops.
        case full
        case charging(Float)
        case unplugged(Float)
#if canImport(UIDevice)
        init(_ state: UIDevice.BatteryState, level: Float = -1) {
            switch state {
            case .unknown:
                self = .unknown
            case .unplugged:
                self = .unplugged(level)
            case .full:
                self = .full
            case .charging:
                self = .charging(level)
            @unknown default:
                debug("Unkonwn battery state level!: \(state)", level: .ERROR)
                self = .unknown
            }
        }
        #endif
        public var description: String {
            switch self {
            case .unknown:
                return "Unknown"
            case .unplugged(let batteryLevel):
                let percent = round(batteryLevel * 100)
                return "\(percent)%"
            case .full:
                return "Fully Charged"
            case .charging(let batteryLevel):
                let percent = round(batteryLevel * 100)
                return "\(percent)% ⚡️"
            }
        }
    }
    
    public let name: String            // Ben's iPhone        Photovoltaic                    Web Server
    public let type: HardwareType    // handheld            laptop                            desktop
    public let systemName: String    // iOS                Mac OS X                        Linux
    public let systemVersion: String// 9.3.1            10.11.4                            3.2.1
    public let identifier: String    // iPhone8,4        MacBookPro10,1                    Dell345
    public let model: String        // iPhone SE        MacBook Pro (Retina, Mid 2012)    Mini Colo

    public let screenScale: Double    // 2.0                2.0                                1.0
    public let hasBattery: Bool        // true                true                            false
    

    // MARK: - FileSystem
    private var fileSystemAttributes: [FileAttributeKey : Any]? {
        do {
            return try FileManager.default.attributesOfFileSystem(forPath: NSHomeDirectory())
        } catch {
            return nil
        }
    }
    
    /// The total disk size of the device in bytes, or `nil` if it could not be determined.
    public var diskSize: UInt64? {
        guard let fileSystemAttributes = self.fileSystemAttributes else { return nil }
        return (fileSystemAttributes[.systemSize] as? NSNumber)?.uint64Value
    }

    /// The available disk space of the device in bytes, or `nil` if it could not be determined.
    public var diskFreeSize: UInt64? {
        guard let fileSystemAttributes = self.fileSystemAttributes else { return nil }
        return (fileSystemAttributes[.systemFreeSize] as? NSNumber)?.uint64Value
    }
    
    /// Get the available and used memory and disk space.
    /// Should be in the form:
    ///        Free Memory: XXX/XXX
    ///        Free Disk: XXX/XXX
    public func currentMemoryInfo() -> String {
        // get RAM
//        var memoryString = "Free Memory: "
        var memoryString = "Memory: "
        var info = task_basic_info()
        var count = mach_msg_type_number_t(MemoryLayout.size(ofValue: info))/4
        
        // TODO: Fix so actually pulls available memory and memory used by this app.  The total memory and disk space is working.
        let kerr: kern_return_t = withUnsafeMutablePointer(to: &info) {
            $0.withMemoryRebound(to: integer_t.self, capacity: 1) {
                task_info(mach_task_self_,
                          task_flavor_t(MACH_TASK_BASIC_INFO),
                          $0,
                          &count)
            }
        }
        if kerr == KERN_SUCCESS {
            let usedMemory = UInt64(info.resident_size).bytes()
            let virtualSize = UInt64(info.virtual_size).bytes()
            memoryString += "RESIDENT: \(usedMemory) VIRTUAL: \(virtualSize)"
        } else {
//            memoryString += String(cString: mach_error_string(kerr))
        }
//        memoryString += "/"
        memoryString += ProcessInfo.processInfo.physicalMemory.bytes()
        // get disk space
        memoryString += "\nFree Disk: "
        if let freeSize = diskFreeSize, let diskSize = diskSize {
            memoryString += "\(freeSize.bytes(marketing: true))/\(diskSize.bytes(marketing: true))"
        } else {
            memoryString += "Error"
        }
        return memoryString
    }
        
    public var description: String {
        var battery = ""
        if hasBattery {
            battery = "\nBattery: \(batteryState)"
        }
        let memory = currentMemoryInfo()
        let scaled = (displayIsScaled ? " (scaled)" : "")
        return "Device Name: \(name)\nPlatform: \(systemName) v\(systemVersion)\nModel: \(model)\nScreen Size: \(screenSize) @\(screenScale)\(scaled)\n\(memory)\(battery)"
    }
    
    private init() { //This prevents others from using the default '()' initializer for this class.
        // parse hardware map (from cache if loaded) and if not, update from server for next run asynchronously.
        let cache = WebCache<String>("com.kudit.hardware")
        let url = "https://www.kudit.com/api/HardwareMap.swift"
        if let disk = cache._loadFromDisk(url) {
            let string = disk.replacingOccurrences(of: "public var kuditHardwareMap = [", with: "{").replacingOccurrences(of: "]", with: "}")
            let data = string.asData()
            let map = JSON.convertFromData(data!)?.dictionary!
            kuditHardwareMap = map as! [String: String]
        }
        // load device map from server so we can dynamically update without re-submitting.  Cache locally.
        cache._loadFromServer(url)

        // get identifier
        var systemInfo = utsname()
        uname(&systemInfo)
        identifier = withUnsafeMutablePointer(to: &systemInfo.machine) {
            ptr in String(cString: UnsafeRawPointer(ptr).assumingMemoryBound(to: CChar.self))
        }
        // look up model name from lookup table
        if let modelString = kuditHardwareMap[identifier] {
            model = modelString
        } else {
            model = identifier
        }

#if canImport(UIDevice)
        name = UIDevice.current.name
        screenScale = Double(UIScreen.main.scale)
        switch UIDevice.current.userInterfaceIdiom {
        case .carPlay:
            type = .dashboard
            hasBattery = false
        case .tv:
            type = .tv
            hasBattery = false
        case .pad:
            type = .tablet
            hasBattery = true
        case .phone:
            type = .handheld
            hasBattery = true
        case .mac:
            fallthrough // covered below in compiler if
        case .unspecified:
            fallthrough
        @unknown default:
            type = .other
            /// assumes new devices will probably have a battery so only returns false if we know for sure it does not.
            hasBattery = true
        //NEXT: WHat about the watch???
        }
        systemName = "iOS"
        systemVersion = UIDevice.current.systemVersion
#elseif os(watchOS)
        name = WKInterfaceDevice.current().name
        screenScale = Double(WKInterfaceDevice.current().screenScale)
        // TODO: add in additional information like (TODO: add device-specific information dictionary [String: String])
        _ = WKInterfaceDevice.current().model
        _ = WKInterfaceDevice.current().wristLocation
        _ = WKInterfaceDevice.current().crownOrientation
        _ = WKInterfaceDevice.current().waterResistanceRating
        systemName = WKInterfaceDevice.current().systemName
        systemVersion = WKInterfaceDevice.current().systemVersion
        type = .watch
        hasBattery = true
#elseif os(macOS)
        // import SystemConfiguration?
        if let name = SCDynamicStoreCopyComputerName(nil, nil) {
            self.name = name as String // cast CFString to String
        } else {
            self.name = "Unnamed Mac Device"
        }
        // determine model identifier
        /* TODO.  Old code seems to have issues.
        let service: io_service_t = IOServiceGetMatchingService(kIOMasterPortDefault, IOServiceMatching("IOPlatformExpertDevice"))
        let cfstr = "model" as CFString
        if let model = IORegistryEntryCreateCFProperty(service, cfstr, kCFAllocatorDefault, 0).takeUnretainedValue() as? NSData {
            if let nsstr =  NSString(data: model as Data, encoding: String.Encoding.utf8.rawValue) {
                return nsstr as String
            }
        }*/
        
        // defaults
        systemName = "Mac OS X"
        type = .desktop // TODO: determine dynamically
//            let blob = IOPSCopyPowerSourcesInfo()
//            hasBattery = (blob != nil) // TODO: actually implement
        hasBattery = false // FIXME: implement
        systemVersion = "X.X.X TODO"
        screenScale = 1.0 // TODO: determine if retina mac
        
    #elseif os(Linux)
        name = "Unknown Linux Device"
        type = .desktop
        systemName = "Linux"
        systemVersion = "Unknown"
        identifier = "Unknown"
        screenScale = 1.0
        hasBattery = false

    #else
        name = "Unknown Device"
        type = .other
        systemName = "UnknownOS"
        systemVersion = "X.X.X"
        screenScale = 1.0
        hasBattery = false
    #endif
    }
    
    public var screenSize: Size {
#if canImport(UIScreen)
        return Size(size: UIScreen.main.bounds.size)
#elseif os(watchOS)
        return Size(size: WKInterfaceDevice.current().screenBounds.size)
#else
        return Size(width: -1, height: -1)
#endif
    }
    
    public var emulated: Bool {
#if canImport(UIDevice)
            // This app is an iPhone app running on an iPad
        return UIDevice.current.userInterfaceIdiom == .phone && model.hasPrefix("iPad")
#else
        return false
#endif
    }
    
    /// Because the zoomed display on an iPhone 6 has the same resolution as an iPhone 5 or running an iPhone app in scaled mode on an iPad or an iPad app on an iPad Pro.
    /// - Returns: `true` if scaling is being applied and `false` if the display is the native resolution for the device.
    public var displayIsScaled: Bool {
#if canImport(UIScreen)
        if #available(iOS 8.0, *) {
            return UIScreen.main.scale < UIScreen.main.nativeScale
        } else {
            // Fallback on earlier versions
            return false;
        }
#else
        return false
#endif
    }

    public var batteryState: BatteryState {
        // battery monitoring not available as of watchOS 3
#if canImport(UIDevice)
        let device = UIDevice.current
        // save the current monitoring level
        let monitoring = device.isBatteryMonitoringEnabled
        // enable monitoring
        device.isBatteryMonitoringEnabled = true
        // read value
        let state = device.batteryState
        let level = device.batteryLevel
        // restore monitoring if previous
        device.isBatteryMonitoringEnabled = monitoring
        // return the value
        return BatteryState(state, level: level)
#elseif os(OSX)
//            #import <IOKit/ps/IOPowerSources.h>
            //IOPSGetTimeRemainingEstimate()
            // kIOPMPSIsChargingKey
            // kIOPMPSAtWarnLevelKey
            // kIOPMPSBatteryInstalledKey
            // kIOPMPSCurrentCapacityKey, kIOPMPSMaxCapacityKey
            
            /* http://stackoverflow.com/questions/31633503/fetch-the-battery-status-of-my-macbook-with-swift
func getBatteryStatus() -> String {
let timeRemaining: CFTimeInterval = IOPSGetTimeRemainingEstimate()
if timeRemaining == -2.0 {
return "Plugged"
} else if timeRemaining == -1.0 {
return "Recently unplugged"
} else {
let minutes = timeRemaining / 60
return "Time remaining: \(minutes) minutes"
}
}

let batteryStatus = getBatteryStatus()
print(batteryStatus)
Note: I couldn't access constants like kIOPSTimeRemainingUnlimited and kIOPSTimeRemainingUnknown so I used their raw values (-2.0 and -1.0) but it would be better to find these constants if they still exist somewhere.

Another example, with IOPSCopyPowerSourcesInfo:

let blob = IOPSCopyPowerSourcesInfo()
let list = IOPSCopyPowerSourcesList(blob.takeRetainedValue())
print(list.takeRetainedValue())
Result:

(
{
"Battery Provides Time Remaining" = 1;
BatteryHealth = Good;
Current = 0;
"Current Capacity" = 98;
DesignCycleCount = 1000;
"Hardware Serial Number" = 1X234567XX8XX;
"Is Charged" = 1;
"Is Charging" = 0;
"Is Present" = 1;
"Max Capacity" = 100;
Name = "InternalBattery-0";
"Power Source State" = "AC Power";
"Time to Empty" = 0;
"Time to Full Charge" = 0;
"Transport Type" = Internal;
Type = InternalBattery;
}
)
*/
        return .unknown
#else
        return .unknown
#endif
    }
    
    /*
    // tests
    var isSimulator: Bool {
    return -1;
    }
    /// example usage alert: the power on your device is running low.  This operation may use up a lot of power so please plug in before using.
    var lowPower: Bool {
    }
    /// true if laptop, desktop, or bluetooth keyboard connected
    var hasKeyboard: Bool {
    }
    /// Asynchronously checks to see if the iOS device is jailbroken and then runs the closure on the original thread if so.
    /// Usage:
    /// Hardware.ifJailbroken { print("I've been hacked!") }
    public func ifJailbroken(closure: () -> ()) {
        #if os(iOS)
            // look for Cydia
            if NSFileManager.defaultManager().fileExistsAtPath("/Applications/Cydia.app") {
                closure()
                return
            }
            if UIApplication.sharedApplication().can
            
            
            
            [[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"cydia://package/com.example.package"]])  {
            // look for suspicious files
            if NSFileManager.defaultManager().fileExistsAtPath("/bin/bash") {
                closure()
                return
            }
            
            // see if we can open bash
            
            return isJailbroken
            
                if ([[NSFileManager defaultManager] fileExistsAtPath:@"/Applications/Cydia.app"] ||
                    [[NSFileManager defaultManager] fileExistsAtPath:@"/Library/MobileSubstrate/MobileSubstrate.dylib"] ||
                    [[NSFileManager defaultManager] fileExistsAtPath:@"/bin/bash"] ||
                    [[NSFileManager defaultManager] fileExistsAtPath:@"/usr/sbin/sshd"] ||
                    [[NSFileManager defaultManager] fileExistsAtPath:@"/etc/apt"] ||
                    [[NSFileManager defaultManager] fileExistsAtPath:@"/private/var/lib/apt/"] ||
                    [[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"cydia://package/com.example.package"]])  {
                    return YES;
                }
                
                FILE *f = NULL ;
                if ((f = fopen("/bin/bash", "r")) ||
                    (f = fopen("/Applications/Cydia.app", "r")) ||
                    (f = fopen("/Library/MobileSubstrate/MobileSubstrate.dylib", "r")) ||
                    (f = fopen("/usr/sbin/sshd", "r")) ||
                    (f = fopen("/etc/apt", "r")))  {
                    fclose(f);
                    return YES;
                }
                fclose(f);
                
                NSError *error;
                NSString *stringToBeWritten = @"This is a test.";
                [stringToBeWritten writeToFile:@"/private/jailbreak.txt" atomically:YES encoding:NSUTF8StringEncoding error:&error];
                [[NSFileManager defaultManager] removeItemAtPath:@"/private/jailbreak.txt" error:nil];
                if(error == nil)
                {
                    return YES;
                }
                
            #endif
            
   return NO;
        #endif
    }
*/
}


