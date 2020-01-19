//
//  CityController.swift
//  App
//
//  Created by Sötnos on 19.1.2020.
//



import Vapor
import Fluent
import Authentication

// Define different route handlers. To access routes you must register handlers with the router. A simple way to do this is to call the functions inside your controller from routes.swift
struct CityController : RouteCollection {
  
     // MARK: - Route Registration
     func boot(router: Router) throws {
        
        // Grouped Routes (/api/products)
        let citiesRoutes = router.grouped("cities")

        // MARK: - Route Groups
        /*
         
         1. Create a TokenAuthenticationMiddleware for User. This uses BearerAuthenticationMiddleware to extract the bearer token out of the request. The middleware then converts this token into a logged in user. Create a
         2. Create a GuardAuthMiddleware. Error to throw if the type is not authenticated.
         3. Create a route group using tokenAuthMiddleware and guardAuthMiddleware to protect the route for creating a user with token authentication.
         4. Create an adminGroup for routes which requires tha the user has an admin access.
        */
        let tokenAuthMiddleware = User.tokenAuthMiddleware() // 1
        let guardAuthMiddleware = User.guardAuthMiddleware() // 2
        let tokenAuthGroup = citiesRoutes.grouped(tokenAuthMiddleware, guardAuthMiddleware) // 3
        let adminGroup = tokenAuthGroup.grouped(AdminMiddleware()) // 4
        
        /*
         1. Post Request : Post Model to add a new citu.
         2. Get Request : Get all the cities 
         */

        adminGroup.post(City.self, use: createHandler) // 1
      //  tokenAuthGroup.get("all", use: getAllHandler) // 3
      //  tokenAuthGroup.get("shipping", String.parameter, use: getSupportedDeliveryMethodsHandler)
    }

    // MARK: - Route Handlers
    
    /**
     # Create Address Handler - Creates a new model with the given data.
        
        - parameters:
            - data: Language Object
            - req: Request
        - throws:  CryptoError
        - Returns: Future Address
    
     1. Save the product on the database.
     */
    func createHandler(_ req: Request, city: City) throws -> Future<City> {
        return city.save(on: req) // 1.
     }
    
    
   
    
    
    
}
