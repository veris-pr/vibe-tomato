import SwiftUI

struct SplatTomatoIcon: Shape {
    func path(in rect: CGRect) -> Path {
        let sx = rect.width / 64
        let sy = rect.height / 64

        var path = Path()

        // Core splat
        path.move(to: CGPoint(x: 32 * sx, y: 32 * sy))
        path.addCurve(
            to: CGPoint(x: 18 * sx, y: 36 * sy),
            control1: CGPoint(x: 20 * sx, y: 20 * sy),
            control2: CGPoint(x: 12 * sx, y: 28 * sy)
        )
        path.addCurve(
            to: CGPoint(x: 28 * sx, y: 44 * sy),
            control1: CGPoint(x: 10 * sx, y: 40 * sy),
            control2: CGPoint(x: 18 * sx, y: 50 * sy)
        )
        path.addCurve(
            to: CGPoint(x: 42 * sx, y: 42 * sy),
            control1: CGPoint(x: 32 * sx, y: 54 * sy),
            control2: CGPoint(x: 44 * sx, y: 52 * sy)
        )
        path.addCurve(
            to: CGPoint(x: 46 * sx, y: 30 * sy),
            control1: CGPoint(x: 54 * sx, y: 44 * sy),
            control2: CGPoint(x: 56 * sx, y: 34 * sy)
        )
        path.addCurve(
            to: CGPoint(x: 36 * sx, y: 26 * sy),
            control1: CGPoint(x: 52 * sx, y: 20 * sy),
            control2: CGPoint(x: 40 * sx, y: 18 * sy)
        )
        path.addCurve(
            to: CGPoint(x: 32 * sx, y: 32 * sy),
            control1: CGPoint(x: 32 * sx, y: 18 * sy),
            control2: CGPoint(x: 26 * sx, y: 20 * sy)
        )
        path.closeSubpath()

        // Splashes
        path.move(to: CGPoint(x: 10 * sx, y: 30 * sy))
        path.addLine(to: CGPoint(x: 6 * sx, y: 28 * sy))

        path.move(to: CGPoint(x: 52 * sx, y: 28 * sy))
        path.addLine(to: CGPoint(x: 58 * sx, y: 26 * sy))

        path.move(to: CGPoint(x: 18 * sx, y: 54 * sy))
        path.addLine(to: CGPoint(x: 14 * sx, y: 58 * sy))

        path.move(to: CGPoint(x: 46 * sx, y: 50 * sy))
        path.addLine(to: CGPoint(x: 50 * sx, y: 56 * sy))

        // Detached leaf
        path.move(to: CGPoint(x: 28 * sx, y: 10 * sy))
        path.addCurve(
            to: CGPoint(x: 38 * sx, y: 10 * sy),
            control1: CGPoint(x: 30 * sx, y: 6 * sy),
            control2: CGPoint(x: 36 * sx, y: 6 * sy)
        )

        return path
    }
}
