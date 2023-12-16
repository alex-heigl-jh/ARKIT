//
//  AREnums.swift
//  Augment
//
//  Created by Alex Heigl on 12/10/23.
//

import Foundation

enum FocusStyleChoices: CustomStringConvertible {
	case classic
	case material
	case color

	var description: String {
		switch self {
		case .classic:
			return "Classic"
		case .material:
			return "Material"
		case .color:
			return "Color"
		}
	}
}


enum EntityType: CustomStringConvertible {
	case model
	case box
	case sphere
	case plane

	var description: String {
		switch self {
		case .model:
			return "Model"
		case .box:
			return "Box"
		case .sphere:
			return "Sphere"
		case .plane:
			return "Plane"
		}
	}
}


enum MeshType: CustomStringConvertible {
	case box
	case sphere
	case plane

	var description: String {
		switch self {
		case .box:
			return "Box"
		case .sphere:
			return "Sphere"
		case .plane:
			return "Plane"
		}
	}
}

