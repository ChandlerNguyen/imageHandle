import UIKit
import GPUImage
import AVFoundation

let blendImageName = "WID-small.jpg"

class FilterDisplayViewController: UIViewController, UISplitViewControllerDelegate {
    
    @IBOutlet var filterSlider: UISlider?
    @IBOutlet var filterView: RenderView?
    
    let videoCamera:Camera?
    var blendImage:PictureInput?
    
    //    let iflyFaceReq : IFlySpeechFaceRequest = IFlySpeechFaceRequest()
    
    required init(coder aDecoder: NSCoder)
    {
        do {
            videoCamera = try Camera(sessionPreset:AVCaptureSessionPreset640x480, location:.backFacing)
            videoCamera!.runBenchmark = true
        } catch {
            videoCamera = nil
            print("Couldn't initialize camera with error: \(error)")
        }
        
        super.init(coder: aDecoder)!
    }
    
    var filterOperation: FilterOperationInterface?
    
    func configureView() {
        guard let videoCamera = videoCamera else {
            let errorAlertController = UIAlertController(title: NSLocalizedString("Error", comment: "Error"), message: "Couldn't initialize camera", preferredStyle: .alert)
            errorAlertController.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: "OK"), style: .default, handler: nil))
            self.present(errorAlertController, animated: true, completion: nil)
            return
        }
        if let currentFilterConfiguration = self.filterOperation {
            self.title = currentFilterConfiguration.titleName
            
            // Configure the filter chain, ending with the view
            if let view = self.filterView {
                switch currentFilterConfiguration.filterOperationType {
                case .singleInput:
                    videoCamera.addTarget(currentFilterConfiguration.filter)
                    currentFilterConfiguration.filter.addTarget(view)
                case .blend:
                    videoCamera.addTarget(currentFilterConfiguration.filter)
                    self.blendImage = PictureInput(imageName:blendImageName)
                    self.blendImage?.addTarget(currentFilterConfiguration.filter)
                    self.blendImage?.processImage()
                    currentFilterConfiguration.filter.addTarget(view)
                case let .custom(filterSetupFunction:setupFunction):
                    currentFilterConfiguration.configureCustomFilter(setupFunction(videoCamera, currentFilterConfiguration.filter, view))
                }
                
                videoCamera.startCapture()
            }
            
            // Hide or display the slider, based on whether the filter needs it
            if let slider = self.filterSlider {
                switch currentFilterConfiguration.sliderConfiguration {
                case .disabled:
                    slider.isHidden = true
                //case let .Enabled(minimumValue, initialValue, maximumValue, filterSliderCallback):
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
            case .enabled(_, _, _): currentFilterConfiguration.updateBasedOnSliderValue(Float(self.filterSlider!.value))
            case .disabled: break
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.configureView()
        //        self.iflyFaceReq.delegate = self
        //        let tempArray:Array = ["Good","Good Night","Good EveryBody","Good Day","Good S","Good M"]
        //        for i:Int in 0..<tempArray.count {
        //            let tempImageView:UIImageView = LKDrawLabBgImage.getParameterCreateLabBgImage(tempArray[i] , strFont: UIFont(name: "Times New Roman", size: 14.0))
        //            var rectFrame:CGRect = tempImageView.frame
        //            rectFrame.origin.y = CGFloat(50 * i + 5)
        //            tempImageView.frame = rectFrame
        //            self.view.addSubview(tempImageView)
        //        }
        
        let btn_red:UIButton = UIButton(frame: CGRect(x: 10, y: 50, width: 60, height: 44))
        btn_red.backgroundColor = UIColor.red
        btn_red.addTarget(self, action: #selector(FilterDisplayViewController.clickRed(sender:)), for: .touchUpInside)
        self.view.addSubview(btn_red)
        
        let btn_verify:UIButton = UIButton(frame: CGRect(x: 10, y: 50, width: 60, height: 44))
        btn_verify.backgroundColor = UIColor.red
        btn_verify.addTarget(self, action: #selector(FilterDisplayViewController.clickverify(sender:)), for: .touchUpInside)
        self.view.addSubview(btn_verify)
        
        let tap:UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(LMImageFilter.tapAction(sender:)))
        tap.numberOfTapsRequired = 1
        tap.numberOfTouchesRequired = 1
        self.view.addGestureRecognizer(tap)
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        if let videoCamera = videoCamera {
            videoCamera.stopCapture()
            videoCamera.removeAllTargets()
            blendImage?.removeAllTargets()
        }
        
        super.viewWillDisappear(animated)
    }
    
    func sender(sender:AnyObject) {
        //        self.iflyFaceReq.setParameter("58afd450", forKey:IFlyFaceConstant.appid())
        //        self.iflyFaceReq.setParameter(IFlyFaceConstant.wfr(), forKey: IFlyFaceConstant.sub())
        //        self.iflyFaceReq.setParameter(IFlyFaceConstant.raw(), forKey: IFlyFaceConstant.aue())
        //        self.iflyFaceReq.setParameter("0", forKey: IFlyFaceConstant.pset())
        //        self.iflyFaceReq.setParameter("true", forKey: IFlyFaceConstant.skip())
    }
    
    func clickRed(sender:Any) {
    }
    
    func clickverify(sender:Any) {
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //    // MARK: ------------ IFlySpeechFaceRequestDelegate
    //    func onEvent(_ eventType: Int32, withBundle params: String!) {
    //        
    //    }
    //    
    //    func onData(_ data: Data!) {
    //        
    //    }
    
}

