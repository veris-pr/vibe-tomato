import SwiftUI

struct SplatTomatoIcon: Shape {
    func path(in rect: CGRect) -> Path {
        let sx = rect.width / 128
        let sy = rect.height / 128

        var path = Path()

        // Core splat body
        path.move(to: CGPoint(x: 50 * sx, y: 90 * sy))
        path.addCurve(
            to: CGPoint(x: 35 * sx, y: 95 * sy),
            control1: CGPoint(x: 40 * sx, y: 80 * sy),
            control2: CGPoint(x: 30 * sx, y: 85 * sy)
        )
        path.addCurve(
            to: CGPoint(x: 45 * sx, y: 100 * sy),
            control1: CGPoint(x: 25 * sx, y: 92 * sy),
            control2: CGPoint(x: 28 * sx, y: 105 * sy)
        )
        path.addCurve(
            to: CGPoint(x: 68 * sx, y: 100 * sy),
            control1: CGPoint(x: 50 * sx, y: 115 * sy),
            control2: CGPoint(x: 70 * sx, y: 112 * sy)
        )
        path.addCurve(
            to: CGPoint(x: 80 * sx, y: 92 * sy),
            control1: CGPoint(x: 85 * sx, y: 105 * sy),
            control2: CGPoint(x: 95 * sx, y: 95 * sy)
        )
        path.addCurve(
            to: CGPoint(x: 65 * sx, y: 85 * sy),
            control1: CGPoint(x: 90 * sx, y: 80 * sy),
            control2: CGPoint(x: 75 * sx, y: 75 * sy)
        )
        path.addCurve(
            to: CGPoint(x: 50 * sx, y: 90 * sy),
            control1: CGPoint(x: 60 * sx, y: 70 * sy),
            control2: CGPoint(x: 50 * sx, y: 75 * sy)
        )
        path.closeSubpath()

        // Splashes
        path.move(to: CGPoint(x: 30 * sx, y: 80 * sy))
        path.addLine(to: CGPoint(x: 20 * sx, y: 70 * sy))

        path.move(to: CGPoint(x: 95 * sx, y: 80 * sy))
        path.addLine(to: CGPoint(x: 110 * sx, y: 70 * sy))

        path.move(to: CGPoint(x: 55 * sx, y: 110 * sy))
        path.addLine(to: CGPoint(x: 50 * sx, y: 120 * sy))

        path.move(to: CGPoint(x: 80 * sx, y: 110 * sy))
        path.addLine(to: CGPoint(x: 90 * sx, y: 120 * sy))

        return path
    }
}
