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
    var shortDistance: Double?
    var longDistance: Double?
    var direction:  Double?
    var message: String
    var messageEn: String
    var messageKo: String?
    var messageZh: String?
    var messagePron: String
    var internalDistance: Double?

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

    func messageLang(_ lang: String, pron: Bool = false) -> String {
        if lang == "en",
           !messageEn.isEmpty {
            return messageEn
        }
        if lang == "ko",
            let message = messageKo {
            return message
        }
        if lang == "zh",
            let message = messageZh {
            return message
        }
        return pron ? messagePron : message
    }
}
