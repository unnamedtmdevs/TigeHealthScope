//
//  SymptomModel.swift
//  TigeHealthScope
//
//  Created on 2026-01-24.
//

import Foundation

enum SymptomSeverity: String, Codable, CaseIterable {
    case mild = "Mild"
    case moderate = "Moderate"
    case severe = "Severe"
    
    var color: String {
        switch self {
        case .mild: return "symptomMild"
        case .moderate: return "symptomModerate"
        case .severe: return "symptomSevere"
        }
    }
}

enum SymptomCategory: String, Codable, CaseIterable {
    case headache = "Headache"
    case fatigue = "Fatigue"
    case fever = "Fever"
    case cough = "Cough"
    case nausea = "Nausea"
    case bodyPain = "Body Pain"
    case dizziness = "Dizziness"
    case other = "Other"
    
    var icon: String {
        switch self {
        case .headache: return "brain.head.profile"
        case .fatigue: return "bed.double.fill"
        case .fever: return "thermometer"
        case .cough: return "lungs.fill"
        case .nausea: return "stomach"
        case .bodyPain: return "figure.walk"
        case .dizziness: return "tornado"
        case .other: return "ellipsis.circle.fill"
        }
    }
}

struct SymptomModel: Identifiable, Codable {
    var id: UUID
    var category: SymptomCategory
    var severity: SymptomSeverity
    var notes: String
    var timestamp: Date
    var duration: TimeInterval? // in minutes
    
    init(id: UUID = UUID(), category: SymptomCategory, severity: SymptomSeverity, notes: String = "", timestamp: Date = Date(), duration: TimeInterval? = nil) {
        self.id = id
        self.category = category
        self.severity = severity
        self.notes = notes
        self.timestamp = timestamp
        self.duration = duration
    }
}
