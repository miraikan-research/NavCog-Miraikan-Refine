//
//  RadioModel.swift
//  NavCog3
//
//  Created by yoshizawr204 on 2023/02/20.
//  Copyright © 2023 HULOP. All rights reserved.
//

import Foundation

struct RadioModel {
    let title: String
    let key: String
    let group: String
    let isEnabled : Bool?
    var tapAction: (()->())?
}
