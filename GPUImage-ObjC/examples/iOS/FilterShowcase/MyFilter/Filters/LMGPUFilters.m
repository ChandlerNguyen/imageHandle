//
//  LMGPUFilters.m
//  FilterShowcase
//
//  Created by wzkj on 2017/1/20.
//  Copyright © 2017年 Cell Phone. All rights reserved.
//

#import "LMGPUFilters.h"

NSString *const kLFGPUImageSutroFragmentShaderString= SHADER_STRING
(
 precision lowp float;
 
 varying highp vec2 textureCoordinate;
 
 uniform sampler2D inputImageTexture;
 uniform sampler2D inputImageTexture2; //sutroMap;
 uniform sampler2D inputImageTexture3; //sutroMetal;
 uniform sampler2D inputImageTexture4; //softLight
 uniform sampler2D inputImageTexture5; //sutroEdgeburn
 uniform sampler2D inputImageTexture6; //sutroCurves
 
 void main()
 {
     vec3 texel = texture2D(inputImageTexture, textureCoordinate).rgb;
     
     vec2 tc = (2.0 * textureCoordinate) - 1.0;
     float d = dot(tc, tc);
     vec2 lookup = vec2(d, texel.r);
     texel.r = texture2D(inputImageTexture2, lookup).r;
     lookup.y = texel.g;
     texel.g = texture2D(inputImageTexture2, lookup).g;
     lookup.y = texel.b;
     texel.b	= texture2D(inputImageTexture2, lookup).b;
     
     vec3 rgbPrime = vec3(0.1019, 0.0, 0.0);
     float m = dot(vec3(.3, .59, .11), texel.rgb) - 0.03058;
     texel = mix(texel, rgbPrime + m, 0.32);
     
     vec3 metal = texture2D(inputImageTexture3, textureCoordinate).rgb;
     texel.r = texture2D(inputImageTexture4, vec2(metal.r, texel.r)).r;
     texel.g = texture2D(inputImageTexture4, vec2(metal.g, texel.g)).g;
     texel.b = texture2D(inputImageTexture4, vec2(metal.b, texel.b)).b;
     
     texel = texel * texture2D(inputImageTexture5, textureCoordinate).rgb;
     
     texel.r = texture2D(inputImageTexture6, vec2(texel.r, .16666)).r;
     texel.g = texture2D(inputImageTexture6, vec2(texel.g, .5)).g;
     texel.b = texture2D(inputImageTexture6, vec2(texel.b, .83333)).b;
     
     
     gl_FragColor = vec4(texel, 1.0);
 }
 );

NSString *const kIFAmaroShaderString = SHADER_STRING
(
 precision lowp float;
 
 varying highp vec2 textureCoordinate;
 
 uniform sampler2D inputImageTexture;
 uniform sampler2D inputImageTexture2; //blowout;
 uniform sampler2D inputImageTexture3; //overlay;
 uniform sampler2D inputImageTexture4; //map
 
 void main()
 {
     
     vec4 texel = texture2D(inputImageTexture, textureCoordinate);
     vec3 bbTexel = texture2D(inputImageTexture2, textureCoordinate).rgb;
     
     texel.r = texture2D(inputImageTexture3, vec2(bbTexel.r, texel.r)).r;
     texel.g = texture2D(inputImageTexture3, vec2(bbTexel.g, texel.g)).g;
     texel.b = texture2D(inputImageTexture3, vec2(bbTexel.b, texel.b)).b;
     
     vec4 mapped;
     mapped.r = texture2D(inputImageTexture4, vec2(texel.r, .16666)).r;
     mapped.g = texture2D(inputImageTexture4, vec2(texel.g, .5)).g;
     mapped.b = texture2D(inputImageTexture4, vec2(texel.b, .83333)).b;
     mapped.a = 1.0;
     
     gl_FragColor = mapped;
 }
 );

NSString *const kIFNormalShaderString = SHADER_STRING
(
 precision lowp float;
 
 varying highp vec2 textureCoordinate;
 
 uniform sampler2D inputImageTexture;
 
 void main()
 {
     
     vec3 texel = texture2D(inputImageTexture, textureCoordinate).rgb;
     
     gl_FragColor = vec4(texel, 1.0);
 }
 );


NSString *const kIFRiseShaderString = SHADER_STRING
(
 precision lowp float;
 
 varying highp vec2 textureCoordinate;
 
 uniform sampler2D inputImageTexture;
 uniform sampler2D inputImageTexture2; //blowout;
 uniform sampler2D inputImageTexture3; //overlay;
 uniform sampler2D inputImageTexture4; //map
 
 void main()
 {
     
     vec4 texel = texture2D(inputImageTexture, textureCoordinate);
     vec3 bbTexel = texture2D(inputImageTexture2, textureCoordinate).rgb;
     
     texel.r = texture2D(inputImageTexture3, vec2(bbTexel.r, texel.r)).r;
     texel.g = texture2D(inputImageTexture3, vec2(bbTexel.g, texel.g)).g;
     texel.b = texture2D(inputImageTexture3, vec2(bbTexel.b, texel.b)).b;
     
     vec4 mapped;
     mapped.r = texture2D(inputImageTexture4, vec2(texel.r, .16666)).r;
     mapped.g = texture2D(inputImageTexture4, vec2(texel.g, .5)).g;
     mapped.b = texture2D(inputImageTexture4, vec2(texel.b, .83333)).b;
     mapped.a = 1.0;
     
     gl_FragColor = mapped;
 }
 );

NSString *const kIFHudsonShaderString = SHADER_STRING
(
 precision lowp float;
 
 varying highp vec2 textureCoordinate;
 
 uniform sampler2D inputImageTexture;
 uniform sampler2D inputImageTexture2; //blowout;
 uniform sampler2D inputImageTexture3; //overlay;
 uniform sampler2D inputImageTexture4; //map
 
 void main()
 {
     
     vec4 texel = texture2D(inputImageTexture, textureCoordinate);
     
     vec3 bbTexel = texture2D(inputImageTexture2, textureCoordinate).rgb;
     
     texel.r = texture2D(inputImageTexture3, vec2(bbTexel.r, texel.r)).r;
     texel.g = texture2D(inputImageTexture3, vec2(bbTexel.g, texel.g)).g;
     texel.b = texture2D(inputImageTexture3, vec2(bbTexel.b, texel.b)).b;
     
     vec4 mapped;
     mapped.r = texture2D(inputImageTexture4, vec2(texel.r, .16666)).r;
     mapped.g = texture2D(inputImageTexture4, vec2(texel.g, .5)).g;
     mapped.b = texture2D(inputImageTexture4, vec2(texel.b, .83333)).b;
     mapped.a = 1.0;
     gl_FragColor = mapped;
 }
 );

@implementation LMGPUFilters
-(instancetype)initWithFilterType:(FilterType)type{
    NSString *fragmentShaderFromString;
    switch (type) {
        case FilterTypeNormal:
            fragmentShaderFromString = kIFNormalShaderString;
            break;
        case FilterTypeSutro:
            fragmentShaderFromString = kLFGPUImageSutroFragmentShaderString;
            break;
        case FilterTypeAmaro:
            fragmentShaderFromString = kIFAmaroShaderString;
            break;
        case FilterTypeRise:
            fragmentShaderFromString = kIFRiseShaderString;
            break;
        case FilterTypeHudson:
            fragmentShaderFromString = kIFHudsonShaderString;
            break;
            
        default:
            break;
    }
    if (!(self = [super initWithFragmentShaderFromString:fragmentShaderFromString])) {
        
    }
    return self;
}
@end
