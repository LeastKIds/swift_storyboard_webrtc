//
//  ViewController.swift
//  studion_application_swift
//
//  Created by 김진홍 on 2022/03/17.
//

import UIKit
import WebKit
import SocketIO
import Alamofire

class ViewController: UIViewController, WKScriptMessageHandler, WKNavigationDelegate, WKUIDelegate {
    
    
    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        print("call 진입")
        print(message)
        
        if(message.name == "success") {
            print("success 호출")
            roomController.getWebViewData(data: message.body)
        }
    }
    
    
    let socket:SocketIOClient = SocketIO.sharedInstance.getSocket()
    let roomController:RoomController = RoomController()
    let webRTCClient: WebRTCClient = WebRTCClient()
    
    @IBOutlet weak var myWebView: WKWebView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
//        guard let localFilePath = Bundle.main.path(forResource: "app", ofType: "html")
//        else {
//          print("path is nil")
//          return
//        }

//        loadWebpage(url: localFilePath)

        
        
        
//        loadWebpage(url: "http://172.20.10.3:9877")
//        loadWebpage(url: "http://192.168.1.4:9877")
        loadWebpage(url: "http://172.21.2.52:9877")
//        loadWebpage(url: "https://www.youtube.com/")
        
//        let api: String = "http://192.168.1.4:8000/"
        let api: String = "http://172.21.2.52:8000/"
        
        
        
        
        SocketIO.sharedInstance.establishConnection()
        socket.on(clientEvent: .connect) {data, ack in
            print("room list socket connected")
            
            let authController = AuthController(api: api)
            authController.login(email: "1@naver.com", password: "aaaaaaaa") {data in
                authController.loginCheck() {data in
                    print("logincheck [view controller]")
//                    self.roomController.joinRoom(room: 1)
                    self.webRTCClient.joinRoom(room: 1)
                }
            }
        }
        
//        roomController.allUsers(myWebView: myWebView)
//        roomController.getAnswer(myWebView: myWebView)
//        roomController.getOffer(myWebView: myWebView)
        webRTCClient.allUsers()
        webRTCClient.getAnswer()
        
    }
    
    
    @IBAction func click(_ sender: Any) {
        
        var data: [String: String] = [
            "test" : "test",
            "aa" : "aa"
        ]
        
        var test: String = "{'test' : 'test', 'aaa' : 'aaa'}"
        
        self.myWebView?.evaluateJavaScript("changeColor(\(test))", completionHandler: {result, error in
            if error != nil{
                print("에러")
                print(error)
            }
            print("함수 호출")
//            print(result!)
            let dic: [String: String] = result! as! Dictionary
            print(dic)
        })
        
    }
    
    func loadWebpage(url:String){
        let myUrl = URL(string: url)    // URL타입으로 바꿔줘야함
        let myRequest = URLRequest(url: myUrl!)
        
        
        let contentController = WKUserContentController()
        let config = WKWebViewConfiguration()

        contentController.add(self, name: "success")
        config.userContentController = contentController

        myWebView = WKWebView(frame: .zero, configuration: config)
        myWebView.uiDelegate = self
        myWebView.navigationDelegate = self

        self.view.addSubview(myWebView)
        
        
        
        myWebView.load(myRequest)
    }
    
}

