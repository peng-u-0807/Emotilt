//
//  MPCSessionManager.swift
//  Emotilt
//
//  Created by 최유림 on 2023/02/28.
//

import Foundation
import MultipeerConnectivity
import NearbyInteraction

class MPCSessionManager: NSObject {
    private let localPeerID = MCPeerID(displayName: UIDevice.current.name)
    private let session: MCSession
    private let advertiser: MCNearbyServiceAdvertiser
    private let browser: MCNearbyServiceBrowser
    
    @Published var received: (MCPeerID, Data)?
    @Published var connectionState: (MCPeerID, MCSessionState)?
    
    override init() {
        self.session = .init(peer: localPeerID,
                             securityIdentity: nil,
                             encryptionPreference: .required)
        self.advertiser = .init(peer: localPeerID,
                                discoveryInfo: [Configuration.serviceName: Configuration.serviceIdentifier],
                                serviceType: Configuration.serviceName)
        self.browser = .init(peer: localPeerID,
                             serviceType: Configuration.serviceName)
        
        super.init()
        self.session.delegate = self
        self.advertiser.delegate = self
        self.browser.delegate = self
        
        startLookingForPeers()
    }
    
    func startLookingForPeers() {
        advertiser.startAdvertisingPeer()
        browser.startBrowsingForPeers()
    }
    
    func suspendLookingForPeers() {
        advertiser.stopAdvertisingPeer()
        browser.stopBrowsingForPeers()
    }
    
    func invalidateSession() {
        suspendLookingForPeers()
        session.disconnect()
    }
    
    /// Share local device's discovery token to a specific peer
    func sendDiscoveryToken(_ token: NIDiscoveryToken, to peer: MCPeerID) {
        if !session.connectedPeers.contains(peer) {
            print("unconnected peer")
            return
        }
        
        guard let encodedToken = try? NSKeyedArchiver.archivedData(withRootObject: token, requiringSecureCoding: true) else {
            print("cannot encode my discovery token")
            return
        }
        
        do {
            try session.send(encodedToken, toPeers: [peer], with: .reliable)
        } catch let error {
            print(error)
        }
    }
    
    /// Send message to a specific peer
    func sendMessage(_ message: Message, to peerID: MCPeerID) {
        if !session.connectedPeers.contains(peerID) {
            print("unconnected peer")
            return
        }
        
        guard let data = try? JSONEncoder().encode(message) else {
            // fail to encode Message into data
            return
        }
        
        do {
            try session.send(data, toPeers: [peerID], with: .reliable)
        } catch let error {
            print(error)
        }
    }
}

extension MPCSessionManager: MCSessionDelegate {
    func session(_ session: MCSession, peer peerID: MCPeerID, didChange state: MCSessionState) {
        connectionState = (peerID, state)
    }
    
    func session(_ session: MCSession, didReceive data: Data, fromPeer peerID: MCPeerID) {
        received = (peerID, data)
    }
    
    func session(_ session: MCSession, didReceive stream: InputStream, withName streamName: String, fromPeer peerID: MCPeerID) {}
    
    func session(_ session: MCSession, didStartReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, with progress: Progress) {}
    
    func session(_ session: MCSession, didFinishReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, at localURL: URL?, withError error: Error?) {}
}

extension MPCSessionManager: MCNearbyServiceBrowserDelegate {
    func browser(_ browser: MCNearbyServiceBrowser, foundPeer peerID: MCPeerID, withDiscoveryInfo info: [String : String]?) {
        guard let identity = info?[Configuration.serviceName] else {
            print("user not using Emotilt")
            return
        }
        
        // if session's maximum number is required, implement here
        if identity == Configuration.serviceIdentifier {
            browser.invitePeer(peerID, to: session, withContext: nil, timeout: 30)
        }
    }
    
    func browser(_ browser: MCNearbyServiceBrowser, lostPeer peerID: MCPeerID) {
        print("lost peer")
    }
}

extension MPCSessionManager: MCNearbyServiceAdvertiserDelegate {
    func advertiser(_ advertiser: MCNearbyServiceAdvertiser, didReceiveInvitationFromPeer peerID: MCPeerID, withContext context: Data?, invitationHandler: @escaping (Bool, MCSession?) -> Void) {
        // if acceptance of invitation should be restricted, implement here
        invitationHandler(true, session)
    }
}

#if DEBUG
    extension MPCSessionManager {
        static var debug: MPCSessionManager {
            .init()
        }
    }
#endif
