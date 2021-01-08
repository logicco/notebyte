import Foundation
import RealmSwift

class Note: Object {
    @objc dynamic var title: String = ""
    @objc dynamic var content: String = ""
    @objc dynamic var createdDate: Date = Date()
    @objc dynamic var updatedDate: Date = Date()
    @objc dynamic var isArchived: Bool = false
    
    var contentDescription: String {
        get {
            return content.trimmingCharacters(in: .whitespacesAndNewlines)
        }
    }
    
    func humanFriendlyCreatedDate() -> String{
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .medium
        dateFormatter.timeStyle = .short
        return dateFormatter.string(from: createdDate)
    }
    
    func humanFriendlyUpdatedDate() -> String{
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .medium
        dateFormatter.timeStyle = .short
        return dateFormatter.string(from: updatedDate)
    }
}
