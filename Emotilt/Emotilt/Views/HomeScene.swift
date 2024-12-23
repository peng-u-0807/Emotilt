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
    @State private var showFindNewPeerAlert: Bool = false
    
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
            
            VStack(spacing: 24) {
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
                    }
                }
            }
            
            Spacer()
            
            VStack(spacing: 8) {
                RoundedButton(isActivated: $isButtonActivated, 
                              label: "전송",
                              textColor: .white, tintColor: .black) {
                    viewModel.sendMessage(.init(emoji: emoji, content: content))
                }
                
                RoundedButton(isActivated: .constant(true),
                              label: "다른 상대 찾기",
                              textColor: .gray, tintColor: .clear) {
                    showFindNewPeerAlert = true
                }
            }
        }
        .padding(.horizontal, 36)
        .padding(.top, 32)
        .padding(.bottom, 16)
        .onChange(of: [content.isEmpty, emoji.isEmpty, viewModel.isConnected]) { condition in
            isButtonActivated = !condition[0] && !condition[1] && condition[2]
        }
        .alert("다른 상대 찾기", isPresented: $showFindNewPeerAlert) {
            Button("취소", role: .cancel) {}
            Button("찾기") {
                viewModel.findNewPeer()
            }
        } message: {
            Text("새로운 상대를 찾아볼까요? 현재 상대를 다시 만날 수도 있습니다.")
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
