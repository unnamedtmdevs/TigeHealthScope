//
//  HealthDataService.swift
//  TigeHealthScope
//
//  Created on 2026-01-24.
//

import Foundation
import Combine

class HealthDataService: ObservableObject {
    static let shared = HealthDataService()
    
    @Published var symptoms: [SymptomModel] = []
    
    private init() {
        loadSymptoms()
    }
    
    // Load symptoms from storage
    func loadSymptoms() {
        symptoms = AppStorageManager.shared.loadSymptoms()
    }
    
    // Add a new symptom
    func addSymptom(_ symptom: SymptomModel) {
        symptoms.insert(symptom, at: 0)
        saveSymptoms()
    }
    
    // Update existing symptom
    func updateSymptom(_ symptom: SymptomModel) {
        if let index = symptoms.firstIndex(where: { $0.id == symptom.id }) {
            symptoms[index] = symptom
            saveSymptoms()
        }
    }
    
    // Delete symptom
    func deleteSymptom(_ symptom: SymptomModel) {
        symptoms.removeAll { $0.id == symptom.id }
        saveSymptoms()
    }
    
    // Get symptoms for specific date range
    func getSymptoms(from startDate: Date, to endDate: Date) -> [SymptomModel] {
        return symptoms.filter { symptom in
            symptom.timestamp >= startDate && symptom.timestamp <= endDate
        }
    }
    
    // Get symptoms by category
    func getSymptoms(by category: SymptomCategory) -> [SymptomModel] {
        return symptoms.filter { $0.category == category }
    }
    
    // Get recent symptoms (last 7 days)
    func getRecentSymptoms() -> [SymptomModel] {
        let sevenDaysAgo = Calendar.current.date(byAdding: .day, value: -7, to: Date()) ?? Date()
        return getSymptoms(from: sevenDaysAgo, to: Date())
    }
    
    // Save symptoms to storage
    private func saveSymptoms() {
        AppStorageManager.shared.saveSymptoms(symptoms)
    }
    
    // Clear all symptoms
    func clearAllSymptoms() {
        symptoms.removeAll()
        saveSymptoms()
    }
}
