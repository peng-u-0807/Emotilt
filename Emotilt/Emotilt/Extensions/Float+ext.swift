//
//  Float+ext.swift
//  Emotilt
//
//  Created by 최유림 on 2023/03/03.
//

import Foundation

extension SIMD3<Float> {
    var azimuth: Float {
        asin(self.x)
    }
}
