//
//  HomeView.swift
//  Emotilt
//
//  Created by 최유림 on 2023/02/27.
//

import SwiftUI
import Combine
import CoreMotion

struct HomeView: View {
    
    @ObservedObject var viewModel: HomeViewModel
    @State private var isEmojiSheetOpen: Bool = false
    @FocusState private var isTextFieldFocused: Bool
    
    //MARK: - 메세지 전송 관련 값
    let motionManager = CMMotionManager()
    @State private var sendTimer: Timer?
    @State private var currentState: viewState = .none
    @State private var isSending = false
    @State private var isAccelerating = false
    @State private var accelerationRate = 0.0
    @State private var counter = 0
    @State private var isReadyForSending = false
    @State var isDetected = false
    
    @State var emoji : String = ""
    @State var content : String = ""
    
    var body: some View {
        VStack(alignment: .center) {
            Spacer()
            
            //MARK: - viewState label
            switch currentState {
            case .sendingTimer:
                Text("\(counter)")
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
                EmptyView()
            }
            
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
                    //DirectionIndicatorView()
                }
            }.frame(width: 280, height: 280)
            
            Group {
                
                if #available(iOS 16.0, *) {
                    TextField("", text: $content, axis: .vertical)
                        .placeholder(when: content.isEmpty && !isTextFieldFocused){
                            Text("20자 이내")
                                .foregroundColor(.gray)
                                .opacity(0.8)
                        }
                        .focused($isTextFieldFocused)
                        .font(.system(size: 24, weight: .bold))
                        .lineLimit(2)
                        .frame(height: 64)
                        .multilineTextAlignment(.center)
                        .onReceive(Just($content)) { _ in
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
                } else {
                    // Fallback on earlier versions
                }
            }
            
            Spacer()
            Spacer()
            
            RoundedButton(label: "Send") {
                detectAcceleration()
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

//MARK: - message sending 
extension HomeView {
    func detectAcceleration() {
        isDetected = false
        isSending = true
        currentState = .sendingTimer
        
        motionManager.startAccelerometerUpdates(to: OperationQueue.current!) { [self] motion, error in
            withAnimation {
                isAccelerating = true
                accelerationRate = (motion?.acceleration.x)! + 1
                if (motion?.acceleration.x)! > 0.35 {
                    isDetected = true
                    motionManager.stopAccelerometerUpdates()
                    UINotificationFeedbackGenerator().notificationOccurred(.success)
                    sendMessage()
                }
            }
        }
        
        startTimer()
    }
    
    ///5초 카운트다운을 시작함
    func startTimer() {
        if counter == 0 { counter = 5 }
        sendTimer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { tempTimer in
            withAnimation {
                if self.counter > 0 { self.counter -= 1 }
                if self.counter == 0 && !self.isDetected {
                    self.currentState = .motionDetectFailure
                    self.stopTimer()
                }
            }
        }
    }
    
    func stopTimer() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) { // 3초 딜레이
            withAnimation {
                self.currentState = .none
                self.isSending = false
                self.sendTimer?.invalidate()
                self.sendTimer = nil
                self.emoji = ""
                self.content = ""
                self.currentState = .none
                self.motionManager.stopAccelerometerUpdates()
                self.isAccelerating = false
            }
        }
    }
    
    func sendMessage() {
        viewModel.sendMessage(emoji: emoji, content: content)
        if let didSendMessage = viewModel.didSendMessage {
            withAnimation {
                currentState = didSendMessage ? .sendingSuccess : .sendingFailure
            }
            stopTimer()
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView(viewModel: .init(peerSessionManager: .debug))
    }
}

