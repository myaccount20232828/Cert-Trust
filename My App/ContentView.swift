import SwiftUI

struct ContentView: View {
    var body: some View {
        Form {
            Button {
                //DispatchQueue.global(qos: .utility).async {
                    getCertTrustSettings()
                //}
            } label: {
                Text("Trust")
            }
        }
    }
}


//void trustCertificate(NSString* certificatePath, PSGCertTrustSettings* certTrustSettings);
