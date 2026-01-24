//
//  SymptomTrackerViewModel.swift
//  TigeHealthScope
//
//  Created on 2026-01-24.
//

import Foundation
import SwiftUI
import Combine

class SymptomTrackerViewModel: ObservableObject {
    @Published var selectedCategory: SymptomCategory = .headache
    @Published var selectedSeverity: SymptomSeverity = .mild
    @Published var notes: String = ""
    @Published var selectedDate: Date = Date()
    @Published var duration: String = ""
    @Published var showingSuccessAlert = false
    
    private let healthDataService = HealthDataService.shared
    
    func addSymptom() {
        let durationValue: TimeInterval? = {
            if let mins = Double(duration), mins > 0 {
                return mins * 60 // Convert to seconds
            }
            return nil
        }()
        
        let symptom = SymptomModel(
            category: selectedCategory,
            severity: selectedSeverity,
            notes: notes,
            timestamp: selectedDate,
            duration: durationValue
        )
        
        healthDataService.addSymptom(symptom)
        
        // Reset form
        resetForm()
        
        // Show success feedback
        showingSuccessAlert = true
    }
    
    func resetForm() {
        selectedCategory = .headache
        selectedSeverity = .mild
        notes = ""
        selectedDate = Date()
        duration = ""
    }
    
    func deleteSymptom(_ symptom: SymptomModel) {
        healthDataService.deleteSymptom(symptom)
    }
    
    func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
    
    func formatDuration(_ duration: TimeInterval?) -> String {
        guard let duration = duration else { return "N/A" }
        let minutes = Int(duration / 60)
        if minutes < 60 {
            return "\(minutes) min"
        } else {
            let hours = minutes / 60
            let remainingMinutes = minutes % 60
            return "\(hours)h \(remainingMinutes)m"
        }
    }
}
