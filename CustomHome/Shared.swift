//
//  Shared.swift
//  CustomHome
//
//  Created by Giuseppe Barillari on 09/10/2021.
//

import Foundation
import SwiftUI

let saveKey: String = "CustomHomeDevices"

let gradient: LinearGradient = LinearGradient(gradient: Gradient(colors: [.orange, .yellow]), startPoint: .leading, endPoint: .bottomTrailing)

struct GradientTextFieldStyle: TextFieldStyle {
    func _body(configuration: TextField<Self._Label>) -> some View {
        configuration
            .padding(10)
            .overlay(RoundedRectangle(cornerRadius: 10).stroke(gradient))
    }
}

struct GradientButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .padding()
            .background(gradient)
            .foregroundColor(.white)
            .cornerRadius(15)
    }
}

func retrieveDevicesList() -> [Device] {
    // Check if a list of saved devices exists
    if let savedDevices = UserDefaults.standard.data(forKey: saveKey) {
        // Decode list
        if let decoded = try? JSONDecoder().decode([Device].self, from: savedDevices) {
                return decoded
        }
    }
    
    // Create emtpy list
    let devices:[Device] = []
    return devices
}
