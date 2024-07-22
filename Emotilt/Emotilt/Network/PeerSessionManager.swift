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
    
    /// 연결된 peer
    var connectedPeer: Peer?
    
    /// 연결된 peer이 있는지에 대한 변수
    @Published var isConnected: Bool = false
    
    /// 수신한 메시지
    @Published var receivedMessage: [MessageMetaData] = []
    
    /// 현재 내 로컬 디바이스와 가장 가까이 있는 기기의 discoveryToken
    //@Published var nearestPeerToken: NIDiscoveryToken?

    private var bag = Set<AnyCancellable>()
    
    init(mpcSessionManager: MPCSessionManager) {
        self.mpcSessionManager = mpcSessionManager
        
        super.init()

        connectedPeer = .init(session: NISession())
        connectedPeer?.session.delegate = self

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
        
        mpcSessionManager.$received.compactMap { $0 }.receive(on: DispatchQueue.main).sink { received in
            if let discoveryToken = try? NSKeyedUnarchiver.unarchivedObject(ofClass: NIDiscoveryToken.self, from: received.1) {
                self.receivedDiscoveryToken(from: received.0, token: discoveryToken)
            } else if let messageMetaData = try? JSONDecoder().decode(MessageMetaData.self, from: received.1) {
                self.receivedMessage.append(messageMetaData)
            }
        }.store(in: &bag)
    }
    
    func sendMessageToNearestPeer(_ message: Message) {
        mpcSessionManager.sendMessage(message, to: connectedPeer?.id)
    }
    
    func removeFirstMessage() {
        if !receivedMessage.isEmpty {
            _ = receivedMessage.removeFirst()
        }
    }
    
    private func sendDiscoveryToken(to peer: MCPeerID) {
        guard let token = connectedPeer?.session.discoveryToken else {
            print("connectPeer is nil")
            return
        }
        mpcSessionManager.sendDiscoveryToken(token)
    }
    
    /// Register peerID to peerList and append new session
    private func registerNewPeer(_ peerID: MCPeerID) {
        guard let _ = connectedPeer else {
            return
        }
        sendDiscoveryToken(to: peerID)
        isConnected = true
    }
    
    private func deleteUnconnectedPeer(_ peerID: MCPeerID) {
        isConnected = false
        mpcSessionManager.deleteUnconnectedPeer(peerID)
    }
    
    private func receivedDiscoveryToken(from peerID: MCPeerID, token: NIDiscoveryToken) {
        print("received discovery token from \(peerID), token: \(token)")
        connectedPeer?.id = peerID
        connectedPeer?.token = token
        //let config = NINearbyPeerConfiguration(peerToken: token)
        //connectedPeer?.session.run(config)
        isConnected = true
    }
}

extension PeerSessionManager: NISessionDelegate {
    
    // session이 열렸을 때에만 동작
    func session(_ session: NISession, didUpdate nearbyObjects: [NINearbyObject]) {
        print(nearbyObjects)
        //nearestPeerToken = getNearestPeer(from: nearbyObjects)
    }
    
    // MARK: Get nearest device
    
    /// Sort nearbyObjects by direction and return the nearest object's discoveryToken
    private func getNearestPeer(from nearbyObjects: [NINearbyObject]) -> NIDiscoveryToken {
//        let directions = nearbyObjects.sorted { $0.distance ?? .zero < $1.distance ?? .zero }
//        return directions[0].discoveryToken
        
        return nearbyObjects.first!.discoveryToken
    }
    
//    func session(_ session: NISession, didRemove nearbyObjects: [NINearbyObject], reason: NINearbyObject.RemovalReason) {
//        switch reason {
//        case .peerEnded:
//            // The peer token is no longer valid.
//            
//            // The peer stopped communicating, so invalidate the session because it's finished.
//            session.invalidate()
//            
//            // Restart the sequence to see if the peer comes back.
//            connectedPeer?.restartSession()
//            connectedPeer?.session.delegate = self
//            
//        case .timeout:
//            
//            // The peer timed out, but the session is valid.
//            // If the configuration is valid, run the session again.
//            if let config = session.configuration {
//                session.run(config)
//            }
//        default:
//            fatalError("Unknown and unhandled NINearbyObject.RemovalReason")
//        }
//    }
}
