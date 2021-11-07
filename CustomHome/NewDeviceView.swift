//
//  NewDeviceView.swift
//  CustomHome
//
//  Created by Giuseppe Barillari on 07/10/2021.
//

import SwiftUI

struct NewDeviceView: View {
    @State private var IPAddress: String = ""
    @State private var DeviceName: String = ""
    @State private var DeviceType: Int = 0
    @State private var showAlert = false
    @State private var tutorial = false
    @State private var successAdd = false
    @State private var device: Device = Device()
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        NavigationView {
            VStack(alignment: .center, spacing: 20) {
                TextField("Device name, e.g. Lamp", text: $DeviceName)
                    .padding(.horizontal)
                TextField("Device IP Address (no http://)", text: $IPAddress)
                    .padding(.horizontal)
                Button("Add") {
                    obtainDeviceInfo()
                }
            }
            .textFieldStyle(GradientTextFieldStyle())
            .buttonStyle(GradientButtonStyle())
            .alert(isPresented: $showAlert) {
                Alert(title: Text("Something went wrong"), message: Text("Please make sure the IP address is correct"), dismissButton: .cancel())
            }
            .navigationTitle("Add a new device")
        }.alert(isPresented: $tutorial) {
            Alert(title: Text("New device setup"), message: Text("Please fill in the parameters below. You can leave the \"Device name\" field empty, every device comes with a default name. You must insert your device IP address."), dismissButton: .default(Text("Got it")))
        }
        .alert(isPresented: $successAdd) {
            Alert(title: Text("Device added successfully"), message: Text("You can now interact with the device from your devices list"), dismissButton: .default(Text("Got it"), action: {
                presentationMode.wrappedValue.dismiss()
            }))
        }
        .onAppear(perform: {
            tutorial = true
        })
    }
    func obtainDeviceInfo() {
        let fullIP = /*"http://" +*/ IPAddress
        guard let url = URL(string: fullIP) else {
            fatalError()
        }
        var request = URLRequest(url: url)
        
        request.httpMethod = "POST"
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data else {
                showAlert = true
                print("Empty response")
                return
            }
            
            do {
                try device = JSONDecoder().decode(Device.self, from: data)
                if (device.type != -1) {
                    // Use user's custom device name if any
                    if DeviceName != "" {
                        device.name = DeviceName
                    }
                    addDevice()
                } else {
                    showAlert = true
                }
            } catch {
                // Bad data/IP/Internet connection
                showAlert = true
            }
        }.resume()
    }
    
    func addDevice() {
        var devices = retrieveDevicesList()
        devices.append(device)
        // Encode new list and save
        if let encoded = try? JSONEncoder().encode(devices) {
            UserDefaults.standard.set(encoded, forKey: saveKey)
            
            successAdd = true
        }
    }
}

struct NewDeviceView_Previews: PreviewProvider {
    static var previews: some View {
        NewDeviceView()
    }
}
