//
//  HomeDeliveryOrderController.swift
//  App
//
//  Created by Sötnos on 20.1.2020.
//

import Vapor
import Fluent
import Authentication

// Define different route handlers. To access routes you must register handlers with the router. A simple way to do this is to call the functions inside your controller from routes.swift
struct HomeDeliveryOrderController : RouteCollection {
  
     // MARK: - Route Registration
     func boot(router: Router) throws {
        
        // Grouped Routes (/api/home-delivery-orders)
        let homeDeliveryOrderRoutes = router.grouped("home-delivery-orders")

        
        // MARK: - Route Groups
        /*
         
         1. Create a TokenAuthenticationMiddleware for User. This uses BearerAuthenticationMiddleware to extract the bearer token out of the request. The middleware then converts this token into a logged in user. Create a
         2. Create a GuardAuthMiddleware. Error to throw if the type is not authenticated.
         3. Create a route group using tokenAuthMiddleware and guardAuthMiddleware to protect the route for creating a user with token authentication.
         4. Create an adminGroup for routes which requires tha the user has an admin access.
        */
        let tokenAuthMiddleware = User.tokenAuthMiddleware() // 1
        let guardAuthMiddleware = User.guardAuthMiddleware() // 2
        let tokenAuthGroup = homeDeliveryOrderRoutes.grouped(tokenAuthMiddleware, guardAuthMiddleware) // 3
        let adminGroup = tokenAuthGroup.grouped(AdminMiddleware()) // 4
        
        /*
         1. Get Request : Get the home delivery
         2. Post Request : Post Home Delivery Model to add a new home delivery model
         */
        tokenAuthGroup.get(HomeDeliveryOrder.parameter, use: getHandler) // 1
        adminGroup.post(HomeDeliveryOrder.self, use: createHandler) // 2
    }

    // MARK: - Route Handlers
    
    /**
     # Get Home Delivery Order Handler - Retrieves the individual Home Delivery Order with the given ID
         - parameters:
            - req: Request
         - throws: Error
         - Returns: Future Home Delivery
     
     1. Extract and return the model from the request parameter.
     */
    func getHandler(_ req: Request) throws -> Future<HomeDeliveryOrder> {
      return try req.parameters.next(HomeDeliveryOrder.self)  // 1.
    }
    
    /**
      # Create Home Delivery Order Handler - Creates a new Home Delivery Order with the given data.
         - parameters:
             - data: HomeDeliveryOrder Object
             - req: Request
         - throws:  CryptoError
         - Returns: Future HomeDeliveryOrder
     
      1. Save the model on the database.
      */
    func createHandler(_ req: Request, data: HomeDeliveryOrder) throws -> Future<HomeDeliveryOrder> {
        return data.save(on: req) // 1
    }
}
