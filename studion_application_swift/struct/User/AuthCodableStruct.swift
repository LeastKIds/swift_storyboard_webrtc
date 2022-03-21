//
//  AuthCodableStruct.swift
//  Runner
//
//  Created by 김진홍 on 2022/01/14.
//

import Foundation


public class AuthCodableStruct {
    
//************************************************************************************
//    회원가입 json 양식
//************************************************************************************
    
    public struct registerJson_error: Codable {
        var status: String?
        var messages: String?
        var access_token: String?
        var token_type: String?
        var expires_in: Int?
        var loginSuccess: Bool?
        var userId: Int?
    }
    
//************************************************************************************
//    로그인 json 양식
//************************************************************************************
    
    public struct loginJson: Codable {
        var error: String?
        var access_token: String?
        var token_type: String?
        var expires_in: Int?
        var loginSuccess: Bool?
        var userId: Int?
    }
    
//************************************************************************************
//    로그아웃 json 양식
//************************************************************************************
    
    public struct logoutJson: Codable {
        var status: String
        var message: String
        
    }
    
//************************************************************************************
//    User Info
//************************************************************************************
    
    public struct userInfo: Codable {
        var created_at: String!
        var updated_at: String!
        var email: String!
        var id: Int!
        var image: String?
        var name: String!
    }
}
