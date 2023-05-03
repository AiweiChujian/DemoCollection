//
//  Chapter1.swift
//  AsyncDemo
//
//  Created by Aiwei on 2023/4/13.
//

import Foundation

/// Chapter 1 - Swift 并发初步
enum Chapter1: Testable {
    static func testCase() {
//        GCDUsage().testProcess()
        
//        for _ in 0 ..< 10 {
//            AsyncUsage().testProcess()
//        }
        
        let usage = AsyncUsage()
        for _ in 0 ..< 100 {
            usage.testProcess()
        }
    }
}

extension Chapter1 {
    enum GeneralError: Error {
        case loadDataError
        case loadSignatureError
    }
}

extension Chapter1 {
    class GCDHolder {
        private let queue = DispatchQueue(label: "resultholder.queue")
        private(set) var results: [String] = []
        
        func getResults() -> [String] {
            queue.sync { results }
        }
        
        func setResults(_ results: [String]) {
            queue.async { self.results = results }
        }
        
        func append(_ value: String) {
            queue.async { self.results.append(value) }
        }
    }
}

extension Chapter1 {
    class GCDUsage {
        let holder = GCDHolder()
        
        func appending(_ value: String, to string: String) {
            holder.append(string.appending(value))
        }
        
        func loadSignature(_ completion: @escaping (String?, Error?) -> Void) {
            DispatchQueue.global().async {
                // mock network load
                sleep(1)
                let signature = "sig"
                DispatchQueue.main.async {
                    completion(signature, nil)
                }
            }
        }
        
        func loadFromDatabase(_ completion: @escaping ([String]?, Error?) -> Void) {
            DispatchQueue.global().async {
                // mock db load
                sleep(1)
                let results = ["data1", "data2", "data3"]
                DispatchQueue.main.async {
                    completion(results, nil)
                }
            }
        }
    }
}

extension Chapter1.GCDUsage {
    func testProcess() {
        loadFromDatabase { strings, error in
            guard let strings = strings else {
                print(error ?? Chapter1.GeneralError.loadDataError)
                return
            }
            self.loadSignature { signature, error in
                guard let signature = signature else {
                    print(error ?? Chapter1.GeneralError.loadSignatureError)
                    return
                }
                strings.forEach {
                    self.appending(signature, to: $0)
                }
                print("GCD Done: \(self.holder.results)")
            }
        }
    }
}

extension Chapter1 {
    actor ActorHolder {
        private(set) var results: [String] = []
        
        func setResults(_ results: [String]) {
            self.results = results
        }
        
        func append(_ value: String) {
            results.append(value)
        }
    }
}

extension Chapter1 {
    class AsyncUsage {
        let holder = ActorHolder()
        
        func appending(_ value: String, to string: String) async {
            await holder.append(string.appending(value))
        }
        
        func loadSignatrue() async throws -> String? {
            // mock network load
            try await Task.sleep(nanoseconds: NSEC_PER_SEC * 1)
            return "sig"
        }
        
        func loadFromDatabase() async throws -> [String]? {
            // mock db load
            try await Task.sleep(nanoseconds: NSEC_PER_SEC * 1)
            return ["data1", "data2", "data3"]
        }
        
        func loadResultRemotely() async throws {
            try await Task.sleep(nanoseconds: NSEC_PER_SEC * 1)
            let results = ["data1^sig", "data2^sig", "data3^sig"]
            await holder.setResults(results)
        }
    }
}


extension Chapter1.AsyncUsage {
    func testProcess() {
        Task {
            await withThrowingTaskGroup(of: Void.self) { group in
                group.addTask {
                    try await self.loadResultRemotely()
                }
                group.addTask(priority: .low) {
                    try await self.processFromScratch()
                }
            }
            print("Async Done: \(await holder.results)")
        }
    }
    
    func processFromScratch() async throws {
        async let loadStrings = try await loadFromDatabase()
        async let loadSignature = try await loadSignatrue()
        await holder.setResults([])
        
        let strings = try await loadStrings
        if let signature = try await loadSignature {
            for value in strings ?? [] {
                await appending(signature, to: value)
            }
        } else {
            throw Chapter1.GeneralError.loadSignatureError
        }
    }
}
