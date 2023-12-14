import SwiftUI

struct ContentView: View {
    @State var TweaksPath = "/var/jb/usr/lib/TweakInject"
    var body: some View {
        Form {
            Section(footer: Text("Made by @AppInstalleriOS")) {
                ForEach(try FileManager.default.contentsOfDirectory(atPath: TweaksPath) ?? [], id: \.self) { Tweak in
                    Button {
                        DispatchQueue.global(qos: .utility).async {
                            InjectTweak("com.tigisoftware.Filza", "\(TweaksPath)/\(Tweak)")
                        }
                    } label: {
                        Text(Tweak)
                    }
                }
            }
        }
    }
}
