// Draws the VibeCapture app icon and writes Resources/AppIcon.icns (+ AppIcon.png preview).
// Usage: scripts/make-icon.sh
import AppKit

// Vibe gradient: violet → pink → orange.
let violet = NSColor(srgbRed: 0.42, green: 0.25, blue: 0.95, alpha: 1)   // #6B40F2
let pink = NSColor(srgbRed: 0.93, green: 0.25, blue: 0.62, alpha: 1)     // #ED409E
let orange = NSColor(srgbRed: 0.99, green: 0.55, blue: 0.22, alpha: 1)   // #FC8C38
let brandBottom = pink

func drawIcon(size: CGFloat) -> NSBitmapImageRep {
    let rep = NSBitmapImageRep(bitmapDataPlanes: nil, pixelsWide: Int(size), pixelsHigh: Int(size), bitsPerSample: 8,
                               samplesPerPixel: 4, hasAlpha: true, isPlanar: false, colorSpaceName: .deviceRGB,
                               bytesPerRow: 0, bitsPerPixel: 0)!
    NSGraphicsContext.saveGraphicsState()
    NSGraphicsContext.current = NSGraphicsContext(bitmapImageRep: rep)
    let ctx = NSGraphicsContext.current!.cgContext
    ctx.scaleBy(x: size / 1024, y: size / 1024)

    // Body on Apple's 1024 grid: 824 × 824, radius 185, soft drop shadow.
    let body = CGRect(x: 100, y: 100, width: 824, height: 824)
    let shape = CGPath(roundedRect: body, cornerWidth: 185, cornerHeight: 185, transform: nil)
    ctx.saveGState()
    ctx.setShadow(offset: CGSize(width: 0, height: -12), blur: 28, color: NSColor.black.withAlphaComponent(0.35).cgColor)
    ctx.addPath(shape)
    ctx.setFillColor(brandBottom.cgColor)
    ctx.fillPath()
    ctx.restoreGState()

    ctx.saveGState()
    ctx.addPath(shape)
    ctx.clip()
    let gradient = CGGradient(colorsSpace: CGColorSpace(name: CGColorSpace.sRGB),
                              colors: [violet.cgColor, pink.cgColor, orange.cgColor] as CFArray, locations: [0, 0.55, 1])!
    ctx.drawLinearGradient(gradient, start: CGPoint(x: 100, y: 924), end: CGPoint(x: 924, y: 100), options: [])
    // Soft light from the top.
    let glow = CGGradient(colorsSpace: CGColorSpace(name: CGColorSpace.sRGB),
                          colors: [NSColor.white.withAlphaComponent(0.28).cgColor, NSColor.white.withAlphaComponent(0).cgColor] as CFArray,
                          locations: [0, 1])!
    ctx.drawRadialGradient(glow, startCenter: CGPoint(x: 512, y: 980), startRadius: 0,
                           endCenter: CGPoint(x: 512, y: 980), endRadius: 620, options: [])
    ctx.restoreGState()

    // Selection corners around the recording area.
    let frame = CGRect(x: 512 - 270, y: 512 - 200, width: 540, height: 400)
    let arm: CGFloat = 120
    ctx.setStrokeColor(NSColor.white.cgColor)
    ctx.setLineWidth(46)
    ctx.setLineCap(.round)
    ctx.setLineJoin(.round)
    ctx.setShadow(offset: CGSize(width: 0, height: -6), blur: 14, color: NSColor.black.withAlphaComponent(0.18).cgColor)
    let corners: [(CGPoint, CGFloat, CGFloat)] = [
        (CGPoint(x: frame.minX, y: frame.maxY), 1, -1), (CGPoint(x: frame.maxX, y: frame.maxY), -1, -1),
        (CGPoint(x: frame.minX, y: frame.minY), 1, 1), (CGPoint(x: frame.maxX, y: frame.minY), -1, 1),
    ]
    for (p, dx, dy) in corners {
        ctx.move(to: CGPoint(x: p.x + dx * arm, y: p.y))
        ctx.addLine(to: p)
        ctx.addLine(to: CGPoint(x: p.x, y: p.y + dy * arm))
    }
    ctx.strokePath()

    // Voice wave in the middle: what you say goes along with what you capture.
    let center = CGPoint(x: frame.midX, y: frame.midY)
    let heights: [CGFloat] = [96, 196, 290, 196, 96]
    let barWidth: CGFloat = 44, gap: CGFloat = 30
    let total = CGFloat(heights.count) * barWidth + CGFloat(heights.count - 1) * gap
    ctx.setFillColor(NSColor.white.cgColor)
    for (i, h) in heights.enumerated() {
        let x = center.x - total / 2 + CGFloat(i) * (barWidth + gap)
        let bar = CGRect(x: x, y: center.y - h / 2, width: barWidth, height: h)
        ctx.addPath(CGPath(roundedRect: bar, cornerWidth: barWidth / 2, cornerHeight: barWidth / 2, transform: nil))
    }
    ctx.fillPath()

    NSGraphicsContext.restoreGraphicsState()
    return rep
}

let root = URL(fileURLWithPath: CommandLine.arguments[1])
let iconset = FileManager.default.temporaryDirectory.appendingPathComponent("AppIcon.iconset")
try? FileManager.default.removeItem(at: iconset)
try! FileManager.default.createDirectory(at: iconset, withIntermediateDirectories: true)
for base in [16, 32, 128, 256, 512] {
    for scale in [1, 2] {
        let px = CGFloat(base * scale)
        let name = scale == 1 ? "icon_\(base)x\(base).png" : "icon_\(base)x\(base)@2x.png"
        try! drawIcon(size: px).representation(using: .png, properties: [:])!.write(to: iconset.appendingPathComponent(name))
    }
}
try! drawIcon(size: 1024).representation(using: .png, properties: [:])!
    .write(to: root.appendingPathComponent("Resources/AppIcon.png"))
let p = Process()
p.executableURL = URL(fileURLWithPath: "/usr/bin/iconutil")
p.arguments = ["-c", "icns", iconset.path, "-o", root.appendingPathComponent("Resources/AppIcon.icns").path]
try! p.run()
p.waitUntilExit()
print(p.terminationStatus == 0 ? "Wrote Resources/AppIcon.icns" : "iconutil failed")
