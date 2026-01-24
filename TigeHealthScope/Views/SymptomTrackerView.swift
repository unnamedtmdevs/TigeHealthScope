//
//  SymptomTrackerView.swift
//  TigeHealthScope
//
//  Created on 2026-01-24.
//

import SwiftUI

struct SymptomTrackerView: View {
    @StateObject private var viewModel = SymptomTrackerViewModel()
    @ObservedObject private var healthDataService = HealthDataService.shared
    @State private var showingAddSheet = false
    
    var body: some View {
        ZStack {
            // Background
            LinearGradient(
                gradient: Gradient(colors: [Color.primaryBackground, Color.secondaryBackground]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Header
                HStack {
                    Text("Symptom Tracker")
                        .font(.system(size: 34, weight: .bold))
                        .foregroundColor(.textPrimary)
                    
                    Spacer()
                    
                    Button(action: {
                        showingAddSheet = true
                    }) {
                        Image(systemName: "plus.circle.fill")
                            .font(.system(size: 28))
                            .foregroundColor(.primaryButton)
                    }
                }
                .padding(.horizontal, 24)
                .padding(.top, 20)
                .padding(.bottom, 16)
                
                // Symptoms list
                if healthDataService.symptoms.isEmpty {
                    EmptyStateView()
                } else {
                    ScrollView {
                        LazyVStack(spacing: 12) {
                            ForEach(healthDataService.symptoms) { symptom in
                                SymptomCard(symptom: symptom, viewModel: viewModel)
                            }
                        }
                        .padding(.horizontal, 24)
                        .padding(.vertical, 8)
                    }
                }
            }
        }
        .sheet(isPresented: $showingAddSheet) {
            AddSymptomSheet(viewModel: viewModel, isPresented: $showingAddSheet)
        }
        .alert("Symptom Added", isPresented: $viewModel.showingSuccessAlert) {
            Button("OK", role: .cancel) { }
        } message: {
            Text("Your symptom has been successfully logged.")
        }
    }
}

// MARK: - Empty State
struct EmptyStateView: View {
    var body: some View {
        VStack(spacing: 16) {
            Spacer()
            
            Image(systemName: "heart.text.square")
                .font(.system(size: 60))
                .foregroundColor(.textSecondary)
            
            Text("No Symptoms Logged")
                .font(.system(size: 22, weight: .semibold))
                .foregroundColor(.textPrimary)
            
            Text("Tap the + button to start tracking your symptoms")
                .font(.system(size: 15))
                .foregroundColor(.textSecondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)
            
            Spacer()
        }
    }
}

// MARK: - Symptom Card
struct SymptomCard: View {
    let symptom: SymptomModel
    let viewModel: SymptomTrackerViewModel
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: symptom.category.icon)
                    .font(.system(size: 20))
                    .foregroundColor(.primaryButton)
                
                Text(symptom.category.rawValue)
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(.textPrimary)
                
                Spacer()
                
                SeverityBadge(severity: symptom.severity)
            }
            
            HStack {
                Image(systemName: "clock")
                    .font(.system(size: 12))
                    .foregroundColor(.textSecondary)
                
                Text(viewModel.formatDate(symptom.timestamp))
                    .font(.system(size: 14))
                    .foregroundColor(.textSecondary)
                
                if symptom.duration != nil {
                    Spacer()
                    
                    Image(systemName: "timer")
                        .font(.system(size: 12))
                        .foregroundColor(.textSecondary)
                    
                    Text(viewModel.formatDuration(symptom.duration))
                        .font(.system(size: 14))
                        .foregroundColor(.textSecondary)
                }
            }
            
            if !symptom.notes.isEmpty {
                Text(symptom.notes)
                    .font(.system(size: 14))
                    .foregroundColor(.textSecondary)
                    .lineLimit(3)
            }
        }
        .padding(16)
        .background(Color.cardBackground)
        .cornerRadius(16)
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color.white.opacity(0.2), lineWidth: 1)
        )
        .contextMenu {
            Button(role: .destructive) {
                viewModel.deleteSymptom(symptom)
            } label: {
                Label("Delete", systemImage: "trash")
            }
        }
    }
}

// MARK: - Severity Badge
struct SeverityBadge: View {
    let severity: SymptomSeverity
    
    var body: some View {
        Text(severity.rawValue)
            .font(.system(size: 12, weight: .semibold))
            .foregroundColor(.white)
            .padding(.horizontal, 10)
            .padding(.vertical, 4)
            .background(severityColor)
            .cornerRadius(8)
    }
    
    private var severityColor: Color {
        switch severity {
        case .mild: return .symptomMild
        case .moderate: return .symptomModerate
        case .severe: return .symptomSevere
        }
    }
}

// MARK: - Add Symptom Sheet
struct AddSymptomSheet: View {
    @ObservedObject var viewModel: SymptomTrackerViewModel
    @Binding var isPresented: Bool
    
    var body: some View {
        NavigationView {
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
                        // Category Selection
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Symptom Type")
                                .font(.system(size: 17, weight: .semibold))
                                .foregroundColor(.textPrimary)
                            
                            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                                ForEach(SymptomCategory.allCases, id: \.self) { category in
                                    CategoryButton(
                                        category: category,
                                        isSelected: viewModel.selectedCategory == category
                                    ) {
                                        viewModel.selectedCategory = category
                                    }
                                }
                            }
                        }
                        
                        // Severity Selection
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Severity")
                                .font(.system(size: 17, weight: .semibold))
                                .foregroundColor(.textPrimary)
                            
                            HStack(spacing: 12) {
                                ForEach(SymptomSeverity.allCases, id: \.self) { severity in
                                    SeverityButton(
                                        severity: severity,
                                        isSelected: viewModel.selectedSeverity == severity
                                    ) {
                                        viewModel.selectedSeverity = severity
                                    }
                                }
                            }
                        }
                        
                        // Date
                        VStack(alignment: .leading, spacing: 12) {
                            Text("When did you experience this?")
                                .font(.system(size: 17, weight: .semibold))
                                .foregroundColor(.textPrimary)
                            
                            DatePicker("", selection: $viewModel.selectedDate, displayedComponents: [.date, .hourAndMinute])
                                .datePickerStyle(.compact)
                                .labelsHidden()
                                .colorScheme(.dark)
                        }
                        
                        // Duration
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Duration (minutes, optional)")
                                .font(.system(size: 17, weight: .semibold))
                                .foregroundColor(.textPrimary)
                            
                            TextField("e.g., 30", text: $viewModel.duration)
                                .keyboardType(.numberPad)
                                .padding()
                                .background(Color.cardBackground)
                                .cornerRadius(12)
                        }
                        
                        // Notes
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Additional Notes (optional)")
                                .font(.system(size: 17, weight: .semibold))
                                .foregroundColor(.textPrimary)
                            
                            TextEditor(text: $viewModel.notes)
                                .frame(height: 100)
                                .padding(8)
                                .background(Color.cardBackground)
                                .cornerRadius(12)
                                .colorScheme(.dark)
                        }
                        
                        // Add Button
                        Button(action: {
                            viewModel.addSymptom()
                            isPresented = false
                        }) {
                            Text("Add Symptom")
                                .font(.system(size: 17, weight: .semibold))
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .frame(height: 50)
                                .background(Color.primaryButton)
                                .cornerRadius(12)
                        }
                        .padding(.top, 8)
                    }
                    .padding(24)
                }
            }
            .navigationTitle("Log Symptom")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        isPresented = false
                    }
                    .foregroundColor(.textPrimary)
                }
            }
        }
    }
}

// MARK: - Category Button
struct CategoryButton: View {
    let category: SymptomCategory
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                Image(systemName: category.icon)
                    .font(.system(size: 24))
                
                Text(category.rawValue)
                    .font(.system(size: 13, weight: .medium))
            }
            .foregroundColor(isSelected ? .white : .textSecondary)
            .frame(maxWidth: .infinity)
            .frame(height: 80)
            .background(isSelected ? Color.primaryButton : Color.cardBackground)
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(isSelected ? Color.primaryButton : Color.white.opacity(0.2), lineWidth: 1)
            )
        }
    }
}

// MARK: - Severity Button
struct SeverityButton: View {
    let severity: SymptomSeverity
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(severity.rawValue)
                .font(.system(size: 15, weight: .semibold))
                .foregroundColor(isSelected ? .white : .textSecondary)
                .frame(maxWidth: .infinity)
                .frame(height: 44)
                .background(isSelected ? severityColor : Color.cardBackground)
                .cornerRadius(10)
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(isSelected ? severityColor : Color.white.opacity(0.2), lineWidth: 1)
                )
        }
    }
    
    private var severityColor: Color {
        switch severity {
        case .mild: return .symptomMild
        case .moderate: return .symptomModerate
        case .severe: return .symptomSevere
        }
    }
}
