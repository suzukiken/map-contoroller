import AVFoundation
import Foundation
import Speech

@MainActor
final class SpeechInputManager {
    private let recognizer = SFSpeechRecognizer(locale: Locale(identifier: "ja-JP"))
    private var recognitionTask: SFSpeechRecognitionTask?
    private let audioEngine = AVAudioEngine()

    var isAvailable: Bool {
        recognizer?.isAvailable == true
    }

    func requestAuthorization() async -> Bool {
        await withCheckedContinuation { continuation in
            SFSpeechRecognizer.requestAuthorization { status in
                continuation.resume(returning: status == .authorized)
            }
        }
    }

    func transcribe() async throws -> String {
        guard let recognizer, recognizer.isAvailable else {
            throw SpeechInputError.notAvailable
        }

        recognitionTask?.cancel()
        recognitionTask = nil

        let session = AVAudioSession.sharedInstance()
        try session.setCategory(.record, mode: .measurement, options: .duckOthers)
        try session.setActive(true, options: .notifyOthersOnDeactivation)

        let request = SFSpeechAudioBufferRecognitionRequest()
        request.shouldReportPartialResults = false

        let inputNode = audioEngine.inputNode
        let recordingFormat = inputNode.outputFormat(forBus: 0)
        inputNode.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat) { buffer, _ in
            request.append(buffer)
        }

        audioEngine.prepare()
        try audioEngine.start()

        return try await withCheckedThrowingContinuation { continuation in
            recognitionTask = recognizer.recognitionTask(with: request) { [weak self] result, error in
                if let error {
                    self?.stopRecording()
                    continuation.resume(throwing: error)
                    return
                }

                guard let result, result.isFinal else { return }
                self?.stopRecording()
                continuation.resume(returning: result.bestTranscription.formattedString)
            }
        }
    }

    private func stopRecording() {
        audioEngine.stop()
        audioEngine.inputNode.removeTap(onBus: 0)
        recognitionTask?.cancel()
        recognitionTask = nil
        try? AVAudioSession.sharedInstance().setActive(false)
    }
}

enum SpeechInputError: LocalizedError {
    case notAvailable

    var errorDescription: String? {
        switch self {
        case .notAvailable:
            return "音声認識が利用できません"
        }
    }
}
