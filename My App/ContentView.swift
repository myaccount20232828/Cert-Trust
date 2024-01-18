import SwiftUI

struct ContentView: View {
    @State var ShouldTrust = true
    var body: some View {
        Form {
            Toggle("Should Trust", isOn: $ShouldTrust)
            Text(isCertificateTrusted("/var/mobile/Library/Filza/.Trash/cert.cer") ? "true" : "false")
            Button {
                trustCertificate("/var/mobile/Library/Filza/.Trash/cert.cer", ShouldTrust)
            } label: {
                Text("Set Trust")
            }
        }
    }
}
