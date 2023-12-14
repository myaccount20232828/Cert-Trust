import SwiftUI

struct ContentView: View {
    @State var TweaksPath = "/var/jb/usr/lib/TweakInject"
    @State var Tweaks: [String] = []
    var body: some View {
        Form {
            ForEach(GetTrollStoreApps(), id: \.self) { App in
                VStack {
                    Text(App.Name)
                    Text(App.BundleID)
                }
            }
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

struct TrollStoreApp: Hashable {
    var Name: String
    var BundleID: String
}

func GetTrollStoreApps() -> [TrollStoreApp] {
    do {
        var TrollStoreApps: [TrollStoreApp] = []
        let BundlesPath = "/var/containers/Bundle/Application"
        let Bundles = try FileManager.default.contentsOfDirectory(atPath: BundlesPath) ?? []
        for App in Bundles.filter({FileManager.default.fileExists(atPath: "\(BundlesPath)/\($0)/_TrollStore")}) {
            let BundlePath = "\(AppBundlesPath)/\($0)"
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
