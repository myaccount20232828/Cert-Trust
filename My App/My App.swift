import SwiftUI

@main
struct MyApp: App {
    init() {
        dlopen("/System/Library/PrivateFrameworks/Settings/GeneralSettingsUI.framework/GeneralSettingsUI", RTLD_NOW)
    }
    var body: some Scene {
        WindowGroup {
            if let certTrustSettings = getCertTrustSettings() {
                ZStack {
                    ViewControllerWrapper(certTrustSettings)
                    .frame(width: 0, height: 0)
                    ContentView(certTrustSettings)
                }
            } else {
                Text("Unable to allocate PSGCertTrustSettings")
            }
        }
    }
}

struct ViewControllerWrapper: UIViewControllerRepresentable {
    var ViewController: UIViewController
    init(_ ViewController: UIViewController) {
        self.ViewController = ViewController
    }
    func makeUIViewController(context: Context) -> UIViewController {
        return ViewController
    }
    func updateUIViewController(_ uiViewController: UIViewController, context: Context) {
        
    }
}
