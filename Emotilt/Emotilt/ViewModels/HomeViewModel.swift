//
//  HomeViewModel.swift
//  Emotilt
//
//  Created by 최유림 on 2023/03/01.
//

import Foundation
import CoreMotion
import UIKit

enum viewState {
    case sendingSuccess //메세지 보내기 성공 직후 + 5초
    case sendingFailure //메세지 보내기 실패 직후 + 5초
    case motionDetectFailure //장전 이후 모션 감지 실패
    case sendingTimer //장전 단계
    case none //디폴트 화면
}

class HomeViewModel: BaseViewModel, ObservableObject {
    /// 연결된 peer 목록
    @Published var peerList: [Peer] = []
    
    /// 수신한 메시지
    @Published var receivedMessage: Message?
    
    /// 메세지 발신 성공 여부
    @Published var didSendMessage: Bool?
    
    var didReceiveMessage: Bool {
        receivedMessage != nil
    }
    
    @Published var currentState: viewState = .none
    
    override init(peerSessionManager: PeerSessionManager) {
        super.init(peerSessionManager: peerSessionManager)
        peerSessionManager.$peerList.assign(to: &$peerList)
        peerSessionManager.$receivedMessage.assign(to: &$receivedMessage)
        peerSessionManager.$didSendMessage.assign(to: &$didSendMessage)
    }
    
    func sendMessage(emoji: String, content: String){
        let message = Message(emoji: emoji, content: content)
        peerSessionManager.sendMessageToNearestPeer(message)
    }
}

   


