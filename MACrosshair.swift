import Cocoa
import Carbon

// MARK: - Crosshair Settings
class CrosshairSettings {
    var color: NSColor = .red
    var lineLength: CGFloat = 12
    var lineThickness: CGFloat = 2
    var showDot: Bool = true
    var dotSize: CGFloat = 4
    var opacity: CGFloat = 0.85
    var offsetX: CGFloat = 0
    var offsetY: CGFloat = 0
}
// Jiwon and Joowon are handsome.
// Joowon and Jiwon are awesome. 
// MARK: - Hotkey Shortcut
struct HotKeyShortcut {
    var keyCode: UInt32
    var modifiers: UInt32
    var displayName: String
}

// MARK: - Theme
enum SettingsTheme: String, CaseIterable {
    case light = "Light Mode"
    case dark = "Dark Mode"
    case clear = "Clear"

    var textColor: NSColor {
        switch self {
        case .light:
            return .black
        case .dark, .clear:
            return .white
        }
    }
}

// MARK: - Glass View
class GlassSettingsView: NSView {
    private let blurView = NSVisualEffectView()

    override var allowsVibrancy: Bool {
        false
    }

    var theme: SettingsTheme = .clear {
        didSet {
            applyAppearance()
        }
    }

    override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)

        wantsLayer = true
        layer?.cornerRadius = 22
        layer?.masksToBounds = true

        blurView.blendingMode = .behindWindow
        blurView.state = .active
        blurView.material = .hudWindow
        blurView.alphaValue = 0.75
        blurView.autoresizingMask = [.width, .height]

        addSubview(blurView, positioned: .below, relativeTo: nil)

        applyAppearance()
    }

    required init?(coder: NSCoder) {
        fatalError()
    }

    override func layout() {
        super.layout()
        blurView.frame = bounds
    }

    func applyAppearance() {
        switch theme {
        case .light:
            blurView.isHidden = true
            layer?.backgroundColor = NSColor.white.cgColor

        case .dark:
            blurView.isHidden = true
            layer?.backgroundColor = NSColor.black.cgColor

        case .clear:
            blurView.isHidden = false
            blurView.material = .hudWindow
            blurView.alphaValue = 0.75
            layer?.backgroundColor = NSColor.clear.cgColor
        }

        needsDisplay = true
    }

    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)

        let rect = bounds.insetBy(dx: 1.5, dy: 1.5)
        let path = NSBezierPath(roundedRect: rect, xRadius: 22, yRadius: 22)

        switch theme {
        case .light:
            NSColor.black.withAlphaComponent(0.18).setStroke()
        case .dark:
            NSColor.white.withAlphaComponent(0.20).setStroke()
        case .clear:
            NSColor.white.withAlphaComponent(0.42).setStroke()
        }

        path.lineWidth = 1.4
        path.stroke()

        let innerRect = bounds.insetBy(dx: 7, dy: 7)
        let innerPath = NSBezierPath(roundedRect: innerRect, xRadius: 17, yRadius: 17)

        switch theme {
        case .light:
            NSColor.black.withAlphaComponent(0.08).setStroke()
        case .dark:
            NSColor.white.withAlphaComponent(0.08).setStroke()
        case .clear:
            NSColor.white.withAlphaComponent(0.22).setStroke()
        }

        innerPath.lineWidth = 2.0
        innerPath.stroke()
    }
}

// MARK: - Crosshair View
class CrosshairView: NSView {
    var settings: CrosshairSettings

    init(frame: NSRect, settings: CrosshairSettings) {
        self.settings = settings
        super.init(frame: frame)
    }

    required init?(coder: NSCoder) {
        fatalError()
    }

    override func draw(_ rect: NSRect) {
        // Apply offset from the true center
        let cx = bounds.midX + settings.offsetX
        let cy = bounds.midY + settings.offsetY
        let l = settings.lineLength
        let t = settings.lineThickness
        let color = settings.color.withAlphaComponent(settings.opacity)

        color.setFill()

        NSRect(x: cx - t / 2, y: cy - l, width: t, height: l * 2).fill()
        NSRect(x: cx - l, y: cy - t / 2, width: l * 2, height: t).fill()

        if settings.showDot {
            let d = settings.dotSize
            NSBezierPath(
                ovalIn: NSRect(
                    x: cx - d / 2,
                    y: cy - d / 2,
                    width: d,
                    height: d
                )
            ).fill()
        }
    }
}

// MARK: - Settings Window
class SettingsWindowController: NSWindowController {
    var settings: CrosshairSettings
    var crosshairView: CrosshairView
    var overlayWindow: NSWindow

    var shortcutButton: NSButton?
    var recordingMonitor: Any?

    var glassView: GlassSettingsView?
    var theme: SettingsTheme = .clear
    var labels: [NSTextField] = []
    var dotCheckButton: NSButton?

    // Offset input fields
    var offsetXField: NSTextField?
    var offsetYField: NSTextField?

    init(settings: CrosshairSettings, crosshairView: CrosshairView, overlayWindow: NSWindow) {
        self.settings = settings
        self.crosshairView = crosshairView
        self.overlayWindow = overlayWindow

        let win = NSWindow(
            contentRect: NSRect(x: 0, y: 0, width: 340, height: 720),
            styleMask: [.titled, .closable, .miniaturizable, .resizable, .fullSizeContentView],
            backing: .buffered,
            defer: false
        )

        win.title = "Crosshair Settings"
        win.center()
        win.isOpaque = false
        win.backgroundColor = .clear
        win.titlebarAppearsTransparent = true
        win.isMovableByWindowBackground = true
        win.hasShadow = true
        win.minSize = NSSize(width: 340, height: 720)

        let glassView = GlassSettingsView(frame: win.contentView!.bounds)
        glassView.autoresizingMask = [.width, .height]
        glassView.theme = theme

        win.contentView = glassView
        self.glassView = glassView

        super.init(window: win)

        win.delegate = self
        buildUI(in: glassView)
        updateWindowAppearance()
    }

    required init?(coder: NSCoder) {
        fatalError()
    }

    func buildUI(in view: NSView) {
        var y: CGFloat = 660

        func label(_ text: String) -> NSTextField {
            let l = NSTextField(labelWithString: text)
            l.frame = NSRect(x: 24, y: y, width: 292, height: 20)
            l.autoresizingMask = [.minYMargin, .width]
            l.font = NSFont.boldSystemFont(ofSize: 12)
            l.textColor = theme.textColor
            view.addSubview(l)
            labels.append(l)
            y -= 26
            return l
        }

        func slider(min: Double, max: Double, value: Double, action: Selector) -> NSSlider {
            let s = NSSlider(frame: NSRect(x: 24, y: y, width: 292, height: 22))
            s.autoresizingMask = [.minYMargin, .width]
            s.minValue = min
            s.maxValue = max
            s.doubleValue = value
            s.target = self
            s.action = action
            view.addSubview(s)
            y -= 36
            return s
        }

        let btn = NSButton(frame: NSRect(x: 24, y: y, width: 292, height: 32))
        btn.autoresizingMask = [.minYMargin, .width]
        btn.title = "Hide Crosshair"
        btn.bezelStyle = .rounded
        btn.target = self
        btn.action = #selector(toggleCrosshair)
        btn.tag = 99
        view.addSubview(btn)
        y -= 48

        _ = label("Theme")

        let themePicker = NSPopUpButton(frame: NSRect(x: 24, y: y, width: 292, height: 30))
        themePicker.autoresizingMask = [.minYMargin, .width]
        themePicker.addItems(withTitles: SettingsTheme.allCases.map { $0.rawValue })
        themePicker.selectItem(withTitle: theme.rawValue)
        themePicker.target = self
        themePicker.action = #selector(themeChanged(_:))
        view.addSubview(themePicker)
        y -= 46

        _ = label("Toggle Shortcut")

        let shortcutButton = NSButton(frame: NSRect(x: 24, y: y, width: 292, height: 32))
        shortcutButton.autoresizingMask = [.minYMargin, .width]
        shortcutButton.title = (NSApp.delegate as? AppDelegate)?.hotKeyShortcut.displayName ?? "Y"
        shortcutButton.bezelStyle = .rounded
        shortcutButton.target = self
        shortcutButton.action = #selector(recordShortcut)
        view.addSubview(shortcutButton)
        self.shortcutButton = shortcutButton
        y -= 48

        _ = label("Color")

        let colorRow = NSStackView(frame: NSRect(x: 24, y: y, width: 292, height: 32))
        colorRow.autoresizingMask = [.minYMargin, .width]
        colorRow.orientation = .horizontal
        colorRow.spacing = 8
        colorRow.distribution = .fillEqually

        for name in ["Red", "Green", "White", "Yellow", "Cyan"] {
            let b = NSButton(frame: .zero)
            b.title = name
            b.bezelStyle = .rounded
            b.target = self
            b.action = #selector(colorChanged(_:))
            b.identifier = NSUserInterfaceItemIdentifier(name)
            colorRow.addArrangedSubview(b)
        }

        view.addSubview(colorRow)
        y -= 48

        _ = label("Line Length")
        _ = slider(
            min: 4,
            max: 40,
            value: Double(settings.lineLength),
            action: #selector(lengthChanged(_:))
        )

        _ = label("Line Thickness")
        _ = slider(
            min: 1,
            max: 8,
            value: Double(settings.lineThickness),
            action: #selector(thicknessChanged(_:))
        )

        let dotCheck = NSButton(
            checkboxWithTitle: "Show Center Dot",
            target: self,
            action: #selector(dotToggled(_:))
        )
        dotCheck.frame = NSRect(x: 24, y: y, width: 292, height: 22)
        dotCheck.autoresizingMask = [.minYMargin, .width]
        dotCheck.state = settings.showDot ? .on : .off
        dotCheck.contentTintColor = theme.textColor
        view.addSubview(dotCheck)

        dotCheckButton = dotCheck
        y -= 36

        _ = label("Dot Size")
        _ = slider(
            min: 2,
            max: 12,
            value: Double(settings.dotSize),
            action: #selector(dotSizeChanged(_:))
        )

        _ = label("Crosshair Opacity")
        _ = slider(
            min: 0.1,
            max: 1.0,
            value: Double(settings.opacity),
            action: #selector(opacityChanged(_:))
        )

        // MARK: Offset Controls
        _ = label("Crosshair Offset (px)")

        // X offset row
        let xLabel = NSTextField(labelWithString: "X:")
        xLabel.frame = NSRect(x: 24, y: y, width: 20, height: 22)
        xLabel.autoresizingMask = [.minYMargin]
        xLabel.textColor = theme.textColor
        view.addSubview(xLabel)
        labels.append(xLabel)

        let xField = NSTextField(frame: NSRect(x: 48, y: y, width: 100, height: 22))
        xField.autoresizingMask = [.minYMargin]
        xField.placeholderString = "0"
        xField.stringValue = "0"
        xField.bezelStyle = .roundedBezel
        xField.target = self
        xField.action = #selector(offsetXChanged(_:))
        view.addSubview(xField)
        offsetXField = xField

        // Y offset row (same line, right side)
        let yLabel = NSTextField(labelWithString: "Y:")
        yLabel.frame = NSRect(x: 168, y: y, width: 20, height: 22)
        yLabel.autoresizingMask = [.minYMargin]
        yLabel.textColor = theme.textColor
        view.addSubview(yLabel)
        labels.append(yLabel)

        let yField = NSTextField(frame: NSRect(x: 192, y: y, width: 100, height: 22))
        yField.autoresizingMask = [.minYMargin]
        yField.placeholderString = "0"
        yField.stringValue = "0"
        yField.bezelStyle = .roundedBezel
        yField.target = self
        yField.action = #selector(offsetYChanged(_:))
        view.addSubview(yField)
        offsetYField = yField

        y -= 36

        // Reset offset button
        let resetBtn = NSButton(frame: NSRect(x: 24, y: y, width: 292, height: 28))
        resetBtn.autoresizingMask = [.minYMargin, .width]
        resetBtn.title = "Reset Offset"
        resetBtn.bezelStyle = .rounded
        resetBtn.target = self
        resetBtn.action = #selector(resetOffset)
        view.addSubview(resetBtn)
        y -= 40
    }

    func updateWindowAppearance() {
        switch theme {
        case .light:
            window?.appearance = NSAppearance(named: .aqua)
        case .dark, .clear:
            window?.appearance = NSAppearance(named: .darkAqua)
        }
    }

    func updateThemeControls() {
        for label in labels {
            label.textColor = theme.textColor
        }

        dotCheckButton?.contentTintColor = theme.textColor
    }

    func refresh() {
        crosshairView.needsDisplay = true
    }

    @objc func toggleCrosshair() {
        (NSApp.delegate as? AppDelegate)?.toggleCrosshairVisibility()
    }

    @objc func themeChanged(_ sender: NSPopUpButton) {
        guard
            let title = sender.selectedItem?.title,
            let newTheme = SettingsTheme(rawValue: title)
        else {
            return
        }

        theme = newTheme
        glassView?.theme = newTheme
        updateThemeControls()
        updateWindowAppearance()
    }

    @objc func recordShortcut() {
        shortcutButton?.title = "Press shortcut..."

        (NSApp.delegate as? AppDelegate)?.unregisterCurrentHotKey()

        if let recordingMonitor {
            NSEvent.removeMonitor(recordingMonitor)
            self.recordingMonitor = nil
        }

        recordingMonitor = NSEvent.addLocalMonitorForEvents(matching: .keyDown) { [weak self] event in
            guard let self else {
                return event
            }

            let flags = event.modifierFlags.intersection(.deviceIndependentFlagsMask)

            var carbonModifiers: UInt32 = 0
            var displayParts: [String] = []

            if flags.contains(.command) {
                carbonModifiers |= UInt32(cmdKey)
                displayParts.append("Command")
            }

            if flags.contains(.shift) {
                carbonModifiers |= UInt32(shiftKey)
                displayParts.append("Shift")
            }

            if flags.contains(.option) {
                carbonModifiers |= UInt32(optionKey)
                displayParts.append("Option")
            }

            if flags.contains(.control) {
                carbonModifiers |= UInt32(controlKey)
                displayParts.append("Control")
            }

            let keyName = (event.charactersIgnoringModifiers ?? "").uppercased()

            guard !keyName.isEmpty else {
                self.shortcutButton?.title = "Try another key"
                (NSApp.delegate as? AppDelegate)?.registerToggleHotKey()
                return nil
            }

            displayParts.append(keyName)

            let shortcut = HotKeyShortcut(
                keyCode: UInt32(event.keyCode),
                modifiers: carbonModifiers,
                displayName: displayParts.joined(separator: " + ")
            )

            (NSApp.delegate as? AppDelegate)?.updateHotKey(shortcut)

            self.shortcutButton?.title = shortcut.displayName

            if let recordingMonitor = self.recordingMonitor {
                NSEvent.removeMonitor(recordingMonitor)
                self.recordingMonitor = nil
            }

            return nil
        }
    }

    @objc func colorChanged(_ sender: NSButton) {
        let map: [String: NSColor] = [
            "Red": .red,
            "Green": .green,
            "White": .white,
            "Yellow": .yellow,
            "Cyan": .cyan
        ]

        if let c = map[sender.identifier?.rawValue ?? ""] {
            settings.color = c
            refresh()
        }
    }

    @objc func lengthChanged(_ sender: NSSlider) {
        settings.lineLength = CGFloat(sender.doubleValue)
        refresh()
    }

    @objc func thicknessChanged(_ sender: NSSlider) {
        settings.lineThickness = CGFloat(sender.doubleValue)
        refresh()
    }

    @objc func dotToggled(_ sender: NSButton) {
        settings.showDot = sender.state == .on
        refresh()
    }

    @objc func dotSizeChanged(_ sender: NSSlider) {
        settings.dotSize = CGFloat(sender.doubleValue)
        refresh()
    }

    @objc func opacityChanged(_ sender: NSSlider) {
        settings.opacity = CGFloat(sender.doubleValue)
        refresh()
    }

    // MARK: - Offset Actions

    @objc func offsetXChanged(_ sender: NSTextField) {
        let value = CGFloat(sender.doubleValue)
        settings.offsetX = value
        refresh()
    }

    @objc func offsetYChanged(_ sender: NSTextField) {
        let value = CGFloat(sender.doubleValue)
        settings.offsetY = value
        refresh()
    }

    @objc func resetOffset() {
        settings.offsetX = 0
        settings.offsetY = 0
        offsetXField?.stringValue = "0"
        offsetYField?.stringValue = "0"
        refresh()
    }
}

extension SettingsWindowController: NSWindowDelegate {
    func windowWillClose(_ notification: Notification) {
        (NSApp.delegate as? AppDelegate)?.unregisterCurrentHotKey()
        NSApp.terminate(nil)
    }
}

// MARK: - App Delegate
class AppDelegate: NSObject, NSApplicationDelegate {
    var overlayWindow: NSWindow!
    var crosshairView: CrosshairView!
    var settingsController: SettingsWindowController!
    let settings = CrosshairSettings()

    var hotKeyRef: EventHotKeyRef?
    var eventTap: CFMachPort?
    var eventTapSource: CFRunLoopSource?

    var hotKeyShortcut = HotKeyShortcut(
        keyCode: UInt32(kVK_ANSI_Y),
        modifiers: 0,
        displayName: "Y"
    )

    func applicationDidFinishLaunching(_ n: Notification) {
        NSApp.setActivationPolicy(.regular)

        let screen = NSScreen.main!.frame
        crosshairView = CrosshairView(frame: screen, settings: settings)

        overlayWindow = NSWindow(
            contentRect: screen,
            styleMask: .borderless,
            backing: .buffered,
            defer: false
        )

        overlayWindow.backgroundColor = .clear
        overlayWindow.isOpaque = false
        overlayWindow.level = .screenSaver
        overlayWindow.ignoresMouseEvents = true
        overlayWindow.collectionBehavior = [.canJoinAllSpaces, .stationary]
        overlayWindow.contentView = crosshairView
        overlayWindow.orderFrontRegardless()

        settingsController = SettingsWindowController(
            settings: settings,
            crosshairView: crosshairView,
            overlayWindow: overlayWindow
        )

        settingsController.showWindow(nil)

        registerToggleHotKey()
        installHotKeyHandler()

        NSApp.activate(ignoringOtherApps: true)
    }

    func toggleCrosshairVisibility() {
        if overlayWindow.isVisible {
            overlayWindow.orderOut(nil)
            (settingsController.window?.contentView?.viewWithTag(99) as? NSButton)?.title = "Show Crosshair"
        } else {
            overlayWindow.orderFrontRegardless()
            (settingsController.window?.contentView?.viewWithTag(99) as? NSButton)?.title = "Hide Crosshair"
        }
    }

    func updateHotKey(_ shortcut: HotKeyShortcut) {
        hotKeyShortcut = shortcut
        registerToggleHotKey()
    }

    func unregisterCurrentHotKey() {
        if let hotKeyRef {
            UnregisterEventHotKey(hotKeyRef)
            self.hotKeyRef = nil
        }

        if let eventTap {
            CFMachPortInvalidate(eventTap)
            self.eventTap = nil
            self.eventTapSource = nil
        }
    }

    func registerToggleHotKey() {
        unregisterCurrentHotKey()

        if hotKeyShortcut.modifiers == 0 {
            registerPlainKeyMonitor()
            return
        }

        var hotKeyID = EventHotKeyID(
            signature: OSType("CRSH".fourCharCodeValue),
            id: 1
        )

        RegisterEventHotKey(
            hotKeyShortcut.keyCode,
            hotKeyShortcut.modifiers,
            hotKeyID,
            GetApplicationEventTarget(),
            0,
            &hotKeyRef
        )
    }

    func registerPlainKeyMonitor() {
        let mask = CGEventMask(1 << CGEventType.keyDown.rawValue)

        eventTap = CGEvent.tapCreate(
            tap: .cgSessionEventTap,
            place: .headInsertEventTap,
            options: .listenOnly,
            eventsOfInterest: mask,
            callback: { _, _, event, userData in
                guard let userData else {
                    return Unmanaged.passUnretained(event)
                }

                let appDelegate = Unmanaged<AppDelegate>
                    .fromOpaque(userData)
                    .takeUnretainedValue()

                let keyCode = UInt32(event.getIntegerValueField(.keyboardEventKeycode))

                if keyCode == appDelegate.hotKeyShortcut.keyCode {
                    DispatchQueue.main.async {
                        appDelegate.toggleCrosshairVisibility()
                    }
                }

                return Unmanaged.passUnretained(event)
            },
            userInfo: Unmanaged.passUnretained(self).toOpaque()
        )

        guard let eventTap else {
            print("Could not create key monitor. You may need Accessibility permission.")
            return
        }

        eventTapSource = CFMachPortCreateRunLoopSource(kCFAllocatorDefault, eventTap, 0)
        CFRunLoopAddSource(CFRunLoopGetCurrent(), eventTapSource, .commonModes)
        CGEvent.tapEnable(tap: eventTap, enable: true)
    }

    func installHotKeyHandler() {
        var eventType = EventTypeSpec(
            eventClass: OSType(kEventClassKeyboard),
            eventKind: UInt32(kEventHotKeyPressed)
        )

        InstallEventHandler(
            GetApplicationEventTarget(),
            { _, _, userData in
                guard let userData else {
                    return noErr
                }

                let appDelegate = Unmanaged<AppDelegate>
                    .fromOpaque(userData)
                    .takeUnretainedValue()

                appDelegate.toggleCrosshairVisibility()
                return noErr
            },
            1,
            &eventType,
            Unmanaged.passUnretained(self).toOpaque(),
            nil
        )
    }
}

extension String {
    var fourCharCodeValue: FourCharCode {
        var result: FourCharCode = 0

        for char in utf16 {
            result = (result << 8) + FourCharCode(char)
        }

        return result
    }
}

let app = NSApplication.shared
let delegate = AppDelegate()
app.delegate = delegate
app.run()