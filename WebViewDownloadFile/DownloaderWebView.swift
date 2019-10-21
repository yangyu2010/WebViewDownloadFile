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
    }
    
    @IBAction func actionAdvance(_ sender: Any) {
    }
    
    @IBAction func actionSaveHTML(_ sender: Any) {
    }
    
    @IBAction func actionRefresh(_ sender: Any) {
    }
    
    @IBAction func actionDelete(_ sender: Any) {
    }
    
    
    // MARK:- WebView
    
    func loadRequest() {
        guard var text = textField.text,
            text.count > 0 else {
                return
        }
        
        if text.hasPrefix("https") == false ||
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
