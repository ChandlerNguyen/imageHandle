//
//  LMGLFilterImageView.swift
//  FilterShowcase
//
//  Created by wzkj on 2017/1/10.
//  Copyright © 2017年 Cell Phone. All rights reserved.
//


/**
 objc调swift 创建一个objc工程 创建一个.swift文件 创建时会弹出一个对话框询问你“Would You like to configure an Objective-C bridging Header”，选择YES即可 在类前面声明为@objc，@objc所声明的类能够被Objective-C访问 进入工程target，选择当前taget的工程文件 修改Build Setting Defines Module 选择YES Product Module Name 输入你的taget名字 在objc文件添加引用 #import "YourProjectName-swift.h" 编译一次，就可以在objc内调就可以调用swift类 swift调objc 找到刚才创建的bridding header文件，即YourTargetName-Bridging-Header.h 在该文件内引用你的objc文件 此时就可以在swift内访问objc类。
 ***/


import UIKit
import GLKit
import OpenGLES

struct LMGLFilterParameter {
    var name: String?
    var key: String
    var minimumValue: Float?
    var maximumValue: Float?
    var currentValue: Float
    
    init(key: String, value: Float) {
        self.key = key
        self.currentValue = value
    }
    
    init(name: String, key: String, minimumValue: Float, maximumValue: Float, currentValue: Float)
    {
        self.name = name
        self.key = key
        self.minimumValue = minimumValue
        self.maximumValue = maximumValue
        self.currentValue = currentValue
    }
}
// @objc 该类可以在objc中调用
class LMGLFilterImageView : GLKView{
    /** gl上下文 */
    var ciContext: CIContext!
    /** 滤镜 */
    var ciFilter:CIFilter!{
        didSet{
            setNeedsDisplay()
        }
    }
    /** 处理的图片 */
    var inputImage: UIImage! {
        didSet{
            setNeedsDisplay()
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame, context: EAGLContext(api: .openGLES2))
        ciContext = CIContext(eaglContext: context);
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.context = EAGLContext(api: .openGLES2)
        ciContext = CIContext(eaglContext: context)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.setNeedsDisplay()
    }
    
    override func draw(_ rect: CGRect) {
        if ciContext != nil && inputImage != nil && ciFilter != nil {
            let ciInputimage:CIImage = CIImage(cgImage: inputImage.cgImage!)
            ciFilter.setValue(ciInputimage, forKey: kCIInputImageKey)
            if let outputImage = ciFilter.outputImage {
                clearBackground()
                
                let inputBounds = ciInputimage.extent;
                let drawableBounds = CGRect(x: 0, y: 0, width: self.drawableWidth, height: self.drawableHeight);
                let targetBounds = imageBoundsForContentMode(fromRect: inputBounds, toRect: drawableBounds)
                
                ciContext.draw(outputImage, in: targetBounds, from: inputBounds)
            }
        }
    }
    
    /** private */
    // 清除背景色
    func clearBackground(){
        var r:CGFloat = 0
        var g:CGFloat = 0
        var b:CGFloat = 0
        var a:CGFloat = 0
        
        backgroundColor?.getRed(&r, green: &g, blue: &b, alpha:&a)
        glClearColor(GLfloat(a), GLfloat(b), GLfloat(b), GLfloat(a))
        glClear(GLbitfield(GL_COLOR_BUFFER_BIT))
    }
    
    func aspectFit(fromRect: CGRect, toRect: CGRect) -> CGRect {
        let fromAspectRatio = fromRect.size.width / fromRect.size.height;
        let toAspectRatio = toRect.size.width / toRect.size.height;
        
        var fitRect = toRect
        
        if (fromAspectRatio > toAspectRatio) {
            fitRect.size.height = toRect.size.width / fromAspectRatio;
            fitRect.origin.y += (toRect.size.height - fitRect.size.height) * 0.5;
        } else {
            fitRect.size.width = toRect.size.height  * fromAspectRatio;
            fitRect.origin.x += (toRect.size.width - fitRect.size.width) * 0.5;
        }
        
        return fitRect.integral
    }
    
    func aspectFill(fromRect: CGRect, toRect: CGRect) -> CGRect {
        let fromAspectRatio = fromRect.size.width / fromRect.size.height;
        let toAspectRatio = toRect.size.width / toRect.size.height;
        
        var fillRect = toRect
        
        if (fromAspectRatio > toAspectRatio) {
            fillRect.size.width = toRect.size.height  * fromAspectRatio;
            fillRect.origin.x += (toRect.size.width - fillRect.size.width) * 0.5;
        } else {
            fillRect.size.height = toRect.size.width / fromAspectRatio;
            fillRect.origin.y += (toRect.size.height - fillRect.size.height) * 0.5;
        }
        
        return fillRect.integral
    }
    
    func imageBoundsForContentMode(fromRect: CGRect, toRect: CGRect) -> CGRect {
        switch contentMode {
        case .scaleAspectFit:
            return aspectFit(fromRect: fromRect, toRect: toRect)
        case .scaleAspectFill:
            return aspectFill(fromRect: fromRect, toRect: toRect)
        default:
            return fromRect
        }
    }
    
    // delegate
    //    func parameterValueDidChange(parameter: ScalarFilterParameter) {
    //        filter.setValue(parameter.currentValue, forKey: parameter.key)
    //        setNeedsDisplay()
    //    }
    
}

class LMGLFilterPreviewCell: UICollectionViewCell {
    var filterView:LMGLFilterImageView
    var title:UILabel
    
    var ciFilter: CIFilter? {
        get {
            return self.ciFilter;
        }
        set {
            if self.ciFilter == nil {
                self.ciFilter = newValue
                if self.ciFilter != nil{
                    filterView.ciFilter = self.ciFilter
                }
            }
        }
    }
    
    override init(frame: CGRect) {
        filterView = LMGLFilterImageView(frame: CGRect(x: 0, y: 0, width: 0, height: 0))
        filterView.inputImage = #imageLiteral(resourceName: "flower.jpg")
        title = UILabel(frame: CGRect(x: 0, y: 0, width: 0, height: 0))
        title.font = UIFont.systemFont(ofSize: 12)
        super.init(frame: frame)
        
        self.addSubview(filterView)
        self.addSubview(title)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        filterView.frame = CGRect(x: 0, y: 0, width: self.frame.size.width, height: self.frame.size.height - 20)
        title.frame = CGRect(x: 0, y: filterView.frame.size.height, width: self.frame.size.width, height: 20)
    }
}


@objc class LMGLFilterImageController : UIViewController,UICollectionViewDataSource,UICollectionViewDelegate,UICollectionViewDelegateFlowLayout{
    var filterView : LMGLFilterImageView
    var collection : UICollectionView
    
    let filterDescriptors:[(filterName:NSString, filterDisplayName:NSString)] = [
        ("CIColorControls", "None"),
        ("CIPhotoEffectMono", "Mono"),
        ("CIPhotoEffectTonal", "Tonal"),
        ("CIPhotoEffectNoir", "Noir"),
        ("CIPhotoEffectFade", "Fade"),
        ("CIPhotoEffectChrome", "Chrome"),
        ("CIPhotoEffectProcess", "Process"),
        ("CIPhotoEffectTransfer", "Transfer"),
        ("CIPhotoEffectInstant", "Instant")
    ]
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        filterView = LMGLFilterImageView(frame: CGRect(x: 0, y: 0, width: 0, height: 0))
        filterView.contentMode = .scaleAspectFit
        filterView.inputImage = #imageLiteral(resourceName: "flower.jpg")
        filterView.backgroundColor = UIColor.white
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        collection = UICollectionView(frame: CGRect(), collectionViewLayout: layout)
        collection.register(LMGLFilterPreviewCell.self, forCellWithReuseIdentifier: "cell")
        collection.backgroundColor = UIColor.white
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        view.addSubview(filterView)
        view.addSubview(collection)
        
        collection.delegate = self
        collection.dataSource = self
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        filterView.frame = CGRect(x: 0, y: 0, width: self.view.frame.size.width, height: self.view.frame.size.height - 60)
        collection.frame = CGRect(x: 0, y: self.view.frame.size.height - 60, width: self.view.frame.size.width, height: 60)
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return filterDescriptors.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell:LMGLFilterPreviewCell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! LMGLFilterPreviewCell
        
        cell.title.text = filterDescriptors[indexPath.item].filterDisplayName as String
        cell.filterView.ciFilter = CIFilter(name: filterDescriptors[indexPath.item].filterName as String)
        return cell;
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let cell:LMGLFilterPreviewCell = collectionView.cellForItem(at: indexPath) as! LMGLFilterPreviewCell
        filterView.ciFilter = cell.filterView.ciFilter
    }
}
