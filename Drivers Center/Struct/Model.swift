import Foundation

struct WeatherResponse: Codable {
    let location: Location
    let current: CurrentWeather
    let forecast: Forecast
    let alerts: Alerts
}

struct Location: Codable {
    let name: String
    let region: String
    let country: String
    let localtime: String
}

struct CurrentWeather: Codable {
    let temp_f: Double
    let is_day: Int
    let wind_dir: String
    let wind_mph: Double
    let gust_mph: Double
    let uv: Int
    let dewpoint_f: Double
    let humidity: Double
    let feelslike_f: Double
    let condition: WeatherCondition
}

struct WeatherCondition: Codable {
    let text: String
    let icon: String
    let code: Int
}

struct Forecast: Codable {
    let forecastday: [ForecastDay]
}

struct ForecastDay: Codable, Identifiable {
    var id: UUID { UUID()}
    let day: Day
    let date: String
    let hour: [Hour]
    let astro: Astro
}

struct Day: Codable {
    let maxtemp_f: Double
    let mintemp_f: Double
    let avgtemp_f: Double
    let condition: DayCondition

}
    struct DayCondition: Codable {
        let text: String
        let icon: String
    }

struct Hour: Codable, Identifiable, Hashable {
    var id: UUID { UUID() }
    var time: String
    var temp_f: Double
    var condition: Condition

    static func == (lhs: Hour, rhs: Hour) -> Bool {
        return lhs.id == rhs.id
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}

struct Condition: Codable {
    let text: String
    let icon: String
}

struct Astro: Codable {
    let sunrise: String
    let sunset: String
    let moonrise: String
    let moonset: String
}

struct Alerts: Codable {
    let alert: [Alert]
}

struct Alert: Codable, Identifiable {
    var id: UUID { UUID()}
    let headline: String
    let msgtype: String
    let severity: String
    let urgency: String
    let areas: String
    let category: String
    let certainty: String
    let event: String
    let note: String
    let effective: String
    let expires: String
    let desc: String
    let instruction: String
}
