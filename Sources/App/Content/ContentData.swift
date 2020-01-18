//
//  ContentData.swift
//  App
//
//  Created by Sötnos on 18.1.2020.
//

import Foundation
import Vapor
// MARK: - UserController

/// # Datatype which contains user credentials
/// - username : String
/// - password : String

struct LoginPostData : Content {
    let username : String
    let password : String
}

/// # RegisterPostData
/// - password : String
/// - firstname : String
/// - lastname : String
/// - email : String
struct RegisterPostData : Content {
    let password : String
    let firstname : String
    let lastname : String
    let email : String
}


