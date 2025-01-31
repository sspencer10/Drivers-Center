//
//  AppStatusHelper.swift
//  Drivers Center
//
//  Created by Steven Spencer on 1/31/25.
//


class AppStatusHelper {
    func isAppInBackground() -> Bool {
        let appState = UIApplication.shared.applicationState
        return appState == .background
    }
}