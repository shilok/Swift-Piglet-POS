//
//  ViewController.swift
//  PigletPOS
//
//  Created by Shilo Kohelet on 13/06/2019.
//  Copyright © 2019 Shilo Kohelet. All rights reserved.
//

import UIKit
import SocketIO

class ViewController: UIViewController {
    @IBAction func btn1(_ sender: Any) {
        
        
        socket.emit("test123", (["name":"shilo"]))

        
        
        
    }
    
    var socket:SocketIOClient!
    let manager = SocketManager(socketURL: URL(string: "https://piglet-pos.com:5000")!, config: [.log(true), .compress])


    override func viewDidLoad() {
        super.viewDidLoad()
        
        socket = manager.defaultSocket
        setSocketEvents()
        socket.connect()
        getHeadlines()
        

        
     
        
    }
    
    func getHeadlines(){
        print("getHeadlines")
    };
    
    
    private func setSocketEvents()
    {
        socket.on(clientEvent: .connect) {data, ack in
            print("socket connected");
        };
        
        socket.on("headlines_updated") {data, ack in
            self.getHeadlines()
        };
    };


}

