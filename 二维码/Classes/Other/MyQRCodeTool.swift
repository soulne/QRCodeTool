//
//  QRCodeTool.swift
//  读取二维码
//
//  Created by 911 on 14/4/21.
//  Copyright © 2014年 911. All rights reserved.
//

import UIKit
import AVFoundation




typealias ScanResultBlock = (resultStrs: [String]) -> ()

enum Level: String {
    case Low = "L"
    case Higth = "H"
    case Middle = "M"
    case QBUZHIDAO = "Q"
}

class MyQRCodeTool: NSObject {
    
    
    // 单例对象
    static let shareInstance: MyQRCodeTool = MyQRCodeTool()
    
    // 用作扫描的时候, 是否需要绘制二维码边框的属性
    // 可以暴露给外界进行复制
    var isDraw: Bool = false
    
    
    // 记录扫描结果的代码块
    private var resultBlock: ScanResultBlock?
    
    
    
    
    // 懒加载创建只需要创建一次的属性
    // 懒加载输入
    private lazy var input: AVCaptureDeviceInput? = {
        // 1. 获取摄像头设备
        // 1.1 把摄像头当做一个输入设备
        let device = AVCaptureDevice.defaultDeviceWithMediaType(AVMediaTypeVideo)
        var input: AVCaptureDeviceInput?
        do {
            input = try AVCaptureDeviceInput(device: device)
        }catch {
            print(error)
            return nil
        }
        
        return input
        
    }()
    
    // 懒加载输出
    private lazy var output: AVCaptureMetadataOutput = {
        // 2. 创建一个(元数据)输出处理对象
        let output = AVCaptureMetadataOutput()
        // 2.1 设置代理, 拿到处理的结果
        output.setMetadataObjectsDelegate(self, queue: dispatch_get_main_queue())
        return output
    }()
    
    // 创建一个会话, 链接输入和输出
    private lazy var session: AVCaptureSession = {
        
        let session = AVCaptureSession()
        return session
        
    }()
    
    // 引用当前的视频预览图层
    private lazy var layer: AVCaptureVideoPreviewLayer = {
        
        let layer = AVCaptureVideoPreviewLayer(session: self.session)
        return layer
        
    }()
    
    
    
    func scanQRCode(inView: UIView, isDraw: Bool, resultBlock: ScanResultBlock?)   {
        
        
        // 0. 记录代码块, 然后, 在合适的地方执行
        // 合适的地方: 就是看下, 代码块里面需要的值, 在哪个地方有
        self.resultBlock = resultBlock
        self.isDraw = isDraw
        
        
        // 容错处理
        // 如果已经添加过了, 就不会再次添加
        if session.canAddInput(self.input) && session.canAddOutput(self.output) {
            session.addInput(self.input)
            session.addOutput(self.output)
        }
        
        // 设置元数据输出处理对象, 处理数据的类型
        // 处理所有支持的类型 output.availableMetadataObjectTypes
        // 二维码
        // 一定要注意
        // 这行代码, 只能写在, 输出对象, 添加到会话之后
        output.metadataObjectTypes = [AVMetadataObjectTypeQRCode]
        
        // 4. 启动会话(让输入开始采集数据, 让输出, 开始处理数据)
        session.startRunning()
        
        
        // 4.1 添加视频预览图层
        // 可以让用户看到扫描的二维码
        // 不是必须()
        // 容错处理: 防止添加多次
        let subLayers = inView.layer.sublayers
        if subLayers == nil || !subLayers!.contains(layer) {
            layer.frame = inView.layer.bounds
            inView.layer.insertSublayer(layer, atIndex: 0)
        }
        
        
        
        
        
        
    }
    
    
    // 兴趣区域, 可以动态的设置
    // 即使在扫描的过程当中, 也可以去修改
    func changeRectOfInterest(originRect: CGRect) -> () {
        //         5. 设置输出的兴趣区域(限定扫描区域)
        //         注意事项:
        //              1. 里面的取值, 是一个0-->1的比例
        //              2. 坐标相对应的坐标系是: 右上角为0, 0 (横屏状态下的坐标系)
        
        let size = UIScreen.mainScreen().bounds.size
        let x: CGFloat = originRect.origin.x / size.width
        let y: CGFloat = originRect.origin.y / size.height
        let w: CGFloat = originRect.size.width / size.width
        let h: CGFloat = originRect.size.height / size.height
        
        output.rectOfInterest = CGRectMake(y, x, h, w)
        
    }
    
    
    
    
    
    // 根据指定的字符串, 以及自定义的中间图片, 生成一个二维码图片,并返回出去
    // 参数1: 二维码的输入内容
    // 参数2: 生成后的合成图片
    class func generatorQRCode(inputStr: String,inputLevel: Level , centerImage: UIImage?) -> UIImage? {
        
        let content = inputStr
        
        // 生成二维码
        
        // 1. 创建二维码滤镜
        let filter = CIFilter(name: "CIQRCodeGenerator")
        
        // 1.1 恢复滤镜默认设置
        filter?.setDefaults()
        
        // 2. 设置滤镜的输入内容
        // 通过KVC 给里面一个inputMessage 赋值
        // 输入的内容类型一定是NSData
        let data = content.dataUsingEncoding(NSUTF8StringEncoding)
        filter?.setValue(data, forKey: "inputMessage")
        
        // 3.2 设置二维码纠错率
        // 纠错率越高, 二维码图片,越复杂, 扫描识别的时间越长
        filter?.setValue(inputLevel.rawValue, forKey: "inputCorrectionLevel")
        
        
        // 3. 从滤镜里面取出结果图片
        // 3.1 注意: 取出的图片是ciimage, 并且大小是23* 23 所以需要我们单独处理
        // (23.0, 23.0)
        guard let outImage = filter?.outputImage else {
            return nil
        }
        
        
        // 3.1 图片处理
        // 使用这种方式, 可以把图片放大处理, 而且保证不失真
        let transform = CGAffineTransformMakeScale(20, 20)
        let resultImage = outImage.imageByApplyingTransform(transform)
        
        // 把CIImage转换成为UIImage
        var image = UIImage(CIImage: resultImage)
        
        if centerImage != nil {
            // 3.3 自定义二维码
            image = createImage(image, centerImage: centerImage!)
        }
        
        return image
        
        
    }
    
    
    // 根据给定的二维码图片, 返回识别到的结果数组
    // 参数1: 二维码图片
    // 参数2: 是否需要绘制识别到的二维码边框
    // 返回值: 元组(识别到的结果, 绘制边框后的图片)
    class func detectorQRCode(image: UIImage, isDraw: Bool) -> (resultStrs: [String], image: UIImage) {
        
        // 识别图片二维码
        
        // 1. 创建一个二维码探测器
        let detector = CIDetector(ofType: CIDetectorTypeQRCode, context: nil, options: [CIDetectorAccuracy : CIDetectorAccuracyHigh])
        
        // 2. 探测二维码图片的特征
        
        let imageCI = CIImage(image: image)
        let features = detector.featuresInImage(imageCI!)
        
        // 3. 处理识别到的特征值
        //        print(features)
        
        // 需要绘制边框的结果图片
        var tempImage = image
        
        // 存放二维码识别的结果
        var resultStrs = [String]()
        
        for feature in features {
            
            // 二维码的特征对象
            if feature.isKindOfClass(CIQRCodeFeature) {
                let qrCodeFeature = feature as! CIQRCodeFeature
                
                //                print(qrCodeFeature.messageString)
                
                resultStrs.append(qrCodeFeature.messageString)
                
                // 绘制识别到的二维码图片
                //                print(qrCodeFeature.bounds)
                
                if isDraw {
                    tempImage = drawQRCodeFrame(tempImage, feature: qrCodeFeature)
                }
                
                
                
            }
            
            
        }
        
        return (resultStrs, tempImage)
        
    }
    
    
    
    
}


// 工具类封装注意
// 如果是私有方法, 直接放到一个类扩展里面, 不要直接和需要暴露给外界的接口写到一块,
// 如果是私有方法, 不要直接暴露给外界使用(外界使用)
extension MyQRCodeTool {
    
    
    // 根据一个二维码特征, 绘制边框到二维码上面, 并且生成一个新的图片
    private class func drawQRCodeFrame(image: UIImage, feature: CIQRCodeFeature) -> UIImage {
        
        
        // 相对于原始图片, 坐标
        // 左下角是0, 0
        // 所以, 我们需要翻转坐标系(采用这种方案比较简单), 或者转换坐标点
        // 注意: 我们要求的是绘制的边框翻转, 而不是图片+边框
        // 所以, 应该在绘制边框之后, 再翻转坐标系
        let bounds = feature.bounds
        let size = image.size
        
        // 1. 开启上下文
        UIGraphicsBeginImageContext(size)
        
        
        // 2. 绘制大图片
        image.drawInRect(CGRectMake(0, 0, size.width, size.height))
        
        // 翻转绘图的坐标系
        // 获取当前上下文
        let context = UIGraphicsGetCurrentContext()
        // 按Y轴, 缩放-1,
        CGContextScaleCTM(context, 1, -1)
        // 需要往下平移一个高度
        CGContextTranslateCTM(context, 0, -size.height)
        
        
        // 3. 绘制边框
        let path = UIBezierPath(rect: bounds)
        // 设置边框颜色
        UIColor.redColor().setStroke()
        // 设置线宽
        path.lineWidth = 6
        // 开始绘制线条
        path.stroke()
        
        
        // 4. 取出结果图片
        let resultImage = UIGraphicsGetImageFromCurrentImageContext()
        
        // 5. 关闭上下文
        UIGraphicsEndImageContext()
        
        // 6. 返回结果
        return resultImage
        
    }
    
    
    
    // 私有方法
    // 根据两张图片, 生成一个合成后的图片
    private class func createImage(sourceImage: UIImage, centerImage: UIImage) -> UIImage {
        
        let size = sourceImage.size
        
        // 1. 开启上下文
        UIGraphicsBeginImageContext(size)
        
        // 2. 绘制大图片
        sourceImage.drawInRect(CGRectMake(0, 0, size.width, size.height))
        
        // 3. 绘制小图片
        let w: CGFloat = 90
        let h: CGFloat = 90
        let x: CGFloat = (size.width - w) * 0.5
        let y: CGFloat = (size.height - h) * 0.5
        
        centerImage.drawInRect(CGRectMake(x, y, w, h))
        
        
        // 4. 获取合成的图片
        let resultImage = UIGraphicsGetImageFromCurrentImageContext()
        
        // 5. 关闭上下文
        UIGraphicsEndImageContext()
        
        // 6. 返回结果
        return resultImage
        
    }
    
    
    
    private func drawQRCodeFrame(qrCodeObj: AVMetadataMachineReadableCodeObject) -> () {
        
        
        // 借助一个图形layer
        // 1. 创建形状图层
        let shapLayer = CAShapeLayer()
        shapLayer.fillColor = UIColor.clearColor().CGColor
        shapLayer.strokeColor = UIColor.redColor().CGColor
        shapLayer.lineWidth = 6
        
        // 2. 给layer, 设置一个形状路径, 让layer来展示
        
        let corners = qrCodeObj.corners
        
        let path = UIBezierPath()
        
        var index = 0
        for corner in corners {
            
            //            {
            //                X = "154.7997282646955";
            //                Y = "431.3352825435441";
            //            }
            
            var point = CGPointZero
            CGPointMakeWithDictionaryRepresentation((corner as! CFDictionary), &point)
            
            
            // 如果第一个点, 移动路径过去, 当做起点
            if index == 0 {
                path.moveToPoint(point)
            }else {
                path.addLineToPoint(point)
            }
            // 如果不是第一个点, 添加一个线到这个点
            
            
            index += 1
            
        }
        
        
        path.closePath()
        
        
        // 2.1 根据四个角对应的坐标, 转换成为一个path
        
        // 2.2 给layer 的path 进行赋值
        shapLayer.path = path.CGPath
        
        // 3. 添加形状图层, 到需要展示的图层上面
        layer.addSublayer(shapLayer)
        
    }
    
    private func removeQRCodeFrame() -> () {
        
        guard let subLayers = layer.sublayers else {
            return
        }
        for subLayer in subLayers {
            if subLayer.isKindOfClass(CAShapeLayer) {
                subLayer.removeFromSuperlayer()
            }
        }
        
        
        
    }
    
}


extension MyQRCodeTool: AVCaptureMetadataOutputObjectsDelegate {
    
    // 扫描到结果, 调用这个方法, 来告诉我们识别的结果
    func captureOutput(captureOutput: AVCaptureOutput!, didOutputMetadataObjects metadataObjects: [AnyObject]!, fromConnection connection: AVCaptureConnection!) {
        
        // 最后如果没有扫描到二维码内容的时候, 也会调用一次
        if self.isDraw {
            removeQRCodeFrame()
        }
        
        // 小技巧: 先打印出来结果, 然后, 反着去找对应的类
        //        print(metadataObjects)
        
        
        var resultStrs = [String]()
        for metaObj in metadataObjects {
            if metaObj.isKindOfClass(AVMetadataMachineReadableCodeObject) {
                
                // 就是把坐标转换成为, 在layer层上面的真实坐标
                let transformObj = layer.transformedMetadataObjectForMetadataObject(metaObj as! AVMetadataObject)
                
                let qrCodeObj = transformObj as! AVMetadataMachineReadableCodeObject
                
                //                let qrCodeObj = qrCodeObj as! AVMetadataMachineReadableCodeObject
                
                // corners: 二维码的四个角
                // 得到的结果, 是点对应的字典组成的数组
                // 并且, 点坐标, 没法直接使用
                // 需要借助layer, 进行转换成为, 我们可以直接处理的坐标
                //                print(qrCodeObj.corners)
                
                if self.isDraw {
                    drawQRCodeFrame(qrCodeObj)
                }
                
                // stringValue: 二维码的具体内容
                resultStrs.append(qrCodeObj.stringValue)
            }
        }
        
        if self.resultBlock != nil
        {
            self.resultBlock!(resultStrs: resultStrs)
            
        }
        
        
        
    }
    
    
    
    
}





