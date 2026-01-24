//
//  ContentView.swift
//  TigeHealthScope
//
//  Created by Simon Bakhanets on 24.01.2026.
//

import SwiftUI

struct ContentView: View {
    @AppStorage("hasCompletedOnboarding") private var hasCompletedOnboarding = false
    
    var body: some View {
        if hasCompletedOnboarding {
            MainTabView()
        } else {
            OnboardingView(hasCompletedOnboarding: $hasCompletedOnboarding)
        }
    }
}

struct MainTabView: View {
    @State private var selectedTab = 0
    
    var body: some View {
        ZStack(alignment: .bottom) {
            // Tab Content
            Group {
                switch selectedTab {
                case 0:
                    SymptomTrackerView()
                case 1:
                    HealthInsightsView()
                case 2:
                    SettingsView()
                default:
                    SymptomTrackerView()
                }
            }
            
            // Custom Tab Bar
            CustomTabBar(selectedTab: $selectedTab)
        }
        .ignoresSafeArea(.keyboard)
    }
}

struct CustomTabBar: View {
    @Binding var selectedTab: Int
    
    var body: some View {
        HStack(spacing: 0) {
            TabBarButton(
                icon: "list.clipboard.fill",
                title: "Tracker",
                isSelected: selectedTab == 0
            ) {
                selectedTab = 0
            }
            
            TabBarButton(
                icon: "chart.bar.fill",
                title: "Insights",
                isSelected: selectedTab == 1
            ) {
                selectedTab = 1
            }
            
            TabBarButton(
                icon: "gearshape.fill",
                title: "Settings",
                isSelected: selectedTab == 2
            ) {
                selectedTab = 2
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(
            Color.primaryBackground.opacity(0.95)
                .overlay(
                    Rectangle()
                        .fill(Color.white.opacity(0.1))
                        .frame(height: 1),
                    alignment: .top
                )
        )
        .ignoresSafeArea(.keyboard)
    }
}

struct TabBarButton: View {
    let icon: String
    let title: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 4) {
                Image(systemName: icon)
                    .font(.system(size: 22))
                    .foregroundColor(isSelected ? .primaryButton : .textSecondary)
                
                Text(title)
                    .font(.system(size: 11, weight: .medium))
                    .foregroundColor(isSelected ? .primaryButton : .textSecondary)
            }
            .frame(maxWidth: .infinity)
        }
    }
}

#Preview {
    ContentView()
}
