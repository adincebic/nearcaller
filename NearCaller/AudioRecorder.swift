//
//  AudioService.swift
//  NearCaller
//
//  Created by Adin Ćebić on 12. 3. 2022..
//

import AVFoundation
import Foundation

protocol AudioRecorderDelegate: AnyObject {
    func recorder(_ recorder: AudioRecorder, didStartRecordingDataFromBus buffer: AVAudioPCMBuffer, time: AVAudioTime)
    func audioRecorderDidStopRecordingDataFromBus()
}

class AudioRecorder {
    private let engine: AVAudioEngine
    private var mixerNode: AVAudioMixerNode!
    private var playerNode: AVAudioPlayerNode!
    weak var delegate: AudioRecorderDelegate?

    init(engine: AVAudioEngine) {
        self.engine = engine
        prepareEngineForRecording()
    }

    private func prepareEngineForRecording() {
        mixerNode = AVAudioMixerNode()

        // Set volume to 0 to avoid audio feedback while recording.
        mixerNode.volume = 0

        engine.attach(mixerNode)

        let inputNode = engine.inputNode
        let inputFormat = inputNode.outputFormat(forBus: 0)
        engine.connect(inputNode, to: mixerNode, format: inputFormat)

        let mainMixerNode = engine.mainMixerNode
        let mixerFormat = AVAudioFormat(commonFormat: .pcmFormatFloat32, sampleRate: inputFormat.sampleRate, channels: 1, interleaved: false)
        engine.connect(mixerNode, to: mainMixerNode, format: mixerFormat)

        engine.prepare()
    }

    func startRecording() throws {
        let format = mixerNode.outputFormat(forBus: 0)

        mixerNode.installTap(onBus: 0, bufferSize: 4096, format: format) { [weak self] buffer, time in
            guard let self = self else { return }
            self.delegate?.recorder(self, didStartRecordingDataFromBus: buffer, time: time)
        }
        try engine.start()
    }

    func stopRecording() {
        mixerNode.removeTap(onBus: 0)
        engine.stop()
        delegate?.audioRecorderDidStopRecordingDataFromBus()
    }
}
