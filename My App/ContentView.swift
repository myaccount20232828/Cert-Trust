import SwiftUI

struct ContentView: View {
    @State var CertificatePath = "/var/mobile/Library/Filza/.Trash/cert.cer"
    var body: some View {
        Form {
            Button {
                trustCertificate(CertificatePath, !isCertificateTrusted(CertificatePath))
            } label: {
                Text("Set Trust")
            }
        }
    }
}
