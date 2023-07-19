//
//  ARViewController.swift
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
import Foundation
import SceneKit
import ARKit

class ARViewController: UIViewController {

    var sceneView: ARSCNView!
    var coverText: UITextView!
    // for VoiceOver
    var controlView: UIButton!

    let arMessageListView = ARMessageListView()

    var mutexlock = false
    var arFrameSize: CGSize?
    var isShowARCamera = false

    private var locationChangedTime = Date().timeIntervalSince1970

    private let checkTime: Double = 1

    private var shakeDate: Date?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = NSLocalizedString("AR navigation", comment: "")
        self.view.backgroundColor = .systemBackground

        isShowARCamera = UserDefaults.standard.bool(forKey: "ARCameraView")
        
        let chevronLeftImage: UIImage? = UIImage(systemName: "chevron.left")
        let backButtonItem = UIBarButtonItem(image: chevronLeftImage, style: .plain, target: self, action: #selector(backButtonPressed(_:)))
        self.navigationItem.leftBarButtonItem = backButtonItem

        if UserDefaults.standard.bool(forKey: "DebugMode") {
            let listButtonItem = UIBarButtonItem(title: "List", style: .done, target: self, action: #selector(listButtonPressed(_:)))
            self.navigationItem.rightBarButtonItem = listButtonItem
        }

        sceneView = ARSCNView(frame: CGRect(x: 0, y: 0, width: self.view.frame.width, height: self.view.frame.height))
        sceneView.delegate = self
        sceneView.session.delegate = self
        self.view.addSubview(sceneView)
        sceneView.translatesAutoresizingMaskIntoConstraints = false
        var leading = sceneView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 0)
        var trailing = sceneView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: 0)
        var top = sceneView.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor, constant: 0)
        var bottom = sceneView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor, constant: 0)
        NSLayoutConstraint.activate([leading, trailing, top, bottom])

        if isShowARCamera {
            sceneView.showsStatistics = true
            // Nodeに無指向性の光を追加する
            sceneView.autoenablesDefaultLighting = true
            sceneView.debugOptions = [.showWorldOrigin, .showFeaturePoints]
        }

        coverText = UITextView(frame: CGRect(x: 0, y: 0, width: self.view.frame.width, height: self.view.frame.height))
        coverText.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.1)
        coverText.textColor = .white
        coverText.font = .systemFont(ofSize: 20)
        self.view.addSubview(coverText)
        coverText.translatesAutoresizingMaskIntoConstraints = false
        leading = coverText.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 0)
        trailing = coverText.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: 0)
        top = coverText.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor, constant: 0)
        bottom = coverText.bottomAnchor.constraint(equalTo: self.view.bottomAnchor, constant: 0)
        NSLayoutConstraint.activate([leading, trailing, top, bottom])

        arMessageListView.tapAction({ model in
            if UIAccessibility.isVoiceOverRunning {
                return
            }
            let arDetailVC = ARDetailViewController()
            arDetailVC.model = model
            self.navigationController?.pushViewController(arDetailVC, animated: true)
        })
        self.view.addSubview(arMessageListView)

        arMessageListView.translatesAutoresizingMaskIntoConstraints = false
        leading = arMessageListView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 0)
        trailing = arMessageListView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: 0)
        top = arMessageListView.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor, constant: 0)
        bottom = arMessageListView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor, constant: 0)
        NSLayoutConstraint.activate([leading, trailing, top, bottom])

        controlView = UIButton(frame: CGRect(x: 0, y: 0, width: self.view.frame.width, height: self.view.frame.height))
        self.view.addSubview(controlView)
        controlView.translatesAutoresizingMaskIntoConstraints = false
        leading = controlView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 0)
        trailing = controlView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: 0)
        top = controlView.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor, constant: 0)
        bottom = controlView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor, constant: 0)
        NSLayoutConstraint.activate([leading, trailing, top, bottom])

        controlView.accessibilityTraits = .none
        UIAccessibility.post(notification: .screenChanged, argument: controlView)
        controlView.isHidden = true
        controlView.addAction(.init { _ in
            if AudioManager.shared.isPlaying {
                AudioManager.shared.stop()
            }
        }, for: .touchUpInside)

        let scene = SCNScene()
        sceneView.scene = scene

        ArUcoManager.shared.initArUcoModel()

        if !UIAccessibility.isVoiceOverRunning {
            AudioManager.shared.setupInitialize()
        }

        becomeFirstResponder()
        setFooterView()
        setNotification()

        coverText.isHidden = !isShowARCamera
        arMessageListView.isHidden = isShowARCamera
        controlView.isHidden = !isShowARCamera

#if targetEnvironment(simulator)
        let alert = UIAlertController(title: nil, message: "simulator does not support", preferredStyle: .alert)
        let yesAction = UIAlertAction(title: "OK", style: .default)
        alert.addAction(yesAction)
        present(alert, animated: true)
#endif
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        let array = ARWorldTrackingConfiguration.supportedVideoFormats
        let videoFormats = array.first
        arFrameSize = videoFormats?.imageResolution
        ArManager.shared.setArFrameSize(arFrameSize: videoFormats?.imageResolution)

    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        // スリープさせない
        UIApplication.shared.isIdleTimerDisabled = true

        // Create a session configuration
        let configuration = ARWorldTrackingConfiguration()
        configuration.planeDetection = .horizontal
//        configuration.isLightEstimationEnabled = true
        configuration.worldAlignment = .gravity

        sceneView.session.run(configuration)
        
        UIAccessibility.post(notification: .screenChanged, argument: arMessageListView.headerView)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        // Pause the view's session
        sceneView.session.pause()
    }

    override var canBecomeFirstResponder: Bool {
        return true
    }

    override func motionBegan(_ motion: UIEvent.EventSubtype, with event: UIEvent?) {
        if motion == .motionShake {
            shakeDate = Date()
        }
    }

    override func motionEnded(_ motion: UIEvent.EventSubtype, with event: UIEvent?) {
        if motion == .motionShake {
            if let shakeDate = shakeDate {
                let diff = Date().timeIntervalSince(shakeDate)
                if diff > 0 && diff < 2 {
                    AudioManager.shared.repeatSpeak()
                }
            }
        }
    }

    override func motionCancelled(_ motion: UIEvent.EventSubtype, with event: UIEvent?) {
        if motion == .motionShake {
            shakeDate = nil
        }
    }
}

extension ARViewController {

    @objc func backButtonPressed(_ sender: UIBarButtonItem) {
        AudioManager.shared.stop()
        self.navigationController?.popViewController(animated: true)
    }

    @objc func listButtonPressed(_ sender: UIBarButtonItem) {
        let idListVC = IDListViewController()
        self.navigationController?.pushViewController(idListVC, animated: true)
    }

    @objc func singleTap(_ gesture: UITapGestureRecognizer) {
        if AudioManager.shared.isPlaying {
            AudioManager.shared.stop()
        }
    }

    private func updateArContent(transforms: Array<MarkerWorldTransform>) -> String {

        var hit = false
        var cognition = ""
        let sortedTransforms = transforms.sorted { $0.distance < $1.distance }

        for transform in sortedTransforms {
            for arUcoModel in ArUcoManager.shared.arUcoList {
//                NSLog("\(transform.arucoId), yaw: \(transform.yaw), pitch: \(transform.pitch), roll: \(transform.roll),  x: \(transform.x), y: \(transform.y), z: \(transform.z), horizontalDistance: \(transform.horizontalDistance)")
                if arUcoModel.id == transform.arucoId {
                    let ratio = ArUcoManager.shared.getMarkerSizeRatio(arUcoModel: arUcoModel)
                    let distance = Double(transform.distance) * ratio
                    let checkStr = String(format: "id: %d, marker: %.1f, distance: %.4f", arUcoModel.id, arUcoModel.marker ?? 10, distance)
                    cognition += "\n" + checkStr
//                    NSLog(checkStr)
                    if !hit &&
                        ArUcoManager.shared.checkActiveSettings(key: arUcoModel.id, timeCheck: true) {
                        activeArUcoData(arUcoModel: arUcoModel, transform: transform)
                        hit = true
                    }
                }
            }
        }
        return cognition.trimmingCharacters(in: .newlines)
    }

    private func activeArUcoData(arUcoModel: ArUcoModel, transform: MarkerWorldTransform) {

        if let markerPoint = arUcoModel.markerPoint,
           markerPoint {
            ArManager.shared.setSoundEffect(arUcoModel: arUcoModel, transform: transform)
        } else {
            setAudioData(arUcoModel: arUcoModel, transform: transform)
        }
    }

    private func setAudioData(arUcoModel: ArUcoModel, transform: MarkerWorldTransform) {
        
        ArManager.shared.setFlatSoundEffect(arUcoModel: arUcoModel, transform: transform)

        let now = Date().timeIntervalSince1970
        if (locationChangedTime + checkTime > now) {
            return
        }

        let phonationModel = ArManager.shared.setSpeakStr(arUcoModel: arUcoModel, transform: transform, isDebug: UserDefaults.standard.bool(forKey: "ARDistanceLimit"))
        if !phonationModel.phonation.isEmpty {
            AudioManager.shared.addGuide(voiceModel: VoiceModel(id: phonationModel.explanation ? arUcoModel.id : nil,
                                                                voice: phonationModel.phonation,
                                                                message: phonationModel.string,
                                                                descriptionDetail: arUcoModel.descriptionDetail,
                                                                priority: 10),
                                         soundEffect: true)
            locationChangedTime = now
            if phonationModel.explanation {
                ArUcoManager.shared.setActiveDate(key: arUcoModel.id)
            }
        }
    }

    func setNotification() {
        let center = NotificationCenter.default
        center.addObserver(self,
                           selector: #selector(voiceOverNotification),
                           name: UIAccessibility.voiceOverStatusDidChangeNotification,
                           object: nil)
    }

    @objc private func voiceOverNotification() {
        controlView.isHidden = true
        UIAccessibility.post(notification: .screenChanged, argument: controlView)
        setFooterView()
        if AudioManager.shared.isPlaying {
            AudioManager.shared.stop()
        }
        
        if UIAccessibility.isVoiceOverRunning {
            UIAccessibility.post(notification: UIAccessibility.Notification.layoutChanged, argument: arMessageListView.headerView)
        }
    }

    func setFooterView() {
        UserDefaults.standard.set(!UIAccessibility.isVoiceOverRunning, forKey: "isFooterButtonView")
    }
}

// MARK: - ARSessionDelegate
extension ARViewController: ARSessionDelegate {

    func session(_ session: ARSession, didUpdate frame: ARFrame) {

        if self.mutexlock {
            return
        }

        self.mutexlock = true
        let pixelBuffer = frame.capturedImage

        let transMatrixArray = OpenCVWrapper.estimatePose(pixelBuffer,
                                                          withIntrinsics: frame.camera.intrinsics,
                                                          andMarkerSize: ArUcoManager.shared.ArucoMarkerSize) as! Array<MarkerWorldTransform>
        if(transMatrixArray.count == 0) {
            DispatchQueue.global().asyncAfter(deadline: DispatchTime.now() + 0.01, execute: {
                self.mutexlock = false
            })
            return
        }

        DispatchQueue.main.async(execute: {
            let cognition = self.updateArContent(transforms: transMatrixArray)
            if self.isShowARCamera {
                self.coverText.text = cognition
            }
            DispatchQueue.global().asyncAfter(deadline: DispatchTime.now() + 0.1, execute: {
                self.mutexlock = false
            })
        })
    }

    func session(_ session: ARSession, didUpdate anchors: [ARAnchor]) {
    }

    func session(_ session: ARSession, didAdd anchors: [ARAnchor]) {
    }

    func session(_ session: ARSession, didRemove anchors: [ARAnchor]) {
    }
}

// MARK: - ARSessionObserver
extension ARViewController: ARSessionObserver {
    func session(_ session: ARSession, cameraDidChangeTrackingState camera: ARCamera) {
    }
}

// MARK: - ARSCNViewDelegate
extension ARViewController: ARSCNViewDelegate {
    func session(_ session: ARSession, didFailWithError error: Error) {
        // Present an error message to the user
    }

    func sessionWasInterrupted(_ session: ARSession) {
        // Inform the user that the session has been interrupted, for example, by presenting an overlay
    }

    func sessionInterruptionEnded(_ session: ARSession) {
        // Reset tracking and/or remove existing anchors if consistent tracking is required
    }
}
