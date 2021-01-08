import UIKit
import RealmSwift

class NoteViewController: UIViewController {
    
    @IBOutlet weak var textView: UITextView!
    
    var note: Note?

    override func viewDidLoad() {
        super.viewDidLoad()

        textView.delegate = self

        if let noteObj = note {
            navigationItem.title = noteObj.title
            textView.text = noteObj.content
        }
        
        let notificationCenter = NotificationCenter.default
        notificationCenter.addObserver(self, selector: #selector(appMovedToBackground), name: UIApplication.willResignActiveNotification, object: nil)
        
    }
    
    
    
    @objc func appMovedToBackground() {
        saveNote()
    }
        
    private func saveNote(){
        if let noteObj = note, let text = textView.text {
            let updatedNote = Note()
            updatedNote.title = noteObj.title
            updatedNote.content = text
            Database.updateNote(noteObj, toUpdateNote: updatedNote)
        }
    }
}

extension NoteViewController: UITextViewDelegate {
    
    func textViewDidEndEditing(_ textViewInEdit: UITextView) {
        if let noteObj = note, let text = textViewInEdit.text {
            let updatedNote = Note()
            updatedNote.title = noteObj.title
            updatedNote.content = text
            Database.updateNote(noteObj, toUpdateNote: updatedNote)
        }
    }
}
