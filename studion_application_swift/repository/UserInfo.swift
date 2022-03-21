//
//  UserInfo.swift
//  Runner
//
//  Created by 김진홍 on 2022/03/03.
//

import Foundation

class UserInfo {
    
    static let userInfo = UserInfo()
    var user: AuthCodableStruct.userInfo?
    
//************************************************************************************
//    set user info
//************************************************************************************
    
    func setUserInfo(data: Data) {
        let decoder = JSONDecoder()
        do {
            let json = try decoder.decode(AuthCodableStruct.userInfo.self, from: data)
            user = json
        } catch {
            print(error)
        }
    }
    
//************************************************************************************
//    get user info
//************************************************************************************
    func getUserInfo() -> AuthCodableStruct.userInfo?{
        return user
    }
    
}
