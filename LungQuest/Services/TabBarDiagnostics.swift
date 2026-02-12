import UIKit

/// Temporary debugging for tab bar touch failures (e.g. first launch / TestFlight).
/// Logs view hierarchy, windows, and any views that might block the tab bar.
/// Set enabled = true to capture logs on first launch; set false after confirming the fix.
enum TabBarDiagnostics {
    static let enabled = false // Set true to log hierarchy when debugging tab bar taps

    static func logHierarchy(label: String) {
        guard enabled else { return }
        DispatchQueue.main.async {
            _logHierarchy(label: label)
        }
    }

    private static func _logHierarchy(label: String) {
        print("[TabBarDiagnostics] ========== \(label) ==========")
        let scene = UIApplication.shared.connectedScenes
            .compactMap { $0 as? UIWindowScene }
            .first { $0.activationState == .foregroundActive }
        let windows = scene?.windows ?? []
        print("[TabBarDiagnostics] Window count: \(windows.count)")
        for (i, win) in windows.enumerated() {
            print("[TabBarDiagnostics]   Window[\(i)]: level=\(win.windowLevel.rawValue), frame=\(win.frame), isKeyWindow=\(win.isKeyWindow)")
            if let rvc = win.rootViewController {
                print("[TabBarDiagnostics]     rootViewController: \(type(of: rvc))")
                dumpView(rvc.view, depth: 2, tabBarFrame: nil)
            }
        }
        // Find tab bar and report views overlapping it
        if let keyWindow = scene?.windows.first(where: { $0.isKeyWindow }) ?? windows.first,
           let rvc = keyWindow.rootViewController {
            var tabBarFrame: CGRect?
            findTabBarFrame(in: rvc.view, result: &tabBarFrame)
            if let tbf = tabBarFrame {
                print("[TabBarDiagnostics] UITabBar frame: \(tbf)")
                print("[TabBarDiagnostics] Views that intersect tab bar (may block touches):")
                listViewsIntersecting(tabBarFrame: tbf, in: rvc.view, depth: 0)
            } else {
                print("[TabBarDiagnostics] No UITabBar found in hierarchy")
            }
        }
        print("[TabBarDiagnostics] ========== end \(label) ==========")
    }

    private static func dumpView(_ view: UIView, depth: Int, tabBarFrame: CGRect?) {
        let indent = String(repeating: "  ", count: depth)
        let interaction = view.isUserInteractionEnabled ? "interaction=Y" : "interaction=N"
        let alpha = view.alpha
        let hidden = view.isHidden
        let name = String(describing: type(of: view))
        let frame = view.frame
        let clip = view.clipsToBounds
        if depth <= 8 {
            print("\(indent)[TabBarDiagnostics] \(name) frame=\(frame) \(interaction) alpha=\(alpha) hidden=\(hidden) clipsToBounds=\(clip)")
        }
        for subview in view.subviews {
            dumpView(subview, depth: depth + 1, tabBarFrame: tabBarFrame)
        }
    }

    private static func findTabBarFrame(in view: UIView, result: inout CGRect?) {
        if view is UITabBar {
            result = view.convert(view.bounds, to: nil)
            return
        }
        for subview in view.subviews {
            findTabBarFrame(in: subview, result: &result)
            if result != nil { return }
        }
    }

    private static func listViewsIntersecting(tabBarFrame: CGRect, in view: UIView, depth: Int) {
        let name = String(describing: type(of: view))
        let frameInWindow = view.convert(view.bounds, to: nil)
        if frameInWindow.intersects(tabBarFrame) && view !== view.window {
            let interaction = view.isUserInteractionEnabled
            let alpha = view.alpha
            let hidden = view.isHidden
            let indent = String(repeating: "  ", count: depth)
            print("\(indent)  \(name) frame=\(frameInWindow) isUserInteractionEnabled=\(interaction) alpha=\(alpha) hidden=\(hidden)")
        }
        for subview in view.subviews {
            listViewsIntersecting(tabBarFrame: tabBarFrame, in: subview, depth: depth + 1)
        }
    }
}
