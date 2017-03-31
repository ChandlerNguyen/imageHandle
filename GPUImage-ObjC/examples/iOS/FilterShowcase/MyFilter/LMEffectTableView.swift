//
//  LMEffectTableView.swift
//  FilterShowcase
//
//  Created by wzkj on 2017/1/17.
//  Copyright © 2017年 Cell Phone. All rights reserved.
//

import UIKit

@objc class LMEffectTableView: UITableView,UITableViewDelegate,UITableViewDataSource {
    override init(frame: CGRect, style: UITableViewStyle) {
        super.init(frame: frame, style: .grouped)
        self.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        self.delegate = self
        self.dataSource = self
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 10
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell : UITableViewCell = tableView.dequeueReusableCell(withIdentifier: "cell")!
        return cell
    }
}
