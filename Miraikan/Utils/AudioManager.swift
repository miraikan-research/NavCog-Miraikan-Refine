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

// 注視マーカーでの文章進み状態
enum Progress {
    case none
    case title
    case mainText
    case next
    case end
}

protocol AudioManagerDelegate {
    func speakingMessage(speakingData: VoiceModel)
}

protocol AudioManagerSystemDelegate {
    func speakFinish(speakingData: VoiceModel)
}

// Singleton
final public class AudioManager: NSObject {
    
    var delegate: AudioManagerDelegate?
    var systemDelegate: AudioManagerSystemDelegate?

    private let tts = DefaultTTS()
    private(set) var isPlaying = false
    private(set) var isSoundEffect = false

    private var voiceList: [VoiceModel] = []

    private var speakingData: VoiceModel?
    private var reserveData: VoiceModel?
    private var reserveStatus = false
    private var speakedId: Int? // 音声再生中のブレによるマーカー交互の読み取り防止
    private var player: AVAudioPlayer?

    private var lastSpeakTime: Double = 0
    private var soundEffectTime: Double = 0
    private var intervalTime: Double = 0

    // 音声区分の進行状態
    var progress: Progress = .none

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
        msg += NSLocalizedString("Audio stops when you tap the screen.", comment: "")
        self.voiceList.append(VoiceModel(id: nil, voice: msg, message: msg, priority: 10))
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            _ = self.dequeueSpeak()
        }
    }

    func setupStartingPoint() {
        self.stop()
        let msg = NSLocalizedString("With your smartphone's camera facing forward and upwards, slowly turn left and right, looking for sound guidance.", comment: "")
        self.voiceList.append(VoiceModel(id: nil, voice: msg, message: msg, priority: 10))

        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            _ = self.dequeueSpeak()
        }
    }

    func addGuide(voiceModel: VoiceModel, soundEffect: Bool = false) {
        if voiceModel.voice.isEmpty || reserveStatus { return }

        if UserDefaults.standard.bool(forKey: "ARMarkerWait") {
            if self.isPlaying {
                return
            }
        }

        var waitTime = 0.0
        
        if self.isPlaying {
            if self.speakingData?.id == voiceModel.id ||
                voiceModel.id == nil {
                // 再生中の同一音声は追加しない
                return
            }
            if let model = voiceList.last,
               model.id != nil,
               voiceModel.id == model.id {
                // 再生中で最後に追加された音声と同一の内容は追加しない
                return
            }
            
            if self.speakedId != nil &&
                self.speakedId == voiceModel.id {
                // 一つ前の中断した音声は即時に再生しない
                return
            }
            
            if UserDefaults.standard.bool(forKey: "ARAudioInterruptDisabled") {
                return
            }
            
            if self.speakingData?.id != voiceModel.id {
                speakedId = self.speakingData?.id
            }

            let temp = speakedId
            self.stop()
            self.speakedId = temp
            self.voiceList.removeAll()
            waitTime = 1.0
        } else if let model = voiceList.last,
                  model.id != nil {

            if voiceModel.id == model.id {
                // 前回と同じIDの間隔
                if lastSpeakTime + Double(MiraikanUtil.readingInterval) > Date().timeIntervalSince1970 {
                    return
                }
            } else {
                if lastSpeakTime + 1.5 > Date().timeIntervalSince1970 {
                    return
                }
            }
        } else if self.speakingData?.id == voiceModel.id {
            if voiceModel.id != nil {
                // 前回と同じIDの間隔
                if lastSpeakTime + Double(MiraikanUtil.readingInterval) > Date().timeIntervalSince1970 {
                    return
                }
            } else {
                if lastSpeakTime + 1.5 > Date().timeIntervalSince1970 {
                    return
                }
            }
        }
        
        if soundEffect {
            AudioManager.shared.SoundEffect(sound: "SoundEffect51", rate: 1, pan: 0, interval: 0)
            // バイブレーション
            UIImpactFeedbackGenerator(style: .light).impactOccurred()
            if waitTime < 0.5 {
                waitTime += 0.3
            }
        }

        reserveStatus = true
        DispatchQueue.main.asyncAfter(deadline: .now() + waitTime) {
            self.voiceList.removeAll()
            if self.isPlaying &&
                self.reserveData == nil {
                self.reserveData = voiceModel
            } else {
                self.voiceList.append(voiceModel)
                _ = self.dequeueSpeak()
            }
            self.reserveStatus = false
        }
    }

    func stop() {
        tts.stop(true)
        self.speakedId = nil
        self.isPlaying = false
    }

    func pauseToggle(forcedPause: Bool = false) {
        tts.pauseToggle(false, forcedPause:forcedPause)
    }

    func isSpeaking() -> Bool {
        tts.isSpeaking()
    }

    func isPause() -> Bool {
        tts.isPause()
    }
    
    func speechStatus() -> SpeechStatus {
        tts.speechStatus()
    }

    func repeatSpeak() {
        if !self.isPlaying,
           let speakingData = self.speakingData {
            self.play(model: speakingData)
        }
    }

    func forcedSpeak(text: String) {
        let voiceModel = VoiceModel(id: nil, voice: text, message: text, priority: 100)
        if self.isPlaying {
            self.stop()
            reserveData = voiceModel
        } else {
            self.play(model: voiceModel)
        }
    }

    private func play(model: VoiceModel) {
        if self.isPlaying { return }

        if self.speakedId == nil {
            self.speakedId = model.id
        }

        self.isPlaying = true
        self.reserveData = nil
        self.speakingData = model
        
        if UIAccessibility.isVoiceOverRunning &&
            model.id != nil {
            self.isPlaying = false
            self.lastSpeakTime = Date().timeIntervalSince1970
        } else {
            if self.speakingData?.type == .lockGuide {
                progress = .title
            }

            tts.speak(model.voice, callback: { [weak self] in
                guard let self = self else { return }
                if self.speakingData?.type != .lockGuide {
                    self.isPlaying = false
                    self.lastSpeakTime = Date().timeIntervalSince1970
                    
                    if let reserveData = self.reserveData {
                        self.play(model: reserveData)
                    } else {
                        _ = self.dequeueSpeak()
                    }
                }
                
                if let delegate = self.systemDelegate {
                    delegate.speakFinish(speakingData: model)
                }
            })
        }

        if let delegate = delegate {
            delegate.speakingMessage(speakingData: model)
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

    func nextStep() {
//        NSLog("\(URL(string: #file)!.lastPathComponent) \(#function): \(#line) progress: \(progress)")
        if let speakingData = self.speakingData,
           speakingData.type == .lockGuide {

            var internalString: String?
            if let internalDistance = speakingData.descriptionDetail?.internalDistance {
                internalString = StrUtil.distanceString(distance: internalDistance)
            }

            switch progress {
            case .title:
                progress = .mainText
                if let mainText = speakingData.descriptionDetail?.mainText,
                   let mainTextPron = speakingData.descriptionDetail?.mainTextPron {
                    var message = speakingData.message + "\n"
                    var text = ""
                    if let internalString = internalString {
                        message += String(format: mainText, internalString)
                        text = String(format: mainTextPron, internalString)
                    } else {
                        message += mainText
                        text = mainTextPron
                    }
                    tts.speak(text, callback: { [weak self] in
                        guard let self = self else { return }
                        if let delegate = self.systemDelegate {
                            delegate.speakFinish(speakingData: speakingData)
                        }
                    })
                    
                    if let delegate = delegate {
                        delegate.speakingMessage(speakingData: VoiceModel(id: speakingData.id, voice: speakingData.voice + text, message: message, priority: 10))
                    }
                }

            case .mainText:
                progress = .next
                if let nextGuide = speakingData.descriptionDetail?.nextGuidePron {
                    var text = ""
                    if let internalString = internalString {
                        text = String(format: nextGuide, internalString)
                    } else {
                        text = nextGuide
                    }

                    tts.speak(text, callback: { [weak self] in
                        guard let self = self else { return }
                        if let delegate = self.systemDelegate {
                            delegate.speakFinish(speakingData: speakingData)
                        }
                    })
                }

            case .next:
                progress = .end
                self.isPlaying = false
                self.lastSpeakTime = Date().timeIntervalSince1970
                
                if let id = speakingData.id {
                    ArUcoManager.shared.setFinishDate(key: id)
                }

                if let reserveData = self.reserveData {
                    self.play(model: reserveData)
                } else {
                    _ = self.dequeueSpeak()
                }
                
            case .end:
                break

            default:
                self.isPlaying = false
                self.lastSpeakTime = Date().timeIntervalSince1970
                
                if let reserveData = self.reserveData {
                    self.play(model: reserveData)
                } else {
                    _ = self.dequeueSpeak()
                }
            }
        }
    }
    
    func SoundEffect(sound: String, rate: Double, pan: Double, interval: Double) {
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

    func speakingID() -> Int? {
        self.speakingData?.id
    }

    @objc private func voiceOverNotification() {
//        NSLog("\(UIAccessibility.isVoiceOverRunning)")
        if UIAccessibility.isVoiceOverRunning { return }
        _ = dequeueSpeak()
    }
}

extension AudioManager: AVAudioPlayerDelegate {
    public func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        self.isSoundEffect = false
    }
}
