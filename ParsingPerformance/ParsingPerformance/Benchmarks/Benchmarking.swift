//
//  Benchmarking.swift
//  ParsingPerformance
//
//  Created by  Vladyslav Fil on 06.02.2023.
//

import Foundation
import Benchmark

struct Benchmarking: AnyBenchmark {
    var name: String
    private var run_: (_ state: inout BenchmarkState) throws -> Void
    private var setUp_: () -> Void

    init(
        name: String,
        setUp: @escaping () -> Void = {},
        run: @escaping (_ state: inout BenchmarkState) throws -> Void
    ) {
        self.name = name
        self.setUp_ = setUp
        self.run_ = run
    }

    func setUp() {
        self.setUp_()
    }

    func run(_ state: inout BenchmarkState) throws {
        try self.run_(&state)
    }

    // No-op
    var settings: [BenchmarkSetting] { [] }
    func tearDown() {}
}
