//
//  FileProgressSettingsView.swift
//  Sapphire
//
//  Created by Shariq Charolia on 2026-09-28
//

import SwiftUI
import AppKit

struct FileProgressSettingsView: View {
    @EditingSettings var settings: SettingsEditingSession
    @ObservedObject private var tracker = FileProgressTracker.shared

    private var installedApps: [FileProgressApp] {
        FileProgressApp.allCases.filter(\.isInstalled)
    }

    private func appBinding(_ app: FileProgressApp) -> Binding<Bool> {
        Binding(
            get: { !settings.settings.fileProgressDisabledApps.contains(app.rawValue) },
            set: { on in
                if on { settings.settings.fileProgressDisabledApps.remove(app.rawValue) }
                else { settings.settings.fileProgressDisabledApps.insert(app.rawValue) }
            }
        )
    }

    var body: some View {
        ScrollView {
            LazyVStack(alignment: .leading, spacing: 20) {
                Text("文件进度（测试版）").font(.largeTitle.bold()).padding(.bottom)

                VStack(alignment: .leading, spacing: 0) {
                    ToggleRow(
                        title: "在刘海显示传输",
                        description: "A live activity with the app's icon and progress while something downloads, copies or arrives over AirDrop.",
                        isOn: $settings.settings.fileProgressLiveActivityEnabled
                    )
                    Divider().padding(.leading, 20)
                    ToggleRow(
                        title: "点击时打开传输列表",
                        description: "Click the live activity for every transfer, with pause, cancel, open and Show in Finder.",
                        isOn: $settings.settings.fileProgressOpenOnClick
                    )
                }
                .modifier(SettingsContainerModifier())

                VStack(alignment: .leading, spacing: 0) {
                    Text("应用").font(.headline).padding([.top, .horizontal])
                    Text("每个应用按自身报告的传输进度显示，因此能看到准确的进度。")
                        .font(.caption).foregroundStyle(.secondary)
                        .padding(.horizontal).padding(.bottom, 8)
                    ForEach(Array(installedApps.enumerated()), id: \.element) { index, app in
                        if index > 0 { Divider().padding(.leading, 56) }
                        HStack(spacing: 12) {
                            Group {
                                if let icon = app.icon {
                                    Image(nsImage: icon).resizable().aspectRatio(contentMode: .fit)
                                } else {
                                    Image(systemName: "app.dashed")
                                }
                            }
                            .frame(width: 28, height: 28)
                            VStack(alignment: .leading, spacing: 2) {
                                Text(app.displayName)
                                Text(app.trackingDetail).font(.caption).foregroundStyle(.secondary)
                            }
                            Spacer()
                            Toggle("", isOn: appBinding(app)).labelsHidden().toggleStyle(.switch)
                        }
                        .padding(.horizontal)
                        .padding(.vertical, 8)
                    }
                }
                .modifier(SettingsContainerModifier())
                .disabled(!settings.settings.fileProgressLiveActivityEnabled)

                VStack(alignment: .leading, spacing: 0) {
                    ToggleRow(title: "显示速度", description: "Download or copy speed next to the percentage.",
                              isOn: $settings.settings.fileProgressShowSpeed)
                    Divider().padding(.leading, 20)
                    ToggleRow(title: "显示剩余时间", description: "An estimate of how long is left.",
                              isOn: $settings.settings.fileProgressShowTimeRemaining)
                    Divider().padding(.leading, 20)
                    ToggleRow(title: "将完成的文件添加到文件架",
                              description: "Put each completed download on the shelf so it's one drag away.",
                              isOn: $settings.settings.fileProgressAddFinishedToShelf)
                    Divider().padding(.leading, 20)
                    VStack(alignment: .leading, spacing: 6) {
                        HStack {
                            Text("保持已完成传输可见")
                            Spacer()
                            Text("\(Int(settings.settings.fileProgressKeepFinishedSeconds)) s").foregroundStyle(.secondary).monospacedDigit()
                        }
                        Slider(value: $settings.settings.fileProgressKeepFinishedSeconds, in: 1...30, step: 1)
                    }
                    .padding()
                }
                .modifier(SettingsContainerModifier())
                .disabled(!settings.settings.fileProgressLiveActivityEnabled)

                VStack(alignment: .leading, spacing: 0) {
                    Text("监视的文件夹").font(.headline).padding([.top, .horizontal])
                    Text("会自动查找“下载”“桌面”“文稿”以及各浏览器自己的下载文件夹。如应用会保存到其他文件夹，可在此添加。")
                        .font(.caption).foregroundStyle(.secondary)
                        .padding(.horizontal).padding(.bottom, 8)
                    ForEach(tracker.watchedFolders, id: \.self) { folder in
                        let isExtra = settings.settings.fileProgressExtraFolders.contains {
                            ($0 as NSString).expandingTildeInPath == folder.path
                        }
                        HStack {
                            Image(systemName: "folder").foregroundStyle(.secondary)
                            Text((folder.path as NSString).abbreviatingWithTildeInPath)
                                .lineLimit(1).truncationMode(.middle)
                            Spacer()
                            if isExtra {
                                Button("移除") {
                                    settings.settings.fileProgressExtraFolders.removeAll {
                                        ($0 as NSString).expandingTildeInPath == folder.path
                                    }
                                }
                                .buttonStyle(.borderless)
                            } else {
                                Text("自动").font(.caption).foregroundStyle(.secondary)
                            }
                        }
                        .padding(.horizontal)
                        .padding(.vertical, 5)
                    }
                    HStack {
                        Spacer()
                        Button("添加文件夹…", action: addFolder)
                    }
                    .padding()
                }
                .modifier(SettingsContainerModifier())
                .disabled(!settings.settings.fileProgressLiveActivityEnabled)
            }
            .padding(25)
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        }
    }

    private func addFolder() {
        let panel = NSOpenPanel()
        panel.canChooseFiles = false
        panel.canChooseDirectories = true
        panel.allowsMultipleSelection = true
        panel.prompt = "Watch"
        guard panel.runModal() == .OK else { return }
        for url in panel.urls {
            let path = (url.path as NSString).abbreviatingWithTildeInPath
            if !settings.settings.fileProgressExtraFolders.contains(path) {
                settings.settings.fileProgressExtraFolders.append(path)
            }
        }
    }
}