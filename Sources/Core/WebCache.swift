//
//  WebCache.swift
//  KuditFrameworks
//
//  Created by Ben Ku on 5/7/16.
//  Copyright © 2016 Kudit. All rights reserved.
//

import Foundation

/*
    WebCache is a simple tool for caching data from the web on disk and in memory.
*/
// TODO: should this be open or public?
open class WebCache<T: DataConvertible> where T.Result == T {
    public typealias Callback = (T?, Bool) -> Void // the data type, whether it was downloaded (in case we want to process and update the cache after downloading)
    public let path: String // was open
    
    var _memoryCache = NSCache<NSString,NSData>() // also used for locking.  Can replace with an NSMutableDictionary if NSCache is not available.
    /// this will prevent repeated server calls for the same file by batching up the callbacks.
    var _activeLookups = [String: [Callback]]()
    /// to prevent repeated queries to server, this will keep a list of failed lookups that will last until memory cache is dumped.
    var _knownMisses = [String: Bool]()
    /// since we might delete the file before it's actually saved to disk, notate this so that we don't bother saving in that case.
    var _markedForDeletion = [String: Bool]()
    
    public init(_ name: String) {
        // create the cache path from the name
        let dir = name.fileSafe
        
        let paths = NSSearchPathForDirectoriesInDomains(.cachesDirectory, .userDomainMask, true)
        let cachePath = paths[0] as NSString // for stringByAppendingPathComponent
        
        path = cachePath.appendingPathComponent(dir)

        // make sure directory exists (may take a second so should probably be run on a background thread?)
        if !FileManager.default.fileExists(atPath: path) {
            do {
                try FileManager.default.createDirectory(atPath: path, withIntermediateDirectories: true, attributes: nil)
            } catch {
                print("KWC: Could not create cache directory at \(path): \(error)")
                // all file system read/writes will fail but still could use the in memory cache and URL sources
            }
        }
    }
    
    /// path to a keyed file on disk
    func _cachePathForKey(_ key: String) -> String {
        return (path as NSString).appendingPathComponent(key.fileSafe)
    }

    /// delete a file from disk (make sure called from synchronized block?)
    func _deleteFileAtPath(_ path: String) {
        guard FileManager.default.fileExists(atPath: path) else {
            return // no file means we don't need to delete.  This is okay.
        }
        do {
            try FileManager.default.removeItem(atPath: path)
        } catch {
            print("KWC: Could not remove file: \(error)")
        }
    }

    /// convert the NSData to the appropriate type object, add it to the memory cache, and optionally save to disk
    func _saveNSData(_ nsdata: Data, key: String, persist: Bool) {
        // save to memory cache
        synchronized(self) {
            self._memoryCache.setObject(nsdata as NSData, forKey: key as NSString)
        }
        // save to disk cache
        if persist {
            // run this block code on a background thread just in case disk access is slow.  already in memory so any future calls should grab.
            background {
                let path = self._cachePathForKey(key)
                synchronized(self) {
                    if (self._markedForDeletion[path] != nil) {
                        return // no need to save file if it's set to be deleted
                    }
                    // see if file already exists and remove (downloaded file may be overwritten)
                    self._deleteFileAtPath(path)
                    if !((try? nsdata.write(to: URL(fileURLWithPath: path), options: [.atomic])) != nil) {
                        print("KWC: Error writing file to \(path)")
                    }
                }
            }
        }
    }

    /// load the resource from the disk cache.  This should almost always be run on a background thread.  key should be filesafe.
    func _loadFromDisk(_ key: String) -> T? {
        let path = _cachePathForKey(key)
        guard FileManager.default.fileExists(atPath: path) else {
            // file does not exist on disk.  Not necessarily an error.  Caller may use this to test for existance before checking server.
            return nil
        }
        // NEXT: should we also return some metadata about the age of this file or when last accessed to see if we should pull a new version from server?
        guard let data = try? Data(contentsOf: URL(fileURLWithPath: path)) else {
            print("KWC: Error loading cache file at \(path)")
            return nil
        }
        // save to memory cache but no need to persist to disk since we just loaded from disk!
        _saveNSData(data, key: key, persist: false)
        // convert for return
        return load(fromMemoryKey: key)
    }

    /// remove all objects in the in memory cache.  Shouldn't normally be necessary as NSCache will automatically purge items.
    open func dumpMemoryCache() {
        print("KWC: Resetting in-memory cache")
        // no reason to clear active lookups as any delayed loads will still want to happen
        synchronized(self) {
            self._memoryCache.removeAllObjects()
            self._knownMisses.removeAll()
        }
    }
    
    /// dump memory cache and delete all files in this cache folder.
    open func deleteDiskCache() {
        dumpMemoryCache()
        synchronized(self) {
            self._markedForDeletion.removeAll()
        }
        // run this block code on a background thread
        background {
            // go through and delete all files in cache folder
            let directoryEnumerator = FileManager.default.enumerator(atPath: self.path)! // if we can't enumerate the directory, we're in trouble
            print("KWC: Deleting all files in \(self.path)")
            while let filename = directoryEnumerator.nextObject() {
                let file = (self.path as NSString).appendingPathComponent(filename as! String)
                synchronized(self) {
                    self._deleteFileAtPath(file)
                }
            }
            print("KWC: DONE")
        }
    }

    /// purge keyed value from memory and disk
    open func remove(_ key: String) {
        let path = _cachePathForKey(key)
        synchronized(self) {
            self._memoryCache.removeObject(forKey: key as NSString)
            self._markedForDeletion[path] = true
        }
        // run this block code on a background thread
        background {
            // background code here
            synchronized(self) {
                self._deleteFileAtPath(path)
            }
        }
    }
    
    /// overwrites any existing cached file for this key and saves in memory cache as well as disk cache
    open func save(_ data: T, key: String, persist: Bool = true) {
        let nsdata = data.asData()
        _saveNSData(nsdata!, key: key, persist: persist)
    }

    /// look up the resource for the given key in memory cache.
    open func load(fromMemoryKey key: String) -> T? {
        // look up in memory cache
        guard let nsdata = _memoryCache.object(forKey: key as NSString) as? Data else {
            return nil
        }
        guard let typed = T.convertFromData(nsdata) else {
            print("KWC: Error converting data to the appropriate type \(path)")
            return nil
        }
        return typed
    }

    /// look up the resource for the given key in memory cache and pull from disk if not in memory.
    open func load(key: String, completion: @escaping Callback) {
        // look up in memory cache
        if let memory = load(fromMemoryKey: key) {
            completion(memory, false)
            return // no need to continue if it's in memory
        }
        // look up on disk cache
        // run this block code on a background thread
        background {
            // background code here
            let disk = self._loadFromDisk(key)
            main {
                // finish up on main thread
                completion(disk, false)
            }
        }
    }

    func _addCallback(_ key: String, callback: Callback?) {
        guard let cb = callback else {
            return // nothing to do
        }
        synchronized(self) {
            var lookups = self._activeLookups[key]
            if lookups == nil {
                lookups = [cb]
            } else {
                lookups?.append(cb)
            }
            self._activeLookups[key] = lookups
        }
    }
    
    /// go through and process any outstanding callbacks for the key
    func _processCallbacksForKey(_ key: String, justFinishedDownloading: Bool) {
        var callback: Callback?
        synchronized(self) {
            guard var lookups = self._activeLookups[key] else {
                return // no callbacks to process
            }
            guard lookups.count > 0 else {
                self._activeLookups.removeValue(forKey: key) // we're done with this fetch
                return
            }
            callback = lookups.removeFirst()
            self._activeLookups[key] = lookups // necessary since this is likely value type so need to update
        }
        // return just exits the synchronized block and not the entire function, so check for null callback
        guard callback != nil else {
            return
        }
        // if we've recently downloaded to the point this had to be queued up, this should be in memory
        callback!(load(fromMemoryKey: key), justFinishedDownloading)
        _processCallbacksForKey(key, justFinishedDownloading: false)
    }
    
    func _failDownload(_ key: String) {
        synchronized(self) {
            self._knownMisses[key] = true
        }
        _processCallbacksForKey(key, justFinishedDownloading: true)
    }

    /// load the resource from the URL.  Getting the callback with a nil value means the URL loading failed for some reason.  Make sure to add processes to queue before calling this
    func _loadFromServer(_ key: String) {
        var knownMiss = false
        synchronized(self) {
            knownMiss = self._knownMisses[key] != nil
        }
        guard key.hasPrefix("http") && !knownMiss else {
            // if already tried and missed, don't query server again!
            // downloading won't work so report errors via callbacks. (but allow this to return so that we don't get into an infinite recursion)
            _processCallbacksForKey(key, justFinishedDownloading: true)
            return
        }
        // run in background in case file load or URL load takes a long time
        background {
            // attempt to load from URL.  done asynchronously and no need for the overhead of connection.  Either works or won't.
            guard let url = URL(string: key) else {
                print("KWC: key appeared to be URL but could not create URL from key: \(key)")
                self._failDownload(key)
                return
            }
            // TODO: check for network (could be in airplane mode...will want to fail more gracefully)
            guard let nsdata = try? Data(contentsOf: url) else { // may take a while
                print("KWC: Problem loading file from url: \(key) (if this is preceded by an App Transport Security message, this may be because it is a cleartext URL)")
                self._failDownload(key)
                return
            }
            guard nsdata.count > 10 else {
                print("KWC: Got data but too small: \(key)")
                self._failDownload(key)
                return
            }
            // save resource for future loads (overwrite if we've already downloaded... this shouldn't have been called in that case anyways)
            self._saveNSData(nsdata, key: key, persist: true) // save to disk and in memory caches
            // regardless of whether we succeeded or not, go ahead and process the callbacks (first callback may set file manually so the rest of the callbacks do not send nil)
            main {
                self._processCallbacksForKey(key, justFinishedDownloading: true)
            }
        }
    }
    
    /// look up the resource for the given key in memory & disk caches, and if not found, pull from URL.
    open func load(url: String, completion: @escaping Callback) {
        load(key: url) { data, downloaded in
            // this will not be run if we found it in the in-memory cache
            // if on disk, TODO: check the age of the file to see if we should look for a newer copy online
            if data != nil {
                completion(data, false)
            } else {
                // if not on-disk, check for needed updates (will load if missing)
                // load the data from URL asynchronously
                self._addCallback(url, callback: completion)
                self._loadFromServer(url)
            }
        }
    }
}
