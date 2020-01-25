//
//  Customer.swift
//  App
//
//  Created by Sötnos on 19.1.2020.
//

import Foundation
import Vapor
import FluentPostgreSQL

// MARK: - Class Represents the Customer Model

/**
 # Class contains properties to hold:
 This model contains information of the receiver of the order.
 - ID : Optional id property that stores the ID of the model assigned by the database when it's saved.
 - firstname: The firstname of the customer
 - lastname :The lastname of the customer
 - email : The email address of the customer
 - orderID : The order of the customer
 - userID : The user
 */

final class Customer : Codable {
    
    var id : UUID?
    var firstname: String
    var lastname : String
    var email : String
    var placedOrderID : PlacedOrder.ID
    var userID : User.ID
    
    // Inits
    init(firstname: String, lastname: String, email: String, placedOrderID : PlacedOrder.ID, userID: User.ID) {
        self.firstname = firstname
        self.lastname = lastname
        self.email = email
        self.placedOrderID = placedOrderID
        self.userID = userID
        
    }
}

// MARK: - Extensions

extension Customer: PostgreSQLUUIDModel {} // Conform the Fluent's Model
extension Customer : Content {} // Conform Content
extension Customer : Parameter {} // Conform Parameter
extension Customer: Migration {} // Conform Migrations


// MARK: - Relationships

extension Customer {
    
    // Parents
    var placedOrder : Parent<Customer, PlacedOrder> {return parent(\.placedOrderID)}
    
    var user : Parent<Customer, User> {return parent(\.userID)}
      
    
}

// MARK: - STATIC FUNCTIONS

extension Customer {
    
    /**
     # Create and save customer model with the given data
     
     - parameters:
        - req: Used to fetch a database connection.
        - customer: The provided data what we use to create a Customer
        - to user: The unique identifier of the user who created the data
        - to order: The unique identifier of the placed order
     - throws: Throws an abort error.
     - returns: Future Result of Customer
     
     1. Create an instance of Customer with the given data.
     2. Save the model.
     */
    static func createCustomer(_ req: Request, customer: CustomerObject, to user: User.ID, to order: PlacedOrder.ID) throws -> Future<Customer> {
        
        return Customer(firstname: customer.firstname, lastname: customer.lastname, email: customer.email, placedOrderID: order, userID: user) // 1
            .save(on: req) // 2
    }


    
}
