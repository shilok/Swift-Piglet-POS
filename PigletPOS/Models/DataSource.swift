//
//  DataSource.swift
//  PigletPOS
//
//  Created by Shilo Kohelet on 13/06/2019.
//  Copyright © 2019 Shilo Kohelet. All rights reserved.
//

import UIKit

struct ProductSource : Codable {
    var products: [Product]
}
struct StoreSource : Codable {
    var stores: [Store]
}



struct InitPull {
    
    
    func getData(token:String, stockID: Int?, callBack: @escaping (Json) -> Void) {
        
        
        let url = "https://piglet-pos.com:5000/api/testing/getProducts"
        let session = URLSession.shared
        
        var request = URLRequest(url: URL(string: url)!)
        request.httpMethod = "POST"
        
        let json = try? JSONSerialization.data(withJSONObject: ["stockID": stockID])
        request.httpBody = json
        request.addValue(token, forHTTPHeaderField: "Authorization")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")

        
        let task = session.dataTask(with: request) { (data, response, err) in
            guard err == nil else {return}
            guard let data = data else {return}
            
            if let res = response as? HTTPURLResponse{
                if res.statusCode == 401{
                    let json = ["status": "Unauthorized"]
                    return callBack(json)
                }
            }
            
            do{
                if let result = try JSONSerialization.jsonObject(with: data, options: []) as? Json{
                    DispatchQueue.main.async {
                        return callBack(result)
                    }
                }
            }catch let err{
                print(err.localizedDescription)
            }
            
        }
        
        task.resume()
    }
}
