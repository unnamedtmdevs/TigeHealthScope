//
//  OnboardingView.swift
//  TigeHealthScope
//
//  Created on 2026-01-24.
//

import SwiftUI

struct OnboardingView: View {
    @StateObject private var viewModel = OnboardingViewModel()
    @Binding var hasCompletedOnboarding: Bool
    
    var body: some View {
        ZStack {
            // Background gradient
            LinearGradient(
                gradient: Gradient(colors: [Color.primaryBackground, Color.secondaryBackground]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Progress indicator
                HStack(spacing: 8) {
                    ForEach(0..<viewModel.totalSteps, id: \.self) { index in
                        Capsule()
                            .fill(index <= viewModel.currentStep ? Color.primaryButton : Color.white.opacity(0.3))
                            .frame(height: 4)
                            .frame(maxWidth: .infinity)
                    }
                }
                .padding(.horizontal, 24)
                .padding(.top, 20)
                
                // Content
                TabView(selection: $viewModel.currentStep) {
                    WelcomeStepView()
                        .tag(0)
                    
                    NameStepView(name: $viewModel.userName)
                        .tag(1)
                    
                    PersonalInfoStepView(age: $viewModel.userAge, email: $viewModel.userEmail)
                        .tag(2)
                    
                    FeaturesStepView()
                        .tag(3)
                }
                .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
                
                // Navigation buttons
                HStack(spacing: 16) {
                    if viewModel.currentStep > 0 {
                        Button(action: {
                            viewModel.previousStep()
                        }) {
                            Text("Back")
                                .font(.system(size: 17, weight: .semibold))
                                .foregroundColor(.textPrimary)
                                .frame(maxWidth: .infinity)
                                .frame(height: 50)
                                .background(Color.white.opacity(0.2))
                                .cornerRadius(12)
                        }
                    }
                    
                    Button(action: {
                        if viewModel.currentStep == viewModel.totalSteps - 1 {
                            viewModel.completeOnboarding()
                            hasCompletedOnboarding = true
                        } else {
                            viewModel.nextStep()
                        }
                    }) {
                        Text(viewModel.currentStep == viewModel.totalSteps - 1 ? "Get Started" : "Next")
                            .font(.system(size: 17, weight: .semibold))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .frame(height: 50)
                            .background(Color.primaryButton)
                            .cornerRadius(12)
                    }
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 30)
            }
        }
        .alert("Error", isPresented: $viewModel.showingError) {
            Button("OK", role: .cancel) { }
        } message: {
            Text(viewModel.errorMessage)
        }
    }
}

// MARK: - Welcome Step
struct WelcomeStepView: View {
    var body: some View {
        VStack(spacing: 24) {
            Spacer()
            
            Image(systemName: "heart.text.square.fill")
                .font(.system(size: 80))
                .foregroundColor(.primaryButton)
            
            Text("Welcome to\nTigeHealth Scope")
                .font(.system(size: 34, weight: .bold))
                .foregroundColor(.textPrimary)
                .multilineTextAlignment(.center)
            
            Text("Your personal health companion for tracking symptoms and gaining valuable health insights")
                .font(.system(size: 17))
                .foregroundColor(.textSecondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 32)
            
            Spacer()
        }
    }
}

// MARK: - Name Step
struct NameStepView: View {
    @Binding var name: String
    
    var body: some View {
        VStack(spacing: 24) {
            Spacer()
            
            Image(systemName: "person.circle.fill")
                .font(.system(size: 70))
                .foregroundColor(.primaryButton)
            
            Text("What's your name?")
                .font(.system(size: 28, weight: .bold))
                .foregroundColor(.textPrimary)
            
            Text("We'll use this to personalize your experience")
                .font(.system(size: 15))
                .foregroundColor(.textSecondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 32)
            
            TextField("Enter your name", text: $name)
                .font(.system(size: 17))
                .foregroundColor(.textPrimary)
                .padding()
                .background(Color.white.opacity(0.2))
                .cornerRadius(12)
                .padding(.horizontal, 32)
                .autocapitalization(.words)
            
            Spacer()
        }
    }
}

// MARK: - Personal Info Step
struct PersonalInfoStepView: View {
    @Binding var age: String
    @Binding var email: String
    
    var body: some View {
        VStack(spacing: 24) {
            Spacer()
            
            Image(systemName: "info.circle.fill")
                .font(.system(size: 70))
                .foregroundColor(.primaryButton)
            
            Text("A bit more about you")
                .font(.system(size: 28, weight: .bold))
                .foregroundColor(.textPrimary)
            
            Text("Optional information to enhance your experience")
                .font(.system(size: 15))
                .foregroundColor(.textSecondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 32)
            
            VStack(spacing: 16) {
                TextField("Age (optional)", text: $age)
                    .font(.system(size: 17))
                    .foregroundColor(.textPrimary)
                    .keyboardType(.numberPad)
                    .padding()
                    .background(Color.white.opacity(0.2))
                    .cornerRadius(12)
                
                TextField("Email (optional)", text: $email)
                    .font(.system(size: 17))
                    .foregroundColor(.textPrimary)
                    .keyboardType(.emailAddress)
                    .autocapitalization(.none)
                    .padding()
                    .background(Color.white.opacity(0.2))
                    .cornerRadius(12)
            }
            .padding(.horizontal, 32)
            
            Spacer()
        }
    }
}

// MARK: - Features Step
struct FeaturesStepView: View {
    var body: some View {
        VStack(spacing: 24) {
            Spacer()
            
            Text("Your Health Journey Starts Here")
                .font(.system(size: 28, weight: .bold))
                .foregroundColor(.textPrimary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 32)
            
            VStack(alignment: .leading, spacing: 20) {
                FeatureRow(
                    icon: "stethoscope",
                    title: "Track Symptoms",
                    description: "Log and monitor your symptoms with ease"
                )
                
                FeatureRow(
                    icon: "chart.line.uptrend.xyaxis",
                    title: "Health Insights",
                    description: "Get personalized health recommendations"
                )
                
                FeatureRow(
                    icon: "bell.fill",
                    title: "Stay Informed",
                    description: "Receive timely health tips and reminders"
                )
                
                FeatureRow(
                    icon: "lock.shield.fill",
                    title: "Private & Secure",
                    description: "Your data stays on your device"
                )
            }
            .padding(.horizontal, 32)
            
            Spacer()
        }
    }
}

struct FeatureRow: View {
    let icon: String
    let title: String
    let description: String
    
    var body: some View {
        HStack(spacing: 16) {
            Image(systemName: icon)
                .font(.system(size: 24))
                .foregroundColor(.primaryButton)
                .frame(width: 40, height: 40)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.system(size: 17, weight: .semibold))
                    .foregroundColor(.textPrimary)
                
                Text(description)
                    .font(.system(size: 14))
                    .foregroundColor(.textSecondary)
            }
            
            Spacer()
        }
    }
}
