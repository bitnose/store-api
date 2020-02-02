//
//  Price.swift
//  App
//
//  Created by Sötnos on 31.1.2020.
//

import Foundation
import Vapor
import FluentPostgreSQL


// MARK: - Class Represents the Price Model

/**

 Class contains properties to hold:
 - ID : Optional id property that stores the ID of the model assigned by the database when it's saved.
 - createdAt: A property for Fluent to store the date object was created.
 - updatedAt: A property for Fluent to store the date object was updated.
 - price: The selling price of the obejct.
 */

final class Price : Codable {
    
    var id : UUID?
    var deletedAt: Date?
    var createdAt: Date?
    var updatedAt: Date?
    let price : Int
    let tax : Int
    var validFrom: Date
    var validUntil: Date?
    var currency: Currency
    var productID : Product.ID?
    var pickupID: PickUp.ID?
    var homeDeliveryID : HomeDelivery.ID?
    
    // Inits
    init(price: Int, tax: Int, validFrom: Date, validUntil: Date?, currency: Currency, productID: Product.ID?, pickupID: PickUp.ID?, homeDeliveryID: HomeDelivery.ID?) {
        self.price = price
        self.tax = tax
        self.validFrom = validFrom
        self.validUntil = validUntil
        self.currency = currency
        self.productID = productID
        self.pickupID = pickupID
        self.homeDeliveryID = homeDeliveryID
    }
    
    // Add to new key path that Fluent checks when you call delete(on:). If the key path exists, Fluent sets the current date on the property and saves the updated model. Otherwise, it deletes the model from the database
    static var deletedAtKey : TimestampKey? = \.deletedAt
    // Fluent will automatically manage these records
    static var createdAtKey: TimestampKey? = \.createdAt
    static var updatedAtKey : TimestampKey? = \.updatedAt

    

}

// MARK: - Extensions

extension Price: PostgreSQLUUIDModel {} // Conform the Fluent's Model
extension Price : Content {} // Conform Content
extension Price : Parameter {} // Conform Parameter
extension Price: Migration {} // Conform Migrations


// MARK: - Relationships

extension Price {
    
    // Children

    
    // Siblings

    
    // Parents
 //   var product: Parent<Price, Product> {return parent(\.productID) ?? nil}

    
}



