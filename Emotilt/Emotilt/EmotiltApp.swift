//
//  EmotiltApp.swift
//  Emotilt
//
//  Created by 최유림 on 2023/02/27.
//

import SwiftUI

@main
struct EmotiltApp: App {
    
    let peerSessionManager: PeerSessionManager
    
    init() {
        peerSessionManager = .init(mpcSessionManager: .init())
    }
    
    var body: some Scene {
        WindowGroup {
            HomeScene(viewModel: .init(peerSessionManager: peerSessionManager))
        }
    }
}
