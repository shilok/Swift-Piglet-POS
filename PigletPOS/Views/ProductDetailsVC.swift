//
//  ProductDetailsVC.swift
//  PigletPOS
//
//  Created by Shilo Kohelet on 29/06/2019.
//  Copyright © 2019 Shilo Kohelet. All rights reserved.
//

import UIKit

class ProductDetailsVC: UIViewController {
    
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
        hideKeyboardWhenTappedAround()
        amountT.delegate = self
        discountT.delegate = self
        
        setLayout()
        setQuantity()

        
    }
    
    func setLayout(){
        guard let product = product else {return}
        name.text = product.name
        orderPrice = product.displayPrice
        orderPriceL.text = "\(product.displayPrice)"
        price.text = "\(orderPrice)"
        minPrice.text = "\(product.minPrice)"
        descriptionL.text = product.description
        
        
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
        guard let amount = amountT.text else {return}
        if amount.isEmpty{
            amountT.text = "1"
        }
        discountT.text = "\(discountStepper.value)"
        calculatePrice()
    }
    
    func calculatePrice(){
        guard let product = product else {return}
        
        let percentage = discountStepper.value
        let amount = amountStepper.value
        
        orderPrice = product.displayPrice * (100 - percentage) / 100 * amount
        
        orderPriceL.text = "\(orderPrice)"
        
        
    }
    
    func discountApproved(product: Product) -> Bool {
        let minPrice = product.minPrice
        let amount = amountStepper.value
        
        return orderPrice >= (amount * minPrice)
    }
    
    @IBAction func checkoutBtn(_ sender: Any) {
    }
    
    @IBAction func addToCart(_ sender: Any) {
        
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
