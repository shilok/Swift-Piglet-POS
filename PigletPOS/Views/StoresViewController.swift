//
//  StoresViewController.swift
//  PigletPOS
//
//  Created by Shilo Kohelet on 02/07/2019.
//  Copyright © 2019 Shilo Kohelet. All rights reserved.
//

import UIKit

class StoresViewController: UIViewController {
    static func storyboardInstance() -> StoresViewController{
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        return storyboard.instantiateViewController(withIdentifier: "storesVC") as! StoresViewController
    }
    
    var stores: [Store]?
    var delegate: StoreDelegate?
    
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.delegate = self
        tableView.dataSource = self
        // Do any additional setup after loading the view.
    }
    


}

extension StoresViewController : UITableViewDelegate & UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return stores?.count ?? 0
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "storeCell", for: indexPath)
        guard let stores = stores else {return cell}
        let store = stores[indexPath.item]
        cell.textLabel?.text = store.name
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let stores = stores else { return }
        let store = stores[indexPath.item]
        UserDefaults.standard.set(true, forKey: "storeSet")
        UserDefaults.standard.set(store.stockID, forKey: "stockID")
//        performSegue(withIdentifier: "storeOutSegue", sender: nil)
        NotificationCenter.default.post(name: .StoreSelected, object: nil, userInfo: ["store" : store])
        dismiss(animated: true)
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    
    
    
}



