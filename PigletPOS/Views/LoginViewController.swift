//
//  LoginViewController.swift
//  PigletPOS
//
//  Created by Shilo Kohelet on 28/06/2019.
//  Copyright © 2019 Shilo Kohelet. All rights reserved.
//

import UIKit

class LoginViewController: UIViewController {
    
    let url = "https://piglet-pos.com:5000/api/users/authenticate"
    
    var delegate : LoginDelegate?
    
    
    @IBOutlet weak var employeeIDField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    @IBOutlet weak var loginBTN: UIButton!
    @IBOutlet weak var contentView: UIView!
    
    @IBOutlet weak var indicator: UIActivityIndicatorView!

    
 
    
    @IBAction func loginBTN(_ sender: Any) {
        
        guard let id = employeeIDField.text, let pass = passwordField.text else {return}
        
        if id.isEmpty {
            employeeIDField.isError(baseColor: UIColor.gray.cgColor, numberOfShakes: 3, revert: true)
            return
        }
        
        if pass.isEmpty {
            passwordField.isError(baseColor: UIColor.gray.cgColor, numberOfShakes: 3, revert: true)
            return
        }
        self.loginBTN.isEnabled = false
        self.indicator.isHidden = false
        self.indicator.startAnimating()
        
        
        login(empID: id, pass: pass) { result in
            
            let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .alert)
            let action = UIAlertAction(title: "Try Again", style: .default)
            alertController.addAction(action)
            
            guard let status = result["status"] as? String else {
                alertController.title = "Error while Login"
                self.present(alertController, animated: true)
                return
            }
            
            switch status{
                
            case "Token":
                guard let token = result["token"]as? String else {return}
                UserDefaults.standard.set(token, forKey: "token")
                self.performSegue(withIdentifier: "outSegue", sender: nil)
                self.delegate?.loginFinish()


            case "Employee":
                alertController.title = "Employee Not Exist"
                self.present(alertController, animated: true)
                
            case "Password":
                alertController.title = "Wrong Password"
                self.present(alertController, animated: true)
                
            default:
                alertController.title = "Error"
                self.present(alertController, animated: true)
            }
            
            self.loginBTN.isEnabled = true
            self.indicator.isHidden = true
            self.indicator.stopAnimating()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        indicator.isHidden = true
        
        contentView.layer.cornerRadius = 5
        
//        view.backgroundColor = .clear
        

        let token = UserDefaults.standard.string(forKey: "token")
        if let token = token{
            print(token)
        }
    }
    

    func login(empID: String, pass: String, callBack: @escaping (Json) -> Void) {
        
        
        let url = "https://piglet-pos.com:5000/api/users/authenticate"
        let session = URLSession.shared
        
        var request = URLRequest(url: URL(string: url)!)
        request.httpMethod = "POST"
        
        request.httpBody = try! JSONSerialization.data(withJSONObject: ["id": empID, "pass": pass])
        
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        
        
        
        let task = session.dataTask(with: request) { (data, response, err) in
            guard err == nil else {return}
            guard let data = data else {return}
            
            
            do{
                
                if let res = try JSONSerialization.jsonObject(with: data, options: []) as? Json{
                    DispatchQueue.main.async {
                        callBack(res)
                    }
                }
                
                
            }catch let err{
                print(err.localizedDescription)
            }
            
        }
        
        task.resume()
    }
    
    
}

typealias Json = Dictionary<String, Any>
