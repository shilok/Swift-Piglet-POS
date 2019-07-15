import UIKit


class Order : Codable{
    var orderName: String
    
    enum CodingKeys: String, CodingKey{
        case orderName
    }
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        orderName = try container.decode(String.self, forKey: .orderName)
    }
    
    
    init(orderName: String) {
        self.orderName = orderName
    }
}

let o1 = Order(orderName: "o1Name")
let o2 = Order(orderName: "o1Name")
let o3 = Order(orderName: "o1Name")


let decoder = JSONDecoder()

let encoder = JSONEncoder()

let data = try? encoder.encode([o1, o2, o3])

let s = String.init(data: data!, encoding: .utf8)


