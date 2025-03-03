//
//  MiraikanController.swift
//  NavCogMiraikan
//
/*******************************************************************************
 * Copyright (c) 2021 © Miraikan - The National Museum of Emerging Science and Innovation
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

/**
 Home and initial settings
 */
class MiraikanController: BaseController {

    private let home = Home()

    private var oldModeObserver: NSKeyValueObservation?

    init(title: String) {
        super.init(home, title: title)
        NSLog("\(URL(fileURLWithPath: #file).lastPathComponent) \(#function): \(#line)")
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        AudioGuideManager.shared.isDisplayButton(true)
        setTitle()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        setKVO()
        setTitle()
        // Accessibility
        UIAccessibility.post(notification: .screenChanged, argument: self.navigationItem.titleView)
        
        if UserDefaults.standard.bool(forKey: "OldMode") {
            // NavBar
            let btnSetting = BaseBarButton(image: UIImage(systemName: "gearshape"))
            btnSetting.accessibilityLabel = NSLocalizedString("Navi Settings", comment: "")
            btnSetting.tapAction { [weak self] in
                guard let self = self else { return }
                let vc = NaviSettingController(title: NSLocalizedString("Navi Settings", comment: ""))
                self.navigationController?.show(vc, sender: nil)
            }
            self.navigationItem.rightBarButtonItem = btnSetting
        }
        
        // TODO: Initialization processing position needs to be changed
        // Load the data
        if let events = MiraikanUtil.readJSONFile(filename: "event",
                                                  type: [EventModel].self) as? [EventModel] {
            ExhibitionDataStore.shared.events = events
        }
        
        if var schedules = MiraikanUtil.readJSONFile(filename: "schedule",
                                                     type: [ScheduleModel].self) as? [ScheduleModel] {
            if !MiraikanUtil.isWeekend { schedules.removeAll(where: { $0.onHoliday == true }) }
            ExhibitionDataStore.shared.schedules = schedules

        }

        MiraikanUtil.initNavData()
        MiraikanUtil.startLocating()

        // From initialization to collaborative startup
        if let navDataStore = NavDataStore.shared(),
           let toID = navDataStore.linkToID {
            guard let nav = self.navigationController as? BaseNavController else { return }
            nav.openMap(nodeId: toID)
        }
    }

    func reload() {
        home.setSection()
        home.tableView.reloadData()
    }

    func setTitle() {
        let title = NSLocalizedString("Home", comment: "")
        let attributedString = NSMutableAttributedString()
        attributedString.append(NSAttributedString(string: title))
        let textAttachment = NSTextAttachment()
        let titleLabel = UILabel()
        let metrics = UIFontMetrics(forTextStyle: .title3)
        let desc = UIFontDescriptor.preferredFontDescriptor(withTextStyle: .title3)
        let font = UIFont.systemFont(ofSize: desc.pointSize, weight: .bold)
        titleLabel.font = metrics.scaledFont(for: font)
        titleLabel.accessibilityLabel = NSLocalizedString("Home pron", comment: "")
        titleLabel.adjustsFontSizeToFitWidth = true
        let pointSize = desc.pointSize

        switch MiraikanUtil.routeMode {
        case .general:
            textAttachment.image = UIImage(named: "icons8-general")
            textAttachment.bounds = CGRect(x: 0, y: -pointSize/5, width: pointSize * 6/5, height: pointSize * 6/5)
            attributedString.append(NSAttributedString(attachment: textAttachment))
            break
        case .wheelchair:
            textAttachment.image = UIImage(named: "icons8-wheelchair")
            textAttachment.bounds = CGRect(x: 0, y: -pointSize/5, width: pointSize * 6/5, height: pointSize * 6/5)
            attributedString.append(NSAttributedString(attachment: textAttachment))
            break
        case .stroller:
            textAttachment.image = UIImage(named: "icons8-stroller")
            textAttachment.bounds = CGRect(x: 0, y: -pointSize/5, width: pointSize * 6/5, height: pointSize * 6/5)
            attributedString.append(NSAttributedString(attachment: textAttachment))
            break
        case .blind:
            textAttachment.image = UIImage(named: "icons8-blind")
            textAttachment.bounds = CGRect(x: 0, y: -pointSize/5, width: pointSize * 6/5, height: pointSize * 6/5)
            attributedString.append(NSAttributedString(attachment: textAttachment))
            break
        }
        titleLabel.attributedText = attributedString
        self.navigationItem.titleView = titleLabel
    }

    private func setKVO() {
        oldModeObserver = UserDefaults.standard.observe(\.OldMode, options: [.initial, .new], changeHandler: { [weak self] (defaults, change) in
            guard let self = self else { return }
            self.reload()
        })
    }
}
