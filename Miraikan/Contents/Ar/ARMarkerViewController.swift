//
//  ARMarkerViewController.swift
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

class ARMarkerViewController: UIViewController {

    private let idLabel = UILabel()
    private let arImage = UIImageView()

    var selectedId = 0

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = .systemBackground
        
        idLabel.text = String(selectedId)
        idLabel.lineBreakMode = .byWordWrapping
        idLabel.textAlignment = .center
        idLabel.numberOfLines = 0
        idLabel.font = .preferredFont(forTextStyle: .headline)
        idLabel.textColor = .label
        idLabel.frame.size.width = UIScreen.main.bounds.width
        idLabel.frame.size.height = 40
        idLabel.center.x = self.view.center.x
        idLabel.frame.origin.y = self.view.center.y - UIScreen.main.bounds.width * 0.5 - 50
        view.addSubview(idLabel)

        arImage.frame.size.width = UIScreen.main.bounds.width * 0.8
        arImage.frame.size.height = UIScreen.main.bounds.width * 0.8
        arImage.center = self.view.center

        view.addSubview(arImage)
        
        if let image = OpenCVWrapper.createARMarker(Int32(selectedId)) {
            arImage.image = image
        }
        
        ARUCOMakerOutput()
    }

    // デバッグ用、マーカー画像生成
    func ARUCOMakerOutput() {
#if targetEnvironment(simulator)
        let DocumentPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]
        print("\(DocumentPath)")
        for i in 0..<1000 {
            if let image = OpenCVWrapper.createARMarker(Int32(i)) {
                do{
                    let name = String(format: "%03d", i)
                    try image.pngData()?.write(to: URL(fileURLWithPath: DocumentPath + "/7x7_1000-\(name).png" ))
                    
                    if let imageFrame = image.ARUCOMakerFrameOutput() {
                        try imageFrame.pngData()?.write(to: URL(fileURLWithPath: DocumentPath + "/7x7_1000-frame-\(name).png" ))
                        try imageFrame.jpegData(compressionQuality: 100)?.write(to:URL(fileURLWithPath: DocumentPath + "/7x7_1000-frame-\(name).jpg" ) )
                    }
                } catch {
                    print("Failed to save the image:", error)
                }
            }
        }
#endif
    }
}

extension UIImage {
    func ARUCOMakerFrameOutput() -> UIImage? {
        let imageFrame = 200
        let sideFrame = 250

        let color = UIColor.white
        let size = CGSize(width: sideFrame, height: sideFrame)
        UIGraphicsBeginImageContext(size)
        
        let rect = CGRect(origin: CGPoint.zero, size: size)
        let context = UIGraphicsGetCurrentContext()
        context?.setFillColor(color.cgColor)
        context?.fill(rect)

        self.draw(in: CGRect(x: (sideFrame - imageFrame) / 2,
                             y: (sideFrame - imageFrame) / 2,
                             width: imageFrame,
                             height: imageFrame))
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image
    }
}
