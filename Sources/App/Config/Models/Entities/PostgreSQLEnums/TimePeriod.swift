//
//  TimePeriod.swift
//  App
//
//  Created by Sötnos on 19.1.2020.
//


import Foundation
import FluentPostgreSQL
import Vapor

/**
 # TimePeriod
 A new enum string type to the home delivery and pick up to define the timeperiod of the shipping.
 FluentPostgreSQL to expose the required types for the enum.
 Create a new String enum type, The type conformances allow Fluent to use the type in the database and prepare the database correctly. The type must be a String enum to conform to Codable.

    - morning : 8-12
    - day : 12-16
    - evening : 16-20
 
*/
enum TimePeriod: String, PostgreSQLEnum, PostgreSQLMigration, Content {
    case morning
    case day
    case evening
}
