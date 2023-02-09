//
//  DestinationViewController.swift
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
 Categories of Regular Exhibition
 */
class DestinationViewController: BaseListController, BaseListDelegate {
    
    private let destinationId = "DestinationCell"

    override func initTable() {
        super.initTable()
        self.tableView.separatorStyle = .singleLine

        self.baseDelegate = self
        self.tableView.register(DestinationCell.self, forCellReuseIdentifier: destinationId)
        
        setData()
        setupTableView()
        setHeaderFooter()
    }

    private func setupTableView() {
        tableView.register(DestinationCell.self, forCellReuseIdentifier: destinationId)
    }

    private func setData() {
        if let navDataStore = NavDataStore.shared(),
           let directory = navDataStore.directory() {
            let sections = directory.sections
            if let sections = sections {
                for section in sections {
                    if let subItems = section.items {
                        for subItem in subItems {
                            if subItem.title == "展示" {
                                items = subItem.content.sections
                                return
                            }
                        }
                    }
                }
            }
            items = sections
        }
    }

    private func setHeaderFooter() {
        let headerView = UIView(frame: CGRect(x: 0, y: 0, width: self.view.frame.width, height: CGFloat.leastNonzeroMagnitude))
        self.tableView.tableHeaderView = headerView

        let footerView = UIView(frame: CGRect(x: 0, y: 0, width: self.view.frame.width, height: 100.0))
        self.tableView.tableFooterView = footerView
    }


    // MARK: BaseListDelegate
    override func numberOfSections(in tableView: UITableView) -> Int {
        if let items = items as? [HLPDirectorySection] {
            return items.count
        }
        return 0
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let items = items as? [HLPDirectorySection],
           section <  items.count {
            let item = items[section]
            if let list = item.items {
                return list.count
            }
        }
        return 0
    }

    func getCell(_ tableView: UITableView, _ indexPath: IndexPath) -> UITableViewCell? {
        if let items = items as? [HLPDirectorySection],
           indexPath.section <  items.count {
            let item = items[indexPath.section]
            if let list = item.items,
               indexPath.row < list.count {
                if let cell = tableView.dequeueReusableCell(withIdentifier: destinationId,
                                                            for: indexPath) as? DestinationCell {
                    cell.configure(list[indexPath.row])
                    return cell
                }
            }
        }
        return nil
    }

    override func onSelect(_ tableView: UITableView, _ indexPath: IndexPath) {
        
        if let cell = self.tableView(tableView, cellForRowAt: indexPath) as? DestinationCell {
            if let model = cell.model {
                guard let nav = self.navigationController as? BaseNavController else { return }
                if let nodeId = model.nodeID {
                    nav.openMap(nodeId: nodeId)
                }
            }
        }
    }

    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let desc = UIFontDescriptor.preferredFontDescriptor(withTextStyle: .subheadline)
        let baseView = UITableViewHeaderFooterView(frame: CGRect(x:0, y:0, width: tableView.frame.width, height: desc.pointSize * 2))
        let label = UILabel(frame: CGRect(x:10, y:0, width: tableView.frame.width, height: desc.pointSize * 2))
        label.font = UIFont.preferredFont(forTextStyle: .subheadline)
        if let items = items as? [HLPDirectorySection],
           section <  items.count {
            label.text = items[section].title
            label.isAccessibilityElement = false
            
            baseView.accessibilityLabel = items[section].title
            baseView.accessibilityTraits = .header
        }
        baseView.addSubview(label)
        
        if #available(iOS 14.0, *) {
            var backgroundConfiguration = UIBackgroundConfiguration.listPlainHeaderFooter()
            backgroundConfiguration.backgroundColor = .systemFill
            baseView.backgroundConfiguration = backgroundConfiguration
        }
        return baseView
    }

    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        let desc = UIFontDescriptor.preferredFontDescriptor(withTextStyle: .subheadline)
        return desc.pointSize * 2
    }

    override func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        view.tintColor = .systemFill
    }
}
