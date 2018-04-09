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
    
    struct DummyDecodable: Codable, Hashable, Parsable, Equatable {
        let text: String
        let number: Int
        let date: Date
        
        static func dateDecodingStrategy() -> JSONDecoder.DateDecodingStrategy {
            return .millisecondsSince1970
        }
        
        static func == (lhs: ParsableTests.DummyDecodable, rhs: ParsableTests.DummyDecodable) -> Bool {
            // We cast here to Int to avoid erros on milliseconds level during encoding/decoding

            return lhs.text == rhs.text &&
                lhs.number == rhs.number &&
                Int(lhs.date.timeIntervalSince1970) == Int(rhs.date.timeIntervalSince1970)
        }
        
    }
    
    func testThatDataObjectSupportsParsable() {
        let data = "FooBar".data(using: .utf8)!
        
        XCTAssert(try Data.parseData(data) == data)
    }
    
    func testThatDecodableObjectSupportsParsable() {
        do {
            let decodable = DummyDecodable(text: "FooBar", number: 42, date: .init())
            let encoder = JSONEncoder()
            encoder.dateEncodingStrategy = .millisecondsSince1970
            let data = try encoder.encode(decodable)
            let result: DummyDecodable = try DummyDecodable.parseData(data)
            
            XCTAssert(result == decodable)
        } catch {
            XCTFail(error.localizedDescription)
        }
    }
    
    func testThatParsableDateDecodingStrategyIsRespected() {
        do {
            let decodable = DummyDecodable(text: "FooBar", number: 42, date: .init())
            let encoder = JSONEncoder()
            encoder.dateEncodingStrategy = .millisecondsSince1970
            let data = try encoder.encode(decodable)
            let result: DummyDecodable = try DummyDecodable.parseData(data)
            
            XCTAssert(result == decodable)
        } catch {
            XCTFail(error.localizedDescription)
        }
    }
    
    func testThatArrayWithDecodablesSupportsParsable() {
        do {
            let arrayOfdecodables = [
                DummyDecodable(text: "FooBar", number: 42, date: .init()),
                DummyDecodable(text: "BarFoo", number: 24, date: .init())]
            
            let encoder = JSONEncoder()
            encoder.dateEncodingStrategy = .millisecondsSince1970
            let data = try encoder.encode(arrayOfdecodables)
            let result: [DummyDecodable] = try DummyDecodable.parseData(data)
            
            for (A, B) in zip(arrayOfdecodables, result) {
                XCTAssert(A == B)
            }
        } catch {
            XCTFail(error.localizedDescription)
        }
    }
}
