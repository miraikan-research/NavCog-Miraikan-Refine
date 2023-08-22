//
//  InquiryManager.swift
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

// Singleton
final public class InquiryManager: NSObject {
    
    public static let shared = InquiryManager()

    private var capturelock = false
    private let arMarkerCaptureFlag = false
    private var safetyCounter = 0

    // デバッグ機能 画像バッファをUIimage変換
    private func convertToUIImage(buffer: CVPixelBuffer) -> UIImage? {
        let ciImage = CIImage(cvPixelBuffer: buffer)
        let temporaryContext = CIContext(options: nil)
        if let temporaryImage = temporaryContext.createCGImage(ciImage,
                                                               from: CGRect(x: 0,
                                                                            y: 0,
                                                                            width: CVPixelBufferGetWidth(buffer),
                                                                            height: CVPixelBufferGetHeight(buffer)))
        {
            let capturedImage = UIImage(cgImage: temporaryImage)
            return capturedImage
        }
        return nil
    }

    // デバッグ機能 画像データからマーカー認識画像を生成、マーカーの認識状態を静止画確認用
    func makerCaptureToUIImage(buffer: CVPixelBuffer) {
        // 必要なデバッグ時のみ有効にする
        if !self.arMarkerCaptureFlag {
            return
        }

        // マーカー認識状態を画像保存、容量注意
        if self.capturelock ||
            self.safetyCounter > 100 {
            return
        }

        self.safetyCounter += 1
        self.capturelock = true
        DispatchQueue.global().asyncAfter(deadline: DispatchTime.now() + 1.0, execute: {
            self.capturelock = false
        })

        let DocumentPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]
        do{
            if let image = self.convertToUIImage(buffer: buffer) {
                let date = Date()
                let df = DateFormatter()
                df.dateFormat = "yyyyMMdd-HHmm-ssSSS"

                try image.pngData()?.write(to: URL(fileURLWithPath: DocumentPath + "/capturedImage-\(df.string(from: date)).png" ))
                let aruco_img = OpenCVWrapper.detectARMarker(image)

                if let cgImage = aruco_img?.cgImage {
                    let capturedImage = UIImage(cgImage: cgImage, scale: 1.0, orientation: .right)
                    try capturedImage.pngData()?.write(to: URL(fileURLWithPath: DocumentPath + "/capturedImageAR-\(df.string(from: date)).png" ))
                }
            }
        } catch {
            print("Failed to save the image:", error)
        }
    }
}
