//
//  PlacedOrderController.swift
//  App
//
//  Created by Sötnos on 20.1.2020.
//


import Vapor
import Fluent
import Authentication

// Define different route handlers. To access routes you must register handlers with the router. A simple way to do this is to call the functions inside your controller from routes.swift
struct PlacedOrderController : RouteCollection {
  
     // MARK: - Route Registration
     func boot(router: Router) throws {
        
        // Grouped Routes (/api/placed-orders)
        let placedOrderRoutes = router.grouped("placed-orders")

        
        // MARK: - Route Groups
        /*
         
         1. Create a TokenAuthenticationMiddleware for User. This uses BearerAuthenticationMiddleware to extract the bearer token out of the request. The middleware then converts this token into a logged in user. Create a
         2. Create a GuardAuthMiddleware. Error to throw if the type is not authenticated.
         3. Create a route group using tokenAuthMiddleware and guardAuthMiddleware to protect the route for creating a user with token authentication.
         4. Create an adminGroup for routes which requires tha the user has an admin access.
        */
        let tokenAuthMiddleware = User.tokenAuthMiddleware() // 1
        let guardAuthMiddleware = User.guardAuthMiddleware() // 2
        let tokenAuthGroup = placedOrderRoutes.grouped(tokenAuthMiddleware, guardAuthMiddleware) // 3
        let adminGroup = tokenAuthGroup.grouped(AdminMiddleware()) // 4
        
        /*
         1. Get Request : Get the model
         2. Post Request : Post the model to add a new placedOrder model
         */
        tokenAuthGroup.get(PlacedOrder.parameter, use: getHandler) // 1
        tokenAuthGroup.post(PlacedOrderObject.self, at: "order", use: createPlacedOrderObjectHandler) // 2
    }

    // MARK: - Route Handlers

    /**
     # Get PlacedOrder Handler - Retrieves the individual PlacedOrder with the given ID
         
         - parameters:
            - req: Request
         - throws: Error
         - Returns: Future PlacedOrder
     
     1. Extract and return the model from the request parameter.
     */
    func getHandler(_ req: Request) throws -> Future<PlacedOrder> {
      return try req.parameters.next(PlacedOrder.self)  // 1.
    }
    
    /**
     # Create PlacedOrder
     This Handler creates:
     PlacedOrder,
     Customer
     OrderAddressesPivot,
     OrderItemPivot,
     PickUpOrder,
     HomeDeliveryOrder,
     - parameters:
         - order: PlacedOrderObject
         - req: Request
     - throws:  Abort Error
     - Returns: Future Order
     
     1. Get the authenticated user from the request.
     2. Ensure that the user id is not nil.
     2A. Try to validate the user input data.
     3. Call a static method to create a new PlacedOrder model with the given data. Unwrap the returned future.
     4. Unwrap the orderID. Throws if orderID is nil.
     5. Wait multiple different futures to resolve by calling flatMap(to:) function.
     6. Argument: The future result of calling a static method to create and save an OrderItemPivots with the given data.
     7. Argument: The future result of calling a static method to create and save an OrderAddressPivots with the given data.
     8. Argument: The future result of calling a static method to create and save a Customer with the given data.
     9. The resolved futures of the flatMap method (i.e. saved models.)
     10. Look if the order is homeDelivery:
     11. If yes, call a static method to creata a HomeDeliveryOrder model with the given data. Unwrap the returned future. We are force wrapping the model because in this point we know it's not nil because we were able to create an order.
     12. Create an order instance with the created data to return.
     13. If no, call a static method to create a PickUpOrder model with the given data. Unwrap the returned future. We are force wrapping the model because in this point we know it's not nil because we were able to create an order.
     14. Create an order instance with the created data to return.
     15. If the resolving future from the flatMap(to:) method resolves as an error, catch the error.
     16. Print the message with the error code.
     17. Because the error occured, we reverse the whole order by calling deletePlacedOrder method. This soft deletes the PlacedOrder model and its pivot models (cascade).
     18. Throw an abort.
     19. Catch the errors of the do block (synchronous errors) and throw abort.
 */
    func createPlacedOrderObjectHandler (_ req: Request, order: PlacedOrderObject) throws -> Future<Order> {
        
        let user = try req.requireAuthenticated(User.self) // 1
       guard let userID = user.id else { return req.future(error: Abort(.internalServerError))} // 2
        // 2A
        do {
            try order.validate()
            try order.customerObject.validate()

            return try PlacedOrder.createPlacedOrder(req, order: order, userID: userID).flatMap(to: Order.self) { savedOrder in // 4

                guard let orderID = savedOrder.id else {return req.future(error: Abort(.internalServerError))} // 4
                
                return flatMap(to: Order.self, // 5
                               try OrderItemPivot.createOrderItems(req, items: order.orderItemObject, to: orderID), // 6
                               try OrderAddressPivot.createOrderAddresses(req, addresses: order.orderAddressObject, to: orderID), // 7
                               try Customer.createCustomer(req, customer: order.customerObject, to: userID, to: orderID)) // 8
                    { savedItems, savedAddresses, savedCustomer in // 9
     
                    if order.isHomeDelivery == true { // 10
                        // 11
    
                        try order.homeDeliveryOrderObject!.validate() // Validate data
                  
                        return try HomeDeliveryOrder.createHomeDeliveryOrder(on: req, deliveryObject: order.homeDeliveryOrderObject!, to: savedOrder).map(to: Order.self) { del in
                             return Order(order: savedOrder, customer: savedCustomer, orderAddresses: savedAddresses, orderItems: savedItems, homeDelivery: del, pickup: nil) // 12
                        }
                    } else { // 13
                        try order.pickUpOrderObject!.validate() // Validate data
                    
            
                        return try PickUpOrder.createPickUpOrder(on: req, pickUpObject: order.pickUpOrderObject!, to: savedOrder).map(to: Order.self) { pick in
                            return Order(order: savedOrder, customer: savedCustomer, orderAddresses: savedAddresses, orderItems: savedItems, homeDelivery: nil, pickup: pick) // 14
                        }
                    }
                }.catchFlatMap { error in // 15
                    print("Error while creating an order: \(error)") // 16
                    return try PlacedOrder.deletePlacedOrder(req, orderID: orderID).flatMap(to: Order.self) { _ in // 17
                        print("PlacedOrder Deleted.")
                        throw Abort(.internalServerError, reason: "Error with creating data. \(error)") // 18
                    }
                }
            }
        } catch let error { // Catch the errors
            throw Abort(.internalServerError, reason: "Error with creating data. \(error)")
        }
    }
}


















struct Order : Content {
    let order : PlacedOrder
    let customer : Customer
    let orderAddresses : [OrderAddressPivot]
    let orderItems : [OrderItemPivot]
    let homeDelivery : HomeDeliveryOrder?
    let pickup : PickUpOrder?
}

