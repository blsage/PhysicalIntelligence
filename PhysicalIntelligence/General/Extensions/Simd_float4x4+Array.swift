//
//  Simd_float4x4+Array.swift
//  PhysicalIntelligence
//
//  Created by Benjamin Sage on 9/28/24.
//

import ARKit

extension simd_float4x4 {
    var array: [Float] {
        let columns = [self.columns.0, self.columns.1, self.columns.2, self.columns.3]
        return columns.flatMap { [$0.x, $0.y, $0.z, $0.w] }
    }
}
