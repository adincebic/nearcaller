//
//  ViewModel.swift
//  NearCaller
//
//  Created by Adin Ćebić on 12. 3. 2022..
//

import Foundation
import AVFoundation
import UIKit

class ViewModel: ObservableObject {
    private let audioService: AudioService
    private let multiPeerService: MultiPeerService

    init(audioService: AudioService = AudioService(), multipeerService: MultiPeerService = MultiPeerService()) {
        self.audioService = audioService
        self.multiPeerService = multipeerService
        audioService.delegate = self
        multipeerService.delegate = self
    }

    func onAppear() {
        requestMicrophoneAccess()
    }

    private func requestMicrophoneAccess() {
        audioService.requestMicrophoneAccess { grantedPermission in
            if grantedPermission {
                // All good
            }
        }
    }

    func callButtonTapped() {
        try? audioService.startRecording()
    }
}

extension ViewModel: AudioServiceDelegate {
    func audioService(_ service: AudioService, didStartRecording data: Data) {
        multiPeerService.send(message: data)
    }
}

extension ViewModel: MultiPeerServiceDelegate {
    func didReceiveMessage(service: MultiPeerService, message: Data) {
        try? audioService.play(message)
    }
}
