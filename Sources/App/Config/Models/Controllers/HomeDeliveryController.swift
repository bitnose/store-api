//
//  HomeDeliveryController.swift
//  App
//
//  Created by Sötnos on 19.1.2020.
//

import Vapor
import Fluent
import Authentication

// Define different route handlers. To access routes you must register handlers with the router. A simple way to do this is to call the functions inside your controller from routes.swift
struct HomeDeliveryController : RouteCollection {
  
     // MARK: - Route Registration
     func boot(router: Router) throws {
        
        // Grouped Routes (/api/products)
        let homeDeliveriesRoute = router.grouped("deliveries")

        
        // MARK: - Route Groups
        /*
         
         1. Create a TokenAuthenticationMiddleware for User. This uses BearerAuthenticationMiddleware to extract the bearer token out of the request. The middleware then converts this token into a logged in user. Create a
         2. Create a GuardAuthMiddleware. Error to throw if the type is not authenticated.
         3. Create a route group using tokenAuthMiddleware and guardAuthMiddleware to protect the route for creating a user with token authentication.
         4. Create an adminGroup for routes which requires tha the user has an admin access.
        */
        let tokenAuthMiddleware = User.tokenAuthMiddleware() // 1
        let guardAuthMiddleware = User.guardAuthMiddleware() // 2
        let tokenAuthGroup = homeDeliveriesRoute.grouped(tokenAuthMiddleware, guardAuthMiddleware) // 3
        let adminGroup = tokenAuthGroup.grouped(AdminMiddleware()) // 4
        
        /*
         1. Get Request : Get the home delivery
         2. Post Request : Post Home Delivery Model to add a new home delivery model
         */
        tokenAuthGroup.get(HomeDelivery.parameter, use: getHandler) // 1
        adminGroup.post(HomeDelivery.self, use: createHandler) // 2
        tokenAuthGroup.get("cities", City.parameter, use: getDeliveriesOfCityHandler)
    }

    // MARK: - Route Handlers
    
    /**
     # Create Home Delivery Handler - Creates a new Home Delivery with the given data.
        
        - parameters:
            - data: HomeDelivery Object
            - req: Request
        - throws:  CryptoError
        - Returns: Future HomeDelivery
    
     1. Save the product on the database.
     */
    
    func createHandler(_ req: Request, data: HomeDelivery) throws -> Future<HomeDelivery> {
        return data.save(on: req) // 1.
     }

    /**
     # Get Home Delivery Handler - Retrieves the individual Home Delivery with the given ID
         
         - parameters:
            - req: Request
         - throws: Error
         - Returns: Future Home Delivery 
     
     1. Extract and return the model from the request parameter.
     */
    func getHandler(_ req: Request) throws -> Future<HomeDelivery> {
      return try req.parameters.next(HomeDelivery.self)  // 1.
    }
    
    /**
    # Get home deliveries from the specific city
     - parameters:
        - req: Request
     - throws: Error
     - Returns: Future [Home Delivery]
     
     1.  Extract the City from the parameters and unwrap the future.
     2. Make a date instance and add 3 days to the date.
     3. Perform a query to the HomeDelivery table to return array of HomeDeliveries.
     4. Filter based on the cityID.
     5. Filter based on the date instance (deliveryDates which are after the date)
     5. Filter based on the boolean value "open"  
     6. Sort dates based on the deliveryDate variable.
     */
    func getDeliveriesOfCityHandler(_ req: Request) throws -> Future<[HomeDelivery]> {
           
        return try req.parameters.next(City.self).flatMap(to: [HomeDelivery].self) { city in // 1
            
            let today = Date() // 2
            guard let modifiedDate = Calendar.current.date(byAdding: .day, value: 3, to: today) else {throw Abort(.internalServerError)}

            return try HomeDelivery.query(on: req) // 3
                .filter(\.cityID == city.requireID()) // 4
                .filter(\.deliveryDate > modifiedDate)  // 5
                .filter(\.open == true) // 5a
           
                .sort(\HomeDelivery.deliveryDate, .ascending).all() // 6
        }
    }
}
