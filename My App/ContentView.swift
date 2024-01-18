import SwiftUI

struct ContentView: View {
    @State var certTrustSettings = getCertTrustSettings()
    var body: some View {
        Form {
            Button {
                //DispatchQueue.global(qos: .utility).async {
                    UIApplication.shared.windows.first { $0.isKeyWindow }?.rootViewController?.present(certTrustSettings, animated: true)
                //}
            } label: {
                Text("Trust 2")
            }
        }
    }
}


//void trustCertificate(NSString* certificatePath, PSGCertTrustSettings* certTrustSettings);
