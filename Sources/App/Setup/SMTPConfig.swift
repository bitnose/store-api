//
//  SMTPConfig.swift
//  App
//
//  Created by Sötnos on 29.1.2020.
//

import Foundation
import Service

// MARK: - SMTPConfig struct representing an environment variables for SMTP
/**
 # SMTPConfig
 - host: The hostname
 - port: The portname to connect to the server
 - email: The email address
 - password: The password of the email address
 */
struct SMTPConfig : Service {
    
    let host : String
    let port : Int
    let email : String
    let password : String
}
