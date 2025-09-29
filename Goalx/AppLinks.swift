import Foundation

enum AppLinks {

    static let appURL = URL(string: "https://apps.apple.com/app/id6753189302")!

    static let termsOfUse = URL(string: "https://docs.google.com/document/d/e/2PACX-1vQqPT9ipVFGML5SGpU0oObIhwWf4wnnTsmKvkfNObcUdzIXMyp1uoKITWSh5wxiiKaOJpuDbshLewEN/pub")!
    static let privacyPolicy = URL(string: "https://docs.google.com/document/d/e/2PACX-1vQqPT9ipVFGML5SGpU0oObIhwWf4wnnTsmKvkfNObcUdzIXMyp1uoKITWSh5wxiiKaOJpuDbshLewEN/pub")!

    static let rcURLKey = "goalx"

    static var shareMessage: String {
        """
        Stay organized and achieve your goals!  
        Add tasks, mark them as completed, and sort them into categories: Important, Urgent, Someday, or Goals.  
        Manage everything with simple swipes and drag & drop.  
        Download the app now:  
        \(appURL.absoluteString)
        """
    }

    static var shareItems: [Any] { [shareMessage, appURL] }
}
