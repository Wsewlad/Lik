//
//  ReceiptView.swift
//  ReceiptScanner
//
//  Created by  Vladyslav Fil on 22.01.2023.
//

import SwiftUI

struct ReceiptRowView: View {
    let receipt: Receipt
    let isLast: Bool
    var onDetailsButtonTapped: () -> Void
    
    var body: some View {
        Section(content: {
            Text(receipt.shop)
            
            ForEach(receipt.products, id: \.id) { product in
                HStack(alignment: .top) {
                    Label(title: {
                        Text(product.name)
                    }, icon: {
                        Image(systemName: "carrot.fill")
                            .foregroundColor(.orange)
                    })

                    Spacer()
                    Text(product.amount.formatted(points: 2))
                        
                    Text(product.amountType.label)
                }
            }
        }, header: {
            Text(receipt.date.formatted(date: .long, time: .omitted) )
        }, footer: {
            Button {
                self.onDetailsButtonTapped()
            } label: {
                Label("Details", systemImage: "basket.fill")
            }
            .padding(.bottom, isLast ? 100 : 0)
        })
    }
}

#Preview {
    List {
        ReceiptRowView(
            receipt: .fake,
            isLast: false,
            onDetailsButtonTapped: {}
        )
    }
    .listStyle(.insetGrouped)
}
