//
//  Language.swift
//  App
//
//  Created by Sötnos on 18.1.2020.
//

import Foundation
import Vapor
import FluentPostgreSQL

// MARK: - Class Represents the Language Model

/**
 # Language
  Class contains properties to hold:
 - ID: Optional id property that stores the ID of the model assigned by the database when it's saved.
 - language: The name of the language
 - code: The language code
 */
final class Language : Codable {
    
    var id : UUID?
    var language : String
    var code : String
    
    // Inits
    init(language: String, code: String) {
        self.language = language
        self.code = code

    }
    
}

// MARK: - Extensions

extension Language: PostgreSQLUUIDModel {} // Conform the Fluent's Model
extension Language : Content {} // Conform Content
extension Language : Parameter {} // Conform Parameter
extension Language: Migration {} // Conform Migrations


// MARK: - Relationships

extension Language {
    
    // Children
    

    
    // Siblings
    var products : Siblings<Language, Product, ProductLanguagePivot> { return siblings()}
    
    var categories: Siblings<Language, Category, CategoryLanguagePivot> {return siblings()}
    
    // Parents
                   
    
}
