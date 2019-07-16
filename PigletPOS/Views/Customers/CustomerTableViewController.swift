//
//  CustomerTableViewController.swift
//  PigletPOS
//
//  Created by Shilo Kohelet on 15/07/2019.
//  Copyright © 2019 Shilo Kohelet. All rights reserved.
//

import UIKit

class CustomerTableViewController: UITableViewController {
    
    @IBOutlet weak var searchBarTest: UIBarButtonItem!
    
    @IBAction func newCustomerBtn(_ sender: Any) {
    }
    @IBAction func searchBarTest1(_ sender: UIBarButtonItem) {
        searchController.isActive = true
        
    }
    
    let searchController = UISearchController(searchResultsController: nil)
    var customers = [Customer]()
    var filterCustomers = [Customer]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.tableFooterView = UIView()
        
        initSearchController()
        
        socket?.on("CustomerSearchReplay") { (data, ack) in
            let jsonData = try! JSONSerialization.data(withJSONObject: data[0], options: [])
            let customerSource = try! JSONDecoder().decode(CustomerSource.self, from: jsonData)
            self.filterCustomers = customerSource.customers
            self.tableView.reloadData()
        }
        
    }
    
    func initSearchController(){
        searchController.delegate = self
        searchController.searchResultsUpdater = self
        searchController.searchBar.delegate = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Search Customer"
        navigationItem.searchController = searchController

        definesPresentationContext = true
        
    }
    
    // MARK: - Table view data source
    

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if isFiltering(){
            return filterCustomers.count
        }
        return customers.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "customerCell")!
        let customer : Customer

        if isFiltering(){
            customer = filterCustomers[indexPath.item]
        }else{
            customer = customers[indexPath.item]
        }
        guard let firstName = customer.firstName, let lastName = customer.lastName else { return cell}
        cell.textLabel?.text = "\(firstName) \(lastName)"
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if isFiltering(){
            
        }
    }
    
    
    
}

extension CustomerTableViewController: UISearchResultsUpdating, UISearchBarDelegate, UISearchControllerDelegate{
    func updateSearchResults(for searchController: UISearchController) {
        filterContentForSearchBar(searchController.searchBar.text!)
    }
    func searchBarIsEmpty() -> Bool{
        return searchController.searchBar.text?.isEmpty ?? true
    }
    
    func isFiltering() -> Bool {
        return searchController.isActive && !searchBarIsEmpty()
    }
    
    func filterContentForSearchBar(_ searchBar: String, scope: String = "All"){
        socket.emit("CustomerSearch", with: [searchBar])
        tableView.reloadData()
    }
    
    func presentSearchController(_ searchController: UISearchController) {
        searchController.searchBar.becomeFirstResponder()
    }
    
    
    
    
}
