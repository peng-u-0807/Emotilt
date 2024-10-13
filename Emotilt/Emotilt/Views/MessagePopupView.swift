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
            HStack(spacing: 4) {
                Image(systemName: "paperplane.fill")
                    .font(.system(size: 13))
                
                if leftCount == 1 {
                    Text("1 new message")
                } else if leftCount > 1 {
                    Text("\(leftCount) new messages")
                }
            }
            
            Spacer()
            
            VStack(spacing: 24) {
                VStack(spacing: 4) {
                    Text("from")
                        .font(.system(size: 16, weight: .medium))
                    Text(messageMetaData.sender + " :")
                        .font(.system(size: 16, weight: .bold))
                }
                
                Text(messageMetaData.message.emoji)
                    .font(.system(size: 168))
                
                Text(messageMetaData.message.content)
                    .font(.system(size: 24, weight: .bold))
                    .multilineTextAlignment(.center)
            }
            
            Spacer()
            
            RoundedButton(isActivated: .constant(true), label: "닫기", textColor: .white, tintColor: .black) {
                dismiss()
            }.padding(.horizontal, 36)
            
            Spacer().frame(height: 24)
        }
        .padding(.top, 32)
    }
}

struct MessagePopupView_Previews: PreviewProvider {
    static var previews: some View {
        MessagePopupView(messageMetaData: .init(sender: "와플's iPhone", message: .init(emoji: "🤔", content: "waffle!")), leftCount: 3)
    }
}
