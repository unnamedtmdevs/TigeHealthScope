//
//  AppStorageManager.swift
//  TigeHealthScope
//
//  Created on 2026-01-24.
//

import Foundation
import SwiftUI

class AppStorageManager {
    static let shared = AppStorageManager()
    
    private init() {}
    
    // User Data
    @AppStorage("userData") private var userDataString: String = ""
    @AppStorage("hasCompletedOnboarding") var hasCompletedOnboarding: Bool = false
    @AppStorage("notificationsEnabled") var notificationsEnabled: Bool = true
    
    // Symptoms Data
    @AppStorage("symptomsData") private var symptomsDataString: String = ""
    
    // Save User
    func saveUser(_ user: UserModel) {
        if let encoded = try? JSONEncoder().encode(user) {
            userDataString = String(data: encoded, encoding: .utf8) ?? ""
            hasCompletedOnboarding = user.hasCompletedOnboarding
            notificationsEnabled = user.notificationsEnabled
        }
    }
    
    // Load User
    func loadUser() -> UserModel? {
        guard !userDataString.isEmpty,
              let data = userDataString.data(using: .utf8),
              let user = try? JSONDecoder().decode(UserModel.self, from: data) else {
            return nil
        }
        return user
    }
    
    // Save Symptoms
    func saveSymptoms(_ symptoms: [SymptomModel]) {
        if let encoded = try? JSONEncoder().encode(symptoms) {
            symptomsDataString = String(data: encoded, encoding: .utf8) ?? ""
        }
    }
    
    // Load Symptoms
    func loadSymptoms() -> [SymptomModel] {
        guard !symptomsDataString.isEmpty,
              let data = symptomsDataString.data(using: .utf8),
              let symptoms = try? JSONDecoder().decode([SymptomModel].self, from: data) else {
            return []
        }
        return symptoms
    }
    
    // Delete All Data
    func deleteAllData() {
        userDataString = ""
        symptomsDataString = ""
        hasCompletedOnboarding = false
        notificationsEnabled = true
    }
}
