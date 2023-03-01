//
//  RouteMode.swift
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

/**
 Caution: This is related to but not the same as the modes in NavCog3
 */
enum RouteMode: String, CaseIterable {
    case general
    case wheelchair
    case stroller
    case blind
    
    var description: String {
        switch self {
        case .general:
            return NSLocalizedString("user_general", comment: "")
        case .wheelchair:
            return NSLocalizedString("user_wheelchair", comment: "")
        case .stroller:
            return NSLocalizedString("user_stroller", comment: "")
        case .blind:
            return NSLocalizedString("user_blind", comment: "")
        }
    }

    var rawInt: Int {
        switch self {
        case .general:
            return 1
        case .wheelchair:
            return 2
        case .stroller:
            return 3
        case .blind:
            return 9
        }
    }
}
