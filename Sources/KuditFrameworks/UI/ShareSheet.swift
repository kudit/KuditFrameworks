//
//  ShareSheet.swift
//  Tracker
//
//  Created by Ben Ku on 10/21/21.
//
// https://developer.apple.com/forums/thread/123951
import SwiftUI

public struct ShareSheet: UIViewControllerRepresentable {
    public typealias ShareSheetCallback = (_ activityType: UIActivity.ActivityType?, _ completed: Bool, _ returnedItems: [Any]?, _ error: Error?) -> Void
    
    public let activityItems: [Any]
    public let applicationActivities: [UIActivity]? = nil
    public let excludedActivityTypes: [UIActivity.ActivityType]? = nil
    public let callback: ShareSheetCallback? = nil
    
    public func makeUIViewController(context: Context) -> UIActivityViewController {
        let controller = UIActivityViewController(
            activityItems: activityItems,
            applicationActivities: applicationActivities)
        controller.excludedActivityTypes = excludedActivityTypes
        controller.completionWithItemsHandler = callback
        return controller
    }
    
    public func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {
        // nothing to do here
    }
}



//MARK: - Test/Preview

/*
 In your other view, you want this to appear modally, so you use the
 .sheet()
 method to do so, along with an
 isPresented
 state variable, like so:
 
 */

struct ShareSheetPreviewView: View {
    @State private var showShareSheet = false
    
    var body: some View {
        VStack(spacing: 20) {
            Text("Hello World")
            Button(action: {
                self.showShareSheet = true
            }) {
                Text("Share Me").bold()
            }
        }
        .sheet(isPresented: $showShareSheet) {
            ShareSheet(activityItems: ["Hello World"])
        }
    }
}

struct ShareSheet_Previews: PreviewProvider {
    static var previews: some View {
        ShareSheetPreviewView()
    }
}
