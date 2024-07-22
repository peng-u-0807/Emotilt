//
//  HomeScene.swift
//  Emotilt
//
//  Created by 최유림 on 2023/02/27.
//

import SwiftUI

struct HomeScene: View {
    
    @ObservedObject var viewModel: HomeViewModel
    
    @State private var isEmojiSheetOpen: Bool = false
    @State private var isButtonActivated: Bool = false
    
    @State private var emoji: String = ""
    @State private var content: String = ""
    
    var body: some View {
        VStack(alignment: .center) {
            if viewModel.isConnected {
                HStack(spacing: 4) {
                    Image(systemName: "checkmark.circle.fill")
                        .tint(.black)
                    Text("상대방을 찾았습니다!")
                }
                .font(.system(size: 15, weight: .medium))
            } else {
                Text("상대방을 찾고 있습니다...")
                    .font(.system(size: 15))
            }
            
            Spacer()
            
            Button {
                isEmojiSheetOpen = true
            } label: {
                if emoji.isEmpty {
                    RoundedRectangle(cornerRadius: 32)
                        .fill(.tertiary.opacity(0.4))
                        .frame(width: 168, height: 168)
                        .overlay(
                            VStack(spacing: 16) {
                                Image(systemName: "plus")
                                Text("Add emoji")
                            }
                        )
                } else {
                    Text(emoji)
                        .font(.system(size: 168))
                }
            }
            
            Spacer().frame(height: 24)
            
            TextField("", text: $content, prompt: Text("20자 이내"))
                .font(.system(size: 24, weight: .bold))
                .lineLimit(2)
                .frame(maxWidth: .infinity)
                .multilineTextAlignment(.center)
            
            Spacer()
            
            RoundedButton(isActivated: $isButtonActivated, label: "Send") {
                viewModel.sendMessage(.init(emoji: emoji, content: content))
            }
            
            Spacer().frame(height: 16)
        }
        .padding(.horizontal, 36)
        .padding(.top, 32)
        .padding(.bottom, 8)
        .onChange(of: [content.isEmpty, emoji.isEmpty]) { empty in
            isButtonActivated = !empty[0] && !empty[1]
        }
        .sheet(isPresented: $isEmojiSheetOpen) {
            EmojiSheet(selected: $emoji)
        }
        .sheet(isPresented: $viewModel.didReceiveMessage) {
            if let messageMetaData = viewModel.receivedMessageList.first {
                MessagePopupView(messageMetaData: messageMetaData, leftCount: $viewModel.receivedMessageList.count)
            }
        }
    }
}
