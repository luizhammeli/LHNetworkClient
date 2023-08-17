//
//  XCTestCase+MemoryLeakTrack.swift
//  
//
//  Created by Luiz Diniz Hammerli on 17/08/23.
//

import Foundation
import XCTest

extension XCTestCase {
    func checkForMemoryLeaks(instance: AnyObject, file: StaticString = #filePath, line: UInt = #line) {
        addTeardownBlock { [weak instance] in
            XCTAssertNil(instance, file: file, line: line)
        }
    }
}

