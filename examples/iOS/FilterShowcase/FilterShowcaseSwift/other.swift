//
//  other.swift
//  FilterShowcase
//
//  Created by wzkj on 2017/1/19.
//  Copyright © 2017年 Sunset Lake Software. All rights reserved.
//

import UIKit
import AVFoundation

class other: UITableViewController {
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row == 0 {
            self.navigationController?.pushViewController(LMImageFilter(mediaType:.Camera, sessionPresset:AVCaptureSessionPreset1280x720 as String, cameraPosition: .back), animated: true)
        } else if indexPath.row == 1{
            self.navigationController?.pushViewController(LMImageFilter(sourceImage:#imageLiteral(resourceName: "WID-small.jpg")), animated: true)
        }
        
    }
}
