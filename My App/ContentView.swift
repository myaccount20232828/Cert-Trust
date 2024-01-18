import SwiftUI

struct ContentView: View {
    var body: some View {
        Form {
            Button {
                //DispatchQueue.global(qos: .utility).async {
                    var obj: PSGCertTrustSettings = objc_getClass("PSGCertTrustSettings") as! PSGCertTrustSettings
                    let certTrustSettings = obj.perform(Selector(("alloc")))?.takeUnretainedValue() as! PSGCertTrustSettings
                //}
            } label: {
                Text("Trust")
            }
        }
    }
}


//void trustCertificate(NSString* certificatePath, PSGCertTrustSettings* certTrustSettings);
