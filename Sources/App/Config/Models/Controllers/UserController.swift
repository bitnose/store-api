
//
//  UserController.swift
//  App
//
//  Created by Sötnos on 03/07/2019.
//


import Vapor
import Crypto
import Fluent
import Authentication

// Define different route handlers. To access routes you must register handlers with the router. A simple way to do this is to call the functions inside your controller from routes.swift
struct UserController : RouteCollection {
  
     // MARK: - Route Registration
     func boot(router: Router) throws {
        
        // Grouped Routes (/api/users)
        let usersRoute = router.grouped("users")

        
        // MARK: - TOKEN AUTH
        /*
         
         1. Create a TokenAuthenticationMiddleware for User. This uses BearerAuthenticationMiddleware to extract the bearer token out of the request. The middleware then converts this token into a logged in user. Create a
         2. Create a GuardAuthMiddleware. Error to throw if the type is not authenticated.
         3. Create a route group using tokenAuthMiddleware and guardAuthMiddleware to protect the route for creating a user with token authentication.
        */
        let tokenAuthMiddleware = User.tokenAuthMiddleware() // 1
        let guardAuthMiddleware = User.guardAuthMiddleware() // 2
        let tokenAuthGroup = usersRoute.grouped(tokenAuthMiddleware, guardAuthMiddleware) // 3
        let adminAuthGroup = usersRoute.grouped(AdminMiddleware())
        
        
        // 1. Get Request : Get the User.Public of the authenticated user
        // 2. Post Request : Post User Model to create a new user.
        // 3. Put Request : Update User Model's usertype to be a host.
        tokenAuthGroup.get(User.parameter, use: getHandler) // 1
        usersRoute.post(RegisterPostData.self, use: createHandler) // 2
        adminAuthGroup.put("host", User.parameter, use: createHostHandler) // 3

        
        // MARK: - BASIC AUTH
        /*
         1. Instantiate a basic authentication middleware which uses BCryptDigest to verify passwords. Since User conforms to BasicAuthenticatable, this is available as a static function on the model.
         2. Create a middleware group what uses basicAuthMiddelware.
   
         */
        let basicAuthMiddleware = User.basicAuthMiddleware(using: BCryptDigest())
        let basicAuthGroup = usersRoute.grouped(basicAuthMiddleware)
        
        // 1. Post Request : Post login credentials to login
        basicAuthGroup.post("login", use: loginHandler)
        
        
        
        
    }
    
    // MARK: - Route Handlers

    /**
     Create User Handler - Creates a new user with the given data.
        
        - parameters:
            - user: RegisterPostData Object
            - req: Request
        - throws:  CryptoError
        - returns: Future User.Public
    
     1. In the do catch block validate the date.
     2. Catch the errors if there were any errors.
     3. If the error was a validationerror throw abort with the error.
     4 Otherwise throw abort with the normal error.
     5. Hash the password of the user.
     6. Create and save the user model to the database.
     7. Generate a token for the authenticated user.
     8. Create a new void promise.
     9. Make an instance of EmailSender to send an email to the user.
     10. Dispatch synchronous work to happen on a background thread.
     11. Call a method to send the mail to the user.
     12. When the "blocking work" has completed, complete the promise and its associated future.
     13. Save and return the token.
     
     */
    func createHandler(_ req: Request, data: RegisterPostData) throws -> Future<Token> {
        // 1
        do {
            try data.validate()
        } catch (let error) { // 2
            if let error = error as? ValidationError { // 3
                throw Abort(.badRequest, reason: "Error while validating the input data: \(error), message: \(error.reason)")
            } else { // 4
                throw Abort(.badRequest, reason: "\(error)")
            }
        }
        let hashedPassword = try BCrypt.hash(data.password) // 5
        // 6
        let user = User(firstname: data.firstname, lastname: data.lastname, email: data.email, password: hashedPassword, userType: .standard)
        return user.save(on: req).flatMap(to: Token.self) { savedUser in
            
            let token = try Token.generate(for: user) // 7
            let promise = req.eventLoop.newPromise(Void.self) // 8
            let sender = try req.make(EmailSender.self) // 9

            DispatchQueue.global().async { // 10
                sender.send(to: savedUser.email, name: savedUser.firstname ?? "", content: "Hi \( savedUser.firstname ?? "") We are happy that you registered to our application. Happy shopping!") // 11
                promise.succeed() // 12
            }
            return  token.save(on: req) // 13
        }
     }
    
    /**
     # Get User Handler - Retrieves the individual user with the given ID
         
         - parameters:
            - req: Request
         - throws: Error
         - returns: Future User.Public
     
     1.  Extract and return the user from the request parameter. Conver to public version of the user.
     */
    
    func getHandler(_ req: Request) throws -> Future<User.Public> {
      return try req.parameters.next(User.self).convertToPublic() // 1
    }
    
    /**
     # Login Post Handler - Function authenticates an user and creates a Token
         
         - parameters:
            - req: Request
         - throws: Authentication error
         - Returns: Future Token
     
     1. Get the authenticated user from the request.
     In the do  catch block catch the synchronous errors (ie. the errors thrown by a generating a token).
     2. Generate a token for the authenticated user
     3. Save and return the token.
     */
    
    func loginHandler(_ req: Request) throws -> Future<Token> {
       let user = try req.requireAuthenticated(User.self) // 1
      
        do {
            let token = try Token.generate(for: user) // 2
            return token.save(on: req) // 3
        } catch let error {
            return req.future(error: error)
        }
     }
    
    
    /**
     # Create Host User
     
        - parameters:
            - req: Request
        - throws: Authentication error
        - Returns: Future Status
     
     1.  Get the user from the request's parameters.
     2. Update the value of the selected user to host.
     3. Update the changes to database and transform the returned future to a HTTPStatus code.
     */
    
    func createHostHandler(_ req: Request) throws -> Future<HTTPStatus> {
        
        return try req.parameters.next(User.self).flatMap(to: HTTPStatus.self) { user in // 1
            user.userType = .host // 2
            return user.update(on: req).transform(to: .ok) // 3
        }
    }
}
