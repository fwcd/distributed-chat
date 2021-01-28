import Foundation
import Dispatch

/// A simple wrapper around GCD's timer that repeatedly invokes a handler.
class RepeatingTimer {
    private let timer: DispatchSourceTimer
    
    init(interval: TimeInterval, handler: @escaping () -> Void) {
        timer = DispatchSource.makeTimerSource()
        timer.schedule(deadline: .now() + interval, repeating: interval)
        timer.setEventHandler(handler: handler)
    }
    
    deinit {
        timer.cancel()
    }
}
