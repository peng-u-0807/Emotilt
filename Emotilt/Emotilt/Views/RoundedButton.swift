//
//  RoundedButton.swift
//  Emotilt
//
//  Created by 최유림 on 2023/03/03.
//

import SwiftUI

struct RoundedButton: View {
    @Binding var isActivated: Bool
    let label: String
    let textColor: Color
    let tintColor: Color
    let action: () -> Void
    
    var body: some View {
        Button {
            action()
        } label: {
            Text(label)
                .foregroundColor(textColor)
                .font(.system(size: 17, weight: .semibold))
                .padding(.vertical, 16)
                .frame(maxWidth: .infinity)
        }
        .tint(tintColor)
        .buttonStyle(.borderedProminent)
        .cornerRadius(48)
        .disabled(!isActivated)
    }
}
