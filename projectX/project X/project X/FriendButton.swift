//
//  FriendButton.swift
//  project X
//
//  Created by Trace Mateo 21 on 6/7/18.
//  Copyright © 2018 X. All rights reserved.
//

import Foundation
import UIKit

class FriendButton {
    func getButton(friends: Int) -> UIView {
        let x: CGFloat = UIScreen.main.bounds.width
        let y: CGFloat = UIScreen.main.bounds.height
        let friendButton = UIView(frame: CGRect(x: x/4, y: y*2/3, width: x/2, height: y/4.75))
        friendButton.backgroundColor = UIColor.gray
        friendButton.layer.cornerRadius = 20
        friendButton.layer.opacity = 0.6
        let label = UILabel(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width/2, height: y/10))
        label.text = "Friends Selected: \(friends)"
        label.textAlignment = .center
        label.font = UIFont(name: "Avenir-Medium ", size:  UIScreen.main.bounds.width/15)
        label.textColor = UIColor.white
        let button = UIButton(frame: CGRect(x: x/8, y: y/10, width: UIScreen.main.bounds.width/4, height: y/10))
        button.setTitle("Find Places", for: .normal)
        button.titleLabel?.font = UIFont(name: "Avenir-Medium ", size: UIScreen.main.bounds.width/15)
        button.backgroundColor = UIColor.black
        button.layer.cornerRadius = 10
        button.layer.opacity = 0.5
        friendButton.addSubview(button)
        friendButton.addSubview(label)
        
        return friendButton
    }
}
