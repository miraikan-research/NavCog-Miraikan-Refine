//
//  RadioButton.swift
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

class RadioButton: UIButton {

    private var action: ((UIView)->())?
    private let baseView = UIView()
    private let radioImage = UIImageView()
    private let valueLabel = UILabel()

    var isChecked: Bool {
        didSet {
            setImage()
            self.isSelected = isChecked
        }
    }

    override init(frame: CGRect) {
        isChecked = false
        super.init(frame: frame)
        self.isAccessibilityElement = true
        setupBaseView()
        setImage()
        setupImageView()
        setupValueLabel()
        
        self.isUserInteractionEnabled = true
        let tapGestureRecognizer = UITapGestureRecognizer(target: self,
                                                          action: #selector(_tapAction(_:)))
        self.addGestureRecognizer(tapGestureRecognizer)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupBaseView() {
        self.addSubview(baseView)

        baseView.translatesAutoresizingMaskIntoConstraints = false
        let widthConstraint = baseView.widthAnchor.constraint(equalTo: self.widthAnchor, multiplier: 0.95)
        let heightConstraint = baseView.heightAnchor.constraint(equalTo: self.heightAnchor, multiplier: 0.95)
        let centerXConstraint = baseView.centerXAnchor.constraint(equalTo: self.centerXAnchor)
        let centerYConstraint = baseView.centerYAnchor.constraint(equalTo: self.centerYAnchor)
        NSLayoutConstraint.activate([widthConstraint, heightConstraint, centerXConstraint, centerYConstraint])
    }

    private func setImage() {
        let imgName = isChecked ? "icons8-checked-radio-button" : "icons8-unchecked-radio-button"
        radioImage.image = UIImage(named: imgName)
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

    private func setupValueLabel() {
        valueLabel.font = .preferredFont(forTextStyle: .callout)
        valueLabel.numberOfLines = 0
        valueLabel.lineBreakMode = .byClipping
        baseView.addSubview(valueLabel)

        let desc = UIFontDescriptor.preferredFontDescriptor(withTextStyle: .callout)

        valueLabel.translatesAutoresizingMaskIntoConstraints = false
        let leading = valueLabel.leadingAnchor.constraint(equalTo: radioImage.trailingAnchor, constant: desc.pointSize / 2)
        let trailing = valueLabel.trailingAnchor.constraint(equalTo: baseView.trailingAnchor, constant: -desc.pointSize / 2)
        let top = valueLabel.topAnchor.constraint(equalTo: baseView.topAnchor, constant: desc.pointSize / 2)
        let bottom = valueLabel.bottomAnchor.constraint(equalTo: baseView.bottomAnchor, constant: -desc.pointSize / 2)
        NSLayoutConstraint.activate([leading, trailing, top, bottom])
        valueLabel.setContentHuggingPriority(.defaultLow, for: .vertical)
    }
    
    func setText(text: String) {
        valueLabel.text = text
        self.accessibilityLabel = text
    }

    @objc public func tapAction(_ action: @escaping ((UIView)->())) {
        self.action = action
    }
    
    @objc private func _tapAction(_ sender: UIView) {
        if let _f = self.action {
            _f(self)
        }
    }
}
