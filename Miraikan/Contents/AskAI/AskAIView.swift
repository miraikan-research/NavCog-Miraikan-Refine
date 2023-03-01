//
//  AskAIView.swift
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

import UIKit

/**
 The view to show before AI Dialog starts and after it ends
 */
class AskAIView: BaseView {
    
    private let btnStart = StyledButton()
    private let lblDesc = AutoWrapLabel()
    
    var openAction : (()->())?
    
    var isAvailable : Bool? {
        didSet {
            guard let isAvailable = isAvailable else { return }
            
            btnStart.isEnabled = isAvailable
            if isAvailable {
                btnStart.setTitle(NSLocalizedString("ai_available", comment: ""), for: .normal)
                btnStart.setTitleColor(.systemBlue, for: .normal)
            } else {
                btnStart.setTitle(NSLocalizedString("ai_not_available", comment: ""), for: .disabled)
                btnStart.setTitleColor(.lightText, for: .disabled)
            }
            btnStart.sizeToFit()
        }
    }
    
    override func setup() {
        super.setup()
        
        btnStart.tapAction { [weak self] _ in
            guard let self = self else { return }
            if let _f = self.openAction {
                _f()
            }
        }
        addSubview(btnStart)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        btnStart.frame = CGRect(x: (self.frame.width - btnStart.frame.width) / 2,
                                y: (self.frame.height - btnStart.frame.height) / 2,
                                width: btnStart.frame.width,
                                height: btnStart.frame.height)
    }
}
