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
    
    @IBOutlet weak var employeeIDField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    @IBOutlet weak var loginBTN: UIButton!
    
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
                let token = result["token"]as! String
                UserDefaults.standard.set(token, forKey: "token")
                
                InitPull().getData(callBack: { data in
                    
                    guard let status = data["status"]as? String else {return}
                    
                    switch status{
                    case "empty":
                        print("Employee Not connected to any store")
                        
                    case "store":
                        do{
                            let json = try JSONSerialization.data(withJSONObject: data, options: [])
                            let products = try JSONDecoder().decode(DataSource.self, from: json)
                            
                            self.performSegue(withIdentifier: "ProductCVSegue", sender: products.products)
                            
                            print("Store")
                            
                        }catch let err{
                            print(err)
                        }
                        
                    case "stores":
                        print("Stores")
                        
                    default:
                        print("Default")
                    }
                    
                })
                
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
        
        employeeIDField.setBottomBorderOnlyWith(color: UIColor.gray.cgColor)
        passwordField.setBottomBorderOnlyWith(color: UIColor.gray.cgColor)
        
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
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    
        if let dest = segue.destination as? ProductsCVController{
            dest.products = sender as? [Product]
        }
    }
    
    
}

typealias Json = Dictionary<String, Any>
