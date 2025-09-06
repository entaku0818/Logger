//
//  ContentView.swift
//  Logger
//
//  Created by 遠藤拓弥 on 2025/01/11.
//

import SwiftUI
import os

// MARK: - Logger Extension
extension Logger {
    static let app = Logger(subsystem: Bundle.main.bundleIdentifier!, category: "app")
    static let network = Logger(subsystem: Bundle.main.bundleIdentifier!, category: "network")
    static let ui = Logger(subsystem: Bundle.main.bundleIdentifier!, category: "ui")
    static let dataModel = Logger(subsystem: Bundle.main.bundleIdentifier!, category: "datamodel")
}

struct ContentView: View {
    @State private var userName = ""
    @State private var isLoading = false
    @State private var logMessages: [String] = []
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                headerSection
                inputSection
                buttonSection
                logDisplaySection
                Spacer()
            }
            .padding()
            .navigationTitle("Logger Sample")
            .onAppear {
                Logger.ui.info("ContentViewが表示されました")
                addLogMessage("📱 アプリが開始されました")
            }
        }
    }
    
    // MARK: - Header Section
    private var headerSection: some View {
        VStack(spacing: 10) {
            Text("os.Logger vs print文")
                .font(.title2)
                .fontWeight(.bold)
            
            Text("ログの違いをXcodeコンソール・Console.app・コマンドラインで確認してください")
                .font(.caption)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
    }
    
    // MARK: - Input Section
    private var inputSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("ユーザー名")
                .font(.headline)
            
            TextField("名前を入力", text: $userName)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .onChange(of: userName, initial: false) { _, newValue in
                    Logger.ui.debug("ユーザー名が変更されました: \(newValue, privacy: .private)")
                }
        }
    }
    
    // MARK: - Button Section
    private var buttonSection: some View {
        VStack(spacing: 15) {
            // print vs Logger比較ボタン
            Button("print文 vs Logger 比較") {
                Logger.ui.info("比較ボタンがタップされました")
                demonstratePrintVsLogger()
            }
            .buttonStyle(.borderedProminent)
            
            // ネットワークシミュレーションボタン
            Button("ネットワーク処理シミュレーション") {
                Logger.ui.info("ネットワークボタンがタップされました")
                simulateNetworkRequest()
            }
            .buttonStyle(.bordered)
            .disabled(isLoading)
            
            // エラーシミュレーションボタン
            Button("エラー処理デモ") {
                Logger.ui.info("エラーボタンがタップされました")
                simulateErrorHandling()
            }
            .buttonStyle(.bordered)
            .foregroundColor(.red)
            
            // コマンドライン確認デモボタン
            Button("コマンドライン確認デモ") {
                Logger.ui.info("コマンドライン確認デモがタップされました")
                demonstrateCommandLineLogging()
            }
            .buttonStyle(.bordered)
            .foregroundColor(.blue)
            
            // ログクリアボタン
            Button("ログクリア") {
                Logger.ui.info("ログがクリアされました")
                logMessages.removeAll()
            }
            .buttonStyle(.bordered)
            .foregroundColor(.orange)
        }
    }
    
    
    // MARK: - Log Display Section
    private var logDisplaySection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("アプリ内ログ表示")
                .font(.headline)
            
            ScrollView {
                LazyVStack(alignment: .leading, spacing: 4) {
                    ForEach(logMessages, id: \.self) { message in
                        Text(message)
                            .font(.caption)
                            .padding(.vertical, 2)
                    }
                }
            }
            .frame(height: 200)
            .background(Color.gray.opacity(0.1))
            .cornerRadius(8)
        }
    }
    
    // MARK: - Print vs Logger Demonstration
    private func demonstratePrintVsLogger() {
        Logger.app.debug("=== print文 vs Logger の比較デモ開始 ===")
        addLogMessage("🔄 比較デモを実行中...")
        
        let sampleEmail = "user@example.com"
        let samplePassword = "password123"
        
        // 危険なprint文の使用例
        print("❌ [PRINT] ユーザーメール: \(sampleEmail)")
        print("❌ [PRINT] パスワード: \(samplePassword)")
        print("❌ [PRINT] これらの情報は危険です！")
        
        // 安全なLoggerの使用例
        Logger.dataModel.info("✅ [LOGGER] ユーザーメール: \(sampleEmail, privacy: .private)")
        Logger.dataModel.info("✅ [LOGGER] パスワード: \(samplePassword, privacy: .private)")
        Logger.dataModel.info("✅ [LOGGER] プライバシー保護されています")
        
        // ユーザー情報の処理ログ
        if !userName.isEmpty {
            Logger.dataModel.info("入力されたユーザー名: \(userName, privacy: .private)")
            addLogMessage("👤 ユーザー名が処理されました")
        } else {
            Logger.dataModel.notice("ユーザー名が未入力です")
            addLogMessage("⚠️ ユーザー名が未入力")
        }
        
        Logger.app.debug("比較デモ完了")
        addLogMessage("✅ 比較デモ完了 - Xcodeコンソールを確認してください")
    }
    
    // MARK: - Network Request Simulation
    private func simulateNetworkRequest() {
        isLoading = true
        Logger.network.info("🌐 ネットワークリクエスト開始")
        addLogMessage("🌐 API呼び出し開始...")
        
        let apiUrl = "https://api.example.com/users"
        Logger.network.debug("リクエストURL: \(apiUrl)")
        
        // 非同期処理をシミュレーション
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            let success = Bool.random()
            
            if success {
                let responseCode = 200
                Logger.network.info("✅ API呼び出し成功 - レスポンスコード: \(responseCode)")
                Logger.network.debug("受信データサイズ: 1024 bytes")
                addLogMessage("✅ API呼び出し成功")
            } else {
                let errorCode = 500
                Logger.network.error("❌ API呼び出し失敗 - エラーコード: \(errorCode)")
                addLogMessage("❌ API呼び出し失敗")
            }
            
            isLoading = false
        }
    }
    
    // MARK: - Error Handling Simulation
    private func simulateErrorHandling() {
        Logger.app.info("🚨 エラー処理デモ開始")
        addLogMessage("🚨 エラー処理デモ開始")
        
        // 異なるレベルのログを出力
        Logger.app.debug("デバッグ情報: 詳細な処理情報")
        Logger.app.info("情報: 重要な状態変化")
        Logger.app.notice("注意: 重要だがエラーではない状況")
        Logger.app.error("エラー: 処理に失敗しました")
        Logger.app.fault("重大: システムエラーが発生")
        
        // アプリ内表示用
        let logLevels = ["DEBUG", "INFO", "NOTICE", "ERROR", "FAULT"]
        logLevels.forEach { level in
            addLogMessage("📝 \(level)レベルのログを出力")
        }
        
        Logger.app.info("エラー処理デモ完了")
        addLogMessage("✅ 全レベルのログ出力完了")
    }
    
    // MARK: - Command Line Logging Demo
    private func demonstrateCommandLineLogging() {
        Logger.app.info("📟 コマンドライン確認デモ開始")
        addLogMessage("📟 コマンドライン確認デモ開始")
        
        // コマンドラインで確認しやすいように特別なログを出力
        Logger.app.info("🔍 [CMD_DEMO] これはコマンドライン確認用のログです")
        Logger.network.error("🔍 [CMD_DEMO] ネットワークエラーのサンプル")
        Logger.ui.debug("🔍 [CMD_DEMO] UIデバッグ情報のサンプル")
        Logger.dataModel.notice("🔍 [CMD_DEMO] データモデルの注意事項")
        
        // print文も出力（比較用）
        print("🔍 [CMD_DEMO_PRINT] これはprint文による出力です")
        
        addLogMessage("✅ コマンドライン確認用ログを出力しました")
        addLogMessage("💡 ターミナルでlog showコマンドを実行してください")
    }
    
    // MARK: - Helper Methods
    private func addLogMessage(_ message: String) {
        DispatchQueue.main.async {
            let formatter = DateFormatter()
            formatter.dateFormat = "HH:mm:ss"
            let timestamp = formatter.string(from: Date())
            logMessages.append("[\(timestamp)] \(message)")
        }
    }
}

#Preview {
    ContentView()
}
