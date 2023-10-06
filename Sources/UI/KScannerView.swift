//
//  KScannerView.swift
//
//  Created by Ben Ku on 4/7/16.
//  Copyright © 2016 Kudit. All rights reserved.
//
// TODO: fix torch button tinting

// usage: assign torch button if you want to control the flash.  Will use the title color to tint the image.  Selected = torch on, default = torch off

#if canImport(UIKit) && canImport(AVCaptureDevice)
import UIKit
import AVFoundation

class KScannerView: UIView, AVCapturePhotoCaptureDelegate {
    var zoomFactor = 2
    var focalPoint = CGPoint(x: 0.5, y: 0.5)
    /// the frame to use to crop image.  Assumes origin is at 0,0 for top left of this view
    var cropFrame = CGRect.zero
    
    @IBOutlet var torchButton: UIButton?
    
    var torchMode = AVCaptureDevice.TorchMode.off
    private var _device = AVCaptureDevice.default(for: .video)!
    private var _imageOutput = AVCapturePhotoOutput()
    
    func tintTorch() {
        torchButton?.tintColor = torchButton?.currentTitleColor
    }
    
    @objc func toggleTorch() {
        if _device.torchLevel == 0 || !_device.isTorchActive { // torchActive reports 1 when torchMode is auto even if torch is off
            torchMode = .on;
            torchButton?.isSelected = false
        } else {
            torchMode = .off;
            torchButton?.isSelected = true
        }
        tintTorch()
        guard _device.isTorchModeSupported(torchMode) else {
            return
        }
        do {
            try _device.lockForConfiguration()
            _device.torchMode = torchMode
            _device.unlockForConfiguration()
        } catch {
            print("ERROR: \(error)")
        }
    }
    
    private func _setupCaptureDevice() {
        let captureSession = AVCaptureSession()
        captureSession.sessionPreset = AVCaptureSession.Preset.photo
        
        let captureVideoPreviewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        
        var bounds = self.layer.bounds
        bounds.size.width *= CGFloat(zoomFactor)
        bounds.size.height *= CGFloat(zoomFactor)
        captureVideoPreviewLayer.videoGravity = AVLayerVideoGravity.resizeAspectFill
        captureVideoPreviewLayer.bounds = bounds
        captureVideoPreviewLayer.position = CGPoint(x: bounds.midX / CGFloat(zoomFactor), y: bounds.midY / CGFloat(zoomFactor))
        
        if cropFrame == CGRect.zero || cropFrame.size.width > self.layer.bounds.size.width {
            cropFrame = self.layer.bounds
        }
        
        self.layer.addSublayer(captureVideoPreviewLayer)

        // make tintable and link up torch button
        if _device.isTorchModeSupported(torchMode) {
            if torchButton != nil, let image = torchButton?.currentImage {
                let template = image.withRenderingMode(.alwaysTemplate)
                torchButton?.setImage(template, for: .normal)
                torchButton?.addTarget(self, action: #selector(KScannerView.toggleTorch), for: .touchDown)
                tintTorch()
            }
        } else {
            torchButton?.isHidden = true
        }
        
        // set up tap gesture for focus points
        let gestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(KScannerView.focus(gestureRecognizer:)))
        self.addGestureRecognizer(gestureRecognizer)
        self.isUserInteractionEnabled = true
        
        do {
            try _device.lockForConfiguration()
            _device.focusPointOfInterest = focalPoint
            _device.isSmoothAutoFocusEnabled = false
            _device.autoFocusRangeRestriction = .near
            _device.exposurePointOfInterest = focalPoint
            if _device.isFocusModeSupported(.continuousAutoFocus) {
                _device.focusMode = .continuousAutoFocus
            } else {
                _device.focusMode = .locked
            }
            _device.unlockForConfiguration()
            
            let input = try AVCaptureDeviceInput(device: _device)
            captureSession.addInput(input)
            
            _imageOutput = AVCapturePhotoOutput()
            captureSession.addOutput(_imageOutput)
            captureSession.startRunning()
        } catch {
            print("ERROR setting up video layer: \(error)")
        }
    }
    
    /// call this method to initialize the video preview layer (make sure view is inited and in the view hierarchy in order to correctly size video preview).  Best to call in viewWillAppear
    func setupVideoLayer() {
        guard UIImagePickerController.isCameraDeviceAvailable(.rear) else { // for testing simulator
            print("No camera available.")
            return
        }
        // make sure we can actually use the video or that video is supported on the device
        let authorizationStatus = AVCaptureDevice.authorizationStatus(for: .video)
        switch authorizationStatus {
        case .notDetermined:
            // permission dialog not yet presented, request authorization
            AVCaptureDevice.requestAccess(for: .video) { (granted:Bool) -> Void in
                if granted {
                    // go ahead
                    self._setupCaptureDevice()
                }
                else {
                    // user denied, nothing much to do
                    print("Camera access denied")
                    return
                }
            }
        case .authorized:
            // go ahead
            _setupCaptureDevice()
        case .denied, .restricted:
            // the user explicitly denied camera usage or is not allowed to access the camera devices
            print("Camera access denied")
            return
        @unknown default:
            debug("Unknown AV authorization status: \(authorizationStatus)")
        }
    }
    
    @objc public func focus(gestureRecognizer: UITapGestureRecognizer) {
        if gestureRecognizer.state == .ended {
            // Don't change focal point since this is a scanner the focus point should always be the same
//            let location = gestureRecognizer.locationInView(self)
//            let point = CGPoint(x: location.x / bounds.size.width, y: location.y / bounds.size.height)
            
            do {
                try _device.lockForConfiguration()
//                _device.focusPointOfInterest = point
//                _device.exposurePointOfInterest = point
                _device.focusMode = .autoFocus
                _device.unlockForConfiguration()
            } catch {
                print("ERROR setting up video layer: \(error)")
            }
        }
    }

    var _imageCallback: ((UIImage?) -> Void)? = nil

    func captureImage(callback: @escaping (UIImage?) -> Void) { // TODO: see where used and see if image label on callback function is even relevant or necessary (removed image: UIImage? from previous code)
        _imageCallback = callback
        
        var videoConnection: AVCaptureConnection?
        for connection in _imageOutput.connections {
            for port in (connection as AnyObject).inputPorts {
                if (port as AnyObject).mediaType == AVMediaType.video {
                    videoConnection = connection // AVCaptureConnection already
                    break
                }
            }
            if videoConnection != nil {
                break
            }
        }
        guard videoConnection != nil else {
            callback(nil)
            return
        }
        _imageOutput.capturePhoto(with: AVCapturePhotoSettings(), delegate: self)
    }
    @available(iOS 11.0, *)
    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        let imageData = photo.fileDataRepresentation()
        guard var image = UIImage(data: imageData!) else {
            print("Image data error")
            _imageCallback?(nil)
            return
        }
        
        //            UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil) // for debugging
        // crop to crop frame + offset based on zoom factor
        
        //            1    0        (1 - 1) / 1 * 2
        //            2    1/4        (2 - 1) / 2 * 2
        //            4    3/8        (4 - 1) / 4 * 2
        
        let blockSize = 1 / CGFloat(self.zoomFactor)
        
        let rect = CGRect(
            x: blockSize * self.cropFrame.origin.x / self.bounds.size.width + (CGFloat(self.zoomFactor) - 1) * blockSize / 2,
            y: blockSize * self.cropFrame.origin.y / self.bounds.size.height + (CGFloat(self.zoomFactor) - 1) * blockSize / 2,
            width: (self.cropFrame.size.width / self.bounds.size.width) / CGFloat(self.zoomFactor),
            height: (self.cropFrame.size.height / self.bounds.size.height) / CGFloat(self.zoomFactor))
        let cropRect = CGRect(
            x: image.size.width * rect.origin.x,
            y: image.size.height * rect.origin.y,
            width: image.size.width * rect.width,
            height: image.size.height * rect.height)
        image = image.croppedToRect(cropRect)
        
        // For debugging.  TODO: take this out.
        //            UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil)
        
        _imageCallback?(image)
        
    }
    /*
    func capture(_ captureOutput: AVCapturePhotoOutput, didFinishProcessingPhotoSampleBuffer photoSampleBuffer: CMSampleBuffer?, previewPhotoSampleBuffer: CMSampleBuffer?, resolvedSettings: AVCaptureResolvedPhotoSettings, bracketSettings: AVCaptureBracketedStillImageSettings?, error: Error?) {
        if let buffer = photoSampleBuffer {
            let imageData = AVCapturePhotoOutput.jpegPhotoDataRepresentation(forJPEGSampleBuffer: buffer, previewPhotoSampleBuffer: nil)
            
            guard var image = UIImage(data: imageData!) else {
                print("Image data error")
                _imageCallback?(nil)
                return
            }
            
            //            UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil) // for debugging
            // crop to crop frame + offset based on zoom factor
            
            //            1    0        (1 - 1) / 1 * 2
            //            2    1/4        (2 - 1) / 2 * 2
            //            4    3/8        (4 - 1) / 4 * 2
            
            let blockSize = 1 / CGFloat(self.zoomFactor)
            
            let rect = CGRect(
                x: blockSize * self.cropFrame.origin.x / self.bounds.size.width + (CGFloat(self.zoomFactor) - 1) * blockSize / 2,
                y: blockSize * self.cropFrame.origin.y / self.bounds.size.height + (CGFloat(self.zoomFactor) - 1) * blockSize / 2,
                width: (self.cropFrame.size.width / self.bounds.size.width) / CGFloat(self.zoomFactor),
                height: (self.cropFrame.size.height / self.bounds.size.height) / CGFloat(self.zoomFactor))
            let cropRect = CGRect(
                x: image.size.width * rect.origin.x,
                y: image.size.height * rect.origin.y,
                width: image.size.width * rect.width,
                height: image.size.height * rect.height)
            image = image.croppedToRect(cropRect)
            
            // For debugging.  TODO: take this out.
            //            UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil)
            
            _imageCallback?(image)
            
        }
    }*/
}
#endif
// LightningBolt file was used for enabling light for scanning.  TODO: if used, replace with SFSymbol "bolt.fill" and "bolt.slash.fill"
