//
//  AppDelegate.swift
//  Gossip
//
//

import SwiftUI
import UserNotifications

class AppDelegate: NSObject, UIApplicationDelegate,
    UNUserNotificationCenterDelegate
{
    var app: GossipApp?

    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication
            .LaunchOptionsKey: Any]?
    ) -> Bool {
        Task {
            await requestNotificationPermissions()
        }

        return true
    }

    func requestNotificationPermissions() async {
        let center = UNUserNotificationCenter.current()
        center.delegate = self

        let options: UNAuthorizationOptions = [.alert, .sound, .badge]
        let granted = try? await center.requestAuthorization(options: options)
        if granted == true {
            await MainActor.run {
                UIApplication.shared.registerForRemoteNotifications()
            }
        }
    }

    func application(
        _ application: UIApplication,
        didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data
    ) {
        let stringifiedToken = deviceToken.map {
            String(format: "%02.2hhx", $0)
        }.joined()
        print("stringifiedToken:", stringifiedToken)
    }
}
