//
//  ListStationView.swift
//  IOS202map_22
//
//  Created by cmStudent on 2024/05/10.
//

import SwiftUI
import MapKit
struct ListStationView: View {
    var nearestStation: [Station]
    @EnvironmentObject var vm: LocationManager
    @Binding var isShowAlert: Bool
    
    
    var body: some View {
        List {
            ForEach(nearestStation, id: \.self) { station in
                Button(action: {
                    
                    if vm.transport == .transit {
                        vm.isShowSheet = false
                        // TODO: Alertで電車の時間を表示する
                        Task {
                            await vm.calculateRoute(from: vm.region.center ,to: CLLocationCoordinate2D(latitude: station.y, longitude: station.x), transportType: vm.transport)
                            isShowAlert.toggle()
                        }
                        
                        print("時間を表示")
                    } else {
                        Task {
                            await vm.calculateRoute(from: vm.region.center ,to: CLLocationCoordinate2D(latitude: station.y, longitude: station.x), transportType: vm.transport)
                        }
                        vm.isShowSheet = false
                    }
                }, label: {
                   selectStation(station: station)
                })
                
            }
        }
        .listStyle(.insetGrouped)
    }
}

#Preview {
    ListStationView(nearestStation: LocationManager.dev, isShowAlert: .constant(false))
        .environmentObject(LocationManager())
}

extension ListStationView {
    func selectStation(station: Station) -> some View {
        VStack {
            HStack {
                Text("\(station.name)")
                    .foregroundStyle(.red)
                    .font(.title)
                    .bold()
                Text("(\(station.distance))")
                    .font(.caption)
                    .italic()
                    .offset(y: 5)
            }
            .padding(.leading, 50)
            HStack(spacing: nil) {
                
                Text(station.next)
                    .foregroundStyle(.black)
                    .font(.headline)
                    .frame(minWidth: 0, maxWidth: .infinity, alignment: .leading)
                Spacer()
                Image(systemName: "arrowshape.left.arrowshape.right.fill")
                    .foregroundColor(.black)
                    .frame(width: 30)
                Spacer()
                Text(station.prev ?? "終点")
                    .foregroundStyle(.black)
                    .font(.headline)
                    .frame(minWidth: 0, maxWidth: .infinity, alignment: .trailing)
            }
        }
    }
}
