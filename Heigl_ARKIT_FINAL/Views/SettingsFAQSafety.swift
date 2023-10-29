//
//  SettingsFAQSafety.swift
//  Heigl_ARKIT_FINAL
//
//  Created by Alex Heigl on 10/23/23.
//

import SwiftUI

struct SettingsPreferencesSafetyView: View {
    @State private var dummyText: String = "Dummy Text"
    @State private var selectedSection: Int = 0
    
    private let sections = ["Settings", "FAQ", "Safety"]

    var body: some View {
        VStack(spacing: 20) {
            Picker(selection: $selectedSection, label: Text("Choose a section")) {
                ForEach(sections.indices, id: \.self) { index in
                    Text(sections[index]).tag(index)
                }
            }
            .pickerStyle(SegmentedPickerStyle())
            .padding(.horizontal)

            ScrollView { // Added ScrollView
                VStack(spacing: 20) {
                    Text("Settings, FAQ, & Safety View")
                        .font(.headline)

                    Divider()

                    switch selectedSection {
                    case 0:
                        SettingsView()
                    case 1:
                        FAQView()
                    case 2:
                        SafetyView()
                    default:
                        EmptyView()
                    }
                }
            }
        }
        .padding()
    }
}

// Settings Content View
struct SettingsView: View {
    var body: some View {
        VStack {
            Text("Settings Content")
            // Add more UI components specific to settings here
        }
    }
}

// FAQ Content View
struct FAQView: View {
    var body: some View {
        VStack {
            Text("FAQ Content")
            // Add more UI components specific to FAQ here
        }
    }
}

// Safety Content View
struct SafetyView: View {
    var body: some View {
        VStack {
            Text("Safety Content")
            // Add more UI components specific to safety here
        }
    }
}

struct SettingsPreferencesSafetyView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsPreferencesSafetyView()
    }
}
