//
//  VoiceGuideRow.swift
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

class VoiceGuideRow : BaseRow {
    
    private let lblDescription = AutoWrapLabel()

    private let gapX: CGFloat = 20
    private let gapY: CGFloat = 10

    // MARK: init
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        self.accessibilityElementsHidden = true
        lblDescription.accessibilityElementsHidden = true
        addSubview(lblDescription)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        lblDescription.text = nil
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()

        let descSize = CGSize(width: innerSize.width - gapX * 2,
                              height: lblDescription.intrinsicContentSize.height + gapY * 2)
        lblDescription.frame = CGRect(x: insets.left + gapX,
                                      y: insets.top + gapY,
                                      width: innerSize.width - gapX * 2,
                                      height: lblDescription.sizeThatFits(descSize).height)
    }
    
    override func sizeThatFits(_ size: CGSize) -> CGSize {
        let descSize = CGSize(width: innerSizing(parentSize: size).width,
                              height: lblDescription.intrinsicContentSize.height)
        let totalHeight = insets.top + gapY
        + lblDescription.sizeThatFits(descSize).height + gapY
        + insets.bottom
        return CGSize(width: size.width, height: totalHeight)
    }

    /**
     Set data from DataSource
     */
    public func configure(title: String) {
        lblDescription.text = title
        lblDescription.sizeToFit()
    }
}
