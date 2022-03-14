//
//  AudioPlayer.swift
//  NearCaller
//
//  Created by Adin Ćebić on 13. 3. 2022..
//

import AVFoundation

class AudioPlayer {
    private let engine: AVAudioEngine
    private var playerNode: AVAudioPlayerNode!
    var playbackFormat: AVAudioFormat? {
        return AVAudioFormat(commonFormat: .pcmFormatFloat32, sampleRate: 48000.0, channels: 1, interleaved: false)
    }

    init(engine: AVAudioEngine) {
        self.engine = engine
        prepareForPlayback()
    }

    private func prepareForPlayback() {
        playerNode = AVAudioPlayerNode()
        engine.attach(playerNode)
        guard let playbackFormat = playbackFormat else {
            assertionFailure("Playback format can not be initialized")
            return
        }
        engine.connect(playerNode, to: engine.outputNode, format: playbackFormat)
    }

    func play(_ buffer: AVAudioPCMBuffer) throws {
        playerNode.scheduleBuffer(buffer)
        guard !engine.isRunning else {
            playerNode.play()
            return
        }
        try engine.start()
        playerNode.play()
    }
}
