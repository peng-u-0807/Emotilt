//
//  HomeView.swift
//  Emotilt
//
//  Created by 최유림 on 2023/02/27.
//

import SwiftUI
import Combine

struct HomeView: View {
    
    @ObservedObject var viewModel: HomeViewModel
    
    @State private var isEmojiSheetOpen: Bool = false
    @State private var emoji: String = ""
    @State private var content: String = ""
    @FocusState private var isTextFieldFocused: Bool
    
    var body: some View {
        VStack(alignment: .center) {
            Spacer()
            
            ZStack {
                Button {
                    isEmojiSheetOpen = true
                } label: {
                    ZStack {
                        if emoji.isEmpty {
                            RoundedRectangle(cornerRadius: 32)
                                .fill(.tertiary.opacity(0.4))
                                .frame(width: 168, height: 168)
                        }
                        
                        Text(emoji)
                            .font(.system(size: 168))
                    }
                }
                
                ZStack {
//                    DirectionIndicatorView()
                }
            }.frame(width: 280, height: 280)
            
            Group {
                TextField("", text: $content, axis: .vertical)
                    .placeholder(when: content.isEmpty && !isTextFieldFocused) {
                            Text("20자 이내")
                                .foregroundColor(.gray)
                                .opacity(0.8)
                    }
                    .focused($isTextFieldFocused)
                    .font(.system(size: 24, weight: .bold))
                    .lineLimit(2)
                    .frame(height: 64)
                    .multilineTextAlignment(.center)
                    .onReceive(Just(content)) { _ in
                        if content.count > 20 {
                            content = String(content.prefix(20))
                        }
                    }
                    .submitLabel(.done)
                    .onChange(of: content) { text in
                        if text.last == "\n" {
                            content = String(text.dropLast())
                            UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to:nil, from:nil, for:nil)
                        }
                    }
                    
            }
            
            Spacer()
            Spacer()
            
            RoundedButton(label: "Send") {
                viewModel.sendMessage(.init(emoji: "🤔", content: "Nyam"))
            }
            
        }
        .padding(.horizontal, 36)
        .padding(.vertical, 24)
        .onTapGesture(perform: {
            UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to:nil, from:nil, for:nil)
        })
        .sheet(isPresented: $isEmojiSheetOpen) {
            EmojiSheetView(selected: $emoji)
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView(viewModel: .init(peerSessionManager: .debug))
    }
}
