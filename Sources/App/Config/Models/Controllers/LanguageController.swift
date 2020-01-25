//
//  LanguageController.swift
//  App
//
//  Created by Sötnos on 18.1.2020.
//


import Vapor
import Fluent
import Authentication

// Define different route handlers. To access routes you must register handlers with the router. A simple way to do this is to call the functions inside your controller from routes.swift
struct LanguageController : RouteCollection {
  
     // MARK: - Route Registration
     func boot(router: Router) throws {
        
        // Grouped Routes (/api/products)
        let productsRoute = router.grouped("languages")

        
        // MARK: - Route Groups
        /*
         
         1. Create a TokenAuthenticationMiddleware for User. This uses BearerAuthenticationMiddleware to extract the bearer token out of the request. The middleware then converts this token into a logged in user. Create a
         2. Create a GuardAuthMiddleware. Error to throw if the type is not authenticated.
         3. Create a route group using tokenAuthMiddleware and guardAuthMiddleware to protect the route for creating a user with token authentication.
         4. Create an adminGroup for routes which requires tha the user has an admin access.
        */
        let tokenAuthMiddleware = User.tokenAuthMiddleware() // 1
        let guardAuthMiddleware = User.guardAuthMiddleware() // 2
        let tokenAuthGroup = productsRoute.grouped(tokenAuthMiddleware, guardAuthMiddleware) // 3
        let adminGroup = tokenAuthGroup.grouped(AdminMiddleware()) // 4
        
        /*
         1. Get Request : Get the language
         2. Post Request : Post Language Model to add a new language.
         */
        
        tokenAuthGroup.get(Language.parameter, use: getHandler) // 1
        adminGroup.post(Language.self, use: createHandler) // 2
    }

    // MARK: - Route Handlers
    
    /**
     # Create Language Handler - Creates a new model with the given data.
        
        - parameters:
            - data: Language Object
            - req: Request
        - throws:  CryptoError
        - Returns: Future Product
    
     1. Save the model on the database.
     */
    
    func createHandler(_ req: Request, data: Language) throws -> Future<Language> {
        return data.save(on: req) // 1.
     }
    

    /**
     # Get Language Handler - Retrieves the individual language with the given ID
         
         - parameters:
            - req: Request
         - throws: Error
         - Returns: Future Language
     
     1. Extract and return the model from the request parameter.
     */
    func getHandler(_ req: Request) throws -> Future<Language> {
      return try req.parameters.next(Language.self)  // 1.
    }
    

}
