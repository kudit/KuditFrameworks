//
//  KuditConnect.swift
//
//  Created by Ben Ku on 10/4/23.
//

/**
 Example usage with additional menu items:
 
KuditConnectMenu {
    Section {
        Toggle("Left-handed mode", systemImage: manager.leftHandedMode ? "hand.point.left.fill" : "hand.point.left", isOn: $manager.leftHandedMode)
        if ExternalDisplayManager.shared.displayConnected {
            ExternalDisplayManager.shared.orientationPicker
                .pickerStyle(.menu)
        }
    }
}
 */

#if canImport(SwiftUI)
import SwiftUI
import StoreKit
// include below for info for appInformation
import Device // TODO: Do we want @_exported to expose Device automatically when importing KuditFrameworks?
import ParticleEffects

/// For presenting KuditConnect menu information.  Usually won't need, but if you want to customize the email message, modify this shared object.  Example to append data:
///  KuditConnect.shared.customizeMessageBody = { original in original + "\nMy New Data" }
// TODO: Have option to include data as file attachment (for Shout It, Score, Halloween Tracker)
// MARK: - KuditConnect model
@MainActor
public class KuditConnect: ObservableObject {
    public static var shared = KuditConnect()

    nonisolated public static let kuditAPIURL = "https://www.kudit.com/api"
    /// KuditConnect version number for API changes.
    nonisolated public static let version: Version = "3.0"
//    @available(*, deprecated, renamed: "version")
//    public static let kuditConnectVersion = KuditConnect.version

    
    // https://www.kudit.com/api/kudos.php?identifier=com.kudit.BROWSERTEST&version=1.2.3&kcVersion=3.2.1
    // Returns "SUCCESS"

    public init() {
        // TODO: Load FAQs
        self.faqs = [KuditFAQ(question: "Loading FAQs…", answer: "Please connect to the internet to make sure the most current FAQs can load from the server.", category: "Standby", minversion: nil, maxversion: nil, updated: Date().mysqlDateTime)]
        // TODO: NEXT: Trigger URL asynchronous loading to update FAQs value and store using SwiftData
        Task {
            await loadFromServer()
        }
    }
    
    func apiURLString(_ api: String, info: String = "") -> String {
        let identifier = Application.main.appIdentifier
        let version = Application.main.version
        var urlString = "\(Self.kuditAPIURL)/\(api).php?identifier=\(identifier.urlEncoded)&version=\(version)&kcVersion=\(Self.version)\(info)"
        // limit to 2000 characters to prevent URI overflow
        urlString = String(urlString.prefix(2000))
        debug("Kudit Connect: API URL: \(urlString)", level: .NOTICE)
        return urlString
    }
    
    enum KuditAPIError: Error {
        /// Throw when the URL is malformed
        case malformedURL(String)
                
        /// Throw when the network is unavailable
        case networkUnavailable
        
        /// Throw when the API server is unreachable
        case serverUnreachable
        
        /// Throw when there's a server error (with HTTP error code)
        case serverError(Int)
        
        /// Throw when the server data cannot be read as a String
        case dataError
    }
    
    /// This should be run in a background thread to get API data from the server.
    func loadDataFromAPI(_ api: String, info: String = "") async throws -> String {
        let apiURLString = apiURLString(api, info: info)

        // Convert string to URL (should never fail!)
        guard let url = URL(string:apiURLString) else {
            debug("Unable to convert string to URL: \(apiURLString)", level: .ERROR)
            throw KuditAPIError.malformedURL(apiURLString)
        }
        
        // Create URL request
        let urlRequest = URLRequest(url: url)

        // Fetch data from server
        let (data, response) = try await URLSession.shared.data(for: urlRequest)
        
        // Check response status code exists (should nearly always pass)
        guard let statusCode = (response as? HTTPURLResponse)?.statusCode else {
            debug("No status code in HTTP response.  Possibly offline?: \(String(describing: response))", level: .ERROR)
            throw KuditAPIError.networkUnavailable
        }
        
        // check status code
        guard statusCode == 200 else {
            throw KuditAPIError.serverError(statusCode)
        }
        
        // convert result data to string (since this will always be a String (either "SUCCESS" or a JSON string)
        guard let results = String(data: data, encoding: .utf8) else {
            debug("Unable to parse string out of data: \(String(describing: data))", level: .ERROR)
            throw KuditAPIError.dataError
        }
        return results
    }
    
    struct KCWrapper: Codable {
        var faqs: [KuditFAQ]
    }
    func loadFromServer() async {
        do {
            let string = try await loadDataFromAPI("faq")
            let wrapper = try KCWrapper(fromJSON: string)
            // filter FAQs based on what the actual app version is
            let filtered = wrapper.faqs.filter { $0.visible(in: Application.main.version) }
            main {
                self.faqs = filtered
                debug("Kudit Connect FAQs updated (found \(KuditConnect.shared.faqs.count))", level: .NOTICE)
            }
        } catch {
            debug("Kudit Connect: Unable to load FAQs from server: \(String(describing: error))", level: .ERROR)
        }
    }
    
    @Published public var faqs: [KuditFAQ] // TODO: have a way of loading on demand
    
    public var additionalLegalInfo = "" // use to add any copyright or license information
    
    // MARK: - Support Email
    @Published public var customizeMessageBody: (String) -> String = {$0} // TODO: Add ability to add files and photos?
    
    @Published var supportEmailData = ComposeMailData(subject: "Unspecified", recipients: [], message: "Overwrite", attachments: nil)
    
    public static var supportEmail = "support+\(Application.main.appIdentifier)@kudit.com"
    public static var supportEmailSubject = "App Feedback for \(Application.main.name)"
    
    /// Information about the application for support emails.
    public var appInformation: String {
        let infostring = """
            Application: \(Application.main.description)
            \(Device.current.description)
            Particle Effects Version: v\(ParticleEffects.version)
            Kudit Frameworks Version: v\(KuditFrameworks.version)
            Kudit Connect Version: v\(KuditConnect.version)
            """
        return infostring
    }
    
    public func generateSupportEmail() -> String {
        let body = """


Enter your feedback, questions, or comments above.
------------- App Information -------------
This section is to help us properly route your feedback and help troubleshoot any issues.
\(appInformation)
------------- App Information -------------

"""
        return customizeMessageBody(body)
    }
    
    func generateSupportEmailLink() -> URL {
        supportEmailData = ComposeMailData(
            subject: Self.supportEmailSubject,
            recipients: [Self.supportEmail],
            message: generateSupportEmail(),
            attachments: nil)
        return supportEmailData.mailtoLink
    }

    public func contactSupport(_ openURL: OpenURLAction) {
        openURL(generateSupportEmailLink())
    }
    
    /// Send Kudos to server for this app
    public func sendKudos() async -> String {
        let displayName = Application.main.name
        do {
            let string = try await loadDataFromAPI("kudos", info: "&info=\(customizeMessageBody(appInformation).urlEncoded)")
            if string != "SUCCESS" {
                throw CustomError("Unable to send Kudos :-( Server responded: \(string)", level: .ERROR)
            }
            return "Thank you so much for sending kudos to the \(displayName) team!  It means a lot to them.  Please rate the app and leave a review to really help the team out!"
        } catch {
            debug("Unable to send Kudos!  Error: \(String(describing: error))", level: .ERROR)
            return "There was a problem sending your kudos to the \(displayName) team!  Please try again later."
        }
    }
}

#endif
