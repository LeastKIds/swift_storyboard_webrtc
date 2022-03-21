//
//  JWTToken.swift
//  Runner
//
//  Created by 김진홍 on 2022/01/21.
//

import Foundation
public class JWTToken{
    
//**************************************************************************************************************
//    get jwt token
//**************************************************************************************************************
    
    public func getToken() -> String? {
        let JWTTOKEN = "stadium_jwt_token"
        let TOKEN: String? = UserDefaults.standard.string(forKey: JWTTOKEN)
        
        return TOKEN
    }
    
//***************************************************************************************************************
//    set jwt token
//***************************************************************************************************************
    
    public func setToken(data: Data) {
        let decoder = JSONDecoder()
        do {
            let json = try decoder.decode(AuthCodableStruct.loginJson.self, from: data)

            let JWTTOKEN = "stadium_jwt_token"
            UserDefaults.standard.set(json.access_token!, forKey: JWTTOKEN)
            UserDefaults.standard.synchronize()

        } catch {
            print(error)
        }
    }
    
    
    
//    public func setJson(data: Data) ->  RoomCodableStruct.rooms_info{
//        let decoder = JSONDecoder()
//        var json:Any?
//        do {
//            json = try decoder.decode(RoomCodableStruct.rooms_info.self, from: data)
//        } catch {
//            print(error)
//        }
//
//        print("@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@")
//        print(type(of: json))
//
//        return json as! RoomCodableStruct.rooms_info
//    }
    
}
