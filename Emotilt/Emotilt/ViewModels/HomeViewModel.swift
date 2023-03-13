//
//  HomeViewModel.swift
//  Emotilt
//
//  Created by 최유림 on 2023/03/01.
//

import Foundation
import CoreMotion
import UIKit

enum viewState {
    case sendingSuccess //메세지 보내기 성공 직후 + 5초
    case sendingFailure //메세지 보내기 실패 직후 + 5초
    case motionDetectFailure //장전 이후 모션 감지 실패
    case sendingTimer //장전 단계
    case none //디폴트 화면
}

class HomeViewModel: BaseViewModel, ObservableObject {
    /// 연결된 peer 목록
    @Published var peerList: [Peer] = []
    
    /// 수신한 메시지
    @Published var receivedMessage: Message?
    
    var didReceiveMessage: Bool {
        receivedMessage != nil
    }
    
    //MARK: - 뷰 관련 값
    @Published var emoji : String = ""
    @Published var content : String = ""
    
    //MARK: - 메세지 전송 관련 값
    let motionManager = CMMotionManager()
    @Published var sendTimer: Timer?
    @Published var currentState: viewState = .none
    @Published var isSending: Bool = false
    @Published var isAccelerating: Bool = false
    @Published var accelerationRate: Double = 0.0
    @Published var counter: Int = 0
    @Published var isReadyForSending: Bool = false
    var isDetected: Bool = false
    
    override init(peerSessionManager: PeerSessionManager) {
        super.init(peerSessionManager: peerSessionManager)
        
        peerSessionManager.$peerList.assign(to: &$peerList)
        peerSessionManager.$receivedMessage.assign(to: &$receivedMessage)
    }
}

//MARK: - message send logic
extension HomeViewModel {
   
    ///장전을 시작하고 모션을 감지함
    func detectAcceleration(){
        isDetected = false
        isSending = true
        currentState = .sendingTimer
        
        motionManager
            .startAccelerometerUpdates(to: OperationQueue.current!, withHandler: { [self] (motion, error) in
                isAccelerating = true
                accelerationRate = (motion?.acceleration.x)! + 1
                if ((motion?.acceleration.x)! > 0.35){
                    isDetected = true
                    motionManager.stopAccelerometerUpdates()
                    UINotificationFeedbackGenerator().notificationOccurred(.success)
                    sendMessage()
                }
            })
        startTimer()
    }
    
    ///5초 카운트다운을 시작함
    func startTimer(){
        if (counter == 0){ counter = 5 }
        sendTimer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { tempTimer in
            if (self.counter > 0){ self.counter = 1 }
            if (self.counter == 0 && !self.isDetected){
                self.currentState = .motionDetectFailure
                self.stopTimer()
            }
        }
    }
    
    func stopTimer(){
        DispatchQueue.main.asyncAfter(deadline: .now() + 3.0){
            self.currentState = .none
            self.isSending = false
            self.sendTimer?.invalidate()
            self.sendTimer = nil
            self.emoji = ""
            self.content = ""
            self.currentState = .none
            self.motionManager.stopAccelerometerUpdates()
            self.isAccelerating = false
        }
    }
    
    func sendMessage(){
        let message = Message(emoji: emoji, content: content)
        peerSessionManager.sendMessageToNearestPeer(message){ success in
            self.currentState = (success) ? .sendingSuccess : .sendingFailure
        }
        stopTimer()
    }
}
