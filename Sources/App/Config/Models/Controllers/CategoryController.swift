//
//  CategoryController.swift
//  App
//
//  Created by Sötnos on 19.1.2020.
//

import Foundation
import Vapor
import Fluent
import Authentication

// Define different route handlers. To access routes you must register handlers with the router. A simple way to do this is to call the functions inside your controller from routes.swift
struct CategoryController : RouteCollection {
  
     // MARK: - Route Registration
     func boot(router: Router) throws {
        
        // Grouped Routes (/api/categories)
        let categoriesRoute = router.grouped("categories")

        
        // MARK: - Route Groups
        
        /*
         1. Create a TokenAuthenticationMiddleware for User. This uses BearerAuthenticationMiddleware to extract the bearer token out of the request. The middleware then converts this token into a logged in user. Create a
         2. Create a GuardAuthMiddleware. Error to throw if the type is not authenticated.
         3. Create a route group using tokenAuthMiddleware and guardAuthMiddleware to protect the route for creating a user with token authentication.
         4. Create an adminGroup for routes which requires tha the user has an admin access.
        */
        let tokenAuthMiddleware = User.tokenAuthMiddleware() // 1
        let guardAuthMiddleware = User.guardAuthMiddleware() // 2
        let tokenAuthGroup = categoriesRoute.grouped(tokenAuthMiddleware, guardAuthMiddleware) // 3
        let adminGroup = tokenAuthGroup.grouped(AdminMiddleware()) // 4
        
        /*
         1. Get Request : Get the Category model with the given parametere.
         2. Post Request : Post Model to create a new category.
         3. Post Request : Post Model to create new translations for the category.
         4. Get Request : Get Category and its translations with the given language ID.
         5. Get Request : Get all the categories and its translations with the given language ID.
         6. Get Request : Get all the products translations from the category with the given language ID.
         7. Post Request : Add Product to the Category.
        */
        tokenAuthGroup.get(Category.parameter, use: getHandler) // 1
        adminGroup.post(use: createHandler) // 2
        adminGroup.post(CategoryLanguagePivot.self, at: "translations", use: createTranslationsHandler) // 3
        categoriesRoute.get(Category.parameter, UUID.parameter, use: getCategoryTranslationsHandler) // 4
        categoriesRoute.get("all", UUID.parameter, use: getAllCategoryTranslationsHandler) // 5
        categoriesRoute.get(Category.parameter, UUID.parameter, "products", use: getAllProductsWithTranslationsFromCategoryHandler) // 6
        adminGroup.post(Category.parameter, Product.parameter, use: addProductToCategoryHandler) // 7
    }

    // MARK: - Route Handlers
    
    /**
     # Create Category Handler - Creates a new user with the given data.
        
     - parameters:
        - data: Category Object
        - req: Request
     - throws:  CryptoError
     - Returns: Future Product

     1. Save the model on the database.
    */
    func createHandler(_ req: Request) throws -> Future<Category> {
       return Category().save(on: req) // 1
     }
    
    /**
     # Get Category Handler - Retrieves the individual Category with the given ID
         
     - parameters:
        - req: Request
     - throws: Error
     - Returns: Future Category
     
     1. Extract and return the Category from the request parameter.
     */
    func getHandler(_ req: Request) throws -> Future<Category> {
      return try req.parameters.next(Category.self)  // 1.
    }
    
    /**
    # Create Translation for the Category Handler
      
      - parameters:
         - req: Request
      - throws: Error
      - Returns: Future CategoryLanguagePivot

     1. Extract and return the product from the request parameter.
    */
    func createTranslationsHandler(_ req: Request, data: CategoryLanguagePivot) throws -> Future<CategoryLanguagePivot> {
        return data.save(on: req) // 1
    }

    /**
     # Get the Translation of Category - Retrieves the translation in the provided language ID and in the provided categoryID.
      
      - parameters:
         - req: Request
      - throws: Error
      - Returns: Future ProductWithTranslation

     1. Extract and return the category from the request parameter and unwrap the returned future.
     2. Extract the UUID from the parameter.
     3. Make a query to the database table
     4. FIlter products based on their categoryID property.
     5. Filter products  based on languageID property. Get the first (and the only) matching result.
     6. Unwrap an Optional value contained inside a Future’s expectation. If the optional resolves to nil (.none), the supplied error will be thrown instead. Otherwise return the found mdoel.
    */
    func getCategoryTranslationsHandler(_ req: Request) throws -> Future<CategoryLanguagePivot> {
        
        return try req.parameters.next(Category.self).flatMap(to: CategoryLanguagePivot.self) { category in // 1
            
            let languageID = try req.parameters.next(UUID.self) // 2
            
            return try CategoryLanguagePivot.query(on: req) // 3
                .filter(\.categoryID == category.requireID()) // 4
                .filter(\.languageID == languageID).first() // 5
                .unwrap(or: Abort(.notFound)) // 6
                
        }
    }
    
    /**
     # Get all the categories in specific language handler - Retrieves all the CategoryLanguagePivot in the provided language ID
     
     - parameters:
        - req: Request
     - throws: Error
     - Returns: Future [CategoryLanguagePivot]

     1. Extract the UUID from the parameter.
     2. Make a query to the database table
     3. FIlter products based on their languageID property.
     4. Sort the results in ascending order based on the vcategory property. Return all the matching results.
    */
    func getAllCategoryTranslationsHandler(_ req: Request) throws -> Future<[CategoryLanguagePivot]> {
         
        let languageID = try req.parameters.next(UUID.self) // 1
        return CategoryLanguagePivot.query(on: req) // 2
            .filter(\.languageID == languageID) // 3
            .sort(\CategoryLanguagePivot.category, .ascending).all() // 4
            
    }
    
    /**
     # Get all the products objects with the translation using the provided catogoryID and the provided languageID
     
     - parameters:
        - req: Request
     - throws: Error
     - Returns: Future [ProductWithTranslation]

     1. Extract the Category  from the parameter and unwrap the future.
     2. Extract the language ID
     3. Use the computed property to get the products  from the category. Then use query to query products.
     4. Join another table to the query through the shared id property of the two models.
     5. Filter models using the provided languageID
     6. Sort the results in ascending order based on the productName property.
     7. Decode also the another model which was joined to the query. The query will return an array of tuples.
     8. Return all the matching results and unwrap the returned futures.
     9. Return an arrray of ProductWithTranslation models by mapping the returned data and 10. creating an  ProductWithTranslation objects using the fetched data.
    */
    func getAllProductsWithTranslationsFromCategoryHandler(_ req: Request) throws -> Future<[ProductWithTranslation]> {
           
        return try req.parameters.next(Category.self).flatMap(to: [ProductWithTranslation].self) { category in // 1
                      
            let languageID = try req.parameters.next(UUID.self) // 2
            
            return try category.products.query(on: req) // 3
                .join(\ProductLanguagePivot.productID, to: \Product.id) // 4
                .filter(\ProductLanguagePivot.languageID == languageID) // 5
                .sort(\ProductLanguagePivot.productName, .ascending) // 6
                .alsoDecode(ProductLanguagePivot.self) // 7
                .all().map(to: [ProductWithTranslation].self) { pairs in // 8
                
                return pairs.map { product, translation -> ProductWithTranslation in // 9
                
                    ProductWithTranslation(id: product.id, price: product.price, productTranslation: translation) // 10
                }
            }
        }
    }
    
    /**
     # Add the product to the category.
       
       - parameters:
          - req: Request
       - throws: Error
       - Returns: HTTPStatus

     1. Extract and return the Category  and Product from the request parameter. Unwrap the futures.
     2. Add product to categories and transform to HttpStatus.
     */
    func addProductToCategoryHandler(_ req: Request) throws -> Future<HTTPStatus> {
          return try flatMap(to: HTTPStatus.self, req.parameters.next(Category.self),  req.parameters.next(Product.self)) { category, product in // 1
              
            return category.products.attach(product, on: req).transform(to: .created) // 2
          }
      }
}
