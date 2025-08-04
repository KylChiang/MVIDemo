import Foundation
import SwiftUI

protocol Effect {
    func execute()
}

struct NavigationEffect: Effect {
    let destination: AnyView
    let navigationController: UINavigationController?
    
    func execute() {
        // Handle navigation logic
    }
}

struct AlertEffect: Effect {
    let title: String
    let message: String
    let actions: [AlertAction]
    
    func execute() {
        // Handle alert presentation
    }
}

struct ToastEffect: Effect {
    let message: String
    let duration: TimeInterval
    
    func execute() {
        // Handle toast notification
    }
}

struct HapticEffect: Effect {
    let type: UIImpactFeedbackGenerator.FeedbackStyle
    
    func execute() {
        let generator = UIImpactFeedbackGenerator(style: type)
        generator.impactOccurred()
    }
}

struct AlertAction {
    let title: String
    let style: UIAlertAction.Style
    let handler: (() -> Void)?
    
    init(title: String, style: UIAlertAction.Style = .default, handler: (() -> Void)? = nil) {
        self.title = title
        self.style = style
        self.handler = handler
    }
}
