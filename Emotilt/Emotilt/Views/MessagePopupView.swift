//
//  MessagePopupView.swift
//  Emotilt
//
//  Created by 최유림 on 2023/03/03.
//

import SwiftUI

struct MessagePopupView: View {
    let messageMetaData: MessageMetaData
    let leftCount: Int
    
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        VStack {
            Spacer().frame(height: 32)
            
            Text("\(leftCount) messages left")
            
            Group {
                Text("From")
                    .font(.system(size: 24, weight: .semibold))
                
                Spacer().frame(height: 8)
                
                Text(messageMetaData.sender)
            }
            
            Spacer()
            
            Text(messageMetaData.message.emoji)
                .font(.system(size: 168))
            
            Spacer().frame(height: 24)
            
            if let content = messageMetaData.message.content {
                Text(content)
                    .font(.system(size: 36, weight: .bold))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 36)
            }
            
            Spacer()
            
            RoundedButton(label: "Close") {
                dismiss()
            }
            .padding(.horizontal, 60)
            
            Spacer().frame(height: 24)
        }
    }
}

struct MessagePopupView_Previews: PreviewProvider {
    static var previews: some View {
        MessagePopupView(messageMetaData: .init(sender: "와플's iPhone", message: .init(emoji: "🤔", content: "waffle!")), leftCount: 3)
    }
}
