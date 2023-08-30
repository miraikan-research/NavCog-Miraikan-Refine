//
//  GuidanceModel.swift
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

struct GuidanceModel: Codable {
    // 有効最短距離
    var shortDistance: Double?
    // 有効最長距離
    var longDistance: Double?
    // 方向, 床に設置　0:正面, 90:左, 180:後ろ, 270:右
    var direction:  Double?

    var messageLanguage: VoiceGuideModel?
    var titleLanguage: VoiceGuideModel?
    var mainTextLanguage: VoiceGuideModel?
    var nextGuideLanguage: VoiceGuideModel?

    func isDistance(_ distance: Double) -> Bool {
        if let shortDistance = shortDistance,
           let longDistance = longDistance {
            if shortDistance < distance && distance < longDistance {
                return true
            }
        } else {
            return true
        }
        return false
    }

    func message(pron: Bool = false, distance: Double? = nil) -> String {
        if let messageLanguage = messageLanguage {
            return messageLanguage.text(pron: pron, distance: distance)
        }
        return ""
    }

    func unionMessage(pron: Bool = false) -> String {
        var message = ""
        
        if let text = self.titleLanguage {
            message += text.text(pron: pron)
        }

        if let text = self.mainTextLanguage {
            message += text.text(pron: pron)
        }

        if let text = self.nextGuideLanguage {
            message += text.text(pron: pron)
        }

        return message
    }
}
