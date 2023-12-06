//
//  ARManager.swift
//  Heigl_ARKIT_FINAL
//
//  Created by Alex Heigl on 10/31/23.
//
//  Code initially based off of tutorial from: https://www.youtube.com/watch?v=KbqbU-cCKf4

/* 
//: Declaring as a singleton pattern so that only one instance of this class will be allowed

//: Purpose of ARManager is to forward all of the actions from a swift UI view to our custom
//: ARView. There isn't a direct way to do this, thus why this file/class was created

 //: Combine allows you to send data from one part of your application to another
 //: @published utilizes combine
 
 //: Publisher publishes value, subscriber receives the published data
 
 */

import Combine

class ARManager{
	static let shared = ARManager()
	// Only ARManager can call the initializer
	private init() { }
	
	// PassthroughSubject: A subject that broadcasts elements to downstream subscribers.
	var actionStream = PassthroughSubject<ARAction, Never>()
	
}
