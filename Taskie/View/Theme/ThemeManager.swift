//
//  ThemeManager.swift
//  RebootChoreReward
//
//  Created by Toan Pham on 2/26/24.
//

import UIKit
import SwiftUI

protocol Themable: AnyObject {
    func applyTheme(_ theme: PDSTheme)
}

struct PDSStyling {
    var cornerRadius: CGFloat
    static let defaultStyling = PDSStyling(cornerRadius: 10)
}

struct PDSColor {
    var primaryColor: UIColor
    var darkenPrimaryColor: UIColor
    var secondaryColor: UIColor
    var darkenSecondaryColor: UIColor
    var backgroundColor: UIColor
    var surfaceColor: UIColor
    var errorColor: UIColor
    var onPrimary: UIColor
    var onSecondary: UIColor
    var onBackground: UIColor
    var onSurface: UIColor
    var onError: UIColor
    var dividerColor: UIColor
    
    // Add more theme attributes as needed
    
    // Define default and other themes
    static let lightModeColors = PDSColor(
        primaryColor: .init(hex: "#1B631B"),
        darkenPrimaryColor: .init(hex: "#165016"),
        secondaryColor: .init(hex: "#329F5B"),
        darkenSecondaryColor: .init(hex: "#2C8C51"),
        backgroundColor: .init(hex: "#EFEFEF"),
        surfaceColor: .init(hex: "#FFFFFF"),
        errorColor: .init(hex: "#CC4700"),
        onPrimary: .init(hex: "#FFFFFF"),
        onSecondary: .init(hex: "#FFFFFF"),
        onBackground: .init(hex: "#000000"),
        onSurface: .init(hex: "#000000"),
        onError: .init(hex: "#FFFFFF"),
        dividerColor: .init(hex: "#e0e0e0")
    )
    
    static let darkModeColors = PDSColor(
        primaryColor: .init(hex: "#9BE49B"),
        darkenPrimaryColor: .init(hex: "#AFE9AF"),
        secondaryColor: .init(hex: "#60CD8A"),
        darkenSecondaryColor: .init(hex: "#73D398"),
        backgroundColor: .init(hex: "#0F0F0F"),
        surfaceColor: .init(hex: "#000000"),
        errorColor: .init(hex: "#FF7A33"),
        onPrimary: .init(hex: "#000000"),
        onSecondary: .init(hex: "#000000"),
        onBackground: .init(hex: "#FFFFFF"),
        onSurface: .init(hex: "#FFFFFF"),
        onError: .init(hex: "#000000"),
        dividerColor: .init(hex: "#e0e0e0")
    )
}

struct PDSTheme {
    var color: PDSColor
    var typography: PDSTypography
    var styling: PDSStyling
    
    static let defaultTheme = PDSTheme(color: .lightModeColors, typography: .defaultTypography, styling: .defaultStyling)
}


class WeakThemable {
    weak var component: Themable?
    
    init(_ component: Themable) {
        self.component = component
    }
}

class ThemeManager: ObservableObject {
    static let shared = ThemeManager()
    
    @Published private(set) var currentTheme: PDSTheme = .defaultTheme {
        didSet {
            themableComponents = themableComponents.compactMap { weakThemable in
                guard let component = weakThemable.component else { return nil }
                component.applyTheme(currentTheme)
                return weakThemable
            }
        }
    }
    
    private var themableComponents = [WeakThemable]()
    
    func register(_ component: Themable) {
        themableComponents.append(WeakThemable(component))
        component.applyTheme(currentTheme) // Apply current theme immediately
    }
    
    func switchToTheme(_ theme: PDSTheme) {
        currentTheme = theme
    }
}


struct ThemedViewModifier: ViewModifier {
    @ObservedObject var themeManager = ThemeManager.shared

    func body(content: Content) -> some View {
        content
            .background(Color(themeManager.currentTheme.color.backgroundColor))
            .foregroundColor(Color(themeManager.currentTheme.color.onBackground))
            // Add more styling as needed
    }
}
