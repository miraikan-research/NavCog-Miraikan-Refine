//
//  RouteModeRow.swift
//  NavCog3
//
//  Created by yoshizawr204 on 2023/01/25.
//  Copyright © 2023 HULOP. All rights reserved.
//

import Foundation
import UIKit

/**
 Caution: This is related to but not the same as the modes in NavCog3
 */

class RouteModeRow: UITableViewCell {
    
    private let baseView = UIView()
    private let titleLabel = UILabel()
    private var radioGroup = [RouteMode: RadioButton]()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        self.selectionStyle = .none
        
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
        let heightConstraint = baseView.heightAnchor.constraint(equalTo: contentView.heightAnchor, multiplier: 0.9)
        let centerXConstraint = baseView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor)
        let centerYConstraint = baseView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor)
        NSLayoutConstraint.activate([widthConstraint, heightConstraint, centerXConstraint, centerYConstraint])
    }

    private func setupTitleLabel() {
        titleLabel.isAccessibilityElement = false
        titleLabel.font = .preferredFont(forTextStyle: .callout)
        titleLabel.text = NSLocalizedString("Mode", comment: "")
        baseView.addSubview(titleLabel)

        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        let leading = titleLabel.leadingAnchor.constraint(equalTo: baseView.leadingAnchor, constant: 0)
        let trailing = titleLabel.trailingAnchor.constraint(equalTo: baseView.trailingAnchor, constant: 0)
        let top = titleLabel.topAnchor.constraint(equalTo: baseView.topAnchor, constant: 8)
        NSLayoutConstraint.activate([leading, trailing, top])
        titleLabel.setContentHuggingPriority(.defaultLow, for: .vertical)
        
        var anchor = titleLabel.bottomAnchor
        RouteMode.allCases.forEach({ mode in
            let btn = RadioButton()
            btn.setText(text: mode.description)
            btn.isChecked = mode == MiraikanUtil.routeMode
            btn.tapAction({ [weak self] _ in
                guard let _self = self else { return }
                if !btn.isChecked {
                    btn.isChecked = true
                    _self.radioGroup.forEach({
                        let (k, v) = ($0.key, $0.value)
                        if k != mode { v.isChecked = false }
                    })
                    UserDefaults.standard.setValue(mode.rawValue, forKey: "RouteMode")
                }
            })
            radioGroup[mode] = btn
            baseView.addSubview(btn)
            
            btn.translatesAutoresizingMaskIntoConstraints = false
            let btnLeading = btn.leadingAnchor.constraint(equalTo: baseView.leadingAnchor, constant: 0)
            let btnTrailing = btn.trailingAnchor.constraint(equalTo: baseView.trailingAnchor, constant: 0)
            let btnTop = btn.topAnchor.constraint(equalTo: anchor, constant: 0)
            NSLayoutConstraint.activate([btnLeading, btnTrailing, btnTop])
            
            anchor = btn.bottomAnchor
        })

        let bottom = baseView.bottomAnchor.constraint(equalTo: anchor, constant: 0)
        NSLayoutConstraint.activate([bottom])
    }
}
