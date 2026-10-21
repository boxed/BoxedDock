import SwiftUI
import UniformTypeIdentifiers

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

// Number of quick-access slots, activated by typing 1...slotCount
let slotCount = 9
let slotsDefaultsKey = "quickAccessSlots"


let workspace = NSWorkspace.shared

extension String {
    func deletingPrefix(_ prefix: String) -> String {
        guard self.hasPrefix(prefix) else { return self }
        return String(self.dropFirst(prefix.count))
    }

    // Digits are reserved for the quick-access slots, so "1Password" is typed as "Password"
    var deletingLeadingDigits: String {
        return String(self.drop(while: { $0.isNumber }).drop(while: { $0.isWhitespace }))
    }
}

extension NSRunningApplication {
    var fixedName : String {
        return self.localizedName!.deletingPrefix("Microsoft ").deletingPrefix("Google ")
    }

    var searchName : String {
        return fixedName.deletingLeadingDigits
    }

    func matches(_ searchText: String) -> Bool {
        return searchName.lowercased().starts(with: searchText.lowercased())
    }
}

func loadSlots() -> [String] {
    let stored = UserDefaults.standard.stringArray(forKey: slotsDefaultsKey) ?? []
    return (0..<slotCount).map { $0 < stored.count ? stored[$0] : "" }
}

func saveSlots(_ slots: [String]) {
    UserDefaults.standard.set(slots, forKey: slotsDefaultsKey)
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

    @State var slots = loadSlots()

    func dismiss() {
        searchText = ""
        window!.orderOut(nil)
    }

    func activate(app: NSRunningApplication) {
//        assert(NSApp.windows.count == 1)
        app.activate(options: .activateAllWindows)
        dismiss()
    }

    func activate(bundleIdentifier: String) {
        if let app = NSRunningApplication.runningApplications(withBundleIdentifier: bundleIdentifier).first {
            activate(app: app)
        }
        else if let url = workspace.urlForApplication(withBundleIdentifier: bundleIdentifier) {
            workspace.openApplication(at: url, configuration: NSWorkspace.OpenConfiguration())
            dismiss()
        }
    }

    // If the app already sits in another slot, the two slots swap contents
    func assign(bundleIdentifier: String, toSlot index: Int) {
        if let previous = slots.firstIndex(of: bundleIdentifier) {
            slots[previous] = slots[index]
        }
        slots[index] = bundleIdentifier
        saveSlots(slots)
    }

    func clearSlot(_ index: Int) {
        slots[index] = ""
        saveSlots(slots)
    }

    var body: some View {
        VStack {
            TextField("", text: $searchText).opacity(0).onSubmit {
                // on enter
                for item in self.apps {
                    if item.matches(searchText) {
//                            NSWorkspace.shared.open(item.bundleURL!)
                        activate(app: item)
                        break
                    }
                }
            }
            .onChange(of: searchText) { _ in
                if searchText.isEmpty {
                    return
                }
                if searchText.count == 1, let number = Int(searchText), number >= 1, number <= slotCount {
                    if slots[number - 1].isEmpty {
                        searchText = ""
                    }
                    else {
                        activate(bundleIdentifier: slots[number - 1])
                    }
                    return
                }
                let hits = self.apps.filter { $0.matches(searchText) }
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
                        // Not a Button: on macOS a Button swallows the mouse drag so onDrag never fires
                        VStack {
                            SystemIcon(item)
                            .interpolation(.high)
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            
                            AppNameLabel(name: item.fixedName, searchText: searchText)
                            Spacer()
                        }
                        .contentShape(Rectangle())
                        .onTapGesture {
//                            NSWorkspace.shared.open(item.bundleURL!)
                            activate(app: item)
                        }
                        .onDrag {
                            NSItemProvider(object: (item.bundleIdentifier ?? "") as NSString)
                        }
                        //.overlay(AcceptingFirstMouse(app: item))
                        .opacity(item.matches(searchText) ? 1 : 0.1)
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

            // Quick-access slots
            HStack(spacing: 16) {
                ForEach(0..<slotCount, id: \.self) { index in
                    QuickAccessSlot(
                        number: index + 1,
                        bundleIdentifier: slots[index],
                        onActivate: { activate(bundleIdentifier: slots[index]) },
                        onDropBundleIdentifier: { assign(bundleIdentifier: $0, toSlot: index) },
                        onClear: { clearSlot(index) }
                    )
                }
            }
            .padding(.top, 20)

            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.black.opacity(0.8))
        .preferredColorScheme(.dark)
        .onAppear {
            contentView = self
        }
        .onExitCommand(perform: {
//            assert(NSApp.windows.count == 1)
            // on escape
            dismiss()
        })
    }
}

// App name with leading digits dimmed (they're not part of the typed name) and the typed prefix highlighted
struct AppNameLabel: View {
    let name: String
    let searchText: String

    var body: some View {
        let searchName = name.deletingLeadingDigits
        let digits = String(name.dropLast(searchName.count))
        let matched = !searchText.isEmpty && searchName.lowercased().starts(with: searchText.lowercased())
        let matchLength = matched ? searchText.count : 0

        return (
            Text(digits).foregroundColor(Color.primary.opacity(0.35))
            + Text(String(searchName.prefix(matchLength))).foregroundColor(.accentColor).bold()
            + Text(String(searchName.dropFirst(matchLength)))
        )
        .font(.system(size: 12))
        .lineLimit(1)
    }
}

struct QuickAccessSlot: View {
    let number: Int
    let bundleIdentifier: String
    let onActivate: () -> Void
    let onDropBundleIdentifier: (String) -> Void
    let onClear: () -> Void

    @State var isTargeted = false

    var appURL: URL? {
        bundleIdentifier.isEmpty ? nil : workspace.urlForApplication(withBundleIdentifier: bundleIdentifier)
    }

    var body: some View {
        VStack(spacing: 6) {
            ZStack {
                // The outline only marks empty slots, and drop targets while dragging
                if appURL == nil || isTargeted {
                    RoundedRectangle(cornerRadius: 14)
                        .strokeBorder(style: StrokeStyle(lineWidth: 2, dash: [6, 4]))
                        .foregroundColor(Color.primary.opacity(isTargeted ? 0.9 : 0.35))
                }
                if let url = appURL {
                    SystemIcon(path: url.path)
                        .interpolation(.high)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        // App icon artwork has a transparent margin, the visible shape is 824 of 1024 points
                        .scaleEffect(1024 / 824)
                }
            }
            .frame(width: 72, height: 72)
            .contentShape(Rectangle())
            .onTapGesture {
                if appURL != nil {
                    onActivate()
                }
            }
            .onDrag {
                NSItemProvider(object: bundleIdentifier as NSString)
            }
            .onDrop(of: [UTType.plainText], isTargeted: $isTargeted) { providers in
                guard let provider = providers.first else { return false }
                _ = provider.loadObject(ofClass: NSString.self) { object, _ in
                    guard let identifier = object as? String, !identifier.isEmpty else { return }
                    DispatchQueue.main.async {
                        onDropBundleIdentifier(identifier)
                    }
                }
                return true
            }
            .contextMenu {
                if appURL != nil {
                    Button("Remove") { onClear() }
                }
            }

            Text("\(number)")
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(Color.primary.opacity(0.6))
        }
    }
}

func SystemIcon(_ item: NSRunningApplication) -> Image {
    return SystemIcon(path: item.bundleURL!.path, fallback: item.icon)
}

func SystemIcon(path: String, fallback: NSImage? = nil) -> Image {
    let systemIcon = NSWorkspace.shared.icon(forFile: path)
    guard let icon = systemIcon
            .representations
            .first(where: { $0.size.width > 150 })?
            .cgImage(forProposedRect: nil, context: nil, hints: nil) else {
        return Image(nsImage: fallback ?? systemIcon)
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
