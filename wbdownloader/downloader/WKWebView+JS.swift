//
//  WKWebView+JS.swift
//  BasketballFlow
//
//  Created by 徐开源 on 2017/9/9.
//  Copyright © 2017年 KyXu. All rights reserved.
//

import WebKit

enum WKTag: Int {
    case canExtract = 100
    case stopExtractUrls = 1
    case stopExtractVideoInfo = 2
}

extension WKWebView {
    
    class func invisibleInstance(height: CGFloat = screenHeight) -> WKWebView {
        let webview = WKWebView(frame: CGRect(x: screenHeight,
                                              y: screenHeight,
                                              width: screenWidth,
                                              height: height))
        webview.isUserInteractionEnabled = false
        webview.tag = WKTag.canExtract.rawValue
        return webview
    }
    
    
    // MARK: - 解析微博主页
    func extractUrls(_ completion:@escaping (([URL])->())) {
        let timer = Timer.scheduledTimer(timeInterval: 0.5,
                                         target: self,
                                         selector: #selector(keepExtractingUrls(timer:)),
                                         userInfo: completion,
                                         repeats: true)
        timer.fire()
    }
    
    func stopExtractUrls() {
        tag = WKTag.stopExtractUrls.rawValue
        self.endHandle()
    }
    
    @objc fileprivate func keepExtractingUrls(timer: Timer) {
        guard tag != WKTag.stopExtractUrls.rawValue else {
            timer.invalidate()
            endHandle()
            return
        }
        let js = "document.documentElement.outerHTML"
        let completion = timer.userInfo as! ([URL])->()
        
        evaluateJavaScript(js) { (obj:Any?, erro:Error?) in
            guard let result = obj as? String else {return}
            let urls: [URL] = result.components(separatedBy: "\"").map({
                if let url = URL(string: $0), $0.contains("t.cn") {
                    return url
                }
                return nil
            }).flatMap({ return $0 })
            completion(urls)
        }
    }
    
    
    // MARK: - 解析视频页面
    func extractVideoInfo(_ completion:@escaping ((VideoInfo?)->())) {
        Timer.scheduledTimer(timeInterval: 1,
                             target: self,
                             selector: #selector(keepExtractingVideoInfo(timer:)),
                             userInfo: completion,
                             repeats: true)
    }
    
    func stopExtractVideoInfo() {
        tag = WKTag.stopExtractVideoInfo.rawValue
        self.endHandle()
    }
    
    @objc fileprivate func keepExtractingVideoInfo(timer: Timer) {
        guard tag != WKTag.stopExtractVideoInfo.rawValue else {
            timer.invalidate()
            endHandle()
            return
        }
        let js = "document.documentElement.outerHTML"
        let completion = timer.userInfo as! (VideoInfo?)->()
        
        evaluateJavaScript(js) { (obj:Any?, erro:Error?) in
            // 解析 JS 失败 n 次则停止
            self.tag = Int(self.tag) + 1
            if Int(self.tag) >= WKTag.canExtract.rawValue + 7 {
                timer.invalidate()
                self.endHandle()
                completion(nil)
                print("废弃 webview")
            }
            // 解析
            guard let result = obj as? String else {return}
            for str in result.components(separatedBy: "\"").filter({ $0.contains(".mp4") }) {                
                if let url = URL(string: str.stringByDecodingHTMLEntities) {
                    timer.invalidate()
                    self.endHandle()
                    completion(VideoInfo(title: self.title ?? "", url: url, thumbNail: nil))
                }
            }
        }
    }
    
    
    // MARK: - 解析完毕之后的操作
    func endHandle() {
        self.stopLoading()
        self.removeFromSuperview()
    }
    
}
