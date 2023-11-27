//
//  SharedusdzModelLoader.swift
//  Heigl_ARKIT_FINAL
//
//  Created by Alex Heigl on 11/26/23.
//

import Foundation

//class SharedModelData: ObservableObject {
//	@Published var models: [Model] = []
//
//	init() {
//		self.models = SharedModelData.loadUSDZModels()
//	}
//
//	// Function to load USDZ models
//	private static func loadUSDZModels() -> [Model] {
//		let filemanager = FileManager.default
//		guard let path = Bundle.main.resourcePath, let files = try? filemanager.contentsOfDirectory(atPath: path) else {
//			return []
//		}
//
//		return files.compactMap { filename in
//			filename.hasSuffix("usdz") ? Model(modelName: filename.replacingOccurrences(of: ".usdz", with: "")) : nil
//		}
//	}
//	
//	func loadModels() {
//		models.forEach { $0.loadModel() }
//	}
//}
