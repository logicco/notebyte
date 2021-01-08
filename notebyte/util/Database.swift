import Foundation
import RealmSwift
import KeychainAccess

enum DatabaseError: Error {
    case message(String)
}

struct Database {
    
    enum Sort: String {
        case title = "title"
        case lastModifield = "modified"
        case added = "added"
    }
    
    static func getEncryptionConfig() -> Realm.Configuration? {
        let keychain = Keychain(service: K.keychainEncryptionKeyTag)
        let key: String? = getEncryptionKeyFromKeychain(keychain, id: K.keychainEncryptionKeyIdentifier)
        if let keyStr = key {
            if let keyData = generateEncryptionKeyInBytes(from: keyStr){
                return Realm.Configuration(fileURL: self.getAppLibraryFolderUrl(filename: "encrypted.realm"), encryptionKey: keyData)
            }
        }
        return nil
    }
    
    static func initialize(){
        let keychain = Keychain(service: K.keychainEncryptionKeyTag)
        storeEncryptionKeyToKeychain(keychain, value: generateEncryptionKey(), id: K.keychainEncryptionKeyIdentifier)
        let token: String? = getEncryptionKeyFromKeychain(keychain, id: K.keychainEncryptionKeyIdentifier)
        if let keyStr = token{
            if let keyBytes = generateEncryptionKeyInBytes(from: keyStr){
                autoreleasepool {
                    let mainConfig = Realm.Configuration(fileURL: getAppLibraryFolderUrl(filename: "main.realm"))
                    do{
                        let realm = try! Realm(configuration: mainConfig)
                        try realm.writeCopy(toFile: self.getAppLibraryFolderUrl(filename: "encrypted.realm"), encryptionKey: keyBytes)
                    }catch{
                        print("could not load realm")
                    }
                }
            }

        }
    }
    
    static func getNotes(_ sortBy: Sort = .title) -> Results<Note>?{
        if let config = Database.getEncryptionConfig(){
            do {
                let realm = try Realm(configuration: config)
                switch sortBy {
                case .title:
                    return realm.objects(Note.self).sorted(byKeyPath: "title")
                case .lastModifield:
                    return realm.objects(Note.self).sorted(byKeyPath: "updatedDate", ascending: false)
                case .added:
                    return realm.objects(Note.self).sorted(byKeyPath: "createdDate", ascending: false)
                }
                
            }catch {
                print(error)
            }
        }
        return nil
    }
    
    static func searchNotes(byTitle title: String) -> Results<Note>? {
        if let config = Database.getEncryptionConfig(){
            do {
                let realm = try Realm(configuration: config)
                return realm.objects(Note.self).filter("title CONTAINS[cd] %@", title).sorted(byKeyPath: "title")
            }catch {
                print(error)
            }
        }
        return nil
    }
 
    static func addNote(_ note: Note){
        if let config = Database.getEncryptionConfig(){
            do {
                let realm = try Realm(configuration: config)
                try realm.write {
                    realm.add(note)
                }                
            }catch {
                print(error)
            }
        }
    }
    
    static func updateNote(_ note: Note, toUpdateNote: Note){
        if let config = Database.getEncryptionConfig(){
            do {
                let realm = try Realm(configuration: config)
                try realm.write {
                    note.title = toUpdateNote.title
                    note.content = toUpdateNote.content
                    note.updatedDate = Date()
                }
            }catch {
                print(error)
            }
        }
    }
    
    static func deleteNote(_ note: Note){
        if let config = Database.getEncryptionConfig(){
            do {
                let realm = try Realm(configuration: config)
                try realm.write {
                    realm.delete(note)
                }
            }catch {}
        }
    }
    
    private static func getAppLibraryFolderUrl(filename: String) -> URL {
        return URL(fileURLWithPath: NSSearchPathForDirectoriesInDomains(.libraryDirectory, .userDomainMask, true)[0], isDirectory: true).appendingPathComponent(filename)
    }
    
    private static func generateEncryptionKey() -> String {
        var key = Data(count: 64)
        _ = key.withUnsafeMutableBytes { bytes in
          SecRandomCopyBytes(kSecRandomDefault, 64, bytes)
        }
        return key.base64EncodedString()
    }
    
    private static func generateEncryptionKeyInBytes(from str: String) -> Data? {
        return Data(base64Encoded: str)
    }
    
    private static func storeEncryptionKeyToKeychain(_ keychain: Keychain, value: String, id: String){
        do {
            try keychain.set(value, key: id)
        }
        catch{
            print(print("could not set key in keychain"))
        }
    }
    
    private static func getEncryptionKeyFromKeychain(_ keychain: Keychain, id: String) -> String? {
        return try? keychain.get(id)
    }
    

}
