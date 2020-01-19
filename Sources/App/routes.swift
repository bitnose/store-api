import Vapor

//  Register your application's routes here.
public func routes(_ router: Router) throws {

    /*
    Register Controllers
    1. Create a new controller object
    2. Register the new type with the router to ensure the controller's router get registered
    */
     
    let userController = UserController() // 1
    try router.register(collection: userController) // 2
    
    let productController = ProductController() // 1
    try router.register(collection: productController) // 2
     
    let languageController = LanguageController() // 1
    try router.register(collection: languageController) // 2
    
    let categoryController = CategoryController() // 1
    try router.register(collection: categoryController) // 2
}
