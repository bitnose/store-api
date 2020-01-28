//
//  PickUpController.swift
//  App
//
//  Created by Sötnos on 20.1.2020.
//

import Vapor
import Fluent
import Authentication

// Define different route handlers. To access routes you must register handlers with the router. A simple way to do this is to call the functions inside your controller from routes.swift
struct PickUpController : RouteCollection {
  
     // MARK: - Route Registration
     func boot(router: Router) throws {
        
        // Grouped Routes (/api/products)
        let pickUpRoutes = router.grouped("pickups")

        
        // MARK: - Route Groups
        /*
         
         1. Create a TokenAuthenticationMiddleware for User. This uses BearerAuthenticationMiddleware to extract the bearer token out of the request. The middleware then converts this token into a logged in user. Create a
         2. Create a GuardAuthMiddleware. Error to throw if the type is not authenticated.
         3. Create a route group using tokenAuthMiddleware and guardAuthMiddleware to protect the route for creating a user with token authentication.
         4. Create an adminGroup for routes which requires tha the user has an admin access.
        */
        let tokenAuthMiddleware = User.tokenAuthMiddleware() // 1
        let guardAuthMiddleware = User.guardAuthMiddleware() // 2
        let tokenAuthGroup = pickUpRoutes.grouped(tokenAuthMiddleware, guardAuthMiddleware) // 3
        let adminGroup = tokenAuthGroup.grouped(AdminMiddleware()) // 4
        
        /*
         1. Get Request : Get the home delivery
         2. Post Request : Post Home Delivery Model to add a new home delivery model
         3. Get Request : Get PickUps with the associated data from the given city id
         */
        tokenAuthGroup.get(PickUp.parameter, use: getHandler) // 1
        adminGroup.post(PickUp.self, use: createHandler) // 2
        tokenAuthGroup.get("cities", City.parameter, use: getPickUpsWithStopsHandler)
    }

    // MARK: - Route Handlers
    
    /**
     # Create New Pick Up Handler - Creates a new Pick Up with the given data.
        
        - parameters:
            - data: PickUp Object
            - req: Request
        - throws:  CryptoError
        - Returns: Future PickUp
    
     1. Save the product on the database.
     */
    
    func createHandler(_ req: Request, data: PickUp) throws -> Future<PickUp> {
        return data.save(on: req) // 1.
     }

    /**
     # Get Pick Up Handler - Retrieves the individual New Pick Up with the given ID
         
         - parameters:
            - req: Request
         - throws: Error
         - Returns: Future New Pick Up Stop
     
     1. Extract and return the product from the request parameter.
     */
    func getHandler(_ req: Request) throws -> Future<PickUp> {
      return try req.parameters.next(PickUp.self)  // 1.
    }
    
    /**
    # Get All Pick Ups with pick up stops in the city Handler - Retrieves all the pick ups with pick up stops with the given city ID
        
        - parameters:
           - req: Request
        - throws: Error
        - Returns: Future New Pick Up Stop
    
     1. Extract and return the model from the request parameter. Unwrap the future.
     2. Make a date instance of today.
     3. Add 3 full dates to the date isntance to get the limit for the earliest possible delivery/pickup date.
     4. Make a query to PickUp table and filter the results: Get the models which has open == true, and deliveryDate is after modifiedDate
     5. Join another model to the query  by using the shared propery.
     6. Filter: Get the models which has the cityID the given cityID.
     7. Sort the models based on the deliveryDate.
     8. Decode the another model also. This will return tuples.
     9. Return all the matching results and unwrap the futures.
     10. Map trough the models to create future model.
     11. Get the parent of the model and unwrap the future.
     12. Create a model with the fethced data.
     13. Create and return the another model with the fetched data.
     14. Flatten an array of futures into a future with an array of results.
    */
    
    func getPickUpsWithStopsHandler(_ req: Request) throws -> Future<[PickUpObject]> {
        
        return try req.parameters.next(City.self).flatMap(to: [PickUpObject].self) { city in // 1
            
            let today = Date() // 2
            guard let modifiedDate = Calendar.current.date(byAdding: .day, value: 3, to: today) else { return req.future(error: Abort(.internalServerError))} // 3
            guard let id = city.id else { return req.future(error: Abort(.internalServerError))}
            
            return PickUp.query(on: req).filter(\.open == true).filter(\.deliveryDate > modifiedDate) // 4
                .join(\PickUpStop.id, to: \PickUp.pickUpStopID) // 5
                .filter(\PickUpStop.cityID == id) // 6
                .sort(\.deliveryDate, .ascending) // 7
                .alsoDecode(PickUpStop.self) // 8
                .all().flatMap(to:[PickUpObject].self) { pairs in // 9
                
                return pairs.map { pickUp, pickUpStop -> Future<PickUpObject> in // 10
                
                    return pickUpStop.address.get(on: req).map(to: PickUpObject.self) { address in // 11
                        
                        let pickUpStopObject = PickUpStopObject(id: pickUpStop.id, addressID: address.id, street: address.street, postalcode: address.postalcode, city: address.city, country: address.country) // 12
                        
                        return PickUpObject(pickUpID: pickUp.id, deliveryDate: pickUp.deliveryDate, timePeriod: pickUp.timePeriod, price: pickUp.price, pickUpStop: pickUpStopObject) // 13
                        }
                }.flatten(on: req) // 14
            }
        }
    }
    
}

