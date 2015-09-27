//
//  LPLdapUser.swift
//  lupa
//
//  Created by Luis Palacios on 27/9/15.
//  Copyright © 2015 Luis Palacios. All rights reserved.
//

import Cocoa

class LPLdapUser: NSObject {

    /// --------------------------------------------------------------------------------
    //  MARK: Attributes
    /// --------------------------------------------------------------------------------
    
    //  For the following attributes I'm using Implicitly Unwrapped Optional (!) so
    //  they are optionals and do not need to initialize them here, will do later.
    
    var dn:         String = ""
    var cn:         String = ""
    var uid:        String = ""
    var desc:       String = ""
    var country:    String = ""
    var city:       String = ""
    var voicetel:   String = ""
    var voicemob:   String = ""
    var voiceint:   String = ""
    var haspict:    String = ""
    var title:      String = ""
    
    /// --------------------------------------------------------------------------------
    //  MARK: Main
    /// --------------------------------------------------------------------------------
    
    override init() {
        super.init()
    }
    
    deinit {
    }
    
}
