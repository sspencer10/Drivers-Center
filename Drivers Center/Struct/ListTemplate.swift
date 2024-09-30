//
//  ListTemplate.swift
//  Drivers Center
//
//  Created by Steven Spencer on 8/31/24.
//

import UIKit
import SwiftUI
import CarPlay
import MapKit
import Foundation
import Combine
import CoreLocation
import Intents
import MediaPlayer

class Lists: NSObject, ObservableObject {
    var lm = LocationManager.shared
    var wvm = WeatherViewModel()
    @State var sections: [CPListSection]?

    let configuration = UIImage.SymbolConfiguration.init(pointSize: 10)

    
    func ListTemplate(completion: @escaping (CPListTemplate) -> Void) {
        lm.UpdateAllowed(x: true, completion:  { x in
            
        let listItemHead = CPListItem(text: "Back", detailText: "")
        listItemHead.setImage(UIImage(systemName: "arrowshape.left.circle", withConfiguration: self.configuration)!)
        listItemHead.userInfo = "0"
        TemplateManager().Back(listItem: listItemHead)
        
        // List Sections
        let sections = [CPListSection(items: [listItemHead])]
        
        // List Template
        let template = CPListTemplate(title: "", sections: sections)
        template.tabImage = UIImage(systemName: "speedometer")
        completion(template)
        })
    }

}
