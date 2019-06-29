//
//  SettingsTVController.swift
//  PigletPOS
//
//  Created by Shilo Kohelet on 29/06/2019.
//  Copyright © 2019 Shilo Kohelet. All rights reserved.
//

import UIKit

class SettingsViewController: UIViewController {
    
    let arr = [
        ["t1-s1", "t2-s1", "t3-s1"],
        ["t1-s2", "t2-s2", "t3-s2", "t4-s2"],
        ["Logout"]
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
        return arr[section].count
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return arr.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CellSettings", for: indexPath)
        
        cell.textLabel?.text = arr[indexPath.section][indexPath.item]
        
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section == 2 {return 50}
        return 30
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        let header = UIView()
        header.backgroundColor = #colorLiteral(red: 0, green: 0.5020497441, blue: 0, alpha: 0)

        if section == 2 {
            header.backgroundColor = #colorLiteral(red: 0.2392156869, green: 0.6745098233, blue: 0.9686274529, alpha: 1)
            
        }
        return header
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let item = arr[indexPath.section][indexPath.item]
        
        switch item {
        case "Logout":
            UserDefaults.standard.removeObject(forKey: "token")
            tabBarController?.selectedIndex = 0
        default:
            print("Default")
        }
        
    }
    
    
    
    
}
