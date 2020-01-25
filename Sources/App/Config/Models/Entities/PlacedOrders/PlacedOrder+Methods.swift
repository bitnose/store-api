//
//  PlacedOrder+Methods.swift
//  App
//
//  Created by Sötnos on 24.1.2020.
//

import Foundation
import Vapor
import FluentPostgreSQL

// MARK: - STATIC METHODS

extension PlacedOrder {
    
    /**
     # Soft Delete Placed Order
     - parameters:
        - req: Request
        - orderID: The ID of the model which will be deleted
     - returns: Futur Void
     - throws: Abort error
     
     1. Make a query to PlacedOrder table. Filter the results with the orderID to find the corresponding model. Soft delete the model.
     2. Catch the error if the resolved future returns as an error.
     3. Print the message with the error.
     4. Return future void.
     
     */
    static func deletePlacedOrder(_ req: Request, orderID: PlacedOrder.ID) throws -> Future<Void> {
           
        return PlacedOrder.query(on: req).filter(\.id == orderID).delete(force: false).catchFlatMap { error in // 1
            print("Can't delete the placed order: \(error)") // 2
            return req.future()// 3
        }
    }
}

extension PlacedOrder {
    
    
    /**
     # Create and Save Placed Order Model with the given data
     - parameters:
            - req: Request
            - orderID: The ID of the model which will be deleted
     - returns: Future<PlacedOrder>
     - throws: Abort error
         
     1. Unwrap the shippingID. Throw an abort if both ids are nil.
     2. Create an array of future floats by calling calculatePrice method inside the closure.
     3. Flatten the array of futures into a future with an array of results and unwrap the future.
     4. Get the shippingFee by calling a static method. Unwrap the future.
     5. Create an instance of total and shippingFee to it.
     6. Loop through prices.
     7. Add the price to the total.
     8. TODO: Get the taxes
     9. Create a new instance of PlacedOrder with the given data and save and return it.
     */
    
    static func createPlacedOrder(_ req: Request, order: PlacedOrderObject, userID: User.ID) throws -> Future<PlacedOrder> {
        
        guard let shippingID = order.pickUpOrderObject?.pickUpID ?? order.homeDeliveryOrderObject?.homeDeliveryID else { throw Abort(.notFound, reason: "The shipping ID is nil.")} // 1

        // 2
        return try order.orderItemObject.map { item in
            return try Product.calculatePrice(req, count: item.productQuantity, productID: item.productID)
        }.flatten(on: req).flatMap(to:  PlacedOrder.self) { prices in // 3
            
            return try PlacedOrder.calculateShippingFee(on: req, from: shippingID, isHomeDelivery: order.isHomeDelivery).flatMap(to: PlacedOrder.self) { shippingFee in // 4
            
                var total : Float = shippingFee // 6
                      
                    for price in prices {
                        total = total + price
                  }
                // TODO: - Calculate total taxes
                let taxes = Float(12)
            
                return PlacedOrder(totalPrice: total, totalTaxes: taxes, deliveryFee: shippingFee, orderStatus: OrderStatus.pendingPayment, userID: userID, isHomeDelivery: order.isHomeDelivery).save(on: req)
            }
        }
    }
}
extension PlacedOrder {

    /**
    # Calculate the shipping fee of the order
    - parameters:
        - on: req:  Request
        - form ID:  The ID of the model: Whether an ID of a HomeDelivery or an ID of a PickUp
        - isHomeDelivery: Boolean value which determines the type of the shipping
    - returns: Future Float
    - throws: Abort error
    
    1. Look if the value is true.
    2. Find the HomeDelivery with the given ID. Unwrap the result, throw an error if there was no result.
    3. Return the price of the delivery.
    4. If the boolean value is equal to false.
    5. Find the PickUp with the given ID. Unwrap the result, throw an error if there was no result.
    6. Return the price of the PickUp.
    */
    static func calculateShippingFee(on req: Request, from ID: UUID, isHomeDelivery: Bool) throws -> Future<Float> {

        if isHomeDelivery == true { // 1
            return HomeDelivery.find(ID, on: req).unwrap(or: Abort(.notFound, reason: "Couldn't find HomeDelivery with the given ID.")).map(to: Float.self) { homeDelivery in // 2
                return homeDelivery.price // 3
            }
        } else { // 4
            return PickUp.find(ID, on: req).unwrap(or: Abort(.notFound, reason: "Couldn't find PickUp with the given ID.")).map(to: Float.self) { foundPickUp in // 5
                return foundPickUp.price // 6
            }
        }
    }
}
