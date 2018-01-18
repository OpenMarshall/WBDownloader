//
//  Common.swift
//  BasketballFlow
//
//  Created by KyXu on 2017/9/8.
//  Copyright © 2017年 KyXu. All rights reserved.
//

import UIKit
import CoreGraphics

let screenWidth = UIScreen.main.bounds.width
let screenHeight = UIScreen.main.bounds.height

let cellHeight: CGFloat = 150
let maxLoadingWebViewCount = 3

var ignoredLink = "" // 记录用户没有进行抓取的链接，下次不再提示

func topController() -> UIViewController? {
    var topController = UIApplication.shared.keyWindow?.rootViewController
    while topController?.presentedViewController != nil {
        topController = topController?.presentedViewController
    }
    return topController
}
extension UIColor {
    static let wd_bg = UIColor(red:0.88, green:0.88, blue:0.88, alpha:1.00)
    static let wd_tint = UIColor(red:0.59, green:0.03, blue:0.19, alpha:1.00)
}
