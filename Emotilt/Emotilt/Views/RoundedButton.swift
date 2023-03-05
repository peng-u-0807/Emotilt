//
//  RoundedButton.swift
//  Emotilt
//
//  Created by 최유림 on 2023/03/03.
//

import SwiftUI

struct RoundedButton: View {
    let label: String
    let action: () -> Void
    
    var body: some View {
        Button {
            action()
        } label: {
            Text(label)
                .foregroundColor(.white)
                .font(.system(size: 17, weight: .semibold))
                .padding(.vertical, 16)
                .frame(maxWidth: .infinity)
        }
        .tint(.black)
        .buttonStyle(.borderedProminent)
        .cornerRadius(48)
    }
}

struct RoundedButton_Previews: PreviewProvider {
    static var previews: some View {
        RoundedButton(label: "Close") {}
    }
}
