//
//  String+Case.swift
//  PL2
//
//  Created by Lekha Mishra on 11/24/17.
//  Copyright © 2017 Praveen kumar. All rights reserved.
//

import Foundation
extension String {
    func capitalizingFirstLetter() -> String {
        let first = String(characters.prefix(1)).capitalized
        let other = String(characters.dropFirst())
        return first + other
    }
    
    mutating func capitalizeFirstLetter() {
        self = self.capitalizingFirstLetter()
    }
    
    var localized: String {
        return NSLocalizedString(self, tableName: nil, bundle: Bundle.main, value: "", comment: "")
    }
}
