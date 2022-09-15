//
//  UIImage.swift
//  KuditFrameworks
//
//  Created by Ben Ku on 2/8/16.
//  Copyright © 2016 Kudit. All rights reserved.
//
/*** TODO: figure out where this is used and what for and if it's necessary add back in
#if canImport(UIKit)
import UIKit
import CoreMedia // not available in watchOS
import Accelerate // not available in watchOS

extension CGSize {
    /// return the size scaled down to fit inside the `availableSpace` bounds.
    func fitToSize(_ availableSpace: CGSize) -> CGSize {
        // calculate rect
        let aspectRatio = self.width / self.height
        if availableSpace.width / aspectRatio <= availableSpace.height {
            return CGSize(width: availableSpace.width, height: availableSpace.width / aspectRatio)
        } else {
            return CGSize(width: availableSpace.height * aspectRatio, height: availableSpace.height)
        }
    }
}


public extension UIImage {
    /// return a horizontally flipped version of the image
    var flippedHorizontally: UIImage {
        UIGraphicsBeginImageContext(self.size)
        let context = UIGraphicsGetCurrentContext()
        
        // core graphics seems to flip vertically automatically :-/
        context?.translateBy(x: self.size.width, y: self.size.height)
        context?.scaleBy(x: -1.0, y: -1.0)
        
        context?.draw(self.cgImage!, in: CGRect(x: 0.0, y: 0.0, width: self.size.width, height: self.size.height))
            
        let flippedImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()

        return flippedImage!
    }
    
    /// return a sub-image using the provided cropping rect.
    func croppedToRect(_ rect: CGRect) -> UIImage {
        //create drawing context
        UIGraphicsBeginImageContextWithOptions(rect.size, false, 1.0);
    
        let origin = rect.origin
        
        // draw into the cropped area (assuming within bounds so offset so the overlap is within the rectangle.  TODO: check for bounds so we're not drawing off-screen entirely.
        self.draw(in: CGRect(x: -origin.x, y: -origin.y, width: self.size.width, height: self.size.height))
    
        //capture resultant image
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        //return image
        return image!
    }
    
    /// aspect fit image to size and include transparent padding
    func scaledToSize(_ size: CGSize) -> UIImage {
        //calculate rect
        let targetSize = self.size.fitToSize(size)
        
        //create drawing context
        UIGraphicsBeginImageContextWithOptions(targetSize, false, 0.0);
        
        var origin = CGPoint(x: 0, y: 0)
        if targetSize.width < size.width {
            origin.x = (size.width - targetSize.width) / 2.0
        }
        if targetSize.height < size.height {
            origin.y = (size.height - targetSize.height) / 2.0
        }
        
        //draw
        self.draw(in: CGRect(x: origin.x, y: origin.y, width: targetSize.width, height: targetSize.height))
        
        //capture resultant image
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        //return image
        return image!
    }

    /// aspect fit image to size (but don't include transparent padding).
    func fitInsideSize(_ size: CGSize) -> UIImage {
        //calculate rect
        let targetSize = self.size.fitToSize(size)
        return self.scaledToSize(targetSize)
    }
    
    /// center square crop image
    var squareCropped: UIImage {
        var startX:CGFloat = 0
        var startY:CGFloat = 0
        let size: CGFloat
        if self.size.width > self.size.height {
            size = self.size.height
            startX = (self.size.width - size) / 2
        } else if self.size.height > self.size.width {
            size = self.size.width
            startY = (self.size.height - size) / 2
        } else {
            // already a square.  Just return self.
            return self
        }
        return self.croppedToRect(CGRect(x: startX, y: startY, width: size, height: size))
    }

    /// returns the image padded with the specified color.  If the color is nil, it will stretch the image and blur and use that as the padding
    func paddedToSize(_ newSize: CGSize, color: UIColor? = nil, blur: Int = 40) -> UIImage { // TODO: make throws?
        //create drawing context
        UIGraphicsBeginImageContextWithOptions(newSize, false, 0.0)
    
        if self.size.width > newSize.width {
            print("cannot pad to less than image width")
            return self
        }
        if self.size.height > newSize.height {
            print("cannot padd to less than image height")
            return self
        }
        let origin = CGPoint(x: (newSize.width - self.size.width) / 2.0, y: (newSize.height - self.size.height) / 2.0)

        if let padColor = color {
            // fill with pad color
            padColor.set()
            UIRectFill(CGRect(x: 0.0, y: 0.0, width: newSize.width, height: newSize.height))
        } else {
            // fill with image scaled/stretched as needed
            self.blurred(blur).draw(in: CGRect(x: 0, y: 0, width: newSize.width, height: newSize.height))
        }
        
        //draw scaled image
        self.draw(in: CGRect(x: origin.x, y: origin.y, width: self.size.width, height: self.size.height))
        
        //capture resultant image
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        //return image
        return image!
    }
    
    /// return copy of self that can be used as a template image for tinting
    var asTemplate: UIImage {
        return self.withRenderingMode(.alwaysTemplate)
    }
    
    /// creates a blurred version of the image.
    /// if there is a problem, just returns self.
    // swift code pulled from https://github.com/hongxinhope/UIImageEffects/blob/master/UIImageEffects/UIImageEffects.swift
    func blurred(_ blurRadius: Int = 40, tintColor: UIColor? = nil, saturationDeltaFactor: CGFloat = 1, maskImage: UIImage? = nil) -> UIImage {
        // Check pre-conditions
        if self.size.width < 1 || self.size.height < 1 {
            print("Image blur error: invalid size: (\(self.size.width) x \(self.size.height)). Both dimensions must be >= 1")
            return self
        }
        guard self.cgImage != nil else {
            print("Image blur error: image must be backed by a CGImage")
            return self
        }
        if maskImage != nil && maskImage!.cgImage == nil {
            print("Image blur error: maskImage must be backed by a CGImage")
            return self
        }
        
        let hasBlur = CGFloat(blurRadius) > CGFloat(Float.ulpOfOne)
        let hasSaturationChange = abs(saturationDeltaFactor - 1) > CGFloat(Float.ulpOfOne)
        let inputCGImage = cgImage!
        let inputImageScale = scale
        let inputImageBitmapInfo = inputCGImage.bitmapInfo
        let inputImageAlphaInfo = CGImageAlphaInfo(rawValue: inputImageBitmapInfo.rawValue & CGBitmapInfo.alphaInfoMask.rawValue)
        let outputImageSizeInPoints = size
        let outputImageRectInPoints = CGRect(origin: CGPoint.zero, size: outputImageSizeInPoints)
        let useOpaqueContext = inputImageAlphaInfo == CGImageAlphaInfo.none || inputImageAlphaInfo == .noneSkipLast || inputImageAlphaInfo == .noneSkipFirst
        UIGraphicsBeginImageContextWithOptions(outputImageRectInPoints.size, useOpaqueContext, inputImageScale)
        defer {
            UIGraphicsEndImageContext()
        }
        let outputContext = UIGraphicsGetCurrentContext()
        outputContext?.scaleBy(x: 1, y: -1)
        outputContext?.translateBy(x: 0, y: -outputImageRectInPoints.height)
        if hasBlur || hasSaturationChange {
            var effectInBuffer = vImage_Buffer()
            var scratchBuffer1 = vImage_Buffer()
            var inputBuffer: UnsafeMutablePointer<vImage_Buffer>
            var outputBuffer: UnsafeMutablePointer<vImage_Buffer>
            let bitmapInfo = CGBitmapInfo(rawValue: CGImageAlphaInfo.premultipliedFirst.rawValue | CGBitmapInfo.byteOrder32Little.rawValue)
            var format = vImage_CGImageFormat(bitsPerComponent: 8,
                                              bitsPerPixel: 32,
                                              colorSpace: nil,
                                              bitmapInfo: bitmapInfo,
                                              version: 0,
                                              decode: nil,
                                              renderingIntent: .defaultIntent)
            let error = vImageBuffer_InitWithCGImage(&effectInBuffer, &format, nil, inputCGImage, vImage_Flags(kvImagePrintDiagnosticsToConsole))
            if error != kvImageNoError {
                print("error: vImageBuffer_InitWithCGImage returned error code \(error)")
                return self
            }
            vImageBuffer_Init(&scratchBuffer1, effectInBuffer.height, effectInBuffer.width, format.bitsPerPixel, vImage_Flags(kvImageNoFlags))
            inputBuffer = withUnsafeMutablePointer(to: &effectInBuffer, { (address) -> UnsafeMutablePointer<vImage_Buffer> in
                return address
            })
            outputBuffer = withUnsafeMutablePointer(to: &scratchBuffer1, { (address) -> UnsafeMutablePointer<vImage_Buffer> in
                return address
            })
            if hasBlur {
                // A description of how to compute the box kernel width from the Gaussian
                // radius (aka standard deviation) appears in the SVG spec:
                // http://www.w3.org/TR/SVG/filters.html#feGaussianBlurElement
                //
                // For larger values of 's' (s >= 2.0), an approximation can be used: Three
                // successive box-blurs build a piece-wise quadratic convolution kernel, which
                // approximates the Gaussian kernel to within roughly 3%.
                //
                // let d = floor(s * 3*sqrt(2*pi)/4 + 0.5)
                //
                // ... if d is odd, use three box-blurs of size 'd', centered on the output pixel.
                //
                var inputRadius = CGFloat(blurRadius) * inputImageScale
                if inputRadius - 2 < CGFloat(Float.ulpOfOne) {
                    inputRadius = 2
                }
                var radius = UInt32(floor((inputRadius * CGFloat(3) * CGFloat(sqrt(2 * Float.pi)) / 4 + 0.5) / 2))
                radius |= 1
                let flags = vImage_Flags(kvImageGetTempBufferSize) | vImage_Flags(kvImageEdgeExtend)
                let tempBufferSize: Int = vImageBoxConvolve_ARGB8888(inputBuffer, outputBuffer, nil, 0, 0, radius, radius, nil, flags)
                let tempBuffer = malloc(tempBufferSize)
                vImageBoxConvolve_ARGB8888(inputBuffer, outputBuffer, tempBuffer, 0, 0, radius, radius, nil, vImage_Flags(kvImageEdgeExtend))
                vImageBoxConvolve_ARGB8888(outputBuffer, inputBuffer, tempBuffer, 0, 0, radius, radius, nil, vImage_Flags(kvImageEdgeExtend))
                vImageBoxConvolve_ARGB8888(inputBuffer, outputBuffer, tempBuffer, 0, 0, radius, radius, nil, vImage_Flags(kvImageEdgeExtend))
                free(tempBuffer)
                let temp = inputBuffer
                inputBuffer = outputBuffer
                outputBuffer = temp
            }
            if hasSaturationChange {
                let s = saturationDeltaFactor
                let floatingPointSaturationMatrix: [CGFloat] = [
                    0.0722 + 0.9278 * s,  0.0722 - 0.0722 * s,  0.0722 - 0.0722 * s,  0,
                    0.7152 - 0.7152 * s,  0.7152 + 0.2848 * s,  0.7152 - 0.7152 * s,  0,
                    0.2126 - 0.2126 * s,  0.2126 - 0.2126 * s,  0.2126 + 0.7873 * s,  0,
                    0,                    0,                    0,  1,
                    ]
                let divisor: Int32 = 256
                let matrixSize = floatingPointSaturationMatrix.count
                var saturationMatrix = [Int16](repeating: 0, count: matrixSize)
                for i in 0..<matrixSize {
                    saturationMatrix[i] = Int16(round(floatingPointSaturationMatrix[i] * CGFloat(divisor)))
                }
                vImageMatrixMultiply_ARGB8888(inputBuffer, outputBuffer, saturationMatrix, divisor, nil, nil, vImage_Flags(kvImageNoFlags))
                let temp = inputBuffer
                inputBuffer = outputBuffer
                outputBuffer = temp
            }
            let cleanupBuffer: @convention(c) (UnsafeMutableRawPointer?, UnsafeMutableRawPointer?) -> Void = {(userData, buf_data) -> Void in
                free(buf_data)
            }
            var effectCGImage = vImageCreateCGImageFromBuffer(inputBuffer, &format, cleanupBuffer, nil, vImage_Flags(kvImageNoAllocate), nil)
            if effectCGImage == nil {
                effectCGImage = vImageCreateCGImageFromBuffer(inputBuffer, &format, nil, nil, vImage_Flags(kvImageNoFlags), nil)
                free(inputBuffer.pointee.data)
            }
            if let _ = maskImage {
                outputContext?.draw(inputCGImage, in: outputImageRectInPoints)
            }
            outputContext?.saveGState()
            if let maskImage = maskImage {
                outputContext?.clip(to: outputImageRectInPoints, mask: maskImage.cgImage!)
            }
            outputContext?.draw((effectCGImage?.takeRetainedValue())!, in: outputImageRectInPoints)
            outputContext?.restoreGState()
            free(outputBuffer.pointee.data)
        } else {
            outputContext?.draw(inputCGImage, in: outputImageRectInPoints)
        }
        if let tintColor = tintColor {
            outputContext?.saveGState()
            outputContext?.setFillColor(tintColor.cgColor)
            outputContext?.fill(outputImageRectInPoints)
            outputContext?.restoreGState()
        }
        let outputImage = UIGraphicsGetImageFromCurrentImageContext()
        return outputImage!
    }
}
#endif
*/
