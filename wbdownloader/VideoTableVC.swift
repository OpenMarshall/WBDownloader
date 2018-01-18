//
//  VideoTableVC.swift
//  wbdownloader
//
//  Created by KyXu on 2017/9/11.
//  Copyright © 2017年 KyXu. All rights reserved.
//

import UIKit
import AVKit
import Photos
import AVFoundation
import MJRefresh

@objcMembers
class VideoTableVC: UITableViewController, VideoCellDelegate {
    
    fileprivate var infoArr = [VideoInfo]()
    var timer = Timer()
    var stopRequest = false // 停止大量解析视频页面
    var bottomDistance: CGFloat {
        return tableView.contentSize.height - tableView.contentOffset.y - tableView.frame.height
    }
    
    
    // MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "获取中..."
        tableView.backgroundColor = UIColor.wd_bg
        tableView.separatorColor = UIColor.wd_tint
        tableView.isScrollEnabled = false
        view.backgroundColor = UIColor.wd_bg
    }
    
    override func viewDidAppear(_ animated: Bool) {
        for url in VideoInfo.urlSet {
            getVideoInfo(url)
        }
        timer = Timer.scheduledTimer(timeInterval: 0.2,
                                     target: self,
                                     selector: #selector(requestingData),
                                     userInfo: nil,
                                     repeats: true)
    }
    
    @objc fileprivate func requestingData() {
        if bottomDistance >= 0 {
            timer.invalidate()
            // 刷新
            tableView.isScrollEnabled = true
            tableView.mj_header = MJRefreshNormalHeader(refreshingTarget: self,
                                                        refreshingAction: #selector(refreshTableView))
            tableView.mj_footer = MJRefreshBackNormalFooter(refreshingTarget: self,
                                                            refreshingAction: #selector(refreshTableView))
        }else if (bottomDistance < 0) && !(tableView.isDragging) && !(tableView.isDecelerating) {
            refreshTableView()
        }
    }

    override func viewWillDisappear(_ animated: Bool) {
        stopGetVideoInfo()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    
    // MARK: - IBAction
    @IBAction func dismiss(_ sender: UIBarButtonItem) {
        dismiss(animated: true, completion: nil)
    }
    
    
    // MARK: - Table View
    @objc fileprivate func refreshTableView() {
        let oldCount = infoArr.count
        for info in VideoInfo.infoSet {
            if !infoArr.contains(info) {
                infoArr.append(info)
            }
        }
        let newCount = infoArr.count
        if tableView.mj_header != nil {
            tableView.mj_header.endRefreshing()
        }
        if tableView.mj_footer != nil {
            tableView.mj_footer.endRefreshing()
        }
        if oldCount == newCount {return}
        // UI
        var ipArr = [IndexPath]()
        for i in oldCount..<newCount {
            ipArr.append(IndexPath(row: i, section: 0))
        }
        tableView.beginUpdates()
        tableView.insertRows(at: ipArr,
                             with: UITableViewRowAnimation.automatic)
        tableView.endUpdates()
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return infoArr.count
    }

    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return cellHeight
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = VideoCell(infoArr[indexPath.row])
        cell.delegate = self
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    
    // MARK: - VideoCellDelegate
    func share(info: VideoInfo) {
        stopGetVideoInfo()
        let ac = UIActivityViewController(activityItems: [info.title, info.url],
                                          applicationActivities: nil)
        present(ac, animated: true, completion: nil)
    }
    
    func play(info: VideoInfo) {
        stopGetVideoInfo()
        let playerVC = AVPlayerViewController()
        playerVC.player = AVPlayer(url: info.url)
        present(playerVC, animated: true, completion: {
            playerVC.player?.play()
        })
    }
    
    func download(info: VideoInfo) {
        stopGetVideoInfo()
        // 相册访问权限
        if PHPhotoLibrary.authorizationStatus() == .denied ||
            PHPhotoLibrary.authorizationStatus() == .restricted {
            let alert = WBDAlertController(title: "没有下载内容到相册的权限", message: nil)
            alert.addAction(UIAlertAction(title: "取消", style: .cancel, handler: nil))
            alert.addAction(UIAlertAction(title: "开启权限", style: .default, handler: { _ in
                UIApplication.shared.openURL(URL(string: UIApplicationOpenSettingsURLString)!)
            }))
            present(alert, animated: true, completion: nil)
            return
        }else if PHPhotoLibrary.authorizationStatus() == .notDetermined {
            PHPhotoLibrary.requestAuthorization({ (status) in
                if status == .authorized {
                    self.download(info: info)
                }
            })
            return
        }else if PHPhotoLibrary.authorizationStatus() == .authorized {
            // 创建自定义相册、保存视频
            createCustomPhotoAlbum({ (customAlbum) in
                self.saveVideoToAlbum(info, customAlbum: customAlbum)
            })
        }
    }
}


