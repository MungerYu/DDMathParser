//
//  GroupingTests.swift
//  DDMathParser
//
//  Created by Dave DeLong on 8/15/15.
//
//

import XCTest
import DDMathParser

class GroupingTests: XCTestCase {
    
    func testNumber() {
        let g = TokenGrouper(string: "1")
        guard let t = XCTAssertNoThrows(try g.group()) else { return }
        switch t.kind {
            case .number(1.0): break
            default: XCTFail("Unexpected token kind")
        }
    }
    
    func testVariable() {
        let g = TokenGrouper(string: "$foo")
        guard let t = XCTAssertNoThrows(try g.group()) else { return }
        switch t.kind {
            case .variable("foo"): break
            default: XCTFail("Unexpected token kind")
        }
    }
    
    func testIdentifier() {
        let g = TokenGrouper(string: "foo")
        guard let t = XCTAssertNoThrows(try g.group()) else { return }
        switch t.kind {
            case .function("foo", _): break
            default: XCTFail("Unexpected token kind")
        }
    }
    
    func testNumberAndOperator() {
        let g = TokenGrouper(string: "1+1")
        guard let t = XCTAssertNoThrows(try g.group()) else { return }
        switch t.kind {
            case .group(let tokens):
                XCTAssert(tokens.count == 3)
            default: XCTFail("Unexpected token kind")
        }
    }
    
    func testGroupedNumber() {
        let g = TokenGrouper(string: "(1)")
        guard let t = XCTAssertNoThrows(try g.group()) else { return }
        switch t.kind {
            case .number(1.0): break
            default: XCTFail("Unexpected token kind")
        }
    }
    
    func testRedundantGroups() {
        let g = TokenGrouper(string: "(((foo())))")
        guard let t = XCTAssertNoThrows(try g.group()) else { return }
        
        switch t.kind {
            case .function("foo", _): break
            default: XCTFail("Unexpected token kind")
        }
    }
    
    func testEmptyFunctionArgument() {
        let g = TokenGrouper(string: "foo(,1)")
        
        do {
            let _ = try g.group()
            XCTFail("Expected error")
        } catch let other {
            guard let error = other as? MathParserError else {
                XCTFail("Unexpected error \(other)")
                return
            }
            XCTAssert(error.kind == .emptyFunctionArgument)
        }
    }
    
    func testFunctionMissingOpenParenthesis() {
        let r = TokenResolver(string: "foo", configuration: .defaultWithEmptyOptions)
        let g = TokenGrouper(resolver: r)
        
        do {
            let _ = try g.group()
            XCTFail("Expected error")
        } catch let other {
            guard let error = other as? MathParserError else {
                XCTFail("Unexpected error \(other)")
                return
            }
            XCTAssert(error.kind == .missingOpenParenthesis)
        }
    }
    
    func testFunctionMissingCloseParenthesis() {
        let r = TokenResolver(string: "foo(", configuration: .defaultWithEmptyOptions)
        let g = TokenGrouper(resolver: r)
        
        do {
            let _ = try g.group()
            XCTFail("Expected error")
        } catch let other {
            guard let error = other as? MathParserError else {
                XCTFail("Unexpected error \(other)")
                return
            }
            XCTAssert(error.kind == .missingCloseParenthesis)
        }
    }
    
    func testGroupMissingCloseParenthesis() {
        let g = TokenGrouper(string: "(4")
        
        do {
            let _ = try g.group()
            XCTFail("Expected error")
        } catch let other {
            guard let error = other as? MathParserError else {
                XCTFail("Unexpected error \(other)")
                return
            }
            XCTAssert(error.kind == .missingCloseParenthesis)
        }
    }
    
    func testGroupMissingOpenParenthesis() {
        let g = TokenGrouper(string: "4)")
        
        do {
            let _ = try g.group()
            XCTFail("Expected error")
        } catch let other {
            guard let error = other as? MathParserError else {
                XCTFail("Unexpected error \(other)")
                return
            }
            XCTAssert(error.kind == .missingOpenParenthesis)
        }
    }
    
    func testFunctionParameterGrouping() {
        let g = TokenGrouper(string: "foo(1,2+3,-4)")
        guard let t = XCTAssertNoThrows(try g.group()) else { return }
        
        switch t.kind {
            case .function("foo", let parameters):
                XCTAssertEqual(parameters.count, 3)
                // first parameter
                guard case .number(1) = parameters[0].kind else { XCTFail("Unexpected parameter 1"); return }
            
                // second parameter
                guard case .group(let second) = parameters[1].kind else {
                    XCTFail("Unexpected parameter 2"); return
                }
                XCTAssertEqual(second.count, 3)
                guard case .number(2) = second[0].kind else {
                    XCTFail("Unexpected parameter 2,1"); return
                }
                guard case .operator(Operator(builtInOperator: .add)) = second[1].kind else {
                    XCTFail("Unexpected parameter 2,2"); return
                }
                guard case .number(3) = second[2].kind else {
                    XCTFail("Unexpected parameter 2,3"); return
                }
            
                guard case .group(let third) = parameters[2].kind else {
                    XCTFail("Unexpected parameter 3"); return
                }
                XCTAssertEqual(third.count, 2)
            
                guard case .operator(Operator(builtInOperator: .unaryMinus)) = third[0].kind else {
                    XCTFail("Unexpected parameter 3,1"); return
                }
                guard case .number(4) = third[1].kind else {
                    XCTFail("Unexpected parameter 3,2"); return
                }
            default:
                XCTFail("Unexpected token kind")
        }
    }
    
    func testEmptyRootGroup() {
        let g = TokenGrouper(string: "")
        
        do {
            let _ = try g.group()
            XCTFail("Expected error")
        } catch let other {
            guard let error = other as? MathParserError else {
                XCTFail("Unexpected error \(other)")
                return
            }
            XCTAssert(error.kind == .emptyGroup)
        }
    }
    
    func testEmptyGroup() {
        let g = TokenGrouper(string: "1+()")
        
        do {
            let _ = try g.group()
            XCTFail("Expected error")
        } catch let other {
            guard let error = other as? MathParserError else {
                XCTFail("Unexpected error \(other)")
                return
            }
            XCTAssert(error.kind == .emptyGroup)
        }
    }
    
    func testUnaryPlus() {
        guard let g = XCTAssertNoThrows(try TokenGrouper(string: "+1").group()) else { return }
        
        guard case let .group(subterms) = g.kind else {
            XCTFail("Unexpected group: \(g)")
            return
        }
        
        XCTAssertEqual(subterms.count, 2)
        let unaryPlus = Operator(builtInOperator: .unaryPlus)
        guard case .operator(unaryPlus) = subterms[0].kind else {
            XCTFail("Unexpected token kind: \(subterms[0].kind)")
            return
        }
        
        guard case .number(1) = subterms[1].kind else {
            XCTFail("Unexpected token kind: \(subterms[1].kind)")
            return
        }
    }

}
