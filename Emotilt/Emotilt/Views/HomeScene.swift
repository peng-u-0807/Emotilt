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
    @State private var emoji: String = ""
    @State private var content: String = ""
    
    var body: some View {
        VStack(alignment: .center) {
            Spacer()
            
            if emoji.isEmpty {
                Button {
                    isEmojiSheetOpen = true
                } label: {
                    RoundedRectangle(cornerRadius: 32)
                        .fill(.tertiary.opacity(0.4))
                        .frame(width: 168, height: 168)
                }
            } else {
                Text(emoji)
                    .font(.system(size: 168))
            }
            
            Spacer().frame(height: 24)
            
            TextField("", text: $content, prompt: Text("20자 이내"))
                .font(.system(size: 24, weight: .bold))
                .lineLimit(2)
                .multilineTextAlignment(.center)
            
            Spacer()
            
            RoundedButton(label: "Send") {
                viewModel.sendMessage(.init(emoji: "🤔", content: "Nyam \(Int.random(in: 0...20))"))
            }
            
            Spacer().frame(height: 16)
        }
        .padding(.horizontal, 36)
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

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        HomeScene(viewModel: .init(peerSessionManager: .debug))
    }
}
