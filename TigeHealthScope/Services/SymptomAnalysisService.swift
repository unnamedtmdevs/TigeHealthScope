//
//  SymptomAnalysisService.swift
//  TigeHealthScope
//
//  Created on 2026-01-24.
//

import Foundation

struct HealthInsight: Identifiable {
    let id = UUID()
    let title: String
    let description: String
    let category: InsightCategory
    let priority: InsightPriority
}

enum InsightCategory: String {
    case trend = "Trend"
    case recommendation = "Recommendation"
    case warning = "Warning"
    case achievement = "Achievement"
}

enum InsightPriority: Int, Comparable {
    case low = 1
    case medium = 2
    case high = 3
    
    static func < (lhs: InsightPriority, rhs: InsightPriority) -> Bool {
        return lhs.rawValue < rhs.rawValue
    }
}

class SymptomAnalysisService {
    static let shared = SymptomAnalysisService()
    
    private init() {}
    
    // Analyze symptoms and generate insights
    func analyzeSymptoms(_ symptoms: [SymptomModel]) -> [HealthInsight] {
        var insights: [HealthInsight] = []
        
        // Check for severe symptoms
        let severeSymptoms = symptoms.filter { $0.severity == .severe }
        if severeSymptoms.count > 0 {
            insights.append(HealthInsight(
                title: "Severe Symptoms Detected",
                description: "You've logged \(severeSymptoms.count) severe symptom(s) recently. Consider consulting a healthcare professional if symptoms persist.",
                category: .warning,
                priority: .high
            ))
        }
        
        // Check for recurring symptoms
        let symptomCategories = Dictionary(grouping: symptoms, by: { $0.category })
        for (category, categorySymptoms) in symptomCategories {
            if categorySymptoms.count >= 3 {
                insights.append(HealthInsight(
                    title: "Recurring \(category.rawValue)",
                    description: "You've experienced \(category.rawValue.lowercased()) \(categorySymptoms.count) times recently. Track patterns to identify triggers.",
                    category: .trend,
                    priority: .medium
                ))
            }
        }
        
        // Check symptom frequency
        let lastWeekSymptoms = symptoms.filter { symptom in
            let weekAgo = Calendar.current.date(byAdding: .day, value: -7, to: Date()) ?? Date()
            return symptom.timestamp >= weekAgo
        }
        
        if lastWeekSymptoms.isEmpty && symptoms.count > 0 {
            insights.append(HealthInsight(
                title: "Symptom-Free Week",
                description: "Great news! You haven't logged any symptoms in the past week. Keep up the healthy habits!",
                category: .achievement,
                priority: .low
            ))
        } else if lastWeekSymptoms.count > 5 {
            insights.append(HealthInsight(
                title: "High Symptom Frequency",
                description: "You've logged \(lastWeekSymptoms.count) symptoms this week. Consider lifestyle adjustments or medical consultation.",
                category: .recommendation,
                priority: .high
            ))
        }
        
        // Hydration recommendation
        if symptoms.contains(where: { $0.category == .headache || $0.category == .dizziness }) {
            insights.append(HealthInsight(
                title: "Stay Hydrated",
                description: "Headaches and dizziness can be linked to dehydration. Ensure you're drinking enough water daily.",
                category: .recommendation,
                priority: .medium
            ))
        }
        
        // Rest recommendation
        if symptoms.contains(where: { $0.category == .fatigue }) {
            insights.append(HealthInsight(
                title: "Prioritize Rest",
                description: "Fatigue can indicate insufficient rest. Aim for 7-9 hours of quality sleep per night.",
                category: .recommendation,
                priority: .medium
            ))
        }
        
        // General wellness tip
        if insights.isEmpty {
            insights.append(HealthInsight(
                title: "Track Your Health",
                description: "Continue logging symptoms to build a comprehensive health picture and identify patterns over time.",
                category: .recommendation,
                priority: .low
            ))
        }
        
        // Sort by priority
        return insights.sorted { $0.priority > $1.priority }
    }
    
    // Get symptom statistics
    func getStatistics(for symptoms: [SymptomModel]) -> SymptomStatistics {
        let totalSymptoms = symptoms.count
        let categoryCounts = Dictionary(grouping: symptoms, by: { $0.category })
            .mapValues { $0.count }
        let mostCommonCategory = categoryCounts.max(by: { $0.value < $1.value })?.key
        
        let severityCounts = Dictionary(grouping: symptoms, by: { $0.severity })
            .mapValues { $0.count }
        
        let lastWeekSymptoms = symptoms.filter { symptom in
            let weekAgo = Calendar.current.date(byAdding: .day, value: -7, to: Date()) ?? Date()
            return symptom.timestamp >= weekAgo
        }
        
        return SymptomStatistics(
            totalSymptoms: totalSymptoms,
            mostCommonCategory: mostCommonCategory,
            severityCounts: severityCounts,
            lastWeekCount: lastWeekSymptoms.count,
            categoryCounts: categoryCounts
        )
    }
}

struct SymptomStatistics {
    let totalSymptoms: Int
    let mostCommonCategory: SymptomCategory?
    let severityCounts: [SymptomSeverity: Int]
    let lastWeekCount: Int
    let categoryCounts: [SymptomCategory: Int]
}
