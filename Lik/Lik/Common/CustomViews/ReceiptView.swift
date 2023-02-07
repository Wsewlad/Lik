//
//  ReceiptView.swift
//  ReceiptScanner
//
//  Created by  Vladyslav Fil on 22.01.2023.
//

import SwiftUI

struct ReceiptView: View {
    let receipt: Receipt
    
    var body: some View {
        VStack(spacing: 8) {
            Text(receipt.id.value)
                .font(.title2())
                .foregroundColor(.primaryText)
            
            Divider()
            
            ForEach(receipt.products, id: \.id) { product in
                HStack(alignment: .top) {
                    VStack(alignment: .leading) {
                        Text(product.name)
                            .font(.body())
                        
                        if let quantity = product.quantity {
                            Text("\(quantity.formatted(points: 3)) X \(product.price.formatted(points: 2))")
                                .font(.subheadline())
                        }
                    }
                    Spacer()
                    Text(product.cost.formatted(points: 2))
                        .font(.callout())
                }
            }
            
            Divider()
            
            HStack {
                Text("Сума")
                Spacer()
                Text(receipt.sum.formatted(points: 2))
            }
            .font(.body())
            
            Divider()
            
            Text(receipt.text)
                .font(.body())
        }
        .padding(16)
        .foregroundColor(.secondaryText)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.secondaryBackground)
        )
    }
}

struct ReceiptView_Previews: PreviewProvider {
    static var previews: some View {
        ReceiptView(
            receipt: .init(
                id: .init(value: "test"),
                date: Date(),
                products: [
                    .init(id: .init(value: "1"), name: "Хл300КиївхлСімейнНар", price: 18.99, cost: 18.99),
                    .init(id: .init(value: "2"), name: "Рул300КиївхлМакВ/гВу", quantity: 0.300, price: 100, cost: 30),
                    .init(id: .init(value: "3"), name: "КартопляКгБіла", quantity: 1.000, price: 8.99, cost: 8.99)
                ],
                sum: 150,
                text: "Хл300КиївхлСімейнНар  18.99\nРул300КиївхлМакВ/гВу  0.300 x 100  30"
            )
        )
        .padding()
        .preferredColorScheme(.dark)
    }
}
