//
//  PlacedOrder.swift
//  App
//
//  Created by Sötnos on 19.1.2020.
//


import Foundation
import Vapor
import FluentPostgreSQL

// MARK: - Class Represents the PlacedOrder Model

/**

 Class contains properties to hold:
 - ID : Optional id property that stores the ID of the model assigned by the database when it's saved.
 - totalPrice : Total price of the order
 - totalTaxes : Total taxes of the fee
 - deliveryFee: Delivery fee
 - status: order status
 - deletedAt: A property for Fluent to store the date you performed a soft delete on the model.
 - createdAt: A property for Fluent to store the date object was created.
 - updatedAt: A property for Fluent to store the date object was updated.
 - userID : The user who created the order
 - isHomeDelivery: Boolean value which determines whether the shipping type is a home delivery or a pick-upPla */

final class PlacedOrder : Codable {
    
    var id : UUID?
    var totalPrice : Float 
    var totalTaxes: Float
    var deliveryFee: Float
    var orderStatus: OrderStatus
    var deletedAt: Date?
    var createdAt: Date?
    var updatedAt: Date?
    var userID : User.ID
    var isHomeDelivery: Bool?

    // Inits with default values 
    init(totalPrice: Float = 0, totalTaxes: Float = 0, deliveryFee: Float = 0, orderStatus: OrderStatus = .shoppingCart, userID : User.ID, isHomeDelivery: Bool? = nil) {
        
        self.totalPrice = totalPrice
        self.totalTaxes = totalTaxes
        self.deliveryFee = deliveryFee
        self.orderStatus = orderStatus
        self.userID = userID
        self.isHomeDelivery = isHomeDelivery
    }
    
    
    // Add to new key path that Fluent checks when you call delete(on:). If the key path exists, Fluent sets the current date on the property and saves the updated model. Otherwise, it deletes the model from the database
    static var deletedAtKey : TimestampKey? = \.deletedAt
    // Fluent will automatically manage these records
    static var createdAtKey: TimestampKey? = \.createdAt
    static var updatedAtKey : TimestampKey? = \.updatedAt

    

}

// MARK: - Extensions

extension PlacedOrder: PostgreSQLUUIDModel {} // Conform the Fluent's Model
extension PlacedOrder : Content {} // Conform Content
extension PlacedOrder : Parameter {} // Conform Parameter
extension PlacedOrder: Migration {} // Conform Migrations


// MARK: - Relationships

extension PlacedOrder {
    
    // MARK: - Children
    var customerData : Children<PlacedOrder, Customer> {return children(\.userID)}

    // MARK: - Siblings
    var products: Siblings<PlacedOrder, Product, OrderItemPivot> { return siblings()}
    
    // Max two addresses in one order
    var addresses: Siblings<PlacedOrder, Address, OrderAddressPivot> {return siblings()}
    
    // Each order has max. one instance of homeDelivery
    var homeDelivery: Siblings<PlacedOrder, HomeDelivery, HomeDeliveryOrder> {return siblings()}
    
    // Each order has max. one instance of pickUp
    var pickUp: Siblings<PlacedOrder, PickUp, PickUpOrder> {return siblings()}
    
    //MARK: - Parents
    
    var user : Parent<PlacedOrder, User> { return parent(\.userID)}
    
}

