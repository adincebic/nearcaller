//
//  AudioService.swift
//  NearCaller
//
//  Created by Adin Ćebić on 13. 3. 2022..
//

import AVFoundation

protocol AudioServiceDelegate: AnyObject {
    func audioService(_ service: AudioService, didStartRecording data: Data)
}

class AudioService {
    private let session: AVAudioSession
    private let engine: AVAudioEngine
    private let recorder: AudioRecorder
    private let player: AudioPlayer
    weak var delegate: AudioServiceDelegate?
    private var played = 0

    init(session: AVAudioSession = .sharedInstance(), engine: AVAudioEngine = AVAudioEngine()) {
        self.session = session
        self.engine = engine
        self.recorder = AudioRecorder(engine: engine)
        self.player = AudioPlayer(engine: engine)
        recorder.delegate = self
    }

    private func setupSession() {
        do {
            try session.setCategory(.playAndRecord, mode: .voiceChat)
        } catch let error {
            print(error, error.localizedDescription)
        }
    }

    func requestMicrophoneAccess(completion: @escaping (_ grantedPermission: Bool) -> Void) {
        session.requestRecordPermission(completion)
    }

    func startRecording() throws {
        try recorder.startRecording()
    }

    func play(_ audioData: Data) throws {
        played += 1
        print("Played", played)
        guard let format = player.playbackFormat else { return }
        guard let buffer = audioData.makePCMBuffer(format: format) else { return }
        try player.play(buffer)
    }
}

extension AudioService: AudioRecorderDelegate {
    func recorder(_ recorder: AudioRecorder, didStartRecordingDataFromBus buffer: AVAudioPCMBuffer, time: AVAudioTime) {
        let data = Data(buffer: buffer, time: time)
        delegate?.audioService(self, didStartRecording: data)
    }

    func audioRecorderDidStopRecordingDataFromBus() {
        
    }
}

private extension Data {
    init(buffer: AVAudioPCMBuffer, time: AVAudioTime) {
        let audioBuffer = buffer.audioBufferList.pointee.mBuffers
        self.init(bytes: audioBuffer.mData!, count: Int(audioBuffer.mDataByteSize))
    }

    func makePCMBuffer(format: AVAudioFormat) -> AVAudioPCMBuffer? {
        let streamDesc = format.streamDescription.pointee
        let frameCapacity = UInt32(count) / streamDesc.mBytesPerFrame
        guard let buffer = AVAudioPCMBuffer(pcmFormat: format, frameCapacity: frameCapacity) else { return nil }

        buffer.frameLength = buffer.frameCapacity
        let audioBuffer = buffer.audioBufferList.pointee.mBuffers

        withUnsafeBytes { (bufferPointer) in
            guard let addr = bufferPointer.baseAddress else { return }
            audioBuffer.mData?.copyMemory(from: addr, byteCount: Int(audioBuffer.mDataByteSize))
        }

        return buffer
    }
}
