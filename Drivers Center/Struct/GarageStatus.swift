import Foundation

class CurlCommands: NSObject, ObservableObject {
    
    // Computed property to securely fetch the token from Info.plist
    // Load the API key from Secrets.plist
    private var authToken: String {
        guard let filePath = Bundle.main.path(forResource: "Secrets", ofType: "plist"),
              let secrets = NSDictionary(contentsOfFile: filePath),
              let token = secrets["HAAuthToken"] as? String,
              !token.isEmpty else {
            fatalError("HAAuthToken not set in Secrets.plist")
        }
        return token
    }
    
    func toggleOutdoorLight(state: String, completion: @escaping (Any) -> Void) {
        let url = URL(string: "https://ha.sspencer10.com/api/services/switch/toggle")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("Bearer \(authToken)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        let body: [String: String] = ["entity_id": "switch.outside_light"]
        request.httpBody = try? JSONSerialization.data(withJSONObject: body, options: [])
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("Error: \(error)")
                return
            }
            if let data = data, let responseString = String(data: data, encoding: .utf8) {
                completion(responseString)
            }
        }
        task.resume()
    }
    
    func unlockBackDoor(completion: @escaping (Any) -> Void) {
        let url = URL(string: "https://ha.sspencer10.com/api/services/lock/unlock")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("Bearer \(authToken)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        let body: [String: String] = ["entity_id": "lock.back_door"]
        request.httpBody = try? JSONSerialization.data(withJSONObject: body, options: [])
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("Error: \(error)")
                return
            }
            if let data = data, let responseString = String(data: data, encoding: .utf8) {
                completion(responseString)
            }
        }
        task.resume()
    }
    
    func lockBackDoor(completion: @escaping (Any) -> Void) {
        let url = URL(string: "https://ha.sspencer10.com/api/services/lock/lock")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("Bearer \(authToken)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        let body: [String: String] = ["entity_id": "lock.back_door"]
        request.httpBody = try? JSONSerialization.data(withJSONObject: body, options: [])
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("Error: \(error)")
                return
            }
            if let data = data, let responseString = String(data: data, encoding: .utf8) {
                completion(responseString)
            }
        }
        task.resume()
    }
    
    func toggleGarageDoor(completion: @escaping (Any) -> Void) {
        let url = URL(string: "https://ha.sspencer10.com/api/services/switch/toggle")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("Bearer \(authToken)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        let body: [String: String] = ["entity_id": "switch.garage_door"]
        request.httpBody = try? JSONSerialization.data(withJSONObject: body, options: [])
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("Error: \(error)")
                return
            }
            if let data = data, let responseString = String(data: data, encoding: .utf8) {
                completion(responseString)
            }
        }
        task.resume()
    }
    
    func getOverheadDoorState(completion: @escaping (Any) -> Void) {
        let url = URL(string: "https://ha.sspencer10.com/api/states/binary_sensor.overhead_door")!
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("Bearer \(authToken)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("Error: \(error)")
                return
            }
            if let data = data, let responseString = String(data: data, encoding: .utf8) {
                completion(responseString)
            }
        }
        task.resume()
    }
    
    func getLockStatus(completion: @escaping (Any) -> Void) {
        let url = URL(string: "https://ha.sspencer10.com/api/states/lock.back_door")!
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("Bearer \(authToken)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("Error: \(error)")
                return
            }
            if let data = data, let responseString = String(data: data, encoding: .utf8) {
                completion(responseString)
            }
        }
        task.resume()
    }
    
    func getOutsideLightState(completion: @escaping (Any) -> Void) {
        let url = URL(string: "https://ha.sspencer10.com/api/states/switch.outside_light")!
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("Bearer \(authToken)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("Error: \(error)")
                return
            }
            if let data = data, let responseString = String(data: data, encoding: .utf8) {
                completion(responseString)
            }
        }
        task.resume()
    }
}
