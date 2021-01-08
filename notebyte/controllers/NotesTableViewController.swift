import UIKit
import RealmSwift
import Foundation
import SwipeCellKit

class NotesTableViewCell: SwipeTableViewCell {
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var contentLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    
}

class NotesTableViewController: UITableViewController {
    
    @IBOutlet weak var searchBar: UISearchBar!
    
    private var notes: Results<Note>?
    private var sort: Database.Sort = Database.Sort.lastModifield

    override func viewDidLoad() {
        super.viewDidLoad()
        
        if Database.getEncryptionConfig() == nil {
            Database.initialize()
        }
        
        searchBar.delegate = self
        
        NotificationCenter.default.addObserver(self, selector: #selector(settingChanged(notification:)), name: UserDefaults.didChangeNotification, object: nil)
        
        sort = Preferences.getSort()
        notes = Database.getNotes(sort)
    }
    
    @objc func settingChanged(notification: NSNotification) {
        sort = Preferences.getSort()
        notes = Database.getNotes(sort)
        tableView.reloadData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        sort = Preferences.getSort()
        notes = Database.getNotes(sort)
        tableView.reloadData()
    }
    @IBAction func addButtonPressed(_ sender: UIBarButtonItem) {
        var textField = UITextField()
        let alert = UIAlertController(title: "Add Note", message: "", preferredStyle: .alert)
        let action = UIAlertAction(title: "Add Note", style: .default) { (action) in
            if let text = textField.text {
                if text != "" {
                    let note = Note()
                    note.title = text
                    Database.addNote(note)
                    guard let noteVc = self.storyboard?.instantiateViewController(withIdentifier: "noteVc") as? NoteViewController else {
                        self.tableView.reloadData()
                        return
                    }
                    noteVc.note = note
                    self.navigationController?.pushViewController(noteVc, animated: true)
                }
            }
        }
        alert.addTextField { (alertTextField) in
            alertTextField.placeholder = "Enter title"
            textField = alertTextField
        }
        alert.addAction(action)
        alert.view.layoutIfNeeded()
        present(alert, animated: true, completion: nil)
    }
    

    // MARK: - Table view data source

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if notes?.count == 0 {
            tableView.setEmptyMessage("No notes yet")
        }else{
            tableView.restore()
        }
        return notes?.count ?? 0
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: K.notesCellIdentifier, for: indexPath) as! NotesTableViewCell
        if let notesList = notes{
            if !notesList.isEmpty {
                let note = notesList[indexPath.row]
                cell.titleLabel.text = note.title.isEmpty ? "Empty" : note.title
                cell.contentLabel.text = note.content.isEmpty ? "Empty" : note.contentDescription
                cell.dateLabel.text = "Last updated: \(note.humanFriendlyUpdatedDate())"
            }
            
        }
        cell.delegate = self
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "goToNote", sender: self)
    }

    // MARK: - Navigation

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let noteViewController = segue.destination as! NoteViewController
        if let indexPath = tableView.indexPathForSelectedRow {
            if let notesList = notes{
                noteViewController.note = notesList[indexPath.row]
            }
        }
    }

}

//MARK: - UISearchBarDelegate

extension NotesTableViewController: UISearchBarDelegate {
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        if let text = searchBar.text {
            if !text.isEmpty {
                notes = Database.searchNotes(byTitle: text)
                tableView.reloadData()
            }
            DispatchQueue.main.async {
                searchBar.resignFirstResponder()
            }
        }
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if let text = searchBar.text {
            if text.isEmpty {
                notes = Database.getNotes(sort)
                tableView.reloadData()
                DispatchQueue.main.async {
                    searchBar.resignFirstResponder()
                }
            }
        }
    }
}

//MARK: - SwipeTableViewCellDelegate

extension NotesTableViewController: SwipeTableViewCellDelegate {
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath, for orientation: SwipeActionsOrientation) -> [SwipeAction]? {
        guard orientation == .right else {
            return nil
        }
        
        let editAction = SwipeAction(style: .default, title: "Edit") { (action, indexPath) in
            var textField = UITextField()
            let alert = UIAlertController(title: "Edit Title", message: "", preferredStyle: .alert)
            let action = UIAlertAction(title: "Edit Title", style: .default) { (action) in
                if let noteObj = self.notes?[indexPath.row], let text = textField.text {
                        if textField.text != "" {
                            let updatedNote = Note()
                            updatedNote.title = text
                            updatedNote.content = noteObj.content
                            Database.updateNote(noteObj, toUpdateNote: updatedNote)
                            self.tableView.reloadData()
                        }
                    }
            }
            alert.addTextField { (alertTextField) in
                alertTextField.placeholder = "Enter title"
                textField = alertTextField
                if let noteObj: Note = self.notes?[indexPath.row]{
                    textField.text = noteObj.title
                }
                
            }
            alert.addAction(action)
            self.present(alert, animated: true, completion: nil)
        }
        
        let deleteAction = SwipeAction(style: .destructive, title: "Delete") { (action, indexPath) in
            if let notesList = self.notes {
                Database.deleteNote(notesList[indexPath.row])
                self.tableView.reloadData()
            }
        }
        
        return [deleteAction, editAction]
    }
}
