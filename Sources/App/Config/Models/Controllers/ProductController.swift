//
//  ProductController.swift
//  App
//
//  Created by Sötnos on 18.1.2020.
//

import Vapor
import Fluent
import Authentication

// Define different route handlers. To access routes you must register handlers with the router. A simple way to do this is to call the functions inside your controller from routes.swift
struct ProductController : RouteCollection {
  
     // MARK: - Route Registration
     func boot(router: Router) throws {
        
        // Grouped Routes (/api/products)
        let productsRoute = router.grouped("products")

        
        // MARK: - Route Groups
        
        /*
         1. Create a TokenAuthenticationMiddleware for User. This uses BearerAuthenticationMiddleware to extract the bearer token out of the request. The middleware then converts this token into a logged in user. Create a
         2. Create a GuardAuthMiddleware. Error to throw if the type is not authenticated.
         3. Create a route group using tokenAuthMiddleware and guardAuthMiddleware to protect the route for creating a user with token authentication.
         4. Create an adminGroup for routes which requires tha the user has an admin access.
        */
        let tokenAuthMiddleware = User.tokenAuthMiddleware() // 1
        let guardAuthMiddleware = User.guardAuthMiddleware() // 2
        let tokenAuthGroup = productsRoute.grouped(tokenAuthMiddleware, guardAuthMiddleware) // 3
        let adminGroup = tokenAuthGroup.grouped(AdminMiddleware()) // 4
        
        /*
         1. Get Request : Get the Product model with the given parametere.
         2. Post Request : Post Model to create a new product.
         3. Post Request : Post Model to create a new translations for the prorduct.
         4. Get Request : Get product and its translation with the given language ID.
         5. Get Request : Get all the products and its translations with the given language ID.
        */
        tokenAuthGroup.get(Product.parameter, use: getHandler) // 1
        adminGroup.post(Product.self, use: createHandler) // 2
        adminGroup.post(ProductLanguagePivot.self, at: "translations", use: createTranslations) // 3
        productsRoute.get(Product.parameter, UUID.parameter, use: getProductWithTranslations) // 4
        productsRoute.get("all", UUID.parameter, use: getAllProductsWithTranslations) // 5
    }

    // MARK: - Route Handlers
    
    /**
     # Create Product Handler - Creates a new user with the given data.
        
     - parameters:
        - data: Product Object
        - req: Request
     - throws:  CryptoError
     - Returns: Future Product

     1. Save the product on the database.
    */
    
    func createHandler(_ req: Request, data: Product) throws -> Future<Product> {
        
        return data.save(on: req) // 1.
         

     }
    

    /**
     # Get Product Handler - Retrieves the individual product with the given ID
         
     - parameters:
        - req: Request
     - throws: Error
     - Returns: Future Product
     
     1. Extract and return the product from the request parameter.
     */
    
    func getHandler(_ req: Request) throws -> Future<Product> {
      return try req.parameters.next(Product.self)  // 1.
    }
    

    /**
    # Create Translation for the Product Handler - Retrieves the individual model with the given ID
      
      - parameters:
         - req: Request
      - throws: Error
      - Returns: Future ProductLanguagePivot

     1. Extract and return the product from the request parameter.
    */
    func createTranslations(_ req: Request, data: ProductLanguagePivot) throws -> Future<ProductLanguagePivot> {
        
        return data.save(on: req) // 1
        
    }

    /**
     # Get the Translation and the Product Handler - Retrieves the individual product and its translation in the provided languaage ID
      
      - parameters:
         - req: Request
      - throws: Error
      - Returns: Future ProductWithTranslation

     1. Extract and return the product from the request parameter and unwrap the returned future.
     2. Extract the UUID from the parameter.
     3. Make a query to the database table
     4. FIlter products based on their productID property.
     5. Filter products  based on languageID property. Get the first (and the only) matching result.
     6. Unwrap an Optional value contained inside a Future’s expectation. If the optional resolves to nil (.none), the supplied error will be thrown instead.
     7. Unwrap the returned futures.
     8. Create a new instance of model with the fetched data and return it.
    */
    func getProductWithTranslations(_ req: Request) throws -> Future<ProductWithTranslation> {
        
        return try req.parameters.next(Product.self).flatMap(to: ProductWithTranslation.self) { product in // 1
            
            let languageID = try req.parameters.next(UUID.self) // 2
            
            return try ProductLanguagePivot.query(on: req) // 3
                .filter(\.productID == product.requireID()) // 4
                .filter(\.languageID == languageID).first() // 5
                .unwrap(or: Abort(.notFound)) // 6
                .map(to: ProductWithTranslation.self) { result in // 7
                
                    return try ProductWithTranslation(id: product.requireID(), price: product.price, images: product.images, productTranslation: result) // 8
                
            }
        }
    }
    
    /**
     # Get all the products with specific translations handler - Retrieves all the products with their translations in the provided languaage ID
     
     - parameters:
        - req: Request
     - throws: Error
     - Returns: Future [ProductWithTranslation]

     1. Extract the UUID from the parameter.
     2. Make a query to the database table
     3. FIlter products based on their languageID property.
     4. Join another table to the query through the shared  id property of the two models.
     5. Sort the results in ascending order based on the name property.
     6. Decode also the another model which was joined to the query. The query will return an array of tuples.
     7. Return all the matching results and unwrap the returned futures.
     8. Return an arrray of ProductWithTranslation models by mapping the returned data and  9. creating an ProductWithTranslation objects using the fetched data.
    */
    func getAllProductsWithTranslations(_ req: Request) throws -> Future<[ProductWithTranslation]> {
         
        let languageID = try req.parameters.next(UUID.self) // 1
        return ProductLanguagePivot.query(on: req) // 2
            .filter(\.languageID == languageID) // 3
            .join(\Product.id, to: ProductLanguagePivot.rightIDKey) // 4
            .sort(\ProductLanguagePivot.productName, .ascending) // 5
            .alsoDecode(Product.self) // 6
            .all().map(to: [ProductWithTranslation].self) { translationProductsPairs in // 7
            
            return translationProductsPairs.map { translation, product -> ProductWithTranslation in // 8
                
                ProductWithTranslation(id: product.id, price: product.price, images: product.images, productTranslation: translation) // 9
                
            }
        }
    }
}

