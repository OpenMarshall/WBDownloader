//
//  VC+Grab.swift
//  BasketballFlow
//
//  Created by KyXu on 2017/9/7.
//  Copyright © 2017年 KyXu. All rights reserved.
//

import UIKit
import WebKit

extension UIViewController {
    
    // 在网页加载了 https://m.weibo.cn/p/ 时，获取视频地址
    func parseWeibo(_ domain: URL, completion:@escaping ((Set<URL>)->())) {
        var urlSet = Set<URL>()
        
        let webview = WKWebView.invisibleInstance(height: 25000)
        webview.load(URLRequest(url: domain))
        view.addSubview(webview)
        
        webview.extractUrls({ (urls:[URL]) in
            for url in urls {
                urlSet.insert(url)
            }
            completion(urlSet)
        })
    }
    
    func stopParseWeibo() {
        for view in view.subviews {
            if let webview = view as? WKWebView {
                webview.stopExtractUrls()
            }
        }
    }
}

extension VideoTableVC {
    // 在网页加载了 www.weibo.com/tv 时，获取视频信息
    func getVideoInfo(_ url:URL) {
        if stopRequest {
            return
        }
        // 如果同时运行过多 webview，则等待
        if loadingWebviewCount() > maxLoadingWebViewCount {
            DispatchQueue.main.asyncAfter(wallDeadline: DispatchWallTime.now() + 1, execute: {
                self.getVideoInfo(url)
            })
            return
        }
        // indicator
        let indicator = UIActivityIndicatorView(frame: CGRect(x: 0, y: 0, width: 20, height: 20))
        navigationItem.leftBarButtonItem = UIBarButtonItem(customView: indicator)
        indicator.startAnimating()
        
        let webview = WKWebView.invisibleInstance()
        webview.load(URLRequest(url: url))
        view.addSubview(webview)
        webview.extractVideoInfo { (info:VideoInfo?) in
            // remove indicator
            if self.loadingWebviewCount() < maxLoadingWebViewCount {
                indicator.stopAnimating()
            }
            guard let info = info else {return}
            if !VideoInfo.infoSet.contains(info) {
                // 移除将数据添加到 set，tableView 再轮询从 set 取数据
                VideoInfo.infoSet.insert(info)
                self.title = "获取到 \(VideoInfo.infoSet.count) 个视频"
                print("链接：\(VideoInfo.urlSet.count) 视频：\(VideoInfo.infoSet.count) webview：\(self.loadingWebviewCount())")
            }
        }
    }
    
    func stopGetVideoInfo() {
        stopRequest = true
        DispatchQueue.main.async {
            self.navigationItem.leftBarButtonItem = nil // remove indicator
            for view in self.view.subviews {
                if let webview = view as? WKWebView {
                    webview.stopExtractVideoInfo()
                }
            }
        }
    }
    
    func loadingWebviewCount() -> Int {
        return view.subviews.filter({$0.isKind(of: WKWebView.classForCoder())}).count
    }
    
}
