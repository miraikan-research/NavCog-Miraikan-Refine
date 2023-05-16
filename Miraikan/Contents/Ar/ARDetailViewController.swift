//
//  ARDetailViewController.swift
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

class ARDetailViewController: UIViewController {
    
    private let tableView = UITableView()
    
    var model: VoiceModel?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = .systemBackground
        
        let chevronLeftImage: UIImage? = UIImage(systemName: "chevron.left")
        let backButtonItem = UIBarButtonItem(image: chevronLeftImage, style: .plain, target: self, action: #selector(backButtonPressed(_:)))
        self.navigationItem.leftBarButtonItem = backButtonItem

        tableView.separatorStyle = .none
        tableView.delegate = self
        tableView.dataSource = self
        tableView.backgroundColor = UITraitCollection.current.userInterfaceStyle == UIUserInterfaceStyle.dark ? UIColor(red: 48/255, green: 48/255, blue: 54/255, alpha: 1) :  UIColor(red: 232/255, green: 255/255, blue: 255/255, alpha: 1)
        tableView.backgroundView = UIView()
        view.addSubview(tableView)
        setHeaderFooter()
        
        tableView.translatesAutoresizingMaskIntoConstraints = false
        let leading = tableView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 0)
        let trailing = tableView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: 0)
        let top = tableView.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor, constant: 0)
        let bottom = tableView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor, constant: 0)
        NSLayoutConstraint.activate([leading, trailing, top, bottom])

        let singleTapGesture = UITapGestureRecognizer(target: self, action: #selector(singleTap(_:)))
        singleTapGesture.numberOfTapsRequired = 1
        tableView.backgroundView?.addGestureRecognizer(singleTapGesture)
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if !UIAccessibility.isVoiceOverRunning,
           let model = model {
            AudioManager.shared.forcedSpeak(text: model.voice)
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

extension ARDetailViewController: UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .default, reuseIdentifier: "VoiceCell")
        cell.textLabel?.font = .preferredFont(forTextStyle: .title1)
        cell.textLabel?.numberOfLines = 0
        cell.textLabel?.textColor = .label
        cell.backgroundColor = .clear
        cell.selectionStyle = .none
        if let model = model {
            cell.textLabel?.text = model.message
            cell.accessibilityLabel = model.voice
        }
        return cell
    }
}

extension ARDetailViewController: UITableViewDelegate {

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        if AudioManager.shared.isPlaying {
            AudioManager.shared.stop()
        } else if !UIAccessibility.isVoiceOverRunning,
                  let model = model {
            AudioManager.shared.forcedSpeak(text: model.voice)
        }
    }
}

extension ARDetailViewController {
    
    @objc func backButtonPressed(_ sender: UIBarButtonItem) {
        AudioManager.shared.stop()
        self.navigationController?.popViewController(animated: true)
    }

    private func setHeaderFooter() {
        let footerView = UIView(frame: CGRect(x: 0, y: 0, width: self.view.frame.width, height: 300.0))
        self.tableView.tableFooterView = footerView
    }

    @objc func singleTap(_ gesture: UITapGestureRecognizer) {
        AudioManager.shared.stop()
    }
}
