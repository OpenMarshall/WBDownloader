//
//  ViewController.swift
//  wbdownloader
//
//  Created by KyXu on 2017/9/11.
//  Copyright © 2017年 KyXu. All rights reserved.
//

import UIKit
import MessageUI
import SnapKit
import FontAwesomeKit
import HGCircularSlider

class ViewController: UIViewController, UITextFieldDelegate, MFMailComposeViewControllerDelegate {
    
    fileprivate let circle = CircularSlider.wd_Instance
    fileprivate let urlCountLabel = UILabel()
    @IBOutlet var moreBtn: UIButton!
    @IBOutlet var tf: UITextField!
    @IBOutlet var parseBtn: UIButton!
    @IBOutlet var stopParseBtn: UIButton!
    enum ParseState: String {
        case none = "抓取微博视频"
        case parsing = "查看已抓取视频"
    }
    fileprivate var parseState: ParseState = .none

    
    // MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.wd_bg
        // 状态栏背景
        let statusBarBgView = UIView(frame: UIApplication.shared.statusBarFrame)
        statusBarBgView.backgroundColor = UIColor.wd_tint
        view.addSubview(statusBarBgView)
        // KVO
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(weiboLinkDetected),
                                               name: .UIApplicationDidBecomeActive,
                                               object: nil)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(enableParseBtn),
                                               name: nil,
                                               object: tf)
        // 多选按钮
        moreBtn.tintColor = UIColor.wd_tint
        let moreImgSize = CGSize(width: 40, height: 25)
        let moreImg = FAKFontAwesome.diamondIcon(withSize: 25).image(with: moreImgSize)
        moreBtn.setImage(moreImg, for: .normal)
        moreBtn.setImage(moreImg, for: .highlighted)
        moreBtn.addTarget(self, action: #selector(more), for: .touchUpInside)
        // 输入框
        tf.attributedPlaceholder = NSAttributedString(
            string: "输入某条微博或某博主首页地址",
            attributes: [NSAttributedStringKey.foregroundColor: UIColor.white])
        tf.backgroundColor = UIColor.wd_tint
        tf.delegate = self
        tf.shimmerOrStop()
        // 圆圈
        view.insertSubview(circle, belowSubview: moreBtn)
        let offset = (screenHeight > 560) ? 10 : 0
        circle.snp.makeConstraints({
            $0.top.equalTo(statusBarBgView.snp.bottom).offset(offset)
            $0.left.equalToSuperview()
            $0.right.equalToSuperview()
            $0.bottom.equalTo(tf.snp.top).offset(-offset)
        })
        circle.addSubview(urlCountLabel)
        urlCountLabel.snp.makeConstraints({
            $0.centerY.equalToSuperview()
            $0.centerX.equalToSuperview()
            $0.width.equalToSuperview()
        })
        showUrlCount()
    }

    override func viewWillAppear(_ animated: Bool) {
        stopParse()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        tf.resignFirstResponder()
    }
    
    
    // MARK: - Button Action
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        controller.dismiss(animated: true)
    }
    
    @objc fileprivate func more() {
        let alert = MoreAlertController(forVC: self)
        present(alert, animated: true, completion: nil)
    }
    
    @IBAction func parse() {
        if parseState == .none {
            // 准备抓链接
            stopParse()
            animateCircleAround()
            guard let url = tf.text?.weiboUrl() else {
                return
            }
            parseState = .parsing
            stopParseBtn.isEnabled = true
            parseBtn.isEnabled = false
            VideoInfo.wbPageName = url.lastPathComponent
            parseWeibo(url) { (urls:Set<URL>) in
                if VideoInfo.urlSet.count != urls.count {
                    VideoInfo.urlSet = urls
                    self.animateCircleAround()
                    self.showUrlCount()
                }
            }
            tf.resignFirstResponder()
        }else if parseState == .parsing {
            VideoInfo.urlSet.removeAll()
            VideoInfo.infoSet.removeAll()
            // 准备下载视频
            if let vc = storyboard?.instantiateViewController(withIdentifier: "navi") as? NaviVC {
                
                present(vc, animated: true, completion: {
                    self.stopParse()
                })
            }
        }
        tf.shimmerOrStop()
    }
    
    @IBAction func stopParse() {
        // 圆圈部分
        NSObject.cancelPreviousPerformRequests(withTarget: self)
        circle.endPointValue = 0
        showUrlCount(0)
        // webview 部分
        stopParseWeibo()
        // 状态
        parseState = .none
        // UI
        stopParseBtn.isEnabled = false
        parseBtn.isEnabled = true
        tf.resignFirstResponder()
        parseBtn.setTitle(ParseState.none.rawValue, for: .normal)
    }
    
    
    // MARK: - UI
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        parse()
        return true
    }
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        if parseState == .parsing {
            stopParse()
        }
        return true
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        if textField.text == "" {
            textField.text = "http://www.weibo.com/"
        }
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        textField.shimmerOrStop()
    }
    
    @objc fileprivate func animateCircleAround() {
        if circle.endPointValue != circle.maximumValue {
            circle.endPointValue = circle.endPointValue + 1
            let ti: TimeInterval = TimeInterval((VideoInfo.urlSet.count == 0)
                ? (30/circle.maximumValue)
                : (3/circle.maximumValue))
            NSObject.cancelPreviousPerformRequests(withTarget: self)
            perform(#selector(animateCircleAround), with: nil, afterDelay: ti)
        }else {
            circle.endPointValue = 0
        }
    }
    
    fileprivate func showUrlCount(_ count: Int = VideoInfo.urlSet.count) {
        let attributedText = NSMutableAttributedString(string: "已找到\n",
                                                       attributes: [NSAttributedStringKey.font : UIFont.boldSystemFont(ofSize: 14)])
        let fontSize = (screenHeight > 560) ? 70 : 40
        attributedText.append(NSMutableAttributedString(string: "\(count)",
            attributes: [NSAttributedStringKey.font : UIFont.boldSystemFont(ofSize: CGFloat(fontSize))]))
        attributedText.append(NSMutableAttributedString(string: "\n条视频地址",
                                                        attributes: [NSAttributedStringKey.font : UIFont.boldSystemFont(ofSize: 14)]))
        urlCountLabel.attributedText = attributedText
        urlCountLabel.textColor = UIColor.wd_tint
        urlCountLabel.numberOfLines = 0
        urlCountLabel.textAlignment = .center
        // 准备停止抓取，并下载视频
        if !VideoInfo.urlSet.isEmpty {
            parseBtn.setTitle(ParseState.parsing.rawValue, for: .normal)
            parseBtn.isEnabled = true
        }
    }
    
    
    // MARK: - 链接自动填充
    @objc fileprivate func weiboLinkDetected() {
        guard let url = UIPasteboard.general.string?.weiboUrl(),
            url.absoluteString != ignoredLink else {
            return
        }
        let alert = WBDAlertController(title: "检测到剪贴板中有微博链接",
                                       message: url.absoluteString)
        alert.addAction(UIAlertAction(title: "抓取视频", style: .default, handler: { _ in
            self.tf.text = url.absoluteString
            self.parseState = .none
            self.parse()
        }))
        alert.addAction(UIAlertAction(title: "取消", style: .cancel, handler: { _ in
            ignoredLink = url.absoluteString
        }))
        present(alert, animated: true, completion: nil)
    }
    
    @objc fileprivate func enableParseBtn() {
        if let string = tf.text, string.contains("."), let _ = URL(string: string) {
            parseBtn.isEnabled = true
        }else {
            parseBtn.isEnabled = false
        }
    }
}


// MARK: - 链接识别
extension String {
    mutating func addMPrefix() {
        if !contains("/u/") && !contains("/p/") {
            return
        }
        if contains("www.weibo") {
            self = replacingOccurrences(of: "www.weibo", with: "m.weibo")
        }
        if contains("://weibo") {
            self = replacingOccurrences(of: "://weibo", with: "://m.weibo")
        }
    }
    
    func weiboUrl() -> URL? {
        var str = self
        if !str.hasPrefix("http") {
            if str.hasPrefix("www.") {
                str = "http://" + str
            }else {
                str = "http://www." + str
            }
        }
        str.addMPrefix()
        if let url = URL(string: str), str.contains("weibo") {
            print(str)
            return url
        }
        return nil
    }
}

