//
//  LMFilterCollectionView.swift
//  FilterShowcase
//
//  Created by wzkj on 2017/1/17.
//  Copyright © 2017年 Cell Phone. All rights reserved.
//

import UIKit

class LMGLFilterCollectionCell: UICollectionViewCell {
    lazy var icon: UIImageView = {
        let iconImageView : UIImageView = UIImageView(frame: CGRect.zero)
        iconImageView.backgroundColor = UIColor.blue
        return iconImageView
    }()
    
    lazy var titleLabel : UILabel = {
        let label : UILabel = UILabel(frame: CGRect.zero)
        label.textAlignment = .center
        label.font = UIFont.systemFont(ofSize: 12)
        label.textColor = UIColor.darkText
        label.backgroundColor = UIColor.green
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.addSubview(icon)
        self.addSubview(titleLabel)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        let height:CGFloat = CGFloat(self.frame.height - 20)
        icon.frame = CGRect(origin: CGPoint.zero, size: CGSize(width: self.frame.width, height: height))
        titleLabel.frame = CGRect(origin: CGPoint(x: 0, y: height), size: CGSize(width: self.frame.width, height: 20))
    }
}


@objc class LMFilterCollectionView: UICollectionView,UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout {
    
    var filterSettings:NSMutableArray = NSMutableArray()
    var image:UIImage
    
    
    public init(frame: CGRect, image : UIImage){
        let filterLayout:UICollectionViewFlowLayout = UICollectionViewFlowLayout()
        filterLayout.scrollDirection = .horizontal
        filterLayout.minimumLineSpacing = 2
        self.image = image
        super.init(frame: frame, collectionViewLayout: filterLayout)
        handlImagePreview()
        self.backgroundColor = UIColor.white
        self.register(LMGLFilterCollectionCell.self, forCellWithReuseIdentifier: "cell")
        self.showsHorizontalScrollIndicator = false
        self.delegate = self
        self.dataSource = self
        var inset = self.contentInset
        inset.top = 2
        self.contentInset = inset
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // --------- UICollectionViewDataSource
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return filterSettings.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell:LMGLFilterCollectionCell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! LMGLFilterCollectionCell
        cell.backgroundColor = UIColor.red
        let item:NSDictionary = filterSettings[indexPath.item] as! NSDictionary
        cell.titleLabel.text = item.object(forKey: "name") as! String?
        cell.icon.image = item.object(forKey: "icon") as! UIImage?
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: self.frame.height-20, height: self.frame.height)
    }
    
    // MARK: ------------ 处理图片预览图
    func handlImagePreview() {
        let empty : LMGPUFilterEmpty = LMGPUFilterEmpty()
        let picture  = GPUImagePicture(image: self.image)
        picture?.addTarget(empty)
        empty.useNextFrameForImageCapture()
        picture?.processImage()
        
        let emptyImage = empty.imageFromCurrentFramebuffer()
        self.filterSettings.add(["name":"empty","icon":emptyImage as Any])
        
        let stillImageFilter:GPUImageSepiaFilter = GPUImageSepiaFilter()
        let vignetteImageFilter:GPUImageVignetteFilter = GPUImageVignetteFilter()
        vignetteImageFilter.vignetteEnd = 0.6;
        vignetteImageFilter.vignetteStart = 0.4;
        
        picture?.removeAllTargets()
        picture?.addTarget(stillImageFilter)
        stillImageFilter.addTarget(vignetteImageFilter)
        vignetteImageFilter.useNextFrameForImageCapture()
        picture?.processImage()
        let vignetImage = vignetteImageFilter.imageFromCurrentFramebuffer()
        self.filterSettings.add(["name":"vignet","icon":vignetImage as Any])
        
        // Linear downsampling
        let passthroughFilter:GPUImageBrightnessFilter = GPUImageBrightnessFilter()
        picture?.addTarget(passthroughFilter)
        passthroughFilter.useNextFrameForImageCapture()
        picture?.processImage()
        let nearestNeighborImage:UIImage = passthroughFilter.imageFromCurrentFramebuffer()
        self.filterSettings.add(["name":"passthrough","icon":nearestNeighborImage as Any])
        // Lanczos downsampling
        picture?.removeAllTargets()
        let lanczosResamplingFilter:GPUImageLanczosResamplingFilter = GPUImageLanczosResamplingFilter()
        picture?.addTarget(lanczosResamplingFilter)
        lanczosResamplingFilter.useNextFrameForImageCapture()
        picture?.processImage()
        let lanczosImage:UIImage = lanczosResamplingFilter.imageFromCurrentFramebuffer()
        self.filterSettings.add(["name":"lanczos","icon":lanczosImage as Any])
        
        
        // LMGPUFilterSutro
        picture?.removeAllTargets()
        let sutro:LMGPUFilters = LMGPUFilters(filterType: .sutro)
        picture?.addTarget(sutro)
        sutro.useNextFrameForImageCapture()
        picture?.processImage()
        let sutroImage = sutro.imageFromCurrentFramebuffer()
        self.filterSettings.add(["name":"sutro","icon":sutroImage as Any])
        
        picture?.removeAllTargets()
        let hudson:LMGPUFilters = LMGPUFilters(filterType: .hudson)
        picture?.addTarget(hudson)
        hudson.useNextFrameForImageCapture()
        picture?.processImage()
        let hudsonImage = hudson.imageFromCurrentFramebuffer()
        self.filterSettings.add(["name":"hudson","icon":hudsonImage as Any])
        // Trilinear downsampling
        //        GPUImagePicture *stillImageSource2 = [[GPUImagePicture alloc] initWithImage:inputImage smoothlyScaleOutput:YES];
        //        GPUImageBrightnessFilter *passthroughFilter2 = [[GPUImageBrightnessFilter alloc] init];
        //        [passthroughFilter2 forceProcessingAtSize:CGSizeMake(640.0, 480.0)];
        //        [stillImageSource2 addTarget:passthroughFilter2];
        //        [passthroughFilter2 useNextFrameForImageCapture];
        //        [stillImageSource2 processImage];
        //        UIImage *trilinearImage = [passthroughFilter2 imageFromCurrentFramebuffer];
    }
}
