//
//  WBDAlertController.swift
//  wbdownloader
//
//  Created by KyXu on 2017/9/17.
//  Copyright © 2017年 KyXu. All rights reserved.
//

import UIKit
import AVKit
import StoreKit
import AVFoundation
import MessageUI

class WBDAlertController: UIAlertController {

    let alertTintColor = UIColor.black
    
    convenience init(title: String?, message: String?) {
        let style: UIAlertControllerStyle = (screenWidth > 500) ? .alert : .actionSheet
        self.init(title: title, message: message, preferredStyle: style)
        self.view.tintColor = alertTintColor
    }
}


class MoreAlertController: WBDAlertController {
    convenience init(forVC vc: ViewController) {
        self.init(title: nil, message: nil)
        // 如何使用
        self.addAction(UIAlertAction(title: "🤔 如何使用", style: .default, handler: { _ in
            let how = WBDAlertController(title: "使用教程", message: "这是一个可以下载微博中的视频的 app\n你可以在微博中找到一条带有视频的微博  或者一个发过视频的博主 在微博页面右上角【复制链接】\n再回到这个 app\n你就可以下载里面的视频了~")
            how.addAction(UIAlertAction(title: "观看视频教程", style: .default, handler: { _ in
                let playerVC = AVPlayerViewController()
                playerVC.player = AVPlayer(
                    url: URL(string: "http://7xssu3.com1.z0.glb.clouddn.com/wbdownloaderTutorial2.MP4")!)
                vc.present(playerVC, animated: true, completion: {
                    playerVC.player?.play()
                })
            }))
            how.addAction(UIAlertAction(title: "取消", style: .cancel, handler: nil))
            vc.present(how, animated: true, completion: nil)
        }))
        self.addAction(UIAlertAction(title: "取消", style: .cancel, handler: nil))
    }
}
