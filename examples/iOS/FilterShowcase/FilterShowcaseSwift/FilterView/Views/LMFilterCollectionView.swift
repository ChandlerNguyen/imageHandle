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
    
    public init(frame: CGRect, image : UIImage){
        let filterLayout:UICollectionViewFlowLayout = UICollectionViewFlowLayout()
        filterLayout.scrollDirection = .horizontal
        filterLayout.minimumLineSpacing = 2
        super.init(frame: frame, collectionViewLayout: filterLayout)
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
        return 10
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell:LMGLFilterCollectionCell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! LMGLFilterCollectionCell
        cell.backgroundColor = UIColor.red
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: self.frame.height-20, height: self.frame.height)
    }
}
