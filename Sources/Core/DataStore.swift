import Foundation

/** Usage:

self.store = DataStoreObserver.getObservedStore(migrateLocal: {
    store in
    self.tokensAvailable = store.integer(forKey: .availableTokensKey)
    // move from store to memory which will get saved later
    store.set(0, forKey: .availableTokensKey)
}, load: { store in
    let storeTokens = store.integer(forKey: .availableTokensKey)
    self.tokensAvailable += storeTokens
}, onUpdate: { store in
    // overwrite with cloud variable since we will synchronize or save/write to cloud at first chance.
    self.tokensAvailable = store.integer(forKey: .availableTokensKey)
})
 */


@available(watchOS 9.0, *)
public protocol DataStore {
    static var notificationName: NSNotification.Name { get }
    @discardableResult func synchronize() -> Bool
    
    var isLocal: Bool { get }
    
    /// Sets the value of the specified default key.
    func set(
        _ value: Any?,
        forKey defaultName: String
    )
    /// Sets the value of the specified default key to the double value.
    func set(
        _ value: Double,
        forKey defaultName: String
    )
    /// Sets the value of the specified default key to the specified integer value.
    func set(
        _ value: Int,
        forKey defaultName: String
    )
    /// Sets the value of the specified default key to the specified Boolean value.
    func set(
        _ value: Bool,
        forKey defaultName: String
    )
    /// Sets the value of the specified default key to the specified URL.
    func set(
        _ value: URL?,
        forKey defaultName: String
    )
    
    ///Returns the object associated with the specified key.
    func object(forKey: String) -> Any?
    ///Returns the URL associated with the specified key.
    func url(forKey: String) -> URL?
    ///Returns the array associated with the specified key.
    func array(forKey: String) -> [Any]?
    ///Returns the dictionary object associated with the specified key.
    func dictionary(forKey: String) -> [String : Any]?
    ///Returns the string associated with the specified key.
    func string(forKey: String) -> String?
    ///Returns the array of strings associated with the specified key.
    func stringArray(forKey: String) -> [String]?
    ///Returns the data object associated with the specified key.
    func data(forKey: String) -> Data?
    ///Returns the Boolean value associated with the specified key.
    func bool(forKey: String) -> Bool
    ///Returns the integer value associated with the specified key.
    func integer(forKey: String) -> Int
    ///Returns the double value associated with the specified key.
    func double(forKey: String) -> Double
    ///Returns a dictionary that contains a union of all key-value pairs in the domains in the search list.
    func dictionaryRepresentation() -> [String : Any]
}
@available(watchOS 9.0, *)
extension NSUbiquitousKeyValueStore: DataStore {
    public func set(_ value: Int, forKey defaultName: String) {
        self.set(Int64(value), forKey: defaultName)
    }

    public func set(_ value: URL?, forKey defaultName: String) {
        set(value?.absoluteString, forKey: defaultName)
    }
}
@available(watchOS 9.0, *)
public extension NSUbiquitousKeyValueStore {
    static var notificationName = NSUbiquitousKeyValueStore.didChangeExternallyNotification
    var isLocal: Bool { false }
    ///Returns the integer value associated with the specified key.
    func integer(forKey key: String) -> Int {
        return Int(self.longLong(forKey: key))
    }
    func url(forKey key: String) -> URL? {
        guard let string = self.string(forKey: key) else {
            return nil
        }
        return URL(string: string)
    }
    func stringArray(forKey key: String) -> [String]? {
        guard let array = self.array(forKey: key) else {
            return nil
        }
        return try? array.map {
            guard let value = $0 as? String else {
                throw CustomError("Type Mismatch")
            }
            return value
        }
    }
    
    func dictionaryRepresentation() -> [String : Any] {
        return self.dictionaryRepresentation
    }
}
@available(watchOS 9.0, *)
extension UserDefaults: DataStore {}
@available(watchOS 9.0, *)
public extension UserDefaults {
    static var notificationName = UserDefaults.didChangeNotification
    var isLocal: Bool { true }
}
@available(watchOS 9.0, *)
public enum DataStoreError: Error {
    // Throw when data cannot be initialized from a store
    case load
}
@available(watchOS 9.0, *)
public class DataStoreObserver {
    static var observers: [DataStoreObserver] = []
    let store: DataStore
    let onUpdate: (DataStore) -> Void
    init(store: DataStore, onUpdate: @escaping (DataStore) -> Void) {
        self.store = store
        self.onUpdate = onUpdate
        // watch for changes in store
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(updateKVStoreItems),
            name: type(of: store).notificationName,
            object: store)
        Self.observers.append(self)
    }
    @objc private func updateKVStoreItems(notification: NSNotification) {
        guard let userInfo = notification.userInfo else { return }
        
        // Get the reason for the notification (initial download, external change or quota violation change).
        guard let reasonForChange = userInfo[NSUbiquitousKeyValueStoreChangeReasonKey] as? Int else {
            debug("Unable to get reason for KVStore change.", level: .WARNING)
            // If a reason could not be determined, do not update anything.
            return
        }
        // The reason for the key-value notification change is one of the following:
        // Update only for changes from the server.
        switch reasonForChange {
        case NSUbiquitousKeyValueStoreServerChange:
            //NSUbiquitousKeyValueStoreServerChange: Value(s) were changed externally from other users/devices.
            debug("Value(s) were changed externally from other users/devices.", level: .DEBUG)
        case NSUbiquitousKeyValueStoreInitialSyncChange:
            // NSUbiquitousKeyValueStoreInitialSyncChange: Initial downloads happen the first time a device is connected to an iCloud account, and when a user switches their primary iCloud account.
            debug("Initial download from iCloud.", level: .NOTICE)
        case NSUbiquitousKeyValueStoreQuotaViolationChange:
            // NSUbiquitousKeyValueStoreQuotaViolationChange: The app’s key-value store has exceeded its space quota on the iCloud server.
            debug("The app’s key-value store has exceeded its space quota on the iCloud server.", level: .ERROR)
            return
        case NSUbiquitousKeyValueStoreAccountChange:
            // NSUbiquitousKeyValueStoreAccountChange: The user has changed the primary iCloud account.
            debug("The user has changed the primary iCloud account.", level: .NOTICE)
            return
        default:
            debug("Unknown reason for change: \(reasonForChange)", level: .ERROR)
            return
        }
        // To obtain key-values that have changed, use the key NSUbiquitousKeyValueStoreChangedKeysKey from the notification’s userInfo.
        // guard let keys = userInfo[NSUbiquitousKeyValueStoreChangedKeysKey] as? [String] else { return }
        // NOTE: Previous version would go through and check keys and items to look for changes.  For this, we should just load the data and set the messages object.  Since struct, shouldn't cause any updates except changes should automatically be visible due to SwiftUI checking state changes.
        onUpdate(store)
    }
    /// Return a data store and provide callbacks to run on notifications like update.  `resetLocal` is called when a store needs to be reset, for example, when migrating local data to iCloud, the local store should be reset after loading local data.  A cloud `load` will be called after.  `load` should load data from the store and throw a DataStoreError.load if we have some fatal error that means we should NOT attempt to synchronize with the online store.  `load` will be called twice if iCloud is enabled, once to check the local store for data and again for the online data.  You can tell if it will be called twice if the Bool value is true (iCloud is enabled). `onUpdate` is called when the online store changes. Make sure if we weren't logged in and then switch to iCloud, that we migrate over data from local store and delete (onReset) and if iCloud goes away, user defaults will be reset so that would be expected to no longer have that synced data.
    public static func getObservedStore(
        /// pull data from the local data source and reset.  Future call to load will be coming.
        migrateLocal: (DataStore) -> Void = { _ in },
        load: (DataStore) throws -> Void, // if error, don't synchronize.  DataStore passed will indicate if local or not in case needed.
        onUpdate: @escaping (DataStore) -> Void
    ) -> DataStore {
        var store: DataStore
        if Application.main.iCloudIsEnabled {
            // migrate local storage first
            migrateLocal(UserDefaults.standard)
            store = NSUbiquitousKeyValueStore.default
        } else {
            // just use local store and ignore any iCloud syncing.
            store = UserDefaults.standard
        }
        
        do {
            try load(store)
        } catch {
            // keep local version?  Don't try to sync anymore?
            debug("Unable to load data from store.  Will not watch for changes.", level: .ERROR)
            return store
        }
        // create observer to monitor changes
        let _ = DataStoreObserver(store: store, onUpdate: onUpdate) // will register itself for retention
        
        store.synchronize() // used for iCloud not necessary for UserDefaults
        
        return store // for saving or additional loading
    }
}
