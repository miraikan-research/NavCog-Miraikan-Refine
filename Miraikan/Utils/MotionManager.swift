//
//  MotionManager.swift
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

import CoreMotion

// Singleton
final public class MotionManager: NSObject {
    
    let motionManager = CMMotionManager()
    
    var checkStartTime: Double = 0
    
    var acceleX: Double = 0
    var acceleY: Double = 0
    var acceleZ: Double = 0
    
    let Alpha = 0.4
    let MotionInterval = 0.2
    
    public static let shared = MotionManager()
    
    private override init() {
        super.init()
        
        guard motionManager.isDeviceMotionAvailable else { return }
        motionManager.deviceMotionUpdateInterval = MotionInterval
    }
    
    func startMonitoringDeviceMotion() {
        if motionManager.isDeviceMotionAvailable {
            
            checkStartTime = Date().timeIntervalSince1970
            
            motionManager.startDeviceMotionUpdates(to: .main) { [weak self] (motion, error) in
                guard let self = self else { return }
                guard let motion = motion else { return }
                self.lowpassFilter(motion: motion)
            }
        }
    }
    
    private func stopMonitoringDeviceMotion() {
        if motionManager.isDeviceMotionActive {
            motionManager.stopDeviceMotionUpdates()
        }
    }
    
    private func lowpassFilter(motion: CMDeviceMotion) {
        // 指数移動平均
        acceleX = Alpha * motion.userAcceleration.x + acceleX * (1.0 - Alpha);
        acceleY = Alpha * motion.userAcceleration.y + acceleY * (1.0 - Alpha);
        acceleZ = Alpha * motion.userAcceleration.z + acceleZ * (1.0 - Alpha);

        // 空間ベクトル
        let vector = sqrt(pow(acceleX, 2) + pow(acceleY, 2) + pow(acceleZ, 2))
        
        if vector < 0.1 {
            // 動きが小さい時間を起点とする
            checkStartTime = Date().timeIntervalSince1970
        }
    }

    // 動きが大きい状態が指定時間続いたかの判定
    func checkMovementTime(time: Double) -> Bool {
        checkStartTime + time < Date().timeIntervalSince1970
    }
}
