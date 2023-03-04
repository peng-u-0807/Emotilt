//
//  EmotiltApp.swift
//  Emotilt
//
//  Created by 최유림 on 2023/02/27.
//

import SwiftUI

@main
struct EmotiltApp: App {
    
    let interactor: PeerSessionManager
    
    init() {
        interactor = .init(mpcSessionManager: .init())
        
    }
    
    var body: some Scene {
        WindowGroup {
            HomeView(viewModel: .init(peerSessionManager: interactor))
        }
    }
}
