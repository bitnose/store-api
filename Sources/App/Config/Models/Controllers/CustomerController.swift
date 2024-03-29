//
//  CustomerController.swift
//  App
//
//  Created by Sötnos on 19.1.2020.
//


import Vapor
import Fluent
import Authentication

// Define different route handlers. To access routes you must register handlers with the router. A simple way to do this is to call the functions inside your controller from routes.swift
struct CustomerController : RouteCollection {
  
     // MARK: - Route Registration
     func boot(router: Router) throws {
        
        // Grouped Routes (/api/products)
        let customerRoutes = router.grouped("customers")

        
        // MARK: - Route Groups
        /*
         
         1. Create a TokenAuthenticationMiddleware for User. This uses BearerAuthenticationMiddleware to extract the bearer token out of the request. The middleware then converts this token into a logged in user. Create a
         2. Create a GuardAuthMiddleware. Error to throw if the type is not authenticated.
         3. Create a route group using tokenAuthMiddleware and guardAuthMiddleware to protect the route for creating a user with token authentication.
         4. Create an adminGroup for routes which requires tha the user has an admin access.
        */
        let tokenAuthMiddleware = User.tokenAuthMiddleware() // 1
        let guardAuthMiddleware = User.guardAuthMiddleware() // 2
        let tokenAuthGroup = customerRoutes.grouped(tokenAuthMiddleware, guardAuthMiddleware) // 3
        let adminGroup = tokenAuthGroup.grouped(AdminMiddleware()) // 4
        
        /*
         1. Get Request : Get the home delivery
         2. Post Request : Post Home Delivery Model to add a new home delivery model
         */
        tokenAuthGroup.get(Customer.parameter, use: getHandler) // 1
        tokenAuthGroup.post(Customer.self, use: createHandler) // 2
  //      tokenAuthGroup.get(City.parameter,  use: getDeliveriesOfCityHandler)
    }

    // MARK: - Route Handlers
    
    /**
     # Create New Customer Handler - Creates a new Customer with the given data.
        
        - parameters:
            - data: Customer Object
            - req: Request
        - throws:  CryptoError
        - Returns: Future Customer
    
     1. Save the customer on the database.
     */
    
    func createHandler(_ req: Request, data: Customer) throws -> Future<Customer> {
        return data.save(on: req) // 1.
     }

    /**
     # Get Customer Handler - Retrieves the individual Customer with the given ID
         
         - parameters:
            - req: Request
         - throws: Error
         - Returns: Future Customer
     
     1. Extract and return the customer from the request parameter.
     */
    func getHandler(_ req: Request) throws -> Future<Customer> {
      return try req.parameters.next(Customer.self)  // 1.
    }
}
