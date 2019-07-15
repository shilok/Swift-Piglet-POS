//
//  SettingsTVController.swift
//  PigletPOS
//
//  Created by Shilo Kohelet on 29/06/2019.
//  Copyright © 2019 Shilo Kohelet. All rights reserved.
//

import UIKit

class SettingsViewController: UIViewController {
    

    let content = [
        [
            ["name": "Orders", "image": "orders"],
            ["name": "Open Orders", "image": "openOrders"]
        ],[
            ["name": "Break", "image": "break"]
        ],[
            ["name": "Logout", "image": "logout"]]
        
    ]
    
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.backgroundColor = #colorLiteral(red: 0.9005612135, green: 0.9007124305, blue: 0.9005413651, alpha: 1)
        tableView.tableFooterView = UIView()
        
    }
    
}



extension SettingsViewController: UITableViewDelegate & UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return content[section].count
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return content.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CellSettings", for: indexPath)
        
        let title = content[indexPath.section][indexPath.item]["name"]
        let image = content[indexPath.section][indexPath.item]["image"]
        cell.textLabel?.text = title
        cell.imageView?.image = UIImage(named: image!)
        
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section == 2 {return 50}
        return 30
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        let header = UIView()
        header.backgroundColor = #colorLiteral(red: 0, green: 0.5020497441, blue: 0, alpha: 0)

       
        return header
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let item = content[indexPath.section][indexPath.item]["name"]
        
        switch item {
        case "Orders":
            performSegue(withIdentifier: "ordersSegue", sender: nil)
     
        case "Logout":
            UserDefaults.standard.removeObject(forKey: "token")
            UserDefaults.standard.removeObject(forKey: "storeSet")
            UserDefaults.standard.removeObject(forKey: "stockID")
            tabBarController?.selectedIndex = 0
        default:
            print("Default")
        }
        tableView.deselectRow(at: indexPath, animated: true)
        
    }
    
    
    
    
}
