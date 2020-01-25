//
//  OrderItemController.swift
//  App
//
//  Created by Sötnos on 20.1.2020.
//

import Vapor
import Fluent
import Authentication

// Define different route handlers. To access routes you must register handlers with the router. A simple way to do this is to call the functions inside your controller from routes.swift
struct OrderItemController : RouteCollection {
  
     // MARK: - Route Registration
     func boot(router: Router) throws {
        
        // Grouped Routes
        let orderItemRoutes = router.grouped("order-items")

        
        // MARK: - Route Groups
        /*
         
         1. Create a TokenAuthenticationMiddleware for User. This uses BearerAuthenticationMiddleware to extract the bearer token out of the request. The middleware then converts this token into a logged in user. Create a
         2. Create a GuardAuthMiddleware. Error to throw if the type is not authenticated.
         3. Create a route group using tokenAuthMiddleware and guardAuthMiddleware to protect the route for creating a user with token authentication.
         4. Create an adminGroup for routes which requires tha the user has an admin access.
        */
        let tokenAuthMiddleware = User.tokenAuthMiddleware() // 1
        let guardAuthMiddleware = User.guardAuthMiddleware() // 2
        let tokenAuthGroup = orderItemRoutes.grouped(tokenAuthMiddleware, guardAuthMiddleware) // 3
   //     let adminGroup = tokenAuthGroup.grouped(AdminMiddleware()) // 4
        
        /*
         1. Get Request : Get the OrderItem
         2. Post Request : Post OrderItem Model to add a new home OrderItem model
         */
        tokenAuthGroup.get(OrderItemPivot.parameter, use: getHandler) // 1
        tokenAuthGroup.post(OrderItemPivot.self, use: createHandler) // 2
  //      tokenAuthGroup.get(City.parameter,  use: getDeliveriesOfCityHandler)
    }

    // MARK: - Route Handlers
    
    /**
     # Create New OrderItem Handler - Creates a new OrderItem with the given data.
        
        - parameters:
            - data: OrderItemPivot Object
            - req: Request
        - throws:  CryptoError
        - Returns: Future OrderItemPivot
    
     1. Save the product on the database.
     */
    
    func createHandler(_ req: Request, data: OrderItemPivot) throws -> Future<OrderItemPivot> {
        return data.save(on: req) // 1.
     }

    /**
     # Get OrderItem Handler - Retrieves the individual OrderItem Up with the given ID
         
         - parameters:
            - req: Request
         - throws: Error
         - Returns: Future OrderItemPivot
     
     1. Extract and return the product from the request parameter.
     */
    func getHandler(_ req: Request) throws -> Future<OrderItemPivot> {
      return try req.parameters.next(OrderItemPivot.self)  // 1.
    }
}
