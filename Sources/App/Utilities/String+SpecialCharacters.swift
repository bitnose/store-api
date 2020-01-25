//
//  String+SpecialCharacters.swift
//  App
//
//  Created by Sötnos on 25.1.2020.
//

import Foundation


extension String {
    /*
     # Extension for the String which returns a boolean value
     - Value is true if the string contains numbers or special characters (except -)
     
     1. Allowed characters.
     2. Test if the string contains any other characters than the allowed characters.
     3. Returns a Boolean value indicating whether the specified object matches the conditions specified by the predicate.
     */
   var containsSpecialCharactersOrNumbers: Bool {
    
      let regex = ".*[^^a-zA-ZÀ-ÿ-][^^a-zA-ZÀ-ÿ-].*" // 1
      let testString = NSPredicate(format:"SELF MATCHES %@", regex) // 2
      return testString.evaluate(with: self) // 3
   }
}
