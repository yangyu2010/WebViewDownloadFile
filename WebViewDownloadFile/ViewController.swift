//
//  ViewController.swift
//  WebViewDownloadFile
//
//  Created by YangYu on 2019/10/18.
//  Copyright © 2019 YangYu. All rights reserved.
//

import UIKit
import WebKit

class ViewController: UIViewController {

    var webView: DownloaderWebView!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        webView = DownloaderWebView.loadFromNib()
        webView.frame = self.view.bounds
        self.view.addSubview(webView)
    }

}
