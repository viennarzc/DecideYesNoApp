//
//  StatCard.swift
//  PickYesOrNo
//
//  Created by Viennarz Curtiz on 10/29/24.
//
import SwiftUI

struct StatCard: View {
    let title: String
    let value: String
    let systemName: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack{
                Image(systemName: systemName)
                    .font(.body)
                    .foregroundStyle(.tertiary)
                
                Text(title)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Text(value)
                .font(.title2)
                .fontWeight(.bold)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
}

#Preview {
    StatCard(title: "Title", value: "232", systemName: "car")
}
