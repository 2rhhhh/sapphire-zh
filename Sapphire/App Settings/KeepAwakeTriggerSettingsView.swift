//
//  KeepAwakeTriggerSettingsView.swift
//  Sapphire
//
//  Created by Shariq Charolia on 2026-10-07

import AppKit
import SwiftUI
import UniformTypeIdentifiers

struct KeepAwakeTriggerSettingsView: View {
    @EditingSettings var settings: SettingsEditingSession

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text("自动保持唤醒").font(.headline).padding([.top, .horizontal])
            Text("当以下任一条件成立时，防休眠会自动开启；全部不成立时自动关闭。若你手动关闭防休眠，这些条件会暂停，直到条件结束。")
                .font(.caption)
                .foregroundStyle(.secondary)
                .padding(.horizontal)
                .padding(.top, 4)

            if !settings.settings.caffeinateEnabled {
                InfoContainer(
                    text: "Caffeinate is switched off above, so nothing here will keep the Mac awake.",
                    iconName: "exclamationmark.triangle",
                    color: .orange
                )
                .padding([.horizontal, .top])
            }

            ToggleRow(
                title: "所选应用运行时",
                description: "Stay awake as long as one of the apps below is open.",
                isOn: $settings.settings.caffeinateWhileAppsRun
            )

            if settings.settings.caffeinateWhileAppsRun {
                KeepAwakeAppList(bundleIDs: $settings.settings.caffeinateTriggerAppBundleIDs)
                    .padding([.horizontal, .bottom])
            }

            Divider().padding(.leading, 20)

            ToggleRow(
                title: "接通电源时",
                description: "Stay awake whenever the Mac is plugged in.",
                isOn: $settings.settings.caffeinateWhileOnACPower
            )

            Divider().padding(.leading, 20)

            ToggleRow(
                title: "连接外接显示器时",
                description: "Stay awake while a monitor is attached. AirPlay and Sidecar displays don't count.",
                isOn: $settings.settings.caffeinateWhileExternalDisplay
            )

            Divider().padding(.leading, 20)

            ToggleRow(
                title: "屏幕锁定时暂停",
                description: "Let the Mac sleep normally after you lock it, even if a condition above is still true. Caffeinate you turned on yourself isn't affected.",
                isOn: $settings.settings.caffeinatePauseTriggersWhenLocked
            )
        }
        .modifier(SettingsContainerModifier())
    }
}

private struct KeepAwakeAppList: View {
    @Binding var bundleIDs: [String]

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            if bundleIDs.isEmpty {
                Text("尚未选择应用。")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            ForEach(bundleIDs, id: \.self) { bundleID in
                HStack(spacing: 8) {
                    Image(nsImage: Self.icon(for: bundleID))
                        .resizable()
                        .frame(width: 18, height: 18)
                    Text(Self.name(for: bundleID))
                    Spacer()
                    Button {
                        DispatchQueue.main.async {
                            bundleIDs.removeAll { $0 == bundleID }
                        }
                    } label: {
                        Image(systemName: "minus.circle.fill").foregroundStyle(.secondary)
                    }
                    .buttonStyle(.plain)
                    .help("Remove \(Self.name(for: bundleID))")
                }
            }
            Button("添加应用…", action: chooseApps)
                .controlSize(.small)
        }
    }

    private func chooseApps() {
        let panel = NSOpenPanel()
        panel.allowedContentTypes = [.application]
        panel.allowsMultipleSelection = true
        panel.canChooseDirectories = false
        panel.directoryURL = URL(fileURLWithPath: "/Applications")
        panel.prompt = "Add"
        guard panel.runModal() == .OK else { return }
        let chosen = panel.urls.compactMap { Bundle(url: $0)?.bundleIdentifier }
        let existing = Set(bundleIDs)
        let additions = chosen.filter { !existing.contains($0) }
        guard !additions.isEmpty else { return }
        bundleIDs.append(contentsOf: Set(additions).sorted())
    }

    private static func name(for bundleID: String) -> String {
        guard let url = NSWorkspace.shared.urlForApplication(withBundleIdentifier: bundleID) else { return bundleID }
        return FileManager.default.displayName(atPath: url.path).replacingOccurrences(of: ".app", with: "")
    }

    private static func icon(for bundleID: String) -> NSImage {
        guard let url = NSWorkspace.shared.urlForApplication(withBundleIdentifier: bundleID) else {
            return NSWorkspace.shared.icon(for: .application)
        }
        return NSWorkspace.shared.icon(forFile: url.path)
    }
}