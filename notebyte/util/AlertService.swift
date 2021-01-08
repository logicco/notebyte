import Foundation
import UIKit

struct AlertService {
    
    static func alert(message: String) -> UIAlertController{
        let alert = UIAlertController(title: nil, message: message, preferredStyle: .alert)
        let action = UIAlertAction(title: "OK", style: .default, handler: nil)
        alert.addAction(action)
        return alert
    }
}
