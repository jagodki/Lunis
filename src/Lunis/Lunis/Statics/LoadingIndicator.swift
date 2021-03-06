//
//  LoadingIndicator.swift
//  Lunis
//
//  Created by Christoph on 31.05.19.
//  Copyright © 2019 jagodki. All rights reserved.
//

import UIKit

/// This class provides static functions to show an overlay view representing loading indicator.
class LoadingIndicator {
    
    static var currentOverlay : UIView?
    static var currentOverlayTarget : UIView?
    static var currentLoadingText: String?
    
    ///This function shows an overlay over the current view.
    static func show() {
        guard let currentMainWindow = UIApplication.shared.keyWindow else {
            print("No main window")
            return
        }
        show(overlayTarget: currentMainWindow)
    }
    
    /// This function shows an overlay over the given view.
    ///
    /// - Parameter overlayTarget: a view that should be overlayed by a loading indicator
    static func show(overlayTarget: UIView) {
        show(overlayTarget: overlayTarget, loadingText: nil, colour: #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1), alpha: 0.5)
    }
    
    /// This function shows an overlay with the given colour.
    ///
    /// - Parameters:
    ///   - colour: the colour of the overlay
    ///   - alpha: the alpha value of the overlay
    static func show(colour: UIColor, alpha: Double) {
        guard let currentMainWindow = UIApplication.shared.keyWindow else {
            print("No main window")
            return
        }
        show(overlayTarget: currentMainWindow, loadingText: nil, colour: colour, alpha: alpha)
    }
    
    /// This function shows an overlay withg the given text and background colour.
    ///
    /// - Parameters:
    ///   - loadingText: the text that should be displayed in the overlay
    ///   - colour: the background colour of the overlay
    ///   - alpha: the alpha value of the overlay
    static func show(loadingText: String, colour: UIColor, alpha: Double) {
        guard let currentMainWindow = UIApplication.shared.keyWindow else {
            print("No main window")
            return
        }
        show(overlayTarget: currentMainWindow,loadingText: loadingText, colour: colour, alpha: alpha)
    }
    
    /// This function shows an overlay as a loading indicator.
    ///
    /// - Parameters:
    ///   - overlayTarget: a view that should be overlayed by a loading indicator
    ///   - loadingText: the text that should be displayed in the overlay
    ///   - colour: the background colour of the overlay
    ///   - alpha: the alpha value of the overlay
    static func show(overlayTarget : UIView, loadingText: String?, colour: UIColor, alpha: Double) {
        // Clear it first in case it was already shown
        hide()
        
        // Create the overlay
        let overlay = UIView()
        overlay.alpha = 0
        overlay.backgroundColor = colour
        overlay.translatesAutoresizingMaskIntoConstraints = false
        overlayTarget.addSubview(overlay)
        overlayTarget.bringSubviewToFront(overlay)
        
        overlay.widthAnchor.constraint(equalTo: overlayTarget.widthAnchor).isActive = true
        overlay.heightAnchor.constraint(equalTo: overlayTarget.heightAnchor).isActive = true
        
        // Create and animate the activity indicator
        let indicator = UIActivityIndicatorView(style: UIActivityIndicatorView.Style.white)
        indicator.translatesAutoresizingMaskIntoConstraints = false
        indicator.startAnimating()
        overlay.addSubview(indicator)
        
        indicator.centerXAnchor.constraint(equalTo: overlay.centerXAnchor).isActive = true
        indicator.centerYAnchor.constraint(equalTo: overlay.centerYAnchor).isActive = true
        
        // Create label
        if let textString = loadingText {
            let label = UILabel()
            label.text = textString
            label.textColor = UIColor.white
            overlay.addSubview(label)
            label.translatesAutoresizingMaskIntoConstraints = false
            label.topAnchor.constraint(equalTo: indicator.bottomAnchor, constant: 16).isActive = true
            label.centerXAnchor.constraint(equalTo: indicator.centerXAnchor).isActive = true
        }
        
        // Animate the overlay to show
        UIView.animate(withDuration: 0.5, animations: {
            overlay.alpha = CGFloat(overlay.alpha > 0 ? 0 : alpha)
        })
        
        self.currentOverlay = overlay
        self.currentOverlayTarget = overlayTarget
        self.currentLoadingText = loadingText
    }
    
    /// This function hides an overlay.
    static func hide() {
        if self.currentOverlay != nil {
            DispatchQueue.main.async {
                self.currentOverlay?.removeFromSuperview()
                self.currentOverlay =  nil
                self.currentLoadingText = nil
                self.currentOverlayTarget = nil
            }
        }
    }
    
}
