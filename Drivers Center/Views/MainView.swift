import SwiftUI

struct MainView: View {
    @State private var tabSelection = 1
    @State var carplay: Bool = false
    @ObservedObject var locationManager: LocationManager
    @ObservedObject var tm: TemplateManager
    @ObservedObject var weatherViewModel: WeatherViewModel
    @ObservedObject var mediaItemViewModel: MediaItemViewModel
    @ObservedObject var addressSearchViewModel: AddressSearchViewModel
    @State var x: Bool = false
    @State var z: Bool = false
    @State var showNavView: Bool = false
    
    

    
    init(locationManager: LocationManager, tm: TemplateManager, weatherViewModel: WeatherViewModel, mediaItemViewModel: MediaItemViewModel, addressSearchViewModel: AddressSearchViewModel) {
        self.locationManager = locationManager
        self.tm = tm
        self.weatherViewModel = weatherViewModel
        self.mediaItemViewModel = mediaItemViewModel
        self.addressSearchViewModel = addressSearchViewModel

        UITabBar.appearance().unselectedItemTintColor = UIColor.gray
        UITabBar.appearance().backgroundColor = UIColor.black
    }

    var body: some View {

        ZStack(alignment: .bottom) {
            if locationManager.showNavView {
               // CustomSheetView(lm: locationManager)
                CustomSheetView()
                        .transition(.move(edge: .bottom))
                        .animation(.spring(), value: showNavView)
                        .presentationDetents([.height(200), .large]) // Adjusts height to show 25% initially
                        .presentationDragIndicator(.visible)
                        .zIndex(9)
                
            }
                if !x {
                    TabView(selection: $tabSelection) {
                        MusicView(viewModel: mediaItemViewModel, carPlay: $x)
                            .tabItem {
                                Label("Music", systemImage: "play.circle")
                            }
                            .tag(1)
                            .preferredColorScheme(.dark)
                        
                
                        //MapsView(loc: locationManager, carPlay: mediaItemViewModel)
                        MapsView(locationManager: locationManager, addressSearchViewModel: addressSearchViewModel, addressTitle: $addressSearchViewModel.addressTitle)
                            .tabItem {
                                Label {
                                    Text("Map")
                                } icon: {
                                    Image(systemName: "map.circle")
                                        .resizable()
                                        .renderingMode(.template)
                                    //.backgroundColor(UIColor.red)
                                }
                            }
                            .tag(3)
                            .preferredColorScheme(.dark)
                        
                        CompassView()
                            .tabItem {
                                Label("Gauges", systemImage: "gauge")
                            }
                            .tag(4)
                            .preferredColorScheme(.dark)
                        
                        WeatherView(viewModel: weatherViewModel, lm: locationManager, tm: tm)
                            .tabItem {
                                Label("Weather", systemImage: "sun.max.fill")
                            }
                            .tag(5)
                            .preferredColorScheme(.dark)
                    }
                    .zIndex(10)
                } else {
                    IsCarPlayView(locationManager: locationManager, tm: tm, weatherViewModel: weatherViewModel, mediaItemViewModel: mediaItemViewModel)
                        .preferredColorScheme(.dark)
 
                        
                }
            //}
        }
        .onAppear {
            setupTabBarAppearance()
            x = mediaItemViewModel.isCarPlay
            z = UserDefaults.standard.bool(forKey: "firstLaunch")
        }
        .onChange(of: mediaItemViewModel.isCarPlay) {
            x = mediaItemViewModel.isCarPlay
        }
        .onChange(of: locationManager.showNavView) {
            showNavView = locationManager.showNavView
            print("show NavView \(showNavView)")
        }
    }

    private func setupTabBarAppearance() {
        let appearance = UITabBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = UIColor.black // Background color of the tab bar
        appearance.shadowColor = UIColor.clear // Remove the horizontal line
        //appearance.stackedLayoutAppearance.selected.iconColor = UIColor(
         //   red: 0.0,
         //   green: 0.0,
        //    blue: 1.0,
        //    alpha: 1.0
        //) // Selected icon color
        //appearance.stackedLayoutAppearance.selected.titleTextAttributes = [.foregroundColor: UIColor(
          //  red: 0.0,
          //  green: 0.0,
           // blue: 1.0,
            //alpha: 1.0
        //)] // Selected text color
        appearance.stackedLayoutAppearance.normal.iconColor = UIColor.gray // Unselected icon color
        appearance.stackedLayoutAppearance.normal.titleTextAttributes = [.foregroundColor: UIColor.gray] // Unselected text color

        UITabBar.appearance().standardAppearance = appearance
        UITabBar.appearance().scrollEdgeAppearance = appearance // For iOS 15 and later
    }
}

struct CustomSheetView: View {
    var body: some View {
        // Customize your “sheet” appearance here.
        Rectangle()
            .fill(Color.blue.opacity(0.3))
            .frame(height: 300)
            .cornerRadius(20)
            .padding()
    }
}

struct CustomSheetView2: View {
    @ObservedObject var lm: LocationManager
    var body: some View {
        VStack {
            Capsule()
                .frame(width: 40, height: 5)
                .foregroundColor(.gray)
                .padding(.top, 8)
            
            Text("Custom Sheet")
                .font(.title)
                .padding()
            
            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(.systemBackground))
        .cornerRadius(16)
        .shadow(radius: 10)
        .offset(y: 40) // Adjust this to sit on top of the TabView
        .gesture(
            DragGesture()
                .onEnded { value in
                    if value.translation.height > 100 {
                        withAnimation {
                            lm.showNavView = false
                        }
                    }
                }
        )
    }
}
