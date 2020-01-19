//
//  Category.swift
//  App
//
//  Created by Sötnos on 19.1.2020.
//

import Foundation
import Vapor
import FluentPostgreSQL

// MARK: - Class Represents the Category Model

/**

 Class contains properties to hold:
 - ID : Optional id property that stores the ID of the model assigned by the database when it's saved.
 */

final class Category : Codable {
    
    var id : UUID?
    
    init() {
        
    }
}

// MARK: - Extensions

extension Category: PostgreSQLUUIDModel {} // Conform the Fluent's Model
extension Category : Content {} // Conform Content
extension Category : Parameter {} // Conform Parameter
extension Category: Migration {} // Conform Migrations


// MARK: - Relationships

extension Category {
    
    // Children

    
    // Siblings
    
    var products: Siblings<Category, Product, ProductCategoryPivot> { return siblings()}
    
   
    
    // Parents
                   
    
}
