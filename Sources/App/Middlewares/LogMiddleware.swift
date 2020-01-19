//
//  LogMiddleware.swift
//  App
//
//  Created by Sötnos on 19.1.2020.
//

import Foundation
import Vapor

//MARK: - Logs Response times for incoming requests

/**
 # LogMiddleware

 Logs incoming requests and displays the following information for each request:
 - Request Method
 - Request Path
 - Response Status
 - How long it took to generate the response
 
 1. Create a stored property to hold a logger.
 2. Implement the Middleware protocol requirement.
 3. Send the request's description to the Logger as an informational log.
 4. Forward the incoming request to the next responder.
 5. Allow LogMiddleware to be registered as a service in your application.
 6. Initiialize an instance of LogMiddleware, using the container to create the necessary Logger.
 */
final class LogMiddleware: Middleware {
    
    // 1
    let logger: Logger
    
    init(logger: Logger) {
        self.logger = logger
    }
    // 2
    func respond(to req: Request, chainingTo next: Responder) throws -> Future<Response> {
        
        // start time
        let start = Date()
        // map the future result to access the Response object
        return try next.respond(to: req).map { res in
            // Call log
            self.log(res, start: start, for: req)
            return res
            
        } // 4
    }
    
    // Logs the response for an incoming request using the response start date
    func log(_ res: Response, start: Date, for req: Request) {
        
        let regInfo = "\(req.http.method.string) \(req.http.url.path)"
        let resInfo = "\(res.http.status.code)" + "\(res.http.status.reasonPhrase)"
        
        let time = Date().timeIntervalSince(start)
        // Log the information to the string
        logger.info("\(regInfo) -> \(resInfo) [\(time)]")
    }
}

// 5
extension LogMiddleware: ServiceType {
    static func makeService(for container: Container) throws -> LogMiddleware {
        return try .init(logger: container.make()) // 6
    }
}


