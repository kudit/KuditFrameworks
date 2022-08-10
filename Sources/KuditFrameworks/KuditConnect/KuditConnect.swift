//
//  KuditConnect.swift
//  KuditFrameworks
//
//  Created by Ben Ku on 4/27/16.
//  Copyright © 2016 Kudit. All rights reserved.
//

// TODO: figure out how to actually build framework and include in projects and include Framework version in KuditConnect info.
//let kAPIURL = "http://photovoltaic.local/kudit/api"
let kAPIURL = "https://www.kudit.com/api"

// use this to flag data format versions
/*
Version 1:
FAQ is [category][question] = answer
Kudos includes only identifier
Version 2:
FAQ is [category][question] = @{@"answer":@"answer",@"minversion":@"1.0.1",@"maxversion":@"3.0.1"} (min/max version can be nil/null/missing
Kudos passes system information
*/
let kKCVersion = 2

import Foundation
import CoreData
#if canImport(MessageUI) && canImport(UIKit)
import UIKit
import MessageUI // not supported in watchOS
extension KuditConnect: MFMailComposeViewControllerDelegate {}
    
// for Kudos particles
// MARK: - particle effects
// http://www.raywenderlich.com/6063/uikit-particle-systems-in-ios-5-tutorial
public class KuditParticleView: UIView {
    var particleEmitter:CAEmitterLayer!
    //2 configure the UIView to have an emitter layer
    override public class var layerClass : AnyClass {
        return CAEmitterLayer.self
    }
    public override init(frame: CGRect) {
        super.init(frame: frame)
        particleEmitter = (self.layer as! CAEmitterLayer)
        particleEmitter.renderMode = .oldestLast // Replaced line below to fix impossible coersion.  Hopefully correct!
        //particleEmitter.renderMode = kCAEmitterLayerVolume as CAEmitterLayerRenderMode
        let emitter = CAEmitterCell()
        emitter.birthRate = 30
        emitter.lifetime = 5.0
        if let image = KuImage.named("kuditConnectKudosSprite") {
            print("Image loaded: \(image)")
            emitter.contents = image.cgImage
        } else {
            print("Could not load any image to use as the emitter contents!")
        }
        emitter.color = UIColor.yellow.cgColor
        emitter.velocity = 230
        emitter.velocityRange = 150
        //emitter.emissionLatitude = CGFloat(M_PI)
        //emitter.emissionLongitude = CGFloat(M_PI_2)
        emitter.emissionRange = .pi
        emitter.scale = 0.2
        emitter.scaleSpeed = 0.7
        //emitter.spin = 2.2
        emitter.alphaSpeed = -0.2
        emitter.yAcceleration = 250
        emitter.name = "particle"
        particleEmitter.emitterCells = [emitter]
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    public func stop() {
        particleEmitter.setValue(0.0, forKeyPath: "emitterCells.particle.birthRate")
        // TODO: have way of clearing out the view (removing it from superview) when everything's finished dying (just delay based on lifetime and removefromsuperview?)
    }
}

extension UIViewController {
    var actualPresentingViewController: UIViewController? {
        // get the presenting controller by navigating down the stack from the window
        let window = self.view.window
        
        var presentingController = window?.rootViewController
        while let pc = presentingController?.presentedViewController {
            presentingController = pc
        }
        
        return presentingController
    }
}
#endif


public class KuditConnect: NSObject {
    private static let _shared = KuditConnect()
    public static var supportEmail = "support@kudit.com"
    
#if canImport(UIKit)
    public static var keyWindow: UIWindow?
    static func link(window: UIWindow) {
        keyWindow = window 
    }
#endif
    
    /// necessary for review links
    private static let _appleID = Bundle.main.infoDictionary?["AppleID"]
    /// necessary for share links, however with the Apple ID, we can construct the share link if not provided or overridden (and include our affiliate token).
    public static var applicationShareURL = Bundle.main.infoDictionary?["ApplicationURL"] ?? "https://itunes.apple.com/us/app/\(Application.main.appIdentifier)/id\(String(describing: _appleID))?mt=8&amp;at=11l5GV&amp;ct=AppShare"
    
    var _faqData = [String: String]()
    var _items = [MenuItem]()
    
    /// Place `KuditConnect.setup()` in `application(_:didFinishLaunchingWithOptions:)` to enable KuditConnect features and version tracking.
    // TODO: add some sort of tracking/validation to make sure this is configured properly before using?
    public static func setup() {
        // make sure configured properly before even tracking so first run isn't violated if there's an issue
        if _appleID == nil {
            print("Please add a property in your Info.plist for the key \"AppleID\" so we can properly direct to review.")
            exit(0)
        }

        Application.track() // Loading from Kudit Connect is the preferred way
        // Make sure the shared instance is up and initialized
        _shared.loadFAQs()
    }
    
    public static var menuGroup: MenuGroup {
        let group = MenuGroup(title: "Connect", userInfo: [MIDetailKey: Application.main.version], items: [
            MenuLabel(title: "Kudit Connect"),
// Remove for now            faqGroup
            ])
#if canImport(UIKit)
//        let shareButton = MenuButton(title: "Share App with Friends", userInfo: [MIIconKey: "kuditConnectShare", MITextAlignmentKey: NSTextAlignment.natural]) {
//            _ in
//            // TODO: show share sheet.  Rip from existing code.
//            // TODO: add in checks above to make sure the necessary values have been set with instructions in the console for setting these values.
//            return .dismissThen {
//                share()
//            }
//        }

        group.items += [
            MenuButton(title: "Contact Support", userInfo: [MIIconKey: "kuditConnectContact", MITextAlignmentKey: NSTextAlignment.natural]) {
                _ in
                return .dismissThen {
                    // Show contact form after dismissing UI
                    KuditConnect.email()
                }
            },
            MenuButton(title: "Leave a Review", userInfo: [MIIconKey: "kuditConnectReview", MITextAlignmentKey: NSTextAlignment.natural]) {
                _ in
                // TODO: show alert prompting for contact or rating (rip from existing code)
                return .dismissThen {
                    encourageGoodReviews()
                }
            },
//            shareButton
        ]
#endif
        group.items += [
            MenuButton(title: "Send us Kudos", userInfo: [MIIconKey: "kuditConnectKudos", MITextAlignmentKey: MITextAlignment.natural]) {
                _ in
                return .dismissThen {
                    sendKudos()
                }
            },
            ]
        return group
    }


#if canImport(UIKit)
    public static var screenshots = [UIImage]()
    
    public static func present(_ controller: UIViewController) {
        controller.actualPresentingViewController?.present(controller, animated: true)
    }
    
    /*
    // determine the UI to use to present the menu group automatically for the different UI styles.  Make this simple enough that this can easily be replicated for custom UI presenters (pass in renderer?)
    public static func present(withItems additionalItems: [MenuItem] = [], from: AnyObject? = nil) {
        // take and store screenshots
        screenshots = UIApplication.shared.windows.map { $0.snapshot() }
        
        // get the KuditConnect group
        let group = KuditConnect.menuGroup
        // TODO: test to see if subsequent calls re-inserts or is this a copy of the group?  Should we create a new group with the items from both?  MenuGroup.combinedWith(items) to return a new group?
        // Add in the specified items at the beginning
        group.items.insert(contentsOf: additionalItems, at: 0)
    
        let navigationController = group.navigationController

        if from is UIBarButtonItem {
            navigationController.modalPresentationStyle = .popover
        }
    
        // preserve storyboard tint color
        if let navController = presentingController as? UINavigationController {
            navigationController.navigationBar.tintColor = navController.navigationBar.tintColor
            navigationController.view.tintColor = navController.navigationBar.tintColor
        }

        present(navigationController)
        
        if let bbi = from as? UIBarButtonItem, let ppc = navigationController.popoverPresentationController {
            ppc.barButtonItem = bbi
        }
    }
     */
    
    public static func alert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Okay", style: .cancel))
        present(alert)
    }

    // MARK: - Email/Contact
    public static func email() {
        guard MFMailComposeViewController.canSendMail() else {
            alert(title: "Can't Send Mail", message: "You have no mail accounts set up or are not able to send mail with this device.  Please configure your accounts to make sure we're able to respond to your concerns.")
            return
        }
        
        let mailComposerVC = MFMailComposeViewController()
        mailComposerVC.setToRecipients([appSupportEmail])
        
        // get images to attach
    print("TODO: get screenshot data and make sure this is only added if not nil!")
        let images = supportAdditionalImages + screenshots
        mailComposerVC.setSubject("App Feedback for \(Application.main.name)")
        
        // Fill out the email body text
        mailComposerVC.setMessageBody(supportEmailContent, isHTML: true)

        // add image data
        for image in images {
            if let png = image.asPNG() {
                mailComposerVC.addAttachmentData(png, mimeType:"image/png", fileName: image.fileName)
            } else {
                print("Could not attach image \(image)")
            }
        }
        
        // set the delegate
        mailComposerVC.mailComposeDelegate = _shared

        // make sheet display style on iPad
        mailComposerVC.modalPresentationStyle = .pageSheet // doesn't really do anything on iPhone

        present(mailComposerVC)
    }
    @objc(mailComposeController:didFinishWithResult:error:) public func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        // Check the result or perform other tasks.
        // TODO: If cancelled, perhaps prompt to look at the FAQ or remind that this is availabe and just simply write the problem or comment.  Button to email and button to FAQ and button to dismiss.
    
        // Dismiss the mail compose view controller.
        controller.actualPresentingViewController?.dismiss(animated: true, completion: nil)
    }
    #endif

    /// return supportEmail with application name inserted before at sign.
    private static var appSupportEmail: String {
        return supportEmail.replacingOccurrences(of: "@", with: "+\(Application.main.appIdentifier)@")
    }
    /// customization point for the beginning of the email.
    public static var supportEmailQuestion = "Enter feedback, questions, or comments: "
    /// customization point for adding additional info.  Be sure to end any content with \n or leave it blank.
    public static var supportEmailAdditional = ""
    /// customization point for attaching additional images to the email.
    public static var supportAdditionalImages = [KuImage]()
    
    public static var supportInfo: String {
        return "\(Application.main)\n" + supportEmailAdditional + Hardware.currentDevice.description
    }
    
    /// returns the email content in HTML form.
    private static var supportEmailContent: String { // TODO: allow including attachments & additional information or other customizations
        let question = supportEmailQuestion
        
        // TODO: add in KuditCompensation information like number of credits and purchases and account ID.
        let info = supportInfo.replacingOccurrences(of: "\n", with: "<br />\n")
        return "\(question)\("<br />".repeated(42))Please provide your feedback above.<hr />This section is to help us properly route your feedback and help troubleshoot any issues.<br /><br /><blockquote>\(info)</blockquote>"
    }
    
    // MARK: - Review Management
    public static let reviewURL = "itms-apps://ax.itunes.apple.com/WebObjects/MZStore.woa/wa/viewContentsUserReviews?type=Purple+Software&id=\(String(describing: _appleID))"
        
#if canImport(UIKit)
    public static func launchReview() {
        UIApplication.shared.open(URL(string: reviewURL)!) {
            success in
            // completion
            if !success {
                // have a fallback notification for simulator/tests
                alert(title: "Uh oh!", message: "Could not launch review.  You don't seem to have access to the App Store app.")
            }
        }
    }
    public static func encourageGoodReviews() {
        let alert = UIAlertController(title: "Review", message: "If you're having problems, please contact us for support.  We cannot respond to reviews so if there is any reason you would not give us 5 stars, please contact us so we can address your issues!", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        alert.addAction(UIAlertAction(title: "Contact", style: .default) {
            _ in
            // TODO: add additional info that this was triggered by review button
            email()
        })
        alert.addAction(UIAlertAction(title: "5 star review!", style: .default) {
            _ in
            launchReview()
        })
        present(alert)
    }
#endif
    
    // MARK: - App Sharing
    public static func share() {
        print(applicationShareURL)
    }
    
    // MARK: - Kudos
    public static func sendKudos() {
        // do the actual Kudos sending
        let bundleIdentifier = (Bundle.main.bundleIdentifier ?? "com.kudit.unknown").urlEncoded
        let version = Application.main.version.urlEncoded
        let urlString = "\(kAPIURL)/kudos.php?identifier=\(bundleIdentifier)&version=\(version)&kcVersion=\(kKCVersion)"
        print("Kudit Connect: Kudos URL: \(urlString)")

        let displayName = Application.main.name
        
        // TODO: alert so
        
        // send the kudos in the background so we don't hold up the interface any
        background {
            // TODO: make sure not crash and save for next connection/launch if no internet
            do {
                let results = try Data(contentsOf: URL(string: urlString)!, options: [.uncached])
                guard let resultsString = String(data: results, encoding: String.Encoding.utf8) else {
                    return
                }
                // else, we've succeeded
                print("Kudos results: \(resultsString)")
            } catch {
                // just fail silently since this really isn't that important
                // TODO: log for future crash reports or contacts.
                print("Error calling the Kudos URL: \(error)")
                return
            }
        }
        
        // report to the user that the Kudos were sent
        let message = "The \(displayName) team has been sent your kudos!  It means a lot to them!  Please rate the app and leave a 5 star review to really help the team out!"
        let title = "Thank You!"

        // TODO: add in a response mechanism where alerts can be shown or returned from a function so that the menu renderer appropriately displays the alert or text
#if canImport(UIKit)
        // TODO: WWDC: figure out how to make this above the darkening layer but below the alert box
        // show the particle effect for "fun"
        //TODO: works when invoked from presented view controller but not from main VC
        guard let window = KuditConnect.keyWindow else {
            debug("Could not present window.  Thank you for your kudos!")
            return
        }
        // TODO: do we need to check orientation and flip here anymore?
        let width = window.frame.size.width
        //            let height = window.frame.size.height
        let kpv = KuditParticleView(frame: CGRect(x: width/2, y: 0, width: 0, height: 0))
        window.addSubview(kpv)
        
        let dismissKPV = {
            kpv.stop()
            //kpv.removeFromSuperview() // TODO: delay until all smileys are gone
        }
        
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "No Thanks", style: .cancel) {
            _ in
            dismissKPV()
        })
        alert.addAction(UIAlertAction(title: "Review", style: .default) {
            _ in
            dismissKPV()
            launchReview()
        })
        present(alert)
#endif
    }

    // MARK: - FAQs
    
    private var faqGroup: MenuGroup {
        let items = [
            MenuLabel(title: "News & Alerts"),
            MenuButton(title: "Item Title", userInfo: ["TODO": "Push a web view controller so have web page item"]),
            ]
        return MenuGroup(title: "Help & FAQs",
                  userInfo: [MIIconKey: "kcHelpIcon", "TODO": "GROUP STYLE TO BE PLAIN NOT GROUPED"],
                  items: items)
    }
    
    private func loadFAQs() {
        // make sure required dependancies are present?
        /*
        // TODO: load FAQ from Server (asynchronously if necessary otherwise pull from disk to be ready when needed).
        _faqData = [KuditCoreDataManager managerWithModelName:@"KuditConnectFAQs" ubiquitous:NO reference:YES];

        _faqData = [KuditCoreDataManager managerWithModelName:@"KuditConnectFAQs" ubiquitous:NO reference:YES];
        
        NSString *bundleIdentifier = NSBundle.mainBundle.infoDictionary[@"CFBundleIdentifier"];
        _kuditData = [[KuditData alloc] initWithDataAtURLString:[NSString stringWithFormat:@"%@/faq.php?identifier=%@&kcVersion=%d", kAPIURL, bundleIdentifier, kKCVersion] initialize:^(void (^finished)(void)) {
        // initialize/replace database each time (we're ignoring the date limiting on the server)
        // go ahead and delete all existing entities (will this be a problem if trying to look at FAQs and loaded context already?  Should happen pretty early and quick, right?
        [_faqData deleteAndResetWithCallback:^() {
        #warning use generated notification to refresh table view if up
        finished();
        }];
        } addData:^(NSDictionary *data) {
        NSArray *faqs = data[@"faqs"];
        // already on background thread
        NSManagedObjectContext *backgroundContext = [_faqData newBackgroundContext];
        
        for (NSDictionary *faqDictionary in faqs) {
        KuditFAQ *faq = [NSEntityDescription insertNewObjectForEntityForName:@"FAQ" inManagedObjectContext:backgroundContext];
        [faq loadFromDictionary:faqDictionary];
        }
        
        [backgroundContext save];
        [backgroundContext reset];
        
        dispatch_async( dispatch_get_main_queue(), ^{
        @synchronized(self) { // make sure no threading issues and this doesn't happen twice/concurrently
        if (!_faqsLoaded) { // ensures only run once
        // make sure run on main thread
        [self _checkAlerts];
        _faqsLoaded = YES;
        }
        }
        });
        }];
        
        _kuditConnectItems
        = @[[KuditConnectItem itemOfType:KuditConnectItemTypeAction
        withLabel:@"Help & FAQs"
        options:@{kKuditConnectItemOptionKeyWithoutDismissal:@YES,
        kKuditConnectItemOptionKeyIconName:@"kuditConnectFAQs"}
        items:nil
        callback:^(KuditConnectItem *item) {
        [self _showFAQs];
        }],
        [KuditConnectItem itemOfType:KuditConnectItemTypeAction // _contact does dismissal automatically
        withLabel:@"Contact Support"
        options:@{kKuditConnectItemOptionKeyWithoutDismissal:@YES,
        kKuditConnectItemOptionKeyIconName:@"kuditConnectContact"}
        items:nil
        callback:^(KuditConnectItem *item) {
        [self _contact];
        }],
        [KuditConnectItem itemOfType:KuditConnectItemTypeAction // handles dismissal
        withLabel:@"Leave a Review"
        options:@{kKuditConnectItemOptionKeyWithoutDismissal:@YES,
        kKuditConnectItemOptionKeyIconName:@"kuditConnectReview"}
        items:nil
        callback:^(KuditConnectItem *item) {
        [self _promptToReview];
        }],
        [KuditConnectItem itemOfType:KuditConnectItemTypeAction // handles dismissal
        withLabel:@"Share App With Friends"
        options:@{kKuditConnectItemOptionKeyWithoutDismissal:@YES,
        kKuditConnectItemOptionKeyIconName:@"kuditConnectShare"}
        items:nil
        callback:^(KuditConnectItem *item) {
        [self _share];
        }],
        [KuditConnectItem itemOfType:KuditConnectItemTypeAction // handles dismissal
        withLabel:@"Send Us Kudos"
        options:@{kKuditConnectItemOptionKeyWithoutDismissal:@YES,
        kKuditConnectItemOptionKeyIconName:@"kuditConnectKudos"}
        items:nil
        callback:^(KuditConnectItem *item) {
        [self _kudos];
        }]];
        
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
            self.modalPresentationStyle = UIModalPresentationCurrentContext;
        }
    */
    
    }
}
//    public static let staticValue = "STATIC VALUE"
//
//    public static let sharedInstance = KuditConnect()
//    private init() { //This prevents others from using the default '()' initializer for this class.
//        print("KuditConnect private initialization")
//    }
//
//    class func initialize() {
//        print("KuditConnect Inited")
//    }
//}

// kudit connect implementation could be different in a virtual menu or as a collection view or as a table view or in an action sheet.  Implementation will take item (string, tuple with label and bool (switch), etc) and will be responsible for rendering and determining what triggers the action (toggling the switch, changing the text).  Need to be able to provide a custom implementation.  Item could implement a setup function that takes the cell or whatever and modifies it.  So strings would just set the label.  Renderers would need to know how to render different types of items.  Have specific classes that need to be implemented.  configureButton, configureSwitch, configureText, configureSegmentedControl, configure - whatever types of controls we support.

// model has types but implementation determines how to display.  custom layout option to allow extending with new types?  Want to be able to customize the look (create new renderer that supports all the different types)

//protocol Image {
//    
//}
//
//protocol Button {
//    
//}

//enum MenuItem {
//    case Custom([String: AnyObject]) // EX: Mana slider, custom controls...most likely will be linked to a specific renderer and won't be interchangeable, but if we stick to the default renderers, then we get behavior for free.
//    case TextButton(String)
//    case ImageButton(Image)
//    case TextImageButton(String, Image)
//    case Switch(String, Bool)
//    case Label(String)
//    case SegmentedControl([Button])
//    case TextField(String, String) // label, default text
//    case PasswordField(String, String)
//    // option for left checkmark or right image, disclosure button w/ action
//    case SectionHeader(String)
//    case Slider(Image, Image, Double) // min image, max image, double value
//    case Submenu([MenuItem],Int) // needs some way of indicating the currently selected item, option for reorderable, optional image
//}

// menu item needs optional text, optional image
// action should indicate if we want to dismiss or not, should include the entire menu so that we could push new view onto navigation stack?
// Goal is to de-couple presentation from behavior
// perhaps think of like a table view data source (that could also be a collection view data source) that has actions and built linearly instead of having to create a data source.

// Think about how the menu would be displayed as a grid (for the virtual world case where it shows at most 4 items + < ^ > controls or Apple Watch menu for example)

// all items can have an additional info dictionary that can be used to set custom configurations for the renderer (like colors)

// KMenuItem<Type>
    // KMenuItemButton


// The items should be a protocol and add the protocol to simple things like strings
// add(item: AnyObject) { item in // Stuff to do when triggered }
// typealias KCAction = (KCItem,
