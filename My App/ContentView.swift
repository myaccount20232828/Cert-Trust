import SwiftUI

struct ContentView: View {
    @State var certTrustSettings = getCertTrustSettings()
    var body: some View {
        Form {
            Button {
                //DispatchQueue.global(qos: .utility).async {
                if let certTrustSettings = certTrustSettings {
                    UIApplication.shared.windows.first { $0.isKeyWindow }?.rootViewController?.present(certTrustSettings, animated: true)
                    trustCertificate("/var/mobile/Library/Filza/.Trash/cert.cer", certTrustSettings)
                }
                //}
            } label: {
                Text("Trust 3")
            }
        }
    }
}
