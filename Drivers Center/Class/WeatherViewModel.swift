import Foundation
import SwiftUI

class WeatherViewModel: NSObject, ObservableObject {
    
    public static var shared = Drivers_Center.WeatherViewModel()

    
    //var lm = LocationManager.shared
    @Published var weather: WeatherResponse?
    @Published var loc: String?
    @Published var min: Double?
    @Published var max: Double?
    @Published var temp: String = ""
    @Published var lat: Double?
    @Published var long: Double?
    @Published var day: Int = 1
    @Published var count: Int = 0
    @Published var showFirstView = true
    @Published var showSecondView = false
    @Published var x: String = ""
    @Published var today_min: Double = 0.0
    @Published var today_max: Double = 0.0
    @Published var code: Int = 0
    @Published var is_day: Int = 0
        
    private var apiKey: String {
        guard let filePath = Bundle.main.path(forResource: "Secrets", ofType: "plist"),
              let secrets = NSDictionary(contentsOfFile: filePath),
              let token = secrets["WeatherAPIKey"] as? String,
              !token.isEmpty else {
            fatalError("WeatherAPIKey not set in Secrets.plist")
        }
        return token
    }
    
    var timer: Timer?
    
    private override init() {
        super.init()
        fetchWeather()
    }
    
    func fetchWeather() {
        print("FetchWeather")
        let urlString = "https://api.weatherapi.com/v1/forecast.json?key=\(apiKey)&q=\(LocationManager.shared.latitude), \(LocationManager.shared.longitude)&alerts=yes&days=5"
        print("urlString: \(urlString)")
        guard let url = URL(string: urlString) else { return }
        
        URLSession.shared.dataTask(with: url) { data, response, error in
            if let data = data {
                do {
                    let decodedData = try JSONDecoder().decode(WeatherResponse.self, from: data)
                    DispatchQueue.main.async {
                        self.weather = decodedData
                        self.count = decodedData.forecast.forecastday.count
                        //self.temp = decodedData.current.temp_f
                        self.day = decodedData.current.is_day
                        print(self.count)
                        self.onMySubmit()
                        self.is_day = decodedData.current.is_day
                        self.today_min = decodedData.forecast.forecastday[0].day.mintemp_f
                        self.today_max = decodedData.forecast.forecastday[0].day.maxtemp_f
                        self.code = decodedData.current.condition.code
                        self.showFirstView = false
                        self.showSecondView = true
                        print("urlString: done")
                    }
                } catch {
                    print("Error decoding data: \(error)")
                }
            }
        }.resume()
    }
    

    
    func getLoc() -> String {
        print("getLoc")
        
        // Ensure all @Published property updates happen on the main thread
        let newLoc = "\(LocationManager.shared.latitude), \(LocationManager.shared.longitude)"
        DispatchQueue.main.async {
            self.loc = newLoc
            if self.loc != "42.1673839, -92.0156213" {
                UserDefaults.standard.setValue(self.loc, forKeyPath: "loc")
            }
        }
        
        if let storedLoc = UserDefaults.standard.string(forKey: "loc") {
            print(storedLoc)
            return storedLoc
        } else {
            print("42.1673839, -92.0156213")
            return "42.1673839, -92.0156213"
        }
    }
    
    func getLat() -> Double {
        self.lat = LocationManager.shared.latitude
        return lat ?? 42.1673839
    }
    
    func getLong() -> Double {
        self.long = LocationManager.shared.longitude
        return long ?? -92.0156213
    }
    
    func onMySubmit() {
        showSecondView = true
        showFirstView = false
        timer?.invalidate()
        print("fetch weather")
        if (getLoc() != "42.1673839, -92.0156213") {
            timer = Timer.scheduledTimer(withTimeInterval: 60.0, repeats: true) {
                [self] timer in
                Task {
                    fetchWeather()

                }
            }
        } else {
            timer = Timer.scheduledTimer(withTimeInterval: 10.0, repeats: true) {
                [self] timer in
                Task {
                    fetchWeather()

                }
            }
        }
        x = "x"
    }
    
    func fetchText() {
        let urlString: String = "https://rightdevllc.com/weather/test.php?q=\(getLoc())"
        
        guard let url = URL(string: urlString) else { return }
        
        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                print("Error fetching text: \(error.localizedDescription)")
                return
            }
            
            guard let data = data, let fetchedText = String(data: data, encoding: .utf8) else {
                print("Failed to convert data to text")
                return
            }
            
            DispatchQueue.main.async {
                let mainString = fetchedText
                let substring = "v18.12.1"

                if mainString.contains(substring) {
                    self.temp = "60.0°"
                } else {
                    self.temp = "\(fetchedText)°"
                }
            }
        }
        
        task.resume()
    }
    
    func getMoreWeather() {
        let urlString = "https://api.weatherapi.com/v1/forecast.json?key=\(apiKey)&alerts=yes&q=\(getLoc())&days=5"
        guard let url = URL(string: urlString) else { return }

        URLSession.shared.dataTask(with: url) { [weak self] data, response, error in
            guard let self = self else { return } // Capture self weakly
            if let data = data {
                do {
                    let decodedData = try JSONDecoder().decode(WeatherResponse.self, from: data)
                    DispatchQueue.main.async {
                        self.today_min = decodedData.forecast.forecastday[0].day.mintemp_f
                        self.today_max = decodedData.forecast.forecastday[0].day.maxtemp_f
                    }
                } catch {
                    print("Error decoding data: \(error)")
                }
            }
        }.resume()
    }
}

