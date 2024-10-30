//
//  LoadingButton.swift
//  PickYesOrNo
//
//  Created by Viennarz Curtiz on 10/30/24.
//
import SwiftUI

struct LoadingButton: View {
    let title: String
    let isLoading: Bool
    let action: () async -> Void
    
    var body: some View {
        Button {
            Task {
                await action()
            }
        } label: {
            if isLoading {
                ProgressView()
                    .tint(.white)
            } else {
                Text(title)
            }
        }
        .disabled(isLoading)
    }
}
