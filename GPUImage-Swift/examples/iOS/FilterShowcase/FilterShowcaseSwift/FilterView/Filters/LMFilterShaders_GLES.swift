//
//  LMFilterShaders_GLES.swift
//  FilterShowcase
//
//  Created by wzkj on 2017/2/24.
//  Copyright © 2017年 Sunset Lake Software. All rights reserved.
//

public let LMAutoLevelsFragmentShader = "varying highp vec2 textureCoordinate;\n uniform sampler2D inputImageTexture;\n uniform lowp float gamma;\n void main()\n {\n lowp vec4 textureColor = texture2D(inputImageTexture, textureCoordinate);\n textureColor.r = 0.5;\n gl_FragColor = textureColor;\n}"
