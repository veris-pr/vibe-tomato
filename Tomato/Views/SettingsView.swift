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
                    value: $settings.workMinutes,
                    range: 1...120,
                    unit: "min"
                )

                settingRow(
                    label: "Short Break",
                    value: $settings.shortBreakMinutes,
                    range: 1...30,
                    unit: "min"
                )

                settingRow(
                    label: "Long Break",
                    value: $settings.longBreakMinutes,
                    range: 1...60,
                    unit: "min"
                )

                HStack {
                    Text("Long break every")
                        .font(.system(size: 12))
                    Spacer()
                    Picker("", selection: $settings.sessionsBeforeLongBreak) {
                        ForEach(2...8, id: \.self) { n in
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
