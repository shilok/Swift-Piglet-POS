//
//  CustomerTableViewController.swift
//  PigletPOS
//
//  Created by Shilo Kohelet on 15/07/2019.
//  Copyright © 2019 Shilo Kohelet. All rights reserved.
//

import UIKit

class CustomerTableViewController: UITableViewController {
    let searchController = UISearchController(searchResultsController: nil)
    var customers = [Customer]()
    var filterCustomers = [Customer]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.tableFooterView = UIView()
        
        initSearchController()
        
        socket?.on("replay") { (data, ack) in
            let jsonData = try! JSONSerialization.data(withJSONObject: data[0], options: [])
            let customerSource = try! JSONDecoder().decode(CustomerSource.self, from: jsonData)
            print(customerSource.customers.count)
//            self.customers = customerSource.customers
            self.filterCustomers = customerSource.customers
            self.tableView.reloadData()
        }
        
    }
    
    func initSearchController(){
        
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Search Customer"
        navigationItem.searchController = searchController
        searchController.searchBar.scopeButtonTitles = ["All", "Category"]
        searchController.searchBar.delegate = self
        
        
        definesPresentationContext = true
        
    }
    
    // MARK: - Table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if isFiltering(){
        print(filterCustomers.count)
            print("filtering")
            return filterCustomers.count
        }
        return 0
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "customerCell")!
        if isFiltering(){
            customers = filterCustomers
        }
        let customer = customers[indexPath.item]
        print(customer.firstName)
        guard let firstName = customer.firstName, let lastName = customer.lastName else { return cell}
        cell.textLabel?.text = "\(firstName) \(lastName)"
        return cell
    }
    
    
    
}

extension CustomerTableViewController: UISearchResultsUpdating, UISearchBarDelegate{
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
        socket.emit("test", with: [searchBar])
        
        
        print(searchBar)
        //        guard let customers = customers else {return}
        //        filterCustomers = customers.filter({ customer -> Bool in
        //            return customer.firstName?.lowercased().contains(searchBar.lowercased()) ?? false
        //        })
        //        tableView.reloadData()
    }
    
    
    
    
}
