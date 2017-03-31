import Foundation
import GPUImage
import QuartzCore

#if os(iOS)
import OpenGLES
#else
import OpenGL
#endif
    
let filterOperations: Array<FilterOperationInterface> = [
    FilterOperation <GPUImageSaturationFilter>(
        listName:"Saturation",
        titleName:"Saturation",
        sliderConfiguration:.enabled(minimumValue:0.0, maximumValue:2.0, initialValue:1.0),
        sliderUpdateCallback: {(filter, sliderValue) in
            filter.saturation = sliderValue
        },
        filterOperationType:.singleInput
    ),
    FilterOperation <GPUImageContrastFilter>(
        listName:"Contrast",
        titleName:"Contrast",
        sliderConfiguration:.enabled(minimumValue:0.0, maximumValue:4.0, initialValue:1.0),
        sliderUpdateCallback: {(filter, sliderValue) in
            filter.contrast = sliderValue
        },
        filterOperationType:.singleInput
    ),
    FilterOperation <GPUImageBrightnessFilter>(
        listName:"Brightness",
        titleName:"Brightness",
        sliderConfiguration:.enabled(minimumValue:-1.0, maximumValue:1.0, initialValue:0.0),
        sliderUpdateCallback: {(filter, sliderValue) in
            filter.brightness = sliderValue
        },
        filterOperationType:.singleInput
    ),
    FilterOperation <GPUImageLevelsFilter>(
        listName:"Levels",
        titleName:"Levels",
        sliderConfiguration:.enabled(minimumValue:0.0, maximumValue:1.0, initialValue:0.0),
        sliderUpdateCallback: {(filter, sliderValue) in
            filter.setRedMin(sliderValue, gamma:1.0, max:1.0, minOut:0.0, maxOut:1.0)
            filter.setGreenMin(sliderValue, gamma:1.0, max:1.0, minOut:0.0, maxOut:1.0)
            filter.setBlueMin(sliderValue, gamma:1.0, max:1.0, minOut:0.0, maxOut:1.0)
        },
        filterOperationType:.singleInput
    ),
    FilterOperation <GPUImageExposureFilter>(
        listName:"Exposure",
        titleName:"Exposure",
        sliderConfiguration:.enabled(minimumValue:-4.0, maximumValue:4.0, initialValue:0.0),
        sliderUpdateCallback: {(filter, sliderValue) in
            filter.exposure = sliderValue
        },
        filterOperationType:.singleInput
    ),
    FilterOperation <GPUImageRGBFilter>(
        listName:"RGB",
        titleName:"RGB",
        sliderConfiguration:.enabled(minimumValue:0.0, maximumValue:2.0, initialValue:1.0),
        sliderUpdateCallback: {(filter, sliderValue) in
            filter.green = sliderValue
        },
        filterOperationType:.singleInput
    ),
    FilterOperation <GPUImageHueFilter>(
        listName:"Hue",
        titleName:"Hue",
        sliderConfiguration:.enabled(minimumValue:0.0, maximumValue:360.0, initialValue:90.0),
        sliderUpdateCallback: {(filter, sliderValue) in
            filter.hue = sliderValue
        },
        filterOperationType:.singleInput
    ),
    FilterOperation <GPUImageWhiteBalanceFilter>(
        listName:"White balance",
        titleName:"White Balance",
        sliderConfiguration:.enabled(minimumValue:2500.0, maximumValue:7500.0, initialValue:5000.0),
        sliderUpdateCallback: {(filter, sliderValue) in
            filter.temperature = sliderValue
        },
        filterOperationType:.singleInput
    ),
    FilterOperation <GPUImageMonochromeFilter>(
        listName:"Monochrome",
        titleName:"Monochrome",
        sliderConfiguration:.enabled(minimumValue:0.0, maximumValue:1.0, initialValue:1.0),
        sliderUpdateCallback: {(filter, sliderValue) in
            filter.intensity = sliderValue
        },
        filterOperationType:.custom(filterSetupFunction:{(camera, outputView) in
            let filter = GPUImageMonochromeFilter()
            camera.addTarget(filter)
            filter.addTarget(outputView)
            filter.color = GPUVector4(one:0.0, two:0.0, three:1.0, four:1.0)
            return (filter, nil)
        })
    ),
    FilterOperation <GPUImageFalseColorFilter>(
        listName:"False color",
        titleName:"False Color",
        sliderConfiguration:.disabled,
        sliderUpdateCallback:nil,
        filterOperationType:.singleInput
    ),
    FilterOperation <GPUImageSharpenFilter>(
        listName:"Sharpen",
        titleName:"Sharpen",
        sliderConfiguration:.enabled(minimumValue:-1.0, maximumValue:4.0, initialValue:0.0),
        sliderUpdateCallback: {(filter, sliderValue) in
            filter.sharpness = sliderValue
        },
        filterOperationType:.singleInput
    ),
    FilterOperation <GPUImageUnsharpMaskFilter>(
        listName:"Unsharp mask",
        titleName:"Unsharp Mask",
        sliderConfiguration:.enabled(minimumValue:0.0, maximumValue:5.0, initialValue:1.0),
        sliderUpdateCallback: {(filter, sliderValue) in
            filter.intensity = sliderValue
        },
        filterOperationType:.singleInput
    ),
    FilterOperation <GPUImageTransformFilter>(
        listName:"Transform (2-D)",
        titleName:"Transform (2-D)",
        sliderConfiguration:.enabled(minimumValue:0.0, maximumValue:6.28, initialValue:0.75),
        sliderUpdateCallback:{(filter, sliderValue) in
            filter.affineTransform = CGAffineTransform(rotationAngle: sliderValue)
        },
        filterOperationType:.singleInput
    ),
    FilterOperation <GPUImageTransformFilter>(
        listName:"Transform (3-D)",
        titleName:"Transform (3-D)",
        sliderConfiguration:.enabled(minimumValue:0.0, maximumValue:6.28, initialValue:0.75),
        sliderUpdateCallback:{(filter, sliderValue) in
            var perspectiveTransform = CATransform3DIdentity
            perspectiveTransform.m34 = 0.4
            perspectiveTransform.m33 = 0.4
            perspectiveTransform = CATransform3DScale(perspectiveTransform, 0.75, 0.75, 0.75)
            perspectiveTransform = CATransform3DRotate(perspectiveTransform, sliderValue, 0.0, 1.0, 0.0)
            filter.transform3D = perspectiveTransform
        },
        filterOperationType:.singleInput
    ),
    FilterOperation <GPUImageCropFilter>(
        listName:"Crop",
        titleName:"Crop",
        sliderConfiguration:.enabled(minimumValue:0.2, maximumValue:1.0, initialValue:0.25),
        sliderUpdateCallback:{(filter, sliderValue) in
            filter.cropRegion = CGRect(x: 0.0, y: 0.0, width: 1.0, height: sliderValue)
        },
        filterOperationType:.singleInput
    ),
    FilterOperation <GPUImageMaskFilter>(
        listName:"Mask",
        titleName:"Mask",
        sliderConfiguration:.disabled,
        sliderUpdateCallback:nil,
        filterOperationType:.custom(filterSetupFunction:{(camera, outputView) in
            let filter = GPUImageMaskFilter()
#if os(iOS)
            let inputImage = UIImage(named:"mask.png")
#else
            let inputImage = NSImage(named:"mask.png")
#endif
            let inputPicture = GPUImagePicture(image:inputImage)
            camera.addTarget(filter)
            inputPicture?.addTarget(filter)
            inputPicture?.processImage()
            filter.addTarget(outputView)
            filter.setBackgroundColorRed(0.0, green:1.0, blue:0.0, alpha:1.0)
            return (filter, inputPicture)
        })
    ),
    FilterOperation <GPUImageGammaFilter>(
        listName:"Gamma",
        titleName:"Gamma",
        sliderConfiguration:.enabled(minimumValue:0.0, maximumValue:3.0, initialValue:1.0),
        sliderUpdateCallback: {(filter, sliderValue) in
            filter.gamma = sliderValue
        },
        filterOperationType:.singleInput
    ),
    FilterOperation <GPUImageToneCurveFilter>(
        listName:"Tone curve",
        titleName:"Tone Curve",
        sliderConfiguration:.enabled(minimumValue:0.0, maximumValue:1.0, initialValue:0.5),
        sliderUpdateCallback: {(filter, sliderValue) in
#if os(iOS)
            filter.blueControlPoints = ([NSValue(cgPoint:CGPoint(x: 0.0, y: 0.0)), NSValue(cgPoint:CGPoint(x: 0.5, y: sliderValue)), NSValue(cgPoint:CGPoint(x: 1.0, y: 0.75))])
#else
            filter.blueControlPoints = ([NSValue(point:NSMakePoint(0.0, 0.0)), NSValue(point:NSMakePoint(0.5, sliderValue)), NSValue(point:NSMakePoint(1.0, 0.75))])
#endif
        },
        filterOperationType:.singleInput
    ),
    FilterOperation <GPUImageHighlightShadowFilter>(
        listName:"Highlights and shadows",
        titleName:"Highlights and Shadows",
        sliderConfiguration:.enabled(minimumValue:0.0, maximumValue:1.0, initialValue:1.0),
        sliderUpdateCallback: {(filter, sliderValue) in
            filter.highlights = sliderValue
        },
        filterOperationType:.singleInput
    ),
    FilterOperation <GPUImageHazeFilter>(
        listName:"Haze / UV",
        titleName:"Haze / UV",
        sliderConfiguration:.enabled(minimumValue:-0.2, maximumValue:0.2, initialValue:0.2),
        sliderUpdateCallback: {(filter, sliderValue) in
            filter.distance = sliderValue
        },
        filterOperationType:.singleInput
    ),
    FilterOperation <GPUImageSepiaFilter>(
        listName:"Sepia tone",
        titleName:"Sepia Tone",
        sliderConfiguration:.enabled(minimumValue:0.0, maximumValue:1.0, initialValue:1.0),
        sliderUpdateCallback: {(filter, sliderValue) in
            filter.intensity = sliderValue
        },
        filterOperationType:.singleInput
    ),
    FilterOperation <GPUImageAmatorkaFilter>(
        listName:"Amatorka (Lookup)",
        titleName:"Amatorka (Lookup)",
        sliderConfiguration:.disabled,
        sliderUpdateCallback: nil,
        filterOperationType:.singleInput
    ),
    FilterOperation <GPUImageMissEtikateFilter>(
        listName:"Miss Etikate (Lookup)",
        titleName:"Miss Etikate (Lookup)",
        sliderConfiguration:.disabled,
        sliderUpdateCallback: nil,
        filterOperationType:.singleInput
    ),
    FilterOperation <GPUImageSoftEleganceFilter>(
        listName:"Soft elegance (Lookup)",
        titleName:"Soft Elegance (Lookup)",
        sliderConfiguration:.disabled,
        sliderUpdateCallback: nil,
        filterOperationType:.singleInput
    ),
    FilterOperation <GPUImageColorInvertFilter>(
        listName:"Color invert",
        titleName:"Color Invert",
        sliderConfiguration:.disabled,
        sliderUpdateCallback: nil,
        filterOperationType:.singleInput
    ),
    FilterOperation <GPUImageGrayscaleFilter>(
        listName:"Grayscale",
        titleName:"Grayscale",
        sliderConfiguration:.disabled,
        sliderUpdateCallback: nil,
        filterOperationType:.singleInput
    ),
    FilterOperation <GPUImageHistogramFilter>(
        listName:"Histogram",
        titleName:"Histogram",
        sliderConfiguration:.enabled(minimumValue:4.0, maximumValue:32.0, initialValue:16.0),
        sliderUpdateCallback: {(filter, sliderValue) in
            filter.downsamplingFactor = UInt(round(sliderValue))
        },
        filterOperationType:.custom(filterSetupFunction: {(camera, outputView) in
            let filter = GPUImageHistogramFilter()
            let gammaFilter = GPUImageGammaFilter()
            let histogramGraph = GPUImageHistogramGenerator()
            histogramGraph.forceProcessing(at: CGSize(width: 256.0, height: 330.0))
            let blendFilter = GPUImageAlphaBlendFilter()
            blendFilter.mix = 0.75
            blendFilter.forceProcessing(at: CGSize(width: 256.0, height: 330.0))

            camera.addTarget(gammaFilter)
            gammaFilter.addTarget(filter)
            camera.addTarget(blendFilter)
            filter.addTarget(histogramGraph)
            histogramGraph.addTarget(blendFilter)
            blendFilter.addTarget(outputView)
            return (filter, nil)
        })
    ),
    FilterOperation <GPUImageAverageColor>(
        listName:"Average color",
        titleName:"Average Color",
        sliderConfiguration:.disabled,
        sliderUpdateCallback: nil,
        filterOperationType:.custom(filterSetupFunction:{(camera, outputView) in
            let filter = GPUImageAverageColor()
            let colorGenerator = GPUImageSolidColorGenerator()
            colorGenerator.forceProcessing(at: outputView.sizeInPixels)
            
            filter.colorAverageProcessingFinishedBlock = {(redComponent, greenComponent, blueComponent, alphaComponent, frameTime) in
                colorGenerator.setColorRed(redComponent, green:greenComponent, blue:blueComponent, alpha:alphaComponent)
            //                NSLog(@"Average color: %f, %f, %f, %f", redComponent, greenComponent, blueComponent, alphaComponent);
            }
            
            camera.addTarget(filter)
            colorGenerator.addTarget(outputView)
            return (filter, nil)
        })
    ),
    FilterOperation <GPUImageLuminosity>(
        listName:"Average luminosity",
        titleName:"Average Luminosity",
        sliderConfiguration:.disabled,
        sliderUpdateCallback: nil,
        filterOperationType:.custom(filterSetupFunction:{(camera, outputView) in
            let filter = GPUImageLuminosity()
            let colorGenerator = GPUImageSolidColorGenerator()
            colorGenerator.forceProcessing(at: outputView.sizeInPixels)
            
            filter.luminosityProcessingFinishedBlock = {(luminosity, frameTime) in
                colorGenerator.setColorRed(luminosity, green:luminosity, blue:luminosity, alpha:luminosity)
                //                NSLog(@"Average color: %f, %f, %f, %f", redComponent, greenComponent, blueComponent, alphaComponent);
            }
            
            camera.addTarget(filter)
            colorGenerator.addTarget(outputView)
            return (filter, nil)
        })
    ),
    FilterOperation <GPUImageLuminanceThresholdFilter>(
        listName:"Luminance threshold",
        titleName:"Luminance Threshold",
        sliderConfiguration:.enabled(minimumValue:0.0, maximumValue:1.0, initialValue:0.5),
        sliderUpdateCallback: {(filter, sliderValue) in
            filter.threshold = sliderValue
        },
        filterOperationType:.singleInput
    ),
    FilterOperation <GPUImageAdaptiveThresholdFilter>(
        listName:"Adaptive threshold",
        titleName:"Adaptive Threshold",
        sliderConfiguration:.enabled(minimumValue:1.0, maximumValue:20.0, initialValue:1.0),
        sliderUpdateCallback: {(filter, sliderValue) in
            filter.blurRadiusInPixels = sliderValue
        },
        filterOperationType:.singleInput
    ),
    FilterOperation <GPUImageAverageLuminanceThresholdFilter>(
        listName:"Average luminance threshold",
        titleName:"Avg. Lum. Threshold",
        sliderConfiguration:.enabled(minimumValue:0.0, maximumValue:2.0, initialValue:1.0),
        sliderUpdateCallback: {(filter, sliderValue) in
            filter.thresholdMultiplier = sliderValue
        },
        filterOperationType:.singleInput
    ),
    FilterOperation <GPUImageSolarizeFilter>(
        listName:"Solarize",
        titleName:"Solarize",
        sliderConfiguration:.enabled(minimumValue:0.0, maximumValue:1.0, initialValue:0.5),
        sliderUpdateCallback: {(filter, sliderValue) in
            filter.threshold = sliderValue
        },
        filterOperationType:.singleInput
    ),
    FilterOperation <GPUImagePixellateFilter>(
        listName:"Pixellate",
        titleName:"Pixellate",
        sliderConfiguration:.enabled(minimumValue:0.0, maximumValue:0.3, initialValue:0.05),
        sliderUpdateCallback: {(filter, sliderValue) in
            filter.fractionalWidthOfAPixel = sliderValue
        },
        filterOperationType:.singleInput
    ),
    FilterOperation <GPUImagePolarPixellateFilter>(
        listName:"Polar pixellate",
        titleName:"Polar Pixellate",
        sliderConfiguration:.enabled(minimumValue:-0.1, maximumValue:0.1, initialValue:0.05),
        sliderUpdateCallback: {(filter, sliderValue) in
            filter.pixelSize = CGSize(width: sliderValue, height: sliderValue)
        },
        filterOperationType:.singleInput
    ),
    FilterOperation <GPUImagePixellatePositionFilter>(
        listName:"Pixellate (position)",
        titleName:"Pixellate (position)",
        sliderConfiguration:.enabled(minimumValue:0.0, maximumValue:0.5, initialValue:0.25),
        sliderUpdateCallback: {(filter, sliderValue) in
            filter.radius = sliderValue
        },
        filterOperationType:.singleInput
    ),
    FilterOperation <GPUImagePolkaDotFilter>(
        listName:"Polka dot",
        titleName:"Polka Dot",
        sliderConfiguration:.enabled(minimumValue:0.0, maximumValue:0.3, initialValue:0.05),
        sliderUpdateCallback: {(filter, sliderValue) in
            filter.fractionalWidthOfAPixel = sliderValue
        },
        filterOperationType:.singleInput
    ),
    FilterOperation <GPUImageHalftoneFilter>(
        listName:"Halftone",
        titleName:"Halftone",
        sliderConfiguration:.enabled(minimumValue:0.0, maximumValue:0.05, initialValue:0.01),
        sliderUpdateCallback: {(filter, sliderValue) in
            filter.fractionalWidthOfAPixel = sliderValue
        },
        filterOperationType:.singleInput
    ),
    FilterOperation <GPUImageCrosshatchFilter>(
        listName:"Crosshatch",
        titleName:"Crosshatch",
        sliderConfiguration:.enabled(minimumValue:0.01, maximumValue:0.06, initialValue:0.03),
        sliderUpdateCallback: {(filter, sliderValue) in
            filter.crossHatchSpacing = sliderValue
        },
        filterOperationType:.singleInput
    ),
    FilterOperation <GPUImageSobelEdgeDetectionFilter>(
        listName:"Sobel edge detection",
        titleName:"Sobel Edge Detection",
        sliderConfiguration:.enabled(minimumValue:0.0, maximumValue:1.0, initialValue:0.25),
        sliderUpdateCallback: {(filter, sliderValue) in
            filter.edgeStrength = sliderValue
        },
        filterOperationType:.singleInput
    ),
    FilterOperation <GPUImagePrewittEdgeDetectionFilter>(
        listName:"Prewitt edge detection",
        titleName:"Prewitt Edge Detection",
        sliderConfiguration:.enabled(minimumValue:0.0, maximumValue:1.0, initialValue:1.0),
        sliderUpdateCallback: {(filter, sliderValue) in
            filter.edgeStrength = sliderValue
        },
        filterOperationType:.singleInput
    ),
    FilterOperation <GPUImageCannyEdgeDetectionFilter>(
        listName:"Canny edge detection",
        titleName:"Canny Edge Detection",
        sliderConfiguration:.enabled(minimumValue:0.0, maximumValue:1.0, initialValue:1.0),
        sliderUpdateCallback: {(filter, sliderValue) in
            filter.blurTexelSpacingMultiplier = sliderValue
        },
        filterOperationType:.singleInput
    ),
    FilterOperation <GPUImageThresholdEdgeDetectionFilter>(
        listName:"Threshold edge detection",
        titleName:"Threshold Edge Detection",
        sliderConfiguration:.enabled(minimumValue:0.0, maximumValue:1.0, initialValue:0.25),
        sliderUpdateCallback: {(filter, sliderValue) in
            filter.threshold = sliderValue
        },
        filterOperationType:.singleInput
    ),
    FilterOperation <GPUImageXYDerivativeFilter>(
        listName:"XY derivative",
        titleName:"XY Derivative",
        sliderConfiguration:.disabled,
        sliderUpdateCallback: nil,
        filterOperationType:.singleInput
    ),
    FilterOperation <GPUImageHarrisCornerDetectionFilter>(
        listName:"Harris corner detector",
        titleName:"Harris Corner Detector",
        sliderConfiguration:.enabled(minimumValue:0.01, maximumValue:0.70, initialValue:0.20),
        sliderUpdateCallback: {(filter, sliderValue) in
            filter.threshold = sliderValue
        },
        filterOperationType:.custom(filterSetupFunction:{(camera, outputView) in
            let filter = GPUImageHarrisCornerDetectionFilter()
            
            let crosshairGenerator = GPUImageCrosshairGenerator()
            crosshairGenerator.crosshairWidth = 15.0
            crosshairGenerator.forceProcessing(at: outputView.sizeInPixels)
            
            filter.cornersDetectedBlock = { (cornerArray:UnsafeMutablePointer<GLfloat>, cornersDetected:UInt, frameTime:CMTime) in
                crosshairGenerator.renderCrosshairs(fromArray: cornerArray, count:cornersDetected, frameTime:frameTime)
            }
            
            camera.addTarget(filter)
            
            let blendFilter = GPUImageAlphaBlendFilter()
            blendFilter.forceProcessing(at: outputView.sizeInPixels)
            let gammaFilter = GPUImageGammaFilter()
            camera.addTarget(gammaFilter)
            gammaFilter.addTarget(blendFilter)
            
            crosshairGenerator.addTarget(blendFilter)
            
            blendFilter.addTarget(outputView)
            return (filter, nil)
        })
    ),
    FilterOperation <GPUImageNobleCornerDetectionFilter>(
        listName:"Noble corner detector",
        titleName:"Noble Corner Detector",
        sliderConfiguration:.enabled(minimumValue:0.01, maximumValue:0.70, initialValue:0.20),
        sliderUpdateCallback: {(filter, sliderValue) in
            filter.threshold = sliderValue
        },
        filterOperationType:.custom(filterSetupFunction:{(camera, outputView) in
            let filter = GPUImageNobleCornerDetectionFilter()
            
            let crosshairGenerator = GPUImageCrosshairGenerator()
            crosshairGenerator.crosshairWidth = 15.0
            crosshairGenerator.forceProcessing(at: outputView.sizeInPixels)
            
            filter.cornersDetectedBlock = { (cornerArray:UnsafeMutablePointer<GLfloat>, cornersDetected:UInt, frameTime:CMTime) in
                crosshairGenerator.renderCrosshairs(fromArray: cornerArray, count:cornersDetected, frameTime:frameTime)
            }
            
            camera.addTarget(filter)
            
            let blendFilter = GPUImageAlphaBlendFilter()
            blendFilter.forceProcessing(at: outputView.sizeInPixels)
            let gammaFilter = GPUImageGammaFilter()
            camera.addTarget(gammaFilter)
            gammaFilter.addTarget(blendFilter)
            
            crosshairGenerator.addTarget(blendFilter)
            
            blendFilter.addTarget(outputView)
            return (filter, nil)
        })
    ),
    FilterOperation <GPUImageShiTomasiFeatureDetectionFilter>(
        listName:"Shi-Tomasi feature detection",
        titleName:"Shi-Tomasi Feature Detection",
        sliderConfiguration:.enabled(minimumValue:0.01, maximumValue:0.70, initialValue:0.20),
        sliderUpdateCallback: {(filter, sliderValue) in
            filter.threshold = sliderValue
        },
        filterOperationType:.custom(filterSetupFunction:{(camera, outputView) in
            let filter = GPUImageShiTomasiFeatureDetectionFilter()
            
            let crosshairGenerator = GPUImageCrosshairGenerator()
            crosshairGenerator.crosshairWidth = 15.0
            crosshairGenerator.forceProcessing(at: outputView.sizeInPixels)
            
            filter.cornersDetectedBlock = { (cornerArray:UnsafeMutablePointer<GLfloat>, cornersDetected:UInt, frameTime:CMTime) in
                crosshairGenerator.renderCrosshairs(fromArray: cornerArray, count:cornersDetected, frameTime:frameTime)
            }
            
            camera.addTarget(filter)
            
            let blendFilter = GPUImageAlphaBlendFilter()
            blendFilter.forceProcessing(at: outputView.sizeInPixels)
            let gammaFilter = GPUImageGammaFilter()
            camera.addTarget(gammaFilter)
            gammaFilter.addTarget(blendFilter)
            
            crosshairGenerator.addTarget(blendFilter)
            
            blendFilter.addTarget(outputView)
            return (filter, nil)
        })
    ),
    FilterOperation <GPUImageHoughTransformLineDetector>(
        listName:"Hough transform line detection",
        titleName:"Hough Transform Line Detection",
        sliderConfiguration:.enabled(minimumValue:0.01, maximumValue:0.70, initialValue:0.60),
        sliderUpdateCallback: {(filter, sliderValue) in
            filter.lineDetectionThreshold = sliderValue
        },
        filterOperationType:.custom(filterSetupFunction:{(camera, outputView) in
            let filter = GPUImageHoughTransformLineDetector()
            
            let lineGenerator = GPUImageLineGenerator()
            
            lineGenerator.forceProcessing(at: outputView.sizeInPixels)
            lineGenerator.setLineColorRed(1.0, green:0.0, blue:0.0)
            
            filter.linesDetectedBlock = { (lineArray:UnsafeMutablePointer<GLfloat>, linesDetected:UInt, frameTime:CMTime) in
                lineGenerator.renderLines(fromArray: lineArray, count:linesDetected, frameTime:frameTime)
            }
            
            camera.addTarget(filter)
            
            let blendFilter = GPUImageAlphaBlendFilter()
            blendFilter.forceProcessing(at: outputView.sizeInPixels)
            let gammaFilter = GPUImageGammaFilter()
            camera.addTarget(gammaFilter)
            gammaFilter.addTarget(blendFilter)
            
            lineGenerator.addTarget(blendFilter)
            
            blendFilter.addTarget(outputView)
            return (filter, nil)
        })
    ),
    FilterOperation <GPUImageColourFASTFeatureDetector>(
        listName:"ColourFAST feature detector",
        titleName:"ColourFAST Feature Detector",
        sliderConfiguration:.disabled,
        sliderUpdateCallback:nil,
        filterOperationType:.singleInput
    ),
    FilterOperation <GPUImageBuffer>(
        listName:"Buffer",
        titleName:"Buffer",
        sliderConfiguration:.disabled,
        sliderUpdateCallback: nil,
        filterOperationType:.custom(filterSetupFunction:{(camera, outputView) in
            let filter = GPUImageBuffer()
            let blendFilter = GPUImageDifferenceBlendFilter()
            let gammaFilter = GPUImageGammaFilter()
            camera.addTarget(gammaFilter)
            gammaFilter.addTarget(blendFilter)
            camera.addTarget(filter)
            filter.addTarget(blendFilter)
            
            blendFilter.addTarget(outputView)
            return (filter, nil)
        })
    ),
    FilterOperation <GPUImageLowPassFilter>(
        listName:"Low pass",
        titleName:"Low Pass",
        sliderConfiguration:.enabled(minimumValue:0.0, maximumValue:1.0, initialValue:0.5),
        sliderUpdateCallback: {(filter, sliderValue) in
            filter.filterStrength = sliderValue
        },
        filterOperationType:.singleInput
    ),
    FilterOperation <GPUImageHighPassFilter>(
        listName:"High pass",
        titleName:"High Pass",
        sliderConfiguration:.enabled(minimumValue:0.0, maximumValue:1.0, initialValue:0.5),
        sliderUpdateCallback: {(filter, sliderValue) in
            filter.filterStrength = sliderValue
        },
        filterOperationType:.singleInput
    ),

//    GPUIMAGE_MOTIONDETECTOR,

    FilterOperation <GPUImageSketchFilter>(
        listName:"Sketch",
        titleName:"Sketch",
        sliderConfiguration:.enabled(minimumValue:0.0, maximumValue:1.0, initialValue:0.5),
        sliderUpdateCallback: {(filter, sliderValue) in
            filter.edgeStrength = sliderValue
        },
        filterOperationType:.singleInput
    ),
    FilterOperation <GPUImageThresholdSketchFilter>(
        listName:"Threshold Sketch",
        titleName:"Threshold Sketch",
        sliderConfiguration:.enabled(minimumValue:0.0, maximumValue:1.0, initialValue:0.25),
        sliderUpdateCallback: {(filter, sliderValue) in
            filter.threshold = sliderValue
        },
        filterOperationType:.singleInput
    ),
    FilterOperation <GPUImageToonFilter>(
        listName:"Toon",
        titleName:"Toon",
        sliderConfiguration:.disabled,
        sliderUpdateCallback: nil,
        filterOperationType:.singleInput
    ),
    FilterOperation <GPUImageSmoothToonFilter>(
        listName:"Smooth toon",
        titleName:"Smooth Toon",
        sliderConfiguration:.enabled(minimumValue:1.0, maximumValue:6.0, initialValue:1.0),
        sliderUpdateCallback: {(filter, sliderValue) in
            filter.blurRadiusInPixels = sliderValue
        },
        filterOperationType:.singleInput
    ),
    FilterOperation <GPUImageTiltShiftFilter>(
        listName:"Tilt shift",
        titleName:"Tilt Shift",
        sliderConfiguration:.enabled(minimumValue:0.2, maximumValue:0.8, initialValue:0.5),
        sliderUpdateCallback: {(filter, sliderValue) in
            filter.topFocusLevel = sliderValue - 0.1
            filter.bottomFocusLevel = sliderValue + 0.1
        },
        filterOperationType:.singleInput
    ),
    FilterOperation <GPUImageCGAColorspaceFilter>(
        listName:"CGA colorspace",
        titleName:"CGA Colorspace",
        sliderConfiguration:.disabled,
        sliderUpdateCallback: nil,
        filterOperationType:.singleInput
    ),
    FilterOperation <GPUImagePosterizeFilter>(
        listName:"Posterize",
        titleName:"Posterize",
        sliderConfiguration:.enabled(minimumValue:1.0, maximumValue:20.0, initialValue:10.0),
        sliderUpdateCallback: {(filter, sliderValue) in
            filter.colorLevels = UInt(round(sliderValue))
        },
        filterOperationType:.singleInput
    ),
    FilterOperation <GPUImage3x3ConvolutionFilter>(
        listName:"3x3 convolution",
        titleName:"3x3 Convolution",
        sliderConfiguration:.disabled,
        sliderUpdateCallback: nil,
        filterOperationType:.custom(filterSetupFunction:{(camera, outputView) in
            let filter = GPUImage3x3ConvolutionFilter()
            camera.addTarget(filter)
            filter.addTarget(outputView)
            filter.convolutionKernel = GPUMatrix3x3(
                one:GPUVector3(one:-1.0, two:0.0, three:1.0),
                two:GPUVector3(one:-2.0, two:0.0, three:2.0),
                three:GPUVector3(one:-1.0, two:0.0, three:1.0))
            return (filter, nil)
        })
    ),
    FilterOperation <GPUImageEmbossFilter>(
        listName:"Emboss",
        titleName:"Emboss",
        sliderConfiguration:.enabled(minimumValue:0.0, maximumValue:5.0, initialValue:1.0),
        sliderUpdateCallback: {(filter, sliderValue) in
            filter.intensity = sliderValue
        },
        filterOperationType:.singleInput
    ),
    FilterOperation <GPUImageLaplacianFilter>(
        listName:"Laplacian",
        titleName:"Laplacian",
        sliderConfiguration:.disabled,
        sliderUpdateCallback: nil,
        filterOperationType:.singleInput
    ),
    FilterOperation <GPUImageChromaKeyFilter>(
        listName:"Chroma key",
        titleName:"Chroma Key",
        sliderConfiguration:.enabled(minimumValue:0.0, maximumValue:1.00, initialValue:0.40),
        sliderUpdateCallback: {(filter, sliderValue) in
            filter.thresholdSensitivity = sliderValue
        },
        filterOperationType:.custom(filterSetupFunction:{(camera, outputView) in
            let filter = GPUImageChromaKeyFilter()
            
            let blendFilter = GPUImageAlphaBlendFilter()
            blendFilter.mix = 1.0
            
#if os(iOS)
            let inputImage = UIImage(named:"WID-small.jpg")
#else
            let inputImage = NSImage(named:"Lambeau.jpg")
#endif
            let blendImage = GPUImagePicture(image: inputImage)

            camera.addTarget(filter)
            blendImage.addTarget(blendFilter)
            blendImage.processImage()
            filter.addTarget(blendFilter)
            blendFilter.addTarget(outputView)
            return (filter, blendImage)
        })
    ),
    FilterOperation <GPUImageKuwaharaFilter>(
        listName:"Kuwahara",
        titleName:"Kuwahara",
        sliderConfiguration:.enabled(minimumValue:3.0, maximumValue:8.0, initialValue:3.0),
        sliderUpdateCallback: {(filter, sliderValue) in
            filter.radius = UInt(round(sliderValue))
        },
        filterOperationType:.singleInput
    ),
    FilterOperation <GPUImageKuwaharaRadius3Filter>(
        listName:"Kuwahara (radius 3)",
        titleName:"Kuwahara (Radius 3)",
        sliderConfiguration:.disabled,
        sliderUpdateCallback: nil,
        filterOperationType:.singleInput
    ),
    FilterOperation <GPUImageVignetteFilter>(
        listName:"Vignette",
        titleName:"Vignette",
        sliderConfiguration:.enabled(minimumValue:0.5, maximumValue:0.9, initialValue:0.75),
        sliderUpdateCallback: {(filter, sliderValue) in
            filter.vignetteEnd = sliderValue
        },
        filterOperationType:.singleInput
    ),
    FilterOperation <GPUImageGaussianBlurFilter>(
        listName:"Gaussian blur",
        titleName:"Gaussian Blur",
        sliderConfiguration:.enabled(minimumValue:0.0, maximumValue:24.0, initialValue:2.0),
        sliderUpdateCallback: {(filter, sliderValue) in
            filter.blurRadiusInPixels = sliderValue
        },
        filterOperationType:.singleInput
    ),
    FilterOperation <GPUImageGaussianSelectiveBlurFilter>(
        listName:"Selective Gaussian blur",
        titleName:"Selective Blur",
        sliderConfiguration:.enabled(minimumValue:0.0, maximumValue:0.75, initialValue:40.0/320.0),
        sliderUpdateCallback: {(filter, sliderValue) in
            filter.excludeCircleRadius = sliderValue
        },
        filterOperationType:.singleInput
    ),
    FilterOperation <GPUImageGaussianBlurPositionFilter>(
        listName:"Positional Gaussian blur",
        titleName:"Circular Blur",
        sliderConfiguration:.enabled(minimumValue:0.0, maximumValue:0.75, initialValue:40.0/320.0),
        sliderUpdateCallback: {(filter, sliderValue) in
            filter.blurRadius = sliderValue
        },
        filterOperationType:.singleInput
    ),
    FilterOperation <GPUImageBoxBlurFilter>(
        listName:"Box blur",
        titleName:"Box Blur",
        sliderConfiguration:.enabled(minimumValue:0.0, maximumValue:24.0, initialValue:2.0),
        sliderUpdateCallback: {(filter, sliderValue) in
            filter.blurRadiusInPixels = sliderValue
        },
        filterOperationType:.singleInput
    ),
    FilterOperation <GPUImageMedianFilter>(
        listName:"Median",
        titleName:"Median",
        sliderConfiguration:.disabled,
        sliderUpdateCallback: nil,
        filterOperationType:.singleInput
    ),
    FilterOperation <GPUImageBilateralFilter>(
        listName:"Bilateral blur",
        titleName:"Bilateral Blur",
        sliderConfiguration:.enabled(minimumValue:0.0, maximumValue:10.0, initialValue:1.0),
        sliderUpdateCallback: {(filter, sliderValue) in
            filter.distanceNormalizationFactor = sliderValue
        },
        filterOperationType:.singleInput
    ),
    FilterOperation <GPUImageMotionBlurFilter>(
        listName:"Motion blur",
        titleName:"Motion Blur",
        sliderConfiguration:.enabled(minimumValue:0.0, maximumValue:180.0, initialValue:0.0),
        sliderUpdateCallback: {(filter, sliderValue) in
            filter.blurAngle = sliderValue
        },
        filterOperationType:.singleInput
    ),
    FilterOperation <GPUImageZoomBlurFilter>(
        listName:"Zoom blur",
        titleName:"Zoom Blur",
        sliderConfiguration:.enabled(minimumValue:0.0, maximumValue:2.5, initialValue:1.0),
        sliderUpdateCallback: {(filter, sliderValue) in
            filter.blurSize = sliderValue
        },
        filterOperationType:.singleInput
    ),

//    GPUIMAGE_IOSBLUR,

    FilterOperation <GPUImageSwirlFilter>(
        listName:"Swirl",
        titleName:"Swirl",
        sliderConfiguration:.enabled(minimumValue:0.0, maximumValue:2.0, initialValue:1.0),
        sliderUpdateCallback: {(filter, sliderValue) in
            filter.angle = sliderValue
        },
        filterOperationType:.singleInput
    ),
    FilterOperation <GPUImageBulgeDistortionFilter>(
        listName:"Bulge",
        titleName:"Bulge",
        sliderConfiguration:.enabled(minimumValue:-1.0, maximumValue:1.0, initialValue:0.5),
        sliderUpdateCallback: {(filter, sliderValue) in
//            filter.scale = sliderValue
            filter.center = CGPoint(x:0.5, y:sliderValue)
        },
        filterOperationType:.singleInput
    ),
    FilterOperation <GPUImagePinchDistortionFilter>(
        listName:"Pinch",
        titleName:"Pinch",
        sliderConfiguration:.enabled(minimumValue:-2.0, maximumValue:2.0, initialValue:0.5),
        sliderUpdateCallback: {(filter, sliderValue) in
            filter.scale = sliderValue
        },
        filterOperationType:.singleInput
    ),
    FilterOperation <GPUImageSphereRefractionFilter>(
        listName:"Sphere refraction",
        titleName:"Sphere Refraction",
        sliderConfiguration:.enabled(minimumValue:0.0, maximumValue:1.0, initialValue:0.15),
        sliderUpdateCallback:{(filter, sliderValue) in
            filter.radius = sliderValue
        },
        filterOperationType:.custom(filterSetupFunction:{(camera, outputView) in
            let filter = GPUImageSphereRefractionFilter()
            camera.addTarget(filter)
            
            // Provide a blurred image for a cool-looking background
            let gaussianBlur = GPUImageGaussianBlurFilter()
            camera.addTarget(gaussianBlur)
            gaussianBlur.blurRadiusInPixels = 5.0

            let blendFilter = GPUImageAlphaBlendFilter()
            blendFilter.mix = 1.0
            gaussianBlur.addTarget(blendFilter)
            filter.addTarget(blendFilter)
            
            blendFilter.addTarget(outputView)

            return (filter, nil)
        })
    ),
    FilterOperation <GPUImageGlassSphereFilter>(
        listName:"Glass sphere",
        titleName:"Glass Sphere",
        sliderConfiguration:.enabled(minimumValue:0.0, maximumValue:1.0, initialValue:0.15),
        sliderUpdateCallback:{(filter, sliderValue) in
            filter.radius = sliderValue
        },
        filterOperationType:.custom(filterSetupFunction:{(camera, outputView) in
            let filter = GPUImageGlassSphereFilter()
            camera.addTarget(filter)
            
            // Provide a blurred image for a cool-looking background
            let gaussianBlur = GPUImageGaussianBlurFilter()
            camera.addTarget(gaussianBlur)
            gaussianBlur.blurRadiusInPixels = 5.0
            
            let blendFilter = GPUImageAlphaBlendFilter()
            blendFilter.mix = 1.0
            gaussianBlur.addTarget(blendFilter)
            filter.addTarget(blendFilter)
            
            blendFilter.addTarget(outputView)
            
            return (filter, nil)
        })
    ),
    FilterOperation <GPUImageStretchDistortionFilter>(
        listName:"Stretch",
        titleName:"Stretch",
        sliderConfiguration:.disabled,
        sliderUpdateCallback: nil,
        filterOperationType:.singleInput
    ),
    FilterOperation <GPUImageRGBDilationFilter>(
        listName:"Dilation",
        titleName:"Dilation",
        sliderConfiguration:.disabled,
        sliderUpdateCallback: nil,
        filterOperationType:.singleInput
    ),
    FilterOperation <GPUImageRGBErosionFilter>(
        listName:"Erosion",
        titleName:"Erosion",
        sliderConfiguration:.disabled,
        sliderUpdateCallback: nil,
        filterOperationType:.singleInput
    ),
    FilterOperation <GPUImageRGBOpeningFilter>(
        listName:"Opening",
        titleName:"Opening",
        sliderConfiguration:.disabled,
        sliderUpdateCallback: nil,
        filterOperationType:.singleInput
    ),
    FilterOperation <GPUImageRGBClosingFilter>(
        listName:"Closing",
        titleName:"Closing",
        sliderConfiguration:.disabled,
        sliderUpdateCallback: nil,
        filterOperationType:.singleInput
    ),

//    GPUIMAGE_PERLINNOISE,
    FilterOperation <GPUImageJFAVoronoiFilter>(
        listName:"Voronoi",
        titleName:"Voronoi",
        sliderConfiguration:.disabled,
        sliderUpdateCallback: nil,
        filterOperationType:.custom(filterSetupFunction: {(camera, outputView) in
            let filter = GPUImageJFAVoronoiFilter()
            let consumerFilter = GPUImageVoronoiConsumerFilter()
#if os(iOS)
            let voronoiPoints = UIImage(named:"voroni_points2.png")
#else
            let voronoiPoints = NSImage(named:"voroni_points2.png")
#endif
            let voronoiPointImage = GPUImagePicture(image:voronoiPoints)

            filter.sizeInPixels = CGSize(width: 1024.0, height: 1024.0)
            consumerFilter.sizeInPixels = CGSize(width: 1024.0, height: 1024.0)
            
            voronoiPointImage.addTarget(filter)
            camera.addTarget(consumerFilter)
            filter.addTarget(consumerFilter)
            voronoiPointImage.processImage()
            
            consumerFilter.addTarget(outputView)
            return (filter, voronoiPointImage)
        })
    ),
    FilterOperation <GPUImageMosaicFilter>(
        listName:"Mosaic",
        titleName:"Mosaic",
        sliderConfiguration:.enabled(minimumValue:0.002, maximumValue:0.05, initialValue:0.025),
        sliderUpdateCallback:{(filter, sliderValue) in
            filter.displayTileSize = CGSize(width: sliderValue, height: sliderValue)
        },
        filterOperationType:.custom(filterSetupFunction:{(camera, outputView) in
            let filter = GPUImageMosaicFilter()
            camera.addTarget(filter)
            
            filter.tileSet = "squares.png"
            filter.colorOn = false
            
            filter.addTarget(outputView)
            
            return (filter, nil)
        })
    ),
    FilterOperation <GPUImageLocalBinaryPatternFilter>(
        listName:"Local binary pattern",
        titleName:"Local Binary Pattern",
        sliderConfiguration:.enabled(minimumValue:1.0, maximumValue:5.0, initialValue:1.0),
        sliderUpdateCallback: {(filter, sliderValue) in
            let filterSize = filter.outputFrameSize()
            filter.texelWidth = (sliderValue / filterSize.width)
            filter.texelHeight = (sliderValue / filterSize.height)
        },
        filterOperationType:.singleInput
    ),
    FilterOperation <GPUImageColorLocalBinaryPatternFilter>(
        listName:"Local binary pattern (color)",
        titleName:"Local Binary Pattern (color)",
        sliderConfiguration:.enabled(minimumValue:1.0, maximumValue:5.0, initialValue:1.0),
        sliderUpdateCallback: {(filter, sliderValue) in
            let filterSize = filter.outputFrameSize()
            filter.texelWidth = (sliderValue / filterSize.width)
            filter.texelHeight = (sliderValue / filterSize.height)
        },
        filterOperationType:.singleInput
    ),
    FilterOperation <GPUImageDissolveBlendFilter>(
        listName:"Dissolve blend",
        titleName:"Dissolve Blend",
        sliderConfiguration:.enabled(minimumValue:0.0, maximumValue:1.0, initialValue:0.5),
        sliderUpdateCallback: {(filter, sliderValue) in
            filter.mix = sliderValue
        },
        filterOperationType:.blend
    ),
    FilterOperation <GPUImageChromaKeyBlendFilter>(
        listName:"Chroma key blend (green)",
        titleName:"Chroma Key (Green)",
        sliderConfiguration:.enabled(minimumValue:0.0, maximumValue:1.0, initialValue:0.4),
        sliderUpdateCallback: {(filter, sliderValue) in
            filter.thresholdSensitivity = sliderValue
        },
        filterOperationType:.blend
    ),
    FilterOperation <GPUImageAddBlendFilter>(
        listName:"Add blend",
        titleName:"Add Blend",
        sliderConfiguration:.disabled,
        sliderUpdateCallback: nil,
        filterOperationType:.blend
    ),
    FilterOperation <GPUImageDivideBlendFilter>(
        listName:"Divide blend",
        titleName:"Divide Blend",
        sliderConfiguration:.disabled,
        sliderUpdateCallback: nil,
        filterOperationType:.blend
    ),
    FilterOperation <GPUImageMultiplyBlendFilter>(
        listName:"Multiply blend",
        titleName:"Multiply Blend",
        sliderConfiguration:.disabled,
        sliderUpdateCallback: nil,
        filterOperationType:.blend
    ),
    FilterOperation <GPUImageOverlayBlendFilter>(
        listName:"Overlay blend",
        titleName:"Overlay Blend",
        sliderConfiguration:.disabled,
        sliderUpdateCallback: nil,
        filterOperationType:.blend
    ),
    FilterOperation <GPUImageLightenBlendFilter>(
        listName:"Lighten blend",
        titleName:"Lighten Blend",
        sliderConfiguration:.disabled,
        sliderUpdateCallback: nil,
        filterOperationType:.blend
    ),
    FilterOperation <GPUImageDarkenBlendFilter>(
        listName:"Darken blend",
        titleName:"Darken Blend",
        sliderConfiguration:.disabled,
        sliderUpdateCallback: nil,
        filterOperationType:.blend
    ),
    FilterOperation <GPUImageColorBurnBlendFilter>(
        listName:"Color burn blend",
        titleName:"Color Burn Blend",
        sliderConfiguration:.disabled,
        sliderUpdateCallback: nil,
        filterOperationType:.blend
    ),
    FilterOperation <GPUImageColorDodgeBlendFilter>(
        listName:"Color dodge blend",
        titleName:"Color Dodge Blend",
        sliderConfiguration:.disabled,
        sliderUpdateCallback: nil,
        filterOperationType:.blend
    ),
    FilterOperation <GPUImageLinearBurnBlendFilter>(
        listName:"Linear burn blend",
        titleName:"Linear Burn Blend",
        sliderConfiguration:.disabled,
        sliderUpdateCallback: nil,
        filterOperationType:.blend
    ),
    FilterOperation <GPUImageScreenBlendFilter>(
        listName:"Screen blend",
        titleName:"Screen Blend",
        sliderConfiguration:.disabled,
        sliderUpdateCallback:nil,
        filterOperationType:.blend
    ),
    FilterOperation <GPUImageDifferenceBlendFilter>(
        listName:"Difference blend",
        titleName:"Difference Blend",
        sliderConfiguration:.disabled,
        sliderUpdateCallback:nil,
        filterOperationType:.blend
    ),
    FilterOperation <GPUImageSubtractBlendFilter>(
        listName:"Subtract blend",
        titleName:"Subtract Blend",
        sliderConfiguration:.disabled,
        sliderUpdateCallback:nil,
        filterOperationType:.blend
    ),
    FilterOperation <GPUImageExclusionBlendFilter>(
        listName:"Exclusion blend",
        titleName:"Exclusion Blend",
        sliderConfiguration:.disabled,
        sliderUpdateCallback:nil,
        filterOperationType:.blend
    ),
    FilterOperation <GPUImageHardLightBlendFilter>(
        listName:"Hard light blend",
        titleName:"Hard Light Blend",
        sliderConfiguration:.disabled,
        sliderUpdateCallback:nil,
        filterOperationType:.blend
    ),
    FilterOperation <GPUImageSoftLightBlendFilter>(
        listName:"Soft light blend",
        titleName:"Soft Light Blend",
        sliderConfiguration:.disabled,
        sliderUpdateCallback:nil,
        filterOperationType:.blend
    ),
    FilterOperation <GPUImageColorBlendFilter>(
        listName:"Color blend",
        titleName:"Color Blend",
        sliderConfiguration:.disabled,
        sliderUpdateCallback:nil,
        filterOperationType:.blend
    ),
    FilterOperation <GPUImageHueBlendFilter>(
        listName:"Hue blend",
        titleName:"Hue Blend",
        sliderConfiguration:.disabled,
        sliderUpdateCallback:nil,
        filterOperationType:.blend
    ),
    FilterOperation <GPUImageSaturationBlendFilter>(
        listName:"Saturation blend",
        titleName:"Saturation Blend",
        sliderConfiguration:.disabled,
        sliderUpdateCallback:nil,
        filterOperationType:.blend
    ),
    FilterOperation <GPUImageLuminosityBlendFilter>(
        listName:"Luminosity blend",
        titleName:"Luminosity Blend",
        sliderConfiguration:.disabled,
        sliderUpdateCallback:nil,
        filterOperationType:.blend
    ),
    FilterOperation <GPUImageNormalBlendFilter>(
        listName:"Normal blend",
        titleName:"Normal Blend",
        sliderConfiguration:.disabled,
        sliderUpdateCallback:nil,
        filterOperationType:.blend
    ),
    FilterOperation <GPUImagePoissonBlendFilter>(
        listName:"Poisson blend",
        titleName:"Poisson Blend",
        sliderConfiguration:.disabled,
        sliderUpdateCallback:nil,
        filterOperationType:.blend
    ),

//    GPUIMAGE_OPACITY,
//    GPUIMAGE_CUSTOM,
//    GPUIMAGE_UIELEMENT,
//    GPUIMAGE_FILECONFIG,
//    GPUIMAGE_FILTERGROUP,
//    GPUIMAGE_FACES,
]
