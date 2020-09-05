import DefaultCodable
import XCTest

final class DefaultTests: XCTestCase {
    private enum ThingType: String, Codable, CaseIterable {
        case foo, bar, baz
    }

    private struct Thing: Codable, Equatable {
        var name: String

        @Default<Empty> var description: String
        @Default<EmptyDictionary> var entities: [String: String]
        @Default<True> var isFoo: Bool
        @Default<FirstCase> var type: ThingType
        @Default<ZeroDouble> var floatingPoint: Double

        init(
            name: String,
            description: String = "",
            entities: [String: String] = [:],
            isFoo: Bool = true,
            type: ThingType = .foo,
            floatingPoint: Double = 0
        ) {
            self.name = name
            self.description = description
            self.entities = entities
            self.isFoo = isFoo
            self.type = type
            self.floatingPoint = floatingPoint
        }
    }

    func testValueDecodesToActualValue() throws {
        // given
        let json = """
        {
          "name": "Any name",
          "description": "Any description",
          "entities": {
            "foo": "bar"
          },
          "isFoo": false,
          "type": "baz",
          "floatingPoint": 12.34
        }
        """.data(using: .utf8)!

        // when
        let result = try JSONDecoder().decode(Thing.self, from: json)

        // then
        XCTAssertEqual("Any description", result.description)
        XCTAssertEqual(["foo": "bar"], result.entities)
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
          "entities": null,
          "isFoo": null,
          "type": null,
          "floatingPoint": null
        }
        """.data(using: .utf8)!

        // when
        let result = try JSONDecoder().decode(Thing.self, from: json)

        // then
        XCTAssertEqual("", result.description)
        XCTAssertEqual([:], result.entities)
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
        XCTAssertEqual([:], result.entities)
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
        let thing = Thing(
            name: "Any name",
            description: "Any description",
            entities: ["foo": "bar"],
            isFoo: false,
            type: .baz,
            floatingPoint: 12.34
        )
        let expected = """
        {
          "description" : "Any description",
          "entities" : {
            "foo" : "bar"
          },
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
