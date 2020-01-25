//
//  PickUpStop.swift
//  App
//
//  Created by Sötnos on 19.1.2020.
//


import Foundation
import Vapor
import FluentPostgreSQL

// MARK: - Class Represents the PickUpStop Model

/**

 Class contains properties to hold:
 - ID : Optional id property that stores the ID of the model assigned by the database when it's saved.
 - hostName: The name of the person who hosts the pick up stop.
 - hostNumber: The phone number of the person who hosts the pick up stop.
 - createdAt: A property for Fluent to store the date object was created.
 - updatedAt: A property for Fluent to store the date object was updated.
 - cityID : The city where the pick up stop locates / is available
 - addressID : The address of the pick up
 */

final class PickUpStop : Codable {
    
    var id : UUID?
    var createdAt: Date?
    var updatedAt: Date?
    var cityID : City.ID
    var addressID: Address.ID
    var userID: User.ID
    
    
    // Init User
    init(cityID: City.ID, addressID: Address.ID, userID: User.ID) {
        self.cityID = cityID
        self.addressID = addressID
        self.userID = userID
    }
    // Fluent will automatically manage these records
    static var createdAtKey: TimestampKey? = \.createdAt
    static var updatedAtKey : TimestampKey? = \.updatedAt
}

// MARK: - Extensions

extension PickUpStop: PostgreSQLUUIDModel {} // Conform the Fluent's Model
extension PickUpStop : Content {} // Conform Content
extension PickUpStop : Parameter {} // Conform Parameter
extension PickUpStop: Migration {} // Conform Migrations

// MARK: - Relationships

extension PickUpStop {
    
    // Parent
    var city : Parent<PickUpStop, City> {return parent(\.cityID)}
    
    // The address of the pickup stop
    var address: Parent<PickUpStop, Address> { return parent(\.addressID)}
    
    // The user who created pickup stop (=host)
    var host: Parent<PickUpStop, User> {return parent(\.userID)}
    
    // Children
    var pickUpTimes : Children<PickUpStop, PickUp> { return children (\.pickUpStopID)}
}
