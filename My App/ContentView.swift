import SwiftUI

struct ContentView: View {
    @State var TweaksPath = "/var/jb/usr/lib/TweakInject"
    @State var Tweaks: [String] = []
    var body: some View {
        Form {
            Section(footer: Text("Made by @AppInstalleriOS")) {
                ForEach(Tweaks, id: \.self) { Tweak in
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
        .onAppear {
            do {
                Tweaks = try FileManager.default.contentsOfDirectory(atPath: TweaksPath) ?? []
            } catch {
                print(error)
            }
        }
    }
}

func GetTrollStoreApps() -> [String] {
    do {
        let AppBundlesPath = "/var/containers/Bundle/Application"
        let AppBundles = try FileManager.default.contentsOfDirectory(atPath: AppBundlesPath) ?? []
        for App in AppBundles.filter({FileManager.default.fileExists(atPath: "\(AppBundlesPath)/\($0)/_TrollStore")}) {
        }
    } catch {
        print(error)
    }
}
