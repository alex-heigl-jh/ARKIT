//
//  LoadingView.swift
//  Heigl_ARKIT_FINAL
//
//  Created by Alex Heigl on 10/23/23.
//

import SwiftUI

struct LoadingView: View {

  let dataModel: InitialDataIngestor
  @Binding private var networkDataLoaded: Bool

  init(dataModel: InitialDataIngestor = InitialDataIngestor(), networkDataLoaded: Binding<Bool>) {
    self.dataModel = dataModel
    _networkDataLoaded = networkDataLoaded
  }

  var body: some View {
  Image("applicationLogo") // Replace with your image name
	  .resizable()
	  .aspectRatio(contentMode: .fit)
	  .foregroundColor(.blue) // This might not be needed if your image already has colors
	  .padding(30)
    Text("Loading Data from Network...")
      .task {
//        await dataModel.loadAllData(from: .Web, isLoaded: _networkDataLoaded) // Load Data from JSON files on server
//          await dataModel.loadAllData(from: .LocalJSON, isLoaded: _networkDataLoaded) // Load Data from local JSON files
        await dataModel.loadAllData(from: .Local, isLoaded: _networkDataLoaded) // Load data from hardcoded data in InitialDataIngestor
      }
  }
}

struct LoadingView_Previews: PreviewProvider {
    static var previews: some View {
      LoadingView(networkDataLoaded: .constant(false))
    }
}

