//
//  UIImageView+downloadImageFromLink.swift
//  Congress 2
//
//  Created by Lance Sigersmith on 4/16/19.
//  Copyright © 2019 Lance Sigersmith. All rights reserved.
//

import UIKit

extension UIImageView {
    func downloadImageFrom(link:String, contentMode: UIView.ContentMode, backup:String) {
        URLSession.shared.dataTask( with: NSURL(string:link)! as URL, completionHandler: {
            (data, response, error) -> Void in
            DispatchQueue.main.async {
                self.contentMode =  contentMode
                if let data = data {
                    if UIImage(data: data) == nil {
                        self.image = UIImage(named: backup)
                    } else {
                    self.image = UIImage(data: data)
                    }
                }
            }
        }).resume()
    }
}
