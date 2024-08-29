//
//  Copyright RevenueCat Inc. All Rights Reserved.
//
//  Licensed under the MIT License (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//      https://opensource.org/licenses/MIT
//
//  TextComponentView.swift
//
//  Created by Josh Holtz on 6/11/24.

import Foundation
import RevenueCat
import SwiftUI

#if PAYWALL_COMPONENTS

@available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, *)
public class TextComponentViewModel: ObservableObject {

    let locale: Locale
    let localization: [String: String]
    @Published private(set) var component: PaywallComponent.TextComponent

    init(locale: Locale, localization: [String : String], component: PaywallComponent.TextComponent) {
        self.locale = locale
        self.localization = localization
        self.component = component
    }

    var text: String {
        // TODO: Replace variables like "{{ }}"
        // TODO: Add logs?
        if let textLid = component.textLid {
            if let localizedText = localization[textLid] {
                return localizedText
            }
            else {
                return component.text.value.first?.value as? String ?? "missing localized text for \(textLid)"
            }
        } else {
            return component.text.value.first?.value as? String ?? "missing localized text"
        }
    }

    public var fontFamily: String {
        component.fontFamily
    }

    public var fontWeight: Font.Weight {
        component.fontWeight.fontWeight
    }

    public var color: Color {
        // TODO: implement color transformation
        // component.color
        Color.cyan
    }

    public var textStyle: Font {
        component.textStyle.font
    }

    public var horizontalAlignment: TextAlignment {
        component.horizontalAlignment.textAlignment
    }

    public var backgroundColor: Color {
        // TODO: implement color transformation
        // component.color
        Color.mint
    }

    public var padding: EdgeInsets {
        component.padding.edgeInsets
    }
    
}
#endif