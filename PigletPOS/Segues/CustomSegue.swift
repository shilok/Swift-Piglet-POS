//
//  ZoomInSegue.swift
//  PigletPOS
//
//  Created by Shilo Kohelet on 29/06/2019.
//  Copyright © 2019 Shilo Kohelet. All rights reserved.
//

import UIKit

class ZoomInSegue: UIStoryboardSegue {
    
    override func perform() {
        scale()
    }
    
    func scale(){
        let toView = destination
        let fromView = source
        
        let container = fromView.view.superview
        let center = fromView.view.center
        
        toView.view.transform = CGAffineTransform(scaleX: 0.05, y: 0.05)
        toView.view.center = center
        
        container?.addSubview(toView.view)
        
        UIView.animate(withDuration: 0.5, animations: {
            toView.view.transform = .identity
        }, completion: { success in
            fromView.present(toView, animated: false)
        })
        
        
        
    }

}

class ZoomOutSegue: UIStoryboardSegue {
    
    override func perform() {
        scale()
    }
    
    func scale(){
        UIView.animate(withDuration: 0.5, animations: {
            self.source.view.transform = CGAffineTransform(scaleX: 0.05, y: 0.05)
        }, completion: { success in
            self.source.dismiss(animated: false)
        })
        
        
        
    }
    
}
