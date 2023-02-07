//
//  RParser.swift
//  Lik
//
//  Created by  Vladyslav Fil on 08.02.2023.
//

import Foundation

let address = Parser<Substring, Substring>.prefix(upTo: "ПН")
let pn = Parser
    .skip("ПН")
    .skip(zeroOrMOreSpaces)
    .take(.uint64)
let chequeNumber = Parser.int
    .skip("/")
    .take(.int)
    .skip("/")
    .take(.int)
let price = Parser.double
    .skip(zeroOrMOreSpaces)
    .skip(.oneOf("Б", "A"))
    .skip(Parser.prefix("\n").zeroOrMore())
let anount = Parser.double
    .skip(zeroOrMOreSpaces)
    .skip(.oneOf("x", "X", "х", "Х"))
    .skip(zeroOrMOreSpaces)
    .take(.double)
let sum = Parser
    .skip("СУМА")
    .skip(zeroOrMOreSpaces)
    .take(.double)
    .skip(zeroOrMOreSpaces)
    .skip("ГРН")

let product1 = Parser.prefix(upToParser: anount)
    .flatMap { $0.split(separator: " ").count > 1 ? .never : .always($0) }
    .take(anount)
    .skip(zeroOrMOreSpaces)
    .take(price)
    .map { (name, arg1, cost) in
        let (quantity, price) = arg1
        let formattedName = name.trimmingCharacters(in: .whitespacesAndNewlines)
        return Product(id: .init(value: formattedName), name: formattedName, quantity: quantity, price: price, cost: cost)
    }


let product2 = Parser.prefix(upToParser: price)
    .flatMap { $0.split(separator: " ").count > 3 ? .never : .always($0) }
    .take(price)
    .map { name, cost in
        let formattedName = name.trimmingCharacters(in: .whitespacesAndNewlines)
        return Product(id: .init(value: formattedName), name: formattedName, price: cost, cost: cost)
    }

let product3 = price
    .take(.prefix(upTo: " "))
    .map { cost, name in
        let formattedName = name.trimmingCharacters(in: .whitespacesAndNewlines)
        return Product(id: .init(value: formattedName), name: formattedName, price: cost, cost: cost)
    }

let products = Parser.oneOf([product2, product3, product1]).zeroOrMore()

let receiptParser = Parser.skip(address)
    .skip(pn)
    .skip(.prefix(upToParser: chequeNumber))
    .take(chequeNumber)
    .take(products)
    .skip(.optional(.prefix(upTo: "СУМА")))
    .take(.optional(sum))
    .take(.rest)
    .map { chequeNumber, products, sum, rest in
        Receipt(
            id: .init(value: "\(chequeNumber.0)/\(chequeNumber.1)/\(chequeNumber.2)"),
            //shop: .init(id: .init(value: shop), name: shop, address: shop),
            date: Date(),
            products: products,
            sum: sum ?? 0,
            text: rest.trimmingCharacters(in: .whitespacesAndNewlines)
        )
    }
