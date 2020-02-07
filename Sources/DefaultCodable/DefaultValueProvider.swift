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

public enum FirstCase<A>: DefaultValueProvider where A: Codable, A: Equatable, A: CaseIterable {
    public static var `default`: A { A.allCases.first! }
}
