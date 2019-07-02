//
//  SocketProtocol.swift
//  PigletPOS
//
//  Created by Shilo Kohelet on 30/06/2019.
//  Copyright © 2019 Shilo Kohelet. All rights reserved.
//




protocol SocketDelegate {
    func receiveUpdate(_ product: Product)
}
