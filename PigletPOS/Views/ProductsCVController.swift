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


class ProductsCVController: UICollectionViewController {
    
    private let spacing:CGFloat = 16.0
    
    var products: [Product]?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        socket = manager.defaultSocket
        setSocketEvents()
        socket.connect()
        
        
        let layout = UICollectionViewFlowLayout()
        layout.sectionInset = UIEdgeInsets(top: spacing, left: spacing, bottom: spacing, right: spacing)
        layout.minimumLineSpacing = spacing
        layout.minimumInteritemSpacing = spacing
        self.collectionView?.collectionViewLayout = layout
        
        
        
    }
    
    private func setSocketEvents()
    {
        socket.on(clientEvent: .connect) {data, ack in
            print("socket connected");
        };
        
        socket.on("quantity_updated") {data, ack in
            
            if let json = data as? [Json]{
                
                
                guard let res = json.first else {return}
                guard
                    let products = self.products,
                    let invetoryID = res["inventoryID"] as? Int,
                    let productID = res["productID"] as? Int,
                    let quantity = res["quantity"] as? Int

                    else {return}
                
                
                guard let productIndex = products.firstIndex(where: { (Product) -> Bool in
                    Product.stockID == invetoryID && Product.productID == productID}) else {return}
                    
                self.products?[productIndex].quantity -= quantity
                let index = IndexPath(indexes: [productIndex])
                self.collectionView.reloadItems(at: [index])
                
                print(self.products?[productIndex].quantity)
                

            }
            
        };
    };
    
    
    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        guard let products = products else {return 0}
        return products.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
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
