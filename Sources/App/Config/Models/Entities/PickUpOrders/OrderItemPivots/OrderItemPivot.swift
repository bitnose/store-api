//
//  OrderItemPivotswift.swift
//  App
//
//  Created by Sötnos on 19.1.2020.
//

import Foundation
import Vapor
import FluentPostgreSQL

// MARK: - Class Represents the OrderItemPivot Model

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
 - ID : Optional id property that stores the ID of the model assigned by the database when it's saved.
 - deletedAt: A property for Fluent to store the date you performed a soft delete on the model.
 - createdAt: A property for Fluent to store the date object was created.
 - updatedAt: A property for Fluent to store the date object was updated.
 - price: The selling price of the obejct (Can be di)
 - quantity: Int
  */
 
final class OrderItemPivot : PostgreSQLUUIDPivot { // 1
    // 2
    var id : UUID?
    // 3
    var placedOrderID : PlacedOrder.ID
    var productID : Product.ID
    var productQuantity: Int
    var status: String
    var createdAt: Date?
 
    // 5
    typealias Left = PlacedOrder
    typealias Right = Product
    // 6
    static let leftIDKey: LeftIDKey = \.placedOrderID
    static let rightIDKey: RightIDKey = \.productID
    
    // 7 Init
    init(placedOrderID: PlacedOrder.ID, productID: Product.ID, productQuantity: Int, status: String) {
        
        self.placedOrderID = placedOrderID
        self.productID = productID
        self.productQuantity = productQuantity
        self.status = status
    }
    
    // Fluent will automatically manage these records
    static var createdAtKey: TimestampKey? = \.createdAt
}
extension OrderItemPivot: Pivot {} // 8

// MARK: - Extensions

extension OrderItemPivot: Codable {} // Conform the Fluent's Model
extension OrderItemPivot : Content {} // Conform Content
extension OrderItemPivot : Parameter {} // Conform Parameter

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

extension OrderItemPivot: Migration {// 1
    
    static func prepare(on connection: PostgreSQLConnection) -> Future<Void> { // 2
        return Database.create(self, on: connection) { builder in // 3
            try addProperties(to: builder) // 4
            builder.reference(from: \.placedOrderID, to: \PlacedOrder.id, onDelete: ._cascade) // 5
            builder.reference(from: \.productID, to: \Product.id, onDelete: .cascade) // 6
        }
    }
    
}


extension OrderItemPivot {
    
    /**
     # Create and Save Order Items
      - parameters:
        - req: Request
        - items : [OrderItemObject]
        - to id: The id of the placed order
     - throws: Abort Error
     - returns: Future<[OrderItemPivot]>
     
     1. Map the items array through.
     1A. Validate the data in the do-catch block before creating new models. Catch the errors if there are any.
     2. Create an instance of OrderItemPivot with the given data.
     3. Return and save the OrderItemPivot.
     4. Flattens an array of futures into a future with an array of results.
     */
     static func createOrderItems(_ req: Request, items: [OrderItemObject], to id: PlacedOrder.ID) throws -> Future<[OrderItemPivot]> {
           
           return try items.map { orderItem in // 1
            
            
            
               let orderItemPivot = OrderItemPivot(placedOrderID: id, productID: orderItem.productID, productQuantity: orderItem.productQuantity, status: "awaitingFullfilment") // 2
            return orderItemPivot.save(on: req) // 3
           }.flatten(on: req) // 4
       }
    
}

