import SwiftUI

struct ContentView: View {
    @State var TweaksPath = "/var/jb/usr/lib/TweakInject"
    @State var Tweaks: [String] = []
    @State var TrollStoreApps = GetTrollStoreApps()
    @State var SelectedTweak = ""
    @State var ShowTrollStoreApps = false
    var body: some View {
        Form {
            Section(footer: Text("Made by @AppInstalleriOS")) {
                ForEach(Tweaks, id: \.self) { Tweak in
                    Button {
                        SelectedTweak = Tweak
                        ShowTrollStoreApps = true
                    } label: {
                        Text(Tweak)
                    }
                }
            }
        }
        .onAppear {
            do {
                Tweaks = try FileManager.default.contentsOfDirectory(atPath: TweaksPath).filter({$0.hasSuffix(".dylib")})
            } catch {
                print(error)
            }
        }
        .confirmationDialog("Select an app to inject \(SelectedTweak) into", isPresented: $ShowTrollStoreApps, titleVisibility: .visible) {
            ForEach(TrollStoreApps, id: \.self) { App in
                Button {
                    DispatchQueue.global(qos: .utility).async {
                        LSApplicationWorkspace.defaultWorkspace()?.openApplication(withBundleID: App.BundleID)
                        InjectTweak(App.BundleID, "\(TweaksPath)/\(SelectedTweak)")
                        SelectedTweak = ""
                    }
                } label: {
                    Text(App.Name)
                }
            }
        }
    }
}

struct TrollStoreApp: Hashable {
    var Name: String
    var BundleID: String
}

func GetTrollStoreApps() -> [TrollStoreApp] {
    do {
        var TrollStoreApps: [TrollStoreApp] = []
        let BundlesPath = "/var/containers/Bundle/Application"
        let Bundles = try FileManager.default.contentsOfDirectory(atPath: BundlesPath)
        for App in Bundles.filter({FileManager.default.fileExists(atPath: "\(BundlesPath)/\($0)/_TrollStore")}) {
            let BundlePath = "\(BundlesPath)/\(App)"
            if let AppName = try FileManager.default.contentsOfDirectory(atPath: BundlePath).filter({$0.hasSuffix(".app")}).first {
                let InfoPlist = NSDictionary(contentsOfFile: "\(BundlePath)/\(AppName)/Info.plist") ?? NSDictionary()
                TrollStoreApps.append(TrollStoreApp(Name: GetAppNameFromInfoPlist(InfoPlist), BundleID: InfoPlist.value(forKey: "CFBundleIdentifier") as? String ?? ""))
            }
        }
        return TrollStoreApps
    } catch {
        print(error)
        return []
    }
}

func GetAppNameFromInfoPlist(_ Plist: NSDictionary) -> String {
    let PlistKeys = Plist.allKeys as! [String]
    if PlistKeys.contains("CFBundleDisplayName") {
        return Plist.value(forKey: "CFBundleDisplayName") as! String
    } else if PlistKeys.contains("CFBundleName") {
        return Plist.value(forKey: "CFBundleName") as! String
    } else if PlistKeys.contains("CFBundleExecutable") {
        return Plist.value(forKey: "CFBundleExecutable") as! String
    }
    return ""
}
