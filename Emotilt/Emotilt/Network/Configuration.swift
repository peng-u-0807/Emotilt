//
//  Configuration.swift
//  Emotilt
//
//  Created by 최유림 on 2023/03/03.
//

import Foundation

struct Configuration {
    static let serviceName: String = Bundle.main.infoDictionary?["SERVICE_NAME"] as! String
    static let serviceIdentifier: String = Bundle.main.infoDictionary?["SERVICE_IDENTIFIER"] as! String
    static let simulatorIdentifier: String = Bundle.main.infoDictionary?["SERVICE_IDENTIFIER_SIM"] as! String
}
