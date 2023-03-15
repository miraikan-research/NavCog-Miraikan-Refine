//
//  DestinationCell.swift
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

class DestinationCell: UITableViewCell {
    private let baseView = UIView()
    private let titleLabel = UILabel()
    private let detailLabel = UILabel()
    
    var model: HLPDirectoryItem?
    var enabled = true

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.selectionStyle = .none
        titleLabel.isAccessibilityElement = false
        detailLabel.isAccessibilityElement = false
        setupBaseView()
        setupTitleLabel()
        setupDetailLabel()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupBaseView() {
        contentView.addSubview(baseView)

        baseView.translatesAutoresizingMaskIntoConstraints = false
        let widthConstraint = baseView.widthAnchor.constraint(equalTo: contentView.widthAnchor, multiplier: 0.9)
        let heightConstraint = baseView.heightAnchor.constraint(equalTo: contentView.heightAnchor)
        let centerXConstraint = baseView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor)
        let centerYConstraint = baseView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor)
        NSLayoutConstraint.activate([widthConstraint, heightConstraint, centerXConstraint, centerYConstraint])
    }

    private func setupTitleLabel() {
        titleLabel.font = .preferredFont(forTextStyle: .title3)
        titleLabel.numberOfLines = 0
        titleLabel.textColor = .label
        baseView.addSubview(titleLabel)
        
        let desc = UIFontDescriptor.preferredFontDescriptor(withTextStyle: .title3)
        let margin = desc.pointSize/2 + 2
        
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        let leading = titleLabel.leadingAnchor.constraint(equalTo: baseView.leadingAnchor, constant: 0)
        let top = titleLabel.topAnchor.constraint(equalTo: baseView.topAnchor, constant: margin)
        let bottom = titleLabel.bottomAnchor.constraint(equalTo: baseView.bottomAnchor, constant: -margin)
        let widthConstraint = titleLabel.widthAnchor.constraint(equalTo: baseView.widthAnchor, multiplier: 0.6)
        NSLayoutConstraint.activate([leading, top, bottom, widthConstraint])
    }

    private func setupDetailLabel() {
        detailLabel.font = .preferredFont(forTextStyle: .subheadline)
        detailLabel.textAlignment = .right
        detailLabel.textColor = .secondaryLabel
        detailLabel.numberOfLines = 0
        baseView.addSubview(detailLabel)

        let desc = UIFontDescriptor.preferredFontDescriptor(withTextStyle: .subheadline)
        let margin = desc.pointSize/2 + 2

        detailLabel.translatesAutoresizingMaskIntoConstraints = false
        let leading = detailLabel.leadingAnchor.constraint(equalTo: titleLabel.trailingAnchor, constant: 0)
        let trailing = detailLabel.trailingAnchor.constraint(equalTo: baseView.trailingAnchor, constant: 0)
        let top = detailLabel.topAnchor.constraint(equalTo: baseView.topAnchor, constant: margin)
        let bottom = detailLabel.bottomAnchor.constraint(equalTo: baseView.bottomAnchor, constant: -margin)
        NSLayoutConstraint.activate([leading, trailing, top, bottom])
    }

    public func configure(_ model: HLPDirectoryItem) {
        self.model = model
        var title = model.title
        var subtitle = model.subtitle

        self.enabled = true
        if let navDataStore = NavDataStore.shared(),
           let destination = navDataStore.destination(byID: model.nodeID),
           let landmark = destination.landmark {
            self.enabled = !landmark.disabled
        }
        titleLabel.isEnabled = self.enabled

        titleLabel.text = title
        detailLabel.text = subtitle

        if let titlePron = model.titlePron {
            title = titlePron
        }
        if let subtitlePron = model.subtitlePron {
            subtitle = subtitlePron
        }

        subtitle = StrUtil.getFloorVoiceString(str: subtitle)

        let destination = (title ?? "") + NSLocalizedString("PERIOD", comment: "") + (subtitle ?? "")
        if self.enabled {
            self.accessibilityLabel = String(format: NSLocalizedString("Guide to %@", comment: ""), destination)
            self.accessibilityTraits = .button
        } else {
            self.accessibilityLabel = String(format: NSLocalizedString("can't guide to %@", comment: ""), destination)
            self.accessibilityTraits = .none
        }
    }
}
