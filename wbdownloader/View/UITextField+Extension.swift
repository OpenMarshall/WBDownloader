//
//  UITextField+Extension.swift
//  wbdownloader
//
//  Created by KyXu on 2017/9/12.
//  Copyright © 2017年 KyXu. All rights reserved.
//

import UIKit
import Shimmer

extension UITextField {
    
    func shimmerOrStop() {
        if let superview = self.superview, superview.isKind(of: FBShimmeringView.classForCoder()) {
            if let text = self.text, text != "" {
                (superview as? FBShimmeringView)?.isShimmering = false
            }else {
                (superview as? FBShimmeringView)?.isShimmering = true
            }
        }else {
            let shimmerView = FBShimmeringView()
            self.superview?.insertSubview(shimmerView, belowSubview: self)
            shimmerView.snp.makeConstraints({
                $0.edges.equalTo(self)
            })
            shimmerView.contentView = self
            shimmerView.isShimmering = true
        }
    }
    
}
