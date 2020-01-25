//
//  Address.swift
//  App
//
//  Created by Sötnos on 19.1.2020.
//


import Foundation
import Vapor
import FluentPostgreSQL

// MARK: - Class Represents the Address Model

/**

 Class contains properties to hold:
 - ID : Optional id property that stores the ID of the model assigned by the database when it's saved.
 - street: Street name
 - postalcode: Postal code
 - city : City
 - country : country
 - deletedAt: A property for Fluent to store the date you performed a soft delete on the model.
 - createdAt: A property for Fluent to store the date object was created.
 - updatedAt: A property for Fluent to store the date object was updated.
 */

final class Address : Codable {
    
    var id : UUID?
    var street : String
    var postalcode: Int
    var city: String
    var country : String
    var deletedAt: Date?
    var createdAt: Date?
    var updatedAt: Date?

    init(street: String, postalcode: Int, city: String, country: String) {
        
        self.street = street
        self.postalcode = postalcode
        self.city = city
        self.country = country
    }
    
    
    // Add to new key path that Fluent checks when you call delete(on:). If the key path exists, Fluent sets the current date on the property and saves the updated model. Otherwise, it deletes the model from the database
    static var deletedAtKey : TimestampKey? = \.deletedAt
    // Fluent will automatically manage these records
    static var createdAtKey: TimestampKey? = \.createdAt
    static var updatedAtKey : TimestampKey? = \.updatedAt

    

}

// MARK: - Extensions

extension Address: PostgreSQLUUIDModel {} // Conform the Fluent's Model
extension Address : Content {} // Conform Content
extension Address : Parameter {} // Conform Parameter
extension Address: Migration {} // Conform Migrations


// MARK: - Relationships

extension Address {
    
    
    var pickUpStop: Children<Address, PickUpStop> {return children(\.addressID)}
    // Siblings
    var residents: Siblings<Address, User, UserAddressPivot> { return siblings()}

    var placedOrders: Siblings<Address, PlacedOrder, OrderAddressPivot> {return siblings()}

    
    // Parents
    
                   
    
}
