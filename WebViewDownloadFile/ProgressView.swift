//
//  ProgressView.swift
//  WebViewDownloadFile
//
//  Created by YangYu on 2019/10/21.
//  Copyright © 2019 YangYu. All rights reserved.
//

import UIKit

class ProgressView: UIView {

    var progress: Float {
        didSet {
            self.setNeedsDisplay()
        }
    }
    
    private var progressLayer = CAShapeLayer()

    override init(frame: CGRect) {
        progress = 0
        super.init(frame: frame)
        setUp()
    }
    
    required init?(coder aDecoder: NSCoder) {
        progress = 0
        super.init(coder: aDecoder)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setUp()
    }
    
    func setUp() {
        backgroundColor = UIColor.clear
        
        progressLayer.fillColor = UIColor.clear.cgColor
        progressLayer.strokeColor = UIColor.white.cgColor
        progressLayer.opacity = 1
        progressLayer.lineCap = .round
        progressLayer.lineWidth = 5
        
        progressLayer.shadowColor = UIColor.black.cgColor
        progressLayer.shadowOffset = CGSize(width: 1, height: 1)
        progressLayer.shadowOpacity = 0.5
        progressLayer.shadowRadius = 2
        
    }
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        
        let center = CGPoint(x: rect.width * 0.5, y: rect.height * 0.5)
        let radius = rect.size.width * 0.5
        let startA = -CGFloat.pi * 0.5
        let endA = -CGFloat.pi * 0.5 + CGFloat.pi * 2.0 * CGFloat(progress)

        progressLayer.frame = self.bounds

        let path = UIBezierPath(arcCenter: center, radius: radius, startAngle: startA, endAngle: endA, clockwise: true)
        progressLayer.path = path.cgPath

        progressLayer.removeFromSuperlayer()
        self.layer.addSublayer(progressLayer)
    }
}
