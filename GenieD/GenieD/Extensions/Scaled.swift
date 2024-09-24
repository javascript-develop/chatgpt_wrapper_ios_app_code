//
//  Scaled.swift
//  GenieD
//
//  Created by OK on 28.02.2023.
//

import Foundation

import UIKit

extension CGFloat {
    var scaled: CGFloat {
        self * UIScreen.main.bounds.width / 414.0 * (Utils.isIpad ? 0.8 : 1.0)
    }
}

extension Int {
    var scaled: CGFloat {
        CGFloat(self).scaled
    }
}

extension CGSize {
    var scaled: CGSize {
        CGSize(width: self.width.scaled, height: self.height.scaled)
    }
}
