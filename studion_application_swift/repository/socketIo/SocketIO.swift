//
//  SocketIo.swift
//  studion_application_swift
//
//  Created by 김진홍 on 2022/03/17.
//

import Foundation
import SocketIO

class SocketIO: NSObject {
    static let sharedInstance = SocketIO()
    
//    var manager:SocketManager = SocketManager(socketURL: URL(string: "http://192.168.1.4:9876/")!, config: [ .compress])
    var manager:SocketManager = SocketManager(socketURL: URL(string: "http://172.21.2.52:9876/")!, config: [ .compress])
    var socket:SocketIOClient!
    
    
    override init() {
        super.init()
                
        socket = self.manager.defaultSocket
        print("소켓 초기화 완료")
    }
    
    func establishConnection() {
            
        socket.connect()

        print("소켓 연결 시도")
    }
    
    func closeConnection() {
            
        socket.disconnect()

        print("소켓 연결 종료")
    }
    
    func getSocket() -> SocketIOClient {
        return socket
    }
    
    func getSocketIOId() -> String {
        return socket.sid
    }
}
