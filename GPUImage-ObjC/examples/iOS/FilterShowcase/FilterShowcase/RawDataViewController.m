//
//  RawDataViewController.m
//  FilterShowcase
//
//  Created by wzkj on 2016/12/8.
//  Copyright © 2016年 Cell Phone. All rights reserved.
//

#import "RawDataViewController.h"
#import "GPUImage.h"

@interface RawDataViewController ()

@end

@implementation RawDataViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    GLubyte *rawDataBytes = calloc(10 * 10 * 4, sizeof(GLubyte));
    for (unsigned int yIndex = 0; yIndex < 10; yIndex++)
    {
        for (unsigned int xIndex = 0; xIndex < 10; xIndex++)
        {
            rawDataBytes[yIndex * 10 * 4 + xIndex * 4] = xIndex;
            rawDataBytes[yIndex * 10 * 4 + xIndex * 4 + 1] = yIndex;
            rawDataBytes[yIndex * 10 * 4 + xIndex * 4 + 2] = 255;
            rawDataBytes[yIndex * 10 * 4 + xIndex * 4 + 3] = 0;
        }
    }
    
    GPUImageRawDataInput *rawDataInput = [[GPUImageRawDataInput alloc] initWithBytes:rawDataBytes size:CGSizeMake(10.0, 10.0)];
    GPUImageFilter *customFilter = [[GPUImageFilter alloc] initWithFragmentShaderFromFile:@"CalculationShader"];
    GPUImageRawDataOutput *rawDataOutput = [[GPUImageRawDataOutput alloc] initWithImageSize:CGSizeMake(10.0, 10.0) resultsInBGRAFormat:YES];
    
    [rawDataInput addTarget:customFilter];
    [customFilter addTarget:rawDataOutput];
    
    __unsafe_unretained GPUImageRawDataOutput * weakOutput = rawDataOutput;
    [rawDataOutput setNewFrameAvailableBlock:^{
        [weakOutput lockFramebufferForReading];
        GLubyte *outputBytes = [weakOutput rawBytesForImage];
        NSInteger bytesPerRow = [weakOutput bytesPerRowInOutput];
        NSLog(@"Bytes per row: %ld", (unsigned long)bytesPerRow);
        for (unsigned int yIndex = 0; yIndex < 10; yIndex++)
        {
            for (unsigned int xIndex = 0; xIndex < 10; xIndex++)
            {
                NSLog(@"Byte at (%d, %d): %d, %d, %d, %d", xIndex, yIndex, outputBytes[yIndex * bytesPerRow + xIndex * 4], outputBytes[yIndex * bytesPerRow + xIndex * 4 + 1], outputBytes[yIndex * bytesPerRow + xIndex * 4 + 2], outputBytes[yIndex * bytesPerRow + xIndex * 4 + 3]);
            }
        }
        [weakOutput unlockFramebufferAfterReading];
    }];
    
    [rawDataInput processData];
    
    free(rawDataBytes);
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */

@end
