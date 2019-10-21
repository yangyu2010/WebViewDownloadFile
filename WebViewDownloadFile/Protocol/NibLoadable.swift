//
//  NibLoadable.swift
//  WebViewDownloadFile
//
//  Created by YangYu on 2019/10/21.
//  Copyright © 2019 YangYu. All rights reserved.
//  保证xib里面设置了类型

import UIKit


protocol NibLoadable {
    
}

extension NibLoadable where Self: UIView {
    static func loadFromNib(nibName: String? = nil) -> Self {
        let loadName = (nibName == nil) ? "\(self)" : nibName!
        return Bundle.main.loadNibNamed(loadName, owner: nil, options: nil)?.first as! Self
    }
}
