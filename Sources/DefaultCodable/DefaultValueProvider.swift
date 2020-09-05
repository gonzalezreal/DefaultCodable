import Foundation

public protocol DefaultValueProvider {
    associatedtype Value: Equatable & Codable

    static var `default`: Value { get }
}

public enum False: DefaultValueProvider {
    public static let `default` = false
}

public enum True: DefaultValueProvider {
    public static let `default` = true
}

public enum Empty<A>: DefaultValueProvider where A: Codable, A: Equatable, A: RangeReplaceableCollection {
    public static var `default`: A { A() }
}

public enum EmptyDictionary<K, V>: DefaultValueProvider where K: Hashable & Codable, V: Equatable & Codable {
    public static var `default`: [K: V] { Dictionary() }
}

public enum FirstCase<A>: DefaultValueProvider where A: Codable, A: Equatable, A: CaseIterable {
    public static var `default`: A { A.allCases.first! }
}

public enum Zero: DefaultValueProvider {
    public static let `default` = 0
}

public enum One: DefaultValueProvider {
    public static let `default` = 1
}

public enum ZeroDouble: DefaultValueProvider {
    public static let `default`: Double = 0
}
