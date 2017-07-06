//
//  ViewController.swift
//  CGDemo
//
//  Created by Xiao Xiao on 平成29-07-06.
//  Copyright © 平成29年 Xiao Xiao. All rights reserved.
//

import UIKit
import ImageIO

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Works fine with JPEG
        let JPEGfileURL = Bundle.main.url(forResource: "R0003103", withExtension: "JPG")
        editEXIF(imageURL: JPEGfileURL!)
        
        // Problem with RAW
        let RAWfileURL = Bundle.main.url(forResource: "R0003095", withExtension: "DNG")
        editEXIF(imageURL: RAWfileURL!)
        
    }
    
    func editEXIF(imageURL:URL) {
        
        // Read EXIF properties from Image file
        let options = [String(kCGImageSourceShouldCache): false, String(kCGImageSourceShouldAllowFloat): true] as NSDictionary as CFDictionary
        let imageSource = CGImageSourceCreateWithURL(imageURL as CFURL, options)
        guard imageSource != nil else {return}
        guard let imageProperties = CGImageSourceCopyPropertiesAtIndex(imageSource!, 0, nil) else {return}
        let properties = NSMutableDictionary(dictionary: imageProperties)
        
        // Since this is a demo, editing properties is omitted.
        
        // Save the edited EXIF properties
        
        let UTI = CGImageSourceGetType(imageSource!) // Get the original image's UTI, JPG is 'public.jpeg', RAW is 'com.adobe.raw-image', but I also tried 'public.camera-raw-image' for RAW, which didn't change the result
        print(UTI ?? "UTI is nil")
        let finalImageData = CFDataCreateMutable(nil, 0)
        guard finalImageData != nil else {
            NSLog("***Could not create image data ***");
            return
        }
        
        let destination = CGImageDestinationCreateWithData(finalImageData!,UTI!,1,nil); // This is where the Problem is, it returns nil when I send a RAW file's UTI in.
        guard destination != nil else{
            NSLog("***Could not create image destination ***");
            return
        }
        NSLog("Yes It works")
        
        CGImageDestinationAddImageFromSource(destination!,imageSource!,0,properties as CFDictionary);
        
        let success = CGImageDestinationFinalize(destination!);
        guard success != false else {
            return
        }
        let imageData = finalImageData! as NSData
        imageData.write(to: imageURL, atomically: true)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

