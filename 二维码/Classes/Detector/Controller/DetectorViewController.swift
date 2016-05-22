//
//  DetectorViewController.swift
//  二维码
//
//  Created by 911 on 12/5/21.
//  Copyright © 2012年 bin. All rights reserved.
//

import UIKit

import CoreImage

class DetectorViewController: UIViewController {

    @IBOutlet weak var imageView: UIImageView!
   


    @IBAction func detector(sender: AnyObject) {
      
        guard let image = imageView.image else {return}
        
        MyQRCodeTool.detectorQRCode(image, isDraw: true)
        
    }
    
        
}
