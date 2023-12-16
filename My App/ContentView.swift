import SwiftUI

struct ContentView: View {
    @AppStorage("HiddenRootPath") var HiddenRootPath = ""
    @State var RootPath = ""
    @State var Tweaks: [String] = []
    @State var TrollStoreApps = GetTrollStoreApps()
    @State var SelectedTweak = ""
    @State var ShowTrollStoreApps = false
    @State var LogItems: [String.SubSequence] = ["Ready!"]
    @State var ShowLog = false
    var body: some View {
        Form {
            if ShowLog {
                ScrollViewReader { scroll in
                    VStack(alignment: .leading) {
                        ForEach(0..<LogItems.count, id: \.self) { LogItem in
                            Text("[*] \(String(LogItems[LogItem]))")
                            .textSelection(.enabled)
                            .font(.custom("Menlo", size: 15))
                        }
                    }
                    .onReceive(NotificationCenter.default.publisher(for: LogStream.shared.reloadNotification)) { obj in
                         DispatchQueue.global(qos: .utility).async {
                            FetchLog()
                            scroll.scrollTo(LogItems.count - 1)
                        }
                    }
                }
            }
            Section {
                ForEach(Tweaks, id: \.self) { Tweak in
                    Button {
                        SelectedTweak = Tweak
                        ShowTrollStoreApps = true
                    } label: {
                        Text(Tweak)
                    }
                }
            }
            .disabled(!FileManager.default.fileExists(atPath: "/var/jb"))
            Section(footer: Text("Made by @AppInstalleriOS")) {
                Toggle("Show Log", isOn: $ShowLog)
                Button {
                    if FileManager.default.fileExists(atPath: "/var/jb") {
                        HiddenRootPath = "/var/\(UUID().uuidString)"
                        spawnRoot("\(RootPath)/usr/bin/RootHelper", ["mv", "/var/jb", HiddenRootPath])
                    } else {
                        spawnRoot("\(RootPath)/usr/bin/RootHelper", ["mv", HiddenRootPath, "/var/jb"])
                        HiddenRootPath = ""
                    }
                    RootPath = FileManager.default.fileExists(atPath: "/var/jb") ? "/var/jb" : HiddenRootPath
                } label: {
                    Text(FileManager.default.fileExists(atPath: "/var/jb") ? "Hide" : "Show")
                }
                Text(RootPath)
                Button {
                    SignAll(RootPath)
                } label: {
                    Text("Sign All")
                }
            }
        }
        .onAppear {
            do {
                RootPath = FileManager.default.fileExists(atPath: "/var/jb") ? "/var/jb" : HiddenRootPath
                Tweaks = try FileManager.default.contentsOfDirectory(atPath: "\(RootPath)/usr/lib/TweakInject").filter({$0.hasSuffix(".dylib")})
            } catch {
                print(error)
            }
        }
        .confirmationDialog("Select an app to inject \(SelectedTweak) into", isPresented: $ShowTrollStoreApps, titleVisibility: .visible) {
            ForEach(TrollStoreApps.filter({$0.BundleID != Bundle.main.bundleIdentifier}), id: \.self) { App in
                Button {
                    DispatchQueue.global(qos: .utility).async {
                        LSApplicationWorkspace.default()?.openApplication(withBundleID: App.BundleID)
                        InjectTweak(App.BundleID, "/var/jb/usr/lib/TweakInject/\(SelectedTweak)", "/var/jb")
                        SelectedTweak = ""
                    }
                } label: {
                    Text(App.Name)
                }
            }
        }
    }
    func FetchLog() {
        guard let AttributedText = LogStream.shared.outputString.copy() as? NSAttributedString else {
            LogItems = ["Error Getting Log!"]
            return
        }
        LogItems = AttributedText.string.split(separator: "\n")
    }
}

func SignAll(_ RootPath: String) {
    let AllFiles = (FileManager.default.subpaths(atPath: RootPath) ?? []).filter({IsFile($0)})
    for File in AllFiles {
        print(File)
    }
}

func IsFile(_ Path: String) -> Bool {
    var IsDirectory: ObjCBool = false
    FileManager.default.fileExists(atPath: Path, isDirectory: &IsDirectory)
    return !IsDirectory.boolValue
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

//From https://github.com/Odyssey-Team/Taurine/blob/main/Taurine/app/LogStream.swift
//Code from Taurine https://github.com/Odyssey-Team/Taurine under BSD 4 License
class LogStream {
    static let shared = LogStream()
    private(set) var outputString: NSMutableAttributedString = NSMutableAttributedString()
    public let reloadNotification = Notification.Name("LogStreamReloadNotification")
    private(set) var outputFd: [Int32] = [0, 0]
    private(set) var errFd: [Int32] = [0, 0]
    private let readQueue: DispatchQueue
    private let outputSource: DispatchSourceRead
    private let errorSource: DispatchSourceRead
    init() {
        readQueue = DispatchQueue(label: "org.coolstar.sileo.logstream", qos: .userInteractive, attributes: .concurrent, autoreleaseFrequency: .inherit, target: nil)
        guard pipe(&outputFd) != -1,
            pipe(&errFd) != -1 else {
                fatalError("pipe failed")
        }
        let origOutput = dup(STDOUT_FILENO)
        let origErr = dup(STDERR_FILENO)
        setvbuf(stdout, nil, _IONBF, 0)
        guard dup2(outputFd[1], STDOUT_FILENO) >= 0,
            dup2(errFd[1], STDERR_FILENO) >= 0 else {
                fatalError("dup2 failed")
        }
        outputSource = DispatchSource.makeReadSource(fileDescriptor: outputFd[0], queue: readQueue)
        errorSource = DispatchSource.makeReadSource(fileDescriptor: errFd[0], queue: readQueue)
        outputSource.setCancelHandler {
            close(self.outputFd[0])
            close(self.outputFd[1])
        }
        errorSource.setCancelHandler {
            close(self.errFd[0])
            close(self.errFd[1])
        }
        let bufsiz = Int(BUFSIZ)
        outputSource.setEventHandler {
            let buffer = UnsafeMutablePointer<UInt8>.allocate(capacity: bufsiz)
            defer { buffer.deallocate() }
            let bytesRead = read(self.outputFd[0], buffer, bufsiz)
            guard bytesRead > 0 else {
                if bytesRead == -1 && errno == EAGAIN {
                    return
                }
                self.outputSource.cancel()
                return
            }
            write(origOutput, buffer, bytesRead)
            let array = Array(UnsafeBufferPointer(start: buffer, count: bytesRead)) + [UInt8(0)]
            array.withUnsafeBufferPointer { ptr in
                let str = String(cString: unsafeBitCast(ptr.baseAddress, to: UnsafePointer<CChar>.self))
                let textColor = UIColor.white
                let substring = NSMutableAttributedString(string: str, attributes: [NSAttributedString.Key.foregroundColor: textColor])
                self.outputString.append(substring)
                DispatchQueue.main.async {
                    NotificationCenter.default.post(name: self.reloadNotification, object: nil)
                }
            }
        }
        errorSource.setEventHandler {
            let buffer = UnsafeMutablePointer<UInt8>.allocate(capacity: bufsiz)
            defer { buffer.deallocate() }
            let bytesRead = read(self.errFd[0], buffer, bufsiz)
            guard bytesRead > 0 else {
                if bytesRead == -1 && errno == EAGAIN {
                    return
                }
                self.errorSource.cancel()
                return
            }
            write(origErr, buffer, bytesRead)
            let array = Array(UnsafeBufferPointer(start: buffer, count: bytesRead)) + [UInt8(0)]
            array.withUnsafeBufferPointer { ptr in
                let str = String(cString: unsafeBitCast(ptr.baseAddress, to: UnsafePointer<CChar>.self))
                let textColor = UIColor(red: 219/255.0, green: 44.0/255.0, blue: 56.0/255.0, alpha: 1)
                let substring = NSMutableAttributedString(string: str, attributes: [NSAttributedString.Key.foregroundColor: textColor])
                self.outputString.append(substring)
                DispatchQueue.main.async {
                    NotificationCenter.default.post(name: self.reloadNotification, object: nil)
                }
            }
        }
        outputSource.resume()
        errorSource.resume()
    }
}
