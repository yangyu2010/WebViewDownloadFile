//
//  DownloaderWebView.swift
//  WebViewDownloadFile
//
//  Created by YangYu on 2019/10/21.
//  Copyright © 2019 YangYu. All rights reserved.
//

import UIKit

class DownloaderWebView: UIView, NibLoadable {

    @IBOutlet weak var textField: UITextField!
    @IBOutlet weak var webView: UIWebView!
    
    var downloader: WebDownloader!
    
    // MARK:- View
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        textField.delegate = self
        
        downloader = WebDownloader()
        downloader.realURLCompletion = {[unowned self]  (str: String?) -> Void in
            self.textField.text = str
        }
        webView.delegate = downloader

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
        webView.loadRequest(URLRequest(url: url))
    }
}


extension DownloaderWebView: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        loadRequest()
        return true
    }
}
