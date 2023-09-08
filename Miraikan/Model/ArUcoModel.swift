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
    // 展示案内
    case exposition
    // 地面
    case floor
    // 移動の案内（展示説明無し）
    case guide
    // マーカー注視音声
    case lockGuide
}

// デフォルトARマーカーサイズ(cm)
let DefultMarkerSize: Float = 10

struct ArUcoModel: Codable {
    var id: Int
    // マーカーサイズ(相対距離算出用)
    var markerSize: Float?
    // 目標マーカー
    var markerPoint: Bool?
    // 音で誘導マーカー
    var markerInduction: Bool?
    // 注視マーカー
    var maintainingMarker: Bool?
    // 施設名
    var titleLanguage: GuideLanguageModel?
    // マーカー位置に誘導
    var guideToHere: GuidanceModel?
    // マーカー位置から次へ誘導
    var guideFromHere: GuidanceModel?
    // 次の案内
    var nextGuide: GuidanceModel?
    // 案内文章のタイトル
    var descriptionTitle: GuidanceModel?
    // 案内本文
    var description: GuidanceModel?
    // 案内本文詳細、ARマーカーを読み取った後に個別にセルを選択すると、AR読み取り時よりも詳細な内容で案内する仕様
    var descriptionDetail: GuidanceModel?
    // 床マーカー
    var flatGuide: [GuidanceModel]?
    // 0:正面から音が聞こえる, 1:右から音が聞こえる, -1:左から音が聞こえる
    var soundGuide: Float?
    // 管理用コメント
    var comment: String?

    func title(pron: Bool = false) -> String {
        if let text = self.titleLanguage {
            return text.text(pron: pron)
        }
        return ""
    }

    func getMarkerSize() -> Float {
        return markerSize ?? DefultMarkerSize
    }

    func getArType() -> ARType {

        if self.maintainingMarker ?? false &&
            !UserDefaults.standard.bool(forKey: "ARCameraLockMarker") {
            return .lockGuide
        }

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
