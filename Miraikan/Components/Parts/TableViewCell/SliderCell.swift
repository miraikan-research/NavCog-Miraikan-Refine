//
//  SliderCell.swift
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

class SliderCell: UITableViewCell {
    private let baseView = UIView()
    private let titleLabel = UILabel()
    private let valueLabel = UILabel()
    private let slider = UISlider()

    private var model : SliderModel?

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.selectionStyle = .none
        titleLabel.isAccessibilityElement = false
        valueLabel.isAccessibilityElement = false
        setupBaseView()
        setupTitleLabel()
        setupValueLabel()
        setupSlider()
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
        let trailing = titleLabel.trailingAnchor.constraint(equalTo: baseView.trailingAnchor, constant: 0)
        let top = titleLabel.topAnchor.constraint(equalTo: baseView.topAnchor, constant: 8)
        NSLayoutConstraint.activate([leading, trailing, top])
        titleLabel.setContentHuggingPriority(.defaultLow, for: .vertical)
    }

    private func setupValueLabel() {
        valueLabel.font = .preferredFont(forTextStyle: .callout)
        baseView.addSubview(valueLabel)

        valueLabel.translatesAutoresizingMaskIntoConstraints = false
        let leading = valueLabel.leadingAnchor.constraint(equalTo: baseView.leadingAnchor, constant: 0)
        let top = valueLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 8)
        let bottom = valueLabel.bottomAnchor.constraint(equalTo: baseView.bottomAnchor, constant: -8)
        let widthConstraint = valueLabel.widthAnchor.constraint(equalToConstant: 60.0)
        NSLayoutConstraint.activate([leading, top, bottom, widthConstraint])
        valueLabel.setContentHuggingPriority(.defaultHigh, for: .vertical)
    }

    private func setupSlider() {
        baseView.addSubview(slider)
        slider.addTarget(self, action: #selector(valueChanged(_:)), for: .valueChanged)

        slider.translatesAutoresizingMaskIntoConstraints = false
        let leading = slider.leadingAnchor.constraint(equalTo: valueLabel.trailingAnchor, constant: 2)
        let trailing = slider.trailingAnchor.constraint(equalTo: baseView.trailingAnchor, constant: 0)
        let centerYConstraint = slider.centerYAnchor.constraint(equalTo: valueLabel.centerYAnchor)
        NSLayoutConstraint.activate([leading, trailing, centerYConstraint])
        slider.setContentHuggingPriority(.defaultLow, for: .vertical)
    }

    public func configure(_ model: SliderModel) {
        titleLabel.text = model.title
        titleLabel.sizeToFit()
        let val = model.defaultValue
        let valueStr = String(format: model.format,
                              round(val) == val ? Int(val) : val)
        valueLabel.text = valueStr
        let txtVal = "\(model.desc) \(valueStr)"
//        valueLabel.accessibilityLabel = "label: \(txtVal)"
        self.model = model
        slider.minimumValue = model.min
        slider.maximumValue = model.max
        slider.value = model.defaultValue
        slider.accessibilityValue = txtVal
    }

    @objc private func valueChanged(_ sender: UISlider) {
        if let step = model?.step,
            let fmt = model?.format,
            let name = model?.name,
            let desc = model?.desc {
            let val = round(sender.value / step) * step
            print("\(sender.value), \(val)")
            sender.value = val
            let updated = String(format: fmt, round(step) == step ? Int(val) : val)
            let current = valueLabel.text
            if updated != current {
                valueLabel.text = updated
                let txtVal = "\(desc) \(updated)"
                valueLabel.accessibilityLabel = "label: \(txtVal)"
                UserDefaults.standard.set(val, forKey: name)
                if name == NSLocalizedString("Speech Speed", comment: "") {
                    slider.accessibilityValue = ""
                    let tts = DefaultTTS()
                    tts.speak(txtVal, callback: { [weak self] in
                        guard let self = self else { return }
                        self.slider.accessibilityValue = txtVal
                    })
                } else {
                    self.slider.accessibilityValue = txtVal
                }
            }
        }
    }
}
