//
//  AudioManager.swift
//  NavCogMiraikan
//
/*******************************************************************************
 * Copyright (c) 2023 © Miraikan - The National Museum of Emerging Science and Innovation
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 * THE SOFTWARE.
 *******************************************************************************/


import Foundation
import AVFoundation
import AudioToolbox
import AVKit

protocol AudioManagerDelegate {
    func speakingMessage(message: String)
}

// Singleton
final public class AudioManager: NSObject {
    
    var delegate: AudioManagerDelegate?
    
    private let tts = DefaultTTS()
    private(set) var isPlaying = false
    private(set) var isSoundEffect = false

    private var voiceList: [VoiceModel] = []

    private var speakingData: VoiceModel?
    private var speakedId: Int? // 音声再生中のブレによるマーカー交互の読み取り防止
    private var player: AVAudioPlayer?

    private var lastSpeakTime: Double = 0
    private var soundEffectTime: Double = 0
    private var intervalTime: Double = 0

    private var lang = ""

    private override init() {
        super.init()
        lang = NSLocalizedString("lang", comment: "")
        lastSpeakTime = Date().timeIntervalSince1970
        
        let center = NotificationCenter.default
        center.addObserver(self,
                           selector: #selector(voiceOverNotification),
                           name: UIAccessibility.voiceOverStatusDidChangeNotification,
                           object: nil)
    }

    public static let shared = AudioManager()

    func setupInitialize() {
        
        var msg = NSLocalizedString("Point your phone's camera at the front and slowly move left and right to look for sound guidance.", comment: "")
        msg += NSLocalizedString("Audio stops when you double tap the screen.", comment: "")
        self.voiceList.append(VoiceModel(id: nil, message: msg, priority: 10))
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            _ = self.dequeueSpeak()
        }
    }

    func setupStartingPoint() {
        self.stop()
        let msg = NSLocalizedString("With your smartphone's camera facing forward and upwards, slowly turn left and right, looking for sound guidance.", comment: "")
        self.voiceList.append(VoiceModel(id: nil, message: msg, priority: 10))

        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            _ = self.dequeueSpeak()
        }
    }

    func addGuide(text: String, id: Int? = nil, priority: Int = 10) {
        if text.isEmpty { return }

        if UserDefaults.standard.bool(forKey: "ARMarkerWait") {
            if self.isPlaying {
                return
            }
        }

        var waitTime = 0.0
        
        if self.isPlaying {
            if self.speakingData?.id == id ||
                id == nil {
                // 再生中の同一音声は追加しない
                return
            }
            if let model = voiceList.last,
               model.id != nil,
               id == model.id {
                // 再生中で最後に追加された音声と同一の内容は追加しない
                return
            }
            
            if self.speakedId != nil &&
                self.speakedId == id {
                // 一つ前の中断した音声は即時に再生しない
                return
            }
            
            if UserDefaults.standard.bool(forKey: "ARAudioInterruptDisabled") {
                return
            }
            
            if self.speakingData?.id != id {
                speakedId = self.speakingData?.id
            }

            let temp = speakedId
            self.stop()
            self.speakedId = temp
            self.voiceList.removeAll()
            waitTime = 1.0
        } else if let model = voiceList.last,
                  model.id != nil {

            if id == model.id {
                if lastSpeakTime + 2.0 > Date().timeIntervalSince1970 {
                    return
                }
            } else {
                if lastSpeakTime + 1.0 > Date().timeIntervalSince1970 {
                    return
                }
            }
        } else if self.speakingData?.id == id {
            if id != nil {
                if lastSpeakTime + 2.0 > Date().timeIntervalSince1970 {
                    return
                }
            } else {
                if lastSpeakTime + 1.0 > Date().timeIntervalSince1970 {
                    return
                }
            }
        }
        
        self.voiceList.removeAll()
        self.voiceList.append(VoiceModel(id: id, message: text, priority: priority))
        DispatchQueue.main.asyncAfter(deadline: .now() + waitTime) {
            _ = self.dequeueSpeak()
        }
    }

    func stop() {
        tts.stop(true)
        self.isPlaying = false
        self.speakedId = nil
    }

    func repeatSpeak() {
        if !self.isPlaying,
           let speakingData = self.speakingData {
            self.play(model: speakingData)
        }
    }

    func forcedSpeak(text: String) {
        self.stop()
        self.play(model: VoiceModel(id: nil, message: text, priority: 100))
    }

    private func play(model: VoiceModel) {
        if self.isPlaying { return }

        if self.speakedId == nil {
            self.speakedId = model.id
        }

        self.isPlaying = true
        self.speakingData = model
        tts.speak(model.message, callback: { [weak self] in
            guard let self = self else { return }
            self.isPlaying = false
            self.lastSpeakTime = Date().timeIntervalSince1970
            _ = self.dequeueSpeak()

        })

        if let delegate = delegate {
            delegate.speakingMessage(message: model.message)
        }
    }

    private func dequeueSpeak() -> Bool {
        if self.isPlaying { return false }
//        if UIAccessibility.isVoiceOverRunning { return false }
        if let model = voiceList.first {
            self.play(model: model)
            self.voiceList.removeFirst()
        }
        return true
    }

    func SoundEffect(sound: String, rate: Double, pan: Double, interval: Double) {
//        NSLog("rate: \(rate),  pan: \(pan),  interval: \(interval)" )
        if self.isSoundEffect { return }
        let now = Date().timeIntervalSince1970
        if (soundEffectTime != 0 &&
            soundEffectTime + intervalTime > now) {
            return
        }
        intervalTime = interval

        soundEffectTime = now
        self.isSoundEffect = true

        if let soundURL = Bundle.main.url(forResource: sound, withExtension: "mp3") {
            do {
                player = try AVAudioPlayer(contentsOf: soundURL)
                if let player = player {
                    player.delegate = self
                    player.enableRate = true
                    player.rate = Float(rate)
                    player.pan = Float(pan)
                    player.play()
                }
            } catch {
                print("error")
            }
        }
    }

    @objc private func voiceOverNotification() {
//        NSLog("\(UIAccessibility.isVoiceOverRunning)")
//        if UIAccessibility.isVoiceOverRunning { return }
        _ = dequeueSpeak()
    }
}

extension AudioManager: AVAudioPlayerDelegate {
    public func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        self.isSoundEffect = false
    }
}
