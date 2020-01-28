//
//  AddressController.swift
//  App
//
//  Created by Sötnos on 19.1.2020.
//

import Vapor
import Fluent
import Authentication

// Define different route handlers. To access routes you must register handlers with the router. A simple way to do this is to call the functions inside your controller from routes.swift
struct AddressController : RouteCollection {
  
     // MARK: - Route Registration
     func boot(router: Router) throws {
        
        // Grouped Routes (/api/products)
        let addressesRoute = router.grouped("addresses")

        
        // MARK: - Route Groups
        /*
         
         1. Create a TokenAuthenticationMiddleware for User. This uses BearerAuthenticationMiddleware to extract the bearer token out of the request. The middleware then converts this token into a logged in user. Create a
         2. Create a GuardAuthMiddleware. Error to throw if the type is not authenticated.
         3. Create a route group using tokenAuthMiddleware and guardAuthMiddleware to protect the route for creating a user with token authentication.
         4. Create an adminGroup for routes which requires tha the user has an admin access.
        */
        let tokenAuthMiddleware = User.tokenAuthMiddleware() // 1
        let guardAuthMiddleware = User.guardAuthMiddleware() // 2
        let tokenAuthGroup = addressesRoute.grouped(tokenAuthMiddleware, guardAuthMiddleware) // 3
      //  let adminGroup = tokenAuthGroup.grouped(AdminMiddleware()) // 4
        
        /*
         1. Post Request : Post Address Model to add a new address.
         2. Get Request : Get user's addresses.
         3. Post Request : Post Address to User
         4. Post Request : Post Order Address
         */
        

        tokenAuthGroup.post(Address.self, use: createHandler) // 1
        tokenAuthGroup.get("user", use: getUsersAddressesHandler) // 2
        tokenAuthGroup.post(Address.parameter, use: addAddressToUserHandler) // 3
        tokenAuthGroup.post(OrderAddressPivot.self, at: "orders", use: addAddressToOrderHandler) // 4
    }

    // MARK: - Route Handlers
    
    /**
     # Create Address Handler - Creates a new model with the given data.
        
        - parameters:
            - data: Language Object
            - req: Request
        - throws:  CryptoError
        - Returns: Future Address
     
    1. In the do catch block validate the date.
    2. Catch the errors if there were any errors.
    3. If the error was a validationerror throw abort with the error.
    4 Otherwise throw abort with the normal error.
    5. Save the model on the database.
     */
    
    func createHandler(_ req: Request, data: Address) throws -> Future<Address> {
        // 1
        do {
            try data.validate()
        } catch let error { // 2
            if let error = error as? ValidationError { // 3
                throw Abort(.badRequest, reason: "Error while validating the input data: \(error), message: \(error.reason)")
            } else { // 4
                throw Abort(.badRequest, reason: "\(error)")
            }
        }
        return data.save(on: req) // 5
     }
    
    /**
     # Get Addresses Handler - Retrieves the individual language with the given ID
         
         - parameters:
            - req: Request
         - throws: Error
         - Returns: Future Language
        
     1. Get the authenticated user.
     2. Use the computed property to get addresses and use query to query models. Sort results based on the creationdate and return all.
     */
    func getUsersAddressesHandler(_ req: Request) throws -> Future<[Address]> {
        let user = try req.requireAuthenticated(User.self) // 1
        return try user.addresses.query(on: req).sort(\.createdAt, .ascending).all() // 2
    }
    
    /**
        # Attach the model to the another model.
          
          - parameters:
             - req: Request
          - throws: Error
          - Returns: HTTPStatus

        1. Get the authenticated user.
        2. Extract and return the First Model from the request parameter. Unwrap the future.
        3. Add the first model to another model and transform to HttpStatus.
        */
    func addAddressToUserHandler(_ req: Request) throws -> Future<HTTPStatus> {
        
        let user = try req.requireAuthenticated(User.self)
        return try req.parameters.next(Address.self).flatMap(to: HTTPStatus.self) { address in // 1
            return user.addresses.attach(address, on: req).transform(to: .created) // 2
        }
    }
    
    /**
    # Attach the model to the another model.
         
         - parameters:
            - req: Request
            - data: OrderAddressPivot
         - throws: Error
         - Returns: HTTPStatus

       1. Extract and return the First Model  and the second Model from the request parameter. Unwrap the futures.
       2. Add the first model to another model and transform to HttpStatus.
        */
    func addAddressToOrderHandler(_ req: Request, data: OrderAddressPivot) throws -> Future<OrderAddressPivot> {
        data.save(on: req)
    }
    
}

