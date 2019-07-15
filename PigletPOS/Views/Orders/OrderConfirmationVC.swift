//
//  OrderConfirmationVC.swift
//  PigletPOS
//
//  Created by Shilo Kohelet on 09/07/2019.
//  Copyright © 2019 Shilo Kohelet. All rights reserved.
//

import UIKit

enum OrderConfirm: Int {
    case Customer, Payment, Review, Summary
}

func getProducts() -> [Product]?{
    if let data = UserDefaults.standard.data(forKey: "products"){
        return try! JSONDecoder().decode([Product].self, from: data)
    }
    return nil
}

func getProduct(productID: Int) -> Product?{
    guard let products = getProducts() else { return nil}
    return products.first { p -> Bool in p.productID == productID }
}


class OrderConfirmationVC: UIViewController {
    @IBOutlet weak var indicatorView: UIView!
    
    @IBOutlet weak var tableView: UITableView!
    var content : [Any]?
    var orderDetails: [OrderDetails]?
    var order: Order?
    let paymentType: Dictionary<Int, String> = [1 : "Master Card", 2: "American Express", 3: "Cash"]
    var products : [Product]?
    var customer : Customer?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        tableView.delegate = self
        tableView.dataSource = self
        
    }
    
    
    
    
    func setContent(){
        content = [ [""], ["", ""], orderDetails as Any , ["", ""] ]
        guard let orderID = order?.id else { return }
        navigationItem.title = "Order: \(orderID)"
        products = getProducts()
        tableView.reloadData()
    }
    
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destination.
     // Pass the selected object to the new view controller.
     }
     */
    
}

extension OrderConfirmationVC : UITableViewDelegate & UITableViewDataSource{
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch indexPath.section {
        case 0:
            if customer == nil{
                let customerSb = UIStoryboard(name: "Customer", bundle: Bundle.main)
                guard let customerVC = customerSb.instantiateViewController(withIdentifier: "customerTableView") as? CustomerTableViewController else { return }
                
                self.navigationController?.pushViewController(customerVC, animated: true)
            }
        default:
            print("default selected")
        }
    }
    
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section == 0{
            if let customer = customer{
                
            }else{
                return 100
            }
        }
        return UITableView.automaticDimension
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        guard let count = content?.count else {return 0}
        print("Count section: \(count)")
        return count
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let content = content as? [[Any]] else {return 0}
        guard let orderDetails = orderDetails else {return 0}
        print("D count", orderDetails.count)
        if section == 2 {return 1 + (orderDetails.count * 2)}
        return content[section].count
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section > 0{
            return 8
        }
        return 0
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell()
        guard let paymentTypeID = order?.paymentTypeID else { return cell}
        guard let customerCell = tableView.dequeueReusableCell(withIdentifier: "customerCell") as? CustomerTableViewCell else { return cell}
        guard let titleCell = tableView.dequeueReusableCell(withIdentifier: "titleCell") as? TitleTableViewCell else { return cell}
        guard let customCell = tableView.dequeueReusableCell(withIdentifier: "customCell") as? CustomTableViewCell else { return cell}
        guard let productCell = tableView.dequeueReusableCell(withIdentifier: "productCell") as? ProductTableViewCell else { return cell}
        guard let totalCell = tableView.dequeueReusableCell(withIdentifier: "totalCell") as? TotalTableViewCell else { return cell}
        
        switch indexPath.section {
        case 0:
            guard let customer = customer else {
                customCell.textLabel?.text = "Enter Customer"
                
                return customCell
            }
            customerCell.fullName.text = "\(customer.firstName) \(customer.lastName)"
            return customerCell
        case 1:
            if indexPath.item == 0{
                titleCell.titleLabel?.text = "Payment Methods"
                return titleCell
            }
            customCell.textLabel?.text = paymentType[paymentTypeID]
            customCell.imageView?.image = setPaymentImage(typeID: paymentTypeID)
            return customCell
            
        case 2:
            if indexPath.item == 0{
                titleCell.titleLabel?.text = "Order Review"
                return titleCell
            }
            
            let noteCell = indexPath.item % 2 == 0
            if noteCell{
                customCell.textLabel?.text = "Notes"
                return customCell
            }
            guard let orderDetails = orderDetails?[indexPath.item / 2] else { return productCell}
            guard let product = getProduct(productID: orderDetails.productID ?? 0) else { return productCell}
            productCell.name.text = product.name
            productCell.price.text = "US $\(orderDetails.price?.roundToDec(2) ?? 0)"
            return productCell
            
        case 3:
            if indexPath.item == 0{
                titleCell.titleLabel?.text = "Order Summary"
                return titleCell
            }
            return totalCell
            
        default:
            return cell
        }
    }
    
    
    func setPaymentImage(typeID: Int) -> UIImage{
        switch typeID {
        case 1:
            return UIImage(named: "amex")!
        case 2:
            return UIImage(named: "visa")!
        case 3:
            return UIImage(named: "cash")!
        default:
            return UIImage()
        }
    }
    
    
    
}
