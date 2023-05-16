//
//  ARGuideRow.swift
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

import UIKit

class ARGuideRow: UITableViewCell {
    private let baseView = UIView()
    private let titleLabel = UILabel()
    
    var model: VoiceModel?
    var enabled = true

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.selectionStyle = .none
        self.backgroundColor = .clear
        
        titleLabel.isAccessibilityElement = true
        setupBaseView()
        setupTitleLabel()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupBaseView() {
        contentView.addSubview(baseView)
        
        baseView.backgroundColor = UIColor(red: 255/255, green: 255/255, blue: 80/255, alpha: 1)
        baseView.layer.cornerRadius = 16

        baseView.translatesAutoresizingMaskIntoConstraints = false
        let widthConstraint = baseView.widthAnchor.constraint(equalTo: contentView.widthAnchor, multiplier: 0.9)
        let centerXConstraint = baseView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor)
        let top = baseView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 6)
        let bottom = baseView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -6)
        NSLayoutConstraint.activate([widthConstraint, top, bottom, centerXConstraint])
    }

    private func setupTitleLabel() {
        titleLabel.font = .preferredFont(forTextStyle: .title3)
        titleLabel.numberOfLines = 0
        titleLabel.textColor = .label
        titleLabel.lineBreakMode = .byTruncatingTail
        baseView.addSubview(titleLabel)
        
        let desc = UIFontDescriptor.preferredFontDescriptor(withTextStyle: .title3)
        let margin = desc.pointSize / 2
        
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        let leading = titleLabel.leadingAnchor.constraint(equalTo: baseView.leadingAnchor, constant: margin)
        let trailing = titleLabel.trailingAnchor.constraint(equalTo: baseView.trailingAnchor, constant: -margin)
        let top = titleLabel.topAnchor.constraint(equalTo: baseView.topAnchor, constant: margin)
        let bottom = titleLabel.bottomAnchor.constraint(equalTo: baseView.bottomAnchor, constant: -margin)
        NSLayoutConstraint.activate([leading, trailing, top, bottom])
    }

    public func configure(_ model: VoiceModel, lines: Int = 0) {
        self.model = model
        titleLabel.text = model.message
        titleLabel.numberOfLines = lines
        titleLabel.accessibilityLabel = model.voice

        baseView.backgroundColor = lines == 0 ? UIColor(red: 255/255, green: 255/255, blue: 160/255, alpha: 1) : UIColor(red: 211/255, green: 211/255, blue: 211/255, alpha: 1)
    }
}
