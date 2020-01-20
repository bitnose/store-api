//
//  UserType.swift
//  App
//
//  Created by Sötnos on 18.1.2020.
//


import Foundation
import FluentPostgreSQL
import Vapor

/**
 # UserType 
 A new enum string type to the user to define basic user access levels (predefined sets).
 FluentPostgreSQL to expose the required types for the enum.
 Create a new String enum type, UserType. The type conformances allow Fluent to use UserType in the database and prepare the database correctly. The type must be a String enum to conform to Codable.

    - admin : Full Access (Registered Users with Admin Panel)
    - host: More than Basic Access: Alllows Users to create PickUpStops
    - standard : Basic Access (Registered Users)
    - restricted : Limited Access (Unregistered Users)
    
 
*/
enum UserType: String, PostgreSQLEnum, PostgreSQLMigration, Content {
    case admin
    case host
    case standard
    case restricted
}


