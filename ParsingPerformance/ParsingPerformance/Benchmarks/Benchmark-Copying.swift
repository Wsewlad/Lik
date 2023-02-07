//
//  Benchmark-Copying.swift
//  ParsingPerformance
//
//  Created by  Vladyslav Fil on 06.02.2023.
//

import Foundation
import Benchmark

let copyingBenchmarkSuite = BenchmarkSuite(name: "Copying") { suite in
    let string = String.init(repeating: "👨‍👩‍👧‍👦", count: 1_000_000)
    
    suite.benchmark("String") {
        var copy = string
        copy.removeFirst()
    }
    
    suite.benchmark("Substring") {
        var copy = string[...]
        copy.removeFirst()
    }
    
    suite.benchmark("UnicodeScalars") {
        var copy = string[...].unicodeScalars
        copy.removeFirst()
    }
    
    suite.benchmark("UTF8") {
        var copy = string[...].utf8
        copy.removeFirst()
    }
}
