# Notebyte: Secure Encrypted Notes App

Notebyte is a secure encrypted IOS notes app with no ads, no telemetry or any permission.
Its simple and really fast, Just simply add title and contents of the note.

**Features**
- No Ads, No telemetry, No Permissions
- Simple Design
- Offline, no network access
- Just write note with title and content
- Sort options by created, modified and title

## Availability

Available for IOS 13+  
[Checkout on App Store](https://apps.apple.com/app/id1547347466 "App store")

## FAQ

**How it is encrypted?**

A 64 byte encryption key is generated. The key is stored in the secure keychain which is dedicated secure hardware (see Apples security white paper for more information). The first 32 bytes are used for encryption. The next 24 bytes are used for the signature, with the remaining 8 bytes not used currently. Each 4KB block of data is encrypted with AES-256 using cipher block chaining (CBC) mode and a unique initialization vector (IV) which is never reused within a file, and then signed with a SHA-2 HMAC.

---
Checkout the [privacy policy](http://logicco.io/notebyte/privacy "privacy policy").
For more information go to our official website [logicco.io ](http://logicco.io "Checkout ")
