//
//  HomeViewModel.swift
//  Emotilt
//
//  Created by 최유림 on 2023/03/01.
//

import Foundation

class HomeViewModel: BaseViewModel, ObservableObject {
    
    var connectedPeer: Peer? {
        peerSessionManager.connectedPeer
    }
    
    /// 수신한 메시지
    @Published var receivedMessageList: [MessageMetaData] = []
    
    @Published var isConnected: Bool = true
    
    /// close-only
    var didReceiveMessage: Bool {
        get { !receivedMessageList.isEmpty }
        set { removeFirstMessage() }
    }
    
    override init(peerSessionManager: PeerSessionManager) {
        super.init(peerSessionManager: peerSessionManager)

        peerSessionManager.$receivedMessage.assign(to: &$receivedMessageList)
        peerSessionManager.$isConnected.assign(to: &$isConnected)
    }
    
    func sendMessage(_ message: Message) {
        peerSessionManager.sendMessageToNearestPeer(message)
    }
    
    private func removeFirstMessage() {
        peerSessionManager.removeFirstMessage()
    }
}
