//
//  Benchmark-IntParsing.swift
//  ParsingPerformance
//
//  Created by  Vladyslav Fil on 06.02.2023.
//

import Foundation
import Benchmark

let intParsingBenchmarkSuite = BenchmarkSuite(name: "IntParsing") { suite in
    let string = "1234567890"
    
    suite.benchmark("Int.init") {
       precondition(Int(string) == 1234567890)
    }

    suite.benchmark("Parser.int") {
        var string = string[...]
        precondition(Parser.int.run(&string) == 1234567890)
    }
    
    suite.benchmark("UnicodeScalar") {
        var string = string[...].unicodeScalars
        precondition(Parser.int.run(&string) == 1234567890)
    }
    
    suite.benchmark("UTF8") {
        var string = string[...].utf8
        precondition(Parser.int.run(&string) == 1234567890)
    }
    
    var scanner: Scanner!
    suite.register(
        benchmark: Benchmarking(
            name: "Scanner",
            setUp: { scanner = Scanner(string: string) },
            run: { _ in precondition(scanner.scanInt() == 1234567890) }
        )
    )
}
