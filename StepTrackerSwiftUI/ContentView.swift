//
//  ContentView.swift
//  StepTrackerSwiftUI
//
//  Created by Rangga Biner on 08/06/24.
//

import SwiftUI

struct ContentView: View {
    @StateObject private var healthStoreManager = HealthStoreManager()
    
    var body: some View {
        VStack(spacing: 20) {
            // Header
            VStack(spacing: 10) {
                Text("StepTracker")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .padding(.top, 40)
                
                Text("by Rangga Biner")
                    .font(.subheadline)
                    .foregroundColor(.gray)
                
                Text(currentDateString())
                    .font(.title2)
                    .foregroundColor(.blue)
            }
            
            Divider()
            
            Spacer()
            
            // Step Count and Distance
            VStack(spacing: 40) {
                // Step Count
                VStack(spacing: 10) {
                    HStack {
                        Spacer()
                        Image(systemName: "figure.walk")
                            .resizable()
                            .frame(width: 50, height: 50)
                            .foregroundColor(.orange)
                        
                        VStack(alignment: .leading, spacing: 5) {
                            Text("Steps Today")
                                .font(.title2)
                                .fontWeight(.semibold)
                            
                            Text("\(healthStoreManager.stepCount)")
                                .font(.system(size: 50))
                                .fontWeight(.bold)
                                .foregroundColor(.orange)
                        }
                        Spacer()
                    }
                }
                
                // Distance
                VStack(spacing: 10) {
                    HStack {
                        Spacer()
                        Image(systemName: "location")
                            .resizable()
                            .frame(width: 50, height: 50)
                            .foregroundColor(.blue)
                        
                        VStack(alignment: .leading, spacing: 5) {
                            Text("Distance Today")
                                .font(.title2)
                                .fontWeight(.semibold)
                            
                            Text(String(format: "%.2f km", healthStoreManager.distance / 1000))
                                .font(.system(size: 50))
                                .fontWeight(.bold)
                                .foregroundColor(.blue)
                        }
                        Spacer()
                    }
                }
            }
            
            Spacer()
        }
        .onAppear {
            healthStoreManager.fetchStepCount()
            healthStoreManager.fetchDistance()
        }
        .padding()
        .background(Color(UIColor.systemBackground))
        .edgesIgnoringSafeArea(.all)
    }
    
    private func currentDateString() -> String {
        let currentDate = Date()
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .full
        dateFormatter.timeStyle = .none
        return dateFormatter.string(from: currentDate)
    }
}

#Preview {
    ContentView()
}
