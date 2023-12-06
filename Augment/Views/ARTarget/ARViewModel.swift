//
//  ARViewModel.swift
//  Heigl_ARKIT_FINAL
//
//  Created by Alex Heigl on 11/24/23.
//

import Foundation
import Photos
import UIKit

//class ARViewModel: ObservableObject {
//	weak var customARView: CustomARView?
//	var onSaveImageRequested: ((UIImage) -> Void)?
//	
//	// Inside your ViewModel or wherever the image capture is triggered
//	func captureAndSaveImage() {
//		customARView?.captureCurrentFrame { [weak self] capturedImage in
//			DispatchQueue.main.async {
//				guard let self = self, let image = capturedImage else {
//					print("DEBUG: Failed to capture AR frame")
//					return
//				}
//				self.onSaveImageRequested?(image)
//			}
//		}
//	}
//}
