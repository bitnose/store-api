//
//  Package.swift
//  App
//
//  Created by Sötnos on 19.1.2020.
//


import Foundation
import Vapor
import FluentPostgreSQL

// MARK: - Class Represents the Package Model

/**

 Class contains properties to hold:
 - ID : Optional id property that stores the ID of the model assigned by the database when it's saved.
 - deliveryDate : The date of the pick up
 - deletedAt: A property for Fluent to store the date you performed a soft delete on the model.
 - createdAt: A property for Fluent to store the date object was created.
 - updatedAt: A property for Fluent to store the date object was updated.
 - timePeriod: The time period of the pick up
 - price: The selling price of the pick up.
 - limit: Limit how many pick ups one pick up can have
 - cityID: The city where the home delivery is available
 - open: Boolean value which tells wheter the HomeDelivery is open / closed for new orders.
 */

final class HomeDelivery : Codable {
    
    var id : UUID?
    var deliveryDate: Date
    var deletedAt: Date?
    var createdAt: Date?
    var updatedAt: Date?
    var timePeriod: TimePeriod
    var limit: Int
    var cityID : City.ID
    var open: Bool
    
    
    // Init User
    init(deliveryDate: Date, timePeriod: TimePeriod, limit: Int, cityID: City.ID, open: Bool) {
        self.deliveryDate = deliveryDate
        self.timePeriod = timePeriod
        self.limit = limit
        self.cityID = cityID
        self.open = open

    }
    
    // Add to new key path that Fluent checks when you call delete(on:). If the key path exists, Fluent sets the current date on the property and saves the updated model. Otherwise, it deletes the model from the database
    static var deletedAtKey : TimestampKey? = \.deletedAt
    // Fluent will automatically manage these records
    static var createdAtKey: TimestampKey? = \.createdAt
    static var updatedAtKey : TimestampKey? = \.updatedAt

    

}

// MARK: - Extensions

extension HomeDelivery: PostgreSQLUUIDModel {} // Conform the Fluent's Model
extension HomeDelivery : Content {} // Conform Content
extension HomeDelivery : Parameter {} // Conform Parameter
extension HomeDelivery: Migration {} // Conform Migrations


// MARK: - Relationships

extension HomeDelivery {
    
    //Parent
    
    var city: Parent<HomeDelivery, City> {return parent(\.cityID)}
    
    // Children
    var prices : Children<HomeDelivery, Price> {return children(\.homeDeliveryID)}
    
    
    // Siblings
    var ordersToDeliver: Siblings<HomeDelivery, PlacedOrder, HomeDeliveryOrder> {return siblings()}

  
    
}
