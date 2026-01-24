//
//  UserModel.swift
//  TigeHealthScope
//
//  Created on 2026-01-24.
//

import Foundation

struct UserModel: Codable {
    var id: UUID
    var name: String
    var age: Int?
    var email: String?
    var hasCompletedOnboarding: Bool
    var notificationsEnabled: Bool
    var createdAt: Date
    
    init(id: UUID = UUID(), name: String = "", age: Int? = nil, email: String? = nil, hasCompletedOnboarding: Bool = false, notificationsEnabled: Bool = true, createdAt: Date = Date()) {
        self.id = id
        self.name = name
        self.age = age
        self.email = email
        self.hasCompletedOnboarding = hasCompletedOnboarding
        self.notificationsEnabled = notificationsEnabled
        self.createdAt = createdAt
    }
}
