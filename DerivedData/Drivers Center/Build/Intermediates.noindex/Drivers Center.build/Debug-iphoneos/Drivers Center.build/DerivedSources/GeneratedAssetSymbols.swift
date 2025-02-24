import Foundation
#if canImport(AppKit)
import AppKit
#endif
#if canImport(UIKit)
import UIKit
#endif
#if canImport(SwiftUI)
import SwiftUI
#endif
#if canImport(DeveloperToolsSupport)
import DeveloperToolsSupport
#endif

#if SWIFT_PACKAGE
private let resourceBundle = Foundation.Bundle.module
#else
private class ResourceBundleClass {}
private let resourceBundle = Foundation.Bundle(for: ResourceBundleClass.self)
#endif

// MARK: - Color Symbols -

@available(iOS 17.0, macOS 14.0, tvOS 17.0, watchOS 10.0, *)
extension DeveloperToolsSupport.ColorResource {

    /// The "AccentColor" asset catalog color resource.
    static let accent = DeveloperToolsSupport.ColorResource(name: "AccentColor", bundle: resourceBundle)

    /// The "almostWhite" asset catalog color resource.
    static let almostWhite = DeveloperToolsSupport.ColorResource(name: "almostWhite", bundle: resourceBundle)

    /// The "circle" asset catalog color resource.
    static let circle = DeveloperToolsSupport.ColorResource(name: "circle", bundle: resourceBundle)

    /// The "color1" asset catalog color resource.
    static let color1 = DeveloperToolsSupport.ColorResource(name: "color1", bundle: resourceBundle)

    /// The "color2" asset catalog color resource.
    static let color2 = DeveloperToolsSupport.ColorResource(name: "color2", bundle: resourceBundle)

    /// The "darkGray2" asset catalog color resource.
    static let darkGray2 = DeveloperToolsSupport.ColorResource(name: "darkGray2", bundle: resourceBundle)

    /// The "darkerGray" asset catalog color resource.
    static let darkerGray = DeveloperToolsSupport.ColorResource(name: "darkerGray", bundle: resourceBundle)

    /// The "guageColor" asset catalog color resource.
    static let guage = DeveloperToolsSupport.ColorResource(name: "guageColor", bundle: resourceBundle)

    /// The "ltGray" asset catalog color resource.
    static let ltGray = DeveloperToolsSupport.ColorResource(name: "ltGray", bundle: resourceBundle)

    /// The "medGray" asset catalog color resource.
    static let medGray = DeveloperToolsSupport.ColorResource(name: "medGray", bundle: resourceBundle)

    /// The "night" asset catalog color resource.
    static let night = DeveloperToolsSupport.ColorResource(name: "night", bundle: resourceBundle)

    /// The "text" asset catalog color resource.
    static let text = DeveloperToolsSupport.ColorResource(name: "text", bundle: resourceBundle)

}

// MARK: - Image Symbols -

@available(iOS 17.0, macOS 14.0, tvOS 17.0, watchOS 10.0, *)
extension DeveloperToolsSupport.ImageResource {

    /// The "day" asset catalog resource namespace.
    enum Day {

        /// The "day/113" asset catalog image resource.
        static let _113 = DeveloperToolsSupport.ImageResource(name: "day/113", bundle: resourceBundle)

        /// The "day/116" asset catalog image resource.
        static let _116 = DeveloperToolsSupport.ImageResource(name: "day/116", bundle: resourceBundle)

        /// The "day/119" asset catalog image resource.
        static let _119 = DeveloperToolsSupport.ImageResource(name: "day/119", bundle: resourceBundle)

        /// The "day/122" asset catalog image resource.
        static let _122 = DeveloperToolsSupport.ImageResource(name: "day/122", bundle: resourceBundle)

        /// The "day/143" asset catalog image resource.
        static let _143 = DeveloperToolsSupport.ImageResource(name: "day/143", bundle: resourceBundle)

        /// The "day/176" asset catalog image resource.
        static let _176 = DeveloperToolsSupport.ImageResource(name: "day/176", bundle: resourceBundle)

        /// The "day/179" asset catalog image resource.
        static let _179 = DeveloperToolsSupport.ImageResource(name: "day/179", bundle: resourceBundle)

        /// The "day/182" asset catalog image resource.
        static let _182 = DeveloperToolsSupport.ImageResource(name: "day/182", bundle: resourceBundle)

        /// The "day/185" asset catalog image resource.
        static let _185 = DeveloperToolsSupport.ImageResource(name: "day/185", bundle: resourceBundle)

        /// The "day/200" asset catalog image resource.
        static let _200 = DeveloperToolsSupport.ImageResource(name: "day/200", bundle: resourceBundle)

        /// The "day/227" asset catalog image resource.
        static let _227 = DeveloperToolsSupport.ImageResource(name: "day/227", bundle: resourceBundle)

        /// The "day/230" asset catalog image resource.
        static let _230 = DeveloperToolsSupport.ImageResource(name: "day/230", bundle: resourceBundle)

        /// The "day/248" asset catalog image resource.
        static let _248 = DeveloperToolsSupport.ImageResource(name: "day/248", bundle: resourceBundle)

        /// The "day/260" asset catalog image resource.
        static let _260 = DeveloperToolsSupport.ImageResource(name: "day/260", bundle: resourceBundle)

        /// The "day/263" asset catalog image resource.
        static let _263 = DeveloperToolsSupport.ImageResource(name: "day/263", bundle: resourceBundle)

        /// The "day/266" asset catalog image resource.
        static let _266 = DeveloperToolsSupport.ImageResource(name: "day/266", bundle: resourceBundle)

        /// The "day/281" asset catalog image resource.
        static let _281 = DeveloperToolsSupport.ImageResource(name: "day/281", bundle: resourceBundle)

        /// The "day/284" asset catalog image resource.
        static let _284 = DeveloperToolsSupport.ImageResource(name: "day/284", bundle: resourceBundle)

        /// The "day/293" asset catalog image resource.
        static let _293 = DeveloperToolsSupport.ImageResource(name: "day/293", bundle: resourceBundle)

        /// The "day/296" asset catalog image resource.
        static let _296 = DeveloperToolsSupport.ImageResource(name: "day/296", bundle: resourceBundle)

        /// The "day/299" asset catalog image resource.
        static let _299 = DeveloperToolsSupport.ImageResource(name: "day/299", bundle: resourceBundle)

        /// The "day/302" asset catalog image resource.
        static let _302 = DeveloperToolsSupport.ImageResource(name: "day/302", bundle: resourceBundle)

        /// The "day/305" asset catalog image resource.
        static let _305 = DeveloperToolsSupport.ImageResource(name: "day/305", bundle: resourceBundle)

        /// The "day/308" asset catalog image resource.
        static let _308 = DeveloperToolsSupport.ImageResource(name: "day/308", bundle: resourceBundle)

        /// The "day/311" asset catalog image resource.
        static let _311 = DeveloperToolsSupport.ImageResource(name: "day/311", bundle: resourceBundle)

        /// The "day/314" asset catalog image resource.
        static let _314 = DeveloperToolsSupport.ImageResource(name: "day/314", bundle: resourceBundle)

        /// The "day/317" asset catalog image resource.
        static let _317 = DeveloperToolsSupport.ImageResource(name: "day/317", bundle: resourceBundle)

        /// The "day/320" asset catalog image resource.
        static let _320 = DeveloperToolsSupport.ImageResource(name: "day/320", bundle: resourceBundle)

        /// The "day/323" asset catalog image resource.
        static let _323 = DeveloperToolsSupport.ImageResource(name: "day/323", bundle: resourceBundle)

        /// The "day/326" asset catalog image resource.
        static let _326 = DeveloperToolsSupport.ImageResource(name: "day/326", bundle: resourceBundle)

        /// The "day/329" asset catalog image resource.
        static let _329 = DeveloperToolsSupport.ImageResource(name: "day/329", bundle: resourceBundle)

        /// The "day/332" asset catalog image resource.
        static let _332 = DeveloperToolsSupport.ImageResource(name: "day/332", bundle: resourceBundle)

        /// The "day/335" asset catalog image resource.
        static let _335 = DeveloperToolsSupport.ImageResource(name: "day/335", bundle: resourceBundle)

        /// The "day/338" asset catalog image resource.
        static let _338 = DeveloperToolsSupport.ImageResource(name: "day/338", bundle: resourceBundle)

        /// The "day/350" asset catalog image resource.
        static let _350 = DeveloperToolsSupport.ImageResource(name: "day/350", bundle: resourceBundle)

        /// The "day/353" asset catalog image resource.
        static let _353 = DeveloperToolsSupport.ImageResource(name: "day/353", bundle: resourceBundle)

        /// The "day/356" asset catalog image resource.
        static let _356 = DeveloperToolsSupport.ImageResource(name: "day/356", bundle: resourceBundle)

        /// The "day/359" asset catalog image resource.
        static let _359 = DeveloperToolsSupport.ImageResource(name: "day/359", bundle: resourceBundle)

        /// The "day/362" asset catalog image resource.
        static let _362 = DeveloperToolsSupport.ImageResource(name: "day/362", bundle: resourceBundle)

        /// The "day/365" asset catalog image resource.
        static let _365 = DeveloperToolsSupport.ImageResource(name: "day/365", bundle: resourceBundle)

        /// The "day/368" asset catalog image resource.
        static let _368 = DeveloperToolsSupport.ImageResource(name: "day/368", bundle: resourceBundle)

        /// The "day/371" asset catalog image resource.
        static let _371 = DeveloperToolsSupport.ImageResource(name: "day/371", bundle: resourceBundle)

        /// The "day/374" asset catalog image resource.
        static let _374 = DeveloperToolsSupport.ImageResource(name: "day/374", bundle: resourceBundle)

        /// The "day/377" asset catalog image resource.
        static let _377 = DeveloperToolsSupport.ImageResource(name: "day/377", bundle: resourceBundle)

        /// The "day/386" asset catalog image resource.
        static let _386 = DeveloperToolsSupport.ImageResource(name: "day/386", bundle: resourceBundle)

        /// The "day/389" asset catalog image resource.
        static let _389 = DeveloperToolsSupport.ImageResource(name: "day/389", bundle: resourceBundle)

        /// The "day/392" asset catalog image resource.
        static let _392 = DeveloperToolsSupport.ImageResource(name: "day/392", bundle: resourceBundle)

        /// The "day/395" asset catalog image resource.
        static let _395 = DeveloperToolsSupport.ImageResource(name: "day/395", bundle: resourceBundle)

    }

    /// The "night" asset catalog resource namespace.
    enum Night {

        /// The "night/113" asset catalog image resource.
        static let _113 = DeveloperToolsSupport.ImageResource(name: "night/113", bundle: resourceBundle)

        /// The "night/116" asset catalog image resource.
        static let _116 = DeveloperToolsSupport.ImageResource(name: "night/116", bundle: resourceBundle)

        /// The "night/119" asset catalog image resource.
        static let _119 = DeveloperToolsSupport.ImageResource(name: "night/119", bundle: resourceBundle)

        /// The "night/122" asset catalog image resource.
        static let _122 = DeveloperToolsSupport.ImageResource(name: "night/122", bundle: resourceBundle)

        /// The "night/143" asset catalog image resource.
        static let _143 = DeveloperToolsSupport.ImageResource(name: "night/143", bundle: resourceBundle)

        /// The "night/176" asset catalog image resource.
        static let _176 = DeveloperToolsSupport.ImageResource(name: "night/176", bundle: resourceBundle)

        /// The "night/179" asset catalog image resource.
        static let _179 = DeveloperToolsSupport.ImageResource(name: "night/179", bundle: resourceBundle)

        /// The "night/182" asset catalog image resource.
        static let _182 = DeveloperToolsSupport.ImageResource(name: "night/182", bundle: resourceBundle)

        /// The "night/185" asset catalog image resource.
        static let _185 = DeveloperToolsSupport.ImageResource(name: "night/185", bundle: resourceBundle)

        /// The "night/200" asset catalog image resource.
        static let _200 = DeveloperToolsSupport.ImageResource(name: "night/200", bundle: resourceBundle)

        /// The "night/227" asset catalog image resource.
        static let _227 = DeveloperToolsSupport.ImageResource(name: "night/227", bundle: resourceBundle)

        /// The "night/230" asset catalog image resource.
        static let _230 = DeveloperToolsSupport.ImageResource(name: "night/230", bundle: resourceBundle)

        /// The "night/248" asset catalog image resource.
        static let _248 = DeveloperToolsSupport.ImageResource(name: "night/248", bundle: resourceBundle)

        /// The "night/260" asset catalog image resource.
        static let _260 = DeveloperToolsSupport.ImageResource(name: "night/260", bundle: resourceBundle)

        /// The "night/263" asset catalog image resource.
        static let _263 = DeveloperToolsSupport.ImageResource(name: "night/263", bundle: resourceBundle)

        /// The "night/266" asset catalog image resource.
        static let _266 = DeveloperToolsSupport.ImageResource(name: "night/266", bundle: resourceBundle)

        /// The "night/281" asset catalog image resource.
        static let _281 = DeveloperToolsSupport.ImageResource(name: "night/281", bundle: resourceBundle)

        /// The "night/284" asset catalog image resource.
        static let _284 = DeveloperToolsSupport.ImageResource(name: "night/284", bundle: resourceBundle)

        /// The "night/293" asset catalog image resource.
        static let _293 = DeveloperToolsSupport.ImageResource(name: "night/293", bundle: resourceBundle)

        /// The "night/296" asset catalog image resource.
        static let _296 = DeveloperToolsSupport.ImageResource(name: "night/296", bundle: resourceBundle)

        /// The "night/299" asset catalog image resource.
        static let _299 = DeveloperToolsSupport.ImageResource(name: "night/299", bundle: resourceBundle)

        /// The "night/302" asset catalog image resource.
        static let _302 = DeveloperToolsSupport.ImageResource(name: "night/302", bundle: resourceBundle)

        /// The "night/305" asset catalog image resource.
        static let _305 = DeveloperToolsSupport.ImageResource(name: "night/305", bundle: resourceBundle)

        /// The "night/308" asset catalog image resource.
        static let _308 = DeveloperToolsSupport.ImageResource(name: "night/308", bundle: resourceBundle)

        /// The "night/311" asset catalog image resource.
        static let _311 = DeveloperToolsSupport.ImageResource(name: "night/311", bundle: resourceBundle)

        /// The "night/314" asset catalog image resource.
        static let _314 = DeveloperToolsSupport.ImageResource(name: "night/314", bundle: resourceBundle)

        /// The "night/317" asset catalog image resource.
        static let _317 = DeveloperToolsSupport.ImageResource(name: "night/317", bundle: resourceBundle)

        /// The "night/320" asset catalog image resource.
        static let _320 = DeveloperToolsSupport.ImageResource(name: "night/320", bundle: resourceBundle)

        /// The "night/323" asset catalog image resource.
        static let _323 = DeveloperToolsSupport.ImageResource(name: "night/323", bundle: resourceBundle)

        /// The "night/326" asset catalog image resource.
        static let _326 = DeveloperToolsSupport.ImageResource(name: "night/326", bundle: resourceBundle)

        /// The "night/329" asset catalog image resource.
        static let _329 = DeveloperToolsSupport.ImageResource(name: "night/329", bundle: resourceBundle)

        /// The "night/332" asset catalog image resource.
        static let _332 = DeveloperToolsSupport.ImageResource(name: "night/332", bundle: resourceBundle)

        /// The "night/335" asset catalog image resource.
        static let _335 = DeveloperToolsSupport.ImageResource(name: "night/335", bundle: resourceBundle)

        /// The "night/338" asset catalog image resource.
        static let _338 = DeveloperToolsSupport.ImageResource(name: "night/338", bundle: resourceBundle)

        /// The "night/350" asset catalog image resource.
        static let _350 = DeveloperToolsSupport.ImageResource(name: "night/350", bundle: resourceBundle)

        /// The "night/353" asset catalog image resource.
        static let _353 = DeveloperToolsSupport.ImageResource(name: "night/353", bundle: resourceBundle)

        /// The "night/356" asset catalog image resource.
        static let _356 = DeveloperToolsSupport.ImageResource(name: "night/356", bundle: resourceBundle)

        /// The "night/359" asset catalog image resource.
        static let _359 = DeveloperToolsSupport.ImageResource(name: "night/359", bundle: resourceBundle)

        /// The "night/362" asset catalog image resource.
        static let _362 = DeveloperToolsSupport.ImageResource(name: "night/362", bundle: resourceBundle)

        /// The "night/365" asset catalog image resource.
        static let _365 = DeveloperToolsSupport.ImageResource(name: "night/365", bundle: resourceBundle)

        /// The "night/368" asset catalog image resource.
        static let _368 = DeveloperToolsSupport.ImageResource(name: "night/368", bundle: resourceBundle)

        /// The "night/371" asset catalog image resource.
        static let _371 = DeveloperToolsSupport.ImageResource(name: "night/371", bundle: resourceBundle)

        /// The "night/374" asset catalog image resource.
        static let _374 = DeveloperToolsSupport.ImageResource(name: "night/374", bundle: resourceBundle)

        /// The "night/377" asset catalog image resource.
        static let _377 = DeveloperToolsSupport.ImageResource(name: "night/377", bundle: resourceBundle)

        /// The "night/386" asset catalog image resource.
        static let _386 = DeveloperToolsSupport.ImageResource(name: "night/386", bundle: resourceBundle)

        /// The "night/389" asset catalog image resource.
        static let _389 = DeveloperToolsSupport.ImageResource(name: "night/389", bundle: resourceBundle)

        /// The "night/392" asset catalog image resource.
        static let _392 = DeveloperToolsSupport.ImageResource(name: "night/392", bundle: resourceBundle)

        /// The "night/395" asset catalog image resource.
        static let _395 = DeveloperToolsSupport.ImageResource(name: "night/395", bundle: resourceBundle)

    }

    /// The "albums" asset catalog image resource.
    static let albums = DeveloperToolsSupport.ImageResource(name: "albums", bundle: resourceBundle)

    /// The "clear" asset catalog image resource.
    static let clear = DeveloperToolsSupport.ImageResource(name: "clear", bundle: resourceBundle)

    /// The "ff" asset catalog image resource.
    static let ff = DeveloperToolsSupport.ImageResource(name: "ff", bundle: resourceBundle)

    /// The "loginImg" asset catalog image resource.
    static let loginImg = DeveloperToolsSupport.ImageResource(name: "loginImg", bundle: resourceBundle)

    /// The "map" asset catalog image resource.
    static let map = DeveloperToolsSupport.ImageResource(name: "map", bundle: resourceBundle)

    /// The "menu" asset catalog image resource.
    static let menu = DeveloperToolsSupport.ImageResource(name: "menu", bundle: resourceBundle)

    /// The "mountains" asset catalog image resource.
    static let mountains = DeveloperToolsSupport.ImageResource(name: "mountains", bundle: resourceBundle)

    /// The "music" asset catalog image resource.
    static let music = DeveloperToolsSupport.ImageResource(name: "music", bundle: resourceBundle)

    /// The "play" asset catalog image resource.
    static let play = DeveloperToolsSupport.ImageResource(name: "play", bundle: resourceBundle)

    /// The "playlist" asset catalog image resource.
    static let playlist = DeveloperToolsSupport.ImageResource(name: "playlist", bundle: resourceBundle)

    /// The "red_microphone" asset catalog image resource.
    static let redMicrophone = DeveloperToolsSupport.ImageResource(name: "red_microphone", bundle: resourceBundle)

    /// The "rew" asset catalog image resource.
    static let rew = DeveloperToolsSupport.ImageResource(name: "rew", bundle: resourceBundle)

    /// The "search" asset catalog image resource.
    static let search = DeveloperToolsSupport.ImageResource(name: "search", bundle: resourceBundle)

    /// The "songs" asset catalog image resource.
    static let songs = DeveloperToolsSupport.ImageResource(name: "songs", bundle: resourceBundle)

    /// The "speed" asset catalog image resource.
    static let speed = DeveloperToolsSupport.ImageResource(name: "speed", bundle: resourceBundle)

    /// The "speed0" asset catalog image resource.
    static let speed0 = DeveloperToolsSupport.ImageResource(name: "speed0", bundle: resourceBundle)

    /// The "speed100" asset catalog image resource.
    static let speed100 = DeveloperToolsSupport.ImageResource(name: "speed100", bundle: resourceBundle)

    /// The "speed30" asset catalog image resource.
    static let speed30 = DeveloperToolsSupport.ImageResource(name: "speed30", bundle: resourceBundle)

    /// The "speed50" asset catalog image resource.
    static let speed50 = DeveloperToolsSupport.ImageResource(name: "speed50", bundle: resourceBundle)

    /// The "speed70" asset catalog image resource.
    static let speed70 = DeveloperToolsSupport.ImageResource(name: "speed70", bundle: resourceBundle)

}

// MARK: - Color Symbol Extensions -

#if canImport(AppKit)
@available(macOS 14.0, *)
@available(macCatalyst, unavailable)
extension AppKit.NSColor {

    /// The "AccentColor" asset catalog color.
    static var accent: AppKit.NSColor {
#if !targetEnvironment(macCatalyst)
        .init(resource: .accent)
#else
        .init()
#endif
    }

    /// The "almostWhite" asset catalog color.
    static var almostWhite: AppKit.NSColor {
#if !targetEnvironment(macCatalyst)
        .init(resource: .almostWhite)
#else
        .init()
#endif
    }

    /// The "circle" asset catalog color.
    static var circle: AppKit.NSColor {
#if !targetEnvironment(macCatalyst)
        .init(resource: .circle)
#else
        .init()
#endif
    }

    /// The "color1" asset catalog color.
    static var color1: AppKit.NSColor {
#if !targetEnvironment(macCatalyst)
        .init(resource: .color1)
#else
        .init()
#endif
    }

    /// The "color2" asset catalog color.
    static var color2: AppKit.NSColor {
#if !targetEnvironment(macCatalyst)
        .init(resource: .color2)
#else
        .init()
#endif
    }

    /// The "darkGray2" asset catalog color.
    static var darkGray2: AppKit.NSColor {
#if !targetEnvironment(macCatalyst)
        .init(resource: .darkGray2)
#else
        .init()
#endif
    }

    /// The "darkerGray" asset catalog color.
    static var darkerGray: AppKit.NSColor {
#if !targetEnvironment(macCatalyst)
        .init(resource: .darkerGray)
#else
        .init()
#endif
    }

    /// The "guageColor" asset catalog color.
    static var guage: AppKit.NSColor {
#if !targetEnvironment(macCatalyst)
        .init(resource: .guage)
#else
        .init()
#endif
    }

    /// The "ltGray" asset catalog color.
    static var ltGray: AppKit.NSColor {
#if !targetEnvironment(macCatalyst)
        .init(resource: .ltGray)
#else
        .init()
#endif
    }

    /// The "medGray" asset catalog color.
    static var medGray: AppKit.NSColor {
#if !targetEnvironment(macCatalyst)
        .init(resource: .medGray)
#else
        .init()
#endif
    }

    /// The "night" asset catalog color.
    static var night: AppKit.NSColor {
#if !targetEnvironment(macCatalyst)
        .init(resource: .night)
#else
        .init()
#endif
    }

    /// The "text" asset catalog color.
    static var text: AppKit.NSColor {
#if !targetEnvironment(macCatalyst)
        .init(resource: .text)
#else
        .init()
#endif
    }

}
#endif

#if canImport(UIKit)
@available(iOS 17.0, tvOS 17.0, *)
@available(watchOS, unavailable)
extension UIKit.UIColor {

    /// The "AccentColor" asset catalog color.
    static var accent: UIKit.UIColor {
#if !os(watchOS)
        .init(resource: .accent)
#else
        .init()
#endif
    }

    /// The "almostWhite" asset catalog color.
    static var almostWhite: UIKit.UIColor {
#if !os(watchOS)
        .init(resource: .almostWhite)
#else
        .init()
#endif
    }

    /// The "circle" asset catalog color.
    static var circle: UIKit.UIColor {
#if !os(watchOS)
        .init(resource: .circle)
#else
        .init()
#endif
    }

    /// The "color1" asset catalog color.
    static var color1: UIKit.UIColor {
#if !os(watchOS)
        .init(resource: .color1)
#else
        .init()
#endif
    }

    /// The "color2" asset catalog color.
    static var color2: UIKit.UIColor {
#if !os(watchOS)
        .init(resource: .color2)
#else
        .init()
#endif
    }

    /// The "darkGray2" asset catalog color.
    static var darkGray2: UIKit.UIColor {
#if !os(watchOS)
        .init(resource: .darkGray2)
#else
        .init()
#endif
    }

    /// The "darkerGray" asset catalog color.
    static var darkerGray: UIKit.UIColor {
#if !os(watchOS)
        .init(resource: .darkerGray)
#else
        .init()
#endif
    }

    /// The "guageColor" asset catalog color.
    static var guage: UIKit.UIColor {
#if !os(watchOS)
        .init(resource: .guage)
#else
        .init()
#endif
    }

    /// The "ltGray" asset catalog color.
    static var ltGray: UIKit.UIColor {
#if !os(watchOS)
        .init(resource: .ltGray)
#else
        .init()
#endif
    }

    /// The "medGray" asset catalog color.
    static var medGray: UIKit.UIColor {
#if !os(watchOS)
        .init(resource: .medGray)
#else
        .init()
#endif
    }

    /// The "night" asset catalog color.
    static var night: UIKit.UIColor {
#if !os(watchOS)
        .init(resource: .night)
#else
        .init()
#endif
    }

    /// The "text" asset catalog color.
    static var text: UIKit.UIColor {
#if !os(watchOS)
        .init(resource: .text)
#else
        .init()
#endif
    }

}
#endif

#if canImport(SwiftUI)
@available(iOS 17.0, macOS 14.0, tvOS 17.0, watchOS 10.0, *)
extension SwiftUI.Color {

    /// The "AccentColor" asset catalog color.
    static var accent: SwiftUI.Color { .init(.accent) }

    /// The "almostWhite" asset catalog color.
    static var almostWhite: SwiftUI.Color { .init(.almostWhite) }

    /// The "circle" asset catalog color.
    static var circle: SwiftUI.Color { .init(.circle) }

    /// The "color1" asset catalog color.
    static var color1: SwiftUI.Color { .init(.color1) }

    /// The "color2" asset catalog color.
    static var color2: SwiftUI.Color { .init(.color2) }

    /// The "darkGray2" asset catalog color.
    static var darkGray2: SwiftUI.Color { .init(.darkGray2) }

    /// The "darkerGray" asset catalog color.
    static var darkerGray: SwiftUI.Color { .init(.darkerGray) }

    /// The "guageColor" asset catalog color.
    static var guage: SwiftUI.Color { .init(.guage) }

    /// The "ltGray" asset catalog color.
    static var ltGray: SwiftUI.Color { .init(.ltGray) }

    /// The "medGray" asset catalog color.
    static var medGray: SwiftUI.Color { .init(.medGray) }

    /// The "night" asset catalog color.
    static var night: SwiftUI.Color { .init(.night) }

    /// The "text" asset catalog color.
    static var text: SwiftUI.Color { .init(.text) }

}

@available(iOS 17.0, macOS 14.0, tvOS 17.0, watchOS 10.0, *)
extension SwiftUI.ShapeStyle where Self == SwiftUI.Color {

    /// The "AccentColor" asset catalog color.
    static var accent: SwiftUI.Color { .init(.accent) }

    /// The "almostWhite" asset catalog color.
    static var almostWhite: SwiftUI.Color { .init(.almostWhite) }

    /// The "circle" asset catalog color.
    static var circle: SwiftUI.Color { .init(.circle) }

    /// The "color1" asset catalog color.
    static var color1: SwiftUI.Color { .init(.color1) }

    /// The "color2" asset catalog color.
    static var color2: SwiftUI.Color { .init(.color2) }

    /// The "darkGray2" asset catalog color.
    static var darkGray2: SwiftUI.Color { .init(.darkGray2) }

    /// The "darkerGray" asset catalog color.
    static var darkerGray: SwiftUI.Color { .init(.darkerGray) }

    /// The "guageColor" asset catalog color.
    static var guage: SwiftUI.Color { .init(.guage) }

    /// The "ltGray" asset catalog color.
    static var ltGray: SwiftUI.Color { .init(.ltGray) }

    /// The "medGray" asset catalog color.
    static var medGray: SwiftUI.Color { .init(.medGray) }

    /// The "night" asset catalog color.
    static var night: SwiftUI.Color { .init(.night) }

    /// The "text" asset catalog color.
    static var text: SwiftUI.Color { .init(.text) }

}
#endif

// MARK: - Image Symbol Extensions -

#if canImport(AppKit)
@available(macOS 14.0, *)
@available(macCatalyst, unavailable)
extension AppKit.NSImage {

    /// The "day" asset catalog resource namespace.
    enum Day {

        /// The "day/113" asset catalog image.
        static var _113: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
            .init(resource: .Day._113)
#else
            .init()
#endif
        }

        /// The "day/116" asset catalog image.
        static var _116: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
            .init(resource: .Day._116)
#else
            .init()
#endif
        }

        /// The "day/119" asset catalog image.
        static var _119: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
            .init(resource: .Day._119)
#else
            .init()
#endif
        }

        /// The "day/122" asset catalog image.
        static var _122: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
            .init(resource: .Day._122)
#else
            .init()
#endif
        }

        /// The "day/143" asset catalog image.
        static var _143: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
            .init(resource: .Day._143)
#else
            .init()
#endif
        }

        /// The "day/176" asset catalog image.
        static var _176: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
            .init(resource: .Day._176)
#else
            .init()
#endif
        }

        /// The "day/179" asset catalog image.
        static var _179: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
            .init(resource: .Day._179)
#else
            .init()
#endif
        }

        /// The "day/182" asset catalog image.
        static var _182: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
            .init(resource: .Day._182)
#else
            .init()
#endif
        }

        /// The "day/185" asset catalog image.
        static var _185: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
            .init(resource: .Day._185)
#else
            .init()
#endif
        }

        /// The "day/200" asset catalog image.
        static var _200: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
            .init(resource: .Day._200)
#else
            .init()
#endif
        }

        /// The "day/227" asset catalog image.
        static var _227: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
            .init(resource: .Day._227)
#else
            .init()
#endif
        }

        /// The "day/230" asset catalog image.
        static var _230: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
            .init(resource: .Day._230)
#else
            .init()
#endif
        }

        /// The "day/248" asset catalog image.
        static var _248: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
            .init(resource: .Day._248)
#else
            .init()
#endif
        }

        /// The "day/260" asset catalog image.
        static var _260: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
            .init(resource: .Day._260)
#else
            .init()
#endif
        }

        /// The "day/263" asset catalog image.
        static var _263: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
            .init(resource: .Day._263)
#else
            .init()
#endif
        }

        /// The "day/266" asset catalog image.
        static var _266: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
            .init(resource: .Day._266)
#else
            .init()
#endif
        }

        /// The "day/281" asset catalog image.
        static var _281: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
            .init(resource: .Day._281)
#else
            .init()
#endif
        }

        /// The "day/284" asset catalog image.
        static var _284: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
            .init(resource: .Day._284)
#else
            .init()
#endif
        }

        /// The "day/293" asset catalog image.
        static var _293: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
            .init(resource: .Day._293)
#else
            .init()
#endif
        }

        /// The "day/296" asset catalog image.
        static var _296: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
            .init(resource: .Day._296)
#else
            .init()
#endif
        }

        /// The "day/299" asset catalog image.
        static var _299: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
            .init(resource: .Day._299)
#else
            .init()
#endif
        }

        /// The "day/302" asset catalog image.
        static var _302: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
            .init(resource: .Day._302)
#else
            .init()
#endif
        }

        /// The "day/305" asset catalog image.
        static var _305: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
            .init(resource: .Day._305)
#else
            .init()
#endif
        }

        /// The "day/308" asset catalog image.
        static var _308: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
            .init(resource: .Day._308)
#else
            .init()
#endif
        }

        /// The "day/311" asset catalog image.
        static var _311: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
            .init(resource: .Day._311)
#else
            .init()
#endif
        }

        /// The "day/314" asset catalog image.
        static var _314: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
            .init(resource: .Day._314)
#else
            .init()
#endif
        }

        /// The "day/317" asset catalog image.
        static var _317: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
            .init(resource: .Day._317)
#else
            .init()
#endif
        }

        /// The "day/320" asset catalog image.
        static var _320: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
            .init(resource: .Day._320)
#else
            .init()
#endif
        }

        /// The "day/323" asset catalog image.
        static var _323: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
            .init(resource: .Day._323)
#else
            .init()
#endif
        }

        /// The "day/326" asset catalog image.
        static var _326: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
            .init(resource: .Day._326)
#else
            .init()
#endif
        }

        /// The "day/329" asset catalog image.
        static var _329: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
            .init(resource: .Day._329)
#else
            .init()
#endif
        }

        /// The "day/332" asset catalog image.
        static var _332: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
            .init(resource: .Day._332)
#else
            .init()
#endif
        }

        /// The "day/335" asset catalog image.
        static var _335: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
            .init(resource: .Day._335)
#else
            .init()
#endif
        }

        /// The "day/338" asset catalog image.
        static var _338: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
            .init(resource: .Day._338)
#else
            .init()
#endif
        }

        /// The "day/350" asset catalog image.
        static var _350: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
            .init(resource: .Day._350)
#else
            .init()
#endif
        }

        /// The "day/353" asset catalog image.
        static var _353: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
            .init(resource: .Day._353)
#else
            .init()
#endif
        }

        /// The "day/356" asset catalog image.
        static var _356: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
            .init(resource: .Day._356)
#else
            .init()
#endif
        }

        /// The "day/359" asset catalog image.
        static var _359: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
            .init(resource: .Day._359)
#else
            .init()
#endif
        }

        /// The "day/362" asset catalog image.
        static var _362: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
            .init(resource: .Day._362)
#else
            .init()
#endif
        }

        /// The "day/365" asset catalog image.
        static var _365: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
            .init(resource: .Day._365)
#else
            .init()
#endif
        }

        /// The "day/368" asset catalog image.
        static var _368: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
            .init(resource: .Day._368)
#else
            .init()
#endif
        }

        /// The "day/371" asset catalog image.
        static var _371: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
            .init(resource: .Day._371)
#else
            .init()
#endif
        }

        /// The "day/374" asset catalog image.
        static var _374: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
            .init(resource: .Day._374)
#else
            .init()
#endif
        }

        /// The "day/377" asset catalog image.
        static var _377: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
            .init(resource: .Day._377)
#else
            .init()
#endif
        }

        /// The "day/386" asset catalog image.
        static var _386: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
            .init(resource: .Day._386)
#else
            .init()
#endif
        }

        /// The "day/389" asset catalog image.
        static var _389: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
            .init(resource: .Day._389)
#else
            .init()
#endif
        }

        /// The "day/392" asset catalog image.
        static var _392: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
            .init(resource: .Day._392)
#else
            .init()
#endif
        }

        /// The "day/395" asset catalog image.
        static var _395: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
            .init(resource: .Day._395)
#else
            .init()
#endif
        }

    }

    /// The "night" asset catalog resource namespace.
    enum Night {

        /// The "night/113" asset catalog image.
        static var _113: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
            .init(resource: .Night._113)
#else
            .init()
#endif
        }

        /// The "night/116" asset catalog image.
        static var _116: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
            .init(resource: .Night._116)
#else
            .init()
#endif
        }

        /// The "night/119" asset catalog image.
        static var _119: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
            .init(resource: .Night._119)
#else
            .init()
#endif
        }

        /// The "night/122" asset catalog image.
        static var _122: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
            .init(resource: .Night._122)
#else
            .init()
#endif
        }

        /// The "night/143" asset catalog image.
        static var _143: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
            .init(resource: .Night._143)
#else
            .init()
#endif
        }

        /// The "night/176" asset catalog image.
        static var _176: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
            .init(resource: .Night._176)
#else
            .init()
#endif
        }

        /// The "night/179" asset catalog image.
        static var _179: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
            .init(resource: .Night._179)
#else
            .init()
#endif
        }

        /// The "night/182" asset catalog image.
        static var _182: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
            .init(resource: .Night._182)
#else
            .init()
#endif
        }

        /// The "night/185" asset catalog image.
        static var _185: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
            .init(resource: .Night._185)
#else
            .init()
#endif
        }

        /// The "night/200" asset catalog image.
        static var _200: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
            .init(resource: .Night._200)
#else
            .init()
#endif
        }

        /// The "night/227" asset catalog image.
        static var _227: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
            .init(resource: .Night._227)
#else
            .init()
#endif
        }

        /// The "night/230" asset catalog image.
        static var _230: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
            .init(resource: .Night._230)
#else
            .init()
#endif
        }

        /// The "night/248" asset catalog image.
        static var _248: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
            .init(resource: .Night._248)
#else
            .init()
#endif
        }

        /// The "night/260" asset catalog image.
        static var _260: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
            .init(resource: .Night._260)
#else
            .init()
#endif
        }

        /// The "night/263" asset catalog image.
        static var _263: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
            .init(resource: .Night._263)
#else
            .init()
#endif
        }

        /// The "night/266" asset catalog image.
        static var _266: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
            .init(resource: .Night._266)
#else
            .init()
#endif
        }

        /// The "night/281" asset catalog image.
        static var _281: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
            .init(resource: .Night._281)
#else
            .init()
#endif
        }

        /// The "night/284" asset catalog image.
        static var _284: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
            .init(resource: .Night._284)
#else
            .init()
#endif
        }

        /// The "night/293" asset catalog image.
        static var _293: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
            .init(resource: .Night._293)
#else
            .init()
#endif
        }

        /// The "night/296" asset catalog image.
        static var _296: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
            .init(resource: .Night._296)
#else
            .init()
#endif
        }

        /// The "night/299" asset catalog image.
        static var _299: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
            .init(resource: .Night._299)
#else
            .init()
#endif
        }

        /// The "night/302" asset catalog image.
        static var _302: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
            .init(resource: .Night._302)
#else
            .init()
#endif
        }

        /// The "night/305" asset catalog image.
        static var _305: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
            .init(resource: .Night._305)
#else
            .init()
#endif
        }

        /// The "night/308" asset catalog image.
        static var _308: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
            .init(resource: .Night._308)
#else
            .init()
#endif
        }

        /// The "night/311" asset catalog image.
        static var _311: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
            .init(resource: .Night._311)
#else
            .init()
#endif
        }

        /// The "night/314" asset catalog image.
        static var _314: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
            .init(resource: .Night._314)
#else
            .init()
#endif
        }

        /// The "night/317" asset catalog image.
        static var _317: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
            .init(resource: .Night._317)
#else
            .init()
#endif
        }

        /// The "night/320" asset catalog image.
        static var _320: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
            .init(resource: .Night._320)
#else
            .init()
#endif
        }

        /// The "night/323" asset catalog image.
        static var _323: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
            .init(resource: .Night._323)
#else
            .init()
#endif
        }

        /// The "night/326" asset catalog image.
        static var _326: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
            .init(resource: .Night._326)
#else
            .init()
#endif
        }

        /// The "night/329" asset catalog image.
        static var _329: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
            .init(resource: .Night._329)
#else
            .init()
#endif
        }

        /// The "night/332" asset catalog image.
        static var _332: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
            .init(resource: .Night._332)
#else
            .init()
#endif
        }

        /// The "night/335" asset catalog image.
        static var _335: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
            .init(resource: .Night._335)
#else
            .init()
#endif
        }

        /// The "night/338" asset catalog image.
        static var _338: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
            .init(resource: .Night._338)
#else
            .init()
#endif
        }

        /// The "night/350" asset catalog image.
        static var _350: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
            .init(resource: .Night._350)
#else
            .init()
#endif
        }

        /// The "night/353" asset catalog image.
        static var _353: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
            .init(resource: .Night._353)
#else
            .init()
#endif
        }

        /// The "night/356" asset catalog image.
        static var _356: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
            .init(resource: .Night._356)
#else
            .init()
#endif
        }

        /// The "night/359" asset catalog image.
        static var _359: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
            .init(resource: .Night._359)
#else
            .init()
#endif
        }

        /// The "night/362" asset catalog image.
        static var _362: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
            .init(resource: .Night._362)
#else
            .init()
#endif
        }

        /// The "night/365" asset catalog image.
        static var _365: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
            .init(resource: .Night._365)
#else
            .init()
#endif
        }

        /// The "night/368" asset catalog image.
        static var _368: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
            .init(resource: .Night._368)
#else
            .init()
#endif
        }

        /// The "night/371" asset catalog image.
        static var _371: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
            .init(resource: .Night._371)
#else
            .init()
#endif
        }

        /// The "night/374" asset catalog image.
        static var _374: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
            .init(resource: .Night._374)
#else
            .init()
#endif
        }

        /// The "night/377" asset catalog image.
        static var _377: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
            .init(resource: .Night._377)
#else
            .init()
#endif
        }

        /// The "night/386" asset catalog image.
        static var _386: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
            .init(resource: .Night._386)
#else
            .init()
#endif
        }

        /// The "night/389" asset catalog image.
        static var _389: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
            .init(resource: .Night._389)
#else
            .init()
#endif
        }

        /// The "night/392" asset catalog image.
        static var _392: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
            .init(resource: .Night._392)
#else
            .init()
#endif
        }

        /// The "night/395" asset catalog image.
        static var _395: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
            .init(resource: .Night._395)
#else
            .init()
#endif
        }

    }

    /// The "albums" asset catalog image.
    static var albums: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .albums)
#else
        .init()
#endif
    }

    /// The "clear" asset catalog image.
    static var clear: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .clear)
#else
        .init()
#endif
    }

    /// The "ff" asset catalog image.
    static var ff: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .ff)
#else
        .init()
#endif
    }

    /// The "loginImg" asset catalog image.
    static var loginImg: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .loginImg)
#else
        .init()
#endif
    }

    /// The "map" asset catalog image.
    static var map: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .map)
#else
        .init()
#endif
    }

    /// The "menu" asset catalog image.
    static var menu: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .menu)
#else
        .init()
#endif
    }

    /// The "mountains" asset catalog image.
    static var mountains: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .mountains)
#else
        .init()
#endif
    }

    /// The "music" asset catalog image.
    static var music: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .music)
#else
        .init()
#endif
    }

    /// The "play" asset catalog image.
    static var play: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .play)
#else
        .init()
#endif
    }

    /// The "playlist" asset catalog image.
    static var playlist: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .playlist)
#else
        .init()
#endif
    }

    /// The "red_microphone" asset catalog image.
    static var redMicrophone: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .redMicrophone)
#else
        .init()
#endif
    }

    /// The "rew" asset catalog image.
    static var rew: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .rew)
#else
        .init()
#endif
    }

    /// The "search" asset catalog image.
    static var search: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .search)
#else
        .init()
#endif
    }

    /// The "songs" asset catalog image.
    static var songs: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .songs)
#else
        .init()
#endif
    }

    /// The "speed" asset catalog image.
    static var speed: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .speed)
#else
        .init()
#endif
    }

    /// The "speed0" asset catalog image.
    static var speed0: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .speed0)
#else
        .init()
#endif
    }

    /// The "speed100" asset catalog image.
    static var speed100: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .speed100)
#else
        .init()
#endif
    }

    /// The "speed30" asset catalog image.
    static var speed30: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .speed30)
#else
        .init()
#endif
    }

    /// The "speed50" asset catalog image.
    static var speed50: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .speed50)
#else
        .init()
#endif
    }

    /// The "speed70" asset catalog image.
    static var speed70: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .speed70)
#else
        .init()
#endif
    }

}
#endif

#if canImport(UIKit)
@available(iOS 17.0, tvOS 17.0, *)
@available(watchOS, unavailable)
extension UIKit.UIImage {

    /// The "day" asset catalog resource namespace.
    enum Day {

        /// The "day/113" asset catalog image.
        static var _113: UIKit.UIImage {
#if !os(watchOS)
            .init(resource: .Day._113)
#else
            .init()
#endif
        }

        /// The "day/116" asset catalog image.
        static var _116: UIKit.UIImage {
#if !os(watchOS)
            .init(resource: .Day._116)
#else
            .init()
#endif
        }

        /// The "day/119" asset catalog image.
        static var _119: UIKit.UIImage {
#if !os(watchOS)
            .init(resource: .Day._119)
#else
            .init()
#endif
        }

        /// The "day/122" asset catalog image.
        static var _122: UIKit.UIImage {
#if !os(watchOS)
            .init(resource: .Day._122)
#else
            .init()
#endif
        }

        /// The "day/143" asset catalog image.
        static var _143: UIKit.UIImage {
#if !os(watchOS)
            .init(resource: .Day._143)
#else
            .init()
#endif
        }

        /// The "day/176" asset catalog image.
        static var _176: UIKit.UIImage {
#if !os(watchOS)
            .init(resource: .Day._176)
#else
            .init()
#endif
        }

        /// The "day/179" asset catalog image.
        static var _179: UIKit.UIImage {
#if !os(watchOS)
            .init(resource: .Day._179)
#else
            .init()
#endif
        }

        /// The "day/182" asset catalog image.
        static var _182: UIKit.UIImage {
#if !os(watchOS)
            .init(resource: .Day._182)
#else
            .init()
#endif
        }

        /// The "day/185" asset catalog image.
        static var _185: UIKit.UIImage {
#if !os(watchOS)
            .init(resource: .Day._185)
#else
            .init()
#endif
        }

        /// The "day/200" asset catalog image.
        static var _200: UIKit.UIImage {
#if !os(watchOS)
            .init(resource: .Day._200)
#else
            .init()
#endif
        }

        /// The "day/227" asset catalog image.
        static var _227: UIKit.UIImage {
#if !os(watchOS)
            .init(resource: .Day._227)
#else
            .init()
#endif
        }

        /// The "day/230" asset catalog image.
        static var _230: UIKit.UIImage {
#if !os(watchOS)
            .init(resource: .Day._230)
#else
            .init()
#endif
        }

        /// The "day/248" asset catalog image.
        static var _248: UIKit.UIImage {
#if !os(watchOS)
            .init(resource: .Day._248)
#else
            .init()
#endif
        }

        /// The "day/260" asset catalog image.
        static var _260: UIKit.UIImage {
#if !os(watchOS)
            .init(resource: .Day._260)
#else
            .init()
#endif
        }

        /// The "day/263" asset catalog image.
        static var _263: UIKit.UIImage {
#if !os(watchOS)
            .init(resource: .Day._263)
#else
            .init()
#endif
        }

        /// The "day/266" asset catalog image.
        static var _266: UIKit.UIImage {
#if !os(watchOS)
            .init(resource: .Day._266)
#else
            .init()
#endif
        }

        /// The "day/281" asset catalog image.
        static var _281: UIKit.UIImage {
#if !os(watchOS)
            .init(resource: .Day._281)
#else
            .init()
#endif
        }

        /// The "day/284" asset catalog image.
        static var _284: UIKit.UIImage {
#if !os(watchOS)
            .init(resource: .Day._284)
#else
            .init()
#endif
        }

        /// The "day/293" asset catalog image.
        static var _293: UIKit.UIImage {
#if !os(watchOS)
            .init(resource: .Day._293)
#else
            .init()
#endif
        }

        /// The "day/296" asset catalog image.
        static var _296: UIKit.UIImage {
#if !os(watchOS)
            .init(resource: .Day._296)
#else
            .init()
#endif
        }

        /// The "day/299" asset catalog image.
        static var _299: UIKit.UIImage {
#if !os(watchOS)
            .init(resource: .Day._299)
#else
            .init()
#endif
        }

        /// The "day/302" asset catalog image.
        static var _302: UIKit.UIImage {
#if !os(watchOS)
            .init(resource: .Day._302)
#else
            .init()
#endif
        }

        /// The "day/305" asset catalog image.
        static var _305: UIKit.UIImage {
#if !os(watchOS)
            .init(resource: .Day._305)
#else
            .init()
#endif
        }

        /// The "day/308" asset catalog image.
        static var _308: UIKit.UIImage {
#if !os(watchOS)
            .init(resource: .Day._308)
#else
            .init()
#endif
        }

        /// The "day/311" asset catalog image.
        static var _311: UIKit.UIImage {
#if !os(watchOS)
            .init(resource: .Day._311)
#else
            .init()
#endif
        }

        /// The "day/314" asset catalog image.
        static var _314: UIKit.UIImage {
#if !os(watchOS)
            .init(resource: .Day._314)
#else
            .init()
#endif
        }

        /// The "day/317" asset catalog image.
        static var _317: UIKit.UIImage {
#if !os(watchOS)
            .init(resource: .Day._317)
#else
            .init()
#endif
        }

        /// The "day/320" asset catalog image.
        static var _320: UIKit.UIImage {
#if !os(watchOS)
            .init(resource: .Day._320)
#else
            .init()
#endif
        }

        /// The "day/323" asset catalog image.
        static var _323: UIKit.UIImage {
#if !os(watchOS)
            .init(resource: .Day._323)
#else
            .init()
#endif
        }

        /// The "day/326" asset catalog image.
        static var _326: UIKit.UIImage {
#if !os(watchOS)
            .init(resource: .Day._326)
#else
            .init()
#endif
        }

        /// The "day/329" asset catalog image.
        static var _329: UIKit.UIImage {
#if !os(watchOS)
            .init(resource: .Day._329)
#else
            .init()
#endif
        }

        /// The "day/332" asset catalog image.
        static var _332: UIKit.UIImage {
#if !os(watchOS)
            .init(resource: .Day._332)
#else
            .init()
#endif
        }

        /// The "day/335" asset catalog image.
        static var _335: UIKit.UIImage {
#if !os(watchOS)
            .init(resource: .Day._335)
#else
            .init()
#endif
        }

        /// The "day/338" asset catalog image.
        static var _338: UIKit.UIImage {
#if !os(watchOS)
            .init(resource: .Day._338)
#else
            .init()
#endif
        }

        /// The "day/350" asset catalog image.
        static var _350: UIKit.UIImage {
#if !os(watchOS)
            .init(resource: .Day._350)
#else
            .init()
#endif
        }

        /// The "day/353" asset catalog image.
        static var _353: UIKit.UIImage {
#if !os(watchOS)
            .init(resource: .Day._353)
#else
            .init()
#endif
        }

        /// The "day/356" asset catalog image.
        static var _356: UIKit.UIImage {
#if !os(watchOS)
            .init(resource: .Day._356)
#else
            .init()
#endif
        }

        /// The "day/359" asset catalog image.
        static var _359: UIKit.UIImage {
#if !os(watchOS)
            .init(resource: .Day._359)
#else
            .init()
#endif
        }

        /// The "day/362" asset catalog image.
        static var _362: UIKit.UIImage {
#if !os(watchOS)
            .init(resource: .Day._362)
#else
            .init()
#endif
        }

        /// The "day/365" asset catalog image.
        static var _365: UIKit.UIImage {
#if !os(watchOS)
            .init(resource: .Day._365)
#else
            .init()
#endif
        }

        /// The "day/368" asset catalog image.
        static var _368: UIKit.UIImage {
#if !os(watchOS)
            .init(resource: .Day._368)
#else
            .init()
#endif
        }

        /// The "day/371" asset catalog image.
        static var _371: UIKit.UIImage {
#if !os(watchOS)
            .init(resource: .Day._371)
#else
            .init()
#endif
        }

        /// The "day/374" asset catalog image.
        static var _374: UIKit.UIImage {
#if !os(watchOS)
            .init(resource: .Day._374)
#else
            .init()
#endif
        }

        /// The "day/377" asset catalog image.
        static var _377: UIKit.UIImage {
#if !os(watchOS)
            .init(resource: .Day._377)
#else
            .init()
#endif
        }

        /// The "day/386" asset catalog image.
        static var _386: UIKit.UIImage {
#if !os(watchOS)
            .init(resource: .Day._386)
#else
            .init()
#endif
        }

        /// The "day/389" asset catalog image.
        static var _389: UIKit.UIImage {
#if !os(watchOS)
            .init(resource: .Day._389)
#else
            .init()
#endif
        }

        /// The "day/392" asset catalog image.
        static var _392: UIKit.UIImage {
#if !os(watchOS)
            .init(resource: .Day._392)
#else
            .init()
#endif
        }

        /// The "day/395" asset catalog image.
        static var _395: UIKit.UIImage {
#if !os(watchOS)
            .init(resource: .Day._395)
#else
            .init()
#endif
        }

    }

    /// The "night" asset catalog resource namespace.
    enum Night {

        /// The "night/113" asset catalog image.
        static var _113: UIKit.UIImage {
#if !os(watchOS)
            .init(resource: .Night._113)
#else
            .init()
#endif
        }

        /// The "night/116" asset catalog image.
        static var _116: UIKit.UIImage {
#if !os(watchOS)
            .init(resource: .Night._116)
#else
            .init()
#endif
        }

        /// The "night/119" asset catalog image.
        static var _119: UIKit.UIImage {
#if !os(watchOS)
            .init(resource: .Night._119)
#else
            .init()
#endif
        }

        /// The "night/122" asset catalog image.
        static var _122: UIKit.UIImage {
#if !os(watchOS)
            .init(resource: .Night._122)
#else
            .init()
#endif
        }

        /// The "night/143" asset catalog image.
        static var _143: UIKit.UIImage {
#if !os(watchOS)
            .init(resource: .Night._143)
#else
            .init()
#endif
        }

        /// The "night/176" asset catalog image.
        static var _176: UIKit.UIImage {
#if !os(watchOS)
            .init(resource: .Night._176)
#else
            .init()
#endif
        }

        /// The "night/179" asset catalog image.
        static var _179: UIKit.UIImage {
#if !os(watchOS)
            .init(resource: .Night._179)
#else
            .init()
#endif
        }

        /// The "night/182" asset catalog image.
        static var _182: UIKit.UIImage {
#if !os(watchOS)
            .init(resource: .Night._182)
#else
            .init()
#endif
        }

        /// The "night/185" asset catalog image.
        static var _185: UIKit.UIImage {
#if !os(watchOS)
            .init(resource: .Night._185)
#else
            .init()
#endif
        }

        /// The "night/200" asset catalog image.
        static var _200: UIKit.UIImage {
#if !os(watchOS)
            .init(resource: .Night._200)
#else
            .init()
#endif
        }

        /// The "night/227" asset catalog image.
        static var _227: UIKit.UIImage {
#if !os(watchOS)
            .init(resource: .Night._227)
#else
            .init()
#endif
        }

        /// The "night/230" asset catalog image.
        static var _230: UIKit.UIImage {
#if !os(watchOS)
            .init(resource: .Night._230)
#else
            .init()
#endif
        }

        /// The "night/248" asset catalog image.
        static var _248: UIKit.UIImage {
#if !os(watchOS)
            .init(resource: .Night._248)
#else
            .init()
#endif
        }

        /// The "night/260" asset catalog image.
        static var _260: UIKit.UIImage {
#if !os(watchOS)
            .init(resource: .Night._260)
#else
            .init()
#endif
        }

        /// The "night/263" asset catalog image.
        static var _263: UIKit.UIImage {
#if !os(watchOS)
            .init(resource: .Night._263)
#else
            .init()
#endif
        }

        /// The "night/266" asset catalog image.
        static var _266: UIKit.UIImage {
#if !os(watchOS)
            .init(resource: .Night._266)
#else
            .init()
#endif
        }

        /// The "night/281" asset catalog image.
        static var _281: UIKit.UIImage {
#if !os(watchOS)
            .init(resource: .Night._281)
#else
            .init()
#endif
        }

        /// The "night/284" asset catalog image.
        static var _284: UIKit.UIImage {
#if !os(watchOS)
            .init(resource: .Night._284)
#else
            .init()
#endif
        }

        /// The "night/293" asset catalog image.
        static var _293: UIKit.UIImage {
#if !os(watchOS)
            .init(resource: .Night._293)
#else
            .init()
#endif
        }

        /// The "night/296" asset catalog image.
        static var _296: UIKit.UIImage {
#if !os(watchOS)
            .init(resource: .Night._296)
#else
            .init()
#endif
        }

        /// The "night/299" asset catalog image.
        static var _299: UIKit.UIImage {
#if !os(watchOS)
            .init(resource: .Night._299)
#else
            .init()
#endif
        }

        /// The "night/302" asset catalog image.
        static var _302: UIKit.UIImage {
#if !os(watchOS)
            .init(resource: .Night._302)
#else
            .init()
#endif
        }

        /// The "night/305" asset catalog image.
        static var _305: UIKit.UIImage {
#if !os(watchOS)
            .init(resource: .Night._305)
#else
            .init()
#endif
        }

        /// The "night/308" asset catalog image.
        static var _308: UIKit.UIImage {
#if !os(watchOS)
            .init(resource: .Night._308)
#else
            .init()
#endif
        }

        /// The "night/311" asset catalog image.
        static var _311: UIKit.UIImage {
#if !os(watchOS)
            .init(resource: .Night._311)
#else
            .init()
#endif
        }

        /// The "night/314" asset catalog image.
        static var _314: UIKit.UIImage {
#if !os(watchOS)
            .init(resource: .Night._314)
#else
            .init()
#endif
        }

        /// The "night/317" asset catalog image.
        static var _317: UIKit.UIImage {
#if !os(watchOS)
            .init(resource: .Night._317)
#else
            .init()
#endif
        }

        /// The "night/320" asset catalog image.
        static var _320: UIKit.UIImage {
#if !os(watchOS)
            .init(resource: .Night._320)
#else
            .init()
#endif
        }

        /// The "night/323" asset catalog image.
        static var _323: UIKit.UIImage {
#if !os(watchOS)
            .init(resource: .Night._323)
#else
            .init()
#endif
        }

        /// The "night/326" asset catalog image.
        static var _326: UIKit.UIImage {
#if !os(watchOS)
            .init(resource: .Night._326)
#else
            .init()
#endif
        }

        /// The "night/329" asset catalog image.
        static var _329: UIKit.UIImage {
#if !os(watchOS)
            .init(resource: .Night._329)
#else
            .init()
#endif
        }

        /// The "night/332" asset catalog image.
        static var _332: UIKit.UIImage {
#if !os(watchOS)
            .init(resource: .Night._332)
#else
            .init()
#endif
        }

        /// The "night/335" asset catalog image.
        static var _335: UIKit.UIImage {
#if !os(watchOS)
            .init(resource: .Night._335)
#else
            .init()
#endif
        }

        /// The "night/338" asset catalog image.
        static var _338: UIKit.UIImage {
#if !os(watchOS)
            .init(resource: .Night._338)
#else
            .init()
#endif
        }

        /// The "night/350" asset catalog image.
        static var _350: UIKit.UIImage {
#if !os(watchOS)
            .init(resource: .Night._350)
#else
            .init()
#endif
        }

        /// The "night/353" asset catalog image.
        static var _353: UIKit.UIImage {
#if !os(watchOS)
            .init(resource: .Night._353)
#else
            .init()
#endif
        }

        /// The "night/356" asset catalog image.
        static var _356: UIKit.UIImage {
#if !os(watchOS)
            .init(resource: .Night._356)
#else
            .init()
#endif
        }

        /// The "night/359" asset catalog image.
        static var _359: UIKit.UIImage {
#if !os(watchOS)
            .init(resource: .Night._359)
#else
            .init()
#endif
        }

        /// The "night/362" asset catalog image.
        static var _362: UIKit.UIImage {
#if !os(watchOS)
            .init(resource: .Night._362)
#else
            .init()
#endif
        }

        /// The "night/365" asset catalog image.
        static var _365: UIKit.UIImage {
#if !os(watchOS)
            .init(resource: .Night._365)
#else
            .init()
#endif
        }

        /// The "night/368" asset catalog image.
        static var _368: UIKit.UIImage {
#if !os(watchOS)
            .init(resource: .Night._368)
#else
            .init()
#endif
        }

        /// The "night/371" asset catalog image.
        static var _371: UIKit.UIImage {
#if !os(watchOS)
            .init(resource: .Night._371)
#else
            .init()
#endif
        }

        /// The "night/374" asset catalog image.
        static var _374: UIKit.UIImage {
#if !os(watchOS)
            .init(resource: .Night._374)
#else
            .init()
#endif
        }

        /// The "night/377" asset catalog image.
        static var _377: UIKit.UIImage {
#if !os(watchOS)
            .init(resource: .Night._377)
#else
            .init()
#endif
        }

        /// The "night/386" asset catalog image.
        static var _386: UIKit.UIImage {
#if !os(watchOS)
            .init(resource: .Night._386)
#else
            .init()
#endif
        }

        /// The "night/389" asset catalog image.
        static var _389: UIKit.UIImage {
#if !os(watchOS)
            .init(resource: .Night._389)
#else
            .init()
#endif
        }

        /// The "night/392" asset catalog image.
        static var _392: UIKit.UIImage {
#if !os(watchOS)
            .init(resource: .Night._392)
#else
            .init()
#endif
        }

        /// The "night/395" asset catalog image.
        static var _395: UIKit.UIImage {
#if !os(watchOS)
            .init(resource: .Night._395)
#else
            .init()
#endif
        }

    }

    /// The "albums" asset catalog image.
    static var albums: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .albums)
#else
        .init()
#endif
    }

    /// The "clear" asset catalog image.
    static var clear: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .clear)
#else
        .init()
#endif
    }

    /// The "ff" asset catalog image.
    static var ff: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .ff)
#else
        .init()
#endif
    }

    /// The "loginImg" asset catalog image.
    static var loginImg: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .loginImg)
#else
        .init()
#endif
    }

    /// The "map" asset catalog image.
    static var map: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .map)
#else
        .init()
#endif
    }

    /// The "menu" asset catalog image.
    static var menu: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .menu)
#else
        .init()
#endif
    }

    /// The "mountains" asset catalog image.
    static var mountains: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .mountains)
#else
        .init()
#endif
    }

    /// The "music" asset catalog image.
    static var music: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .music)
#else
        .init()
#endif
    }

    /// The "play" asset catalog image.
    static var play: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .play)
#else
        .init()
#endif
    }

    /// The "playlist" asset catalog image.
    static var playlist: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .playlist)
#else
        .init()
#endif
    }

    /// The "red_microphone" asset catalog image.
    static var redMicrophone: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .redMicrophone)
#else
        .init()
#endif
    }

    /// The "rew" asset catalog image.
    static var rew: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .rew)
#else
        .init()
#endif
    }

    /// The "search" asset catalog image.
    static var search: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .search)
#else
        .init()
#endif
    }

    /// The "songs" asset catalog image.
    static var songs: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .songs)
#else
        .init()
#endif
    }

    /// The "speed" asset catalog image.
    static var speed: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .speed)
#else
        .init()
#endif
    }

    /// The "speed0" asset catalog image.
    static var speed0: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .speed0)
#else
        .init()
#endif
    }

    /// The "speed100" asset catalog image.
    static var speed100: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .speed100)
#else
        .init()
#endif
    }

    /// The "speed30" asset catalog image.
    static var speed30: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .speed30)
#else
        .init()
#endif
    }

    /// The "speed50" asset catalog image.
    static var speed50: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .speed50)
#else
        .init()
#endif
    }

    /// The "speed70" asset catalog image.
    static var speed70: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .speed70)
#else
        .init()
#endif
    }

}
#endif

// MARK: - Thinnable Asset Support -

@available(iOS 17.0, macOS 14.0, tvOS 17.0, watchOS 10.0, *)
@available(watchOS, unavailable)
extension DeveloperToolsSupport.ColorResource {

    private init?(thinnableName: Swift.String, bundle: Foundation.Bundle) {
#if canImport(AppKit) && os(macOS)
        if AppKit.NSColor(named: NSColor.Name(thinnableName), bundle: bundle) != nil {
            self.init(name: thinnableName, bundle: bundle)
        } else {
            return nil
        }
#elseif canImport(UIKit) && !os(watchOS)
        if UIKit.UIColor(named: thinnableName, in: bundle, compatibleWith: nil) != nil {
            self.init(name: thinnableName, bundle: bundle)
        } else {
            return nil
        }
#else
        return nil
#endif
    }

}

#if canImport(AppKit)
@available(macOS 14.0, *)
@available(macCatalyst, unavailable)
extension AppKit.NSColor {

    private convenience init?(thinnableResource: DeveloperToolsSupport.ColorResource?) {
#if !targetEnvironment(macCatalyst)
        if let resource = thinnableResource {
            self.init(resource: resource)
        } else {
            return nil
        }
#else
        return nil
#endif
    }

}
#endif

#if canImport(UIKit)
@available(iOS 17.0, tvOS 17.0, *)
@available(watchOS, unavailable)
extension UIKit.UIColor {

    private convenience init?(thinnableResource: DeveloperToolsSupport.ColorResource?) {
#if !os(watchOS)
        if let resource = thinnableResource {
            self.init(resource: resource)
        } else {
            return nil
        }
#else
        return nil
#endif
    }

}
#endif

#if canImport(SwiftUI)
@available(iOS 17.0, macOS 14.0, tvOS 17.0, watchOS 10.0, *)
extension SwiftUI.Color {

    private init?(thinnableResource: DeveloperToolsSupport.ColorResource?) {
        if let resource = thinnableResource {
            self.init(resource)
        } else {
            return nil
        }
    }

}

@available(iOS 17.0, macOS 14.0, tvOS 17.0, watchOS 10.0, *)
extension SwiftUI.ShapeStyle where Self == SwiftUI.Color {

    private init?(thinnableResource: DeveloperToolsSupport.ColorResource?) {
        if let resource = thinnableResource {
            self.init(resource)
        } else {
            return nil
        }
    }

}
#endif

@available(iOS 17.0, macOS 14.0, tvOS 17.0, watchOS 10.0, *)
@available(watchOS, unavailable)
extension DeveloperToolsSupport.ImageResource {

    private init?(thinnableName: Swift.String, bundle: Foundation.Bundle) {
#if canImport(AppKit) && os(macOS)
        if bundle.image(forResource: NSImage.Name(thinnableName)) != nil {
            self.init(name: thinnableName, bundle: bundle)
        } else {
            return nil
        }
#elseif canImport(UIKit) && !os(watchOS)
        if UIKit.UIImage(named: thinnableName, in: bundle, compatibleWith: nil) != nil {
            self.init(name: thinnableName, bundle: bundle)
        } else {
            return nil
        }
#else
        return nil
#endif
    }

}

#if canImport(AppKit)
@available(macOS 14.0, *)
@available(macCatalyst, unavailable)
extension AppKit.NSImage {

    private convenience init?(thinnableResource: DeveloperToolsSupport.ImageResource?) {
#if !targetEnvironment(macCatalyst)
        if let resource = thinnableResource {
            self.init(resource: resource)
        } else {
            return nil
        }
#else
        return nil
#endif
    }

}
#endif

#if canImport(UIKit)
@available(iOS 17.0, tvOS 17.0, *)
@available(watchOS, unavailable)
extension UIKit.UIImage {

    private convenience init?(thinnableResource: DeveloperToolsSupport.ImageResource?) {
#if !os(watchOS)
        if let resource = thinnableResource {
            self.init(resource: resource)
        } else {
            return nil
        }
#else
        return nil
#endif
    }

}
#endif

