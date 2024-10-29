//
//  DecisionRow.swift
//  PickYesOrNo
//
//  Created by Viennarz Curtiz on 10/29/24.
//
import SwiftUI

struct DecisionRow: View {
    let decision: DecisionModel
    
    var body: some View {
        HStack {
            Circle()
                .fill(color())
                .frame(width: 12, height: 12)
            
            VStack(alignment: .leading, spacing: 4) {
                if let date = decision.createdAt {
                    Text(date.formatted())
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                }
        
            }
            
            Spacer()
            
            Text(decisionAnswer)
                .font(.callout)
                .fontWeight(.medium)
                .foregroundColor(color())
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
    
    func color() -> Color {
        guard let answer = decision.answer else { return Color.orange }
        
        return answer ? Color.green : Color.red
    }
    
    var decisionAnswer: String {
        guard let answer = decision.answer else { return "Undecided" }
        
        return answer ? "Yes" : "No"
    }
}


