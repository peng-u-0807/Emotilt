//
//  HomeViewModel.swift
//  Emotilt
//
//  Created by 최유림 on 2023/03/01.
//

import Foundation

class HomeViewModel: BaseViewModel, ObservableObject {
    /// 연결된 peer 목록
    @Published var peerList: [Peer] = []
    
    /// 수신한 메시지
    @Published var receivedMessageList: [MessageMetaData] = []
    
    /// close-only
    var didReceiveMessage: Bool {
        get { !receivedMessageList.isEmpty }
        set { removeFirstMessage() }
    }
    
    override init(peerSessionManager: PeerSessionManager) {
        super.init(peerSessionManager: peerSessionManager)
        
        peerSessionManager.$peerList.assign(to: &$peerList)
        peerSessionManager.$receivedMessage.assign(to: &$receivedMessageList)
    }
    
    func sendMessage(_ message: Message) {
        peerSessionManager.sendMessageToNearestPeer(message)
    }
    
    private func removeFirstMessage() {
        peerSessionManager.removeFirstMessage()
    }
}
