//
//  OrdersTableViewController.swift
//  PigletPOS
//
//  Created by Shilo Kohelet on 07/07/2019.
//  Copyright © 2019 Shilo Kohelet. All rights reserved.
//

import UIKit

var orders : [Order]?

class OrdersViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        tableView.tableFooterView = UIView()

        setupOrders()
        
        
    }
    

    
    func setupOrders(){
        if let token = UserDefaults.standard.string(forKey: "token"){
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
            
            
            DataSource().getOrders(token: token, employeeID: nil) { json in
                guard let success = json["success"] as? Bool else {return}
                if success{
                    do{
                        let decoder = JSONDecoder()
                        decoder.dateDecodingStrategy = .formatted(formatter)
                        
                        let data = try JSONSerialization.data(withJSONObject: json, options: [])
                        let orderSource = try decoder.decode(OrderSource.self, from: data)
                        orders = orderSource.orders
                        self.tableView.reloadData()
                    }catch let err{
                        print(err)
                    }
                }
                
            }
            
        }else{
            
        }
    }
    
}

extension OrdersViewController: UITableViewDelegate & UITableViewDataSource{
    
    // MARK: - Table view data source

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return orders?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "orderCell", for: indexPath)
        
        guard let order = orders?[indexPath.item] else {return cell}
        
        cell.textLabel?.text = "\(order.id!)"
        print(order.id!)
        
        let orderStatus = OrderStatus(rawValue: order.statusID!)!
        
        switch orderStatus {
        case .open:
            cell.imageView?.image = UIImage(named: "order_open")
        case .close:
            cell.imageView?.image = UIImage(named: "order_close")
        case .aborted:
            cell.imageView?.image = UIImage(named: "order_aborted")
        case .layaway:
            cell.imageView?.image = UIImage(named: "order_layaway")
        }
        
        return cell
    }
 
    

    
}
