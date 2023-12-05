//
//  SettingsRowView.swift
//  Heigl_ARKIT_FINAL
//
//  Created by Alex Heigl on 11/25/23.
//
//  Re-usable Code block for an image / title
//  Generated using tutorial from: https://www.youtube.com/watch?v=QJHmhLGv-_0&t=161s

import SwiftUI

struct SettingsRowView: View {
	let imageName: String
	let title: String
	let tintColor: Color
	
    var body: some View {
		HStack(spacing: 12) {
			Image(systemName: imageName)
				.imageScale(.small)
				.font(.title)
				.foregroundColor(tintColor)
			
			Text(title)
				.font(.subheadline)
				.foregroundColor(.black)
		}
    }
}

//#Preview {
//    SettingsRowView()
//}
