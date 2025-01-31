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
    
    init(locationManager: LocationManager, tm: TemplateManager, weatherViewModel: WeatherViewModel, mediaItemViewModel: MediaItemViewModel, addressSearchViewModel: AddressSearchViewModel) {
        self.locationManager = locationManager
        self.tm = tm
        self.weatherViewModel = weatherViewModel
        self.mediaItemViewModel = mediaItemViewModel
        self.addressSearchViewModel = addressSearchViewModel
        //UITabBar.appearance().tintColor = UIColor(
            //red: 0.0,
            //green: 0.0,
           // blue: 1.0,
           // alpha: 1.0
       // )
        UITabBar.appearance().unselectedItemTintColor = UIColor.gray
        UITabBar.appearance().backgroundColor = UIColor.black
    }

    var body: some View {
        ZStack(alignment: .bottom) {
            //if !z {
              //  IsFirst(locationManager: locationManager, tm: tm, weatherViewModel: weatherViewModel, mediaItemViewModel: mediaItemViewModel)
             //       .preferredColorScheme(.dark)
           // } else {
                if !x {
                    TabView(selection: $tabSelection) {
                        MusicView(viewModel: mediaItemViewModel, carPlay: $x)
                            .tabItem {
                                Label("Music", systemImage: "play.circle")
                            }
                            .tag(1)
                            .preferredColorScheme(.dark)
                        
                        SpeedometerView(lm: LocationManager.shared, coveredRadius: 230, maxValue: 100, steperSplit: 10)
                            .tabItem {
                                Label("Speed", systemImage: "gauge.with.dots.needle.33percent")
                            }
                            .tag(2)
                            .preferredColorScheme(.dark)
                        
                        //MapsView(loc: locationManager, carPlay: mediaItemViewModel)
                        MapsView(locationManager: locationManager)
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
                        
                        NavView(viewModel: locationManager, addressSearchViewModel: addressSearchViewModel)
                            .tabItem {
                                Label("Navigation", systemImage: "binoculars.circle")
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
