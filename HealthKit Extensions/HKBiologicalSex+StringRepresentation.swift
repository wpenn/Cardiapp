//
//  HKBiologicalSex+StringRepresentation.swift
//  Cardiapp
//
//  Created by Wesley Penn on 2/7/18.
//  Copyright © 2018 Riverdale Country School. All rights reserved.
//

import HealthKit

extension HKBiologicalSex {
    
    var stringRepresentation: String {
        switch self {
        case .notSet: return "Unknown"
        case .female: return "Female"
        case .male: return "Male"
        case .other: return "Other"
        }
    }
}
