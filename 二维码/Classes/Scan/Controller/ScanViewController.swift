//
//  ScanViewController.swift
//  二维码
//
//  Created by 911 on 16/5/21.
//  Copyright © 2016年 bin. All rights reserved.
//

import UIKit
import AVFoundation

class ScanViewController: UIViewController {

    @IBOutlet weak var scanLine: UIImageView!
    //懒加载摄像设备
    @IBOutlet weak var scanCons: NSLayoutConstraint!
  
    @IBOutlet var backView: UIView!
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        beginScanAnimation()
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        //        endAniamtion()
        //        scan()
        
        MyQRCodeTool.shareInstance.changeRectOfInterest(backView.frame)
        MyQRCodeTool.shareInstance.scanQRCode(view, isDraw: true) { (resultStrs) in
            print(resultStrs)
        }
        
    }
    
    
    
    // 扫描冲击波多出来的部分, 没有被隐藏
    
    func beginScanAnimation() -> () {
        
        scanCons.constant = -backView.frame.size.height
        view.layoutIfNeeded()
        
        scanCons.constant = 0
        UIView.animateWithDuration(2) {
            // 重复的次数
            UIView.setAnimationRepeatCount(MAXFLOAT)
            
            self.view.layoutIfNeeded()
        }
        
        
    }
    
    
    func endAniamtion() -> () {
        scanLine.layer.removeAllAnimations()
    }

    
}