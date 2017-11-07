//
//  AppDelegate.swift
//  CurrencyConverter
//
//  Created by CK on 31/10/17.
//  Copyright © 2017 Chunkai Meng. All rights reserved.
//

import UIKit
import CoreData

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    var managedObjectContext: NSManagedObjectContext!
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Initialize CoreData ManagedObjectContext,
        // seed the DB if needed,
        // and update exchange rates.
        createMainContext {
            container in
            
            let mainContext = container.viewContext
            self.managedObjectContext = mainContext
            self.seedDatabase()
            self.update()
        }
        
        // Override point for customization after application launch.
        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        // Saves changes in the application's managed object context before the application terminates.
    }
    
    
    // MARK: Exchange rate data.
    
    // Seeds the database with initial data if the DB is empty.
    func seedDatabase() {
        // If data exists in DB, there's no need to seed.
        do {
            let fetch = NSFetchRequest<NSFetchRequestResult>(entityName: Currency.entityName)
            let res = try managedObjectContext!.fetch(fetch)
            
            if res.count > 0 { return }
        } catch {
            print("Something went wrong: \(error)")
        }
        
        // Get the JSON file from disk.
        if let seedFile = Bundle.main.path(forResource: "SeedData", ofType: "json") {
            do {
                // Parse contents.
                let seedData = try NSData(contentsOfFile: seedFile, options: NSData.ReadingOptions.mappedIfSafe)
                let decoder = JSONDecoder()
                let currencies = try decoder.decode([CurrencyCodable].self, from: seedData as Data)
                
                // Iterate over each...
                for currency in currencies {
                    let currencyEntity = NSEntityDescription.insertNewObject(forEntityName: Currency.entityName, into: managedObjectContext) as! Currency
                    currencyEntity.code = currency.code
                    currencyEntity.name = currency.name
                    currencyEntity.rate = NSNumber(value: currency.rate)
                    currencyEntity.symbol = currency.symbol
                    
                    // and persist to DB.
                    do {
                        try managedObjectContext.save()
                    } catch {
                        print("Something went wrong: \(error)")
                        managedObjectContext.rollback()
                    }
                }
            } catch {
                 fatalError("Error reading seed JSON: \(error)")
            }
        }
    }
    
    // Updates to latest exchange rates.
    func update() {
        func hideActivityIndicator() {
            DispatchQueue.main.async {
                UIApplication.shared.isNetworkActivityIndicatorVisible = false
            }
        }
        
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        
        // Get exchange rate JSON data from fixer.io API.
        DispatchQueue.global(qos: .default).async {
            let url = URL(string: "https://api.fixer.io/latest?base=USD")
            let task = URLSession.shared.dataTask(with: url!, completionHandler: { (data, response, error) in
                guard data != nil else {
                    print("Error fetching exchange rates")
                    hideActivityIndicator()
                    return
                }
                
                // Parse JSON.
                do {
                    if let json = try JSONSerialization.jsonObject(with: data!) as? [String: Any] {
                        if let rates = json["rates"] as? [String: Float] {
                            for (code, rate) in rates {
                                // Fetch currency from DB, set the new rate, and persist to DB.
                                let predicate = NSPredicate(format: "code == %@", code)
                                let currencyRequest = NSFetchRequest<Currency>(entityName: Currency.entityName)
                                currencyRequest.predicate = predicate
                                do {
                                    let currency = try self.managedObjectContext.fetch(currencyRequest).first
                                    currency?.setValue(NSNumber(value: rate), forKey: "rate")
                                    do {
                                        try self.managedObjectContext.save()
                                        print("\(code) updated with rate: \(rate)")
                                    } catch { print("Error saving exchange rate: \(error)") }
                                } catch { print("Error reading currency: \(error)") }
                            }
                        }
                    }
                } catch {
                    print("Error deserializing JSON: \(error)")
                }
                
                hideActivityIndicator()
            })
            
            task.resume()
        }
    }

}
