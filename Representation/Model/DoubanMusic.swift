//
//  DoubanMusic.swift
//  Representation
//
//  Created by Tian Youhui on 15/7/26.
//  Copyright (c) 2015年 Hesion 3D. All rights reserved.
//

import Foundation

class Music: NSObject {
    var id: Int = 0
    var title: String?
    var alt: String?
    var author: [[String: String]]?
    var alt_title: String?
    var tags: [Tag]?
    var summary: String?
    var image: String?
    var mobile_link: String?
    var attrs: Attrs?
    var rating: Rating?
}

class Tag: NSObject {
    var count: Int = 0
    var name: String?
}

class Attrs: NSObject {
    var publisher: [String]?
    var singer: [String]?
    var discs: [String]?
    var pubdate: [String]?
    var title: [String]?
    var media: [String]?
    var tracks: [String]?
    var version: [String]?
}

class Rating: NSObject {
    var max: Int = 10
    var average: Float = 0
    var numRaters: Int = 0
    var min: Int = 0
}

class SearchMusics: NSObject {
    var start: Int = 0
    var count: Int = 0
    var total: Int = 0
    var musics : [Music]?
}
