//
//  CustomerRequesData.swift
//  App
//
//  Created by Sötnos on 25.1.2020.
//

import Foundation
import Vapor


/**
 # CustomerObject
 - firstname: String
 - lastname : String
 - email : String
 */
struct CustomerObject : Content{
    let firstname: String
    let lastname : String
    let email : String
}
