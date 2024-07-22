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
    
    @FocusState private var isFocused: Bool
    
    var body: some View {
        VStack {
            if viewModel.isConnected {
                HStack(spacing: 4) {
                    Image(systemName: "checkmark.circle.fill")
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
                    RoundedRectangle(cornerRadius: 84)
                        .fill(.tertiary.opacity(0.2))
                        .frame(width: 168, height: 168)
                        .overlay(
                            Image(systemName: "plus")
                                .font(.system(size: 24))
                        )
                } else {
                    Text(emoji)
                        .font(.system(size: 168))
                }
            }
            
            Spacer().frame(height: 24)
            
            VStack(spacing: 24) {
                TextField("", text: $content, prompt: Text("30자 이내"), axis: .vertical)
                    .lineLimit(2)
                    .font(.system(size: 24, weight: .bold))
                    .multilineTextAlignment(.center)
                    .onChange(of: content) { text in
                        self.content = String(text.prefix(30))
                    }
                    .autocorrectionDisabled()
                    .focused($isFocused)
                
                if isButtonActivated {
                    Button {
                        emoji = ""
                        content = ""
                    } label: {
                        HStack(spacing: 4) {
                            Image(systemName: "arrow.clockwise")
                                .tint(.black)
                            Text("입력 내용 초기화")
                        }
                        .font(.system(size: 15))
                    }
                }
            }
            
            Spacer()
            
            RoundedButton(isActivated: $isButtonActivated, label: "Send") {
                viewModel.sendMessage(.init(emoji: emoji, content: content))
            }
        }
        .padding(.horizontal, 36)
        .padding(.top, 32)
        .padding(.bottom, 24)
        .onChange(of: [content.isEmpty, emoji.isEmpty]) { empty in
            isButtonActivated = !empty[0] && !empty[1]
        }
        .background()
        .containerShape(Rectangle())
        .onTapGesture {
            isFocused = false
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
