//
//  DialogView.swift
//  EdgeOCRSample
//
//  Created by kikemori on 2024/04/16.
//

import Foundation
import SwiftUI

struct DialogView: View {
    @Binding var showDialog: Bool
    @Binding var messages: [String]

    var body: some View {
        VStack {
            HStack {
                Image(systemName: "checkmark.circle.fill")
                    .resizable()
                    .frame(width: 30, height: 30)
                    .foregroundColor(.black)
                Text("検出")

            }.font(.title)
                .bold()
                .padding(.all, 10)
                .frame(width: 150, height: 50)
                .background(Color.green.opacity(0.8))
                .cornerRadius(15)
            Spacer().frame(height: 20)
            VStack(spacing: 10) {
                ForEach(messages, id: \.self) { message in
                    Text(message)
                }
            }
            Spacer().frame(height: 25)
            Button(action: {
                showDialog = false
            }, label: {
                Text("OK")
                    .font(.system(size: 25))
                    .bold()
                    .foregroundColor(.blue)
            })
        }
        .frame(width: 200)
        .padding(.all, 20)
        .background(Color(red: 232/255, green: 242/255, blue: 228/255).opacity(0.6))
        .cornerRadius(15)
    }
}

#Preview {
    DialogView(
        showDialog: .constant(true),
        messages: .constant(["9000021", "9000022", "9000023"]))
}
