//
//  CarPlayObserver.swift
//  Drivers Center
//
//  Created by Steven Spencer on 1/17/25.
//


import Foundation
import Combine

class CarPlayObserver: ObservableObject {
    // Singleton instance
    static let shared = CarPlayObserver()

    // Published property to notify SwiftUI views of changes
    @Published var carPlay: Bool {
        didSet {
            // Update UserDefaults whenever carPlay changes
            UserDefaults.standard.set(carPlay, forKey: "carPlay")
        }
    }

    private var cancellable: AnyCancellable?

    // Private initializer to enforce singleton usage
    private init() {
        // Set the initial value from UserDefaults or default to false
        self.carPlay = UserDefaults.standard.bool(forKey: "carPlay")

        // Subscribe to UserDefaults changes
        self.cancellable = NotificationCenter.default
            .publisher(for: UserDefaults.didChangeNotification, object: UserDefaults.standard)
            .map { _ in
                UserDefaults.standard.bool(forKey: "carPlay")
            }
            .removeDuplicates()
            .receive(on: RunLoop.main)
            .sink { [weak self] newValue in
                self?.carPlay = newValue
            }
    }

    deinit {
        cancellable?.cancel()
    }

    // Method to toggle the carPlay value
    func toggleCarPlay() {
        carPlay.toggle()
    }

    // Optional: Method to set carPlay to a specific value
    func setCarPlay(_ value: Bool) {
        carPlay = value
    }
}