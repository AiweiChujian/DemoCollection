//
//  Chapter1.swift
//  AsyncDemo
//
//  Created by Aiwei on 2023/4/13.
//

import Foundation

enum Chapter1: Testable {
    static func testCase() {
        
    }
}

extension Chapter1 {
    class GCDUsage {
        var results: [String] = []
        
        func appending(_ value: String, to string: String) {
            results.append(value.appending(string))
        }
        
        func loadSignature() throws -> String? {
            let data = try Data(contentsOf: URL(string:"https://www.baidu.com")!)
            return String(data: data, encoding: .utf8)
        }
    }
}

extension Chapter1 {
    class AsyncUsage {
        
    }
}
