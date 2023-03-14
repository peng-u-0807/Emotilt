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
    @FocusState private var isTextFieldFocused: Bool
    
    var body: some View {
        VStack(alignment: .center) {
            Spacer()
            
            //MARK: - viewState label
            switch (viewModel.currentState){
            case .sendingTimer:
                Text("\(viewModel.counter)")
                    .font(.system(size: 40, weight: .bold))
            case .sendingSuccess:
                Text("메세지 전송 성공!")
                    .font(.system(size: 20, weight: .bold))
            case .sendingFailure:
                Text("메세지 전송 실패 ㅠ")
                    .font(.system(size: 20, weight: .bold))
            case .motionDetectFailure:
                Text("메시지를 보내려면 흔들어주세요!")
                    .font(.system(size: 20, weight: .bold))
            case .none:
                Text("")
            }
            
            ZStack {
                Button {
                    isEmojiSheetOpen = true
                } label: {
                    ZStack {
                            if viewModel.emoji.isEmpty {
                                RoundedRectangle(cornerRadius: 32)
                                    .fill(.tertiary.opacity(0.4))
                                    .frame(width: 168, height: 168)
                            }
                            
                            Text(viewModel.emoji)
                                .font(.system(size: 168))
                        }
                    }
                    
                    
                    ZStack {
                        //DirectionIndicatorView()
                    }
                }.frame(width: 280, height: 280)
                
                Group {
                    if #available(iOS 16.0, *) {
                        TextField("", text: $viewModel
                            .content, axis: .vertical)
                        .placeholder(when: viewModel.content.isEmpty && !isTextFieldFocused) {
                            Text("20자 이내")
                                .foregroundColor(.gray)
                                .opacity(0.8)
                        }
                        .focused($isTextFieldFocused)
                        .font(.system(size: 24, weight: .bold))
                        .lineLimit(2)
                        .frame(height: 64)
                        .multilineTextAlignment(.center)
                        .onReceive(Just($viewModel.content)) { _ in
                            if viewModel.content.count > 20 {
                                viewModel.content = String(viewModel.content.prefix(20))
                            }
                        }
                        .submitLabel(.done)
                        .onChange(of: viewModel.content) { text in
                            if text.last == "\n" {
                                viewModel.content = String(text.dropLast())
                                UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to:nil, from:nil, for:nil)
                            }
                        }
                    } else {
                        // Fallback on earlier versions
                    }
                    
                }
                
                Spacer()
                Spacer()
                
                RoundedButton(label: "Send") {
                    //viewModel.detectAcceleration()
                    viewModel.sendMessage()
                }
            }
                .padding(.horizontal, 36)
                .padding(.vertical, 24)
                .onTapGesture(perform: {
                    UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to:nil, from:nil, for:nil)
                })
                .sheet(isPresented: $isEmojiSheetOpen) {
                    EmojiSheetView(selected: $viewModel.emoji)
                }
        }
    }
    
    
struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView(viewModel: .init(peerSessionManager: .debug))
    }
}

