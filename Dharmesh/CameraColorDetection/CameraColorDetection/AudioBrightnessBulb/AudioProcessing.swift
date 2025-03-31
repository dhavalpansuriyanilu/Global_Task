import AVFoundation
import Accelerate
//MARK: - SwiftChartsAudioVisualizer
//Sorhttps://github.com/vNakamura/SwiftChartsAudioVisualizer
//class AudioProcessing {
//    static let shared = AudioProcessing()
//    
//    private let engine = AVAudioEngine()
//    private let bufferSize = 1024
//    private var audioFile: AVAudioFile?
//    private var currentFramePosition: AVAudioFramePosition = 0
//    
//    let player = AVAudioPlayerNode()
//    var fftMagnitudes: [Float] = []
//    
//    private init() {setupAudio()}
//    
//    func setupAudio() {
//        
//        _ = engine.mainMixerNode
//        
//        engine.prepare()
//        try! engine.start()
//        
//        audioFile = try! AVAudioFile(
//            forReading: Bundle.main.url(forResource: "8D Audio Bass Test !!", withExtension: "mp3")!
//        )
//        let format = audioFile!.processingFormat
//        
//        engine.attach(player)
//        engine.connect(player, to: engine.mainMixerNode, format: format)
//        
//        player.scheduleFile(audioFile!, at: nil)
//        
//        let fftSetup = vDSP_DFT_zop_CreateSetup(
//            nil,
//            UInt(bufferSize),
//            vDSP_DFT_Direction.FORWARD
//        )
//        
//        engine.mainMixerNode.installTap(
//            onBus: 0,
//            bufferSize: UInt32(bufferSize),
//            format: nil
//        ) { [self] buffer, _ in
//            let channelData = buffer.floatChannelData?[0]
//            fftMagnitudes = fft(data: channelData!, setup: fftSetup!)
//        }
//        
//    }
//
//    func fft(data: UnsafeMutablePointer<Float>, setup: OpaquePointer) -> [Float] {
//        var realIn = [Float](repeating: 0, count: bufferSize)
//        var imagIn = [Float](repeating: 0, count: bufferSize)
//        var realOut = [Float](repeating: 0, count: bufferSize)
//        var imagOut = [Float](repeating: 0, count: bufferSize)
//            
//        for i in 0 ..< bufferSize {
//            realIn[i] = data[i]
//        }
//        
//        vDSP_DFT_Execute(setup, &realIn, &imagIn, &realOut, &imagOut)
//        
//        var magnitudes = [Float](repeating: 0, count: 40)
//        
//        realOut.withUnsafeMutableBufferPointer { realBP in
//            imagOut.withUnsafeMutableBufferPointer { imagBP in
//                var complex = DSPSplitComplex(realp: realBP.baseAddress!, imagp: imagBP.baseAddress!)
//                vDSP_zvabs(&complex, 1, &magnitudes, 1, UInt(40))
//            }
//        }
//        
//        var normalizedMagnitudes = [Float](repeating: 0.0, count: 40)
//        var scalingFactor = Float(1)
//        vDSP_vsmul(&magnitudes, 1, &scalingFactor, &normalizedMagnitudes, 1, UInt(40))
//            
//        return normalizedMagnitudes
//    }
//    
//    func play() {
//        if !player.isPlaying {
//            player.play()
//        }
//    }
//    
//    func pause() {
//        if player.isPlaying {
//            currentFramePosition = player.lastRenderTime!.sampleTime
//            player.pause()
//        }
//    }
//    
//    func resume() {
//        if !player.isPlaying {
//            player.play()
//        }
//    }
//    
//    func stop() {
//        player.stop()
//    }
//}

//class AudioProcessing {
//    static let shared = AudioProcessing()
//    
//    private let engine = AVAudioEngine()
//    private let bufferSize = 1024
//    private var audioFile: AVAudioFile?
//    private var currentFramePosition: AVAudioFramePosition = 0
//    
//    let player = AVAudioPlayerNode()
//    var fftMagnitudes: [Float] = []
//    
//    private init() {
//        _ = engine.mainMixerNode
//        
//        engine.prepare()
//        try! engine.start()
//        
//        audioFile = try! AVAudioFile(
//            forReading: Bundle.main.url(forResource: "music", withExtension: "mp3")!
//        )
//        let format = audioFile!.processingFormat
//            
//        engine.attach(player)
//        engine.connect(player, to: engine.mainMixerNode, format: format)
//            
//        player.scheduleFile(audioFile!, at: nil)
//            
//        let fftSetup = vDSP_DFT_zop_CreateSetup(
//            nil,
//            UInt(bufferSize),
//            vDSP_DFT_Direction.FORWARD
//        )
//            
//        engine.mainMixerNode.installTap(
//            onBus: 0,
//            bufferSize: UInt32(bufferSize),
//            format: nil
//        ) { [self] buffer, _ in
//            let channelData = buffer.floatChannelData?[0]
//            fftMagnitudes = fft(data: channelData!, setup: fftSetup!)
//        }
//    }
//    
//    func fft(data: UnsafeMutablePointer<Float>, setup: OpaquePointer) -> [Float] {
//        var realIn = [Float](repeating: 0, count: bufferSize)
//        var imagIn = [Float](repeating: 0, count: bufferSize)
//        var realOut = [Float](repeating: 0, count: bufferSize)
//        var imagOut = [Float](repeating: 0, count: bufferSize)
//            
//        for i in 0 ..< bufferSize {
//            realIn[i] = data[i]
//        }
//        
//        vDSP_DFT_Execute(setup, &realIn, &imagIn, &realOut, &imagOut)
//        
//        var magnitudes = [Float](repeating: 0, count: 40)
//        
//        realOut.withUnsafeMutableBufferPointer { realBP in
//            imagOut.withUnsafeMutableBufferPointer { imagBP in
//                var complex = DSPSplitComplex(realp: realBP.baseAddress!, imagp: imagBP.baseAddress!)
//                vDSP_zvabs(&complex, 1, &magnitudes, 1, UInt(40))
//            }
//        }
//        
//        var normalizedMagnitudes = [Float](repeating: 0.0, count: 40)
//        var scalingFactor = Float(1)
//        vDSP_vsmul(&magnitudes, 1, &scalingFactor, &normalizedMagnitudes, 1, UInt(40))
//            
//        return normalizedMagnitudes
//    }
//    
//    func play() {
//        if !player.isPlaying {
//            player.play()
//        }
//    }
//    
//    func pause() {
//        if player.isPlaying {
//            currentFramePosition = player.lastRenderTime!.sampleTime
//            player.pause()
//        }
//    }
//    
//    func resume() {
//        if !player.isPlaying {
//            player.play()
//        }
//    }
//    
//    func stop() {
//        player.stop()
//    }
//}

import AVFoundation

class AudioProcessing {
    static let shared = AudioProcessing()
    
    private let engine = AVAudioEngine()
    private let bufferSize = 1024
    private var audioFile: AVAudioFile?
    private var currentFramePosition: AVAudioFramePosition = 0
    
    let player = AVAudioPlayerNode()
    var fftMagnitudes: [Float] = []
    
    private init() {
        setupAudioSession()
        setupAudio()
    }
    
    private func setupAudioSession() {
        let audioSession = AVAudioSession.sharedInstance()
        do {
            try audioSession.setCategory(.playback, mode: .default, options: [.defaultToSpeaker])
            try audioSession.setActive(true)
        } catch {
            print("Failed to set up audio session: \(error)")
        }
    }

    private func setupAudio() {
        _ = engine.mainMixerNode
        
        engine.prepare()
        do {
            try engine.start()
        } catch {
            print("Failed to start the audio engine: \(error)")
        }
        
        do {
            audioFile = try AVAudioFile(forReading: Bundle.main.url(forResource: "music", withExtension: "mp3")!)
        } catch {
            print("Failed to load audio file: \(error)")
        }
        
        guard let audioFile = audioFile else { return }
        
        let format = audioFile.processingFormat
            
        engine.attach(player)
        engine.connect(player, to: engine.mainMixerNode, format: format)
            
        player.scheduleFile(audioFile, at: nil)
            
        let fftSetup = vDSP_DFT_zop_CreateSetup(nil, UInt(bufferSize), vDSP_DFT_Direction.FORWARD)
            
        engine.mainMixerNode.installTap(onBus: 0, bufferSize: UInt32(bufferSize), format: nil) { [self] buffer, _ in
            let channelData = buffer.floatChannelData?[0]
            fftMagnitudes = fft(data: channelData!, setup: fftSetup!)
        }
    }
    
    func fft(data: UnsafeMutablePointer<Float>, setup: OpaquePointer) -> [Float] {
        var realIn = [Float](repeating: 0, count: bufferSize)
        var imagIn = [Float](repeating: 0, count: bufferSize)
        var realOut = [Float](repeating: 0, count: bufferSize)
        var imagOut = [Float](repeating: 0, count: bufferSize)
            
        for i in 0 ..< bufferSize {
            realIn[i] = data[i]
        }
        
        vDSP_DFT_Execute(setup, &realIn, &imagIn, &realOut, &imagOut)
        
        var magnitudes = [Float](repeating: 0, count: 40)
        
        realOut.withUnsafeMutableBufferPointer { realBP in
            imagOut.withUnsafeMutableBufferPointer { imagBP in
                var complex = DSPSplitComplex(realp: realBP.baseAddress!, imagp: imagBP.baseAddress!)
                vDSP_zvabs(&complex, 1, &magnitudes, 1, UInt(40))
            }
        }
        
        var normalizedMagnitudes = [Float](repeating: 0.0, count: 40)
        var scalingFactor = Float(1)
        vDSP_vsmul(&magnitudes, 1, &scalingFactor, &normalizedMagnitudes, 1, UInt(40))
            
        return normalizedMagnitudes
    }
    
    func play() {
        if !player.isPlaying {
            player.play()
        }
    }
    
    func pause() {
        if player.isPlaying {
            currentFramePosition = player.lastRenderTime!.sampleTime
            player.pause()
        }
    }
    
    func resume() {
        if !player.isPlaying {
            player.play()
        }
    }
    
    func stop() {
        player.stop()
    }
}
