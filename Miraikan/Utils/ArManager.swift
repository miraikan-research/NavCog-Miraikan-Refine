//
//  ArManager.swift
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

// Singleton
final public class ArManager: NSObject {
    
    public static let shared = ArManager()

    var arFrameSize: CGSize?

    private var guideSoundTime: Double = 0
    private var markerCenterFlag = false

    private var checkMarkerTime: Double = 0
    private var flatGuideTime: Double = 0

    private let widthBaseRatio: Double = 100
    private let widthMinCenterRatio: Double = 10
    private let widthMaxCenterRatio: Double = 25
    private let widthMinMarginRatio: Double = 20
    private let widthMaxMarginRatio: Double = 40

    private let longRange: Double = 10
    
    enum arType {
        case target
        case exposition
        case floor
        case guide
        case unknown
    }

    private override init() {
        super.init()
    }

    func setArFrameSize(arFrameSize: CGSize?) {
        self.arFrameSize = arFrameSize
    }
    
    func setSpeakStr(arUcoModel: ArUcoModel, transform: MarkerWorldTransform, isDebug: Bool = false) -> PhonationModel {
        
        let ratio = ArUcoManager.shared.getMarkerSizeRatio(arUcoModel: arUcoModel)
        let distance = Double(transform.distance) * ratio
        let horizontalDistance = Double(transform.horizontalDistance) * ratio
        let direction = Double(transform.yaw)
        let meterString = StrUtil.distanceString(distance: distance)

//        NSLog("id: \(transform.arucoId), ratio: \(ratio), distance: \(distance), horizontalDistance: \(horizontalDistance),  x: \(direction)")

        let phonationModel = PhonationModel()

        if let guideToHere = arUcoModel.guideToHere,
           guideToHere.isDistance(distance) || isDebug {
            
            if let internalDistance = guideToHere.internalDistance {
                let internalString = StrUtil.distanceString(distance: internalDistance)
                setPhonation(phonationModel, strParam: internalString, guidance: guideToHere)
            } else {
                setPhonation(phonationModel, strParam: meterString, guidance: guideToHere)
            }
        }
        
        if let description = arUcoModel.description {
            if description.isDistance(distance) || isDebug {
                if let descriptionTitle = arUcoModel.descriptionTitle,
                   descriptionTitle.isDistance(distance) {
                    if let internalDistance = descriptionTitle.internalDistance {
                        let internalString = StrUtil.distanceString(distance: internalDistance)
                        setPhonation(phonationModel, strParam: internalString, guidance: descriptionTitle)
                    } else {
                        setPhonation(phonationModel, strParam: meterString, guidance: descriptionTitle)
                    }
                }
                if let internalDistance = description.internalDistance {
                    let internalString = StrUtil.distanceString(distance: internalDistance)
                    setPhonation(phonationModel, strParam: internalString, guidance: description)
                } else {
                    setPhonation(phonationModel, strParam: meterString, guidance: description)
                }
                phonationModel.explanation = true
            }

            if let nextGuide = arUcoModel.nextGuide,
               nextGuide.isDistance(distance) || isDebug {
                if let internalDistance = nextGuide.internalDistance {
                    let internalString = StrUtil.distanceString(distance: internalDistance)
                    setPhonation(phonationModel, strParam: internalString, guidance: nextGuide)
                } else {
                    setPhonation(phonationModel, strParam: meterString, guidance: nextGuide)
                }
            }

            if let guideFromHere = arUcoModel.guideFromHere,
               guideFromHere.isDistance(distance) || isDebug {
                if let internalDistance = guideFromHere.internalDistance {
                    let internalString = StrUtil.distanceString(distance: internalDistance)
                    setPhonation(phonationModel, strParam: internalString, guidance: guideFromHere)
                } else {
                    setPhonation(phonationModel, strParam: meterString, guidance: guideFromHere)
                }
            }
        }

        if (arUcoModel.markerPoint ?? false) && isDebug && !arUcoModel.title.isEmpty {
            let str = String(format: NSLocalizedString("%1$@ to the entrance of %2$@", comment: ""),
                             meterString,
                             NSLocalizedString("lang", comment: "") == "ja" ? arUcoModel.titlePron : arUcoModel.titleEn)
            phonationModel.append(str: str)
        }

        if !isGuideMarker() {
            if let flatGuideList = arUcoModel.flatGuide,
               distance < 3.0 {
                if horizontalDistance > 0.9 {
                    
                    let now = Date().timeIntervalSince1970
                    var msg = ""
                    if let arFrameSize = arFrameSize {
                        if arFrameSize.height * 2 / 5 > transform.intersection.y {
                            msg += NSLocalizedString("Turn to the right a little", comment: "")
                            msg += NSLocalizedString("PERIOD", comment: "")
                        } else if arFrameSize.height * 3 / 5 < transform.intersection.y {
                            msg += NSLocalizedString("Turn to the left a little", comment: "")
                            msg += NSLocalizedString("PERIOD", comment: "")
                        } else {
                            UISelectionFeedbackGenerator().selectionChanged()
                        }
                        msg += NSLocalizedString("please proceed slowly.", comment: "")
                    }
                    
                    if flatGuideTime + 5.0 < Date().timeIntervalSince1970 {
                        phonationModel.append(str: msg, phon: msg, isDelimiter: false)
                        flatGuideTime = now
                    }
                } else {
                    for flatGuide in flatGuideList {
                        if let targetDirection = flatGuide.direction {
                            let directionStr = getDirectionString(direction: targetDirection, currentDirection: direction)
                            phonationModel.append(str: directionStr.string, phon: directionStr.phonation, isDelimiter: false)

                            if let internalDistance = flatGuide.internalDistance {
                                let internalString = StrUtil.distanceString(distance: internalDistance)
                                setPhonation(phonationModel, strParam: internalString, guidance: flatGuide)
                            } else {
                                setPhonation(phonationModel, guidance: flatGuide)
                            }
                        }
                    }
                }
            }
        }

        if !AudioManager.shared.isPlaying,
           let markerInduction = arUcoModel.markerInduction,
           markerInduction {
            setSoundEffect(arUcoModel: arUcoModel, transform: transform, isEntrance: false)
        }

        return phonationModel
    }

    // 地面AR
    func setFlatSoundEffect(arUcoModel: ArUcoModel, transform: MarkerWorldTransform) {
        let ratio = ArUcoManager.shared.getMarkerSizeRatio(arUcoModel: arUcoModel)
        let distance = Double(transform.distance) * ratio

        if let _ = arUcoModel.flatGuide,
           distance < 3.0 {

            guard let arFrameSize = arFrameSize else {
                return
            }

            var rate: Double = -1
            var pan: Double = 0
            var interval: Double = 0

            // 中央判定
            let centerRatio = (widthMaxCenterRatio - widthMinCenterRatio) / longRange * distance + widthMinCenterRatio
            let minCenterRange = (widthBaseRatio - centerRatio) / 2
            let maxCenterRange = widthBaseRatio - minCenterRange
            
            // 中央近く判定
            let marginRatio = (widthMaxMarginRatio - widthMinMarginRatio) / longRange * distance + widthMinMarginRatio
            let minMarginRange = (widthBaseRatio - marginRatio) / 2
            let maxnMarginRange = widthBaseRatio - minMarginRange

            if arFrameSize.height * minCenterRange / widthBaseRatio  < transform.intersection.y &&
                arFrameSize.height * maxCenterRange / widthBaseRatio > transform.intersection.y {
                // 中央
            } else if arFrameSize.height * minMarginRange / widthBaseRatio < transform.intersection.y &&
                    arFrameSize.height * maxnMarginRange / widthBaseRatio > transform.intersection.y {
                // 中央近く高速音
                rate = 2
                pan = 0.3
                interval = 0
            } else {
                
                let width = arFrameSize.height / 2
                let baseWidth: Double = arFrameSize.height * minMarginRange / widthBaseRatio
                if width < transform.intersection.y {
                    pan = Double(transform.intersection.y - width) / baseWidth
                } else {
                    pan = Double(width - transform.intersection.y) / baseWidth
                }
                
                if pan < 0.0 { pan = 0.0 }
                if pan > 1.0 { pan = 1.0 }
                interval = pan * 0.8
                rate = 2 - pan * 0.3
            }

            if rate > 2.0 { rate = 2.0 }
            if interval > 2.0 { interval = 2.0 }

            // right or left
            if arFrameSize.height / 2 < transform.intersection.y {
                pan = -1 * pan
            }

            if rate > 0 &&
                !AudioManager.shared.isSoundEffect {
                AudioManager.shared.SoundEffect(sound: "SoundEffect02", rate: rate, pan: pan, interval: interval)
            }
        }
    }
    
    func setSoundEffect(arUcoModel: ArUcoModel, transform: MarkerWorldTransform, isEntrance: Bool) {
        guard let arFrameSize = arFrameSize else {
            return
        }

        let ratio = ArUcoManager.shared.getMarkerSizeRatio(arUcoModel: arUcoModel)
        let distance = Double(transform.distance) * ratio

        if distance < 1.2 && !arUcoModel.title.isEmpty && isEntrance {
            let str = String(format: NSLocalizedString("Entrance to %@.", comment: ""),
                             NSLocalizedString("lang", comment: "") == "ja" ? arUcoModel.title : arUcoModel.titleEn)
            let voice = String(format: NSLocalizedString("Entrance to %@.", comment: ""),
                               NSLocalizedString("lang", comment: "") == "ja" ? arUcoModel.titlePron : arUcoModel.titleEn)
            
            AudioManager.shared.addGuide(voiceModel: VoiceModel(id: arUcoModel.id, voice: voice, message: str, descriptionDetail: arUcoModel.descriptionDetail, priority: 10))
            return
        }

        var rate: Double = -1
        var pan: Double = 0
        var interval: Double = 0

        if let soundGuide = arUcoModel.soundGuide {
            if distance > 2.5 &&
                !AudioManager.shared.isSoundEffect {
                rate = 1
                if soundGuide != 0 {
                    pan = soundGuide < 1 ? -1 : 1
                }
                interval = 1
                AudioManager.shared.SoundEffect(sound: "SoundEffect02", rate: rate, pan: pan, interval: interval)
            }
            return
        }

        let now = Date().timeIntervalSince1970
        checkMarkerTime = now

        // 中央判定
        let centerRatio = (widthMaxCenterRatio - widthMinCenterRatio) / longRange * distance + widthMinCenterRatio
        let minCenterRange = (widthBaseRatio - centerRatio) / 2
        let maxCenterRange = widthBaseRatio - minCenterRange
        
        // 中央近く判定
        let marginRatio = (widthMaxMarginRatio - widthMinMarginRatio) / longRange * distance + widthMinMarginRatio
        let minMarginRange = (widthBaseRatio - marginRatio) / 2
        let maxnMarginRange = widthBaseRatio - minMarginRange

        if arFrameSize.height * minCenterRange / widthBaseRatio  < transform.intersection.y &&
            arFrameSize.height * maxCenterRange / widthBaseRatio > transform.intersection.y {
            // 中央
            UISelectionFeedbackGenerator().selectionChanged()

            if !markerCenterFlag &&
                !AudioManager.shared.isSoundEffect {
                AudioManager.shared.SoundEffect(sound: "SoundEffect01", rate: 2, pan: 0, interval: 0)
                guideSoundTime = now
                markerCenterFlag = true
            } else if guideSoundTime != 0 &&
                        guideSoundTime + 1.0 < now &&
                        !arUcoModel.title.isEmpty &&
                        isEntrance {
                guideSoundTime = now + 10.0
                markerCenterFlag = true

                let meterString = StrUtil.distanceString(distance: distance)
                let str = String(format: NSLocalizedString("%1$@ to the entrance of %2$@", comment: ""),
                                 meterString,
                                 NSLocalizedString("lang", comment: "") == "ja" ? arUcoModel.title : arUcoModel.titleEn)
                let voice = String(format: NSLocalizedString("%1$@ to the entrance of %2$@", comment: ""),
                                 meterString,
                                 NSLocalizedString("lang", comment: "") == "ja" ? arUcoModel.titlePron : arUcoModel.titleEn)
                AudioManager.shared.addGuide(voiceModel: VoiceModel(id: arUcoModel.id, voice: voice, message: str, descriptionDetail: arUcoModel.descriptionDetail, priority: 10))
            }
            return
        } else if arFrameSize.height * minMarginRange / widthBaseRatio < transform.intersection.y &&
                arFrameSize.height * maxnMarginRange / widthBaseRatio > transform.intersection.y {
            // 中央近く高速音
            rate = 2
            pan = 0.3
            interval = 0
        } else {
            
            let width = arFrameSize.height / 2
            let baseWidth: Double = arFrameSize.height * minMarginRange / widthBaseRatio
            if width < transform.intersection.y {
                pan = Double(transform.intersection.y - width) / baseWidth
            } else {
                pan = Double(width - transform.intersection.y) / baseWidth
            }
            
            if pan < 0.0 { pan = 0.0 }
            if pan > 1.0 { pan = 1.0 }
            interval = pan * 0.8
            rate = 2 - pan * 0.3
        }

        if rate > 2.0 { rate = 2.0 }
        if interval > 2.0 { interval = 2.0 }

        // right or left
        if arFrameSize.height / 2 < transform.intersection.y {
            pan = -1 * pan
        }

        if rate > 0 &&
            !AudioManager.shared.isSoundEffect {
            AudioManager.shared.SoundEffect(sound: "SoundEffect02", rate: rate, pan: pan, interval: interval)
            markerCenterFlag = false
            guideSoundTime = 0
        }
    }

    private func isGuideMarker() -> Bool {
        if checkMarkerTime + 1.0 > Date().timeIntervalSince1970 {
            return true
        }

        return false
    }

    private func getDirectionString(direction: Double, currentDirection: Double) -> PhonationModel {
        var angle = direction + currentDirection - 90
        angle = angle.remainder(dividingBy: 360.0)
        angle = angle < 0 ? angle + 360 : angle
        return StrUtil.getDirectionString(angle: angle)
    }

    private func setPhonation(_ phonation: PhonationModel, strParam: String? = nil, guidance: GuidanceModel) {
        if NSLocale.preferredLanguages.first?.components(separatedBy: "-").first == "ja" {
            if let strParam = strParam {
                phonation.append(str: String(format: guidance.message, strParam), phon: String(format: guidance.messagePron, strParam))
            } else {
                phonation.append(str: guidance.message, phon: guidance.messagePron)
            }
        } else {
            if let strParam = strParam {
                phonation.append(str: String(format: guidance.messageEn, strParam))
            } else {
                phonation.append(str: guidance.messageEn)
            }
        }
    }

    func getArType(_ arUcoModel: ArUcoModel) -> arType {

        if arUcoModel.markerPoint ?? false {
            return .target
        }

        if let _ = arUcoModel.flatGuide {
            return .floor
        }
        
        if let _ = arUcoModel.description {
            return .exposition
        }

        if let _ = arUcoModel.guideToHere {
            return .guide
        }
        if let _ = arUcoModel.guideFromHere {
            return .guide
        }

        return .unknown
    }
}
