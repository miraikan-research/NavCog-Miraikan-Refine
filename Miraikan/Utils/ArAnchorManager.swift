//
//  ArAnchorManager.swift
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
import SceneKit
import ARKit

// Singleton
final public class ArAnchorManager: NSObject {
    
    public static let shared = ArAnchorManager()

    private var arView: ARSCNView?
    private var arFrameSize: CGSize?

    private var arMarkerlock = false

    func setARSCNView(arView: ARSCNView?) {
        self.arView = arView
    }

    func setArFrameSize(arFrameSize: CGSize?) {
        self.arFrameSize = arFrameSize
    }

    func setArMarkerAnchor(transforms: Array<MarkerWorldTransform>) {
        guard let _ = arView else { return }

        if self.arMarkerlock {
            return
        }
        self.arMarkerlock = true
        DispatchQueue.global().asyncAfter(deadline: DispatchTime.now() + 3.0, execute: {
            self.arMarkerlock = false
        })

        // ARマーカーにARアンカー設置
        for transform in transforms {
            self.addMarkerNode(transform: transform)
        }
    }

    func addMarkerNode(transform: MarkerWorldTransform) {
        guard let arView = arView else { return }
        
        let x = Float(transform.x)
        let y = Float(transform.y)
        let z = -Float(transform.z)
        NSLog("==================")
        NSLog("(\(x), \(y), \(z))")
        NSLog("==================")

        // 目標
        let ball = SCNSphere(radius: 0.05)
        ball.firstMaterial?.diffuse.contents = UIColor.white
        let node = SCNNode(geometry: ball)
        node.name = String(transform.arucoId)

        // カメラ座標系, 奥行きのみ一致
        let infrontOfCamera = SCNVector3(x: 0, y: 0, z: z)

        // カメラ座標系 -> ワールド座標系
        guard let cameraNode = arView.pointOfView else { return }
        let pointInWorld = cameraNode.convertPosition(infrontOfCamera, to: nil)
        // ワールド座標系 -> スクリーン座標系
        var screenPos = arView.projectPoint(pointInWorld)
        
        let arFrameWidth = arFrameSize?.height ?? 1920
        let arFrameHeight = arFrameSize?.width ?? 1440

        screenPos.x = Float(((arFrameHeight - transform.intersection.y) + (arView.frame.width - arFrameWidth) / 2) * arView.frame.width / UIScreen.main.nativeBounds.width)
        screenPos.y = Float((transform.intersection.x + (arView.frame.height - arFrameHeight) / 2) * arView.frame.height / UIScreen.main.nativeBounds.height + 270) // 算出方法不明な補正値
        
        // ワールド座標に戻す
        let finalPosition = arView.unprojectPoint(screenPos)
        node.position = finalPosition

        // 同一IDで設置済みの場合は置き換え
        for childNodes in arView.scene.rootNode.childNodes {
            if childNodes.name == String(transform.arucoId) {
                arView.scene.rootNode.replaceChildNode(childNodes, with: node)
                return
            }
        }

        arView.scene.rootNode.addChildNode(node)
    }

    //
    func addCheckNodeSphere(x: Float, y: Float, z: Float, size: CGFloat, color: UIColor, name: String? = nil) {
        guard let arView = arView else { return }

        let ball = SCNSphere(radius: size)
        ball.firstMaterial?.diffuse.contents = color
        let node = SCNNode(geometry: ball)
        node.position = SCNVector3(x, y, z)
        node.name = name
        arView.scene.rootNode.addChildNode(node)
    }

    func addCheckNodeBox(x: Float, y: Float, z: Float, color: UIColor, name: String? = nil) {
        guard let arView = arView else { return }

        let box = SCNBox(width: 0.01, height: 0.01, length: 0.01, chamferRadius: 0)
        box.firstMaterial?.diffuse.contents = color
        let node = SCNNode(geometry: box)
        node.position = SCNVector3(x, y, z)
        node.name = name
        arView.scene.rootNode.addChildNode(node)
    }

    func drawLine(from: SCNVector3, to: SCNVector3, color: UIColor, name: String? = nil) {
        guard let arView = arView else { return }

        let source = SCNGeometrySource(vertices: [from, to])
        let element = SCNGeometryElement(data: Data([0, 1]), primitiveType: .line, primitiveCount: 1, bytesPerIndex: 1)
        let geometry = SCNGeometry(sources: [source], elements: [element])
        let node = SCNNode(geometry: geometry)
        node.geometry?.materials.first?.diffuse.contents = color
        node.name = name
        arView.scene.rootNode.addChildNode(node)
    }
}
