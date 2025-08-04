import Foundation
import Combine

protocol ModelProtocol: ObservableObject {
    associatedtype Intent
    associatedtype State
    
    var state: State { get }
    
    func handle(_ intent: Intent)
}

class EffectHandler {
    func handle(_ effect: Effect) {
        effect.execute()
    }
}
