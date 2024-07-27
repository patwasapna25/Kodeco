/*:
 [Previous](@previous)&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;[Next](@next)
 
 # Adapter
 - - - - - - - - - -
 ![Adapter Diagram](Adapter_Diagram.png)
 
 The adapter pattern allows incompatible types to work together. It involves four components:
 
 1. An **object using an adapter** is the object that depends on the new protocol.
 
 2. The **new protocol** that is desired to be used.
 
 3. A **legacy object** that existed before the protocol was made and cannot be modified directly to conform to it.
 
 4. An **adapter** that's created to conform to the protocol and passes calls onto the legacy object.
 
 ## Code Example
 */
import Foundation 

public class GoogleAuthenticator {
    public func login(email: String, password: String, compleition: @escaping (GoogleUser?, Error?) -> Void) {
        //Make networking calls which returns a special "token"
        let token = "special-token"
        let user = GoogleUser(email: email, password: password, token: token)
        compleition(user, nil)
    }
}

public struct GoogleUser {
    public var email: String
    public var password: String
    public var token: String
}

public protocol AuthenticationService {
    func login(email: String, password: String, success: @escaping (User, Token) -> Void, failure: @escaping (Error?) -> Void)
}

public struct User {
    public let email: String
    public let password: String
}

public struct Token {
    public let value: String
}

public class GoogleAuthenticatorAdapter: AuthenticationService {
    let authenticator = GoogleAuthenticator()
    
    public func login(email: String, password: String, success: @escaping (User, Token) -> Void, failure: @escaping (Error?) -> Void) {
        authenticator.login(email: email, password: password, compleition: { (googleUser, error) in
            guard let googleUser else {
                failure(error)
                return
            }
            let user = User(email: email, password: password)
            let token = Token(value: googleUser.token)
            success(user, token)
        })
    }    
}

let authService: AuthenticationService = GoogleAuthenticatorAdapter()
authService.login(email: "user@ex.com", password: "password", success: { (user, token) in
    print("Auth succeeded: \(user.email) \(token.value)")
}, failure: { error in 
    print("Auth Failed with error: \(String(describing: error))")
})
