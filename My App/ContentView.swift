import SwiftUI

struct ContentView: View {
    @State var certTrustSettings = getCertTrustSettings()
    var body: some View {
        if let certTrustSettings = certTrustSettings {
            ZStack {
                ViewControllerWrapper(certTrustSettings)
                .frame(width: 0, height: 0)
                Form {
                    Button {
                        trustCertificate("/var/mobile/Library/Filza/.Trash/cert.cer", certTrustSettings)
                    } label: {
                        Text("Trust 6")
                    }
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
