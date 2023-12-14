import SwiftUI

struct ContentView: View {
    var body: some View {
        Form {
            Section(footer: Text("Made by @AppInstalleriOS")) {
                Button {
                    DispatchQueue.global(qos: .utility).async {
                        
                    }
                } label: {
                    Text("test")
                }
            }
        }
    }
}
