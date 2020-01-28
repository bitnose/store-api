//
//  HostMiddleware.swift
//  App
//
//  Created by Sötnos on 28.1.2020.
//

import Foundation
import Vapor

/// # Custom HostMiddleware looks if a user has admin or host access: If not it sends a forbidden response.
/// 1. Called with each Request that passes through this middleware.
/// 2. Get the user from the request.
/// 3. Looks if a user has admin or host access: If not, throw an Abort with forbidden response.
/// 4. Chain to the next middleware normally.

final class HostMiddleware : Middleware {
    
    func respond(to request: Request, chainingTo next: Responder) throws -> EventLoopFuture<Response> { // 1
        let requestUser = try request.requireAuthenticated(User.self) // 2
        guard requestUser.userType == .admin || requestUser.userType == .host else { return request.future(error: Abort(.forbidden))} // 3
        return try next.respond(to: request) // 4
    }
}

