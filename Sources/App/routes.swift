import Vapor

/// Register your application's routes here.
public func routes(_ router: Router) throws {
    // Basic "It works" example
   
     // Basic "It works" example
     
     /*
      Register Controllers
      1. Create a new controller object
      2. Register the new type with the router to ensure the controller's router get registered
      */
     
     let userController = UserController() // 1
     try router.register(collection: userController) // 2
     
}
