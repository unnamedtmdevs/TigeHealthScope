//
//  HealthInsightsViewModel.swift
//  TigeHealthScope
//
//  Created on 2026-01-24.
//

import Foundation
import SwiftUI
import Combine

class HealthInsightsViewModel: ObservableObject {
    @Published var insights: [HealthInsight] = []
    @Published var statistics: SymptomStatistics?
    @Published var selectedTimeRange: TimeRange = .week
    
    private let healthDataService = HealthDataService.shared
    private let analysisService = SymptomAnalysisService.shared
    private var cancellables = Set<AnyCancellable>()
    
    enum TimeRange: String, CaseIterable {
        case week = "Last 7 Days"
        case month = "Last 30 Days"
        case all = "All Time"
        
        func getStartDate() -> Date {
            let calendar = Calendar.current
            switch self {
            case .week:
                return calendar.date(byAdding: .day, value: -7, to: Date()) ?? Date()
            case .month:
                return calendar.date(byAdding: .day, value: -30, to: Date()) ?? Date()
            case .all:
                return Date.distantPast
            }
        }
    }
    
    init() {
        setupSubscriptions()
        refreshInsights()
    }
    
    private func setupSubscriptions() {
        healthDataService.$symptoms
            .sink { [weak self] _ in
                self?.refreshInsights()
            }
            .store(in: &cancellables)
    }
    
    func refreshInsights() {
        let symptoms = getFilteredSymptoms()
        insights = analysisService.analyzeSymptoms(symptoms)
        statistics = analysisService.getStatistics(for: symptoms)
    }
    
    private func getFilteredSymptoms() -> [SymptomModel] {
        let startDate = selectedTimeRange.getStartDate()
        return healthDataService.symptoms.filter { $0.timestamp >= startDate }
    }
    
    func getCategoryPercentage(for category: SymptomCategory) -> Double {
        guard let stats = statistics, stats.totalSymptoms > 0 else { return 0 }
        let count = stats.categoryCounts[category] ?? 0
        return Double(count) / Double(stats.totalSymptoms) * 100
    }
    
    func getSeverityPercentage(for severity: SymptomSeverity) -> Double {
        guard let stats = statistics, stats.totalSymptoms > 0 else { return 0 }
        let count = stats.severityCounts[severity] ?? 0
        return Double(count) / Double(stats.totalSymptoms) * 100
    }
}
