//
//  ModalTrasitionSingleton.swift
//  TownHunt
//
//  Created by Alvin Lee on 19/03/2017.
//  Copyright © 2017 LeeTech. All rights reserved.
//

import Foundation

protocol ModalTransitionListener {
    func modalViewDismissed()
}

class ModalTransitionMediator {
    /* Singleton */
    class var instance: ModalTransitionMediator {
        struct Static {
            static let instance: ModalTransitionMediator = ModalTransitionMediator()
        }
        return Static.instance
    }
    
    private var listener: ModalTransitionListener?
    
    private init() {
        
    }
    
    func setListener(listener: ModalTransitionListener) {
        self.listener = listener
    }
    
    func sendModalViewDismissed(modelChanged: Bool) {
        listener?.modalViewDismissed()
    }
}
