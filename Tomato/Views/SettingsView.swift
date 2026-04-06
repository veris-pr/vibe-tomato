import SwiftUI

struct SettingsView: View {
    @ObservedObject var settings: AppSettings

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Settings")
                .font(.headline)

            VStack(alignment: .leading, spacing: 12) {
                settingRow(
                    label: "Work Duration",
                    value: Binding(
                        get: { settings.workMinutes },
                        set: { settings.setWorkMinutes($0) }
                    ),
                    range: AppSettings.Limits.workMinutes,
                    unit: "min"
                )

                settingRow(
                    label: "Short Break",
                    value: Binding(
                        get: { settings.shortBreakMinutes },
                        set: { settings.setShortBreakMinutes($0) }
                    ),
                    range: AppSettings.Limits.shortBreakMinutes,
                    unit: "min"
                )

                settingRow(
                    label: "Long Break",
                    value: Binding(
                        get: { settings.longBreakMinutes },
                        set: { settings.setLongBreakMinutes($0) }
                    ),
                    range: AppSettings.Limits.longBreakMinutes,
                    unit: "min"
                )

                HStack {
                    Text("Long break every")
                        .font(.system(size: 12))
                    Spacer()
                    Picker("", selection: Binding(
                        get: { settings.sessionsBeforeLongBreak },
                        set: { settings.setSessionsBeforeLongBreak($0) }
                    )) {
                        ForEach(AppSettings.Limits.sessionsBeforeLongBreak, id: \.self) { n in
                            Text("\(n) sessions").tag(n)
                        }
                    }
                    .labelsHidden()
                    .frame(width: 120)
                }
            }
        }
        .padding(16)
        .frame(width: 280)
    }

    private func settingRow(label: String, value: Binding<Int>, range: ClosedRange<Int>, unit: String) -> some View {
        HStack {
            Text(label)
                .font(.system(size: 12))
            Spacer()
            HStack(spacing: 4) {
                TextField("", value: value, format: .number)
                    .textFieldStyle(.roundedBorder)
                    .frame(width: 50)
                    .multilineTextAlignment(.center)
                Text(unit)
                    .font(.system(size: 11))
                    .foregroundStyle(.secondary)
                Stepper("", value: value, in: range)
                    .labelsHidden()
            }
        }
    }
}
