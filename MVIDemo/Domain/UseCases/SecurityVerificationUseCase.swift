//
//  SecurityVerificationUseCase.swift
//  MVIDemo
//
//  Created by Kylie on 2025/8/13.
//

import Foundation

protocol SecurityVerificationUseCase {
    func verifyPassword(_ password: String) async throws -> Bool
}

class SecurityVerificationUseCaseImpl: SecurityVerificationUseCase {
    func verifyPassword(_ password: String) async throws -> Bool {
        // 模擬網路請求延遲
        try await Task.sleep(nanoseconds: 1_000_000_000) // 1 second
        
        // 簡單的密碼驗證邏輯（實際應用中應該與後端驗證）
        // 這裡使用固定密碼 "123456" 作為示例
        return password == "123456"
    }
}