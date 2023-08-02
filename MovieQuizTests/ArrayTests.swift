import XCTest
@testable import MovieQuiz

class ArrayTests: XCTestCase {
    // тест на успешное взятие элемента по индексу
    func testGetValueInRange() throws {
        // Given
        let array = [1, 1, 4, 3, 5]
        // When
        let value = array[safe: 2]
        // Then
        XCTAssertNotNil(value)
        XCTAssertEqual(value, 4)
    }
    // тест на взятие элемента по неправильному индексу
    func testGetValueOutOfRange() throws {
        // Given
        let array = [1, 1, 4, 3, 5]
        // When
        let value = array[safe: 6]
        // Then
        XCTAssertNil(value)
    }
}
