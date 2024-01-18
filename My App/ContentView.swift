import SwiftUI

struct ContentView: View {
    @State var certTrustSettings = getCertTrustSettings()
    var body: some View {
        if let certTrustSettings = certTrustSettings {
            Form {
                ViewControllerWrapper(certTrustSettings)
                .frame(width: 50, height: 50)
                Button {
                    //UIApplication.shared.windows.first { $0.isKeyWindow }?.rootViewController?.present(certTrustSettings, animated: true)
                    trustCertificate("/var/mobile/Library/Filza/.Trash/cert.cer", certTrustSettings)
                } label: {
                    Text("Trust 4")
                }
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
