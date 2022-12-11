//
//  MGTests.swift
//  DDMathParserDemoTests
//
//  Created by 余洁洁 on 12/11/22.
//

import XCTest
import DDMathParser

class MGTests: XCTestCase {
    func testIssue1() {
        let expression = "(3*3)-3+3"
        guard let d = XCTAssertNoThrows(try expression.evaluate()) else { return }
        printLog("expression:\(expression) = \(d)")
        XCTAssertEqual(d, 9)
    }
    
    func testIssue2() {
        let expression = "(3  **  3)-3+3"
        guard let d = XCTAssertNoThrows(try expression.evaluate()) else { return }
        printLog("expression:\(expression) = \(d)")
        XCTAssertEqual(d, 27)
    }
}

func printLog<T>(_ message: T,file: String = #file,method: String = #function,line: Int = #line){
    let dFormatter = DateFormatter()
    dFormatter.dateFormat = "yyyy/MM/dd HH:mm:ss SSS"
    let date = dFormatter.string(from: Date())
    print("\(date),Line = [\(line)], Method = \(method): \(message)")
}
