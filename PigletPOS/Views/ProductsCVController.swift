//
//  ProductsCVController.swift
//  PigletPOS
//
//  Created by Shilo Kohelet on 28/06/2019.
//  Copyright © 2019 Shilo Kohelet. All rights reserved.
//

import UIKit
import SocketIO

private let reuseIdentifier = "Cell"

var socket:SocketIOClient!
let manager = SocketManager(socketURL: URL(string: "https://piglet-pos.com:5000")!, config: [.log(false), .compress])


class ProductsCVController: UIViewController {

    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var blur: UIVisualEffectView!
    @IBAction func dismissView(dis: UIStoryboardSegue){}
    
    private let spacing:CGFloat = 16.0
    
    var products: [Product]?
    
    override func viewDidAppear(_ animated: Bool) {
        checkToken()
        
    }
    
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        
        
        
        
//        view.addSubview(new)
        
        collectionView.delegate = self
        collectionView.dataSource = self
        
        
        socket = manager.defaultSocket
        setSocketEvents()
        socket.connect()
        
        
        let layout = UICollectionViewFlowLayout()
        layout.sectionInset = UIEdgeInsets(top: spacing, left: spacing, bottom: spacing, right: spacing)
        layout.minimumLineSpacing = spacing
        layout.minimumInteritemSpacing = spacing
        self.collectionView?.collectionViewLayout = layout
        
        
        
    }
    
    private func setSocketEvents(){
        
        socket.on(clientEvent: .connect) {data, ack in
            print("socket connected");
        };
        
        socket.on("quantity_updated") {data, ack in
            
            guard
                let json = data as? [Json],
                let res = json.first,
                let products = self.products,
                
                let invetoryID = res["inventoryID"] as? Int,
                let productID = res["productID"] as? Int,
                let quantity = res["quantity"] as? Int,
                
                let productIndex = products.firstIndex(where: { (Product) -> Bool in
                    Product.stockID == invetoryID && Product.productID == productID})
                else {return}
            
            let index = IndexPath(indexes: [productIndex])
            
            self.products?[productIndex].quantity -= quantity
            self.collectionView.reloadItems(at: [index])
            
        };
    };
    
    
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let dest = segue.destination as? LoginViewController{
            dest.delegate = self
        }
    }
    
    func checkToken() {
        if let token = UserDefaults.standard.string(forKey: "token"){
            UIView.animate(withDuration: 0.3) {
                self.blur.alpha = 0
            }
            
            InitPull().getData(token: token, callBack: { data in
                guard let status = data["status"]as? String else {return}
                
                switch status{
                    
                case "store":
                    do{
                        let json = try JSONSerialization.data(withJSONObject: data, options: [])
                        let newProducts = try JSONDecoder().decode(DataSource.self, from: json)
                        self.products = newProducts.products
                        self.collectionView.reloadData()
                        
                    }catch let err{ print(err) }
                    
                case "empty": print("Employee Not connected to any store")
                case "stores": print("Stores")
                default: print("Default")
                }
                
            })
        }else{
            performSegue(withIdentifier: "LoginVCSegue", sender: nil)
            blur.alpha = 0.75
            }


        }
    
    override func unwind(for unwindSegue: UIStoryboardSegue, towards subsequentVC: UIViewController) {
        print("Dissmiss2")
        let segue = ZoomOutSegue(identifier: unwindSegue.identifier, source: unwindSegue.source, destination: unwindSegue.destination)
        segue.perform()
    }
    }



extension ProductsCVController : LoginDelegate{
    func loginFinish() {
        checkToken()
    }
    
    
}

extension ProductsCVController : UICollectionViewDataSource{
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        guard let products = products else {return 0}
        return products.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath) as! ProductCVCell
        
        cell.layer.borderWidth = 1
        cell.layer.cornerRadius = 5
        cell.layer.borderColor = #colorLiteral(red: 0.1411764771, green: 0.3960784376, blue: 0.5647059083, alpha: 1).cgColor
        
        guard let products = products else {return cell}
        
        cell.nameField.text = products[indexPath.item].name
        cell.priceField.text = String(products[indexPath.item].displayPrice)
        
        
        return cell
    }
    

}

extension ProductsCVController : UICollectionViewDelegateFlowLayout{
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let numberOfItemsPerRow:CGFloat = 2
        let spacingBetweenCells:CGFloat = 16
        
        let totalSpacing = (2 * self.spacing) + ((numberOfItemsPerRow - 1) * spacingBetweenCells) //Amount of total spacing in a row
        
        if let collection = self.collectionView{
            let width = (collection.bounds.width - totalSpacing)/numberOfItemsPerRow
            return CGSize(width: width, height: width)
        }else{
            return CGSize(width: 0, height: 0)
        }
    }
}
