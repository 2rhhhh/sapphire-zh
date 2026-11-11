//
//  AppActivitiesSettingsView.swift
//  Sapphire
//
//  Created by Shariq Charolia on 2026-09-28
//

import SwiftUI

struct AppActivitiesSettingsView: View {
    @EditingSettings var settings: SettingsEditingSession
    @ObservedObject private var monitor = AppActivityMonitor.shared

    private func appBinding(_ app: AppActivityApp) -> Binding<Bool> {
        Binding(
            get: { !settings.settings.appActivitiesDisabled.contains(app.rawValue) },
            set: { on in
                if on { settings.settings.appActivitiesDisabled.remove(app.rawValue) }
                else { settings.settings.appActivitiesDisabled.insert(app.rawValue) }
            }
        )
    }

    var body: some View {
        ScrollView {
            LazyVStack(alignment: .leading, spacing: 20) {
                Text("应用活动（测试版）").font(.largeTitle.bold()).padding(.bottom)

                VStack(alignment: .leading, spacing: 0) {
                    ToggleRow(
                        title: "在刘海显示应用活动",
                        description: "A live activity with the app's icon and a timer while you're in a meeting, on a call, recording, or connected to another Mac. Click it for controls.",
                        isOn: $settings.settings.appActivitiesEnabled
                    )
                    Divider().padding(.leading, 20)
                    ToggleRow(
                        title: "操作后返回你的应用",
                        description: "Some apps only take shortcuts in front; after muting or toggling video, switch back to what you were using.",
                        isOn: $settings.settings.appActivityRestoreFocus
                    )
                }
                .modifier(SettingsContainerModifier())

                if !monitor.activities.isEmpty {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("正在使用").font(.headline)
                        ForEach(monitor.activities) { activity in
                            HStack(spacing: 10) {
                                AppActivityIcon(app: activity.app, size: 22)
                                Text(activity.title)
                                if let subtitle = activity.subtitle { Text(subtitle).foregroundStyle(.secondary) }
                                Spacer()
                                Text(activity.startedAt, style: .timer).monospacedDigit().foregroundStyle(.secondary)
                            }
                        }
                    }
                    .padding()
                    .modifier(SettingsContainerModifier())
                }

                VStack(alignment: .leading, spacing: 0) {
                    Text("应用").font(.headline).padding([.top, .horizontal])
                    Text("控制功能需要辅助功能权限；Google Meet 还需要控制浏览器的权限。")
                        .font(.caption).foregroundStyle(.secondary)
                        .padding(.horizontal).padding(.bottom, 8)
                    let apps = AppActivityApp.allCases.filter(\.isInstalled)
                    ForEach(Array(apps.enumerated()), id: \.element) { index, app in
                        if index > 0 { Divider().padding(.leading, 56) }
                        HStack(spacing: 12) {
                            AppActivityIcon(app: app, size: 28)
                            VStack(alignment: .leading, spacing: 2) {
                                Text(app.displayName)
                                Text(app.detectionDetail).font(.caption).foregroundStyle(.secondary)
                            }
                            Spacer()
                            Toggle("", isOn: appBinding(app)).labelsHidden().toggleStyle(.switch)
                        }
                        .padding(.horizontal)
                        .padding(.vertical, 8)
                    }
                }
                .modifier(SettingsContainerModifier())
                .disabled(!settings.settings.appActivitiesEnabled)
            }
            .padding(25)
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        }
    }
}