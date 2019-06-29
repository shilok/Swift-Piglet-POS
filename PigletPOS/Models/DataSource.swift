//
//  DataSource.swift
//  PigletPOS
//
//  Created by Shilo Kohelet on 13/06/2019.
//  Copyright © 2019 Shilo Kohelet. All rights reserved.
//

import UIKit

struct DataSource : Codable {
    var products: [Product]
    var employee: Employee
}

struct InitPull {
    
    
    func getData(token:String, callBack: @escaping (Json) -> Void) {
        
        
        let url = "https://piglet-pos.com:5000/api/testing/getProducts"
        let session = URLSession.shared
        
        var request = URLRequest(url: URL(string: url)!)
        request.httpMethod = "POST"
        
//        guard let token = UserDefaults.standard.string(forKey: "token") else {return}
        request.addValue(token, forHTTPHeaderField: "Authorization")
        
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        
        
        
        let task = session.dataTask(with: request) { (data, response, err) in
            guard err == nil else {return}
            guard let data = data else {return}
            
            
            do{
                if let result = try JSONSerialization.jsonObject(with: data, options: []) as? Json{
                    DispatchQueue.main.async {
                        callBack(result)
                    }
                }
            }catch let err{
                print(err.localizedDescription)
            }
            
        }
        
        task.resume()
    }
}
