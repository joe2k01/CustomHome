//
//  ContentView.swift
//  CustomHome
//
//  Created by Giuseppe Barillari on 04/10/2021.
//

import SwiftUI

//private var devices: [Device] = retrieveDevicesList()

class DevicesViewModel: ObservableObject {
    @Published var devices = retrieveDevicesList()
    
    func reload() {
        devices = retrieveDevicesList()
        print(devices)
    }
}

struct ContentView: View {
    @ObservedObject var devicesViewModel = DevicesViewModel()
    @State private var addingDevice = false
    
    var body: some View {
        VStack {
            if(devicesViewModel.devices.count > 0) {
                List{
                    ForEach(devicesViewModel.devices) { device in
                        Text(device.name)
                    }
                }.onAppear {
                    devicesViewModel.reload()
                    print(devicesViewModel.devices)
                }
            }
            Button("Add new device") {
                addingDevice.toggle()
            }.sheet(isPresented: $addingDevice) {
                NewDeviceView().onDisappear {
                    devicesViewModel.reload()
                }
            }
        }.buttonStyle(GradientButtonStyle())
        .frame(alignment: .bottom)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
