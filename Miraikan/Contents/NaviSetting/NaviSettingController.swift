//
//
//  NaviSettingController.swift
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

import Foundation
import UIKit

class NaviSettingController : BaseListController, BaseListDelegate {
    
    private let radioId = "radioCell"
    private let labelId = "labelCell"
    private let switchId = "switchCell"
    private let sliderId = "sliderCell"
    private let buttonId = "buttonCell"
    
    private struct SectionModel {
        let title: String
        let items: [CellModel]
    }

    private struct CellModel {
        let cellId: String
        let model: Any?
    }
    
    override func initTable() {
        super.initTable()
        setHeaderFooter()
        
        AudioGuideManager.shared.isDisplayButton(false)

        self.baseDelegate = self
        self.tableView.register(RadioCell.self, forCellReuseIdentifier: radioId)
        self.tableView.register(LabelCell.self, forCellReuseIdentifier: labelId)
        self.tableView.register(SwitchCell.self, forCellReuseIdentifier: switchId)
        self.tableView.register(SliderCell.self, forCellReuseIdentifier: sliderId)
        self.tableView.register(ButtonCell.self, forCellReuseIdentifier: buttonId)
        self.tableView.separatorStyle = .none

        var sectionList: [SectionModel] = []
        var cellList: [CellModel] = []

        let sectionMode = sectionList.count
        var title = NSLocalizedString("Mode", comment: "")
        cellList.removeAll()
        cellList.append(CellModel(cellId: radioId,
                                  model: RadioModel(title: NSLocalizedString("user_general", comment: ""),
                                                    key: "general",
                                                    group: "RouteMode",
                                                    isEnabled: nil,
                                                    tapAction: { [weak self] in
            guard let self = self else { return }
            self.reloadSection(sectionMode)
        })))

        cellList.append(CellModel(cellId: radioId,
                                  model: RadioModel(title: NSLocalizedString("user_wheelchair", comment: ""),
                                                    key: "wheelchair",
                                                    group: "RouteMode",
                                                    isEnabled: nil,
                                                    tapAction: { [weak self] in
            guard let self = self else { return }
            self.reloadSection(sectionMode)
        })))

//        cellList.append(CellModel(cellId: radioId,
//                                  model: RadioModel(title: NSLocalizedString("user_stroller", comment: ""),
//                                                    key: "stroller",
//                                                    group: "RouteMode",
//                                                    isEnabled: nil,
//                                                    tapAction: { [weak self] in
//            guard let self = self else { return }
//            self.reloadSection(sectionMode)
//        })))

        cellList.append(CellModel(cellId: radioId,
                                  model: RadioModel(title: NSLocalizedString("user_blind", comment: ""),
                                                    key: "blind",
                                                    group: "RouteMode",
                                                    isEnabled: nil,
                                                    tapAction: { [weak self] in
            guard let self = self else { return }
            self.reloadSection(sectionMode)
        })))

        sectionList.append(SectionModel(title: title, items: cellList))
        
        title = NSLocalizedString("Voice", comment: "")
        cellList.removeAll()
        cellList.append(CellModel(cellId: switchId,
                                  model: SwitchModel(desc: NSLocalizedString("Voice Guide", comment: ""),
                                                     key: "isVoiceGuideOn",
                                                     isOn: UserDefaults.standard.bool(forKey: "isVoiceGuideOn"),
                                                     isEnabled: nil)))
        cellList.append(CellModel(cellId: sliderId,
                                  model: SliderModel(min: 0.1,
                                                     max: 1,
                                                     defaultValue: MiraikanUtil.speechSpeed,
                                                     step: 0.01,
                                                     format: "%.2f",
                                                     title: NSLocalizedString("Speech speed", comment: ""),
                                                     name: "speech_speed",
                                                     desc: NSLocalizedString("Speech Speed Description",
                                                                             comment: "Description for VoiceOver"))))
        sectionList.append(SectionModel(title: title, items: cellList))

        title = NSLocalizedString("Navigation", comment: "")
        cellList.removeAll()
        cellList.append(CellModel(cellId: switchId,
                                  model: SwitchModel(desc: NSLocalizedString("Playback even in silent mode", comment: ""),
                                                     key: "SilentModeInvalid",
                                                     isOn: UserDefaults.standard.bool(forKey: "SilentModeInvalid"),
                                                     isEnabled: nil)))
        cellList.append(CellModel(cellId: switchId,
                                  model: SwitchModel(desc: NSLocalizedString("vibrateSetting", comment: ""),
                                                     key: "vibrate",
                                                     isOn: UserDefaults.standard.bool(forKey: "vibrate"),
                                                     isEnabled: nil)))
        cellList.append(CellModel(cellId: switchId,
                                  model: SwitchModel(desc: NSLocalizedString("soundEffectSetting", comment: ""),
                                                     key: "sound_effect",
                                                     isOn: UserDefaults.standard.bool(forKey: "sound_effect"),
                                                     isEnabled: nil)))
        cellList.append(CellModel(cellId: switchId,
                                  model: SwitchModel(desc: NSLocalizedString("for_bone_conduction_headset", comment: ""),
                                                     key: "for_bone_conduction_headset",
                                                     isOn: UserDefaults.standard.bool(forKey: "for_bone_conduction_headset"),
                                                     isEnabled: nil)))
        cellList.append(CellModel(cellId: switchId,
                                  model: SwitchModel(desc: NSLocalizedString("Ignore facility info.", comment: ""),
                                                     key: "ignore_facility",
                                                     isOn: UserDefaults.standard.bool(forKey: "ignore_facility"),
                                                     isEnabled: nil)))
        cellList.append(CellModel(cellId: switchId,
                                  model: SwitchModel(desc: NSLocalizedString("Show POI with Action", comment: ""),
                                                     key: "show_poi_with_action",
                                                     isOn: UserDefaults.standard.bool(forKey: "show_poi_with_action"),
                                                     isEnabled: nil)))
        sectionList.append(SectionModel(title: title, items: cellList))

        let sectionDistance = sectionList.count
        title = NSLocalizedString("Distance unit", comment: "") + "(" + NSLocalizedString("user_blind", comment: "") + ")"
        cellList.removeAll()
        cellList.append(CellModel(cellId: radioId,
                                  model: RadioModel(title: NSLocalizedString("Meter", comment: ""),
                                                    key: "unit_meter",
                                                    group: "distance_unit",
                                                    isEnabled: nil,
                                                    tapAction: { [weak self] in
            guard let self = self else { return }
            self.reloadSection(sectionDistance)
        })))
        cellList.append(CellModel(cellId: radioId,
                                  model: RadioModel(title: NSLocalizedString("Feet", comment: ""),
                                                    key: "unit_feet",
                                                    group: "distance_unit",
                                                    isEnabled: nil,
                                                    tapAction: { [weak self] in
            guard let self = self else { return }
            self.reloadSection(sectionDistance)
        })))
        sectionList.append(SectionModel(title: title, items: cellList))
        
        title = NSLocalizedString("Augmented Reality", comment: "")
        cellList.removeAll()
        cellList.append(CellModel(cellId: switchId,
                                  model: SwitchModel(desc: NSLocalizedString("AR marker immediate loading standby", comment: ""),
                                                     key: "ARMarkerWait",
                                                     isOn: UserDefaults.standard.bool(forKey: "ARMarkerWait"),
                                                     isEnabled: nil)))
        sectionList.append(SectionModel(title: title, items: cellList))

        if MiraikanUtil.isLoggedIn {
            title = NSLocalizedString("Login", comment: "")
            cellList.removeAll()
            cellList.append(CellModel(cellId: buttonId,
                                      model: ButtonModel(title: NSLocalizedString("Logout", comment: ""),
                                                         key: "LoggedIn",
                                                         isEnabled: MiraikanUtil.isLoggedIn,
                                                         tapAction: { [weak self] in
                                                            guard let self = self else { return }
                                                            self.navigationController?.popViewController(animated: true)
            })))
            sectionList.append(SectionModel(title: title, items: cellList))
        }
        var locationStr: String
        if MiraikanUtil.isLocated,
           let loc = MiraikanUtil.location {
            locationStr = " \(loc.lat)\n \(loc.lng)\n \(loc.floor)F\n speed: \(loc.speed)\n accuracy: \(loc.accuracy)\n orientation: \(loc.orientation)\n orientationAccuracy: \(loc.orientationAccuracy)"
        } else {
            locationStr = NSLocalizedString("not_located", comment: "")
        }

        title = NSLocalizedString("Debug", comment: "")
        cellList.removeAll()
        cellList.append(CellModel(cellId: labelId,
                                  model: LabelModel(title: NSLocalizedString("Current Location", comment: ""),
                                                    value: locationStr
                                                   )))

        cellList.append(CellModel(cellId: switchId,
               model: SwitchModel(desc: NSLocalizedString("Preview", comment: ""),
                                  key: "OnPreview",
                                  isOn: MiraikanUtil.isPreview,
                                  isEnabled: nil)))
        cellList.append(CellModel(cellId: sliderId,
                                  model: SliderModel(min: 1,
                                                     max: 10,
                                                     defaultValue: MiraikanUtil.previewSpeed,
                                                     step: 1,
                                                     format: "%d",
                                                     title: NSLocalizedString("Preview speed", comment: ""),
                                                     name: "preview_speed",
                                                     desc: NSLocalizedString("Preview Speed Description",
                                                                             comment: "Description for VoiceOver"))))

        cellList.append(CellModel(cellId: switchId,
                                  model: SwitchModel(desc: NSLocalizedString("Debug Mode", comment: ""),
                                                     key: "DebugMode",
                                                     isOn: UserDefaults.standard.bool(forKey: "DebugMode"),
                                                     isEnabled: nil)))


        cellList.append(CellModel(cellId: switchId,
                                  model: SwitchModel(desc: NSLocalizedString("Old Mode", comment: ""),
                                                     key: "OldMode",
                                                     isOn: UserDefaults.standard.bool(forKey: "OldMode"),
                                                     isEnabled: nil)))


        cellList.append(CellModel(cellId: switchId,
                                  model: SwitchModel(desc: NSLocalizedString("AR Audio interrupt disabled", comment: ""),
                                                     key: "ARAudioInterruptDisabled",
                                                     isOn: UserDefaults.standard.bool(forKey: "ARAudioInterruptDisabled"),
                                                     isEnabled: nil)))

        cellList.append(CellModel(cellId: switchId,
                                  model: SwitchModel(desc: NSLocalizedString("AR Distance Limit Invalid", comment: ""),
                                                     key: "ARDistanceLimit",
                                                     isOn: UserDefaults.standard.bool(forKey: "ARDistanceLimit"),
                                                     isEnabled: nil)))

//        cellList.append(CellModel(cellId: switchId,
//                                  model: SwitchModel(desc: NSLocalizedString("AR stop reading single tap", comment: ""),
//                                                     key: "ARStopReadingSingleTap",
//                                                     isOn: UserDefaults.standard.bool(forKey: "ARStopReadingSingleTap"),
//                                                     isEnabled: nil)))

//        cellList.append(CellModel(cellId: sliderId,
//                                  model: SliderModel(min: 0,
//                                                     max: 10,
//                                                     defaultValue: MiraikanUtil.readingInterval,
//                                                     step: 1,
//                                                     format: "%d",
//                                                     title: NSLocalizedString("AR Same reading interval", comment: ""),
//                                                     name: "ARSameReadingInterval",
//                                                     desc: NSLocalizedString("AR Same reading interval",
//                                                                             comment: "AR Same reading interval"))))

        cellList.append(CellModel(cellId: switchId,
                                  model: SwitchModel(desc: NSLocalizedString("AR Marker Test Data", comment: ""),
                                                     key: "ARMarkerTestData",
                                                     isOn: UserDefaults.standard.bool(forKey: "ARMarkerTestData"),
                                                     isEnabled: nil)))

        cellList.append(CellModel(cellId: sliderId,
                                  model: SliderModel(min: 0,
                                                     max: 300,
                                                     defaultValue: MiraikanUtil.arReadingInterval,
                                                     step: 10,
                                                     format: "%d",
                                                     title: NSLocalizedString("AR reading interval", comment: ""),
                                                     name: "ARReadingInterval",
                                                     desc: NSLocalizedString("AR reading interval",
                                                                             comment: "AR reading interval"))))


        cellList.append(CellModel(cellId: buttonId,
                                  model: ButtonModel(title: NSLocalizedString("Reset_Location", comment: ""),
                                                     key: "",
                                                     isEnabled: nil,
                                                     tapAction: { [weak self] in
                                                        guard let self = self else { return }
            
            let center = NotificationCenter.default
            center.post(name: NSNotification.Name(rawValue: REQUEST_LOCATION_RESTART), object: self)
            self.navigationController?.popViewController(animated: true)
        })))
        
        cellList.append(CellModel(cellId: buttonId,
                                  model: ButtonModel(title: NSLocalizedString("Stop_Location", comment: ""),
                                                     key: "",
                                                     isEnabled: nil,
                                                     tapAction: { [weak self] in
                                                        guard let self = self else { return }
            
            let center = NotificationCenter.default
            center.post(name: NSNotification.Name(rawValue: REQUEST_LOCATION_STOP), object: self)
            self.navigationController?.popViewController(animated: true)
        })))
        cellList.append(CellModel(cellId: buttonId,
                                  model: ButtonModel(title: NSLocalizedString("Start_Location", comment: ""),
                                                     key: "",
                                                     isEnabled: nil,
                                                     tapAction: { [weak self] in
                                                        guard let self = self else { return }
            
            let center = NotificationCenter.default
            center.post(name: NSNotification.Name(rawValue: REQUEST_LOCATION_START), object: self)
            self.navigationController?.popViewController(animated: true)
        })))
        sectionList.append(SectionModel(title: title, items: cellList))
        
        self.items = sectionList
    }
    
    func reloadSection(_ section: Int) {
        DispatchQueue.main.async {
            self.tableView.reloadSections(IndexSet(integer: section), with: .none)
        }
    }
    
    func getCell(_ tableView: UITableView, _ indexPath: IndexPath) -> UITableViewCell? {
        if let items = items as? [SectionModel] {
            if  items.count  < indexPath.section {
                return nil
            }
            let sectionData = items[indexPath.section]
            if sectionData.items.count < indexPath.row {
                return nil
            }
            let item = sectionData.items[indexPath.row]
            let cellId = item.cellId
            let cell = tableView.dequeueReusableCell(withIdentifier: cellId, for: indexPath)
            if let cell = cell as? RadioCell, let model = item.model as? RadioModel {
                cell.configure(model)
                return cell
            } else if let cell = cell as? LabelCell, let model = item.model as? LabelModel {
                cell.configure(model)
                return cell
            } else if let cell = cell as? SwitchCell, let model = item.model as? SwitchModel {
                cell.configure(model)
                return cell
            } else if let cell = cell as? SliderCell,
                        let model = item.model as? SliderModel {
                cell.configure(model)
                return cell
            } else if let cell = cell as? ButtonCell,
                        let model = item.model as? ButtonModel {
                cell.configure(model)
                return cell
            }
        }
        return nil
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        super.tableView(tableView, didSelectRowAt: indexPath)
        let item = (items as? [CellModel])?[indexPath.row]
        guard let cellId = item?.cellId else { return }
        if cellId == labelId {
            if let nav = self.navigationController {
                nav.show(DistanceCheckViewController(title: ""), sender: nil)
            }
        }
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        if let items = items as? [SectionModel] {
            return items.count
        }
        return 0
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let items = items as? [SectionModel] {
            if section < items.count {
                let sectionData = items[section]
                return sectionData.items.count
            }
        }
        return 0
    }

    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let desc = UIFontDescriptor.preferredFontDescriptor(withTextStyle: .subheadline)
        let baseView = UITableViewHeaderFooterView(frame: CGRect(x:0, y:0, width: tableView.frame.width, height: desc.pointSize * 2))
        let label = UILabel(frame: CGRect(x:10, y:0, width: tableView.frame.width, height: desc.pointSize * 2))
        label.font = UIFont.preferredFont(forTextStyle: .subheadline)
        if let items = items as? [SectionModel],
           section <  items.count {
           let item = items[section]
            label.text = item.title
            label.isAccessibilityElement = false
            baseView.accessibilityLabel = item.title
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


    private func setHeaderFooter() {
        let headerView = UIView(frame: CGRect(x: 0, y: 0, width: self.view.frame.width, height: CGFloat.leastNonzeroMagnitude))
        self.tableView.tableHeaderView = headerView

        let footerView = UIView(frame: CGRect(x: 0, y: 0, width: self.view.frame.width, height: 100.0))
        self.tableView.tableFooterView = footerView
    }
}
