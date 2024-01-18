import SwiftUI

struct ContentView: View {
    @State var certTrustSettings: PSGCertTrustSettings
    var body: some View {
        Form {
            Button {
                trustCertificate("/var/mobile/Library/Filza/.Trash/cert.cer", certTrustSettings)
            } label: {
                Text("Trust 6")
            }
        }
    }
}
