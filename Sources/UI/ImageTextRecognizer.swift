//
//  ImageTextRecognizer.swift
//
//  Created by Ben Ku on 7/24/22.
//  Modified by Ben Ku on 8/28/2023
//


import Foundation
import Vision

struct RecognizedText: Identifiable {
    var text: String
    var bounds: CGRect
    var confidence: VNConfidence
    var id = UUID()
}

// var recognizedBlocks = await ImageTextRecognizer.parseItem(image)
extension [RecognizedText] {
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
                        debug("No candidate", level: .DEBUG)
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

        // order vertical
        let vertical = self.sorted { tA, tB in
            tA.bounds.origin.y < tB.bounds.origin.y
        }
        let delta = vertical.last!.bounds.origin.y / 10 // or should we just do 10 px?
        debug("Delta set to \(delta)", level: .ERROR)
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
extension Data {
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
extension Data {
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

extension URL {
    func download() async -> Data? {
        do {
            let (fileURL, response) = try await URLSession.shared.download(from: self)
            
            debug("URL Download response: \(response)", level: .DEBUG)
            
            // load data from local file URL
            guard let data = try? Data(contentsOf: fileURL) else {
                debug("Unable to load File URL data \(fileURL)", level: .ERROR)
                return nil
            }
            
            return data
        } catch {
            debug("Unable to download URL data \(self): \(error)", level: .ERROR)
            return nil
        }
    }
}

import SwiftUI
class RecognizedImageModel: ObservableObject {
    let urlString: String
    @Published var recognizedTexts = [RecognizedText]()
    
    init(urlString: String) {
        self.urlString = urlString
        Task {
            guard let imageURL = URL(string: urlString),
                  let data = await imageURL.download(),
                  let cgImage = data.asCGImage() else {
                debug("Unable to scan image. \(urlString)", level: .ERROR)
                return
            }
            recognizedTexts = await [RecognizedText].parse(cgImage: cgImage)
            debug("RAW: \(recognizedTexts.short)••••", level: .ERROR)
            let sorted = recognizedTexts.lineOrder()
            debug("SORTED: \(sorted.short)", level: .ERROR)
        }
    }
}
struct RecognizedImageView: View {
    @StateObject var model: RecognizedImageModel
    var body: some View {
        ZStack(alignment: .topLeading) {
            AsyncImage(url: URL(string: model.urlString))
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
        static let testURL = "https://fbfeudguide.com/wp-content/uploads/2023/08/Screenshot-2023-08-22-at-2.24.17-PM-768x458.png"
    static var previews: some View {
        let _ = { DebugLevel.currentLevel = .NOTICE }()
        VStack {
            Text("Test Image")
            RecognizedImageView(model: RecognizedImageModel(urlString: testURL))
                .scaledToFit()
        }
    }
}
