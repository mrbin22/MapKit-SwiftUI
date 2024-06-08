//
//  FilterMenuBarView.swift
//  IOS202map_22
//
//  Created by cmStudent on 2024/06/07.
//

import SwiftUI

struct FilterMenuBarView: View {
    @EnvironmentObject var manager: LocationManager
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 20) {
                ForEach(LocationManager.spots) { spot in
                    ZStack {
                        RoundedRectangle(cornerRadius: 10)
                            .fill(.white)
                            .overlay(
                                RoundedRectangle(cornerRadius: 10)
                                    .stroke(.black, lineWidth: 1)
                            )
                            .frame(width: /*@START_MENU_TOKEN@*/100/*@END_MENU_TOKEN@*/, height: 30)
                        
                        
                        Text(spot.title)
                    }
                    .onTapGesture {
                        Task {
                            await manager.searchPlaces(keyword: spot.title)
                        }
                    }
                }
            }
        }
    }
}

#Preview {
    FilterMenuBarView()
        .environmentObject(LocationManager())
}
