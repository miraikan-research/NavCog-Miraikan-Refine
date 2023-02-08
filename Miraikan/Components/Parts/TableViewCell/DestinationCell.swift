//
//  DestinationCell.swift
//  NavCog3
//
//  Created by yoshizawr204 on 2023/02/07.
//  Copyright © 2023 HULOP. All rights reserved.
//

import UIKit

class DestinationCell: UITableViewCell {
    private let baseView = UIView()
    private let titleLabel = UILabel()
    private let detailLabel = UILabel()
    
    var model: HLPDirectoryItem?

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
        titleLabel.text = model.title
        detailLabel.text = model.subtitle
        self.accessibilityLabel = model.titlePron + NSLocalizedString("PERIOD", comment: "") + model.subtitlePron
        self.accessibilityTraits = .button
    }
}
