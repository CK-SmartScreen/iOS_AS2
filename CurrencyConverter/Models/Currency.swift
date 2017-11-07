//
//  Currency.swift
//  Rates
//
//  Created by Xavier Francis on 31/10/17.
//  Copyright © 2017 CM+XF. All rights reserved.
//

import Foundation
import CoreData

class Currency: NSManagedObject {
    
    static var entityName: String { return "Currency" }
    @NSManaged dynamic var code: String!
    @NSManaged dynamic var name: String!
    @NSManaged dynamic var decimals: NSNumber!
    @NSManaged dynamic var rate: NSNumber!
    @NSManaged dynamic var symbol: String!
    @NSManaged dynamic var symbolPosition: String!

}

// Swift 4 feature that allows for easy decomposition of JSON.
// This is used for seeding the DB.
struct CurrencyCodable : Codable {
    
    var code: String
    var name: String
    var rate: Double
    var symbol: String?

}
