//
//  LMWaterEffect.swift
//  FilterShowcase
//
//  Created by wzkj on 2017/2/17.
//  Copyright © 2017年 Sunset Lake Software. All rights reserved.
//

import GPUImage
// 技术参考地址http://blog.sina.com.cn/s/blog_78ea87380101ehk3.html
class LMWaterEffect : BasicOperation {
    
    public var time:Float = 0.0 { didSet { uniformSettings["time"] = time} }
    
    public init() throws{
        let mainBundle:Bundle = Bundle.main
        let vshPath = mainBundle.path(forResource: "LMWaterEffect", ofType: "vsh")
        let fshPath = mainBundle.path(forResource: "LMWaterEffect_GLES", ofType: "fsh")
        
        let waterVsh:String? = try shaderFromFile(URL(fileURLWithPath:vshPath!))
        let waterFsh:String? = try shaderFromFile(URL(fileURLWithPath:fshPath!))
        
        super.init(vertexShader: waterVsh, fragmentShader: waterFsh!, numberOfInputs:1)
    }
}
