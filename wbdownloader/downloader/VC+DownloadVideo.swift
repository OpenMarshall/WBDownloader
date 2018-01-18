//
//  VC+DownloadVideo.swift
//  wbdownloader
//
//  Created by KyXu on 2017/9/14.
//  Copyright © 2017年 KyXu. All rights reserved.
//

import UIKit
import Photos
import Alamofire
import SnapKit

extension UIViewController {
    /// 后台下载视频，并且保存到相册，保存成功后提示
    ///
    /// - Parameters:
    ///   - info: 视频信息
    ///   - customAlbum: 自定义相册
    func saveVideoToAlbum(_ info: VideoInfo, customAlbum: PHAssetCollection?) {
        let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let destination: DownloadRequest.DownloadFileDestination = { _, _ in
            let fileURL = documentsURL.appendingPathComponent(info.url.lastPathComponent)
            return (fileURL, [.removePreviousFile, .createIntermediateDirectories])
        }
        // 下载
        Alamofire.download(info.url, to: destination).downloadProgress {
            self.showDownloadProgress(Float($0.fractionCompleted))
            }.response { (response) in
                guard let url = response.destinationURL else {
                    print(response.error ?? "没有获取到 response.destinationURL")
                    return
                }
                // 保存到相册
                PHPhotoLibrary.shared().performChanges({
                    let assetRequest = PHAssetChangeRequest.creationRequestForAssetFromVideo(atFileURL: url)
                    // 自定义相册
                    if let customAlbum = customAlbum,
                        let albumRequest = PHAssetCollectionChangeRequest(for: customAlbum),
                        let placeHolder = assetRequest?.placeholderForCreatedAsset {
                        let enumeration: NSArray = [placeHolder]
                        albumRequest.addAssets(enumeration)
                    }
                }) { (saved, error) in
                    // 提示
                    let alert = WBDAlertController(title: saved ? "视频已保存到相册" : "发生错误",
                                                   message: saved ? info.title : error?.localizedDescription)
                    alert.addAction(UIAlertAction(title: "好", style: .cancel, handler: nil))
                    DispatchQueue.main.async {
                        self.present(alert, animated: true, completion: {
                            // 清理 document 文件夹
                            let fileManager = FileManager.default
                            do {
                                let fileNames = try fileManager.contentsOfDirectory(atPath: documentsURL.path)
                                for fileName in fileNames {
                                    let filePath = documentsURL.path + "/" + fileName
                                    try fileManager.removeItem(atPath: filePath)
                                }
                            } catch {
                                print("Could not clear temp folder: \(error)")
                            }
                        })
                    }
                }
        }
    }
    
    func createCustomPhotoAlbum(_ completion:@escaping ((PHAssetCollection?)->())) {
        let fetchOptions = PHFetchOptions()
        let appName = Bundle.main.object(forInfoDictionaryKey: "CFBundleDisplayName") as! String
        fetchOptions.predicate = NSPredicate(format: "title = %@", appName)
        if let collection = PHAssetCollection
            .fetchAssetCollections(with: .album, subtype: .any, options: fetchOptions)
            .firstObject {
            completion(collection)
        }else {
            PHPhotoLibrary.shared().performChanges({
                PHAssetCollectionChangeRequest.creationRequestForAssetCollection(withTitle: appName)
            }, completionHandler: { (success, error) in
                if success {
                    print("创建自定义相册")
                    self.createCustomPhotoAlbum(completion)
                }else {
                    print(error ?? "创建自定义相册失败")
                    completion(nil)
                }
            })
        }
    }

    func showDownloadProgress(_ progress: Float) {
        // get progressView
        var progressView: UIProgressView!
        guard let bar = navigationController?.navigationBar else {
            return
        }
        if let exist = bar.subviews.filter({
            $0 is UIProgressView
        }).first as? UIProgressView {
            progressView = exist
        }else {
            progressView = UIProgressView()
            progressView.trackTintColor = UIColor.clear
            progressView.tintColor = UIColor.wd_bg
            bar.addSubview(progressView)
            progressView.snp.makeConstraints({
                $0.left.equalToSuperview()
                $0.right.equalToSuperview()
                $0.top.equalToSuperview()
            })
        }
        // set progress
        if progress > progressView.progress {
            UIView.animate(withDuration: 0.5, animations: {
                progressView.setProgress(progress, animated: true)
            })
        }
        if progress == 1.0 {
            UIView.animate(withDuration: 0.5, animations: {
                progressView.alpha = 0
            }, completion: { _ in
                progressView.alpha = 1
                progressView.progress = 0
            })
        }
    }
}
