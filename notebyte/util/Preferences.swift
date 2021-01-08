import Foundation
import UIKit

struct Preferences {
    
    static func getSort() -> Database.Sort {
        let userDefaults = UserDefaults.standard
        if let sortSettingsStr = userDefaults.string(forKey: "sort"){
            switch sortSettingsStr {
                    case Database.Sort.title.rawValue:
                        return Database.Sort.title
                    case Database.Sort.lastModifield.rawValue:
                        return Database.Sort.lastModifield
                    case Database.Sort.added.rawValue:
                        return Database.Sort.added
                    default:
                        return Database.Sort.lastModifield
                }
        }
        return Database.Sort.lastModifield
    }
}
