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
    
    var body: some View {
        VStack(alignment: .center) {
            Spacer().frame(height: 24)
            
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
                //TODO: 흔드는 애니메이션이나 가이드 넣기
            case .none:
                Text("")
            }
            
            if let message = viewModel.receivedMessage {
                Text(message.emoji)
                    .font(.system(size: 42))
                
                Spacer().frame(height: 16)
                
                Text(message.content ?? "")
                    .font(.system(size: 36))
            }
            
            Spacer()
            
            RoundedButton(label: "Send") {
               //viewModel.detectAcceleration()
                viewModel.sendMessage()
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
