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
    lazy var device : AVCaptureDevice = {
        return AVCaptureDevice.defaultDeviceWithMediaType(AVMediaTypeVideo)
    }()
    //懒加载 通过摄像头加载输入对象
    lazy var input : AVCaptureInput = {
        var input : AVCaptureInput?
        //设置输入对象为摄像头
        do {
             input = try AVCaptureDeviceInput(device: self.device)
        }catch{
            print(error)
        }
        return input!
    }()
    
    //懒加载 元数据输出对象
    lazy var output : AVCaptureMetadataOutput = {
        let output = AVCaptureMetadataOutput()
        output.setMetadataObjectsDelegate(self, queue: dispatch_get_main_queue())
       return output
    }()
    
    //懒加载 会话对象
    lazy var session : AVCaptureSession = {
       return AVCaptureSession()
    }()
    
    //懒加载 视频图层
    lazy var previewLayer : AVCaptureVideoPreviewLayer = {
        let preview = AVCaptureVideoPreviewLayer(session: self.session)
        preview.frame = self.view.bounds
        self.view.layer.insertSublayer(preview, atIndex: 0)
        return preview
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        //添加会话输入
        session.addInput(input)
        //添加会话输出
        session.addOutput(output)
        //设置输出元数据的类型
        output.metadataObjectTypes = [AVMetadataObjectTypeQRCode]
        //开始扫描
        session.startRunning()
        
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        beginScanAnimation()
        
    }
    
    func beginScanAnimation(){
        self.scanCons.constant = -self.scanLine.bounds.height
        view.layoutIfNeeded()
        self.scanCons.constant = 0
        UIView.animateWithDuration(2) {
            UIView.setAnimationRepeatCount(MAXFLOAT)
            self.view.layoutIfNeeded()
        }
    }
    
}

//元数据输出代理
extension ScanViewController : AVCaptureMetadataOutputObjectsDelegate {
    func captureOutput(captureOutput: AVCaptureOutput!, didOutputMetadataObjects metadataObjects: [AnyObject]!, fromConnection connection: AVCaptureConnection!){
        
        removeQRCodeFrame()
        
        for object in metadataObjects {
            let result = previewLayer.transformedMetadataObjectForMetadataObject(object as! AVMetadataObject)
            
            let qrCodeObj = result as! AVMetadataMachineReadableCodeObject
            
            drawQRCodeFrame(qrCodeObj)
            
        }
        
    }
    
}


extension ScanViewController {
    //MARK:- 在视频图层加二维码识别边框
    private func drawQRCodeFrame(qrCodeObj : AVMetadataMachineReadableCodeObject) {
        
        let shapeLayer = CAShapeLayer()
        shapeLayer.fillColor = UIColor.clearColor().CGColor
        shapeLayer.strokeColor = UIColor.redColor().CGColor
        shapeLayer.lineWidth = 6
        
        let corners = qrCodeObj.corners
        
        var index = 0
        let path = UIBezierPath()
        for corner in corners {
            var point = CGPointZero
            CGPointMakeWithDictionaryRepresentation((corner as! CFDictionary), &point)
            
            if index == 0 {
                path.moveToPoint(point)
            }else{
                path.addLineToPoint(point)
            }
            
            index += 1
        }
        path.closePath()
        
        shapeLayer.path = path.CGPath
        previewLayer.addSublayer(shapeLayer)
    }
    
    //Mark:- 删除所有的框框
    private func removeQRCodeFrame(){
        guard let subLayers = previewLayer.sublayers else{return}
        for subLayer in subLayers {
            if subLayer.isKindOfClass(CAShapeLayer){
                subLayer.removeFromSuperlayer()
            }
        }
    }
}