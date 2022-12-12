//
//  Extension+String.swift
//  WeatherApp
//
//  Created by Saidac Alexandru on 30.11.2022.
//

import Foundation
import UIKit

extension String {
    func capitalizingFirstLetter() -> String {
        return prefix(1).capitalized + dropFirst()
    }

    mutating func capitalizeFirstLetter() {
        self = self.capitalizingFirstLetter()
    }
}
