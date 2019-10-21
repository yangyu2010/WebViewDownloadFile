//
//  WebViewDownloader.swift
//  WebViewDownloadFile
//
//  Created by YangYu on 2019/10/21.
//  Copyright © 2019 YangYu. All rights reserved.
//

import UIKit
import Alamofire

protocol WebDownloaderDelegate {
    func startRequestWith(_ urlString: String?)
    func startDownloadFile()
    func downloadFile(_ progress: Float)
    func endDownloadFile(_ error: Error?)
}

private let kCachePath = NSSearchPathForDirectoriesInDomains(FileManager.SearchPathDirectory.cachesDirectory, FileManager.SearchPathDomainMask.userDomainMask, true).first!
private let kTempPath = NSTemporaryDirectory()

class WebDownloader: NSObject {
//    /// 浏览器解析后的URL显示在输入界面
//    var realURLCompletion: ((String?) -> Void)?
//    /// 浏览器解析后的URL显示在输入界面
//    var progressBlock: ((Float) -> Void)?
    var delegate: WebDownloaderDelegate?
    
    /// 支持下载的文件后缀
    let supportAssetType = [
        "zip", "rar", "7z",                     // 压缩包格式
        "pdf", "doc", "xls", "txt", "html",     // 文稿格式
        "exe", "dmg",                           // 安装包格式 可以不支持
        "mp3", "m4a", "wav", "flac",            // 音频格式
        "mp4", "mov", "rmvb", "avi", "mpeg",    // 视频格式
        "jgp", "png", "jpge", "heic", "gif",    // 图片格式
    ]
    
    /// 文件下载的session
    fileprivate lazy var session : URLSession  = {
        let config = URLSessionConfiguration.default
        let session = URLSession(configuration: config, delegate: self, delegateQueue: OperationQueue.main)
        return session
    }()
    
    fileprivate var outputStream : OutputStream?
    fileprivate var downLoadedPath : String?
    fileprivate var downLoadingPath : String?
    fileprivate var currentLength: Float = 0
    
    /// 判断当前 URL 是否需要下载
    func requestIsDownloadable( request: URLRequest) -> Bool {
        guard let requestString = request.url?.absoluteString as NSString? else { return false }
        print(requestString)
        print(requestString.lastPathComponent)
        print("---------")
        let fileType = requestString.pathExtension
        return supportAssetType.contains(fileType)
    }
    
    /// 开始下载工作
    func initializeDownload( download: URLRequest) {
        guard let requestString = download.url?.absoluteString as NSString? else {
            print("当前URL格式不正确...")
            return
        }
        
        guard let url = URL(string: requestString as String) else { return }
        
        let fileName = requestString.lastPathComponent
        
        // 临时下载文件路径
        downLoadingPath = kTempPath + "/" + fileName
        // 下载完成后保存的路径
        downLoadedPath = kCachePath + "/" + fileName
        
        #if !DEBUG
        // 检查当前路径是否已经下载了该文件
        if FileManager.default.fileExists(atPath: downLoadedPath!) {
            print("文件已下载...")
            return
        }
        #endif
        
        // 检查tmp是否有之前没下载成功的, 有直接删除老的, 开始新的下载
        // To-Do 这里可以用断点续传来下载
        // if FileManager.default.fileExists(atPath: downLoadingPath) {
        //    try? FileManager.default.removeItem(atPath: downLoadingPath)
        // }
        
        // 直接删除 try?
        try? FileManager.default.removeItem(atPath: downLoadingPath!)

        // 开始下载
        let request = NSURLRequest(url: url, cachePolicy: NSURLRequest.CachePolicy.reloadIgnoringCacheData, timeoutInterval: 0) as URLRequest
        let dataTask = self.session.dataTask(with: request)
        dataTask.resume()
    }
}


extension WebDownloader: UIWebViewDelegate {
    func webView(_ webView: UIWebView, shouldStartLoadWith request: URLRequest, navigationType: UIWebView.NavigationType) -> Bool {
        
        delegate?.startRequestWith(request.url?.absoluteString)
        
        if requestIsDownloadable(request: request) {
            initializeDownload(download: request)
            return false
        }
        
        return true
    }
}


extension WebDownloader: URLSessionDataDelegate {
    
    func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didReceive response: URLResponse, completionHandler: @escaping (URLSession.ResponseDisposition) -> Void) {
        print("开始响应...............")
        
        delegate?.startDownloadFile()

        // 继续接受数据
        // 确定开始下载数据
        self.outputStream = OutputStream(toFileAtPath: self.downLoadingPath!, append: true)
        
        self.outputStream?.open()
        completionHandler(URLSession.ResponseDisposition.allow);
        
    }
    
    func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didReceive data: Data) {
        
        var buffer = [UInt8](repeating: 0, count: data.count)
        data.copyBytes(to: &buffer, count: data.count)
        self.outputStream?.write(buffer, maxLength: data.count)
        
        let totalLength = Float(dataTask.response?.expectedContentLength ?? -1)
        currentLength += Float(data.count)
        var progress = currentLength / totalLength
        if totalLength < 0 {
            progress = 0.0
        }
        
        delegate?.downloadFile(progress)
        print("接收到数据............... %.2f", progress)
    }

    func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
        print("请求完成")
        delegate?.endDownloadFile(error)
        if (error == nil) {
            
            // 不一定是成功
            // 数据是肯定可以请求完毕
            // 判断, 本地缓存 == 文件总大小 {filename: filesize: md5:xxx}
            // 如果等于 => 验证, 是否文件完整(file md5 )
            try? FileManager.default.moveItem(atPath: downLoadingPath!, toPath: downLoadedPath!)
        } else {
            print("有问题")
        }
        
        self.outputStream?.close()
        currentLength = 0
    }
}
