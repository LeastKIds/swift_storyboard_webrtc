//
//  AuthController.swift
//  Runner
//
//  Created by 김진홍 on 2022/01/10.
//

import Foundation
import Alamofire

public class AuthController {
    
    var api: String
    
    init(api: String) {
        self.api = api
    }
    
    
//************************************************************************************
//    로그인 체크
//************************************************************************************
    public func loginCheck(handler: @escaping (Any) -> Void){
        
        
        
        let tokenController = JWTToken()
        let TOKEN:String? = tokenController.getToken()
        
        if (TOKEN != nil) {
            let url = api + "api/users/user"
            let headers: HTTPHeaders = [
                "Authorization" : "Bearer \(TOKEN!)"
            ]
            
            
            AF.request(url, method: .get, headers: headers).responseData{
                response in
                
                var status = response.response?.statusCode ?? 500
                print("logincheck [swift]")
                print(response.result)
                switch response.result {
                case .success(let data):
                    if(status == 401) {
                        let response_data : [String: Any] = [
                            "status" : status,
                            "data" : data
                        ]
                        
                        handler(response_data)
                    } else if (status == 200) {
                        let response_data : [String: Any] = [
                            "status" : status,
                            "data" : data
                        ]
                        
                        UserInfo.userInfo.setUserInfo(data: data)
                    
                        
                        handler(response_data)
                    }
                case .failure(let error):
                    let response_data : [String: Any] = [
                        "status" : 500,
                        "error" : "server disconnected"
                    ]
                    handler(response_data)
                }
            
            }
        } else {
            print("AA")
            
            let response_data : [String: Any] = [
                "status" : 401,
            ]
            
            handler(response_data)
        }
        
    }
    
    
//***********************************************************************************
//    회원가입
//***********************************************************************************
    public func register(email: String, password: String, password_confirm: String , name: String, handler: @escaping (Any) -> Void) {
        let url = api + "api/users/register"
        let parameter : [String: String] = [
            "email" : email,
            "password" : password,
            "password_confirmation" : password_confirm,
            "name" : "name"
        ]
        
        AF.request(url, method: .post, parameters: parameter).responseData{ response in
            var status = response.response?.statusCode ?? 500
            switch response.result {
            case .success(let data):
                if(status == 200) {
                    let decoder = JSONDecoder()
                    do {
                        let json = try decoder.decode(AuthCodableStruct.registerJson_error.self, from: data)
                        
                        if(json.status != nil) {
                            let response_data : [String: Any] = [
                                "status" : 402,
                                "messages" : "이미 가입이 되어 있는 이메일 입니다.",
                                "messages_title" : "회원가입 오류"
                            ]
                            handler(response_data)
                        } else {
                            let JWTTOKEN = "stadium_jwt_token"
                
                            UserDefaults.standard.set(json.access_token!, forKey: JWTTOKEN)
                            UserDefaults.standard.synchronize()
                            
                            let response_data : [String: Any] = [
                                "status" : status,
                            ]
//                            print("aa")
//                            print("now : \(UserDefaults.standard.string(forKey: JWTTOKEN))")
                            
                            handler(response_data)
                        }
                    } catch {
                        print(error)
                    }
                }
            case .failure(let error):
                let response_data : [String: Any] = [
                    "status" : 500,
                    "messages" : "네트워크를 확인해주세요",
                    "messages_title" : "서버 오류"
                ]
                
                handler(response_data)
            }
        }
    }
    
//*********************************************************************************************
//    로그인
//*********************************************************************************************
    public func login(email: String, password: String, handler: @escaping (Any) -> Void) {
        let url = api + "api/users/login"
        let parameter : [String: String] = [
            "email" : email,
            "password" : password
        ]
        
        AF.request(url, method: .post, parameters: parameter).responseData{
            response in
            
            var status = response.response?.statusCode ?? 500
            
            print("login [swift]")
            print(response.result)
            
            switch response.result {
            case .success(let data):
                print("login [swift] : \(data)")
                print("login status [swift] : \(status)")
                if(status == 401) {
                    let response_data : [String: Any] = [
                        "status" : status,
                        "error" : "없는 계정입니다."
                    ]
                    
                    handler(response_data)
                }else if (status == 200) {
//
                    let JWTToken = JWTToken()
                    JWTToken.setToken(data: data)
                    
                    let response_data : [String: Any] = [
                                        "status" : status,
                                    ]
                        handler(response_data)
                    
                    
                }
            case .failure(let error):
                let response_data: [String: Any] = [
                    "status" : 500,
                    "error" : "서버와 연결이 끊어졌습니다."
                ]
                
                handler(response_data)
            }
        }
    }
    
//****************************************************************************************************************
//    로그아웃
//****************************************************************************************************************
    public func logout(handler: @escaping (Any) -> Void) {
        let url = api + "api/users/logout"
        let JWTTOKEN = "stadium_jwt_token"
        let TOKEN = UserDefaults.standard.string(forKey: JWTTOKEN)
        
        let headers: HTTPHeaders = [
            "Authorization" : "Bearer \(TOKEN!)"
        ]
        
        AF.request(url, method: .get, headers: headers).responseJSON{
            response in
            
            var status = response.response?.statusCode ?? 500
            
            switch response.result {
            case .success(let data):
                if(status == 401) {
                    let response_data: [String: Int] = [
                        "status" : 401,
                    ]
                    
                    handler(response_data)
                } else if (status == 200) {
                    let response_data: [String: Int] = [
                        "status" : 200
                    ]
                    
                    handler(response_data)
                    
                }
                
            case .failure(let error):
                let response_data: [String: Any] = [
                    "status" : 500,
                    "error" : error
                ]
                
                handler(response_data)
            }
        
        }
    }
    
}
