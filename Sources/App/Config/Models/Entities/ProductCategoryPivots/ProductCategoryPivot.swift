//
//  CategoryProductPivot.swift
//  App
//
//  Created by Sötnos on 19.1.2020.
//

import Foundation
import Vapor
import FluentPostgreSQL

// MARK: - Class Represents the ProductCategoryPivot Moddel

/*
 1. Define a new object that conforms to PostgreSQLUUIDPivot. This is a helper protocol on top of Fluent's Pivot protocol.
 2. Define an id for the model. Note this is a UUID type so you must import the Foundationn module in the file.
 3. Define two properties to link to the IDs of Objects. This is what holds the relationship.
 4. Define Left and Right types required by Pivot. This tells Fluent what the two models in the relationship are.
 5. Tell Fluent the key path of the two ID properties for each side of the relationship.
 6. Implement the throwing initializer, as required by ModifiablePivot.
 7. Conform to Migration so Fluent can set up the table.
 8. Confrom to Pivot.
*/


// # Contains the Pivot model to manage the sibling relationship
  
 
final class ProductCategoryPivot: PostgreSQLUUIDPivot { // 1
    // 2
    var id : UUID?
    // 3
    var categoryID : Category.ID
    var productID : Product.ID
    // 5
    typealias Left = Category
    typealias Right = Product
    // 6
    static let leftIDKey: LeftIDKey = \.categoryID
    static let rightIDKey: RightIDKey = \.productID
    
    
    // 7 Init
    init(_ categoryID: Category, _ productID: Product) throws {
        
        self.categoryID = try categoryID.requireID()
        self.productID = try productID.requireID()
    

    }
    
}

extension ProductCategoryPivot: ModifiablePivot {} // 8


// MARK: - Foreign Ket Constraints

/*
 Foreign Key Constraints
 1. Conform the Pivot to Migration.
 2. Implement prepare(on:) as defined by Migration. This overrides the default implementation.
 3. Create the table for pivot model in the database.
 4. Use addProperties(to:) to add all the fields to the database.
 5. Add a reference between the id property on pivot model and the id property on another model. This sets up the foreign key constraint. .cascade sets a cascade schema reference action when you delete the model. This means that the relationship is automatically removed instead of an error being thrown.
 6. Add a reference between the id property on pivot model and the id property on another model. This sets up the foreign key constraint. Also set the schema reference action for deletion when deleting the model.
 */

extension ProductCategoryPivot: Migration {// 1
    
    static func prepare(on connection: PostgreSQLConnection) -> Future<Void> { // 2
        return Database.create(self, on: connection) { builder in // 3
            try addProperties(to: builder) // 4
            builder.reference(from: \.categoryID, to: \Category.id, onDelete: ._cascade) // 5
            builder.reference(from: \.productID, to: \Product.id, onDelete: .cascade) // 6
        }
    }
    
}

