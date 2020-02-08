# DefaultCodable
![Swift 5.1](https://img.shields.io/badge/Swift-5.1-orange.svg)
[![Swift Package Manager](https://img.shields.io/badge/spm-compatible-brightgreen.svg?style=flat)](https://swift.org/package-manager)
[![Twitter: @gonzalezreal](https://img.shields.io/badge/twitter-@gonzalezreal-blue.svg?style=flat)](https://twitter.com/gonzalezreal)

**DefaultCodable** is a Swift µpackage that provides a convenient way to define default values in `Codable` types for properties that are **not present or have a `nil` value**.

## Usage
Consider a hypothetical model for Apple products., in which only the property `name` is *required*.

```swift
enum ProductType: String, Codable, CaseIterable {
  case phone, pad, mac, accesory
}

struct Product: Codable {
  var name: String
  var description: String?
  var isAvailable: Bool?
  var type: ProductType?
}
```

Using the `@Default` property wrapper, we can provide default values for the properties not required and thus get rid of the optionals in our model.

```swift
struct Product: Codable {
  var name: String
  
  @Default<Empty>
  var description: String
  
  @Default<True>
  var isAvailable: Bool
  
  @Default<FirstCase>
  var type: ProductType
}
```

With that in place, we can safely decode the following JSON into a `Product` type.

```json
{
  "name": "iPhone 11 Pro"
}
```

The resulting `Product` instance is using the default values for those properties not present in the JSON.

```
▿ Product
- name : "iPhone 11 Pro"
- description : ""
- isAvailable : true
- type : ProductType.phone
```

If you encode the result back, the resulting JSON will be the same as the one we started with. The `@Default` property wrapper will not encode the value if it is equal to the default value.

The `@Default` property wrapper takes a `DefaultValueProvider` as a parameter. This type provides the default value when a value is not present or is `nil`.

```swift
protocol DefaultValueProvider {
  associatedtype Value: Equatable & Codable
  
  static var `default`: Value { get }
}
```

**DefaultCodable** provides the following implementations for your convenience:

### `Empty`
It provides an empty instance of a `String`, `Array` or any type that implements `RangeReplaceableCollection`.

### `True` and `False`
Provide `true` and `false` respectively for `Bool` properties.

### `Zero` and `One`
Provide `0` and `1` respectively for `Int` properties.

### `FirstCase`
It provides the first case of an `enum` type as the default value. The `enum` must implement the `CaseIterable` protocol.

## Default values for custom types
Your custom type must implement the `DefaultValueProvider` protocol to be compatible with the `@Default` property wrapper.

Consider the following type that models a role in a conversation:

```swift
struct Role: Codable, Equatable, Hashable, RawRepresentable {
  let rawValue: String

  init?(rawValue: String) {
    self.rawValue = rawValue
  }

  static let user = Role(rawValue: "user")!
  static let bot = Role(rawValue: "bot")!
}
```

If we want the default role to be `user`, we can implement `DefaultValueProvider` as follows:

```swift
extension Role: DefaultValueProvider {
  static let `default` = user
}
```

With that in place, we can use the `@Default` property wrapper in any type that has a property of type `Role`:

```swift
struct ChannelAccount: Codable {
  var name: String
  
  @Default<Role>
  var role: Role
}
```

## Installation
**Using the Swift Package Manager**

Add **DefaultCodable** as a dependency to your `Package.swift` file. For more information, see the [Swift Package Manager documentation](https://github.com/apple/swift-package-manager/tree/master/Documentation).

```
.package(url: "https://github.com/gonzalezreal/DefaultCodable", from: "1.0.0")
```

## Help & Feedback
- [Open an issue](https://github.com/gonzalezreal/DefaultCodable/issues/new) if you need help, if you found a bug, or if you want to discuss a feature request.
- [Open a PR](https://github.com/gonzalezreal/DefaultCodable/pull/new/master) if you want to make some change to `DefaultCodable`.
- Contact [@gonzalezreal](https://twitter.com/gonzalezreal) on Twitter.
