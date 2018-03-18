//
//  SlideSegue.swift
//  Clima
//
//  Created by Gabriel Bryant on 3/9/18.
//  Copyright © 2018 Phaeroh. All rights reserved.
//

import UIKit

class SlideSegue: UIStoryboardSegue {
    
    override func perform() {
        slideLeft()
    }
    
    func slideLeft() {
        // Assign the source and destination views to local variables.
        let fromVC = self.source
        let toVC = self.destination
        
        // Get the screen width and height.
        let screenWidth = UIScreen.main.bounds.size.width
        let screenHeight = UIScreen.main.bounds.size.height
        
        // Specify the initial position of the destination view.
        toVC.view.frame = CGRect(x: screenWidth, y: 0.0, width: screenWidth, height: screenHeight)
        
        // Access the superview and insert the destination view above the current (source) one.
        let containerView = fromVC.view.superview
        containerView?.addSubview(toVC.view)
        
        //Animate the transition
        UIView.animate(withDuration: 0.5, delay: 0, options: .curveEaseInOut, animations: {
            toVC.view.transform = CGAffineTransform(translationX: -screenWidth, y:0.0)
        }, completion: { success in
            fromVC.present(self.destination, animated: false, completion: nil)
        })
    }
}

class UnwindSlideSegue: UIStoryboardSegue {
    
    override func perform() {
        slideRight()
    }
    
    func slideRight() {
        // Assign the source and destination views to local variables.
        let fromVC = self.source
        let toVC = self.destination
        
        // Get the screen width and height.
//        let screenHeight = UIScreen.main.bounds.size.height
        let screenWidth = UIScreen.main.bounds.size.width
        
        fromVC.view.superview?.insertSubview(toVC.view, at: 0)
        
        // Animate the transition.
        UIView.animate(withDuration: 0.5, delay: 0, options: .curveEaseInOut, animations: {
            fromVC.view.transform = CGAffineTransform(translationX: screenWidth, y:0.0)
        }, completion: { success in
            fromVC.dismiss(animated: false, completion: nil)
        })
    }
}





