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
    @State private var ValidIP = false
    @State private var showAlert = false
    @State private var tutorial = false
    @State private var device: Device = Device()
    
    var body: some View {
        NavigationView {
            VStack {
                Form {
                    Section(header: Text("Parameters")) {
                        TextField("Device name, e.g. Lamp", text: $DeviceName).padding()
                        TextField("Device IP Address (no http://)", text: $IPAddress) { _ in
                        } onCommit: {
                            obtainDeviceInfo()
                        }
                        .padding()
                        .disableAutocorrection(true)
                    }
                }
            }.alert(isPresented: $showAlert) {
                Alert(title: Text("Something went wrong"), message: Text("Please make sure the IP address is correct"), dismissButton: .cancel())
            }
            .navigationTitle("Add a new device")
            .toolbar(content: {
                Button("Add", action: addDevice).disabled(ValidIP == false).frame(alignment: .bottom)
            })
        }.alert(isPresented: $tutorial) {
            Alert(title: Text("New device setup"), message: Text("Please fill in the parameters below. You can leave the \"Device name\" field empty, every device comes with a default name. You must insert your device IP address. If a device is found at the IP you enter (press enter when you are done writing), you will be able to click the \"Add\" button"), dismissButton: .default(Text("Got it")))
        }
        .onAppear(perform: {
            tutorial = true
        })
    }
    func obtainDeviceInfo() {
        let fullIP = "http://" + IPAddress
        guard let url = URL(string: fullIP) else {
            fatalError()
        }
        var request = URLRequest(url: url)
        
        request.httpMethod = "POST"
        
        URLSession.shared.dataTask(with: request) { data, response, emrror in
            guard let data = data else {
                showAlert = true
                print("Empty response")
                return
            }
            
            do {
                try device = JSONDecoder().decode(Device.self, from: data)
                // Enable Add button
                ValidIP = true
                
                // Use user's custom device name if any
                if DeviceName != "" {
                    device.name = DeviceName
                }
            } catch {
                // Bad data/IP/Internet connection
                showAlert = true
            }
        }.resume()
    }
    
    func addDevice() {
        // Check if a list of saved devices exists
        if let savedDevices = UserDefaults.standard.data(forKey: saveKey) {
            // Decode list
            if let decoded = try? JSONDecoder().decode([Device].self, from: savedDevices) {
                var devices = decoded
                // Add new device to list
                devices.append(device)
                print(devices)
                // Encode list and save
                if let encoded = try? JSONEncoder().encode(devices) {
                    UserDefaults.standard.set(encoded, forKey: saveKey)
                }
            }
        } else {
            // Create new list and add new device
            var devices = [Device]()
            devices.append(device)
            print(devices)
            // Encode new list and save
            if let encoded = try? JSONEncoder().encode(devices) {
                UserDefaults.standard.set(encoded, forKey: saveKey)
            }
        }
    }
}

struct NewDeviceView_Previews: PreviewProvider {
    static var previews: some View {
        NewDeviceView()
    }
}
