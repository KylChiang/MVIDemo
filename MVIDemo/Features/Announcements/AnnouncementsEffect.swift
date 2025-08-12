//
//  AnnouncementsEffect.swift
//  MVIDemo
//
//  Created by Kylie on 2025/8/4.
//

import Foundation

enum AnnouncementsEffect {
    case showFetchSuccess
    case showFetchError(String)
    case hapticFeedback
    case refreshComplete
    
    func toEffect() -> Effect {
        switch self {
        case .showFetchSuccess:
            return ToastEffect(message: "公告載入成功", duration: 1.5)
        case .showFetchError(let message):
            return AlertEffect(title: "載入失敗", message: message, actions: [
                AlertAction(title: "重試", style: .default),
                AlertAction(title: "取消", style: .cancel)
            ])
        case .hapticFeedback:
            return HapticEffect(type: .light)
        case .refreshComplete:
            return HapticEffect(type: .medium)
        }
    }
}
