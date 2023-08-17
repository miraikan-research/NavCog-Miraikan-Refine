//
//  ArUcoModel.swift
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

enum ARType {
    // ARではない
    case none
    // 入り口案内
    case target
    //
    case exposition
    // 地面
    case floor
    // 展示案内
    case guide
}

struct ArUcoModel: Codable {
    var id: Int
    var marker: Float?
    var markerPoint: Bool?
    var markerInduction: Bool?
    var title: String
    var titleEn: String
    var titleKo: String?
    var titleZh: String?
    var titlePron: String
    var guideToHere: GuidanceModel?
    var guideFromHere: GuidanceModel?
    var nextGuide: GuidanceModel?
    var descriptionTitle: GuidanceModel?
    var description: GuidanceModel?
    var descriptionDetail: GuidanceModel?
    var flatGuide: [GuidanceModel]?
    var soundGuide: Float?
    var comment: String?

    func titleLang(_ lang: String, pron: Bool = false) -> String {
        if lang == "en",
           !titleEn.isEmpty {
            return titleEn
        }
        if lang == "ko",
           let title = titleKo {
            return title
        }
        if lang == "zh",
           let title = titleZh {
            return title
        }
        return pron ? titlePron : title
    }
    
    func getArType() -> ARType {

        if self.markerPoint ?? false {
            return .target
        }

        if let _ = self.flatGuide {
            return .floor
        }
        
        if let _ = self.description {
            return .exposition
        }

        if let _ = self.guideToHere {
            return .guide
        }

        if let _ = self.guideFromHere {
            return .guide
        }

        return .none
    }
}
