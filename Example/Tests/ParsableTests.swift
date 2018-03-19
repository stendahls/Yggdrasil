import XCTest
import Yggdrasil

class ParsableTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    struct DummyDecodable: Codable, Hashable, Parsable {
        let text: String
        let number: Int
    }
    
    func testThatDataObjectSupportsParsable() {
        let data = "FooBar".data(using: .utf8)!
        
        XCTAssert(try Data.parseData(data) == data)
    }
    
    func testThatDecodableObjectSupportsParsable() {
        do {
            let decodable = DummyDecodable(text: "FooBar", number: 42)
            let data = try JSONEncoder().encode(decodable)
            let result: DummyDecodable = try DummyDecodable.parseData(data)
            
            XCTAssert(result == decodable)
        } catch {
            XCTFail(error.localizedDescription)
        }
    }
    
    func testThatArrayWithDecodablesSupportsParsable() {
        do {
            let arrayOfdecodables = [DummyDecodable(text: "FooBar", number: 42), DummyDecodable(text: "BarFoo", number: 24)]
            let data = try JSONEncoder().encode(arrayOfdecodables)
            let result: [DummyDecodable] = try DummyDecodable.parseData(data)
            
            for (A, B) in zip(arrayOfdecodables, result) {
                XCTAssert(A == B)
            }
        } catch {
            XCTFail(error.localizedDescription)
        }
    }
}
