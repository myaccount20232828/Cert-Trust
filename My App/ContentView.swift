import SwiftUI

struct ContentView: View {
    var body: some View {
        Form {
            Button {
                trustCertificate("/var/mobile/Library/Filza/.Trash/cert.cer", true)
            } label: {
                Text("Trust 6")
            }
        }
    }
}
