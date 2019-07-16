//
//  NewCustomerViewController.swift
//  PigletPOS
//
//  Created by Shilo Kohelet on 16/07/2019.
//  Copyright © 2019 Shilo Kohelet. All rights reserved.
//

import UIKit

class NewCustomerViewController: UIViewController {
    
    var keyboardHeigth : CGFloat?
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var firstName: UITextField!
    @IBOutlet weak var lastName: UITextField!
    @IBOutlet weak var country: UITextField!
    @IBOutlet weak var state: UITextField!
    @IBOutlet weak var city: UITextField!
    @IBOutlet weak var line1: UITextField!
    @IBOutlet weak var line2: UITextField!
    @IBOutlet weak var email: UITextField!
    @IBOutlet weak var phone: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        delegateTextViews()
        
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(notification:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(notification:)), name: UIResponder.keyboardWillHideNotification, object: nil)

    }
    
    @IBAction func doneBTN(_ sender: UIBarButtonItem) {
    }
    
    
    @objc func keyboardWillShow(notification: Notification){
        guard let keyFrame = notification.userInfo?["UIKeyboardFrameEndUserInfoKey"] as? CGRect else {return}
        if notification.name == UIResponder.keyboardWillShowNotification{
            keyboardHeigth = keyFrame.height
        }else if notification.name == UIResponder.keyboardWillHideNotification {
            view.frame.origin.y = 0
        }
    }
   
    
    func checkPosition(_ keyboardHeigth: CGFloat){
        for v in scrollView.subviews{
            if let field = v as? UITextField{
                if field.isFirstResponder{
                    let s = field.frame.origin.y - keyboardHeigth
                    if (s > 0){
                        view.frame.origin.y = -s
                    }
                }
            }
        }
    }
    
    func delegateTextViews(){
        for v in scrollView.subviews{
            if let field = v as? UITextField{
                field.delegate = self
            }
        }
    }

}


extension NewCustomerViewController: UITextFieldDelegate{
    func textFieldDidBeginEditing(_ textField: UITextField) {
        guard let keyboardHeigth = keyboardHeigth else { return }
        checkPosition(keyboardHeigth)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if let nextField = textField.superview?.viewWithTag(textField.tag + 1) as? UITextField{
            nextField.becomeFirstResponder()
        }else{
            textField.resignFirstResponder()
        }
        return false
    }
    
}
