//
//  ContentData.swift
//  App
//
//  Created by Sötnos on 18.1.2020.
//

import Foundation
import Vapor


// MARK: - User Request Data: Datatypes for decoding requests

/// # Datatype which contains user credentials
/// - username : String
/// - password : String

struct LoginPostData : Content {
    let username : String
    let password : String
}

/// # Datatype which contains user 
/// - password : String
/// - firstname : String
/// - lastname : String
/// - email : String
struct RegisterPostData : Content {
    let password : String
    let firstname : String?
    let lastname : String?
    let email : String
}


