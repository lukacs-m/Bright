//
//  DIInjector.swift
//  Bright
//
//  Created by Martin Lukacs on 27/11/2021.
//

import Foundation
import UIKit
import SwiftUI

// swiftlint:disable file_length

public protocol DIInjectorRegistering {
    static func registerAllServices()
}

/// The Resolving protocol is used to make the Resolver registries available to a given class.
public protocol DIInjecting {
    var resolver: DIInjector { get }
}

extension DIInjecting {
    public var resolver: DIInjector {
        return DIInjector.root
    }
}

/// Resolver is a Dependency Injection registry that registers Services for later resolution and
/// injection into newly constructed instances.
public final class DIInjector {

    // MARK: - Defaults

    /// Default registry used by the static Registration functions.
    public static var main: DIInjector = DIInjector()
    /// Default registry used by the static Resolution functions and by the Resolving protocol.
    public static var root: DIInjector = main
    /// Default scope applied when registering new objects.
    public static var defaultScope: ResolverScope = .graph
    /// Internal scope cache used for .scope(.container)
    public lazy var cache: ResolverScope = ResolverScopeCache()

    // MARK: - Lifecycle

    /// Initialize with optional child scope.
    /// If child is provided this container is searched for registrations first, then any of its children.
    public init(child: DIInjector? = nil) {
        if let child = child {
            self.childContainers.append(child)
        }
    }

    /// Initializer which maintained Resolver 1.0's "parent" functionality even when multiple child scopes were added in 1.4.3.
    @available(swift, deprecated: 5.0, message: "Please use Resolver(child:).")
    public init(parent: DIInjector) {
        self.childContainers.append(parent)
    }

    /// Adds a child container to this container. Children will be searched if this container fails to find a registration factory
    /// that matches the desired type.
    public func add(child: DIInjector) {
        lock.lock()
        defer { lock.unlock() }
        self.childContainers.append(child)
    }

    /// Call function to force one-time initialization of the Resolver registries. Usually not needed as functionality
    /// occurs automatically the first time a resolution function is called.
    public final func registerServices() {
        lock.lock()
        defer { lock.unlock() }
        registrationCheck()
    }

    /// Call function to force one-time initialization of the Resolver registries. Usually not needed as functionality
    /// occurs automatically the first time a resolution function is called.
    public static var registerServices: (() -> Void)? = {
        lock.lock()
        defer { lock.unlock() }
        registrationCheck()
    }

    /// Called to effectively reset Resolver to its initial state, including recalling registerAllServices if it was provided. This will
    /// also reset the three known caches: application, cached, shared.
    public static func reset() {
        lock.lock()
        defer { lock.unlock() }
        main = DIInjector()
        root = main
        ResolverScope.application.reset()
        ResolverScope.cached.reset()
        ResolverScope.shared.reset()
        registrationNeeded = true
    }

    // MARK: - Service Registration

    /// Static shortcut function used to register a specifc Service type and its instantiating factory method.
    ///
    /// - parameter type: Type of Service being registered. Optional, may be inferred by factory result type.
    /// - parameter name: Named variant of Service being registered.
    /// - parameter factory: Closure that constructs and returns instances of the Service.
    ///
    /// - returns: ResolverOptions instance that allows further customization of registered Service.
    ///
    @discardableResult
    public static func register<Service>(_ type: Service.Type = Service.self, name: DIInjector.Name? = nil,
                                         factory: @escaping ResolverFactory<Service>) -> ResolverOptions<Service> {
        return main.register(type, name: name, factory: factory)
    }

    /// Static shortcut function used to register a specific Service type and its instantiating factory method.
    ///
    /// - parameter type: Type of Service being registered. Optional, may be inferred by factory result type.
    /// - parameter name: Named variant of Service being registered.
    /// - parameter factory: Closure that constructs and returns instances of the Service.
    ///
    /// - returns: ResolverOptions instance that allows further customization of registered Service.
    ///
    @discardableResult
    public static func register<Service>(_ type: Service.Type = Service.self, name: DIInjector.Name? = nil,
                                         factory: @escaping ResolverFactoryResolver<Service>) -> ResolverOptions<Service> {
        return main.register(type, name: name, factory: factory)
    }

    /// Static shortcut function used to register a specific Service type and its instantiating factory method with multiple argument support.
    ///
    /// - parameter type: Type of Service being registered. Optional, may be inferred by factory result type.
    /// - parameter name: Named variant of Service being registered.
    /// - parameter factory: Closure that accepts arguments and constructs and returns instances of the Service.
    ///
    /// - returns: ResolverOptions instance that allows further customization of registered Service.
    ///
    @discardableResult
    public static func register<Service>(_ type: Service.Type = Service.self, name: DIInjector.Name? = nil,
                                         factory: @escaping ResolverFactoryArgumentsN<Service>) -> ResolverOptions<Service> {
        return main.register(type, name: name, factory: factory)
    }

    /// Registers a specific Service type and its instantiating factory method.
    ///
    /// - parameter type: Type of Service being registered. Optional, may be inferred by factory result type.
    /// - parameter name: Named variant of Service being registered.
    /// - parameter factory: Closure that constructs and returns instances of the Service.
    ///
    /// - returns: ResolverOptions instance that allows further customization of registered Service.
    ///
    @discardableResult
    public final func register<Service>(_ type: Service.Type = Service.self, name: DIInjector.Name? = nil,
                                        factory: @escaping ResolverFactory<Service>) -> ResolverOptions<Service> {
        lock.lock()
        defer { lock.unlock() }
        let key = Int(bitPattern: ObjectIdentifier(Service.self))
        let factory: ResolverFactoryAnyArguments = { (_,_) in factory() }
        let registration = ResolverRegistration<Service>(resolver: self, key: key, name: name, factory: factory)
        add(registration: registration, with: key, name: name)
        return ResolverOptions(registration: registration)
    }

    /// Registers a specific Service type and its instantiating factory method.
    ///
    /// - parameter type: Type of Service being registered. Optional, may be inferred by factory result type.
    /// - parameter name: Named variant of Service being registered.
    /// - parameter factory: Closure that constructs and returns instances of the Service.
    ///
    /// - returns: ResolverOptions instance that allows further customization of registered Service.
    ///
    @discardableResult
    public final func register<Service>(_ type: Service.Type = Service.self, name: DIInjector.Name? = nil,
                                        factory: @escaping ResolverFactoryResolver<Service>) -> ResolverOptions<Service> {
        lock.lock()
        defer { lock.unlock() }
        let key = Int(bitPattern: ObjectIdentifier(Service.self))
        let factory: ResolverFactoryAnyArguments = { (r,_) in factory(r) }
        let registration = ResolverRegistration<Service>(resolver: self, key: key, name: name, factory: factory)
        add(registration: registration, with: key, name: name)
        return ResolverOptions(registration: registration)
    }

    /// Registers a specific Service type and its instantiating factory method with multiple argument support.
    ///
    /// - parameter type: Type of Service being registered. Optional, may be inferred by factory result type.
    /// - parameter name: Named variant of Service being registered.
    /// - parameter factory: Closure that accepts arguments and constructs and returns instances of the Service.
    ///
    /// - returns: ResolverOptions instance that allows further customization of registered Service.
    ///
    @discardableResult
    public final func register<Service>(_ type: Service.Type = Service.self, name: DIInjector.Name? = nil,
                                        factory: @escaping ResolverFactoryArgumentsN<Service>) -> ResolverOptions<Service> {
        lock.lock()
        defer { lock.unlock() }
        let key = Int(bitPattern: ObjectIdentifier(Service.self))
        let factory: ResolverFactoryAnyArguments = { (r,a) in factory(r, Args(a)) }
        let registration = ResolverRegistration<Service>(resolver: self, key: key, name: name, factory: factory )
        add(registration: registration, with: key, name: name)
        return ResolverOptions(registration: registration)
    }

    // MARK: - Service Resolution

    /// Static function calls the root registry to resolve a given Service type.
    ///
    /// - parameter type: Type of Service being resolved. Optional, may be inferred by assignment result type.
    /// - parameter name: Named variant of Service being resolved.
    /// - parameter args: Optional arguments that may be passed to registration factory.
    ///
    /// - returns: Instance of specified Service.
    public static func resolve<Service>(_ type: Service.Type = Service.self, name: DIInjector.Name? = nil, args: Any? = nil) -> Service {
        lock.lock()
        defer { lock.unlock() }
        registrationCheck()
        if let registration = root.lookup(type, name: name), let service = registration.resolve(resolver: root, args: args) {
            return service
        }
        fatalError("RESOLVER: '\(Service.self):\(name?.rawValue ?? "NONAME")' not resolved. To disambiguate optionals use resolver.optional().")
    }

    /// Resolves and returns an instance of the given Service type from the current registry or from its
    /// parent registries.
    ///
    /// - parameter type: Type of Service being resolved. Optional, may be inferred by assignment result type.
    /// - parameter name: Named variant of Service being resolved.
    /// - parameter args: Optional arguments that may be passed to registration factory.
    ///
    /// - returns: Instance of specified Service.
    ///
    public final func resolve<Service>(_ type: Service.Type = Service.self, name: DIInjector.Name? = nil, args: Any? = nil) -> Service {
        lock.lock()
        defer { lock.unlock() }
        registrationCheck()
        if let registration = lookup(type, name: name), let service = registration.resolve(resolver: self, args: args) {
            return service
        }
        fatalError("RESOLVER: '\(Service.self):\(name?.rawValue ?? "NONAME")' not resolved. To disambiguate optionals use resolver.optional().")
    }

    /// Static function calls the root registry to resolve an optional Service type.
    ///
    /// - parameter type: Type of Service being resolved. Optional, may be inferred by assignment result type.
    /// - parameter name: Named variant of Service being resolved.
    /// - parameter args: Optional arguments that may be passed to registration factory.
    ///
    /// - returns: Instance of specified Service.
    ///
    public static func optional<Service>(_ type: Service.Type = Service.self, name: DIInjector.Name? = nil, args: Any? = nil) -> Service? {
        lock.lock()
        defer { lock.unlock() }
        registrationCheck()
        if let registration = root.lookup(type, name: name), let service = registration.resolve(resolver: root, args: args) {
            return service
        }
        return nil
    }

    /// Resolves and returns an optional instance of the given Service type from the current registry or
    /// from its parent registries.
    ///
    /// - parameter type: Type of Service being resolved. Optional, may be inferred by assignment result type.
    /// - parameter name: Named variant of Service being resolved.
    /// - parameter args: Optional arguments that may be passed to registration factory.
    ///
    /// - returns: Instance of specified Service.
    ///
    public final func optional<Service>(_ type: Service.Type = Service.self, name: DIInjector.Name? = nil, args: Any? = nil) -> Service? {
        lock.lock()
        defer { lock.unlock() }
        registrationCheck()
        if let registration = lookup(type, name: name), let service = registration.resolve(resolver: self, args: args) {
            return service
        }
        return nil
    }

    // MARK: - Internal

    /// Internal function searches the current and child registries for a ResolverRegistration<Service> that matches
    /// the supplied type and name.
    private final func lookup<Service>(_ type: Service.Type, name: DIInjector.Name?) -> ResolverRegistration<Service>? {
        let key = Int(bitPattern: ObjectIdentifier(Service.self))
        if let name = name?.rawValue {
            if let registration = namedRegistrations["\(key):\(name)"] as? ResolverRegistration<Service> {
                return registration
            }
        } else if let registration = typedRegistrations[key] as? ResolverRegistration<Service> {
            return registration
        }
        for child in childContainers {
            if let registration = child.lookup(type, name: name) {
                return registration
            }
        }
        return nil
    }

    /// Internal function adds a new registration to the proper container.
    private final func add<Service>(registration: ResolverRegistration<Service>, with key: Int, name: DIInjector.Name?) {
        if let name = name?.rawValue {
            namedRegistrations["\(key):\(name)"] = registration
        } else {
            typedRegistrations[key] = registration
        }
    }

    private let NONAME = "*"
    private let lock = DIInjector.lock
    private var childContainers: [DIInjector] = []
    private var typedRegistrations = [Int : Any]()
    private var namedRegistrations = [String : Any]()
}

/// Resolving an instance of a service is a recursive process (service A needs a B which needs a C).
private final class ResolverRecursiveLock {
    init() {
        pthread_mutexattr_init(&recursiveMutexAttr)
        pthread_mutexattr_settype(&recursiveMutexAttr, PTHREAD_MUTEX_RECURSIVE)
        pthread_mutex_init(&recursiveMutex, &recursiveMutexAttr)
    }
    @inline(__always)
    final func lock() {
        pthread_mutex_lock(&recursiveMutex)
    }
    @inline(__always)
    final func unlock() {
        pthread_mutex_unlock(&recursiveMutex)
    }
    private var recursiveMutex = pthread_mutex_t()
    private var recursiveMutexAttr = pthread_mutexattr_t()
}

extension DIInjector {
    fileprivate static let lock = ResolverRecursiveLock()
}

/// Resolver Service Name Space Support
extension DIInjector {

    /// Internal class used by Resolver for typed name space support.
    public struct Name: ExpressibleByStringLiteral, Hashable, Equatable {
        public let rawValue: String
        public init(_ rawValue: String) {
            self.rawValue = rawValue
        }
        public init(stringLiteral: String) {
            self.rawValue = stringLiteral
        }
        public static func name(fromString string: String?) -> Name? {
            if let string = string { return Name(string) }
            return nil
        }
        static public func == (lhs: Name, rhs: Name) -> Bool {
            return lhs.rawValue == rhs.rawValue
        }
        public func hash(into hasher: inout Hasher) {
            hasher.combine(rawValue)
        }
    }

}

/// Resolver Multiple Argument Support
extension DIInjector {

    /// Internal class used by Resolver for multiple argument support.
    public struct Args {

        private var args: [String:Any?]

        public init(_ args: Any?) {
            if let args = args as? Args {
                self.args = args.args
            } else if let args = args as? [String:Any?] {
                self.args = args
            } else {
                self.args = ["" : args]
            }
        }

        #if swift(>=5.2)
        public func callAsFunction<T>() -> T {
            assert(args.count == 1, "argument order indeterminate, use keyed arguments")
            return (args.first?.value as? T)!
        }

        public func callAsFunction<T>(_ key: String) -> T {
            return (args[key] as? T)!
        }
        #endif

        public func optional<T>() -> T? {
            return args.first?.value as? T
        }

        public func optional<T>(_ key: String) -> T? {
            return args[key] as? T
        }

        public func get<T>() -> T {
            assert(args.count == 1, "argument order indeterminate, use keyed arguments")
            return (args.first?.value as? T)!
        }

        public func get<T>(_ key: String) -> T {
            return (args[key] as? T)!
        }

    }

}

// Registration Internals

private var registrationNeeded: Bool = true

@inline(__always)
private func registrationCheck() {
    guard registrationNeeded else {
        return
    }
    if let registering = (DIInjector.root as Any) as? DIInjectorRegistering {
        type(of: registering).registerAllServices()
    }
    registrationNeeded = false
}

public typealias ResolverFactory<Service> = () -> Service?
public typealias ResolverFactoryResolver<Service> = (_ resolver: DIInjector) -> Service?
public typealias ResolverFactoryArgumentsN<Service> = (_ resolver: DIInjector, _ args: DIInjector.Args) -> Service?
public typealias ResolverFactoryAnyArguments<Service> = (_ resolver: DIInjector, _ args: Any?) -> Service?
public typealias ResolverFactoryMutator<Service> = (_ resolver: DIInjector, _ service: Service) -> Void
public typealias ResolverFactoryMutatorArgumentsN<Service> = (_ resolver: DIInjector, _ service: Service, _ args: DIInjector.Args) -> Void

/// A ResolverOptions instance is returned by a registration function in order to allow additional configuration. (e.g. scopes, etc.)
public struct ResolverOptions<Service> {

    // MARK: - Parameters

    public var registration: ResolverRegistration<Service>

    // MARK: - Fuctionality

    /// Indicates that the registered Service also implements a specific protocol that may be resolved on
    /// its own.
    ///
    /// - parameter type: Type of protocol being registered.
    /// - parameter name: Named variant of protocol being registered.
    ///
    /// - returns: ResolverOptions instance that allows further customization of registered Service.
    ///
    @discardableResult
    public func implements<Protocol>(_ type: Protocol.Type, name: DIInjector.Name? = nil) -> ResolverOptions<Service> {
        registration.resolver?.register(type.self, name: name) { r, args in r.resolve(Service.self, args: args) as? Protocol }
        return self
    }

    /// Allows easy assignment of injected properties into resolved Service.
    ///
    /// - parameter block: Resolution block.
    ///
    /// - returns: ResolverOptions instance that allows further customization of registered Service.
    ///
    @discardableResult
    public func resolveProperties(_ block: @escaping ResolverFactoryMutator<Service>) -> ResolverOptions<Service> {
        registration.update { existingFactory in
            return { (resolver, args) in
                guard let service = existingFactory(resolver, args) else {
                    return nil
                }
                block(resolver, service)
                return service
            }
        }
        return self
    }

    /// Allows easy assignment of injected properties into resolved Service.
    ///
    /// - parameter block: Resolution block that also receives resolution arguments.
    ///
    /// - returns: ResolverOptions instance that allows further customization of registered Service.
    ///
    @discardableResult
    public func resolveProperties(_ block: @escaping ResolverFactoryMutatorArgumentsN<Service>) -> ResolverOptions<Service> {
        registration.update { existingFactory in
            return { (resolver, args) in
                guard let service = existingFactory(resolver, args) else {
                    return nil
                }
                block(resolver, service, DIInjector.Args(args))
                return service
            }
        }
        return self
    }

    /// Defines scope in which requested Service may be cached.
    ///
    /// - parameter block: Resolution block.
    ///
    /// - returns: ResolverOptions instance that allows further customization of registered Service.
    ///
    @discardableResult
    public func scope(_ scope: ResolverScope) -> ResolverOptions<Service> {
        registration.scope = scope
        return self
    }
}

/// ResolverRegistration base class provides storage for the registration keys, scope, and property mutator.
public final class ResolverRegistration<Service> {

    public let key: Int
    public let cacheKey: String
    
    fileprivate var factory: ResolverFactoryAnyArguments<Service>
    fileprivate var scope: ResolverScope = DIInjector.defaultScope
    
    fileprivate weak var resolver: DIInjector?

    public init(resolver: DIInjector, key: Int, name: DIInjector.Name?, factory: @escaping ResolverFactoryAnyArguments<Service>) {
        self.resolver = resolver
        self.key = key
        if let namedService = name {
            self.cacheKey = String(key) + ":" + namedService.rawValue
        } else {
            self.cacheKey = String(key)
        }
        self.factory = factory
    }

    /// Called by Resolver containers to resolve a registration. Depending on scope may return a previously cached instance.
    public final func resolve(resolver: DIInjector, args: Any?) -> Service? {
        return scope.resolve(registration: self, resolver: resolver, args: args)
    }
    
    /// Called by Resolver scopes to instantiate a new instance of a service.
    public final func instantiate(resolver: DIInjector, args: Any?) -> Service? {
        return factory(resolver, args)
    }
    
    /// Called by ResolverOptions to wrap a given service factory with new behavior.
    public final func update(factory modifier: (_ factory: @escaping ResolverFactoryAnyArguments<Service>) -> ResolverFactoryAnyArguments<Service>) {
        self.factory = modifier(factory)
    }

}

// Scopes

/// Resolver scopes exist to control when resolution occurs and how resolved instances are cached. (If at all.)
public protocol ResolverScopeType: AnyObject {
    func resolve<Service>(registration: ResolverRegistration<Service>, resolver: DIInjector, args: Any?) -> Service?
    func reset()
}

public class ResolverScope: ResolverScopeType {

    // Moved definitions to ResolverScope to allow for dot notation access

    /// All application scoped services exist for lifetime of the app. (e.g Singletons)
    public static let application = ResolverScopeCache()
    /// Proxy to container's scope. Cache type depends on type supplied to container (default .cache)
    public static let container = ResolverScopeContainer()
    /// Cached services exist for lifetime of the app or until their cache is reset.
    public static let cached = ResolverScopeCache()
    /// Graph services are initialized once and only once during a given resolution cycle. This is the default scope.
    public static let graph = ResolverScopeGraph()
    /// Shared services persist while strong references to them exist. They're then deallocated until the next resolve.
    public static let shared = ResolverScopeShare()
    /// Unique services are created and initialized each and every time they're resolved.
    public static let unique = ResolverScope()

    public init() {}
    
    /// Core scope resolution simply instantiates new instance every time it's called (e.g. .unique)
    public func resolve<Service>(registration: ResolverRegistration<Service>, resolver: DIInjector, args: Any?) -> Service? {
        return registration.instantiate(resolver: resolver, args: args)
    }
    
    public func reset() {
        // nothing to see here. move along.
    }
}

/// Cached services exist for lifetime of the app or until their cache is reset.
public class ResolverScopeCache: ResolverScope {

    public override init() {}

    public override func resolve<Service>(registration: ResolverRegistration<Service>, resolver: DIInjector, args: Any?) -> Service? {
        if let service = cachedServices[registration.cacheKey] as? Service {
            return service
        }
        let service = registration.instantiate(resolver: resolver, args: args)
        if let service = service {
            cachedServices[registration.cacheKey] = service
        }
        return service
    }

    public override func reset() {
        cachedServices.removeAll()
    }

    fileprivate var cachedServices = [String : Any](minimumCapacity: 32)
}

/// Graph services are initialized once and only once during a given resolution cycle. This is the default scope.
public final class ResolverScopeGraph: ResolverScope {

    public override init() {}

    public override final func resolve<Service>(registration: ResolverRegistration<Service>, resolver: DIInjector, args: Any?) -> Service? {
        if let service = graph[registration.cacheKey] as? Service {
            return service
        }
        resolutionDepth = resolutionDepth + 1
        let service = registration.instantiate(resolver: resolver, args: args)
        resolutionDepth = resolutionDepth - 1
        if resolutionDepth == 0 {
            graph.removeAll()
        } else if let service = service, type(of: service as Any) is AnyClass {
            graph[registration.cacheKey] = service
        }
        return service
    }
    
    public override final func reset() {}

    private var graph = [String : Any?](minimumCapacity: 32)
    private var resolutionDepth: Int = 0
}

/// Shared services persist while strong references to them exist. They're then deallocated until the next resolve.
public final class ResolverScopeShare: ResolverScope {

    public override init() {}

    public override final func resolve<Service>(registration: ResolverRegistration<Service>, resolver: DIInjector, args: Any?) -> Service? {
        if let service = cachedServices[registration.cacheKey]?.service as? Service {
            return service
        }
        let service = registration.instantiate(resolver: resolver, args: args)
        if let service = service, type(of: service as Any) is AnyClass {
            cachedServices[registration.cacheKey] = BoxWeak(service: service as AnyObject)
        }
        return service
    }

    public override final func reset() {
        cachedServices.removeAll()
    }

    private struct BoxWeak {
        weak var service: AnyObject?
    }

    private var cachedServices = [String : BoxWeak](minimumCapacity: 32)
}

/// Unique services are created and initialized each and every time they're resolved. Performed by default implementation of ResolverScope.
public typealias ResolverScopeUnique = ResolverScope

/// Proxy to container's scope. Cache type depends on type supplied to container (default .cache)
public final class ResolverScopeContainer: ResolverScope {
    
    public override init() {}
    
    public override final func resolve<Service>(registration: ResolverRegistration<Service>, resolver: DIInjector, args: Any?) -> Service? {
        return resolver.cache.resolve(registration: registration, resolver: resolver, args: args)
    }
    
}


//#if os(iOS)
///// Storyboard Automatic Resolution Protocol
//public protocol StoryboardResolving: Resolving {
//    func resolveViewController()
//}
//
///// Storyboard Automatic Resolution Trigger
//public extension UIViewController {
//    // swiftlint:disable unused_setter_value
//    @objc dynamic var resolving: Bool {
//        get {
//            return true
//        }
//        set {
//            if let vc = self as? StoryboardResolving {
//                vc.resolveViewController()
//            }
//        }
//    }
//    // swiftlint:enable unused_setter_value
//}
//#endif

// MARK: - <# name #>
// Swift Property Wrappers

@propertyWrapper public struct Injected<Service> {
    private var service: Service
    public init() {
        self.service = DIInjector.resolve(Service.self)
    }
    public init(name: DIInjector.Name? = nil, container: DIInjector? = nil) {
        self.service = container?.resolve(Service.self, name: name) ?? DIInjector.resolve(Service.self, name: name)
    }
    public var wrappedValue: Service {
        get { return service }
        mutating set { service = newValue }
    }
    public var projectedValue: Injected<Service> {
        get { return self }
        mutating set { self = newValue }
    }
}

@propertyWrapper public struct OptionalInjected<Service> {
    private var service: Service?
    public init() {
        self.service = DIInjector.optional(Service.self)
    }
    public init(name: DIInjector.Name? = nil, container: DIInjector? = nil) {
        self.service = container?.optional(Service.self, name: name) ?? DIInjector.optional(Service.self, name: name)
    }
    public var wrappedValue: Service? {
        get { return service }
        mutating set { service = newValue }
    }
    public var projectedValue: OptionalInjected<Service> {
        get { return self }
        mutating set { self = newValue }
    }
}

@propertyWrapper public struct LazyInjected<Service> {
    private var lock = DIInjector.lock
    private var initialize: Bool = true
    private var service: Service!
    public var container: DIInjector?
    public var name: DIInjector.Name?
    public var args: Any?
    public init() {}
    public init(name: DIInjector.Name? = nil, container: DIInjector? = nil) {
        self.name = name
        self.container = container
    }
    public var isEmpty: Bool {
        lock.lock()
        defer { lock.unlock() }
        return service == nil
    }
    public var wrappedValue: Service {
        mutating get {
            lock.lock()
            defer { lock.unlock() }
            if initialize {
                self.initialize = false
                self.service = container?.resolve(Service.self, name: name, args: args) ?? DIInjector.resolve(Service.self, name: name, args: args)
            }
            return service
        }
        mutating set {
            lock.lock()
            defer { lock.unlock() }
            initialize = false
            service = newValue
        }
    }
    public var projectedValue: LazyInjected<Service> {
        get { return self }
        mutating set { self = newValue }
    }
    public mutating func release() {
        lock.lock()
        defer { lock.unlock() }
        self.service = nil
    }
}

@propertyWrapper public struct WeakLazyInjected<Service> {
    private var lock = DIInjector.lock
    private var initialize: Bool = true
    private weak var service: AnyObject?
    public var container: DIInjector?
    public var name: DIInjector.Name?
    public var args: Any?
    public init() {}
    public init(name: DIInjector.Name? = nil, container: DIInjector? = nil) {
        self.name = name
        self.container = container
    }
    public var isEmpty: Bool {
        lock.lock()
        defer { lock.unlock() }
        return service == nil
    }
    public var wrappedValue: Service? {
        mutating get {
            lock.lock()
            defer { lock.unlock() }
            if initialize {
                self.initialize = false
                self.service = (container?.resolve(Service.self, name: name, args: args)
                                    ?? DIInjector.resolve(Service.self, name: name, args: args)) as AnyObject
            }
            return service as? Service
        }
        mutating set {
            lock.lock()
            defer { lock.unlock() }
            initialize = false
            service = newValue as AnyObject
        }
    }
    public var projectedValue: WeakLazyInjected<Service> {
        get { return self }
        mutating set { self = newValue }
    }
}

@available(OSX 10.15, iOS 13.0, tvOS 13.0, watchOS 6.0, *)
@propertyWrapper public struct InjectedObject<Service>: DynamicProperty where Service: ObservableObject {
    @ObservedObject private var service: Service
    public init() {
        self.service = DIInjector.resolve(Service.self)
    }
    public init(name: DIInjector.Name? = nil, container: DIInjector? = nil) {
        self.service = container?.resolve(Service.self, name: name) ?? DIInjector.resolve(Service.self, name: name)
    }
    public var wrappedValue: Service {
        get { return service }
        mutating set { service = newValue }
    }
    public var projectedValue: ObservedObject<Service>.Wrapper {
        return self.$service
    }
}
