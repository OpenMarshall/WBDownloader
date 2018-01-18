//
//  NaviVC.swift
//  wbdownloader
//
//  Created by KyXu on 2017/9/12.
//  Copyright © 2017年 KyXu. All rights reserved.
//

import UIKit

class NaviVC: UINavigationController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationBar.barTintColor = UIColor.wd_tint
        navigationBar.tintColor = UIColor.white
        navigationBar.isTranslucent = false
        navigationBar.titleTextAttributes = [NSAttributedStringKey.foregroundColor:UIColor.white]
        // 状态栏背景
        let statusBarBgView = UIView(frame: CGRect(x: 0, y: 0, width: screenWidth, height: 20))
        statusBarBgView.backgroundColor = UIColor.wd_tint
        view.addSubview(statusBarBgView)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
}
