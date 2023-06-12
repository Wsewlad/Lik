//
//  ReceiptDetailsView.swift
//  Lik
//
//  Created by  Vladyslav Fil on 26.05.2023.
//

import SwiftUI

struct ReceiptDetailsView: View {
    @Environment(\.dismiss) var dismiss
//    @Environment(\.editMode) private var editMode
    
    @Binding var receipt: Receipt
    
    var body: some View {
        Form {
            Section {
                DatePicker("Date", selection: $receipt.date, displayedComponents: .date)
            } header: {
                Text("Info")
            }
            
            Section {
                ForEach(receipt.products, id: \.id) { product in
                    HStack(alignment: .top) {
                        Label {
                            Text(product.name)
                        } icon: {
                            Image(systemName: "carrot.fill")
                                .foregroundColor(.orange)
                        }

                        Spacer()
                        Text("\(product.amount.formatted(points: 2))")
                            
                        Text("шт")
                    }
                }
            } header: {
                Text("Items")
            }
            
            Section {
                FullTextView(text: $receipt.text)
            } header: {
                Text("Full text")
            }
        }
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                Button("Dismiss") {
                    dismiss()
                }
            }
            
            ToolbarItem(placement: .primaryAction) {
                EditButton()
            }
        }
    }
}

//MARK: - FullText
struct FullTextView: View {
    @Environment(\.editMode) private var editMode
    
    @Binding var text: String
    
    var body: some View {
        VStack {
            if editMode?.wrappedValue.isEditing == true {
                TextEditor(text: $text)
            } else {
                Text(text)
            }
        }
        .animation(nil, value: editMode?.wrappedValue)
    }
}

struct ReceiptDetailsView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            ReceiptDetailsView(
                receipt: .constant(.fake)
            )
        }
    }
}
