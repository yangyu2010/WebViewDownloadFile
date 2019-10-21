//
//  DownloaderWebView.swift
//  WebViewDownloadFile
//
//  Created by YangYu on 2019/10/21.
//  Copyright © 2019 YangYu. All rights reserved.
//

import UIKit
import WebKit

class DownloaderWebView: UIView, NibLoadable {

    @IBOutlet weak var textField: UITextField!
    @IBOutlet weak var webView: WKWebView!
    @IBOutlet weak var downloadingView: UIView!
    @IBOutlet weak var progressView: ProgressView!
    
    var downloader: WebDownloader!
    
    // MARK:- View

    override func awakeFromNib() {
        super.awakeFromNib()
        
        textField.delegate = self
        
        downloader = WebDownloader()
        downloader.delegate = self

        webView.navigationDelegate = downloader
        
        #if DEBUG
        webView.load(URLRequest(url: URL(string: "https://www.baidu.com")!))
        #endif
    }
    
    // MARK:- Action
    
    @IBAction func actionBack(_ sender: Any) {
        webView.goBack()
    }
    
    @IBAction func actionAdvance(_ sender: Any) {
        webView.goForward()
    }
    
    @IBAction func actionSaveHTML(_ sender: Any) {
        
        // 获取当前的URL等
        guard var urlString = self.textField.text else { return }
        guard let currentURL = URL(string: urlString) else { return }
        guard urlString.count > 0 else { return }
        
        // 分割?后面的参数
        if let first = urlString.split(separator: "?").first {
            urlString = String(first)
        }
        
        var pathComponent = (urlString as NSString).lastPathComponent
        
        // 大于10个字符, 直接改成临时名
        if pathComponent.count > 20 {
            pathComponent = "page"
        }

        // 判断保存的路径是否已经存在, 若存在, 往上加
        var savePath = kCachePath + "/" + pathComponent + ".html"
        var count = 1
        while FileManager.default.fileExists(atPath: savePath) {
            savePath = kCachePath + "/" + pathComponent + "(\(count))" + ".html"
            count += 1
        }

        let savePathURL = URL(fileURLWithPath: savePath)
        
        // 读取html
        guard let data = try? Data(contentsOf: currentURL) else {
            print("html读取内容失败")
            return
        }

        // 保存html
        do {
            try data.write(to: savePathURL)
            print("html保存到本地成功")
        } catch {
            print("html保存到本地失败")
            print(error.localizedDescription)
        }
    }
    
    @IBAction func actionRefresh(_ sender: Any) {
        webView.reload()
    }
    
    @IBAction func actionDelete(_ sender: Any) {
    }
    
    
    // MARK:- WebView
    
    func loadRequest() {
        guard var text = textField.text,
            text.count > 0 else {
                return
        }
        
        if text.hasPrefix("https") == false &&
            text.hasPrefix("http") == false {
            text = "https://" + text
        }
        
        guard let url = URL(string: text) else { return }
        webView.load(URLRequest(url: url))
    }
}


extension DownloaderWebView: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        loadRequest()
        return true
    }
}


extension DownloaderWebView: WebDownloaderDelegate {
    func startRequestWith(_ urlString: String?) {
        textField.text = urlString
    }
    
    func startDownloadFile() {
        downloadingView.isHidden = false
    }
    
    func downloadFile(_ progress: Float) {
        progressView.progress = progress
    }
    
    func endDownloadFile(_ error: Error?) {
        downloadingView.isHidden = true
    }
    
    
}
