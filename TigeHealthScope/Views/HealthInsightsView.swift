//
//  HealthInsightsView.swift
//  TigeHealthScope
//
//  Created on 2026-01-24.
//

import SwiftUI

struct HealthInsightsView: View {
    @StateObject private var viewModel = HealthInsightsViewModel()
    
    var body: some View {
        ZStack {
            // Background
            LinearGradient(
                gradient: Gradient(colors: [Color.primaryBackground, Color.secondaryBackground]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: 24) {
                    // Header
                    HStack {
                        Text("Health Insights")
                            .font(.system(size: 34, weight: .bold))
                            .foregroundColor(.textPrimary)
                        
                        Spacer()
                    }
                    .padding(.horizontal, 24)
                    .padding(.top, 20)
                    
                    // Time Range Selector
                    Picker("Time Range", selection: $viewModel.selectedTimeRange) {
                        ForEach(HealthInsightsViewModel.TimeRange.allCases, id: \.self) { range in
                            Text(range.rawValue).tag(range)
                        }
                    }
                    .pickerStyle(SegmentedPickerStyle())
                    .padding(.horizontal, 24)
                    .onChange(of: viewModel.selectedTimeRange) { _ in
                        viewModel.refreshInsights()
                    }
                    
                    // Statistics Card
                    if let stats = viewModel.statistics {
                        StatisticsCard(stats: stats)
                            .padding(.horizontal, 24)
                    }
                    
                    // Insights
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Your Insights")
                            .font(.system(size: 22, weight: .bold))
                            .foregroundColor(.textPrimary)
                            .padding(.horizontal, 24)
                        
                        if viewModel.insights.isEmpty {
                            EmptyInsightsView()
                        } else {
                            ForEach(viewModel.insights) { insight in
                                InsightCard(insight: insight)
                                    .padding(.horizontal, 24)
                            }
                        }
                    }
                    .padding(.bottom, 24)
                }
            }
        }
        .onAppear {
            viewModel.refreshInsights()
        }
    }
}

// MARK: - Statistics Card
struct StatisticsCard: View {
    let stats: SymptomStatistics
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Overview")
                .font(.system(size: 18, weight: .semibold))
                .foregroundColor(.textPrimary)
            
            HStack(spacing: 20) {
                StatItem(
                    icon: "list.bullet.clipboard",
                    title: "Total",
                    value: "\(stats.totalSymptoms)"
                )
                
                StatItem(
                    icon: "calendar.badge.clock",
                    title: "This Week",
                    value: "\(stats.lastWeekCount)"
                )
                
                if let mostCommon = stats.mostCommonCategory {
                    StatItem(
                        icon: mostCommon.icon,
                        title: "Most Common",
                        value: mostCommon.rawValue,
                        isCompact: true
                    )
                }
            }
            
            // Severity Distribution
            if stats.totalSymptoms > 0 {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Severity Distribution")
                        .font(.system(size: 15, weight: .medium))
                        .foregroundColor(.textSecondary)
                    
                    HStack(spacing: 8) {
                        ForEach(SymptomSeverity.allCases, id: \.self) { severity in
                            let count = stats.severityCounts[severity] ?? 0
                            if count > 0 {
                                VStack(spacing: 4) {
                                    Text("\(count)")
                                        .font(.system(size: 14, weight: .semibold))
                                        .foregroundColor(.white)
                                    
                                    Text(severity.rawValue)
                                        .font(.system(size: 11))
                                        .foregroundColor(.white.opacity(0.8))
                                }
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 8)
                                .background(severityColor(severity))
                                .cornerRadius(8)
                            }
                        }
                    }
                }
            }
        }
        .padding(20)
        .background(Color.cardBackground)
        .cornerRadius(16)
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color.white.opacity(0.2), lineWidth: 1)
        )
    }
    
    private func severityColor(_ severity: SymptomSeverity) -> Color {
        switch severity {
        case .mild: return .symptomMild
        case .moderate: return .symptomModerate
        case .severe: return .symptomSevere
        }
    }
}

// MARK: - Stat Item
struct StatItem: View {
    let icon: String
    let title: String
    let value: String
    var isCompact: Bool = false
    
    var body: some View {
        VStack(spacing: 6) {
            Image(systemName: icon)
                .font(.system(size: isCompact ? 18 : 22))
                .foregroundColor(.primaryButton)
            
            Text(value)
                .font(.system(size: isCompact ? 16 : 20, weight: .bold))
                .foregroundColor(.textPrimary)
            
            Text(title)
                .font(.system(size: isCompact ? 11 : 12))
                .foregroundColor(.textSecondary)
        }
        .frame(maxWidth: .infinity)
    }
}

// MARK: - Insight Card
struct InsightCard: View {
    let insight: HealthInsight
    
    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: categoryIcon)
                .font(.system(size: 20))
                .foregroundColor(categoryColor)
                .frame(width: 36, height: 36)
                .background(categoryColor.opacity(0.2))
                .cornerRadius(8)
            
            VStack(alignment: .leading, spacing: 6) {
                HStack {
                    Text(insight.title)
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.textPrimary)
                    
                    Spacer()
                    
                    if insight.priority == .high {
                        Image(systemName: "exclamationmark.circle.fill")
                            .font(.system(size: 14))
                            .foregroundColor(.accentButton)
                    }
                }
                
                Text(insight.description)
                    .font(.system(size: 14))
                    .foregroundColor(.textSecondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
        .padding(16)
        .background(Color.cardBackground)
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(categoryColor.opacity(0.3), lineWidth: 1)
        )
    }
    
    private var categoryIcon: String {
        switch insight.category {
        case .trend: return "chart.line.uptrend.xyaxis"
        case .recommendation: return "lightbulb.fill"
        case .warning: return "exclamationmark.triangle.fill"
        case .achievement: return "star.fill"
        }
    }
    
    private var categoryColor: Color {
        switch insight.category {
        case .trend: return .secondaryButton
        case .recommendation: return .primaryButton
        case .warning: return .accentButton
        case .achievement: return .tertiaryBackground
        }
    }
}

// MARK: - Empty Insights View
struct EmptyInsightsView: View {
    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: "chart.bar.doc.horizontal")
                .font(.system(size: 50))
                .foregroundColor(.textSecondary)
                .padding(.top, 20)
            
            Text("No Insights Yet")
                .font(.system(size: 18, weight: .semibold))
                .foregroundColor(.textPrimary)
            
            Text("Start logging symptoms to receive personalized health insights")
                .font(.system(size: 14))
                .foregroundColor(.textSecondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)
                .padding(.bottom, 20)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 20)
        .background(Color.cardBackground)
        .cornerRadius(16)
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color.white.opacity(0.2), lineWidth: 1)
        )
        .padding(.horizontal, 24)
    }
}
