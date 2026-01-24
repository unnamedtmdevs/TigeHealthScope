//
//  SettingsView.swift
//  TigeHealthScope
//
//  Created on 2026-01-24.
//

import SwiftUI

struct SettingsView: View {
    @AppStorage("hasCompletedOnboarding") private var hasCompletedOnboarding = false
    @AppStorage("notificationsEnabled") private var notificationsEnabled = true
    @State private var user: UserModel?
    @State private var showingDeleteAlert = false
    @State private var showingResetAlert = false
    
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
                        Text("Settings")
                            .font(.system(size: 34, weight: .bold))
                            .foregroundColor(.textPrimary)
                        
                        Spacer()
                    }
                    .padding(.horizontal, 24)
                    .padding(.top, 20)
                    
                    // Profile Section
                    if let user = user {
                        ProfileSection(user: user)
                            .padding(.horizontal, 24)
                    }
                    
                    // Preferences Section
                    PreferencesSection(notificationsEnabled: $notificationsEnabled)
                        .padding(.horizontal, 24)
                    
                    // Data Management Section
                    DataManagementSection(
                        showingResetAlert: $showingResetAlert,
                        showingDeleteAlert: $showingDeleteAlert
                    )
                    .padding(.horizontal, 24)
                    
                    // App Info Section
                    AppInfoSection()
                        .padding(.horizontal, 24)
                    
                    Spacer(minLength: 40)
                }
            }
        }
        .onAppear {
            loadUserData()
        }
        .alert("Reset Symptom Data", isPresented: $showingResetAlert) {
            Button("Cancel", role: .cancel) { }
            Button("Reset", role: .destructive) {
                HealthDataService.shared.clearAllSymptoms()
            }
        } message: {
            Text("Are you sure you want to delete all logged symptoms? This action cannot be undone.")
        }
        .alert("Delete Account", isPresented: $showingDeleteAlert) {
            Button("Cancel", role: .cancel) { }
            Button("Delete", role: .destructive) {
                deleteAccount()
            }
        } message: {
            Text("This will delete all your data and reset the app. This action cannot be undone.")
        }
    }
    
    private func loadUserData() {
        user = AppStorageManager.shared.loadUser()
    }
    
    private func deleteAccount() {
        AppStorageManager.shared.deleteAllData()
        HealthDataService.shared.clearAllSymptoms()
        hasCompletedOnboarding = false
    }
}

// MARK: - Profile Section
struct ProfileSection: View {
    let user: UserModel
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Profile")
                .font(.system(size: 20, weight: .semibold))
                .foregroundColor(.textPrimary)
            
            VStack(spacing: 12) {
                ProfileRow(icon: "person.fill", title: "Name", value: user.name)
                
                if let age = user.age {
                    ProfileRow(icon: "calendar", title: "Age", value: "\(age)")
                }
                
                if let email = user.email {
                    ProfileRow(icon: "envelope.fill", title: "Email", value: email)
                }
                
                ProfileRow(
                    icon: "clock.fill",
                    title: "Member Since",
                    value: formatDate(user.createdAt)
                )
            }
            .padding(16)
            .background(Color.cardBackground)
            .cornerRadius(16)
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(Color.white.opacity(0.2), lineWidth: 1)
            )
        }
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter.string(from: date)
    }
}

// MARK: - Profile Row
struct ProfileRow: View {
    let icon: String
    let title: String
    let value: String
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 16))
                .foregroundColor(.primaryButton)
                .frame(width: 24)
            
            Text(title)
                .font(.system(size: 15))
                .foregroundColor(.textSecondary)
            
            Spacer()
            
            Text(value)
                .font(.system(size: 15, weight: .medium))
                .foregroundColor(.textPrimary)
        }
    }
}

// MARK: - Preferences Section
struct PreferencesSection: View {
    @Binding var notificationsEnabled: Bool
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Preferences")
                .font(.system(size: 20, weight: .semibold))
                .foregroundColor(.textPrimary)
            
            VStack(spacing: 0) {
                Toggle(isOn: $notificationsEnabled) {
                    HStack(spacing: 12) {
                        Image(systemName: "bell.fill")
                            .font(.system(size: 16))
                            .foregroundColor(.primaryButton)
                            .frame(width: 24)
                        
                        VStack(alignment: .leading, spacing: 2) {
                            Text("Notifications")
                                .font(.system(size: 15, weight: .medium))
                                .foregroundColor(.textPrimary)
                            
                            Text("Receive health tips and reminders")
                                .font(.system(size: 13))
                                .foregroundColor(.textSecondary)
                        }
                    }
                }
                .toggleStyle(SwitchToggleStyle(tint: .primaryButton))
                .padding(16)
            }
            .background(Color.cardBackground)
            .cornerRadius(16)
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(Color.white.opacity(0.2), lineWidth: 1)
            )
        }
        .onChange(of: notificationsEnabled) { newValue in
            if var user = AppStorageManager.shared.loadUser() {
                user.notificationsEnabled = newValue
                AppStorageManager.shared.saveUser(user)
            }
        }
    }
}

// MARK: - Data Management Section
struct DataManagementSection: View {
    @Binding var showingResetAlert: Bool
    @Binding var showingDeleteAlert: Bool
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Data Management")
                .font(.system(size: 20, weight: .semibold))
                .foregroundColor(.textPrimary)
            
            VStack(spacing: 12) {
                SettingsButton(
                    icon: "arrow.counterclockwise",
                    title: "Reset Symptom Data",
                    color: .secondaryButton
                ) {
                    showingResetAlert = true
                }
                
                SettingsButton(
                    icon: "trash.fill",
                    title: "Delete Account",
                    color: .accentButton
                ) {
                    showingDeleteAlert = true
                }
            }
        }
    }
}

// MARK: - App Info Section
struct AppInfoSection: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("About")
                .font(.system(size: 20, weight: .semibold))
                .foregroundColor(.textPrimary)
            
            VStack(spacing: 12) {
                InfoRow(title: "Version", value: "1.0.0")
                InfoRow(title: "App Name", value: "TigeHealth Scope")
                
                VStack(spacing: 8) {
                    Text("Your personal health companion")
                        .font(.system(size: 13))
                        .foregroundColor(.textSecondary)
                        .multilineTextAlignment(.center)
                    
                    Text("All data is stored securely on your device")
                        .font(.system(size: 11))
                        .foregroundColor(.textSecondary.opacity(0.7))
                        .multilineTextAlignment(.center)
                }
                .frame(maxWidth: .infinity)
                .padding(.top, 4)
            }
            .padding(16)
            .background(Color.cardBackground)
            .cornerRadius(16)
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(Color.white.opacity(0.2), lineWidth: 1)
            )
        }
    }
}

// MARK: - Info Row
struct InfoRow: View {
    let title: String
    let value: String
    
    var body: some View {
        HStack {
            Text(title)
                .font(.system(size: 15))
                .foregroundColor(.textSecondary)
            
            Spacer()
            
            Text(value)
                .font(.system(size: 15, weight: .medium))
                .foregroundColor(.textPrimary)
        }
    }
}

// MARK: - Settings Button
struct SettingsButton: View {
    let icon: String
    let title: String
    let color: Color
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 12) {
                Image(systemName: icon)
                    .font(.system(size: 16))
                    .foregroundColor(.white)
                    .frame(width: 24)
                
                Text(title)
                    .font(.system(size: 15, weight: .medium))
                    .foregroundColor(.white)
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .font(.system(size: 14))
                    .foregroundColor(.white.opacity(0.6))
            }
            .padding(16)
            .background(color)
            .cornerRadius(12)
        }
    }
}
