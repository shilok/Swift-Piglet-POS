//
//  UIView+Extension.swift
//  PigletPOS
//
//  Created by Shilo Kohelet on 06/07/2019.
//  Copyright © 2019 Shilo Kohelet. All rights reserved.
//

import UIKit

extension UIViewController{
    
    func animateInFrom4Margins(container: UIViewController, duration: TimeInterval){
        
        guard let rootView = UIApplication.shared.delegate?.window??.rootViewController else { return }

        
        let width = view.frame.width
        let height = view.frame.height
        
        let t1 = view.resizableSnapshotView(from: CGRect(x: width/2, y: -height/2, width: width, height: height), afterScreenUpdates: true, withCapInsets: UIEdgeInsets())  // top right
        
        let t2 = view.resizableSnapshotView(from: CGRect(x: -width/2, y: -height/2, width: width, height: height), afterScreenUpdates: true, withCapInsets: UIEdgeInsets()) // top left

        let t3 = view.resizableSnapshotView(from: CGRect(x: width/2, y: height/2, width: width, height: height), afterScreenUpdates: true, withCapInsets: UIEdgeInsets()) // bottom right

        let t4 = view.resizableSnapshotView(from: CGRect(x: -width/2, y: height/2, width: width, height: height), afterScreenUpdates: true, withCapInsets: UIEdgeInsets()) // bottom left
        
        if let t1 = t1, let t2 = t2, let t3 = t3, let t4 = t4{
            t1.transform = CGAffineTransform(translationX: -width, y: height/2)
            t2.transform = CGAffineTransform(translationX: width, y: height/2)
            t3.transform = CGAffineTransform(translationX: -width, y: 0)
            t4.transform = CGAffineTransform(translationX: width, y: 0)
        }

        UIView.animate(withDuration: duration, animations: {
            if let t1 = t1, let t2 = t2, let t3 = t3, let t4 = t4{
                container.view.addSubview(t1)
                container.view.addSubview(t2)
//                container.view.addSubview(t3)
//                container.view.addSubview(t4)
                
                
                t1.transform = CGAffineTransform(translationX: width/2, y: -height/2)
                t2.transform = CGAffineTransform(translationX: -width/2, y: -height/2)
                t3.transform = CGAffineTransform(translationX: width/2, y: height/2)
                t4.transform = CGAffineTransform(translationX: -width/2, y: height/2)
            }
        }, completion: { success in
            
            rootView.present(self, animated: false)
            
//            t1?.removeFromSuperview()
//            t2?.removeFromSuperview()
//            t3?.removeFromSuperview()
//            t4?.removeFromSuperview()
        })
        
    }

    func animateOutFrom4Margins(container: UIViewController, duration: TimeInterval){
        
        let width = view.frame.width
        let height = view.frame.height
        
        let t1 = view.resizableSnapshotView(from: CGRect(x: width/2, y: -height/2, width: width, height: height), afterScreenUpdates: true, withCapInsets: UIEdgeInsets())  // top right
        
        let t2 = view.resizableSnapshotView(from: CGRect(x: -width/2, y: -height/2, width: width, height: height), afterScreenUpdates: true, withCapInsets: UIEdgeInsets()) // top left
        
        let t3 = view.resizableSnapshotView(from: CGRect(x: width/2, y: height/2, width: width, height: height), afterScreenUpdates: true, withCapInsets: UIEdgeInsets()) // bottom right
        
        let t4 = view.resizableSnapshotView(from: CGRect(x: -width/2, y: height/2, width: width, height: height), afterScreenUpdates: true, withCapInsets: UIEdgeInsets()) // bottom left
        
        if let t1 = t1, let t2 = t2, let t3 = t3, let t4 = t4{
            t1.transform = CGAffineTransform(translationX: -width, y: height/2)
            t2.transform = CGAffineTransform(translationX: width, y: height/2)
            t3.transform = CGAffineTransform(translationX: -width, y: 0)
            t4.transform = CGAffineTransform(translationX: width, y: 0)
        }
        
        UIView.animate(withDuration: duration, animations: {
            if let t1 = t1, let t2 = t2, let t3 = t3, let t4 = t4{
                t1.transform = CGAffineTransform(translationX: -width, y: height/2)
                t2.transform = CGAffineTransform(translationX: width, y: height/2)
                t3.transform = CGAffineTransform(translationX: -width, y: 0)
                t4.transform = CGAffineTransform(translationX: width, y: 0)
            }
        }, completion: { success in
            self.removeFromParent()
        })
        
    }

    
    
}
