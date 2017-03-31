import UIKit
import GPUImage

class FilterDisplayViewController: UIViewController, UISplitViewControllerDelegate {

    @IBOutlet var filterSlider: UISlider?
    @IBOutlet var filterView: GPUImageView?
    
    let videoCamera: GPUImageVideoCamera
    var blendImage: GPUImagePicture?

    required init(coder aDecoder: NSCoder)
    {
        videoCamera = GPUImageVideoCamera(sessionPreset: AVCaptureSessionPreset640x480, cameraPosition: .back)
        videoCamera.outputImageOrientation = .portrait;

        super.init(coder: aDecoder)!
    }
    
    var filterOperation: FilterOperationInterface? {
        didSet {
            self.configureView()
        }
    }

    func configureView() {
        if let currentFilterConfiguration = self.filterOperation {
            self.title = currentFilterConfiguration.titleName
            
            // Configure the filter chain, ending with the view
            if let view = self.filterView {
                switch currentFilterConfiguration.filterOperationType {
                case .singleInput:
                    videoCamera.addTarget((currentFilterConfiguration.filter as! GPUImageInput))
                    currentFilterConfiguration.filter.addTarget(view)
                case .blend:
                    videoCamera.addTarget((currentFilterConfiguration.filter as! GPUImageInput))
                    let inputImage = UIImage(named:"WID-small.jpg")
                    self.blendImage = GPUImagePicture(image: inputImage)
                    self.blendImage?.addTarget((currentFilterConfiguration.filter as! GPUImageInput))
                    self.blendImage?.processImage()
                    currentFilterConfiguration.filter.addTarget(view)
                case let .custom(filterSetupFunction:setupFunction):
                    let inputToFunction:(GPUImageOutput, GPUImageOutput?) = setupFunction(videoCamera, view) // Type inference falls down, for now needs this hard cast
                    currentFilterConfiguration.configureCustomFilter(inputToFunction)
                }
                
                videoCamera.startCapture()
            }

            // Hide or display the slider, based on whether the filter needs it
            if let slider = self.filterSlider {
                switch currentFilterConfiguration.sliderConfiguration {
                case .disabled:
                    slider.isHidden = true
//                case let .Enabled(minimumValue, initialValue, maximumValue, filterSliderCallback):
                case let .enabled(minimumValue, maximumValue, initialValue):
                    slider.minimumValue = minimumValue
                    slider.maximumValue = maximumValue
                    slider.value = initialValue
                    slider.isHidden = false
                    self.updateSliderValue()
                }
            }
            
        }
    }
    
    @IBAction func updateSliderValue() {
        if let currentFilterConfiguration = self.filterOperation {
            switch (currentFilterConfiguration.sliderConfiguration) {
            case .enabled(_, _, _):
                currentFilterConfiguration.updateBasedOnSliderValue(CGFloat(self.filterSlider!.value)) // If the UISlider isn't wired up, I want this to throw a runtime exception
            case .disabled:
                break
            }
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.configureView()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}

