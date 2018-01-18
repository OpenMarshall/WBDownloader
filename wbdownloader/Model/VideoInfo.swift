//
//  VideoInfo.swift
//  BasketballFlow
//
//  Created by KyXu on 2017/9/8.
//  Copyright © 2017年 KyXu. All rights reserved.
//

import UIKit

struct VideoInfo: Equatable, Hashable {
    
    var title: String
    var url: URL
    var thumbNail: UIImage?
    
    // 存储信息给 tableview 使用
    static var wbPageName = ""
    static var urlSet = Set<URL>()
    static var infoSet = Set<VideoInfo>()
    
    // Equatable
    static func == (lhs: VideoInfo, rhs: VideoInfo) -> Bool {
        return (lhs.title == rhs.title) || (lhs.url.absoluteString == rhs.url.absoluteString)
    }
    
    // Hashable
    var hashValue: Int {
        return url.absoluteString.hashValue
    }
}
