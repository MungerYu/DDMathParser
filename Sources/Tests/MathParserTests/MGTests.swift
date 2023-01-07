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
    
    func testComplexExponent() {
        let expression = "2⁻⁽²⁺¹⁾⁺⁵**5+3"
        guard let tokens = XCTAssertNoThrows(try Tokenizer(string: expression).tokenize()) else { return }
        printLog("expression:\(expression) = \(tokens)")
        for token in tokens {
            printLog("expression: range = \(token.range)")
            printLog("expression: string = \(token.string)")
        }
        XCTAssertEqual(tokens.count, 2)
        
    }
    
    
    func testIssue3() {
        let expression = "8÷2(2+2)"
        guard let valuate = XCTAssertNoThrows(try expression.evaluate()) else { return }
        printLog("expression:\(expression) = \(valuate)")
        
        XCTAssertEqual(valuate, 2)
        
    }
}

func printLog<T>(_ message: T,file: String = #file,method: String = #function,line: Int = #line){
    let dFormatter = DateFormatter()
    dFormatter.dateFormat = "yyyy/MM/dd HH:mm:ss SSS"
    let date = dFormatter.string(from: Date())
    print("\(date),Line = [\(line)], Method = \(method): \(message)")
}
