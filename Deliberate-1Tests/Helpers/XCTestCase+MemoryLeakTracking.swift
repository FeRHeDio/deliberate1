//
//  XCTestCase+MemoryLeakTracking.swift
//  Deliberate-1Tests
//
//  Created by Fernando Putallaz on 28/05/2023.
//

import XCTest

extension XCTestCase {
    func trackForMemoryLeaks(_ instance: AnyObject, file: StaticString = #file, line: UInt = #line) {
        addTeardownBlock { [weak instance] in
            XCTAssertNil(instance, "Instance should be deallocated, potential memory leak.", file: file, line: line)
        }
    }
}
