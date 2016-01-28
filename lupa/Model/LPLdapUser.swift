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
    
    //  LDAP search results will be mapped to these fields
    //
    var dn:             String = ""
    var cn:             String = ""
    var uid:            String = ""
    var desc:           String = ""
    var country:        String = ""
    var city:           String = ""
    var voicetel:       String = ""
    var voicemob:       String = ""
    var voiceint:       String = ""
    var title:          String = ""
    var picturlMini:    NSURL!
    var picturlZoom:    NSURL!
    
    /// --------------------------------------------------------------------------------
    //  MARK: Main
    /// --------------------------------------------------------------------------------
    
    override init() {
        super.init()
    }
    
    deinit {
    }
    
}
