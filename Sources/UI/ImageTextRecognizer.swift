//
//  ImageTextRecognizer.swift
//
//  Created by Ben Ku on 7/24/22.
//  Modified by Ben Ku on 8/28/2023
//


import Foundation
import Vision

public struct RecognizedText: Identifiable {
    public var text: String
    public var bounds: CGRect
    public var confidence: VNConfidence
    public var id = UUID()
}

// var recognizedBlocks = await ImageTextRecognizer.parseItem(image)
public extension [RecognizedText] {
    static func parse(cgImage: CGImage) async -> [RecognizedText] {
        // Create a new image-request handler.
        let requestHandler = VNImageRequestHandler(cgImage: cgImage)
        
        return await withCheckedContinuation { continuation in
            // Create a new request to recognize text.
            let request = VNRecognizeTextRequest { request, error in
                guard let observations = request.results as? [VNRecognizedTextObservation] else {
                    debug("Received invalid observations", level: .ERROR)
                    continuation.resume(returning: []) // TODO: Throw error somehow?
                    return
                    // continue with [] instead?
                }
                
                var results = [RecognizedText]()
                
                for observation in observations {
//                    debug("Candidates: \(observation.topCandidates(8))", level: .DEBUG)
                    // Find the top observation.
                    guard let candidate = observation.topCandidates(1).first else {
                        debug("No candidate", level: .NOTICE)
                        continue
                    }
                    
                    debug("Found this candidate: \(candidate.string) [\(candidate.confidence)]", level: .DEBUG)
                    
                    /*
                    // Find the bounding-box observation for the string range.
                    let stringRange = candidate.string.startIndex..<candidate.string.endIndex
                    let boxObservation = try? candidate.boundingBox(for: stringRange)
                    
                    // Get the normalized CGRect value.
                    let boundingBox = boxObservation?.boundingBox ?? .zero
*/
                    // origin is lower left corner of image
                    let boundingBox = CGRect(origin: CGPoint(x: observation.topLeft.x, y: 1 - observation.topLeft.y), size: CGSize(width: observation.topRight.x - observation.topLeft.x, height: observation.topLeft.y - observation.bottomLeft.y))

                    // Convert the rectangle from normalized coordinates to image coordinates.
                    let bounds = VNImageRectForNormalizedRect(boundingBox,
                                                              Int(cgImage.width),
                                                              Int(cgImage.height))

//                    debug("Found this candidate: \(candidate.string) [\(boundingBox)] -> [\(bounds)]", level: .NOTICE)
                    
                    let result = RecognizedText(text: candidate.string, bounds: bounds, confidence: candidate.confidence)
                    results.append(result)
                }
                
                // Continuation with result
                //results =  Array(results.prefix(3)) // get just first 3 items
                continuation.resume(returning:results)
            }
            
            do {
                // Perform the text-recognition request.
                try requestHandler.perform([request])
            } catch {
                debug("Unable to perform the requests: \(error).", level: .WARNING)
                continuation.resume(returning: [])
            }
        }
    }
    
    func orderHorizontal() -> [RecognizedText] {
        return self.sorted { tA, tB in
            tA.bounds.origin.x < tB.bounds.origin.x            
        }
    }
    
    func lineOrder() -> [RecognizedText] {
        guard self.count > 1 else {
            return self
        }
        
        var ordered = [RecognizedText]()

        // wiggle room should be 2/3 of the smallest height box
        let heights = self.map { $0.bounds.height }.filter { $0 > 5 } // filter out items that are 0 height or less than 5 height so we have a minimum of 3px wiggle room when all is said and done.
        debug("Box Heights: \(heights)", level: .DEBUG)
        let delta = (heights.min() ?? 5) * 2 / 3 // further shrink in case all blocks are exactly height away
        debug("Delta set to \(delta)", level: .DEBUG)
        // order vertical
        let vertical = self.sorted { tA, tB in
            tA.bounds.origin.y < tB.bounds.origin.y
        }
        var yLevel = vertical.first!.bounds.origin.y // guaranteed since guard above
        var lineItems = [RecognizedText]()
        // go through line by line and find similar +10, then order horizontally
        for item in vertical {
            if item.bounds.origin.y < yLevel + delta {
                lineItems.append(item)
            } else {
                ordered += lineItems.orderHorizontal()
                // start next line
                lineItems = [item]
                yLevel = item.bounds.origin.y
            }
        }
        ordered += lineItems.orderHorizontal()
        return ordered
    }
    
    var short: String {
        let strings = self.map { $0.text }
        return strings.joined(separator: "\n")
    }
}

#if canImport(UIKit)
// iOS, tvOS, and watchOS – use UIImage
import UIKit
import CoreGraphics
public extension Data {
    func asCGImage() -> CGImage? {
        guard let image = UIImage(data: self), let cgImage = image.cgImage else {
            debug("Unable to create CGImage from data.", level: .WARNING)
            return nil
        }
        return cgImage
    }
}
#elseif canImport(AppKit)
// macOS - use NSImage
import AppKit
public extension Data {
    func asCGImage() -> CGImage? {
        guard let image = NSImage(data: self), let cgImage = image.cgImage(forProposedRect: nil, context: nil, hints: nil) else {
            debug("Unable to create CGImage from data.", level: .WARNING)
            return nil
        }
        return cgImage
    }
}
#else
// all other platforms - Can't convert to CGImage
#endif

import SwiftUI
class RecognizedImageModel: ObservableObject {
    let urlString: String
    @Published var recognizedTexts = [RecognizedText]()
    
    init(urlString: String) {
        self.urlString = urlString
        Task {
            guard let imageURL = URL(string: urlString),
                  let data = try? await imageURL.download(),
                  let cgImage = data.asCGImage() else {
                debug("Unable to scan image. \(urlString)", level: .ERROR)
                return
            }
            recognizedTexts = await [RecognizedText].parse(cgImage: cgImage)
            debug("RAW: \(recognizedTexts.short)••••", level: .DEBUG)
            let sorted = recognizedTexts.lineOrder()
            debug("SORTED: \(sorted.short)", level: .DEBUG)
        }
    }
}
public struct RecognizedImageView: View {
    @StateObject var model: RecognizedImageModel
    public var body: some View {
        ZStack(alignment: .topLeading) {
            AsyncImage(url: URL(string: model.urlString)?.secured)
            ForEach(model.recognizedTexts) { recognizedText in
                Rectangle()
                    .fill(.red.opacity(0.1))
                    .frame(width: recognizedText.bounds.width, height: recognizedText.bounds.height)
                    .overlay {
                        Text(recognizedText.text)         
                            .foregroundColor(.green)
                    }
                    .border(.red)
                    .offset(x: recognizedText.bounds.origin.x, y: recognizedText.bounds.origin.y)
                //                    .offset(recognizedText.bounds.origin)
            }
        }
    }
}

struct ImageRecognizer_Previews: PreviewProvider {
//    static let testURL = "https://fbfeudguide.com/wp-content/uploads/2023/08/Screenshot-2023-08-23-at-11.18.22-AM-768x456.png"
// static let testURL = "https://fbfeudguide.com/wp-content/uploads/2023/08/Screenshot-2023-08-22-at-2.24.17-PM-768x458.png"
  //  static let testURL = "https://facebookfamilyfeudcheats.files.wordpress.com/2010/07/picture-14.png"
//    static let testURL = "https://facebookfamilyfeudcheats.files.wordpress.com/2010/06/picture-4.png"
//    static let testURL = "http://facebookfamilyfeudcheats.files.wordpress.com/2010/06/picture-3.png"
    static let testURL = "http://facebookfamilyfeudcheats.files.wordpress.com/2010/06/picture-12.png"
    static var previews: some View {
        let _ = { DebugLevel.currentLevel = .WARNING }()
        VStack {
            Text("Test Image")
            RecognizedImageView(model: RecognizedImageModel(urlString: testURL))
                .scaledToFit()
        }
    }
}
