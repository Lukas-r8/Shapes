//
//  Extension.swift
//  shapes
//
//  Created by Lucas Alves da Silva on 11/20/18.
//  Copyright © 2018 Lucas Alves da Silva. All rights reserved.
//

import Foundation
import UIKit

extension CGPoint {
    func multiplyByFactor(_ factor: CGFloat) -> CGPoint{
        return CGPoint(x: self.x * factor, y: self.y * factor)
    }
}
