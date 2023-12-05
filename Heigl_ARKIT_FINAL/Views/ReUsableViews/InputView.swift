//
//  InputView.swift
//  Heigl_ARKIT_FINAL
//
//  Created by Alex Heigl on 11/25/23.
//  Reusable input field with title 
//  Creating using tutorial from: https://www.youtube.com/watch?v=QJHmhLGv-_0&t=161s

import Foundation
import SwiftUI

struct InputView: View {
	
	@Binding var text: String
	let title: String
	let placeholder: String
	var isSecureField = false
	
	
	var body: some View {
		VStack(alignment: .leading, spacing: 12) {
			Text(title)
				.foregroundColor(Color(.darkGray))
				.fontWeight(.semibold)
				.font(.footnote)
			
			if isSecureField {
				SecureField(placeholder, text: $text)
					.font(.system(size: 14))
			} else {
				TextField(placeholder, text: $text)
					.font(.system(size: 14))
			}
			
			Divider()
			
		}
	}
}
