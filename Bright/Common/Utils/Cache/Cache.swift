//
//  Cache.swift
//  Bright
//
//  Created by Martin Lukacs on 27/11/2021.
//

import Combine
import Foundation

protocol CacheContract {
    associatedtype Value
    associatedtype Key

    func insert(_ value: Value, forKey key: Key)
    func value(forKey key: Key) -> Value?
    func removeValue(forKey key: Key)
    func removeAll()
}

final class Cache<Key: Hashable, Value>: CacheContract {
    private let wrapped = NSCache<WrappedKey, Entry>()
    private let dateProvider: () -> Date
    private let entryLifetime: TimeInterval
    private let keyTracker = KeyTracker()
    private var cancelBag = Set<AnyCancellable>()

    var valueEvicted: PassthroughSubject<Value, Never> = .init()

    init(dateProvider: @escaping () -> Date = Date.init,
         entryLifetime: TimeInterval = AppConfigs.Cache.entryLifetime,
         maximumEntryCount: Int = AppConfigs.Cache.maximumEntryCount) {
        self.dateProvider = dateProvider
        self.entryLifetime = entryLifetime
        wrapped.countLimit = maximumEntryCount
        wrapped.delegate = keyTracker
        setUpPublishers()
    }

    func insert(_ value: Value, forKey key: Key) {
        let date = dateProvider().addingTimeInterval(entryLifetime)
        let entry = Entry(key: key, value: value, expirationDate: date)
        wrapped.setObject(entry, forKey: WrappedKey(key))
        keyTracker.keys.insert(key)
    }

    func value(forKey key: Key) -> Value? {
        guard let entry = wrapped.object(forKey: WrappedKey(key)) else {
            return nil
        }

        guard dateProvider() < entry.expirationDate else {
            // Discard values that have expired
            removeValue(forKey: key)
            return nil
        }

        return entry.value
    }

    func removeValue(forKey key: Key) {
        wrapped.removeObject(forKey: WrappedKey(key))
    }

    func removeAll() {
        wrapped.removeAllObjects()
    }

    private func setUpPublishers() {
        keyTracker.entryEvicted
            .sink(receiveValue: { [weak self] entry in
                self?.valueEvicted.send(entry.value)
            })
            .store(in: &cancelBag)
    }
}

extension Cache {
    subscript(key: Key) -> Value? {
        get { value(forKey: key) }
        set {
            guard let value = newValue else {
                // If nil was assigned using our subscript,
                // then we remove any value for that key:
                removeValue(forKey: key)
                return
            }

            insert(value, forKey: key)
        }
    }
}

extension Cache {
    fileprivate final class WrappedKey: NSObject {
        let key: Key

        init(_ key: Key) { self.key = key }

        override var hash: Int { key.hashValue }

        override func isEqual(_ object: Any?) -> Bool {
            guard let value = object as? WrappedKey else {
                return false
            }

            return value.key == key
        }
    }
}

extension Cache {
    fileprivate final class Entry {
        let key: Key
        let value: Value
        let expirationDate: Date

        init(key: Key, value: Value, expirationDate: Date) {
            self.key = key
            self.value = value
            self.expirationDate = expirationDate
        }
    }
}

extension Cache {
    fileprivate final class KeyTracker: NSObject, NSCacheDelegate {
        var entryEvicted: PassthroughSubject<Entry, Never> = .init()

        var keys = Set<Key>()

        func cache(_ cache: NSCache<AnyObject, AnyObject>,
                   willEvictObject object: Any) {
            guard let entry = object as? Entry else {
                return
            }

            entryEvicted.send(entry)

            keys.remove(entry.key)
        }
    }
}
