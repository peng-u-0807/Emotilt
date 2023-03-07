//
//  PeerSessionManager.swift
//  Emotilt
//
//  Created by 최유림 on 2023/03/01.
//

import Foundation
import Combine
import NearbyInteraction
import MultipeerConnectivity

class PeerSessionManager: NSObject {
    private let mpcSessionManager: MPCSessionManager
    
    /// 연결된 peer 목록
    @Published var peerList: [Peer] = []
    
    /// 수신한 메시지
    @Published var receivedMessage: MessageMetaData?
    
    /// 현재 내 로컬 디바이스와 가장 가까이 있는 기기의 discoveryToken
    @Published var nearestPeerToken: NIDiscoveryToken?

    private var bag = Set<AnyCancellable>()
    
    init(mpcSessionManager: MPCSessionManager) {
        self.mpcSessionManager = mpcSessionManager
        
        super.init()
        
        peerList.append(getReadyForPeer())
        
        mpcSessionManager.$connectionState.compactMap { $0 }.receive(on: RunLoop.main).sink { [weak self] state in
            switch state.1 {
            case .connected:
                self?.registerNewPeer(state.0)
            case .notConnected:
                self?.deleteUnconnectedPeer(state.0)
            case .connecting:
                print("connecting")
            @unknown default:
                print("default")
            }
        }.store(in: &bag)
        
        mpcSessionManager.$received.compactMap { $0 }.receive(on: RunLoop.main).sink { [weak self] received in
            if let discoveryToken = try? NSKeyedUnarchiver.unarchivedObject(ofClass: NIDiscoveryToken.self, from: received.1) {
                self?.receivedDiscoveryToken(from: received.0, token: discoveryToken)
            } else if let messageMetaData = try? JSONDecoder().decode(MessageMetaData.self, from: received.1) {
                self?.receivedMessage = messageMetaData
            }
        }.store(in: &bag)
    }
    
    func sendMessageToNearestPeer(_ message: Message) {
        guard let token = nearestPeerToken else {
            print("no nearest peer's token")
            return
        }
        print("trying to send to \(token)")
        
        guard let peerID = peerList.first(where: { $0.token == token })?.id else {
            print("no matching peer in peerList")
            return
        }
        
        mpcSessionManager.sendMessage(message, to: peerID)
    }
    
    /// 새로운 Peer를 추가하고 연결받을 준비를 합니다.
    private func getReadyForPeer() -> Peer {
        let peer = Peer(session: .init())
        peer.session.delegate = self
        return peer
    }
    
    private func sendDiscoveryToken(_ token: NIDiscoveryToken, to peer: MCPeerID) {
        mpcSessionManager.sendDiscoveryToken(token, to: peer)
    }
    
    /// Register peerID to peerList and append new session
    private func registerNewPeer(_ peerID: MCPeerID) {
        if let peer = peerList.first(where: { $0.id == nil }) {
            guard let myToken = peer.session.discoveryToken else {
                return
            }
            
            if !peer.didShareToken {
                sendDiscoveryToken(myToken, to: peerID)
                peer.didShareToken = true
                peer.id = peerID
                
                peerList.append(getReadyForPeer())
                for peer in peerList {
                    print(peer.id)
                    print(peer.token)
                }
                print("did register new peer")
            }
        }
    }
    
    private func deleteUnconnectedPeer(_ peerID: MCPeerID) {
        peerList.removeAll(where: { $0.id == peerID && $0.session.configuration != nil })
    }
    
    /// Session을 열어둔 상태에서 token을 받은 경우
    private func receivedDiscoveryToken(from peerID: MCPeerID, token: NIDiscoveryToken) {
        guard let peer = peerList.first(where: { $0.id == peerID }) else {
            print("no matching peer")
            return
        }
        
        peer.token = token
        let config = NINearbyPeerConfiguration(peerToken: token)
        peer.session.run(config)
    }
}

extension PeerSessionManager: NISessionDelegate {
    
    // session이 열렸을 때에만 동작
    func session(_ session: NISession, didUpdate nearbyObjects: [NINearbyObject]) {
        nearestPeerToken = getNearestPeer(from: nearbyObjects)
    }
    
    // MARK: Get nearest device
    
    /// Sort nearbyObjects by direction and return the nearest object's discoveryToken
    private func getNearestPeer(from nearbyObjects: [NINearbyObject]) -> NIDiscoveryToken {
        let directions = nearbyObjects.sorted { $0.distance ?? .zero < $1.distance ?? .zero }
        return directions[0].discoveryToken
    }
}

#if DEBUG
    extension PeerSessionManager {
        static var debug: PeerSessionManager {
            .init(mpcSessionManager: .debug)
        }
    }
#endif
