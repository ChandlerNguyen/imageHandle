//
//  LMAutoLevels.swift
//  FilterShowcase
//
//  Created by wzkj on 2017/2/21.
//  Copyright © 2017年 Sunset Lake Software. All rights reserved.
//
/** 自动色阶 */

import GPUImage

class LMAutoLevels : BasicOperation {
    public init() {
        super.init(fragmentShader: LMAutoLevelsFragmentShader)
    }
}
