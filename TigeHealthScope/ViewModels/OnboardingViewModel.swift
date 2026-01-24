//
//  OnboardingViewModel.swift
//  TigeHealthScope
//
//  Created on 2026-01-24.
//

import Foundation
import SwiftUI
import Combine

class OnboardingViewModel: ObservableObject {
    @Published var currentStep = 0
    @Published var userName = ""
    @Published var userAge = ""
    @Published var userEmail = ""
    @Published var showingError = false
    @Published var errorMessage = ""
    
    let totalSteps = 4
    
    func nextStep() {
        if validateCurrentStep() {
            withAnimation {
                if currentStep < totalSteps - 1 {
                    currentStep += 1
                }
            }
        }
    }
    
    func previousStep() {
        withAnimation {
            if currentStep > 0 {
                currentStep -= 1
            }
        }
    }
    
    func validateCurrentStep() -> Bool {
        switch currentStep {
        case 1: // Name validation
            if userName.trimmingCharacters(in: .whitespaces).isEmpty {
                showError("Please enter your name")
                return false
            }
            return true
        case 2: // Age validation (optional but if provided must be valid)
            if !userAge.isEmpty {
                if let age = Int(userAge), age > 0 && age < 120 {
                    return true
                } else {
                    showError("Please enter a valid age")
                    return false
                }
            }
            return true
        default:
            return true
        }
    }
    
    func completeOnboarding() {
        let age = Int(userAge)
        let email = userEmail.isEmpty ? nil : userEmail
        
        let user = UserModel(
            name: userName,
            age: age,
            email: email,
            hasCompletedOnboarding: true,
            notificationsEnabled: true
        )
        
        AppStorageManager.shared.saveUser(user)
    }
    
    private func showError(_ message: String) {
        errorMessage = message
        showingError = true
    }
}
