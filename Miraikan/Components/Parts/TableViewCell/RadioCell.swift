//
//  RadioCell.swift
//  NavCog3
//
//  Created by yoshizawr204 on 2023/02/09.
//  Copyright © 2023 HULOP. All rights reserved.
//

import Foundation


class RadioCell: UITableViewCell {
    private let baseView = UIView()
    private let baseButton = UIButton()
    private let titleLabel = UILabel()
    private let radioImage = UIImageView()

    private var action: (()->())?

    private var value = ""
    private var group = ""

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.selectionStyle = .none
        self.isAccessibilityElement = false
        setupBaseView()
        setupBaseButton()
        setImage()
        setupImageView()
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

    private func setupBaseButton() {
        contentView.addSubview(baseButton)
        
        baseButton.translatesAutoresizingMaskIntoConstraints = false
        let leading = baseButton.leadingAnchor.constraint(equalTo: contentView.leadingAnchor)
        let trailing = baseButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor)
        let top = baseButton.topAnchor.constraint(equalTo: contentView.topAnchor)
        let bottom = baseButton.bottomAnchor.constraint(equalTo: contentView.bottomAnchor)
        NSLayoutConstraint.activate([leading, trailing, top, bottom])
        
        baseButton.addTarget(self,
                             action: #selector(tapAction),
                             for: .touchUpInside)
    }

    private func setImage() {
        let check = UserDefaults.standard.string(forKey: "RouteMode") ?? "unknown" == value
        let imgName = check ? "icons8-checked-radio-button" : "icons8-unchecked-radio-button"
        radioImage.image = UIImage(named: imgName)
        baseButton.isSelected = check
    }

    private func setupImageView() {
        baseView.addSubview(radioImage)

        let desc = UIFontDescriptor.preferredFontDescriptor(withTextStyle: .callout)
        radioImage.translatesAutoresizingMaskIntoConstraints = false
        let widthConstraint = radioImage.widthAnchor.constraint(equalToConstant: desc.pointSize * 2)
        let heightConstraint = radioImage.heightAnchor.constraint(equalToConstant: desc.pointSize * 2)
        let leading = radioImage.leadingAnchor.constraint(equalTo: baseView.leadingAnchor, constant: 0)
        let centerYConstraint = radioImage.centerYAnchor.constraint(equalTo: baseView.centerYAnchor)
        NSLayoutConstraint.activate([widthConstraint, heightConstraint, leading, centerYConstraint])
    }

    private func setupTitleLabel() {
        titleLabel.isAccessibilityElement = false
        titleLabel.font = .preferredFont(forTextStyle: .callout)
        titleLabel.numberOfLines = 0
        titleLabel.lineBreakMode = .byClipping
        titleLabel.textColor = .label
        baseView.addSubview(titleLabel)
        
        let desc = UIFontDescriptor.preferredFontDescriptor(withTextStyle: .title3)
        let margin = desc.pointSize/2 + 2
        
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        let leading = titleLabel.leadingAnchor.constraint(equalTo: radioImage.trailingAnchor, constant: desc.pointSize / 2)
        let trailing = titleLabel.trailingAnchor.constraint(equalTo: baseView.trailingAnchor, constant: -desc.pointSize / 2)
        let top = titleLabel.topAnchor.constraint(equalTo: baseView.topAnchor, constant: margin)
        let bottom = titleLabel.bottomAnchor.constraint(equalTo: baseView.bottomAnchor, constant: -margin)
        NSLayoutConstraint.activate([leading, trailing, top, bottom])
    }

    public func configure(_ model: RadioModel) {

        baseButton.accessibilityLabel = model.title
        titleLabel.text = model.title
        value = model.key
        group = model.group
        action = model.tapAction
        setImage()
    }

    @objc func tapAction(_ sender: Any) {
        UserDefaults.standard.setValue(value, forKey: group)
        if let _f = self.action {
            _f()
        }
    }
}
