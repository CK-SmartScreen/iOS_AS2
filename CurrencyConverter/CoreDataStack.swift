//
//  CoreDataStack.swift
//  Rates
//
//  Created by Xavier Francis on 31/10/17.
//  Copyright © 2017 CM+XF. All rights reserved.
//

import Foundation
import CoreData

func createMainContext(completion: @escaping (NSPersistentContainer) -> Void) {
    let container = NSPersistentContainer(name: "CurrencyModel")
//    print(container.persistentStoreDescriptions.first?.url! as Any) // Get SQLite DB location on disk.
    
    // Asynchronous
    container.loadPersistentStores(completionHandler: {
        persistentStoreDescription, error in
        
        guard error == nil else { fatalError("Failed to load store: \(String(describing: error))") }
        
        DispatchQueue.main.async {
            completion(container)
        }
    })
}
