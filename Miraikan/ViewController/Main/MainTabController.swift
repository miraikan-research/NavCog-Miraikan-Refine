//
//  MainTabController.swift
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

class MainTabController: UITabBarController, UITabBarControllerDelegate {

    private var selectedTab: TabItem = .home
    
    private var buttonBaseView = ThroughView()
    private var voiceGuideButton = VoiceGuideButton()
    var voiceGuideObserver: NSKeyValueObservation?
    var footerButtonViewObserver: NSKeyValueObservation?
    private var oldModeObserver: NSKeyValueObservation?
    private var silentModeInvalidObserver: NSKeyValueObservation?

    override func viewDidLoad() {
        super.viewDidLoad()

        self.delegate = self
        self.tabBar.backgroundColor = .systemBackground
        self.tabBar.layer.borderWidth = 1.0
        self.tabBar.layer.borderColor = UIColor.systemGray5.cgColor
        self.setTabs()

        UserDefaults.standard.set(true, forKey: "isFooterButtonView")
        AudioGuideManager.shared.active()
        AudioGuideManager.shared.isActive(UserDefaults.standard.bool(forKey: "isVoiceGuideOn"))
        setLayerButton()
        setKVO()
        setNotification()

    }

    override func tabBar(_ tabBar: UITabBar, didSelect item: UITabBarItem) {
        guard let firstIndex = tabBar.items?.firstIndex(of: item),
              let tab = TabItem(rawValue: firstIndex)
              else { return }

        if tab == selectedTab { return }

        switch tab {
        case .callStaff:
            AudioGuideManager.shared.isDisplayButton(false)
        case .callSC:
            AudioGuideManager.shared.isDisplayButton(false)
        case .home:
            break
        case .login:
            AudioGuideManager.shared.isDisplayButton(false)
        case .askAI:
            AudioGuideManager.shared.isDisplayButton(false)
            MapManager.shared.stopNavigation()
        }
        selectedTab = tab
    }

    func tabBarController(_ tabBarController: UITabBarController, shouldSelect viewController: UIViewController) -> Bool {
//        if let navigationController = viewController as? UINavigationController {
//            navigationController.popToRootViewController(animated: true)
//        } else if let navigationController = viewController as? BaseTabController {
//            navigationController.popToRootViewController(animated: true)
//        }
        return true
    }

    private func setKVO() {
        voiceGuideObserver = AudioGuideManager.shared.observe(\.isDisplay,
                                                     options: [.initial, .new],
                                                     changeHandler: { [weak self] (defaults, change) in
            guard let self = self else { return }
            if let change = change.newValue {
                self.voiceGuideButton.isDisplayButton(change)
            }
        })

        footerButtonViewObserver = UserDefaults.standard.observe(\.isFooterButtonView, options: [.initial, .new], changeHandler: { [weak self] (defaults, change) in
            guard let self = self else { return }
            if let change = change.newValue {
                UserDefaults.standard.set(change, forKey: "isFooterButtonView")
                self.buttonBaseView.isHidden = !change
            }
        })

        oldModeObserver = UserDefaults.standard.observe(\.OldMode, options: [.initial, .new], changeHandler: { [weak self] (defaults, change) in
            guard let self = self else { return }
            self.setTabs()
        })
        
        silentModeInvalidObserver = UserDefaults.standard.observe(\.SilentModeInvalid, options: [.initial, .new], changeHandler: { [weak self] (defaults, change) in
            guard let _ = self else { return }
            let tts = DefaultTTS()
            tts.checkSilentMode()
        })
        
    }

    private func setTabs() {
        var tabs: [TabItem]
        if !UserDefaults.standard.bool(forKey: "OldMode") {
            tabs = [TabItem.home, TabItem.askAI]
        } else {
            tabs = TabItem.allCases.filter({ item in
                return true
            })
        }
        
        self.viewControllers = tabs.map({ $0.vc })
        self.selectedIndex = tabs.firstIndex(where: { $0 == .home })!
        if let items = self.tabBar.items {
            for (i, t) in tabs.enumerated() {
                items[i].title = t.title
                items[i].accessibilityLabel = t.accessibilityTitle
                items[i].image = UIImage(named: t.imgName)
            }
        }
    }

    private func setLayerButton() {
        setLayerBaseView()
        setLayerVoiceGuideButton()
    }

    func setLayerBaseView() {
        buttonBaseView.backgroundColor = .clear
        self.view.addSubview(buttonBaseView)

        var bottomPadding: CGFloat = 0
        if let window = UIApplication.shared.windows.first {
            bottomPadding = window.safeAreaInsets.bottom
        }
        let tabHeight = self.tabBar.frame.height
        
        buttonBaseView.translatesAutoresizingMaskIntoConstraints = false
        let leading = buttonBaseView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 0)
        let trailing = buttonBaseView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: 0)
        let bottom = buttonBaseView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor, constant: -(tabHeight + bottomPadding))
        let heightConstraint = buttonBaseView.heightAnchor.constraint(equalToConstant: 100)
        NSLayoutConstraint.activate([leading, trailing, bottom, heightConstraint])

    }
    
    func setLayerVoiceGuideButton() {
        buttonBaseView.addSubview(voiceGuideButton)
        
        voiceGuideButton.translatesAutoresizingMaskIntoConstraints = false
        let trailing = voiceGuideButton.trailingAnchor.constraint(equalTo: buttonBaseView.trailingAnchor, constant: -10)
        let centerYConstraint = voiceGuideButton.centerYAnchor.constraint(equalTo: buttonBaseView.centerYAnchor)
        let widthConstraint = voiceGuideButton.widthAnchor.constraint(equalToConstant: 80)
        let heightConstraint = voiceGuideButton.heightAnchor.constraint(equalToConstant: 80)
        NSLayoutConstraint.activate([trailing, centerYConstraint, widthConstraint, heightConstraint])
    }
    
    
    func setNotification() {
        let center = NotificationCenter.default
        center.addObserver(self,
                           selector: #selector(self.openMap(note:)),
                           name: Notification.Name(rawValue:REQUEST_START_NAVIGATION),
                           object: nil)
    }

    @objc func openMap(note: Notification) {
        guard let toID = note.userInfo?["toID"] as? String else { return }

        if let viewControllers = self.viewControllers,
           let vc = viewControllers.first as? HomeTabController {
            vc.nav.popToRootViewController(animated: false)
            vc.nav.openMap(nodeId: toID)
        }
        self.tabBarController?.selectedIndex = 0
    }
}
