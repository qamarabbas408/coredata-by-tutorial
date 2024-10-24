//
//  ColorAttributeTransformer.swift
//  BowTies
//
//  Created by Siliconplex on 23/10/2024.
//

import UIKit

class ColorAttributeTransformer: NSSecureUnarchiveFromDataTransformer {
    //1
      override static var allowedTopLevelClasses: [AnyClass] {
        [UIColor.self]
      }
    //2
      static func register() {
        let className =
          String(describing: ColorAttributeTransformer.self)
        let name = NSValueTransformerName(className)
        let transformer = ColorAttributeTransformer()
        ValueTransformer.setValueTransformer(
          transformer, forName: name)
      }
}
