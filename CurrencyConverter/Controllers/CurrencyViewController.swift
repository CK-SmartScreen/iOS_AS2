//
//  CurrencyViewController.swift
//  CurrencyConverter
//
//  Created by Xavier Francis on 7/11/17.
//  Copyright © 2017 Chunkai Meng. All rights reserved.
//

import CoreData
import UIKit

class CurrencyViewController: UIViewController {

    @IBOutlet weak var currenciesTable: UITableView!
    
    var managedObjectContext: NSManagedObjectContext!
    var delegate: CurrencyViewControllerDelegate?
    var targetCurrency: String!
    var selectedCurrency: String!
    var tableData: Array<Currency>!

    override func viewDidLoad() {
        super.viewDidLoad()

        // Configure the TableView and CoreData context.
        currenciesTable.delegate = self
        currenciesTable.dataSource = self
        currenciesTable.rowHeight = 54.0
        if let appDelegate = UIApplication.shared.delegate as? AppDelegate {
            managedObjectContext = appDelegate.managedObjectContext
        }
        
        tableData = getCurrencies()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // Returns an array with all the currencies in the DB, sorted by name.
    func getCurrencies() -> [Currency] {
        let fetch = NSFetchRequest<NSFetchRequestResult>(entityName: Currency.entityName)
        let sortDescriptor = NSSortDescriptor(key: "name", ascending: true)
        fetch.sortDescriptors = [sortDescriptor]
        
        var result = [AnyObject]()
        do {
            result = try managedObjectContext!.fetch(fetch)
        } catch {
            print("Error fetching currencies: \(error)")
        }
        
        return result as! [Currency]
    }

}

// MARK: TableView protocol conformance.
extension CurrencyViewController: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tableData.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = self.currenciesTable.dequeueReusableCell(withIdentifier: "CurrencyCell")
        let currency = tableData[indexPath.row]
        
        cell!.textLabel!.text = currency.name!
        cell!.detailTextLabel!.text = currency.code!
        cell!.accessoryType = UITableViewCellAccessoryType.none
        
        if currency.code! == self.selectedCurrency {
            cell!.accessoryType = UITableViewCellAccessoryType.checkmark
        }
        
        return cell!
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return "Select a currency"
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if (tableData.count == 0) {
            return 0.0
        }
        return UITableViewAutomaticDimension
    }
    
    // Returns the currency data to delegate.
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let currency = tableData[indexPath.row]
        let code = currency.code!
        let symbol = currency.symbol!
        delegate?.didChangeCurrency(code: code, symbol: symbol, target: targetCurrency)
        self.dismiss(animated: true, completion: {})
    }
    
}

protocol CurrencyViewControllerDelegate {
    func didChangeCurrency(code: String, symbol: String, target: String)
}

