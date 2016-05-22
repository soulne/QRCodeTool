//
//  GeneratorViewController.swift
//  二维码
//
//  Created by 911 on 16/5/21.
//  Copyright © 2016年 bin. All rights reserved.
//

import UIKit
import CoreImage

//生成二维码
class GeneratorViewController: UIViewController {

  
    @IBOutlet weak var imageView: UIImageView!
    
    @IBOutlet weak var textField: UITextField!
    @IBAction func buttonClick(sender: AnyObject) {
    
//        //创建二维码滤镜
//        let filter = CIFilter(name: "CIQRCodeGenerator")
//        //回复滤镜默认设置
//        filter?.setDefaults()
//        //字符串数据
//        let data = textField.text?.dataUsingEncoding(NSUTF8StringEncoding)
//        //通过KVC设置滤镜inputMessage数据
//        filter?.setValue(data, forKey: "inputMessage")
//        
//        //获得滤镜输出的图像
//        let outputImage = filter?.outputImage
//        //大小默认是23 * 23
//        //将CIImage转换成UIImage，并放大显示
//        let ciImage = outputImage?.imageByApplyingTransform(CGAffineTransformMakeScale(20, 20))
//        
//        let image = UIImage(CIImage: ciImage!)
//        
//        imageView.image = image;

        let image = MyQRCodeTool.generatorQRCode(textField.text!, inputLevel: Level.Higth, centerImage: nil)
        
        imageView.image = image
        
        /** 根据CIImage生成指定大小的高清UIImage :param: image 指定CIImage :param: size 指定大小 :returns: 生成好的图片 */
        //private func createBigImage(image: CIImage, size: CGFloat) -> UIImage { let extent: CGRect = CGRectIntegral(image.extent) let scale: CGFloat = min(size/CGRectGetWidth(extent), size/CGRectGetHeight(extent)) 
        // 1.创建bitmap; let width = CGRectGetWidth(extent) * scale 
//        let height = CGRectGetHeight(extent) * scale
//        let cs: CGColorSpaceRef = CGColorSpaceCreateDeviceGray()!
//        let bitmapRef = CGBitmapContextCreate(nil, Int(width), Int(height), 8, 0, cs, 0)!
//        let context = CIContext(options: nil)
//        let bitmapImage: CGImageRef = context.createCGImage(image, fromRect: extent)
//        CGContextSetInterpolationQuality(bitmapRef, CGInterpolationQuality.None)
//        CGContextScaleCTM(bitmapRef, scale, scale);
//        CGContextDrawImage(bitmapRef, extent, bitmapImage);
        // 2.保存bitmap到图片 let scaledImage: CGImageRef = CGBitmapContextCreateImage(bitmapRef)! return UIImage(CGImage: scaledImage) }
        
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        view.endEditing(true)
        
    }

    
}
