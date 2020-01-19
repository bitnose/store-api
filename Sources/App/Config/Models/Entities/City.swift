//
//  City.swift
//  App
//
//  Created by Sötnos on 19.1.2020.
//


import Vapor
import Foundation
import FluentPostgreSQL

// MARK: - Class represents the City Model
//

/**
 # City Model
 
 Supported cities
 
- id : UUID
- city : The name of the city
*/
final class City : Codable {
    
    var id : UUID?
    var city : String
    
    init(city : String) {
        self.city = city
    }
}


// Conform models
// Conform the Fluent's Model
extension City: PostgreSQLUUIDModel {}
// Conform to Content and Parameter Models
extension City : Content {}
extension City : Parameter {}
extension City : Migration {}
/*
 
 Extension to Get the Relationships (Children and Siblings)
 
 1. Add a computed property to Model to get an object's(city) parent(Department). This returns Fluent’s generic Parent type.
 2. Use Fluent’s parent(_:) function to retrieve the parent.
 3. Add a computed property to Model to get an object's cities.
 4. Return siblings.
 */

extension City {
    
    // Children
    var homeDeliveries : Children<City, HomeDelivery> {return children(\.cityID)}
    
    var pickUpStops: Children<City, PickUpStop> {return children(\.cityID)}
}
