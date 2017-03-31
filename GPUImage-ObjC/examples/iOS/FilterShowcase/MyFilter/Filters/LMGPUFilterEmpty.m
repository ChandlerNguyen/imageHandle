//
//  LMGPUFilterEmpty.m
//  FilterShowcase
//
//  Created by wzkj on 2017/1/20.
//  Copyright © 2017年 Cell Phone. All rights reserved.
//

#import "LMGPUFilterEmpty.h"
#if TARGET_IPHONE_SIMULATOR || TARGET_OS_IPHONE
NSString *const kLFGPUImageEmptyFragmentShaderString = SHADER_STRING
(
 varying highp vec2 textureCoordinate;
 
 uniform sampler2D inputImageTexture;
 
 void main(){
     lowp vec4 textureColor = texture2D(inputImageTexture, textureCoordinate);
     
     gl_FragColor = vec4((textureColor.rgb), textureColor.w);
 }
 );
#else
NSString *const kGPUImageInvertFragmentShaderString = SHADER_STRING
(
 varying vec2 textureCoordinate;
 
 uniform sampler2D inputImageTexture;
 
 void main(){
     vec4 textureColor = texture2D(inputImageTexture, textureCoordinate);
     
     gl_FragColor = vec4((textureColor.rgb), textureColor.w);
 }
 
 );
#endif

@implementation LMGPUFilterEmpty
- (id)init;
{
    if (!(self = [super initWithFragmentShaderFromString:kLFGPUImageEmptyFragmentShaderString])) {
        return nil;
    }
    
    return self;
}
@end
