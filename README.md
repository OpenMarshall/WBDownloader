# WBDownloader
这是一个完整的 iOS 客户端，可以用于抓取、下载微博视频。

- 可以输入某一个博主的微博主页地址，抓取其发过的全部视频
- 可以输入某一条视频的微博地址，进行抓取
- 抓取到的视频可以直接下载并保存到系统相册

## 技术
项目使用 Xcode 9 + Swift 4 构建，抓取原理很简单，从移动端微博 H5 的 HTML 中解析出视频地址即可，客户端使用 pod 依赖于以下第三方库：

    pod 'SnapKit', '~> 4.0.0'
    pod 'HGCircularSlider', '~> 2.0.0'
    pod 'Shimmer'
    pod 'FontAwesomeKit', '~> 2.2.0'
    pod 'MJRefresh'
    pod 'Alamofire', '~> 4.5'
	
## 声明
**此项目仅用于 iOS 开发技术的交流学习，你可以把这些代码随意用于自己的项目，但是下载视频请务必尊重发布者版权。<br><br>此项目违反 App Store Review Guidelines 5.2**

