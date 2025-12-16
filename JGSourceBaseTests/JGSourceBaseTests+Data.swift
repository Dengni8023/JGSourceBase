//
//  JGSourceBaseTests+Data.swift
//  JGSourceBaseTests
//
//  Created by 梅继高 on 2025/12/16.
//  Copyright © 2025 MeiJiGao. All rights reserved.
//

import Foundation
import JGSourceBase

extension JGSourceBaseTests {
    
    func testDataAES() {
        
        let data = Data(capacity: 128)
        let aes128key = ""
        let aesIv = ""
        let encStr1 = data.jg_AES128Encrypt(withKey: aes128key, iv: aesIv)
        let encStr2 = (data as NSData).jg_AES128Encrypt(withKey: aes128key, iv: aesIv)
    }
}
