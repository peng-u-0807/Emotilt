//
//  MessagePopupView.swift
//  Emotilt
//
//  Created by 최유림 on 2023/03/03.
//

import SwiftUI

struct MessagePopupView: View {
    let message: Message
    @Binding var isPopupViewPresented: Bool
    
    var body: some View {
        VStack {
            Spacer()
            
            Text(message.emoji)
                .font(.system(size: 168))
            
            Spacer().frame(height: 24)
            
            if let content = message.content {
                Text(content)
                    .font(.system(size: 36, weight: .bold))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 36)
            }
            
            Spacer()
            
            RoundedButton(label: "Close") {
                isPopupViewPresented = false
            }
            .padding(.horizontal, 60)
            
            Spacer().frame(height: 16)
        }
    }
}

struct MessagePopupView_Previews: PreviewProvider {
    static var previews: some View {
        MessagePopupView(message: .init(emoji: "🤔", content: "waffle!"), isPopupViewPresented: .constant(true))
    }
}
