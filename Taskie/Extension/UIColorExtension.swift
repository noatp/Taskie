//
//  UIColorExtension.swift
//  RebootChoreReward
//
//  Created by Toan Pham on 2/26/24.
//

import UIKit

extension UIColor {
    convenience init(hex: String?, alpha: CGFloat? = nil) {
        
        var nonEmptyHex = ""
        
        if let hex = hex {
            if hex.isEmpty  {
                nonEmptyHex = "#D3D3D3"
            }
            else {
                nonEmptyHex = hex
            }
        }
        else {
            nonEmptyHex = "#D3D3D3"
        }
        
        var hexFormatted: String = nonEmptyHex.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines).uppercased()
        
        if hexFormatted.hasPrefix("#") {
            hexFormatted = String(hexFormatted.dropFirst())
        }
        
        assert(hexFormatted.count == 6 || hexFormatted.count == 8, "Invalid hex code used.")
        
        var rgbValue: UInt64 = 0
        Scanner(string: hexFormatted).scanHexInt64(&rgbValue)
        
        if hexFormatted.count == 6 {
            let red = CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0
            let green = CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0
            let blue = CGFloat(rgbValue & 0x0000FF) / 255.0
            self.init(red: red, green: green, blue: blue, alpha: alpha ?? 1.0)
        } else {
            let red = CGFloat((rgbValue & 0xFF000000) >> 24) / 255.0
            let green = CGFloat((rgbValue & 0x00FF0000) >> 16) / 255.0
            let blue = CGFloat((rgbValue & 0x0000FF00) >> 8) / 255.0
            let alphaValue = CGFloat(rgbValue & 0x000000FF) / 255.0
            self.init(red: red, green: green, blue: blue, alpha: alpha ?? alphaValue)
        }
    }
    
    var hexString: String? {
        guard let components = cgColor.components, components.count >= 3 else {
            return nil
        }
        let r = Float(components[0])
        let g = Float(components[1])
        let b = Float(components[2])
        let a = components.count >= 4 ? Float(components[3]) : 1.0
        return String(format: "#%02lX%02lX%02lX%02lX",
                      lroundf(r * 255), lroundf(g * 255), lroundf(b * 255), lroundf(a * 255))
    }
}
