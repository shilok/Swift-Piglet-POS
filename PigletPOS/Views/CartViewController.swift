//
//  CartViewController.swift
//  PigletPOS
//
//  Created by Shilo Kohelet on 29/06/2019.
//  Copyright © 2019 Shilo Kohelet. All rights reserved.
//

import UIKit

class CartViewController: UIViewController {
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var summaryHeight: NSLayoutConstraint!
    @IBOutlet weak var summaryStatus: UIButton!
    @IBOutlet weak var priceViewHeight: NSLayoutConstraint!
    

    @IBOutlet weak var priceView: UIView!
    @IBAction func summaryStatus(_ sender: UIButton) {
        hideSummary()
    }
    var orderDetails : [OrderDetails]?
    var products : [Product]?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        products = getProducts()
        

        tableView.delegate = self
        tableView.dataSource = self
//        tableView.tableFooterView = UIView()
        
        getOrderDetails()
    }
    
    @IBAction func checkOutBtn(_ sender: UIButton) {
        let ordersSB = UIStoryboard(name: "Orders", bundle: Bundle.main)
        
        guard let orderConfirmVC = ordersSB.instantiateViewController(withIdentifier: "orderConfirm") as? OrderConfirmationVC else {return}
        self.navigationController?.pushViewController(orderConfirmVC, animated: true)
        
        createOrder {[weak self] order in
            if let order = order{
                guard let orderDetails = self?.orderDetails else { return }
                orderDetails.forEach({ orderDetails in orderDetails.orderID = order.id })
                
                
                orderConfirmVC.orderDetails = orderDetails
                orderConfirmVC.order = order
                orderConfirmVC.setContent()
                orderConfirmVC.indicatorView.isHidden = true
            }else{
                orderConfirmVC.dismiss(animated: true, completion: {
                    self?.navigationController?.popViewController(animated: true)
                })
            }
        }
    }
    
    func getOrderDetails(){
        if let dataDetails = UserDefaults.standard.data(forKey: "orderDetails"){
            orderDetails = try! JSONDecoder().decode([OrderDetails].self, from: dataDetails)
            tableView.reloadData()
        }
        
    }
    func createOrder(callback: @escaping (Order?) -> Void){
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        
        guard let token = UserDefaults.standard.string(forKey: "token") else { callback(nil); return }
        guard let orderDetails = orderDetails else { return }
        DataSource().newOrder(token: token, orderDetailsSource: OrderDetailsSource(orderDetails: orderDetails) ) { json in
            guard let success = json["success"] as? Bool else { return callback(nil) }
            guard let orderJson = json["order"] as? Json else { return callback(nil) }
            if success{
                do{
                    let decoder = JSONDecoder()
                    decoder.dateDecodingStrategy = .formatted(formatter)
                    
                    let data = try JSONSerialization.data(withJSONObject: orderJson, options: [])
                    let order = try decoder.decode(Order.self, from: data)
                    return callback(order)
                }catch let err{
                    print(err)
                    return callback(nil)
                }
            }
            return callback(nil)
        }
        
    }


    func hideSummary(){
        self.summaryHeight.constant = self.summaryHeight.constant == 180 ? 0 : 180
        UIView.animate(withDuration: 0.5) {
            self.summaryStatus.transform = self.summaryStatus.transform.isIdentity ?  CGAffineTransform(rotationAngle: .pi) : .identity
            self.view.layoutIfNeeded()
        }
    }
}




extension CartViewController: UITableViewDelegate & UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let orderDetails = orderDetails else { return 0}
        return orderDetails.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "cartCell") as? CartTableViewCell
            else {return UITableViewCell()}
        guard let orderDetails = orderDetails?[indexPath.item] else { return cell }
        guard let product = getProduct(productID: orderDetails.productID ?? 0) else { return cell }
        let name = product.name
        let price = orderDetails.price?.roundToDec(3)
        
        cell.name.text = name
        cell.price.text = "\(price ?? 0.0) $ US"
        
        return cell
    }
  
    
    
}
