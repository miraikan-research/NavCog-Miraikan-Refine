//
//  ArUcoManager.swift
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
final public class ArUcoManager: NSObject {
    
    public static let shared = ArUcoManager()

    // ARマーカー基準サイズ(m)
    let ArucoMarkerSize: Float = 0.1;

    var arUcoList: [ArUcoModel] = []
    private var activeSettings: Dictionary<String, Bool> = [:]
    private var activeDateList: Dictionary<String, Date> = [:]

    private var lang = ""
    private var userKey = "arUcoSettingKey"

    private override init() {
        super.init()
        lang = NSLocale.preferredLanguages.first?.components(separatedBy: "-").first ?? "ja"
        initArUcoModel()
        loadActiveSettings()
    }

    func initArUcoModel() {
        if let arUcoList = MiraikanUtil.readJSONFile(filename: "ArUco",
                                                     type: [ArUcoModel].self) as? [ArUcoModel] {
            self.arUcoList = arUcoList
            
#if targetEnvironment(simulator)
            for arUcoModel in self.arUcoList {
                if let description = arUcoModel.description {
                    print("\(arUcoModel.id), \(description.message.trimmingCharacters(in: .newlines))")
                }
            }
#endif

        }
    }

    func getMarkerSizeRatio(arUcoModel: ArUcoModel) -> Double {
        var ratio: Double = 1
        if let markerSize = arUcoModel.marker {
            ratio = Double((markerSize / 100) / ArucoMarkerSize)
        }
        return ratio
    }
    
    func loadActiveSettings() {
        if let activeSettings = UserDefaults.standard.dictionary(forKey: userKey) as? Dictionary<String, Bool> {
            self.activeSettings = activeSettings
        } else {
            self.activeSettings = [:]
        }
    }
    
    func setActiveSettings(key: Int, value: Bool) {
        let strKey = String(key)
        self.activeSettings[strKey] = value
        UserDefaults.standard.set(self.activeSettings, forKey: userKey)
    }

    func checkActiveSettings(key: Int, timeCheck: Bool = false) -> Bool {
        let strKey = String(key)
        if timeCheck {
            if self.activeDateList.keys.contains(strKey),
               let date = activeDateList[strKey] {
                let dayChecker = Date(timeIntervalSinceNow: -60 * 3)
                if dayChecker < date {
                    return false
                }
            }
        }
        
        if self.activeSettings.keys.contains(strKey) {
            return self.activeSettings[strKey] ?? true
        }
        return true
    }

    func setActiveDate(key: Int) {
        let strKey = String(key)
        self.activeDateList[strKey] = Date()
    }
}
