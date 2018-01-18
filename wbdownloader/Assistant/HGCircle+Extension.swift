//
//  HGCircle+Extension.swift
//  wbdownloader
//
//  Created by KyXu on 2017/9/11.
//  Copyright © 2017年 KyXu. All rights reserved.
//

import Foundation
import HGCircularSlider

extension CircularSlider {
    static var wd_Instance: CircularSlider {
        let circle = CircularSlider()
        circle.minimumValue = 0
        circle.maximumValue = 600
        circle.endPointValue = 0
        circle.backgroundColor = UIColor.wd_bg
        circle.diskColor = UIColor.wd_bg
        circle.trackFillColor = UIColor.wd_tint
        circle.endThumbStrokeColor = UIColor.wd_tint
        circle.thumbRadius = 8
        circle.isUserInteractionEnabled = false
        return circle
    }
}
