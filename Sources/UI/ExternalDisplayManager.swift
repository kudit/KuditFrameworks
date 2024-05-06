#if canImport(UIKit) && canImport(SwiftUI)
import SwiftUI
/**
 Usage:
 
 In app init:
 
 ExternalDisplayManager.setup {
     MyView()
 }
 
 */

public enum ExternalDisplayOrientation: Int, CaseIterable, Identifiable, CustomStringConvertible {
    case upright, bottomAtLeft, bottomAtRight, upsideDown
    
    public var description: String {
        switch self {
        case .upright:
            return "Right Side Up"
        case .bottomAtLeft:
            return "Bottom at Left"
        case .bottomAtRight:
            return "Bottom at Right"
        case .upsideDown:
            return "Upside Down"
        }
    }
    public var rotated: Bool {
        switch self {
        case .upright:
            return false
        case .bottomAtLeft:
            return true
        case .bottomAtRight:
            return true
        case .upsideDown:
            return false
        }
    }
    static var renderedIcons: [CGImage?] = [nil,nil,nil,nil]
    /// This unfortunately has to be rendered or labels will strip the rotation.
    public var icon: some View {
        if let rendered = ExternalDisplayOrientation.renderedIcons[self.rawValue] {
            return AnyView(Image(rendered, scale: 1, label: Text("Hello")))
        }
        let icon = Image(systemName: "tv")
        // all these things below are because stupid swiftui tries to strip the rotation!
            .resizable()
            .aspectRatio(contentMode: .fit)
            .font(.system(size: 60))
            .frame(size: 60)
        // end hacks
            .rotationEffect(-rotation)
        
        if #available(iOS 16.0, watchOS 9.0, tvOS 20.0, macCatalyst 16.0, *) {
            // begin renderer (must be run on main thread so switch in case we're not)
            DispatchQueue.main.async {
                // finish up on main thread
                let renderer = ImageRenderer(content: icon)
                if let image = renderer.cgImage {
                    ExternalDisplayOrientation.renderedIcons[self.rawValue] = image
                }
            }
        } // if not available, just accept that the icon will be wrong.
        // end renderer.  Should really just return icon with rotation effect and be done with!
        return AnyView(icon)
    }
    public var label: some View {
        Label{
            Text(description)
        } icon: {
            icon
        }
    }
    public var id: Self { self }
    public var rotation: Angle {
        switch self {
        case .upright:
            return .degrees(0)
        case .bottomAtLeft:
            return .degrees(-90)
        case .bottomAtRight:
            return .degrees(90)
        case .upsideDown:
            return .degrees(180)
        }
    }
}

#Preview("Icons") {
    VStack {
        HStack {
            ForEach(ExternalDisplayOrientation.allCases) { orientation in
                orientation.icon
                    .frame(size: 60)
                    .border(.blue, width: 1)
            }
        }
        Label {
            Text("Left")
        } icon: {
            ExternalDisplayOrientation.bottomAtLeft.icon
        }
        ForEach(ExternalDisplayOrientation.allCases) { orientation in
            orientation.label
        }
        //        KuditLogo()
    }
}

struct ExternalDisplayOrientationPicker: View {
    @Binding var orientation: ExternalDisplayOrientation
    var body: some View {
        Picker("External Display Rotation", selection: $orientation) {
            // 1
            ForEach(ExternalDisplayOrientation.allCases) { option in
                // 2
                option.label
            }
        }
    }
}

#if !os(watchOS) && !os(tvOS)
#Preview("Picker") {
    VStack {
        ExternalDisplayOrientationPicker(orientation: .constant(.bottomAtLeft))
        Divider()
        Menu("Test Menu") {
            ExternalDisplayOrientationPicker(orientation: .constant(.bottomAtRight))
            //                .pickerStyle(.palette)
        }
        Divider()
        Menu("Manual") {
            ForEach(ExternalDisplayOrientation.allCases) { option in
                option.label
            }
        }
    }
}

// https://prathamesh.xyz/blog/2020/10/7/add-multi-screen-support-to-swiftui-apps
struct ExternalViewWrapper<Content: View>: View {
    @ObservedObject var manager: ExternalDisplayManager
    
    var content: () -> Content
    
    init(manager: ExternalDisplayManager, @ViewBuilder content: @escaping () -> Content) {
        self.manager = manager
        self.content = content
    }
    
    var body: some View {
        GeometryReader { geometry in
            content()
                .if(manager.orientation.rotated) { content in
                    content
                        .frame(width: geometry.size.height, height: geometry.size.width, alignment: .center)
                }
                .rotationEffect(manager.orientation.rotation, anchor: .center)
                .position(x: geometry.size.width / 2, y: geometry.size.height / 2) // make sure centered in view
        }
        .ignoresSafeArea()
        // make sure "safe" area isn't avoided since external view likely doesn't need a safe area
    }
}

public class ExternalDisplayManager: ObservableObject {
    public static var shared = ExternalDisplayManager()
    
    @Published public var orientation: ExternalDisplayOrientation = .upright
    @Published private var externalWindow: UIWindow?
    
    public var displayConnected: Bool {
        externalWindow != nil
    }
    
    public static func setup(@ViewBuilder _ externalViewBuilder: @escaping () -> some View) {
        NotificationCenter.default.addObserver(forName: UIScene.willConnectNotification, object: nil, queue: nil) { (connectNotice) in
            guard let connectedWindowScene = connectNotice.object as? UIWindowScene else {
                debug("ConnectedWindowScene: Unable to find scene object", level: .ERROR)
                return
            }
            if #available(iOS 16.0, macCatalyst 16.0, *) {
                guard connectedWindowScene.session.role == .windowExternalDisplayNonInteractive else {
                    return
                }
            } else {
                // Fallback on earlier versions
                guard connectedWindowScene.session.role == .windowExternalDisplay else {
                    return
                }
            }
            
            let newWindow = UIWindow()
            newWindow.windowScene = connectedWindowScene
            
            newWindow.rootViewController = UIHostingController(rootView: ExternalViewWrapper(manager: shared, content: externalViewBuilder))
            
            newWindow.isHidden = false
            // Store window object in this delegate so we don't lose the reference and can dealloc.
            shared.externalWindow = newWindow
            debug("Assigned window content to non-interactive external display", level: .NOTICE)
        }
        NotificationCenter.default.addObserver(forName: UIScene.didDisconnectNotification, object: nil, queue: nil) { (disconnectNotice) in
            let externalScene = disconnectNotice.object as! UIScene
            
            if externalScene == shared.externalWindow?.windowScene {
                shared.externalWindow?.isHidden = true
                shared.externalWindow = nil
                debug("SceneDelegate: Display Disconnected cleanly")
            } else {
                debug("SceneDelegate: External display disconnected not clean?")
            }
        }
        //        NotificationCenter.default.addObserver(forName: UIScreen.modeDidChangeNotification, object: nil, queue: nil) { (modeNotice) in
        //            if let externalScreen = modeNotice.object as? UIScreen, externalScreen == self.externalWindow?.screen
        //            {
        //                debug("DM.NC.modeDidChangeNotification External screen changed mode")
        //                //self.view.setNeedsLayout()
        //                //self.view.layoutSubviews()
        //            }
        //        }
    }
    
    @ViewBuilder public var orientationPicker : some View {
        let binding = Binding(get: {
            self.orientation
        }, set: {
            self.orientation = $0
        })
        ExternalDisplayOrientationPicker(orientation: binding)
    }
}


#Preview("Menu") {
    Menu("Pop menu") {
        Text("Foo start")
        ExternalDisplayManager.shared.orientationPicker
            .pickerStyle(.menu)
        Text("Foo end")
    }
}
#endif
#endif
