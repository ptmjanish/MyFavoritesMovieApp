//
//  UIViewController+Extension.swift
//  MyFavouriteMovies
//
//  Created by Mohammed Janish on 03/07/25.
//

import Foundation
import UIKit

extension UIViewController {

    private static var activityIndicatorTag: Int = 998877 // A unique tag for the activity indicator
    private static var overlayViewTag: Int = 998878     // A unique tag for the semi-transparent overlay

    func showLoadingIndicator(style: UIActivityIndicatorView.Style = .large,
                              backgroundColor: UIColor = UIColor.black.withAlphaComponent(0.5),
                              indicatorColor: UIColor = .white) {

        hideLoadingIndicator(animated: false) // Hide immediately if present

        let overlayView = UIView(frame: self.view.bounds)
        overlayView.tag = UIViewController.overlayViewTag
        overlayView.backgroundColor = backgroundColor
        overlayView.alpha = 0.0 // Start with alpha 0 for fade-in animation

        let activityIndicator = UIActivityIndicatorView(style: style)
        activityIndicator.tag = UIViewController.activityIndicatorTag
        activityIndicator.color = indicatorColor
        activityIndicator.center = overlayView.center // Center the indicator within the overlay
        activityIndicator.hidesWhenStopped = true // Automatically hides the indicator view when stopAnimating() is called

        overlayView.addSubview(activityIndicator)
        self.view.addSubview(overlayView)

        activityIndicator.startAnimating()

        UIView.animate(withDuration: 0.3) {
            overlayView.alpha = 1.0
        }
    }

    func hideLoadingIndicator(animated: Bool = true) {
        if let overlayView = self.view.viewWithTag(UIViewController.overlayViewTag) {
            if let activityIndicator = overlayView.viewWithTag(UIViewController.activityIndicatorTag) as? UIActivityIndicatorView {
                activityIndicator.stopAnimating()
            }

            if animated {
                UIView.animate(withDuration: 0.3, animations: {
                    overlayView.alpha = 0.0
                }) { _ in
                    overlayView.removeFromSuperview()
                }
            } else {
                overlayView.removeFromSuperview()
            }
        }
    }
}
