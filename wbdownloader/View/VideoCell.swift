//
//  VideoCell.swift
//  wbdownloader
//
//  Created by KyXu on 2017/9/12.
//  Copyright © 2017年 KyXu. All rights reserved.
//

import UIKit
import SnapKit
import FontAwesomeKit

protocol VideoCellDelegate {
    func share(info: VideoInfo)
    func play(info: VideoInfo)
    func download(info: VideoInfo)
}

@objcMembers
class VideoCell: UITableViewCell {
    
    var videoInfo: VideoInfo!
    var delegate: VideoCellDelegate!
    
    fileprivate var titleLabel = UILabel()
    fileprivate var toolbar = UIToolbar()
    
    init(_ videoInfo: VideoInfo) {
        super.init(style: .default, reuseIdentifier: "videoCell")
        self.videoInfo = videoInfo
        backgroundColor = .clear
        
        // 圆角矩形框
        let rr = UIView()
        addSubview(rr)
        rr.snp.makeConstraints {
            $0.left.equalToSuperview().offset(6)
            $0.right.equalToSuperview().offset(-6)
            $0.top.equalToSuperview().offset(8)
            $0.bottom.equalToSuperview().offset(-8)
        }
        rr.layer.borderColor = UIColor.wd_tint.cgColor
        rr.layer.borderWidth = 3
        rr.layer.cornerRadius = 10
        rr.clipsToBounds = true
        
        // 文字
        rr.addSubview(titleLabel)
        titleLabel.snp.makeConstraints {
            $0.left.equalToSuperview().offset(16)
            $0.right.equalToSuperview().offset(-16)
            $0.top.equalToSuperview().offset(8)
            $0.height.equalTo(82) // 四行字的高度
        }
        titleLabel.text = videoInfo.title
        titleLabel.textColor = UIColor.wd_tint
        titleLabel.numberOfLines = 0
        
        // 按钮
        rr.addSubview(toolbar)
        toolbar.snp.makeConstraints {
            $0.left.equalToSuperview()
            $0.right.equalToSuperview()
            $0.bottom.equalToSuperview()
        }
        configToolbar()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configToolbar() {
        toolbar.backgroundColor = .clear
        toolbar.isTranslucent = false
        toolbar.barTintColor = UIColor.wd_bg
        toolbar.tintColor = UIColor.wd_tint
        toolbar.clipsToBounds = true
        let size: CGFloat = 30
        var items = [UIBarButtonItem]()
        items.append(UIBarButtonItem(image: FAKFontAwesome.shareAltIcon(withSize: size).cellImg,
                                     style: .plain,
                                     target: self,
                                     action: #selector(share)))
        items.append(UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: self, action: nil))
        items.append(UIBarButtonItem(image: FAKFontAwesome.playIcon(withSize: size).cellImg,
                                     style: .plain,
                                     target: self,
                                     action: #selector(play)))
        items.append(UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: self, action: nil))
        items.append(UIBarButtonItem(image: FAKFontAwesome.downloadIcon(withSize: size).cellImg,
                                     style: .plain,
                                     target: self,
                                     action: #selector(download)))
        toolbar.setItems(items, animated: false)
    }
    
    func share() {
        delegate.share(info: videoInfo)
    }
    
    func play() {
        delegate.play(info: videoInfo)
    }
    
    func download() {
        delegate.download(info: videoInfo)
    }
}

extension FAKIcon {
    var cellImg: UIImage {
        return image(with: CGSize(width: iconFontSize, height: iconFontSize))
    }
}

