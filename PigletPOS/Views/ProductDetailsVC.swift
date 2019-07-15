//
//  ProductDetailsVC.swift
//  PigletPOS
//
//  Created by Shilo Kohelet on 29/06/2019.
//  Copyright © 2019 Shilo Kohelet. All rights reserved.
//

import UIKit

class ProductDetailsVC: UIViewController {
    
    var orderDetails : OrderDetails?
    var product : Product?
    var orderPrice: Double = 0

    @IBOutlet weak var productImage: UIImageView!
    
    @IBOutlet var currency: [UILabel]!
    @IBOutlet weak var price: UILabel!
    
    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var availableQuantity: UILabel!
    @IBOutlet weak var amountT: UITextField!
    @IBOutlet weak var amountStepper: UIStepper!
    @IBOutlet weak var discountT: UITextField!
    @IBOutlet weak var discountStepper: UIStepper!
    @IBOutlet weak var orderPriceL: UILabel!
    @IBOutlet weak var minPrice: UILabel!
    @IBOutlet weak var descriptionL: UILabel!
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        initOrderDetails()
        
        
        hideKeyboardWhenTappedAround()
        amountT.delegate = self
        discountT.delegate = self
        
        setLayout()
        setQuantity()

        
    }
    
    func initOrderDetails(){
        orderDetails = OrderDetails(orderID: nil, productID: product?.productID, inventoryID: product?.stockID, statusID: 1, quantity: 1, price: product?.displayPrice, discount: 0)
    }
    
    func setLayout(){
        guard let product = product else {return}
        name.text = product.name
        orderPrice = product.displayPrice
        orderPriceL.text = "\(product.displayPrice.roundToDec(3))"
        price.text = "\(orderPrice.roundToDec(3))"
        minPrice.text = "\(product.minPrice.roundToDec(3))"
        descriptionL.text = product.descriptions
    }
    
    func setQuantity(){
        guard let product = product else {return}
        availableQuantity.text = "\(product.quantity)"
        if (amountStepper.value > Double(product.quantity)){
            amountStepper.value = Double(product.quantity)
            amountT.text = "\(product.quantity)"
            availableQuantity.highlight()
        }
        amountStepper.maximumValue = Double(product.quantity)
    }
    
    
    @IBAction func amountStepper(_ sender: UIStepper) {
        guard let amount = amountT.text else {return}
        guard let discount = discountT.text else {return}

        if amount.isEmpty{
            amountStepper.value = 1
        }
        if discount.isEmpty{
            discountT.text = "0.0"
        }
        calculatePrice()
        amountT.text = "\(Int(amountStepper.value))"
        
        
    }
    
    @IBAction func discountStepper(_ sender: UIStepper) {
        print(sender.value)

        guard let amount = amountT.text else {return}
        if amount.isEmpty{
            amountT.text = "1"
        }
        discountT.text = "\(discountStepper.value.roundToDec(2))"
        calculatePrice()
    }
    
    

    func calculatePrice(){
        guard let product = product else {return}
        let percentage = discountStepper.value
        let amount = amountStepper.value
        
        orderPrice = product.displayPrice * (100 - percentage) / 100 * amount
        orderPriceL.text = "\(orderPrice.roundToDec(3))"
        
        guard let orderDetails = orderDetails else { return }
        orderDetails.price = orderPrice
        orderDetails.quantity = Int(amount)
        orderDetails.discount = percentage
    }
    
    func discountApproved(product: Product) -> Bool {
        let minPrice = product.minPrice
        let amount = amountStepper.value
        
        return orderPrice >= (amount * minPrice)
    }
    
    func alertWhenPriceNotApproved(){
            let alert = UIAlertController(title: "Discount does not approved!", message: "\nPlease adjust the price", preferredStyle: .alert)
            let actionOK = UIAlertAction(title: "OK", style: .default)
            alert.addAction(actionOK)
            self.present(alert, animated: true)
    }
    
    @IBAction func checkoutBtn(_ sender: Any) {
        
        guard let product = product else {return}
        if !discountApproved(product: product){
            alertWhenPriceNotApproved()
            return
        }
        let ordersSB = UIStoryboard(name: "Orders", bundle: Bundle.main)
        
        guard let orderConfirmVC = ordersSB.instantiateViewController(withIdentifier: "orderConfirm") as? OrderConfirmationVC else {return}
        self.navigationController?.pushViewController(orderConfirmVC, animated: true)

        createOrder {[weak self] order in
            if let order = order{
                print(order)
                guard let orderDetails = self?.orderDetails else { return }
                orderDetails.orderID = order.id
                
                orderConfirmVC.orderDetails = [orderDetails, orderDetails, orderDetails]
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
    
    func createOrder(callback: @escaping (Order?) -> Void){
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"

        guard let token = UserDefaults.standard.string(forKey: "token") else { callback(nil); return }
        
        DataSource().newOrder(token: token, orderDetailsSource: OrderDetailsSource(orderDetails: [orderDetails!]) ) { json in
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
    
    @IBAction func addToCart(_ sender: Any) {
        guard let orderDetails = orderDetails else {return}
        guard let product = product else {return}
        if !discountApproved(product: product){
            alertWhenPriceNotApproved()
            return
        }
        var orderDetailsArray = [OrderDetails]()
        if let dataDetails = UserDefaults.standard.data(forKey: "orderDetails") {
            orderDetailsArray = try! JSONDecoder().decode([OrderDetails].self, from: dataDetails)
        }
        orderDetailsArray.append(orderDetails)
        
        let dataDetails = try? JSONEncoder().encode(orderDetailsArray)
        UserDefaults.standard.set(dataDetails, forKey: "orderDetails")
        setCartBadge()

    }
}

func setCartBadge(){
    guard let appDelegate = UIApplication.shared.delegate else { return }
    guard let tabController = appDelegate.window??.rootViewController as? UITabBarController else { return }
    
    if let dataDetails = UserDefaults.standard.data(forKey: "orderDetails") {
        let d1 = try! JSONDecoder().decode([OrderDetails].self, from: dataDetails)
        if let tabBar = tabController.tabBar.items{
            tabBar[1].badgeValue = "\(d1.count)"
        }
    }
}



extension ProductDetailsVC : SocketDelegate{
    func receiveUpdate(_ product: Product) {
        guard let p = self.product else {return}
        if (p.productID == product.productID){
            self.product = product
            setQuantity()
        }
    }

}

extension ProductDetailsVC: UITextFieldDelegate{
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        guard let text = textField.text else {return false}
        guard let stringRange = Range(range, in: text) else {return false}
        guard let quantity = product?.quantity else {return false}

        if textField.restorationIdentifier == "amount"{
            
            let allowedSet = CharacterSet(charactersIn: "0123456789")
            let updated = text.replacingCharacters(in: stringRange, with: string)
            
            
            let allowed = updated.rangeOfCharacter(from: allowedSet.inverted) == nil
                && updated.count <= String(quantity).count
                && updated.first != "0"
            
            
            if allowed && updated.count > 0{
                amountStepper.value = Double(updated)!
            }
            
            if allowed && Int(updated) ?? 0 <= quantity{
                if discountT.text!.isEmpty {
                    discountT.text = "0.0"
                }
                if updated.isEmpty{
                    orderPriceL.text = "0.0"
                }else{
                    calculatePrice()
                }
                return true
            }else if (Int(updated) ?? 0 > quantity){
                availableQuantity.shake()
            }
            
        }else if textField.restorationIdentifier == "discount"{
            
            let allowedSet = CharacterSet(charactersIn: "0123456789.")
            let updated = text.replacingCharacters(in: stringRange, with: string)
            
            
            let allowed = updated.rangeOfCharacter(from: allowedSet.inverted) == nil
                        && updated.first != "." && updated.count < 5
            
            
            if allowed{
                if Double(updated) ?? 0 > 100{
                    return false
                }else if amountT.text!.isEmpty {
                    amountT.text = "1"
                }
                if (!updated.containCharsTwice(char: ".")){
                    discountStepper.value = Double(updated) ?? 0
                    calculatePrice()
                    return true
                }
            }
        }
 
        return false

    }
    
}
