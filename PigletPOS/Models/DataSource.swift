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
struct OrderSource : Codable {
    var orders: [Order]
}

struct OrderDetailsSource : Codable {
    var orderDetails: [OrderDetails]
}





struct DataSource {
    
    
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
                        self.saveEmployee(json: result)
                        return callBack(result)
                    }
                }
            }catch let err{
                print(err.localizedDescription)
            }
            
        }
        
        task.resume()
    }
    
    func saveEmployee(json: Json){
        guard let emp = json["employee"] else { return }
        do {
            let data = try JSONSerialization.data(withJSONObject: emp, options: [])
            UserDefaults.standard.set(data, forKey: "employee")
        } catch let err {
            print(err.localizedDescription)
        }
    }
    
    func getEmployee() -> Employee?{
        guard let data = UserDefaults.standard.data(forKey: "employee") else { return nil }
        do {
            let employee = try JSONDecoder().decode(Employee.self, from: data)
            return employee
        } catch let err {
            print(err.localizedDescription)
        }
        return nil
    }
    
    func getOrders(token:String, employeeID: Int?, callBack: @escaping (Json) -> Void) {
        
        
        let url = "https://piglet-pos.com:5000/api/testing/getOrders"
        let session = URLSession.shared
        
        var request = URLRequest(url: URL(string: url)!)
        request.httpMethod = "POST"
        
        let json = try? JSONSerialization.data(withJSONObject: ["employeeID": employeeID])
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
    
    func getOrder(token:String, orderID:Int, callBack: @escaping (Json) -> Void) {
        
        let url = "https://piglet-pos.com:5000/api/testing/getOrder"
        let session = URLSession.shared
        
        var request = URLRequest(url: URL(string: url)!)
        request.httpMethod = "POST"
        
        let json = try? JSONSerialization.data(withJSONObject: ["orderID": orderID])
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
                    DispatchQueue.main.async { return callBack(json) }
                }
            }
            
            do{
                if let result = try JSONSerialization.jsonObject(with: data, options: []) as? Json{
                    
                    DispatchQueue.main.async { return callBack(result) }
                }
            }catch let err{ print(err) }
        }
        task.resume()
    }
    
    func newOrder(token:String, orderDetailsSource: OrderDetailsSource, callBack: @escaping (Json) -> Void) {
        
        
        let dataDetails = try? JSONEncoder().encode(orderDetailsSource)
        
        
        let url = "https://piglet-pos.com:5000/api/testing/createOrderTest"
        let session = URLSession.shared
        
        var request = URLRequest(url: URL(string: url)!)
        request.httpMethod = "POST"
        request.httpBody = dataDetails
        request.addValue(token, forHTTPHeaderField: "Authorization")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        
        
        let task = session.dataTask(with: request) { (data, response, err) in
            guard err == nil else {return}
            guard let data = data else {return}
            
            if let res = response as? HTTPURLResponse{
                if res.statusCode == 401{
                    let json = ["status": "Unauthorized"]
                    DispatchQueue.main.async { return callBack(json) }
                }
            }
            
            do{
                if let result = try JSONSerialization.jsonObject(with: data, options: []) as? Json{
                    DispatchQueue.main.async { return callBack(result) }
                }
            }catch let err { print(err) }
            
        }
        
        task.resume()
    }
    
    
    
}


