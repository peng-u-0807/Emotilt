//
//  HomeView.swift
//  Emotilt
//
//  Created by 최유림 on 2023/02/27.
//

import SwiftUI

struct HomeView: View {
    
    @ObservedObject var viewModel: HomeViewModel
    
    @State private var isEmojiSheetOpen: Bool = false
    @State private var emoji: String = ""
    @State private var content: String = ""
    
    var body: some View {
        VStack(alignment: .center) {
            Spacer().frame(height: 24)
            
            if let message = viewModel.receivedMessage {
                Text(message.emoji)
                    .font(.system(size: 42))
                
                Spacer().frame(height: 16)
                
                Text(message.content ?? "")
                    .font(.system(size: 36))
            }
            
            Spacer()
            
            RoundedButton(label: "Send") {
                viewModel.sendMessage(.init(emoji: "🤔", content: "Nyam"))
            }
            
            Spacer().frame(height: 16)
        }
        .padding(.horizontal, 36)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView(viewModel: .init(peerSessionManager: .debug))
    }
}
