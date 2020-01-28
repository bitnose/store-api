//
//  OrderAddressPivot.swift
//  App
//
//  Created by Sötnos on 19.1.2020.
//

import Foundation
import Vapor
import FluentPostgreSQL

// MARK: - Class Represents the OrderAddressPivot Moddel

// This class contains information about the order's addresses: The shipping address, The billing address
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
 - placedOrderID
 - addressID
 - billingAddress : Determines whether the address is billing address or not
 - shippingAddress: Determines whether the address is shippin address or not
  */
 
final class OrderAddressPivot : PostgreSQLUUIDPivot { // 1
    // 2
    var id : UUID?
    // 3
    var placedOrderID : PlacedOrder.ID
    var addressID : Address.ID
    var billingAddress: Bool
    var shippingAddress: Bool
    
    // 5
    typealias Left = PlacedOrder
    typealias Right = Address
    // 6
    static let leftIDKey: LeftIDKey = \.placedOrderID
    static let rightIDKey: RightIDKey = \.addressID
    
    // 7 Init
    init(placedOrderID: PlacedOrder.ID, addressID: Address.ID, billingAddress: Bool, shippingAddress: Bool) {
        
        self.placedOrderID = placedOrderID
        self.addressID = addressID
        self.billingAddress = billingAddress
        self.shippingAddress = shippingAddress
   
    }
}
extension OrderAddressPivot: Pivot {} // 8

// MARK: - Extensions

extension OrderAddressPivot: Codable {} // Conform the Fluent's Model
extension OrderAddressPivot : Content {} // Conform Content
extension OrderAddressPivot : Parameter {} // Conform Parameter

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

extension OrderAddressPivot: Migration {// 1
    
    static func prepare(on connection: PostgreSQLConnection) -> Future<Void> { // 2
        return Database.create(self, on: connection) { builder in // 3
            try addProperties(to: builder) // 4
            builder.reference(from: \.placedOrderID, to: \PlacedOrder.id, onDelete: ._cascade) // 5
            builder.reference(from: \.addressID, to: \Address.id, onDelete: .cascade) // 6
        }
    }
    
}

// MARK: - STATIC METHODS

extension OrderAddressPivot {
    
    /**
    # Create and Save OrderAddressPivot Models
     - parameters:
       - req: Request
       - addresses : [OrderAddressObject]
       - to id: The id of the placed order
    - throws: Abort Error
    - returns: Future<[OrderAddressPivot]>
    
    1. Map the items array through.
    2. Create an instance of OrderAddressPivot with the given data.
    3. Return and save the model.
    4. Flattens an array of futures into a future with an array of results.
    */
    
    static func createOrderAddresses(_ req: Request, addresses: [OrderAddressObject], to id: PlacedOrder.ID) throws -> Future<[OrderAddressPivot]> {
        
        // TODO: - Validate the date
        
        return addresses.map { orderAddress in // 1
     
            let orderAddressPivot = OrderAddressPivot(placedOrderID: id, addressID: orderAddress.addressID, billingAddress: orderAddress.billingAddress, shippingAddress: orderAddress.shippingAddress) // 2
            return orderAddressPivot.save(on: req) // 3
        }.flatten(on: req) // 4
    }
}
