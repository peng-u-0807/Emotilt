//
//  Peer.swift
//  Emotilt
//
//  Created by 최유림 on 2023/02/28.
//

import Foundation
import NearbyInteraction
import MultipeerConnectivity

/// Custom object for NISession sharing same NISessionDelegate
class Peer {
    let session: NISession
    
    /// Currently connected peer in this session
    var id: MCPeerID?
    
    /// Currently connected peer's discovery token
    var token: NIDiscoveryToken?
    
    var didShareToken: Bool = false
    
    init(session: NISession) {
        self.session = session
    }
}
