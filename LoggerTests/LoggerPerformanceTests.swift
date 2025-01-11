//
//  LoggerPerformanceTests.swift
//  LoggerTests
//
//  Created by 遠藤拓弥 on 2025/01/11.
//

import Foundation
import XCTest
import OSLog

final class LoggerPerformanceTests: XCTestCase {
    // テスト用のLogger
    let logger = Logger(subsystem: Bundle.main.bundleIdentifier ?? "", category: "PerformanceTest")

    // テストデータの準備
    let testStrings = [
        "短いメッセージ",
        "これは少し長めのメッセージです。パフォーマンスの違いを確認します。",
        String(repeating: "これは非常に長いメッセージです。", count: 100)
    ]

    // ログ出力回数
    let iterationCount = 1000

    func testPrintPerformance() {
        measure {
            for i in 0..<iterationCount {
                for testString in testStrings {
                    print("[\(i)] Print test: \(testString)")
                }
            }
        }
    }

    func testLoggerPerformance() {
        measure {
            for i in 0..<iterationCount {
                for testString in testStrings {
                    logger.info("[\(i)] Logger test: \(testString)")
                }
            }
        }
    }

    // 並列処理での比較テスト
    func testParallelPrintPerformance() {
        measure {
            DispatchQueue.concurrentPerform(iterations: iterationCount) { i in
                for testString in testStrings {
                    print("[\(i)] Parallel print test: \(testString)")
                }
            }
        }
    }

    func testParallelLoggerPerformance() {
        measure {
            DispatchQueue.concurrentPerform(iterations: iterationCount) { i in
                for testString in testStrings {
                    logger.info("[\(i)] Parallel logger test: \(testString)")
                }
            }
        }
    }

    // メモリ使用量の比較テスト
    func testMemoryUsagePrint() {
        var memoryBefore: Int = 0
        var memoryAfter: Int = 0

        // メモリ使用量を取得する関数
        func getMemoryUsage() -> Int {
            var info = mach_task_basic_info()
            var count = mach_msg_type_number_t(MemoryLayout<mach_task_basic_info>.size)/4

            let kerr: kern_return_t = withUnsafeMutablePointer(to: &info) {
                $0.withMemoryRebound(to: integer_t.self, capacity: 1) {
                    task_info(mach_task_self_,
                            task_flavor_t(MACH_TASK_BASIC_INFO),
                            $0,
                            &count)
                }
            }

            return kerr == KERN_SUCCESS ? Int(info.resident_size) : 0
        }

        memoryBefore = getMemoryUsage()

        for i in 0..<iterationCount {
            for testString in testStrings {
                print("[\(i)] Memory print test: \(testString)")
            }
        }

        memoryAfter = getMemoryUsage()

        XCTAssertNotEqual(memoryBefore, 0, "メモリ使用量の取得に失敗しました")
        print("Print memory usage: \((memoryAfter - memoryBefore) / 1024) KB")
    }

    func testMemoryUsageLogger() {
        var memoryBefore: Int = 0
        var memoryAfter: Int = 0

        func getMemoryUsage() -> Int {
            var info = mach_task_basic_info()
            var count = mach_msg_type_number_t(MemoryLayout<mach_task_basic_info>.size)/4

            let kerr: kern_return_t = withUnsafeMutablePointer(to: &info) {
                $0.withMemoryRebound(to: integer_t.self, capacity: 1) {
                    task_info(mach_task_self_,
                            task_flavor_t(MACH_TASK_BASIC_INFO),
                            $0,
                            &count)
                }
            }

            return kerr == KERN_SUCCESS ? Int(info.resident_size) : 0
        }

        memoryBefore = getMemoryUsage()

        for i in 0..<iterationCount {
            for testString in testStrings {
                logger.info("[\(i)] Memory logger test: \(testString)")
            }
        }

        memoryAfter = getMemoryUsage()

        XCTAssertNotEqual(memoryBefore, 0, "メモリ使用量の取得に失敗しました")
        print("Logger memory usage: \((memoryAfter - memoryBefore) / 1024) KB")
    }
}
