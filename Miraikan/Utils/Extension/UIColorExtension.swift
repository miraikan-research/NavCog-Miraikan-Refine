//
//
//  UIColorExtension.swift
//  NavCogMiraikan
//
/*******************************************************************************
 * Copyright (c) 2022 © Miraikan - The National Museum of Emerging Science and Innovation  
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
import UIKit

extension UIColor {
    func createColorImage() -> UIImage {
        let rect = CGRect(x: 0, y: 0, width: 1, height: 1)
        UIGraphicsBeginImageContext(rect.size)
        guard let context = UIGraphicsGetCurrentContext() else { assertionFailure(); return UIImage() }
        context.setFillColor(self.cgColor)
        context.fill(rect)
        guard let image: UIImage = UIGraphicsGetImageFromCurrentImageContext() else { assertionFailure(); return UIImage() }
        UIGraphicsEndImageContext()
        return image
    }
    
    static func getColor(darkColor: UIColor, lightColor: UIColor) -> UIColor {
        return UIColor { traitCollection  in
            return traitCollection.userInterfaceStyle == .dark ? darkColor : lightColor
        }
    }
    
    static let mapButtonBorderColor = UIColor(red: 105/255, green: 0, blue: 50/255, alpha: 1)
    static let mapButtonBorderDarkColor = UIColor(red: 178/255, green: 34/255, blue: 24/255, alpha: 1)
    static var mapButtonBorderExchangeColor: UIColor {
        getColor(darkColor: .mapButtonBorderDarkColor, lightColor: .mapButtonBorderColor)
    }
    
    static let arListBackgroundColor = UIColor(red: 232/255, green: 255/255, blue: 255/255, alpha: 1)
    static let arListBackgroundDarkColor = UIColor(red: 32/255, green: 32/255, blue: 32/255, alpha: 1)
    static var arListBackgroundExchangeColor: UIColor {
        getColor(darkColor: .arListBackgroundDarkColor, lightColor: .arListBackgroundColor)
    }
    
    static let arCellActiveColor = UIColor(red: 255/255, green: 255/255, blue: 160/255, alpha: 1)
    static let arCellActiveDarkColor = UIColor(red: 80/255, green: 80/255, blue: 88/255, alpha: 1)
    static var arCellActiveExchangeColor: UIColor {
        getColor(darkColor: .arCellActiveDarkColor, lightColor: .arCellActiveColor)
    }
    
    static let arCellPassiveColor = UIColor(red: 211/255, green: 211/255, blue: 211/255, alpha: 1)
    static let arCellPassiveDarkColor = UIColor(red: 48/255, green: 48/255, blue: 54/255, alpha: 1)
    static var arCellPassiveExchangeColor: UIColor {
        getColor(darkColor: .arCellPassiveDarkColor, lightColor: .arCellPassiveColor)
    }

    static let arDetailBackgroundColor = UIColor(red: 232/255, green: 255/255, blue: 255/255, alpha: 1)
    static let arDetailBackgroundDarkColor = UIColor(red: 48/255, green: 48/255, blue: 54/255, alpha: 1)
    static var arDetailBackgroundExchangeColor: UIColor {
        getColor(darkColor: .arDetailBackgroundDarkColor, lightColor: .arDetailBackgroundColor)
    }

}
