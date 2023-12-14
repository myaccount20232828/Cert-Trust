import SwiftUI

struct ContentView: View {
    var body: some View {
        Form {
            Section(footer: Text("Made by @AppInstalleriOS")) {
                ForEach(try FileManager.default.contentsOfDirectory(atPath: "/var/jb/usr/lib/TweakInject") ?? [], id: \.self) { TweakName in
                    Button {
                        DispatchQueue.global(qos: .utility).async {
                            InjectTweak("com.tigisoftware.Filza", "/var/jb/usr/lib/TweakInject/\(TweakName)")
                        }
                    } label: {
                        Text("test")
                    }
                }
            }
        }
    }
}
