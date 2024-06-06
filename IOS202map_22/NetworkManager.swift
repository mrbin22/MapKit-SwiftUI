//
//  NetworkManager.swift
//  IOS202map_22
//
//  Created by cmStudent on 2024/05/10.
//

import Foundation

@MainActor
class NetworkManager: ObservableObject {
    @Published var stations: StationModel?
    
    func getData(x: CGFloat, y: CGFloat) async {
        guard let url = URL(string: "https://express.heartrails.com/api/json?method=getStations&x=\(y)&y=\(x)") else { return }
        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            let jsonData = try JSONDecoder().decode(StationModel.self, from: data)
            self.stations = jsonData
        } catch {
            print(error.localizedDescription)
        }
        
    }
}
