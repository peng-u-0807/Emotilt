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
    private let myPeerID = MCPeerID(displayName: UIDevice.current.name)
    private let mcSession: MCSession
    private let advertiser: MCNearbyServiceAdvertiser
    private let browser: MCNearbyServiceBrowser
    
    @Published var received: (MCPeerID, Data)?
    @Published var connectionState: (MCPeerID, MCSessionState)?
    
    override init() {
        self.mcSession = .init(peer: myPeerID,
                             securityIdentity: nil,
                             encryptionPreference: .required)
        self.browser = .init(peer: myPeerID,
                             serviceType: Configuration.serviceName)
        #if targetEnvironment(simulator)
        self.advertiser = .init(peer: myPeerID,
                                discoveryInfo: [Configuration.serviceName: Configuration.simulatorIdentifier],
                                serviceType: Configuration.serviceName)
        #else
        self.advertiser = .init(peer: myPeerID,
                                discoveryInfo: [Configuration.serviceName: Configuration.serviceIdentifier],
                                serviceType: Configuration.serviceName)
        #endif
        super.init()
        
        self.advertiser.delegate = self
        self.browser.delegate = self
        self.mcSession.delegate = self

        startLookingForPeers()
    }
    
    deinit {
        mcSession.disconnect()
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
        mcSession.disconnect()
    }
    
    func deleteConnectedPeer(_ peerID: MCPeerID) {
        mcSession.disconnect()
        suspendLookingForPeers()
        startLookingForPeers()
    }
    
    /// Share local device's discovery token to peers
    func sendDiscoveryToken(_ token: NIDiscoveryToken) {
        guard let encodedToken = try? NSKeyedArchiver.archivedData(withRootObject: token, requiringSecureCoding: true) else {
            print("cannot encode my discovery token")
            return
        }
        
        do {
            try mcSession.send(encodedToken, toPeers: mcSession.connectedPeers, with: .reliable)
        } catch let error {
            print(error)
        }
    }
    
    func sendMessage(_ message: Message, to peerID: MCPeerID?) {
        let messageMetaData = MessageMetaData(sender: mcSession.myPeerID.displayName, message: message)
        guard let data = try? JSONEncoder().encode(messageMetaData) else {
            // fail to encode Message into data
            return
        }
        guard let peerID = peerID else { return }
        do {
            try mcSession.send(data, toPeers: [peerID], with: .reliable)
        } catch let error {
            print("Error occured while sending to \([peerID]), connectedPeers: \(mcSession.connectedPeers) \n \(error)")
        }
    }
}

extension MPCSessionManager: MCSessionDelegate {
    func session(_ session: MCSession, peer peerID: MCPeerID, didChange state: MCSessionState) {
        self.connectionState = (peerID, state)
    }
    
    func session(_ session: MCSession, didReceive data: Data, fromPeer peerID: MCPeerID) {
        self.received = (peerID, data)
    }
    
    func session(_ session: MCSession, didReceive stream: InputStream, withName streamName: String, fromPeer peerID: MCPeerID) {}
    
    func session(_ session: MCSession, didStartReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, with progress: Progress) {}
    
    func session(_ session: MCSession, didFinishReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, at localURL: URL?, withError error: Error?) {}
}

extension MPCSessionManager: MCNearbyServiceBrowserDelegate {
    func browser(_ browser: MCNearbyServiceBrowser, foundPeer peerID: MCPeerID, withDiscoveryInfo info: [String : String]?) {
        guard let serviceName = info?[Configuration.serviceName] else {
            return
        }
        
        // if session's maximum number is required, implement here
        #if targetEnvironment(simulator)
        if serviceName == Configuration.simulatorIdentifier {
            browser.invitePeer(peerID, to: mcSession, withContext: nil, timeout: 10)
        }
        #else
        if serviceName == Configuration.serviceIdentifier {
            browser.invitePeer(peerID, to: mcSession, withContext: nil, timeout: 10)
        }
        #endif
    }
    
    func browser(_ browser: MCNearbyServiceBrowser, lostPeer peerID: MCPeerID) {
        print("lost peer: \(peerID)")
        self.connectionState = (peerID, .notConnected)
    }
}

extension MPCSessionManager: MCNearbyServiceAdvertiserDelegate {
    func advertiser(_ advertiser: MCNearbyServiceAdvertiser, didReceiveInvitationFromPeer peerID: MCPeerID, withContext context: Data?, invitationHandler: @escaping (Bool, MCSession?) -> Void) {
        // if acceptance of invitation should be restricted, implement here
        invitationHandler(true, mcSession)
    }
}
