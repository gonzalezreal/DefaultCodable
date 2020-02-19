import DefaultCodable
import XCTest

final class DefaultTests: XCTestCase {
    private enum ThingType: String, Codable, CaseIterable {
        case foo, bar, baz
    }

    private struct Thing: Codable, Equatable {
        var name: String

        @Default<Empty>
        var description: String

        @Default<True>
        var isFoo: Bool

        @Default<FirstCase>
        var type: ThingType

        @Default<ZeroDouble>
        var floatingPoint: Double
    }

    func testValueDecodesToActualValue() throws {
        // given
        let json = """
        {
          "name": "Any name",
          "description": "Any description",
          "isFoo": false,
          "type": "baz",
          "floatingPoint": 12.34
        }
        """.data(using: .utf8)!

        // when
        let result = try JSONDecoder().decode(Thing.self, from: json)

        // then
        XCTAssertEqual("Any description", result.description)
        XCTAssertFalse(result.isFoo)
        XCTAssertEqual(ThingType.baz, result.type)
        XCTAssertEqual(result.floatingPoint, 12.34)
    }

    func testNullDecodesToDefaultValue() throws {
        // given
        let json = """
        {
          "name": "Any name",
          "description": null,
          "isFoo": null,
          "type": null,
          "floatingPoint": null
        }
        """.data(using: .utf8)!

        // when
        let result = try JSONDecoder().decode(Thing.self, from: json)

        // then
        XCTAssertEqual("", result.description)
        XCTAssertTrue(result.isFoo)
        XCTAssertEqual(ThingType.foo, result.type)
        XCTAssertEqual(result.floatingPoint, 0)
    }

    func testNotPresentValueDecodesToDefaultValue() throws {
        // given
        let json = """
        {
          "name": "Any name"
        }
        """.data(using: .utf8)!

        // when
        let result = try JSONDecoder().decode(Thing.self, from: json)

        // then
        XCTAssertEqual("", result.description)
        XCTAssertTrue(result.isFoo)
        XCTAssertEqual(ThingType.foo, result.type)
        XCTAssertEqual(result.floatingPoint, 0)
    }

    func testTypeMismatchThrows() {
        // given
        let json = """
        {
          "name": "Any name",
          "description": ["nope"],
          "isFoo": 5500,
          "type": [1, 2, 3],
          "floatingPoint": "point"
        }
        """.data(using: .utf8)!

        // then
        XCTAssertThrowsError(try JSONDecoder().decode(Thing.self, from: json))
    }

    @available(OSX 10.13, iOS 11.0, watchOS 4.0, tvOS 11.0, *)
    func testValueEncodesToActualValue() throws {
        // given
        let thing = Thing(name: "Any name", description: "Any description", isFoo: false, type: .baz, floatingPoint: 12.34)
        let expected = """
        {
          "description" : "Any description",
          "floatingPoint" : 12.34,
          "isFoo" : false,
          "name" : "Any name",
          "type" : "baz"
        }
        """.data(using: .utf8)!
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]

        // when
        let result = try encoder.encode(thing)

        // then
        XCTAssertEqual(expected, result)
    }

    func testDefaultValueEncodesToNothing() throws {
        // given
        let thing = Thing(name: "Any name")
        let expected = """
        {
          "name" : "Any name"
        }
        """.data(using: .utf8)!
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.prettyPrinted]

        // when
        let result = try encoder.encode(thing)

        // then
        XCTAssertEqual(expected, result)
    }

    static var allTests = [
        ("testValueDecodesToActualValue", testValueDecodesToActualValue),
        ("testNullDecodesToDefaultValue", testNullDecodesToDefaultValue),
        ("testNotPresentValueDecodesToDefaultValue", testNotPresentValueDecodesToDefaultValue),
        ("testTypeMismatchThrows", testTypeMismatchThrows),
        ("testDefaultValueEncodesToNothing", testDefaultValueEncodesToNothing),
    ]
}
