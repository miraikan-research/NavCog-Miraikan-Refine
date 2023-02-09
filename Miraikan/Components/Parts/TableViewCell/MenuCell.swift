//
//  MenuCell.swift
//  NavCog3
//
//  Created by yoshizawr204 on 2023/02/09.
//  Copyright © 2023 HULOP. All rights reserved.
//

import Foundation


class MenuCell: UITableViewCell {
    private let baseView = UIView()
    private let titleLabel = UILabel()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.selectionStyle = .none
        self.isAccessibilityElement = false
        setupBaseView()
        setupTitleLabel()
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
        titleLabel.lineBreakMode = .byClipping
        titleLabel.textColor = .label
        baseView.addSubview(titleLabel)
        
        let desc = UIFontDescriptor.preferredFontDescriptor(withTextStyle: .title3)
        let margin = desc.pointSize/2 + 2
        
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        let leading = titleLabel.leadingAnchor.constraint(equalTo: baseView.leadingAnchor, constant: 0)
        let trailing = titleLabel.trailingAnchor.constraint(equalTo: baseView.trailingAnchor, constant: 0)
        let top = titleLabel.topAnchor.constraint(equalTo: baseView.topAnchor, constant: margin)
        let bottom = titleLabel.bottomAnchor.constraint(equalTo: baseView.bottomAnchor, constant: -margin)
        NSLayoutConstraint.activate([leading, trailing, top, bottom])
    }

    public func configure(_ model: MenuItem) {
        let attrStr = NSMutableAttributedString()
        attrStr.append(NSAttributedString(string:(model.name)))
        
        if let image = UIImage(systemName: "chevron.right") {
            let attachment = NSTextAttachment(image: image)
            attrStr.append(NSAttributedString(string: " "))
            attrStr.append(NSAttributedString(attachment: attachment))
        }
        titleLabel.attributedText = attrStr
        titleLabel.isEnabled = model.isAvailable
        self.selectionStyle = model.isAvailable ? .default : .none
        self.accessibilityLabel = model.isAvailable ? model.name : NSLocalizedString("blank_description", comment: "")
        self.accessibilityTraits = .button
    }
}
