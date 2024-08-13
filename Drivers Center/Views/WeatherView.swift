import SwiftUI

struct WeatherView: View {
    
    @ObservedObject private var viewModel = WeatherViewModel()
    @StateObject private var templateManager = LocationManager()
    @State private var city: String = ""
    @State private var q: String = ""
    @State private var x: String = ""
    @State private var y: String = ""
    @FocusState private var focused: Bool // 1. create a @FocusState here
    @State var searchText = ""
    @State var showFirstView = true

    @State var showSecondView = false

    
    var body: some View {
        ZStack {

            
            ScrollView {
                if viewModel.showFirstView {
                    ProgressView()
                    Text("Getting location...")
                } else {
                    if let weather = viewModel.weather {
                        PullToRefresh(coordinateSpaceName: "pullToRefresh") {
                            print("refresh")
                            viewModel.showFirstView = true
                            viewModel.showSecondView = false
                            let location = viewModel.getLoc()
                            Task {
                                await viewModel.fetchWeather()
                                if (location != "42.1673839, -92.0156213") {
                                    viewModel.showFirstView = false
                                    viewModel.showSecondView = true
                                }
                            }
                            viewModel.onMySubmit()
                        }
                        
                        VStack {
                            
                            Text(weather.location.name)
                                .font(.largeTitle)
                                .padding(.bottom, 1)
                            Text("\(weather.current.temp_f, specifier: "%.1f")°F")
                                .font(.system(size: 70))
                            Text("(Feels Like \(weather.current.feelslike_f, specifier: "%.1f")°F)")
                                .font(.system(size: 20))
                            //.padding(.top, 0)
                                .padding(.bottom, 10)
                            Text("\(weather.forecast.forecastday.first?.day.mintemp_f ?? 0.0, specifier: "%.0f")°/\(weather.forecast.forecastday.first?.day.maxtemp_f ?? 0.0, specifier: "%.0f")°")
                                .font(.system(size: 35))
                            //.padding(.top, 1)
                            if let url = URL(string: "https:\(weather.current.condition.icon)") {
                                AsyncImage(url: url) { image in
                                    image
                                        .resizable()
                                        .aspectRatio(contentMode: .fill)
                                        .frame(width: 125, height: 100)
                                } placeholder: {
                                    //ProgressView()
                                }
                                
                            } else {
                                Text(weather.current.condition.text)
                                    .font(.system(size: 20))
                            }
                        }
                        .padding(.top, 65)
                        VStack {
                            HStack {
                                if viewModel.count >= 5 {
                                    
                                    Spacer()
                                    VStack {
                                        Text("\(weather.forecast.forecastday[0].date.toMMDDFormat())")
                                            .font(.system(size: 15))
                                        if let url = URL(string: "https:\(weather.forecast.forecastday[0].day.condition.icon)") {
                                            AsyncImage(url: url) { image in
                                                image
                                                    .resizable()
                                                    .aspectRatio(contentMode: .fit)
                                                    .frame(width: 40, height: 40)
                                            } placeholder: {
                                                ProgressView()
                                            }
                                        } else {
                                            Text(weather.current.condition.text)
                                                .font(.title2)
                                        }
                                        Text("\(weather.forecast.forecastday[0].day.mintemp_f, specifier: "%.0f")/\(weather.forecast.forecastday[0].day.maxtemp_f, specifier: "%.0f")")
                                            .font(.system(size: 15))
                                        
                                    }
                                    Spacer()
                                    VStack {
                                        Text("\(weather.forecast.forecastday[1].date.toMMDDFormat())")
                                            .font(.system(size: 15))
                                        if let url = URL(string: "https:\(weather.forecast.forecastday[1].day.condition.icon)") {
                                            AsyncImage(url: url) { image in
                                                image
                                                    .resizable()
                                                    .aspectRatio(contentMode: .fit)
                                                    .frame(width: 40, height: 40)
                                            } placeholder: {
                                                ProgressView()
                                            }
                                        } else {
                                            Text(weather.current.condition.text)
                                                .font(.title2)
                                        }
                                        Text("\(weather.forecast.forecastday[1].day.mintemp_f, specifier: "%.0f")/\(weather.forecast.forecastday[1].day.maxtemp_f, specifier: "%.0f")")
                                            .font(.system(size: 15))
                                        
                                    }
                                    Spacer()
                                    VStack {
                                        Text("\(weather.forecast.forecastday[2].date.toMMDDFormat())")
                                            .font(.system(size: 15))
                                        if let url = URL(string: "https:\(weather.forecast.forecastday[2].day.condition.icon)") {
                                            AsyncImage(url: url) { image in
                                                image
                                                    .resizable()
                                                    .aspectRatio(contentMode: .fit)
                                                    .frame(width: 40, height: 40)
                                            } placeholder: {
                                                ProgressView()
                                            }
                                        } else {
                                            Text(weather.current.condition.text)
                                                .font(.title2)
                                        }
                                        Text("\(weather.forecast.forecastday[2].day.mintemp_f, specifier: "%.0f")/\(weather.forecast.forecastday[2].day.maxtemp_f, specifier: "%.0f")")
                                            .font(.system(size: 15))
                                        
                                    }
                                    Spacer()
                                    VStack {
                                        Text("\(weather.forecast.forecastday[3].date.toMMDDFormat())")
                                            .font(.system(size: 15))
                                        if let url = URL(string: "https:\(weather.forecast.forecastday[3].day.condition.icon)") {
                                            AsyncImage(url: url) { image in
                                                image
                                                    .resizable()
                                                    .aspectRatio(contentMode: .fit)
                                                    .frame(width: 40, height: 40)
                                            } placeholder: {
                                                ProgressView()
                                            }
                                        } else {
                                            Text(weather.current.condition.text)
                                                .font(.title2)
                                        }
                                        Text("\(weather.forecast.forecastday[3].day.mintemp_f, specifier: "%.0f")/\(weather.forecast.forecastday[3].day.maxtemp_f, specifier: "%.0f")")
                                            .font(.system(size: 15))
                                        
                                    }
                                    Spacer()
                                    VStack {
                                        Text("\(weather.forecast.forecastday[4].date.toMMDDFormat())")
                                            .font(.system(size: 15))
                                        if let url = URL(string: "https:\(weather.forecast.forecastday[4].day.condition.icon)") {
                                            AsyncImage(url: url) { image in
                                                image
                                                    .resizable()
                                                    .aspectRatio(contentMode: .fit)
                                                    .frame(width: 40, height: 40)
                                            } placeholder: {
                                                ProgressView()
                                            }
                                        } else {
                                            Text(weather.current.condition.text)
                                                .font(.title2)
                                        }
                                        Text("\(weather.forecast.forecastday[4].day.mintemp_f, specifier: "%.0f")/\(weather.forecast.forecastday[4].day.maxtemp_f, specifier: "%.0f")")
                                            .font(.system(size: 15))
                                        
                                    }
                                    Spacer()
                                    
                                }
                            }
                        }
                        .padding(.top, 100)
                    }
                }
            }
            .foregroundColor(Color("text"))
            .coordinateSpace(name: "pullToRefresh")
            .onAppear {
                templateManager.setup()
                let location = viewModel.getLoc()
                print("Location: \(location)")
                Task {
                    await viewModel.fetchWeather()
                    if (location != "42.1673839, -92.0156213") {
                        viewModel.showFirstView = false
                        viewModel.showSecondView = true
                    }
                }
                viewModel.onMySubmit()
            }
        }
        .padding(.bottom,80)
        //.padding(.top, 50)
    }
}

struct WeatherView_Previews: PreviewProvider {
    static var previews: some View {
        WeatherView()
    }
}
