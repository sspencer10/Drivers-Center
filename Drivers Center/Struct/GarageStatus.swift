import Foundation
class CurlCommands: NSObject, ObservableObject {
    func toggleOutdoorLight(state: String, completion: @escaping (Any) -> Void) {
        // Define the URL
        let url = URL(string: "https://ha.sspencer10.com/api/services/switch/toggle")!
        
        // Create a URLRequest object
        var request = URLRequest(url: url)
        
        // Set the HTTP method to POST
        request.httpMethod = "POST"
        
        // Set the required headers
        request.setValue("Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiI5ZWU5NWNiOWViNDM0MzViODcyYWI1ZmU2NmJhZWVkYSIsImlhdCI6MTcyNTE2MTY2NywiZXhwIjoyMDQwNTIxNjY3fQ.2fVXubLMbQg305K49MdgNAeRqDhDMIE6-5LavXQ9Jys", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        // Set the HTTP body with the JSON data
        let body: [String: String] = ["entity_id": "switch.outside_light"]
        request.httpBody = try? JSONSerialization.data(withJSONObject: body, options: [])
        
        // Create a data task to send the request
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            // Handle any errors
            if let error = error {
                print("Error: \(error)")
                return
            }
            
            // Handle the response data
            if let data = data, let responseString = String(data: data, encoding: .utf8) {
                completion(responseString)
            }
        }
        
        // Start the task
        task.resume()
    }
    
    func toggleGarageDoor(completion: @escaping (Any) -> Void) {
        // Define the URL
        let url = URL(string: "https://ha.sspencer10.com/api/services/switch/toggle")!
        
        // Create a URLRequest object
        var request = URLRequest(url: url)
        
        // Set the HTTP method to POST
        request.httpMethod = "POST"
        
        // Set the required headers
        request.setValue("Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiI5ZWU5NWNiOWViNDM0MzViODcyYWI1ZmU2NmJhZWVkYSIsImlhdCI6MTcyNTE2MTY2NywiZXhwIjoyMDQwNTIxNjY3fQ.2fVXubLMbQg305K49MdgNAeRqDhDMIE6-5LavXQ9Jys", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        // Set the HTTP body with the JSON data
        let body: [String: String] = ["entity_id": "switch.garage_door"]
        request.httpBody = try? JSONSerialization.data(withJSONObject: body, options: [])
        
        // Create a data task to send the request
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            // Handle any errors
            if let error = error {
                print("Error: \(error)")
                return
            }
            
            // Handle the response data
            if let data = data, let responseString = String(data: data, encoding: .utf8) {
                completion(responseString)
            }
        }
        
        // Start the task
        task.resume()
    }
    
        
    func getOverheadDoorState(completion: @escaping (Any) -> Void) {
            // Define the URL
            let url = URL(string: "https://ha.sspencer10.com/api/states/binary_sensor.overhead_door")!
            
            // Create a URLRequest object
            var request = URLRequest(url: url)
            
            // Set the HTTP method to GET (default)
            request.httpMethod = "GET"
            
            // Set the required headers
            request.setValue("Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiI5ZWU5NWNiOWViNDM0MzViODcyYWI1ZmU2NmJhZWVkYSIsImlhdCI6MTcyNTE2MTY2NywiZXhwIjoyMDQwNTIxNjY3fQ.2fVXubLMbQg305K49MdgNAeRqDhDMIE6-5LavXQ9Jys", forHTTPHeaderField: "Authorization")
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            
            // Create a data task to send the request
            let task = URLSession.shared.dataTask(with: request) { data, response, error in
                // Handle any errors
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
        // Define the URL
        let url = URL(string: "https://ha.sspencer10.com/api/states/switch.outside_light")!
        
        // Create a URLRequest object
        var request = URLRequest(url: url)
        
        // Set the HTTP method to GET (default)
        request.httpMethod = "GET"
        
        // Set the required headers
        request.setValue("Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiI5ZWU5NWNiOWViNDM0MzViODcyYWI1ZmU2NmJhZWVkYSIsImlhdCI6MTcyNTE2MTY2NywiZXhwIjoyMDQwNTIxNjY3fQ.2fVXubLMbQg305K49MdgNAeRqDhDMIE6-5LavXQ9Jys", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        // Create a data task to send the request
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            // Handle any errors
            if let error = error {
                print("Error: \(error)")
                return
            }
            
            // Handle the response data
            if let data = data, let responseString = String(data: data, encoding: .utf8) {
                completion(responseString)
            }
        }
        task.resume()
    }
}
