//
//  StrUtil.swift
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

class StrUtil: NSObject {

    // 距離を簡略化数値にする。1m以下はcmで四捨五入の数値
    static public func getMeterString(distance: Double) -> String {
        if distance < 0.95 {
            let distance = Int(round((distance + 0.05) * 10) * 10)
            if distance == 100 {
                return String(format: NSLocalizedString("unit_meter", tableName: "BlindView", comment: ""), 1)
            } else {
                return String(format: NSLocalizedString("unit_centimeter", tableName: "BlindView", comment: ""), distance)
            }
        } else {
            let distance = Int(round(distance))
            return String(format: NSLocalizedString("unit_meter", tableName: "BlindView", comment: ""), distance)
        }
    }

    static public func distanceString(distance: Double) -> String {
        
        let isFeet = UserDefaults.standard.string(forKey: "distance_unit") ?? "unknown" == "unit_feet"

        var measurement = Measurement(value: distance, unit: UnitLength.meters)
        if (isFeet) {
            measurement = measurement.converted(to: .feet)
        }
        
        let distance = measurement.value
        if (isFeet) {
            return String(format: NSLocalizedString("unit_feet", tableName: "BlindView", comment: ""), Int(round(distance)))
        }

        if distance < 0.95 {
            let distance = Int(round((distance + 0.05) * 10) * 10)
            if distance == 100 {
                return String(format: NSLocalizedString("unit_meter", tableName: "BlindView", comment: ""), 1)
            } else {
                return String(format: NSLocalizedString("unit_centimeter", tableName: "BlindView", comment: ""), distance)
            }
        } else {
            return String(format: NSLocalizedString("unit_meter", tableName: "BlindView", comment: ""), Int(round(distance)))
        }
    }

    static public func getClockPosition(angle: Double) -> PhonationModel {
        let phonationModel = PhonationModel()

        let clockPosition = 12 - Int(floor(Double(angle + 15) / 30 )) % 12
        let str = String(format: NSLocalizedString("clock position %@", tableName: "BlindView", comment: ""), String(clockPosition))
        phonationModel.setUp(string: str, phonation: str)
        return phonationModel
    }

    static public func getDirectionString(angle: Double) -> PhonationModel {
        let phonationModel = PhonationModel()
        let HourAngle = Double(360 / 24)

        // 正面 -30 ~ +30 //
        var str = NSLocalizedString("in front of you", tableName: "BlindView", comment: "")
        
        if HourAngle < angle && angle <= HourAngle * 3 {
            // やや左方向 +15 ~ +45 //
            str = NSLocalizedString("slightly to the left", tableName: "BlindView", comment: "")
        } else if HourAngle * 3 < angle && angle <= HourAngle * 5 {
            // 斜め左方向 +45 ~ +75 //
            str = NSLocalizedString("The slant left direction", tableName: "BlindView", comment: "")
        } else if HourAngle * 5 < angle && angle <= HourAngle * 7 {
            // 左方向 +75 ~ +105 //
            str = NSLocalizedString("LEFT_DIRECTION", tableName: "BlindView", comment: "")
        } else if HourAngle * 7 < angle && angle <= HourAngle * 9 {
            // 左斜め後ろ方向 +105 ~ +135 //
            str = NSLocalizedString("LEFT_BACK_DIRECTION", tableName: "BlindView", comment: "")
        } else if HourAngle * 9 < angle && angle <= HourAngle * 11 {
            // 左斜め後ろ方向 +135 ~ +165 //
            str = NSLocalizedString("LEFT_BACK_DIRECTION", tableName: "BlindView", comment: "")
        } else if HourAngle * 11 < angle && angle <= HourAngle * 13 {
            // 後ろ +165 ~ +195 //
            str = NSLocalizedString("BACK_DIRECTION", tableName: "BlindView", comment: "")
        } else if HourAngle * 13 < angle && angle <= HourAngle * 15 {
            // 右斜め後ろ方向 +195 ~ +225 //
            str = NSLocalizedString("RIGHT_BACK_DIRECTION", tableName: "BlindView", comment: "")
        } else if HourAngle * 15 < angle && angle <= HourAngle * 17 {
            // 右斜め後ろ方向 +225 ~ +255 //
            str = NSLocalizedString("RIGHT_BACK_DIRECTION", tableName: "BlindView", comment: "")
        } else if HourAngle * 17 < angle && angle <= HourAngle * 19 {
            // 右方向 +255 ~ +285 //
            str = NSLocalizedString("RIGHT_DIRECTION", tableName: "BlindView", comment: "")
        } else if HourAngle * 19 < angle && angle <= HourAngle * 21 {
            // 斜め右方向 +285 ~ +315 //
            str = NSLocalizedString("The slant right direction", tableName: "BlindView", comment: "")
        } else if HourAngle * 21 < angle && angle <= HourAngle * 23 {
            // やや右方向 +315 ~ +345 //
            str = NSLocalizedString("slightly to the right", tableName: "BlindView", comment: "")
        }
        
        str = NSLocalizedString("PERIOD", comment: "") + str
        phonationModel.setUp(string: str, phonation: str)
        return phonationModel
    }

    static public func getFloorVoiceString(str: String?) -> String? {

        if let str = str {
            var tmpStr = ""
            let array = str.split(separator: " ")
            for data in array {
                var str = String(data)
                for i in -2..<8 {
                    if str == "\(i)F" {
                        str = NSLocalizedString("floor \(i)", tableName: "BlindView", comment: "")
                        break
                    }
                }
                tmpStr += str + " "
            }
            return tmpStr.trimmingCharacters(in: .whitespaces) 
        }
        return nil
    }

}
