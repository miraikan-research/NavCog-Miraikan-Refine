//
//  ARMessageListView.swift
//  NavCogMiraikan
//
/*******************************************************************************
 * Copyright (c) 2023 © Miraikan - The National Museum of Emerging Science and Innovation
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

class ARMessageListView: UIView {
    
    let titleHeaderLabel = UILabel()
    let headerView = UIView()
    let tableView = UITableView()
    
    private let cellId = "cellId"
    
    private var action: ((VoiceModel) -> ())?
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    override init(frame: CGRect) {
        super.init(frame:frame)
        setup()
    }
    
    func setup() {
        setHeader()
        setTableView()
        
        setHeaderLayout()
        setTableViewLayout()
        
        AudioManager.shared.delegate = self
        
        let singleTapGesture = UITapGestureRecognizer(target: self, action: #selector(singleTap(_:)))
        singleTapGesture.numberOfTapsRequired = 1
        tableView.backgroundView?.addGestureRecognizer(singleTapGesture)

    }

    public func tapAction(_ action: @escaping ((VoiceModel)->())) {
        self.action = action
    }
}

extension ARMessageListView {
    private func setHeader() {
        titleHeaderLabel.text = NSLocalizedString("Look for markers on the camera", comment: "")
        titleHeaderLabel.font = .preferredFont(forTextStyle: .title3)
        titleHeaderLabel.numberOfLines = 0
        titleHeaderLabel.textAlignment = .center
        titleHeaderLabel.textColor = .label
        titleHeaderLabel.lineBreakMode = .byTruncatingTail
        
        headerView.backgroundColor = UITraitCollection.current.userInterfaceStyle == UIUserInterfaceStyle.dark ? UIColor(red: 32/255, green: 32/255, blue: 32/255, alpha: 1) : UIColor(red: 232/255, green: 255/255, blue: 255/255, alpha: 1)     // LightCyan    #E0FFFF    224,255,255
        headerView.addSubview(titleHeaderLabel)
        self.addSubview(headerView)
    }

    private func setTableView() {
        tableView.register(ARGuideRow.self, forCellReuseIdentifier: cellId)
        tableView.separatorStyle = .none
        tableView.delegate = self
        tableView.dataSource = self
        tableView.backgroundColor = UITraitCollection.current.userInterfaceStyle == UIUserInterfaceStyle.dark ? UIColor(red: 32/255, green: 32/255, blue: 32/255, alpha: 1) : UIColor(red: 232/255, green: 255/255, blue: 255/255, alpha: 1)     // LightCyan    #E0FFFF    224,255,255
        tableView.backgroundView = UIView()
        self.addSubview(tableView)
    }

    private func setHeaderLayout() {
        let desc = UIFontDescriptor.preferredFontDescriptor(withTextStyle: .title3)
        let margin = desc.pointSize

        titleHeaderLabel.translatesAutoresizingMaskIntoConstraints = false
        let labelLeading = titleHeaderLabel.leadingAnchor.constraint(equalTo: headerView.leadingAnchor, constant: margin)
        let labelTrailing = titleHeaderLabel.trailingAnchor.constraint(equalTo: headerView.trailingAnchor, constant: -margin)
        let labelTop = titleHeaderLabel.topAnchor.constraint(equalTo: headerView.topAnchor, constant: margin)
        let labelBottom = titleHeaderLabel.bottomAnchor.constraint(equalTo: headerView.bottomAnchor, constant: -margin / 2)
        NSLayoutConstraint.activate([labelLeading, labelTrailing, labelTop, labelBottom])

        headerView.translatesAutoresizingMaskIntoConstraints = false
        let leading = headerView.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 0)
        let trailing = headerView.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: 0)
        let top = headerView.topAnchor.constraint(equalTo: self.safeAreaLayoutGuide.topAnchor, constant: 0)
        NSLayoutConstraint.activate([leading, trailing, top])
    }

    private func setTableViewLayout() {
        tableView.translatesAutoresizingMaskIntoConstraints = false
        let leading = tableView.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 0)
        let trailing = tableView.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: 0)
        let top = tableView.topAnchor.constraint(equalTo: headerView.bottomAnchor, constant: 0)
        let bottom = tableView.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: 0)
        NSLayoutConstraint.activate([leading, trailing, top, bottom])
    }
    @objc func singleTap(_ gesture: UITapGestureRecognizer) {
        if AudioManager.shared.isPlaying {
            AudioManager.shared.stop()
        }
    }
}

// MARK: - AudioManagerDelegate
extension ARMessageListView: AudioManagerDelegate {
    func speakingMessage(speakingData: VoiceModel) {
//        NSLog("\(speakingData.message)")
        if speakingData.id == nil {
            return
        }
        
        DispatchQueue.main.async {
            self.tableView.beginUpdates()
            self.tableView.reloadSections(IndexSet(integer: 0), with: .automatic)
            if let index = AudioGuideManager.shared.data.firstIndex(where: { $0.id == speakingData.id }) {
                AudioGuideManager.shared.data.remove(at: index)
            }
            AudioGuideManager.shared.data.insert(speakingData, at: 0)
            self.tableView.insertRows(at: [IndexPath(row: 0, section: 0)],
                                      with: .automatic)
            self.tableView.endUpdates()

            if UIAccessibility.isVoiceOverRunning,
               let cell = self.tableView.cellForRow(at: IndexPath(row:0 , section: 0)) {
                if AudioManager.shared.isPlaying {
                    AudioManager.shared.stop()
                }
                UIAccessibility.post(notification: UIAccessibility.Notification.layoutChanged, argument: cell)
            }
        }
    }
}


// MARK: - UITableViewDelegate
extension ARMessageListView: UITableViewDelegate , UITableViewDataSource {

    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return AudioGuideManager.shared.data.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: cellId, for: indexPath)
            as? ARGuideRow {
            
            if indexPath.row < AudioGuideManager.shared.data.count {
                cell.configure(AudioGuideManager.shared.data[indexPath.row], lines: indexPath.row == 0 ? 0 : 1)
            }
            return cell
        }
        return UITableViewCell()
    }

    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return nil
    }

    // MARK: UITableViewDelegate
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)

        if AudioManager.shared.isPlaying {
            AudioManager.shared.stop()
        } else if let cell = self.tableView(tableView, cellForRowAt: indexPath)
            as? ARGuideRow {
            
            if let action = action,
               let model = cell.model {
                action(model)
            }
        }
    }

    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        return nil
    }

    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0
    }
}
