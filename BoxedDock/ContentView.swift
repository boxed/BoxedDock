import SwiftUI

// MARK: - Constants

// Items in the dock: Add any application you’d like to see in here
let sortOrder = [
    "Finder",
    "Safari",
    "PyCharm",
    "TextMate",
    "Linear",
    "Slack",
    "Messages",
    "Calendar",
    "Spotify",
    "Terminal",
    "NetNewsWire",
    "Notes",
    "Mail",
]


let workspace = NSWorkspace.shared

extension String {
    func deletingPrefix(_ prefix: String) -> String {
        guard self.hasPrefix(prefix) else { return self }
        return String(self.dropFirst(prefix.count))
    }
}

extension NSRunningApplication {
    var fixedName : String {
        return self.localizedName!.deletingPrefix("Microsoft ").deletingPrefix("Google ")
    }
}

func getRunningApplications() -> [NSRunningApplication] {
    return workspace.runningApplications
        .filter {
            $0.activationPolicy == .regular
        }.sorted { a, b in
            if sortOrder.contains(a.fixedName) && !sortOrder.contains(b.fixedName) {
                return true
            }

            if sortOrder.contains(b.fixedName) && !sortOrder.contains(a.fixedName) {
                return false
            }
            
            if sortOrder.contains(a.fixedName) && sortOrder.contains(b.fixedName) {
                return sortOrder.firstIndex(of: a.fixedName)! < sortOrder.firstIndex(of: b.fixedName)!
            }

            if let a = a.launchDate, let b = b.launchDate {
                return a < b
            }
            return true
        }
}

// MARK: - View

var contentView: ContentView? = nil

struct ContentView: View {

    @State var apps = getRunningApplications()
    
    @State var searchText = ""

    func activate(app: NSRunningApplication) {
        assert(NSApp.windows.count == 1)
        app.activate(options: .activateAllWindows)
        searchText = ""
        window!.orderOut(nil)
    }

    var body: some View {
        VStack {
            TextField("", text: $searchText).opacity(0).onSubmit {
                // on enter
                for item in self.apps {
                    if item.fixedName.lowercased().starts(with: searchText.lowercased()) {
//                            NSWorkspace.shared.open(item.bundleURL!)
                        activate(app: item)
                        break
                    }
                }
            }
            .onChange(of: searchText) { _ in
                var hits : [NSRunningApplication] = []
                for item in self.apps {
                    if item.fixedName.lowercased().starts(with: searchText.lowercased()) {
                        hits.append(item)
                    }
                }
                if hits.count == 1 {
                    activate(app: hits[0])
                }
            }
            .frame(height: 1)
            
            Spacer()

            // Front
            ZStack(alignment: .bottom) {
                // Icons
                HStack {
                    ForEach(apps, id: \.self) { item in
                        Button {
//                            NSWorkspace.shared.open(item.bundleURL!)
                            activate(app: item)
                        } label: {
                            VStack {
                                SystemIcon(item)
                                .interpolation(.high)
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                
                                Text(item.fixedName.description).font(.system(size: 12)).lineLimit(1)
                                Spacer()
                            }
                        }
                        .buttonStyle(PlainButtonStyle())
                        //.overlay(AcceptingFirstMouse(app: item))
                        .opacity((item.fixedName.lowercased().starts(with: searchText.lowercased())) ? 1 : 0.1)
                    }
                }
                .frame(height: 120)
                .offset(y: -5)


                // Running indicators
//                HStack(alignment: .bottom, spacing: 70) {
//                    ForEach(items, id: \.self) { item in
//                        if NSWorkspace.shared
//                            .runningApplications
//                            .first(where: { $0.bundleURL?.absoluteString.contains(item) ?? false }) != nil {
//                            Rectangle()
//                                .fill(Color.white)
//                                .frame(width: 13, height: 8)
//                                .offset(y: 5)
//                                .shadow(color: Color(red: 168/255, green: 238/255, blue: 1), radius: 7, x: 0, y: 0)
//                        } else {
//                            Spacer().frame(width: 13)
//                        }
//                    }
//                }
            }
            Spacer()
        }
        .onAppear {
            contentView = self
        }
        .onExitCommand(perform: {
            assert(NSApp.windows.count == 1)
            // on escape
            searchText = ""
            window!.orderOut(nil)
        })
    }
}

func SystemIcon(_ item: NSRunningApplication) -> Image {
    guard let icon =
            NSWorkspace.shared.icon(forFile: item.bundleURL!.absoluteString.replacingOccurrences(of: "file://", with: ""))
            .representations
            .first(where: { $0.size.width > 150 })?
            .cgImage(forProposedRect: nil, context: nil, hints: nil) else {
        return Image(nsImage:item.icon!)
    }
    let nsImage = NSImage(cgImage: icon, size: CGSize(width: icon.width, height: icon.height))
    return Image(nsImage: nsImage)
}

// MARK: - Supporting Functions

class MyViewView : NSView {
    var app : NSRunningApplication? = nil

    override func acceptsFirstMouse(for event: NSEvent?) -> Bool {
        NSWorkspace.shared.open(app!.bundleURL!)
        return true
    }
}

// Representable wrapper (bridge to SwiftUI)
struct AcceptingFirstMouse : NSViewRepresentable {
    let app : NSRunningApplication
    
    init(app : NSRunningApplication) {
        self.app = app
    }
    
    func makeNSView(context: NSViewRepresentableContext<AcceptingFirstMouse>) -> MyViewView {
        let x = MyViewView()
        x.app = app
        return x
    }

    func updateNSView(_ nsView: MyViewView, context: NSViewRepresentableContext<AcceptingFirstMouse>) {
        nsView.setNeedsDisplay(nsView.bounds)
    }

    typealias NSViewType = MyViewView
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
