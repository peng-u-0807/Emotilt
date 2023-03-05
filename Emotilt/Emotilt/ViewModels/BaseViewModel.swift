//
//  BaseViewModel.swift
//  Emotilt
//
//  Created by 최유림 on 2023/03/03.
//

import Foundation

class BaseViewModel {
    var peerSessionManager: PeerSessionManager
    
    init(peerSessionManager: PeerSessionManager) {
        self.peerSessionManager = peerSessionManager
    }
}
