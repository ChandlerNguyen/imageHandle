//
//  LMImageFilter.swift
//  FilterShowcase
//
//  Created by wzkj on 2017/1/19.
//  Copyright © 2017年 Sunset Lake Software. All rights reserved.
//

import UIKit
import AVFoundation
import GPUImage

/// 媒体类型
///
/// - Camera: 相机
/// - Video: 视频
/// - LocalVideo: 本地视频
/// - StillImage: 静态图片
public enum LMMediaType: Int {
    case Camera
    case Video
    case LocalVideo
    case StillImage
}

class LMImageFilter : UIViewController {
    private var mediaType:LMMediaType
    private var imageSource:ImageSource!
    private var filter: BasicOperation!//SaturationAdjustment!
    private var isRecording = false
    private var movieOutput:MovieOutput? = nil
    private var renderView:RenderView!
    
    init(mediaType:LMMediaType, sessionPresset:String, cameraPosition:AVCaptureDevicePosition) {
        self.mediaType = mediaType
        do {
            switch mediaType {
            case .Camera:
                let camera:Camera = try Camera(sessionPreset: sessionPresset, cameraDevice: nil, location: .backFacing, captureAsYUV: true)
                camera.runBenchmark = true
                filter = SaturationAdjustment()
                renderView = RenderView(frame: CGRect.zero)
                camera --> filter --> renderView
                self.imageSource = camera
                camera.startCapture()
                break
            case .Video:
                
                break
            default: break
                
            }
        } catch{
            fatalError("Could not initialize rendering pipeline: \(error)")
        }
        
        super.init(nibName: nil, bundle: nil)
    }
    
    init(sourceImage:AnyObject) {
        self.mediaType = .StillImage
        var picture:PictureInput?
        
        if sourceImage is UIImage {
            picture = PictureInput(image: sourceImage as! UIImage)
        }else if sourceImage is NSString {
            picture = PictureInput(imageName: sourceImage as! String)
        }
        filter =  LMAutoLevels()//SaturationAdjustment()
        renderView = RenderView(frame: CGRect.zero)
        
        if picture != nil {
            picture! --> filter --> renderView
            picture?.processImage()
            self.imageSource = picture
        }
        
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.renderView.frame = view.frame
        self.view.addSubview(self.renderView)
        
        let tap:UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(LMImageFilter.tapAction(sender:)))
        tap.numberOfTapsRequired = 1
        tap.numberOfTouchesRequired = 1
        renderView.addGestureRecognizer(tap)
    }
    
    // MARK: 初始化
    func tapAction(sender:AnyObject) {
        if filter is SaturationAdjustment {
            (filter as! SaturationAdjustment).saturation += 0.2
        }
        
        if imageSource is PictureInput {
            (imageSource as! PictureInput).processImage()
        }
    }
}
