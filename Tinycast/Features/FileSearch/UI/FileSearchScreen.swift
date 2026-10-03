import SwiftUI

struct FileSearchScreen: PaletteScreen {
    let session: FileSearchSession
    let core: AppCore
    let vm: PaletteState
    let openActions: () -> Void

    private var metrics: InterfaceMetrics { core.settings.interfaceSize.metrics }

    var rows: [FileSearchResult] { session.results }

    private var isShowingRecents: Bool {
        vm.query.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    var primaryActionTitle: String {
        guard let result = result(at: vm.selection) else { return "Open File" }
        return result.isDirectory ? "Open Folder" : "Open File"
    }

    func result(at selection: Int) -> FileSearchResult? {
        rows.indices.contains(selection) ? rows[selection] : nil
    }

    func actions(at selection: Int) -> PopoverMenuContent? {
        guard let result = result(at: selection) else { return nil }
        return FileSearchActionsMenu.content(result: result, core: core, session: session, vm: vm)
    }

    func activate(at selection: Int) {
        guard let result = result(at: selection) else { return }
        core.fileSearchCoordinator.open(result)
    }

    func secondary(at selection: Int) -> Bool {
        guard let result = result(at: selection) else { return false }
        core.fileSearchCoordinator.showInFinder(result)
        return true
    }

    func perform(_ shortcut: PaletteShortcut, at selection: Int) -> Bool {
        switch shortcut {
        case .copyFile:
            guard let result = result(at: selection) else { return false }
            core.fileSearchCoordinator.copyFile(result)
            return true
        case .copyName:
            guard let result = result(at: selection) else { return false }
            core.fileSearchCoordinator.copyName(result)
            return true
        case .copyPath:
            guard let result = result(at: selection) else { return false }
            core.fileSearchCoordinator.copyPath(result)
            return true
        case .pasteFile:
            guard let result = result(at: selection) else { return false }
            core.fileSearchCoordinator.pasteFile(result)
            return true
        case .delete:
            guard let result = result(at: selection) else { return false }
            core.fileSearchCoordinator.trash(result)
            return true
        case .quickLook:
            guard let result = result(at: selection) else { return false }
            core.fileSearchCoordinator.quickLook(result)
            return true
        case .showDetails, .toggleInfoPanel:
            core.fileSearchCoordinator.toggleInfoPanel()
            return true
        case .showInfoInFinder:
            guard let result = result(at: selection) else { return false }
            core.fileSearchCoordinator.showInfoInFinder(result)
            return true
        case .saveAsQuicklink:
            guard let result = result(at: selection) else { return false }
            core.fileSearchCoordinator.saveAsQuicklink(result)
            return true
        default:
            return false
        }
    }

    func body(selection: Int, scroll: ScrollIntent) -> AnyView {
        AnyView(content(selection: selection, scroll: scroll))
    }

    @ViewBuilder
    private func content(selection: Int, scroll: ScrollIntent) -> some View {
        if session.state == .failed {
            EmptyResults(text: "File search is unavailable")
        } else if rows.isEmpty {
            emptyState
        } else {
            let selected = result(at: selection)
            Group {
                if session.showsInfoPanel {
                    HStack(spacing: 0) {
                        FileSearchList(
                            title: isShowingRecents ? "Recently Used" : "Results",
                            results: rows,
                            selectedID: selected?.id,
                            showsInfoPanel: true,
                            scroll: scroll,
                            onSelect: { result in
                                if let index = rows.firstIndex(of: result) { vm.selection = index }
                            },
                            onActivate: { core.fileSearchCoordinator.open($0) },
                            onActions: { result in
                                if let index = rows.firstIndex(of: result) { vm.selection = index }
                                openActions()
                            },
                            onDropped: { core.fileSearchCoordinator.fileDropped() }
                        )
                        .frame(width: metrics.size.clipboardListWidth)

                        Rectangle()
                            .fill(Theme.Colors.separator)
                            .frame(width: 1)

                        FileSearchPreview(result: selected)
                    }
                } else {
                    FileSearchList(
                        title: isShowingRecents ? "Recently Used" : "Results",
                        results: rows,
                        selectedID: selected?.id,
                        showsInfoPanel: false,
                        scroll: scroll,
                        onSelect: { result in
                            if let index = rows.firstIndex(of: result) { vm.selection = index }
                            session.showsInfoPanel = true
                        },
                        onActivate: { core.fileSearchCoordinator.open($0) },
                        onActions: { result in
                            if let index = rows.firstIndex(of: result) { vm.selection = index }
                            openActions()
                        },
                        onDropped: { core.fileSearchCoordinator.fileDropped() }
                    )
                }
            }
            .onChange(of: selected?.id) { _, newID in
                if let newID {
                    session.lastSelectedID = newID
                }
                core.fileSearchCoordinator.updateQuickLookIfVisible(selected)
            }
            .onAppear {
                restoreSelectionIfNeeded()
            }
            .onChange(of: rows) { _, _ in
                restoreSelectionIfNeeded()
            }
        }
    }

    @ViewBuilder
    private var emptyState: some View {
        if session.state != .ready {
            Color.clear
        } else if isShowingRecents {
            EmptyResults(text: "Type to search files and folders")
        } else {
            EmptyResults(text: vm.fileSearchFilter.emptyMessage)
        }
    }

    private func restoreSelectionIfNeeded() {
        guard let lastID = session.lastSelectedID,
            let targetIndex = rows.firstIndex(where: { $0.id == lastID }),
            vm.selection != targetIndex
        else { return }
        vm.selection = targetIndex
        vm.followToken = UUID()
    }
}

@MainActor
enum FileSearchActionsMenu {
    static func content(
        result: FileSearchResult, core: AppCore, session: FileSearchSession, vm: PaletteState
    ) -> PopoverMenuContent {
        var items: [PopoverMenuItem] = []

        if core.settings.isFileSearchActionVisible(.open) {
            items.append(
                PopoverMenuItem(
                    title: result.isDirectory ? "Open Folder" : "Open File",
                    systemImage: result.isDirectory ? "folder" : "doc", shortcut: "↵"
                ) { core.fileSearchCoordinator.open(result) }
            )
        }
        if core.settings.isFileSearchActionVisible(.showInFinder) {
            items.append(
                PopoverMenuItem(
                    title: "Show in Finder", systemImage: "folder", shortcut: "⌘↵"
                ) { core.fileSearchCoordinator.showInFinder(result) }
            )
        }
        if core.settings.isFileSearchActionVisible(.quickLook) {
            items.append(
                PopoverMenuItem(
                    title: "Quick Look", systemImage: "eye", shortcut: "⌘Y"
                ) { core.fileSearchCoordinator.quickLook(result) }
            )
        }
        if core.settings.isFileSearchActionVisible(.showInfoInFinder) {
            items.append(
                PopoverMenuItem(
                    title: "Show Info in Finder", systemImage: "info.circle", shortcut: "⌥⌘I"
                ) { core.fileSearchCoordinator.showInfoInFinder(result) }
            )
        }
        if core.settings.isFileSearchActionVisible(.toggleInfoPanel) {
            items.append(
                PopoverMenuItem(
                    title: session.showsInfoPanel ? "Hide Info Panel" : "Show Info Panel",
                    systemImage: "sidebar.right", startsSection: !items.isEmpty, shortcut: "⌘I"
                ) { core.fileSearchCoordinator.toggleInfoPanel() }
            )
        }
        var startedCopySection = false
        if core.settings.isFileSearchActionVisible(.copyFile) {
            items.append(
                PopoverMenuItem(
                    title: "Copy File", systemImage: "doc.on.doc", startsSection: !items.isEmpty,
                    shortcut: "⇧⌘C"
                ) { core.fileSearchCoordinator.copyFile(result) }
            )
            startedCopySection = true
        }
        if let target = vm.pasteTarget {
            items.append(
                PopoverMenuItem(
                    title: "Paste File to \(target.name)", icon: .paste(target, fallback: "doc.on.clipboard"),
                    shortcut: "⇧⌘V"
                ) { core.fileSearchCoordinator.pasteFile(result) }
            )
            startedCopySection = true
        } else {
            items.append(
                PopoverMenuItem(
                    title: "Paste File", systemImage: "doc.on.clipboard",
                    shortcut: "⇧⌘V"
                ) { core.fileSearchCoordinator.pasteFile(result) }
            )
            startedCopySection = true
        }
        if core.settings.isFileSearchActionVisible(.copyName) {
            items.append(
                PopoverMenuItem(
                    title: "Copy Name", systemImage: "doc.text",
                    startsSection: !startedCopySection && !items.isEmpty, shortcut: "⌥⌘C"
                ) { core.fileSearchCoordinator.copyName(result) }
            )
            startedCopySection = true
        }
        if core.settings.isFileSearchActionVisible(.copyPath) {
            items.append(
                PopoverMenuItem(
                    title: "Copy Path", systemImage: "doc.on.clipboard",
                    startsSection: !startedCopySection && !items.isEmpty, shortcut: "⌃⌘C"
                ) { core.fileSearchCoordinator.copyPath(result) }
            )
        }
        items.append(
            PopoverMenuItem(
                title: "Move to Trash", systemImage: "trash", startsSection: true,
                shortcut: "⌃X", isDestructive: true
            ) { core.fileSearchCoordinator.trash(result) }
        )
        if core.settings.isFileSearchActionVisible(.saveAsQuicklink) {
            items.append(
                PopoverMenuItem(
                    title: "Save as Quicklink", systemImage: "link", startsSection: !items.isEmpty,
                    shortcut: "⌘S"
                ) { core.fileSearchCoordinator.saveAsQuicklink(result) }
            )
        }

        if items.isEmpty {
            items.append(
                PopoverMenuItem(
                    title: result.isDirectory ? "Open Folder" : "Open File",
                    systemImage: result.isDirectory ? "folder" : "doc", shortcut: "↵"
                ) { core.fileSearchCoordinator.open(result) }
            )
        }

        return PopoverMenuContent(header: result.name, items: items)
    }
}
