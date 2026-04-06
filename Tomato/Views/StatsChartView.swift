import SwiftUI
import Charts

struct StatsChartView: View {
    let title: String
    let stats: [DayStat]

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                Text(title)
                    .font(.system(size: 11, weight: .semibold))
                    .foregroundStyle(.secondary)
                Spacer()
                legendView
            }

            ZStack {
                emptyState
                    .opacity(hasData ? 0 : 1)

                if hasData {
                    chartView
                }
            }
            .frame(height: 60)
        }
    }

    private var hasData: Bool {
        !stats.isEmpty && stats.contains { $0.tracked > 0 || $0.missed > 0 || $0.paused > 0 }
    }

    private var legendView: some View {
        HStack(spacing: 8) {
            HStack(spacing: 3) {
                Circle().fill(.primary).frame(width: 6, height: 6)
                Text("Tracked").font(.system(size: 9)).foregroundStyle(.tertiary)
            }
            HStack(spacing: 3) {
                Circle().fill(.secondary.opacity(0.5)).frame(width: 6, height: 6)
                Text("Missed").font(.system(size: 9)).foregroundStyle(.tertiary)
            }
            HStack(spacing: 3) {
                Circle().fill(.quaternary).frame(width: 6, height: 6)
                Text("Paused").font(.system(size: 9)).foregroundStyle(.tertiary)
            }
        }
    }

    private var emptyState: some View {
        Text("No data yet")
            .font(.system(size: 10))
            .foregroundStyle(.quaternary)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    private var chartView: some View {
        Chart {
            ForEach(stats) { stat in
                BarMark(
                    x: .value("Period", stat.label),
                    y: .value("Count", stat.tracked)
                )
                .foregroundStyle(.primary.opacity(0.8))
                .cornerRadius(2)

                BarMark(
                    x: .value("Period", stat.label),
                    y: .value("Count", stat.missed)
                )
                .foregroundStyle(.secondary.opacity(0.5))
                .cornerRadius(2)

                BarMark(
                    x: .value("Period", stat.label),
                    y: .value("Count", stat.paused)
                )
                .foregroundStyle(.quaternary)
                .cornerRadius(2)
            }
        }
        .chartYAxis {
            AxisMarks(values: .automatic(desiredCount: 3)) { value in
                AxisGridLine(stroke: StrokeStyle(lineWidth: 0.5, dash: [2]))
                    .foregroundStyle(.quaternary)
                AxisValueLabel()
                    .font(.system(size: 8))
                    .foregroundStyle(.tertiary)
            }
        }
        .chartXAxis {
            AxisMarks { value in
                AxisValueLabel()
                    .font(.system(size: 9))
                    .foregroundStyle(.tertiary)
            }
        }
        .chartLegend(.hidden)
        .frame(maxHeight: .infinity)
    }
}
