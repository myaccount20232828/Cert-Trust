import SwiftUI

struct ContentView: View {
    @State var CertificatePath = "/var/mobile/Library/Filza/.Trash/cert.cer"
    var body: some View {
        Form {
            Button {
                trustCertificate(CertificatePath, !isCertificateTrusted(CertificatePath))
                //Auto trust
                if let Alert = UIApplication.shared.windows.first?.rootViewController.presentedViewController as? UIAlertController {
                    UIPasteboard.general.string = "good"
                    Alert.actions[1].trigger()
                } else {
                    UIPasteboard.general.string = "bad"
                }
            } label: {
                Text("Set Trust 1")
            }
        }
    }
}
