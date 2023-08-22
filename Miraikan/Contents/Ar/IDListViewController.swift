//
//  IDListViewController.swift
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

import Foundation

class IDListViewController: UIViewController {
    
    private let tableView = UITableView()
    
    var arUcoList: [ArUcoModel] = []

    private let prepareIdentifierARMarker = "toARMarkerViewController"

    var selectedId = 0

    private var isSelectMode = true

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = .systemBackground
        
        let chevronLeftImage: UIImage? = UIImage(systemName: "chevron.left")
        let backButtonItem = UIBarButtonItem(image: chevronLeftImage,
                                             style: .plain,
                                             target: self,
                                             action: #selector(backButtonPressed(_:)))
        self.navigationItem.leftBarButtonItem = backButtonItem

        setListButton()

        arUcoList = ArUcoManager.shared.arUcoList
        tableView.delegate = self
        tableView.dataSource = self
        setTableView()
        view.addSubview(tableView)
        setHeaderFooter()

        tableView.translatesAutoresizingMaskIntoConstraints = false
        let leading = tableView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 0)
        let trailing = tableView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: 0)
        let top = tableView.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor, constant: 0)
        let bottom = tableView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor, constant: 0)
        NSLayoutConstraint.activate([leading, trailing, top, bottom])
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    private func setListButton() {
        let listButtonItem = UIBarButtonItem(title: NSLocalizedString(isSelectMode ? "marker" : "disabled selection", comment: ""),
                                             style: .done,
                                             target: self,
                                             action: #selector(listButtonPressed(_:)))
        self.navigationItem.rightBarButtonItem = listButtonItem
    }
}

extension IDListViewController: UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return arUcoList.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .default, reuseIdentifier: "IdARUcoCell")
        cell.textLabel?.numberOfLines = 0
        cell.accessoryType = .detailButton

        if indexPath.row < arUcoList.count {
            let arUcoModel = arUcoList[indexPath.row]
            setCell(cell: cell, arUcoModel: arUcoModel)
            cell.tag = arUcoModel.id
            if isSelectMode {
                let check = ArUcoManager.shared.checkActiveSettings(key: arUcoModel.id)
                cell.accessoryType = check ? .checkmark : .none
                cell.textLabel?.textColor = check ? .label : .secondaryLabel
            } else {
                cell.accessoryType = .detailButton
                cell.textLabel?.textColor = .label
            }
        }
        return cell
    }
}

extension IDListViewController: UITableViewDelegate {

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        if AudioManager.shared.isPlaying {
            AudioManager.shared.stop()
        } else {
            let cell = self.tableView(tableView, cellForRowAt: indexPath)
            if isSelectMode {
                if indexPath.row < arUcoList.count {
                    let arUcoModel = arUcoList[indexPath.row]
                    let check = ArUcoManager.shared.checkActiveSettings(key: arUcoModel.id)
                    ArUcoManager.shared.setActiveSettings(key: arUcoModel.id, value: !check)
                    tableView.reloadRows(at: [indexPath], with: .automatic)
                }
            } else {
                if let text = cell.textLabel?.accessibilityLabel {
                    AudioManager.shared.forcedSpeak(text: text)
                }
                cell.accessoryType = .none
            }
        }
    }

    func tableView(_ tableView: UITableView, accessoryButtonTappedForRowWith indexPath: IndexPath) {
        let cell = self.tableView(tableView, cellForRowAt: indexPath)
        
        self.selectedId = cell.tag
        
        let arMarkerVC = ARMarkerViewController()
        arMarkerVC.selectedId = selectedId
        self.navigationController?.pushViewController(arMarkerVC, animated: true)
    }
}

extension IDListViewController {
    
    @objc func backButtonPressed(_ sender: UIBarButtonItem) {
        AudioManager.shared.stop()
        self.navigationController?.popViewController(animated: true)
    }

    @objc func listButtonPressed(_ sender: UIBarButtonItem) {
        isSelectMode = !isSelectMode
        setListButton()
        setTableView()
    }

    private func setTableView() {
        tableView.allowsMultipleSelection = isSelectMode
        tableView.reloadData()
    }

    private func setHeaderFooter() {
        let footerView = UIView(frame: CGRect(x: 0, y: 0, width: self.view.frame.width, height: 300.0))
        self.tableView.tableFooterView = footerView
    }

    func setCell(cell: UITableViewCell, arUcoModel: ArUcoModel) {
        let transform = MarkerWorldTransform()
        transform.distance = 0.9
        transform.horizontalDistance = 0.4
        transform.yaw = 90

        let arType = arUcoModel.getArType()
        var markerType = ""
        switch arType {
        case .target:
            markerType =  NSLocalizedString("target marker", comment: "")
        case .exposition:
            markerType =  NSLocalizedString("exposition marker", comment: "")
        case .floor:
            markerType =  NSLocalizedString("floor marker", comment: "")
        case .guide:
            markerType =  NSLocalizedString("guide marker", comment: "")
        default:
            break
        }
        
        let phonationModel = ArManager.shared.setSpeakStr(arUcoModel: arUcoModel, transform: transform, isDebug: true)
        var addComment = ""
        if let comment = arUcoModel.comment {
            addComment = "[\(comment)]"
        }
        cell.textLabel?.text = String(arUcoModel.id) + "  markerSize  " + String(arUcoModel.marker ?? 10) + "cm  " + markerType + "\n" + phonationModel.string + addComment
        cell.textLabel?.accessibilityLabel = phonationModel.phonation
    }
}
