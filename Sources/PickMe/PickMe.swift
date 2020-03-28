//
//  PickMe.swift
//  PickMe
//
//  Created by Kieran Brown on 3/25/20.
//  Copyright © 2020 BrownandSons. All rights reserved.
//


import SwiftUI

// MARK: - Style
@available(iOS 13.0, macOS 10.15, watchOS 6.0 , tvOS 13.0, *)
public struct SelectableConfiguration {
    public let view: AnyView
    public let isSelected: Bool
}
@available(iOS 13.0, macOS 10.15, watchOS 6.0 , tvOS 13.0, *)
public protocol SelectableStyle {
    associatedtype Selection: View
    
    func makeBody(configuration: Self.Configuration) -> Self.Selection
    
    typealias Configuration = SelectableConfiguration
}
@available(iOS 13.0, macOS 10.15, watchOS 6.0 , tvOS 13.0, *)
public extension SelectableStyle {
    func makeBodyTypeErased(configuration: Self.Configuration) -> AnyView {
        AnyView(self.makeBody(configuration: configuration))
    }
}
@available(iOS 13.0, macOS 10.15, watchOS 6.0 , tvOS 13.0, *)
public struct AnySelectableStyle: SelectableStyle {
    private let _makeBody: (Self.Configuration) -> AnyView
    
    public init<ST: SelectableStyle>(_ style: ST) {
        self._makeBody = style.makeBodyTypeErased
    }
    
    public func makeBody(configuration: Self.Configuration) -> some View {
        self._makeBody(configuration)
    }
}
@available(iOS 13.0, macOS 10.15, watchOS 6.0 , tvOS 13.0, *)
public struct DefaultSelectableStyle: SelectableStyle {
    public func makeBody(configuration: Self.Configuration) -> some View {
        configuration.view.border(configuration.isSelected ? Color.blue : Color.clear)
    }
}
@available(iOS 13.0, macOS 10.15, watchOS 6.0 , tvOS 13.0, *)
public struct SelectableStyleKey: EnvironmentKey {
    public static let defaultValue: AnySelectableStyle = AnySelectableStyle(DefaultSelectableStyle())
}
@available(iOS 13.0, macOS 10.15, watchOS 6.0 , tvOS 13.0, *)
extension EnvironmentValues {
    public var selectableStyle: AnySelectableStyle {
        get {
            return self[SelectableStyleKey.self]
        }
        set {
            self[SelectableStyleKey.self] = newValue
        }
    }
}
@available(iOS 13.0, macOS 10.15, watchOS 6.0 , tvOS 13.0, *)
extension View {
    public func selectableStyle<S>(_ style: S) -> some View where S: SelectableStyle {
        self.environment(\.selectableStyle, AnySelectableStyle(style))
    }
}


// MARK: - Selectable Modifiers
@available(iOS 13.0, macOS 10.15, watchOS 6.0 , tvOS 13.0, *)
struct Selectable<H: Hashable>: ViewModifier {
    @Environment(\.selectableStyle) private var style: AnySelectableStyle
    @Binding var selection: H
    var id: H
    func select() {
        self.selection = self.id
    }
    
    func body(content: Content) -> some View {
        style.makeBody(configuration: .init(view: AnyView(content.onTapGesture { self.select() }), isSelected: self.id == self.selection))
    }
}
@available(iOS 13.0, macOS 10.15, watchOS 6.0 , tvOS 13.0, *)
struct SelectableOptional<H: Hashable>: ViewModifier {
    @Environment(\.selectableStyle) private var style: AnySelectableStyle
    @Binding var selection: H?
    var id: H
    func select() {
        if self.selection == self.id {
            self.selection = nil
        } else {
            self.selection = self.id
        }
    }
    
    func body(content: Content) -> some View {
        style.makeBody(configuration: .init(view: AnyView(content.onTapGesture { self.select() }), isSelected: self.id == self.selection))
    }
}
@available(iOS 13.0, macOS 10.15, watchOS 6.0 , tvOS 13.0, *)
struct SelectableSet<H: Hashable>: ViewModifier {
    @Environment(\.selectableStyle) private var style: AnySelectableStyle
    @Binding var selection: Set<H>
    var id: H
    func select() {
        if self.selection.contains(self.id) {
            self.selection.remove(self.id)
        } else {
            self.selection.insert(self.id)
        }
    }
    
    func body(content: Content) -> some View {
        style.makeBody(configuration: .init(view: AnyView(content.onTapGesture { self.select() }), isSelected: self.selection.contains(self.id)))
    }
}

// MARK: - View Extensions
@available(iOS 13.0, macOS 10.15, watchOS 6.0 , tvOS 13.0, *)
public extension View {
    func selectable<H: Hashable>(selection: Binding<H>, id: H) -> some View {
        self.modifier(Selectable(selection: selection, id: id))
    }
    func selectable<H: Hashable>(selection: Binding<H?>, id: H) -> some View {
        self.modifier(SelectableOptional(selection: selection, id: id))
    }
    
    func selectable<H: Hashable>(selection: Binding<Set<H>>, id: H) -> some View {
        self.modifier(SelectableSet(selection: selection, id: id))
    }
}
