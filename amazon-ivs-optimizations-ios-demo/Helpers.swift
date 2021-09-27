//
//  Helpers.swift
//  amazon-ivs-optimizations-ios-demo
//
//  Created by Uldis on 05/05/2021.
//

import UIKit

enum OptimizationTechnique {
    case RebufferToLive
    case CatchUpToLive
    case PreCaching
}

extension UIColor {
    convenience init(hex: String) {
        let a, r, g, b: UInt64
        let hexString = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int = UInt64()

        Scanner(string: hexString).scanHexInt64(&int)

        switch hexString.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }

        self.init(
            red: CGFloat(r) / 255,
            green: CGFloat(g) / 255,
            blue: CGFloat(b) / 255,
            alpha: CGFloat(a) / 255
        )
    }

    class func color(for latency: Double) -> UIColor {
        if latency <= 5 {
            return UIColor(hex: "#5AAD43")
        } else if latency <= 10 {
            return UIColor(hex: "#C9F02C")
        } else if latency < 15 {
            return UIColor(hex: "#DD6B10")
        } else {
            return UIColor(hex: "#D33212")
        }
    }
}

extension Date {
    func timeInterval(_ to: String) -> TimeInterval? {
        let dateFormatter = DateFormatter()
        dateFormatter.timeZone = TimeZone(identifier: "UTC")
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
        var result: TimeInterval? = nil

        if let date = dateFormatter.date(from: to) {
            result = self.timeIntervalSince(date)
        }

        return result
    }
}
