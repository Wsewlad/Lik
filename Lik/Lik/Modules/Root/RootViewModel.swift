//
//  RootViewModel.swift
//  Lik
//
//  Created by  Vladyslav Fil on 19.05.2023.
//

import Foundation

class RootViewModel: ObservableObject {
    @Published private(set) var receipts: [Receipt] = []
    
    func addNewReceipt(_ newReceipt: Receipt) {
        receipts.append(newReceipt)
    }
}
