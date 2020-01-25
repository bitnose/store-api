//
//  PickUpOrder.swift
//  App
//
//  Created by Sötnos on 19.1.2020.
//

import Foundation
import Vapor
import FluentPostgreSQL

// MARK: - Class Represents the PickUpOrder Pivot Model

/*
 1. Define a new object that conforms to PostgreSQLUUIDPivot. This is a helper protocol on top of Fluent's Pivot protocol.
 2. Define an id for the model. Note this is a UUID type so you must import the Foundationn module in the file.
 3. Define two properties to link to the IDs of Objects. This is what holds the relationship.
 4. Define Left and Right types required by Pivot. This tells Fluent what the two models in the relationship are.
 5. Tell Fluent the key path of the two ID properties for each side of the relationship.
 6. Implement the throwing initializer, as required by ModifiablePivot.
 7. Conform to Migration so Fluent can set up the table.
 8. Confrom to Pivot.
*/

/**
 # Contains the Pivot model to manage the sibling relationship
 Class contains properties to hold:
 - id : The unique identifier of the object
 - placedOrderID: The id of the order
 - pickUpID: The id of the pick up
 - note: A note about the pickUp
 - finalDeliveryFee: The final fee of the pick up
 - status: Status of the pick up
 - createdAt: TheTimestamp of the moment when the object was created

  */
 
final class PickUpOrder : PostgreSQLUUIDPivot { // 1
    // 2
    var id : UUID?
    // 3
    var placedOrderID : PlacedOrder.ID
    var pickUpID : PickUp.ID
    var note: String?
    var finalDeliveryFee: Float
    var status: String
    var createdAt: Date?
   
    // 5
    typealias Left = PlacedOrder
    typealias Right = PickUp
    // 6
    static let leftIDKey: LeftIDKey = \.placedOrderID
    static let rightIDKey: RightIDKey = \.pickUpID
    
    // 7 Init
    init(placedOrderID: PlacedOrder.ID, pickUpID: PickUp.ID, note: String?, finalDeliveryFee: Float, status: String) {
        
        self.placedOrderID = placedOrderID
        self.pickUpID = pickUpID
        self.note = note
        self.finalDeliveryFee = finalDeliveryFee
        self.status = status

    }
    
    // Fluent will automatically manage these records
    static var createdAtKey: TimestampKey? = \.createdAt

    
}
// MARK: - Extensions
extension PickUpOrder: Pivot {} // 8
extension PickUpOrder: Parameter {}
extension PickUpOrder: Content {}
extension PickUpOrder: Encodable {}

// MARK: - Foreign Ket Constraints

/*
 Foreign Key Constraints
 1. Conform the Pivot to Migration.
 2. Implement prepare(on:) as defined by Migration. This overrides the default implementation.
 3. Create the table for pivot model in the database.
 4. Use addProperties(to:) to add all the fields to the database.
 5. Add a reference between the id property on pivot model and the id property on another model. This sets up the foreign key constraint. .cascade sets a cascade schema reference action when you delete the model. This means that the relationship is automatically removed instead of an error being thrown.
 6. Add a reference between the id property on pivot model and the id property on another model. This sets up the foreign key constraint. Also set the schema reference action for deletion when deleting the model.
 */


extension PickUpOrder: Migration {// 1
    
    static func prepare(on connection: PostgreSQLConnection) -> Future<Void> { // 2
        return Database.create(self, on: connection) { builder in // 3
            try addProperties(to: builder) // 4
            builder.reference(from: \.placedOrderID, to: \PlacedOrder.id, onDelete: ._cascade) // 5
            builder.reference(from: \.pickUpID, to: \PickUp.id, onDelete: .cascade) // 6
        }
    }
    
}

extension PickUpOrder {

    /**
    # Create and Save PickUpOrder model with the given data
    
    - parameters:
       - req: Used to fetch a database connection.
       - customer: The provided data what we use to create the model
       - to order: The unique identifier of the placed order
    - throws: Throws an abort error.
    - returns: Future Result of PickUpOrder
    
    1. Create an instance of PickUpOrder with the given data.
    2. Save the model.
    */
    
    static func createPickUpOrder(on req: Request, pickUpObject: PickUpOrderObject, to order: PlacedOrder) throws -> Future<PickUpOrder> {
        // 1
        return try PickUpOrder(placedOrderID: order.requireID(),
                                   pickUpID: pickUpObject.pickUpID,
                                   note: pickUpObject.note,
                                   finalDeliveryFee: order.deliveryFee,
                                   status: "notShipped")
            .save(on: req) // 2
  
    }
}
