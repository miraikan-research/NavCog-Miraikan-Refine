//
//  GuideLanguageModel.swift
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

struct GuideLanguageModel: Codable {
    // 日本語表示用
    var text: String
    // 日本語発音用
    var textPron: String?
    // 英語
    var textEn: String?
    // 韓国語
    var textKo: String?
    // 中国語
    var textZh: String?
    // テキスト内のメートル数値、フィート変換出来るように別定義
    var internalDistance: Double?

    func text(pron: Bool = false, distance: Double? = nil) -> String {
        let lang = NSLocalizedString("lang", comment: "")

        var str = text
        if lang == "en",
           let text = textEn,
           !text.isEmpty {
            str = text
        } else if lang == "ko",
                  let text = textKo,
                  !text.isEmpty {
            str = text
        } else if lang == "zh",
                  let text = textZh,
                  !text.isEmpty {
            str = text
        } else if lang == "ja",
                  pron,
                  let text = textPron,
                  !text.isEmpty {
            // 日本語発音
            str = text
        }

        // 距離単位変換用、別設定
        if let internalDistance = self.internalDistance {
            let internalString = StrUtil.distanceString(distance: internalDistance)
            return String(format: str, internalString)
        } else if let distance = distance {
            let internalString = StrUtil.distanceString(distance: distance)
            return String(format: str, internalString)
        }

        return str
    }
}
