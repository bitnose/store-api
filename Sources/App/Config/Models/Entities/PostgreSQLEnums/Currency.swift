//
//  Currency.swift
//  App
//
//  Created by Sötnos on 31.1.2020.
//

import Foundation
import FluentPostgreSQL
import Vapor

/**
 # Currency
 A new enum string type to the Price model to represent currencies
 FluentPostgreSQL to expose the required types for the enum.
 Create a new String enum type, The type conformances allow Fluent to use the type in the database and prepare the database correctly. The type must be a String enum to conform to Codable.

    - CHF
    - EUR
 
*/
enum Currency: String, PostgreSQLEnum, PostgreSQLMigration, Content {
    case CHF
    case EUR
}
