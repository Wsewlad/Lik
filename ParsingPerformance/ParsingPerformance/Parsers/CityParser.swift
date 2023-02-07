//
//  CityParser.swift
//  ParsingPerformance
//
//  Created by  Vladyslav Fil on 06.02.2023.
//

import Foundation

let cityEnum = """
{
  "Kyiv": "м. Київ",
  "Odesa": "м. Одеса"
}
"""

let cityParser: Parser<Substring, String> = .oneOf(
    try! JSONDecoder().decode([String: String].self, from: cityEnum.data(using: .utf8)!).map { key, value in
            Parser.prefix(value[...]).map { key }
    }
)

//cityParser.run("м. Київ, вулиця Дорогожицька, будинок 2")
