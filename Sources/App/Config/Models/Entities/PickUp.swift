//
//  PickUp.swift
//  App
//
//  Created by Sötnos on 19.1.2020.
//

import Foundation
import Vapor
import FluentPostgreSQL

// MARK: - Class Represents the PickUp Model

/**

 Class contains properties to hold:
 - ID : Optional id property that stores the ID of the model assigned by the database when it's saved.
 - deliveryDate : The date of the pick up
 - deletedAt: A property for Fluent to store the date you performed a soft delete on the model.
 - createdAt: A property for Fluent to store the date object was created.
 - updatedAt: A property for Fluent to store the date object was updated.
 - timePeriod: The time period of the pick up
 - price: The selling price of the pick up.
 - pickUpStopID: The pick up stop ID (parent)
 - limit: Limit how many pick ups one pick up can have
 - open: Boolean value which tells wheter the pickUp is open / closed for new orders.
 */

final class PickUp : Codable {
    
    var id : UUID?
    var deliveryDate: String
    var deletedAt: Date?
    var createdAt: Date?
    var updatedAt: Date?
    var timePeriod: TimePeriod
    var price : Float
    var pickUpStopID : PickUpStop.ID
    var limit: Int
    var open: Bool
     
    // Init User
    init(deliveryDate: String, timePeriod: TimePeriod, price: Float, pickUpStopID: PickUpStop.ID, limit: Int, open: Bool) {
        self.deliveryDate = deliveryDate
        self.timePeriod = timePeriod
        self.price = price
        self.pickUpStopID = pickUpStopID
        self.limit = limit
        self.open = open
    }
    // Add to new key path that Fluent checks when you call delete(on:). If the key path exists, Fluent sets the current date on the property and saves the updated model. Otherwise, it deletes the model from the database
    static var deletedAtKey : TimestampKey? = \.deletedAt
    // Fluent will automatically manage these records
    static var createdAtKey: TimestampKey? = \.createdAt
    static var updatedAtKey : TimestampKey? = \.updatedAt
}

// MARK: - Extensions
extension PickUp: PostgreSQLUUIDModel {} // Conform the Fluent's Model
extension PickUp : Content {} // Conform Content
extension PickUp : Parameter {} // Conform Parameter
extension PickUp: Migration {} // Conform Migrations


// MARK: - Relationships
extension PickUp {
    
    // Children

    // Siblings
    var orders: Siblings<PickUp, PlacedOrder, PickUpOrder> {return siblings()}

    // Parents
    var pickUpStop: Parent<PickUp, PickUpStop> {return parent(\.pickUpStopID)}    
}
