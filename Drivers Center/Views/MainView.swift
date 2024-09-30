import SwiftUI

struct MainView: View {
    @State private var tabSelection = 1
    @State var carplay: Bool = false
    @StateObject var locationManager = LocationManager.shared
    @StateObject var tm = TemplateManager()
    var body: some View {
        
        ZStack(alignment: .bottom) {
            if !carplay {
                TabView(selection: $tabSelection) {
                    WeatherView()
                        .tabItem {
                            Label("Weather", systemImage: "sun.max.fill")
                        }
                        .tag(1)
                    RetroSpeedometerView(lm: LocationManager.shared)
                        .tabItem {
                            Label("Speed", systemImage: "gauge.with.dots.needle.33percent")
                        }
                        .tag(2)
                    MapsView(carPlay: TemplateManager())
                        .tabItem {
                            Label("Map", systemImage: "map.circle")
                        }
                        .tag(3)
                    
                    CompassView(carPlay: LocationManager.shared)
                        .tabItem {
                            Label("Compass", systemImage: "binoculars.circle")
                        }
                        .tag(4)
                    MusicView(viewModel: MediaItemViewModel())
                        .tabItem {
                            Label("Music", systemImage: "play.circle")
                        }
                        .tag(5)
                }
                .tabViewStyle(.page(indexDisplayMode: .never))
                
                TabButtons(selectedTab: $tabSelection, carPlay: LocationManager.shared)
            } else {
                Text("CarPlay Active")
            }

        }.onAppear {
            //UserDefaults.standard.setValue(false, forKey: "isCarPlay")
        }
        .onChange(of: tm.isCarPlay) {
            if tm.isCarPlay {
                carplay = true
            } else {
                carplay = false
            }
        }
    }
    
}


struct TabButtons: View {
    @Binding var selectedTab: Int
    @StateObject var carPlay: LocationManager
    @StateObject var tm = TemplateManager()

    @State var showingPopover = false
    
    var body: some View {
        HStack {
            Spacer()
            VStack() {
                Image(systemName: "sun.max.circle")
                    .foregroundColor(selectedTab == 1 ? .red : .gray)
                    .scaleEffect(1.5)
                    .onTapGesture {
                        selectedTab = 1
                    }
                Text("\nWeather")
                    .font(.caption)
                    .foregroundColor(selectedTab == 1 ? .red : .gray)
                    .onTapGesture {
                        selectedTab = 1
                    }
            }
            
            Spacer()
            VStack() {
                Image(systemName: "gauge.with.dots.needle.33percent")
                    .foregroundColor(selectedTab == 2 ? .red : .gray)
                    .scaleEffect(1.5)
                    .onTapGesture {
                        selectedTab = 2
                    }
                Text("\n Speed ")
                    .font(.caption)
                    .foregroundColor(selectedTab == 2 ? .red : .gray)
                    .onTapGesture {
                        selectedTab = 2
                    }
            }
            
            Spacer()
            VStack() {
                Image(systemName: "map.circle")
                    .foregroundColor(selectedTab == 3 ? .red : .gray)
                    .scaleEffect(1.5)
                    .onTapGesture {
                        selectedTab = 3
                    }
                Text("\nLocation")
                    .font(.caption)
                    .foregroundColor(selectedTab == 3 ? .red : .gray)
                    .onTapGesture {
                        selectedTab = 3
                    }
                
                    
            }

            
            Spacer()
            VStack() {
                Image(systemName: "binoculars.circle")
                    .foregroundColor(selectedTab == 4 ? .red : .gray)
                    .scaleEffect(1.5)
                    .onTapGesture {
                        selectedTab = 4
                    }
                Text("\nCompass")
                    .font(.caption)
                    .foregroundColor(selectedTab == 4 ? .red : .gray)
                    .onTapGesture {
                        selectedTab = 4
                    }
            }
            
            Spacer()
            VStack() {
                Image(systemName: "play.circle")
                    .foregroundColor(selectedTab == 5 ? .red : .gray)
                    .scaleEffect(1.5)
                    .onTapGesture {
                        selectedTab = 5
                    }
                Text("\nMusic")
                    .font(.caption)
                    .foregroundColor(selectedTab == 5 ? .red : .gray)
                    .onTapGesture {
                        selectedTab = 5
                    }
            }
            
            Spacer()
        }
        .padding(.top)
        .padding(.bottom)
        
        .sheet(isPresented: $showingPopover) {
            Text("Map Options").frame(width: 400, alignment: .leading).multilineTextAlignment(.leading)
                .bold()
                .font(.title)
                .padding(.leading, 40)
                .padding(.bottom, 20)
            
            
            HStack {
                Button("Send Location") {
                    let msgBody = "https://maps.google.com/?%26daddr=\(carPlay.latitude),\(carPlay.longitude)%26directionsmode=driving"
                    
                    UIApplication.shared.open(URL(string: "imessage://?&body=\(msgBody)")!)
                }
                .buttonStyle(.borderedProminent)
                .frame(maxWidth: .infinity)
                .padding(.bottom, 15)
                .tint(.red)
                Button("Google Maps") {
                    UIApplication.shared.open(URL(string: "comgooglemaps://")!)
                }
                .buttonStyle(.borderedProminent)
                .tint(.red)
                .frame(maxWidth: 400 )
                .padding(.bottom, 15)
                .presentationDetents([.medium, .large])
            }
        }
    }
}

