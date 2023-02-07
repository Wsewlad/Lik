//
//  AddButton.swift
//  Lik
//
//  Created by  Vladyslav Fil on 07.02.2023.
//

import SwiftUI

struct PlusView: View {
    var body: some View {
        ZStack {
            Circle()
                .fill(Color.secondaryBackground)
                .frame(width: 50)
                .shadow(color: .primaryText.opacity(0.5), radius: 2)
            
            Image(systemName: "plus")
                .font(.system(size: 25))
                .foregroundColor(.primaryText)
        }
    }
}

struct PlusView_Previews: PreviewProvider {
    static var previews: some View {
        PlusView()
            .padding()
            .preferredColorScheme(.dark)
        
        PlusView()
            .padding()
            .preferredColorScheme(.light)
    }
}
