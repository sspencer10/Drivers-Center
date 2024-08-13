import SwiftUI

struct MainView: View {
    @State private var tabSelection = 1
    @StateObject var templateManager = TemplateManager()
    var body: some View {

            ZStack(alignment: .bottom) {
                TabView(selection: $tabSelection) {
                    WeatherView()
                        .tabItem {
                            Label("Weather", systemImage: "sun.max.fill")
                        }
                        .tag(1)
                    SpeedometerView(carPlay: LocationManager())
                        .tabItem {
                            Label("Speed", systemImage: "gauge.with.dots.needle.33percent")
                        }
                        .tag(2)
                    MapsView(carPlay: TemplateManager())
                        .tabItem {
                            Label("Map", systemImage: "map.circle")
                        }
                        .tag(3)
                    
                    CompassView(carPlay: LocationManager())
                        .tabItem {
                            Label("Compass", systemImage: "binoculars.circle")
                        }
                        .tag(4)
                    ElevationView(carPlay: LocationManager())
                        .tabItem {
                            Label("Elevation", systemImage: "mountain.2.circle")
                        }
                        .tag(5)
                }
                .tabViewStyle(.page(indexDisplayMode: .never))
                
                TabButtons(selectedTab: $tabSelection, carPlay: LocationManager())
            }
        }
    
}


struct TabButtons: View {
    @Binding var selectedTab: Int
    @StateObject var carPlay: LocationManager
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
            .onLongPressGesture(perform: {
                showingPopover = true
            })
            
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
                Image(systemName: "mountain.2.circle")
                    .foregroundColor(selectedTab == 5 ? .red : .gray)
                    .scaleEffect(1.5)
                    .onTapGesture {
                        selectedTab = 5
                    }
                Text("\nElevation")
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

