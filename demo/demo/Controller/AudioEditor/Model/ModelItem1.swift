//
//  ModelItem.swift
//  AudioControllerFFMPEG
//
//  Created by Viet Hoang on 7/14/20.
//  Copyright © 2020 Viet Hoang. All rights reserved.
//

import Foundation

struct ModelItem1 {
    var title: String
    var image: String
}

struct Song {
    let name:String
    let albumName:String
    let trackName:String
    let image:String
    let artist:String
}

struct SaveParameter {
    let volume: Float
    let rate: Float
    let quality: String
}
