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

    var mutexLock = false
    var arFrameSize: CGSize?
    var isShowARCamera = false
    var vibrationLock = false
    var inFrame = false
    var tapPause: SpeechStatus?

    private var locationChangedTime = Date().timeIntervalSince1970

    private let CheckTime: Double = 1

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

        var leading, trailing, top, bottom: NSLayoutConstraint

        sceneView = ARSCNView(frame: CGRect(x: 0, y: 0, width: self.view.frame.width, height: self.view.frame.height))
        sceneView.delegate = self
        sceneView.session.delegate = self
        self.view.addSubview(sceneView)
        sceneView.translatesAutoresizingMaskIntoConstraints = false
        leading = sceneView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 0)
        trailing = sceneView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: 0)
        top = sceneView.topAnchor.constraint(equalTo: self.view.topAnchor, constant: 0)
        bottom = sceneView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor, constant: 0)
        NSLayoutConstraint.activate([leading, trailing, top, bottom])

        if isShowARCamera {
            sceneView.showsStatistics = true
            // Nodeに無指向性の光を追加する
//            sceneView.autoenablesDefaultLighting = true
//            sceneView.debugOptions = [.showWorldOrigin, .showFeaturePoints]
        }

        coverText = UITextView(frame: CGRect(x: 0, y: 0, width: self.view.frame.width, height: self.view.frame.height))
        coverText.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.1)
        coverText.textColor = .white
        coverText.font = .systemFont(ofSize: 20)
        coverText.accessibilityTraits = .none
        coverText.isAccessibilityElement = false
        self.view.addSubview(coverText)
        coverText.translatesAutoresizingMaskIntoConstraints = false
        leading = coverText.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 0)
        trailing = coverText.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: 0)
        top = coverText.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor, constant: 0)
        bottom = coverText.bottomAnchor.constraint(equalTo: self.view.bottomAnchor, constant: 0)
        NSLayoutConstraint.activate([leading, trailing, top, bottom])

        arMessageListView.tapAction({ model in
            if UIAccessibility.isVoiceOverRunning {
                self.tapAction()
                return
            }

            if let model = model {
                let arDetailVC = ARDetailViewController()
                arDetailVC.model = model
                self.navigationController?.pushViewController(arDetailVC, animated: true)
            } else {
                self.tapAction()
            }
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
            self.tapAction()
        }, for: .touchUpInside)

        let scene = SCNScene()
        sceneView.scene = scene

        ArUcoManager.shared.initArUcoModel()
        MotionManager.shared.startMonitoringDeviceMotion()

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
        ArAnchorManager.shared.setArFrameSize(arFrameSize: videoFormats?.imageResolution)
        ArAnchorManager.shared.setARSCNView(arView: sceneView)

    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        // スリープさせない
        UIApplication.shared.isIdleTimerDisabled = true

        // Create a session configuration
        let configuration = ARWorldTrackingConfiguration()
        configuration.planeDetection = .vertical
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
        tapAction()
    }

    private func tapAction() {
//        NSLog("\(URL(string: #file)!.lastPathComponent) \(#function): \(#line), isPlaying: \(AudioManager.shared.isPlaying), isSpeaking: \(AudioManager.shared.isSpeaking()), isPause: \(AudioManager.shared.isPause()), progress: \(AudioManager.shared.progress), speechStatus: \(AudioManager.shared.speechStatus()), tapPause: \(tapPause)")
        DispatchQueue.main.async {
            
            if AudioManager.shared.isPlaying || AudioManager.shared.isSpeaking() {
                
                if UserDefaults.standard.bool(forKey: "ARCameraLockMarker") {
                    AudioManager.shared.stop()
                    return
                }

                switch AudioManager.shared.speechStatus() {
                case SpeechStatusPlay, SpeechStatusContinue:
                    if self.tapPause == SpeechStatusContinue {
                        // マーカーがフレーム内にある場合のみ読み上げる通常の挙動にする
                        self.tapPause = nil
                        NSLog("\(URL(string: #file)!.lastPathComponent) \(#function): \(#line), マーカーがフレーム内にある場合のみ読み上げる通常の挙動にする")
                    } else {
                        self.tapPause = SpeechStatusPause
                        NSLog("\(URL(string: #file)!.lastPathComponent) \(#function): \(#line), 通常一時停止")
                    }
                    AudioManager.shared.pauseToggle()
                case SpeechStatusPause:
                    if self.tapPause == SpeechStatusPause &&
                        self.inFrame {
                        // マーカーがフレーム内にある状態で、音声再開した場合は、マーカーがフレーム内にある場合のみ読み上げる通常の挙動にする
                        NSLog("\(URL(string: #file)!.lastPathComponent) \(#function): \(#line), マーカーがフレーム内にある状態で、音声再開した場合は、マーカーがフレーム内にある場合のみ読み上げる通常の挙動にする")
                        self.tapPause = nil
                    } else {
                        // マーカーがフレーム外にある状態で、音声再開した場合は、マーカーがフレーム外にあっても読み上げを継続させる状態にする
                        NSLog("\(URL(string: #file)!.lastPathComponent) \(#function): \(#line), マーカーがフレーム外にある状態で、音声再開した場合は、マーカーがフレーム外にあっても読み上げを継続させる状態にする")
                        self.tapPause = SpeechStatusContinue
                    }
                    AudioManager.shared.pauseToggle()
                case SpeechStatusStop:
                    // 音声が停止中に再開した場合は、次の状態に移行する。マーカーがフレーム外にあっても読み上げを継続させる状態にする
                    NSLog("\(URL(string: #file)!.lastPathComponent) \(#function): \(#line), 音声が停止中に再開した場合は、次の状態に移行する。マーカーがフレーム外にあっても読み上げを継続させる状態にする")
                    self.tapPause = SpeechStatusContinue
                    AudioManager.shared.nextStep()
                default:
                    break
                }
            }
        }
    }

    private func updateArContent(transforms: Array<MarkerWorldTransform>) -> String {
//        NSLog("\(URL(string: #file)!.lastPathComponent) \(#function): \(#line)")

        var hit = false
        var cognition = ""
        let sortedTransforms = transforms.sorted { $0.distance < $1.distance }

        for transform in sortedTransforms {
            for arUcoModel in ArUcoManager.shared.arUcoList {
//                NSLog("\(transform.arucoId), yaw: \(transform.yaw), pitch: \(transform.pitch), roll: \(transform.roll),  x: \(transform.x), y: \(transform.y), z: \(transform.z), horizontalDistance: \(transform.horizontalDistance)")
                if arUcoModel.id == transform.arucoId {
                    let ratio = ArUcoManager.shared.getMarkerSizeRatio(arUcoModel: arUcoModel)
                    let distance = Double(transform.distance) * ratio
                    let checkStr = String(format: "id: %d, marker: %.1f, distance: %.4f", arUcoModel.id, arUcoModel.getMarkerSize(), distance)
                    cognition += "\n" + checkStr
//                    NSLog("\(checkStr), hit: \(hit), isPlaying: \(AudioManager.shared.isPlaying), isSpeaking: \(AudioManager.shared.isSpeaking()), isPause: \(AudioManager.shared.isPause()), progress: \(AudioManager.shared.progress), tapPause: \(tapPause)")
                    if !hit &&
                        ArUcoManager.shared.checkActiveSettings(key: arUcoModel.id, timeCheck: UserDefaults.standard.bool(forKey: "ARCameraLockMarker")) {
                        // 最も近くで有効なARマーカーのみ音声マーカー処理する、それ以外も音声以外のデータ処理するため、hitフラグを立てる
                        activeArUcoData(arUcoModel: arUcoModel, transform: transform)
                        hit = true
                    }
                }
            }
        }
        return cognition.trimmingCharacters(in: .newlines)
    }

    private func activeArUcoData(arUcoModel: ArUcoModel, transform: MarkerWorldTransform) {
//        NSLog("\(URL(string: #file)!.lastPathComponent) \(#function): \(#line), \(arUcoModel.id), speechStatus: \(AudioManager.shared.speechStatus())")
        // 音声停止終了している場合は、一時停止・再開は無いため、タップステータスをクリア
        if AudioManager.shared.speechStatus() == SpeechStatusStop {
            self.tapPause = nil
        }

        if UserDefaults.standard.bool(forKey: "ARCameraLockMarker") {
            if let markerPoint = arUcoModel.markerPoint,
               markerPoint {
                ArManager.shared.setSoundEffect(arUcoModel: arUcoModel, transform: transform, isEntrance: true)
            } else {
                setAudioData(arUcoModel: arUcoModel, transform: transform)
            }
        } else if ArManager.shared.setLockArMarker(marker: arUcoModel, transform: transform) {
            if self.tapPause == SpeechStatusPause {
                // タップで一時停止している場合
                return
            }

            if arUcoModel.id == AudioManager.shared.speakingID() {
                ArManager.shared.serialMarkerAction()
            }

            if let markerPoint = arUcoModel.markerPoint,
               markerPoint {
                ArManager.shared.setSoundEffect(arUcoModel: arUcoModel, transform: transform, isEntrance: true)
            } else {
                setAudioData(arUcoModel: arUcoModel, transform: transform)
            }
        }
    }

    private func setAudioData(arUcoModel: ArUcoModel, transform: MarkerWorldTransform) {
        
        ArManager.shared.setFlatSoundEffect(arUcoModel: arUcoModel, transform: transform)

        let now = Date().timeIntervalSince1970
//        if locationChangedTime + CheckTime > now {
//            return
//        }

        if AudioManager.shared.isSpeaking() &&
            arUcoModel.id == AudioManager.shared.speakingID() {
            return
        }

        // 同一ID読み終わり, 連続読み上げ間隔チェック
        if !ArUcoManager.shared.checkFinishSettings(key: arUcoModel.id) {
            return
        }

        let phonationModel = ArManager.shared.setSpeakStr(arUcoModel: arUcoModel, transform: transform, isDebug: UserDefaults.standard.bool(forKey: "ARDistanceLimit"))
        if !phonationModel.phonation.isEmpty {
            AudioManager.shared.addGuide(voiceModel: VoiceModel(id: phonationModel.explanation ? arUcoModel.id : nil,
                                                                type: arUcoModel.getArType(),
                                                                voice: phonationModel.phonation,
                                                                message: phonationModel.string,
                                                                descriptionDetail: arUcoModel.descriptionDetail == nil ? arUcoModel.description : arUcoModel.descriptionDetail),
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
//        NSLog("\(URL(string: #file)!.lastPathComponent) \(#function): \(#line), isPlaying:\(AudioManager.shared.isPlaying), isSpeaking:\(AudioManager.shared.isSpeaking())")
        UIAccessibility.post(notification: .screenChanged, argument: controlView)
        setFooterView()
        if AudioManager.shared.isPlaying || AudioManager.shared.isSpeaking() {
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

        // ARフレーム処理中はロックする
        if self.mutexLock {
            return
        }
        self.mutexLock = true

        let pixelBuffer = frame.capturedImage

        if !UserDefaults.standard.bool(forKey: "ARCameraLockMarker") &&
            AudioManager.shared.progress == .mainText &&
            (AudioManager.shared.isPlaying || AudioManager.shared.isSpeaking()) {
//            NSLog("isPlaying: \(AudioManager.shared.isPlaying), isSpeaking: \(AudioManager.shared.isSpeaking()), isPause: \(AudioManager.shared.isPause()), progress: \(AudioManager.shared.progress), tapPause: \(tapPause), movementFlag: \(MotionManager.shared.checkMovementTime(time: 1.0))")
            if AudioManager.shared.isSpeaking() &&
                self.tapPause == SpeechStatusContinue {
                // 本文音声再生中でタップで再開している状態で、端末を大きく動作させた場合は、次に進む案内を行う
                // 意図的に再開しているため、大きく動作させる時間は通常より長くする
                // 音声停止させてから、次に進む
                if MotionManager.shared.checkMovementTime(time: 2.0) {
                    AudioManager.shared.stop()
                    AudioManager.shared.nextStep()
                    MotionManager.shared.updateMovementTime(time: 2.0)
                    DispatchQueue.global().asyncAfter(deadline: DispatchTime.now() + 1.0, execute: {
                        self.mutexLock = false
                    })
                    return
                }
            } else {
                // 本文音声の一時停止中で端末を大きく動作させた場合は、次に進む案内を行う
                if MotionManager.shared.checkMovementTime(time: 1.0) {
                    AudioManager.shared.stop()
                    AudioManager.shared.nextStep()
                    MotionManager.shared.updateMovementTime(time: 1.0)
                    DispatchQueue.global().asyncAfter(deadline: DispatchTime.now() + 1.0, execute: {
                        self.mutexLock = false
                    })
                    return
                }
            }
        }

        // ARマーカー認識処理
        let transMatrixArray = OpenCVWrapper.estimatePose(pixelBuffer,
                                                          withIntrinsics: frame.camera.intrinsics,
                                                          andMarkerSize: ArUcoManager.shared.ArucoMarkerSize) as! Array<MarkerWorldTransform>
        inFrame = transMatrixArray.count > 0
        // ARマーカー認識無し
        if transMatrixArray.count == 0 {
            // 即時に次のカメラフレーム認識解放
            DispatchQueue.global().asyncAfter(deadline: DispatchTime.now() + 0.01, execute: {
                self.mutexLock = false
            })

            if !UserDefaults.standard.bool(forKey: "ARCameraLockMarker") {
                // タップで一時停止、再開している場合は、意図的に実行していると判別して、その処理を継続させる
                if self.tapPause == SpeechStatusContinue {
                    // タップで継続再生実施で音声再生が終了している場合は、状態更新
                    if AudioManager.shared.speechStatus() == SpeechStatusStop {
                        self.tapPause = SpeechStatusStop
                    }
                    return
                } else if self.tapPause == SpeechStatusPause {
                    // タップで一時停止中は処理停止
                    return
                }
                
                // 本文音声再生中に大きく動作させた場合は、本文音声を一時停止する
                if MotionManager.shared.checkMovementTime(time: 0.3) &&
                    AudioManager.shared.isPlaying &&
                    AudioManager.shared.isSpeaking() &&
                    !ArManager.shared.serialMarker &&
                    !AudioManager.shared.isPause() {
                    switch AudioManager.shared.progress {
                    case .mainText:
                        MotionManager.shared.updateMovementTime(time: 0.3)
                        AudioManager.shared.pauseToggle(forcedPause: true)
                    default:
                        break
                    }
                }
            }
            return
        }

        DispatchQueue.main.async(execute: {
            let cognition = self.updateArContent(transforms: transMatrixArray)

            // デバッグ用、現在認識している方ARマーカーのID情報、距離を画面表示する
            if self.isShowARCamera {
                self.coverText.text = cognition
            }

            // 次のカメラフレーム認識解放
            DispatchQueue.global().asyncAfter(deadline: DispatchTime.now() + 0.1, execute: {
                self.mutexLock = false
            })

            // 画面内にマーカーがある場合は一定周期ごとに端末振動
            if !self.vibrationLock {
                UIImpactFeedbackGenerator(style: .soft).impactOccurred()
                DispatchQueue.global().asyncAfter(deadline: DispatchTime.now() + 1.5, execute: {
                    self.vibrationLock = false
                })
                self.vibrationLock = true
            }

            // ARマーカーにアンカーを設置
            if UserDefaults.standard.bool(forKey: "ARCameraMarkerAnchor") {
                ArAnchorManager.shared.setArMarkerAnchor(transforms: transMatrixArray)
            }

            // デバッグ、マーカー認識状態を画像保存
            if UserDefaults.standard.bool(forKey: "ARCameraCheckImage") {
                InquiryManager.shared.makerCaptureToUIImage(buffer: pixelBuffer)
            }
        })
    }

    // アンカー更新
    func session(_ session: ARSession, didUpdate anchors: [ARAnchor]) {
//        NSLog("\(URL(string: #file)!.lastPathComponent) \(#function): \(#line)")
    }

    // アンカー追加
    func session(_ session: ARSession, didAdd anchors: [ARAnchor]) {
//        NSLog("\(URL(string: #file)!.lastPathComponent) \(#function): \(#line)")
    }

    // アンカー削除
    func session(_ session: ARSession, didRemove anchors: [ARAnchor]) {
//        NSLog("\(URL(string: #file)!.lastPathComponent) \(#function): \(#line)")
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

    func view(_ view: ARSKView, nodeFor anchor: ARAnchor) -> SKNode? {
        return nil
    }

    func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
        
    }

    func renderer(_ renderer: SCNSceneRenderer, didUpdate node: SCNNode, for anchor: ARAnchor) {
        
    }
}
