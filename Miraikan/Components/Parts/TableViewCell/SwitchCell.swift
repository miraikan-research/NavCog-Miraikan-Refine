//
//  SwitchCell.swift
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

class SwitchCell: UITableViewCell {
    private let baseView = UIView()
    private let titleLabel = UILabel()
    private let switchButton = BaseSwitch()

    private var model : SwitchModel?

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.selectionStyle = .none
        titleLabel.isAccessibilityElement = false
        setupBaseView()
        setupSwitchButton()
        setupTitleLabel()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupBaseView() {
        contentView.addSubview(baseView)

        baseView.translatesAutoresizingMaskIntoConstraints = false
        let widthConstraint = baseView.widthAnchor.constraint(equalTo: contentView.widthAnchor, multiplier: 0.9)
        let heightConstraint = baseView.heightAnchor.constraint(equalTo: contentView.heightAnchor, multiplier: 0.9)
        let centerXConstraint = baseView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor)
        let centerYConstraint = baseView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor)
        NSLayoutConstraint.activate([widthConstraint, heightConstraint, centerXConstraint, centerYConstraint])
    }

    private func setupTitleLabel() {
        titleLabel.font = .preferredFont(forTextStyle: .callout)
        baseView.addSubview(titleLabel)
        
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        let leading = titleLabel.leadingAnchor.constraint(equalTo: baseView.leadingAnchor, constant: 0)
        let trailing = titleLabel.trailingAnchor.constraint(equalTo: switchButton.leadingAnchor, constant: 0)
        let centerYConstraint = titleLabel.centerYAnchor.constraint(equalTo: switchButton.centerYAnchor)
        NSLayoutConstraint.activate([leading, trailing, centerYConstraint])
    }

    private func setupSwitchButton() {
        baseView.addSubview(switchButton)

        switchButton.translatesAutoresizingMaskIntoConstraints = false
        let trailing = switchButton.trailingAnchor.constraint(equalTo: baseView.trailingAnchor, constant: -8)
        let top = switchButton.topAnchor.constraint(equalTo: baseView.topAnchor, constant: 8)
        let bottom = switchButton.bottomAnchor.constraint(equalTo: baseView.bottomAnchor, constant: -8)
        NSLayoutConstraint.activate([trailing, top, bottom])
    }
    
    public func configure(_ model : SwitchModel) {
        titleLabel.text = model.desc
        switchButton.accessibilityLabel = model.desc

        switchButton.isOn = model.isOn
        if let isEnabled = model.isEnabled {
            switchButton.isEnabled = isEnabled
        }
        switchButton.onSwitch({ sw in
            UserDefaults.standard.set(sw.isOn, forKey: model.key)
        })
    }
}
