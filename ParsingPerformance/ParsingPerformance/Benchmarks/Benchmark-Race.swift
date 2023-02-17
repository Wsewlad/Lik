//
//  Benchmark-Race.swift
//  ParsingPerformance
//
//  Created by  Vladyslav Fil on 09.02.2023.
//

import Foundation
import Benchmark

let raceSuite = BenchmarkSuite(name: "Race") { suite in
    suite.benchmark("Substring") {
        var input = upcomingRaces[...]
        precondition(races.run(&input)?.count == 3)
    }
    
    suite.benchmark("UTF8") {
        var input = upcomingRaces[...].utf8
        precondition(racesUTF8.run(&input)?.count == 3)
    }
}
