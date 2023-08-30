//
//  PhonationModel.swift
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


class PhonationModel {
    // 表示文字列
    var string = ""
    // 発音文字列
    var phonation = ""
    // true:マーカー音声, false:アプリ内部定義音声
    var explanation = false

    private let Delimiter = "\n"

    func setUp(string: String, phonation: String) {
        self.string = string
        self.phonation = phonation
    }

    func append(str: String, phon: String? = nil, isDelimiter: Bool = true) {
        if str.isEmpty {
            return
        }

        if !string.isEmpty && isDelimiter {
            string += Delimiter
        }
        if !phonation.isEmpty && isDelimiter {
            phonation += NSLocalizedString("PERIOD", comment: "")
        }

        string += str
        if let phon = phon {
            phonation += phon
        } else {
            phonation += str
        }
    }

    func append(guidance: VoiceGuideModel?, distance: Double? = nil, isDelimiter: Bool = true) {
        guard let guidance = guidance else { return }

        if !string.isEmpty && isDelimiter {
            string += Delimiter
        }

        if !phonation.isEmpty && isDelimiter {
            phonation += NSLocalizedString("PERIOD", comment: "")
        }

        string += guidance.text(distance: distance)
        phonation += guidance.text(pron: true, distance: distance)
    }

    private func setPhonation(_ phonation: PhonationModel, guidance: VoiceGuideModel?, distance: Double? = nil) {
        phonation.append(guidance: guidance, distance: distance)
    }
}
