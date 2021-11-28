//
//  API.swift
//  Bright
//
//  Created by Martin Lukacs on 27/11/2021.
//

import Foundation

final class API: JoltNetworkServicing {
    let joltNetworkClient = JoltNetwork(baseURL: APIConfig.baseUrl)

    init() {
        setUp()
    }
}

extension API {
    private func setUp() {
        joltNetworkClient.setSessionHeader(with: ["Authorization": APIConfig.apiKey])
        joltNetworkClient.setSessionRequestTimout(with: APIConfig.Settings.timeout)
        #if DEBUG
        joltNetworkClient.setLogLevel(with: .debugVerbose)
        joltNetworkClient.setSessionRequestTimout(with: 5)
        #else
        joltNetworkClient.setLogLevel(with: .none)
        joltNetworkClient.setSessionRequestTimout(with: APIConfig.Settings.timeout)
        #endif
    }
}
