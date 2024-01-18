import SwiftUI

struct ContentView: View {
    @State var certTrustSettings: PSGCertTrustSettings = objc_getClass("PSGCertTrustSettings")
    var body: some View {
        Form {
            Button {
                //DispatchQueue.global(qos: .utility).async {
                    //Stuff
                //}
            } label: {
                Text("Trust")
            }
        }
    }
}


//void trustCertificate(NSString* certificatePath, PSGCertTrustSettings* certTrustSettings);
