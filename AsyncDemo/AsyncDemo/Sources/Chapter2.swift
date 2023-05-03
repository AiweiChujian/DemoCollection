//
//  Chapter2.swift
//  AsyncDemo
//
//  Created by Aiwei on 2023/5/3.
//

import Foundation

/// Chapter 2 - 创建异步函数
class Chapter2: Testable {
    static func testCase() {
        Task.init {
            let instance = Chapter2()
            do {
//                let results = try await instance.loadChecked()
                let results = try await instance.load()
                print("Async func done: \(results)")
            } catch {
                print(error)
            }
        }
        Task.init {
            let worker = Worker()
            do {
                let results = try await worker.doWork()
                print("Worker done: \(results)")
            } catch {
                print(error)
            }
        }
    }
}

// MARK: - 修改函数签名 & 函数带有返回值
extension Chapter2 {
    func someAsyncMethod() async {
        try? await Task.sleep(nanoseconds: NSEC_PER_SEC * 1)
    }
    
    func someAsyncMethod(_ completion: @escaping () -> Void) {
        DispatchQueue.global().async {
            sleep(1)
            completion()
        }
    }
    
    func syncFunc(completion: @escaping (Int) -> Void) -> Bool {
        someAsyncMethod {
            completion(1)
        }
        return true
    }
    
    func asyncFunc(started: inout Bool) async -> Int {
        started = true
        await someAsyncMethod()
        return 1
    }
}

// MARK: - 使用续体改写函数
extension Chapter2 {
    func load(completion: @escaping ([String]?, Error?) -> Void) {
        DispatchQueue.global().async {
            sleep(3)
            completion(["string1", "string2"], nil)
        }
    }
    
    func load() async throws -> [String] {
        try await withUnsafeThrowingContinuation { continuation in
            load { values, error in
                if let error = error {
                    continuation.resume(throwing: error)
                } else if let values = values {
                    continuation.resume(returning: values)
                } else {
                    assertionFailure("Both parameters are nil")
                }
            }
        }
    }
    
    func loadChecked() async throws -> [String] {
        try await withCheckedThrowingContinuation { continuation in
            load { values, error in
                if let values = values {
                    continuation.resume(returning: values)
                    continuation.resume(returning: values)
                }
            }
        }
    }
}

// MARK: - 续体暂存
protocol WorkDelegate {
    func workDidDone(values: [String])
    func workDidFailed(error: Error)
}


extension Chapter2 {
    class Worker {
        var continuation: CheckedContinuation<[String], Error>?
    }
}

extension Chapter2.Worker {
    func doWork() async throws -> [String] {
        try await withCheckedThrowingContinuation { continuation in
            self.continuation = continuation
            performWork(delegate: self)
        }
    }
    
    func performWork(delegate: WorkDelegate) {
        DispatchQueue.global().async {
            sleep(3)
            delegate.workDidDone(values: ["value1", "value2"])
        }
    }
}

extension Chapter2.Worker: WorkDelegate {
    func workDidDone(values: [String]) {
        continuation?.resume(returning: values)
        continuation = nil
    }
    
    func workDidFailed(error: Error) {
        continuation?.resume(throwing: error)
        continuation = nil
    }
}
