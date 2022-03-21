//
//  RoomController.swift
//  Runner
//
//  Created by 김진홍 on 2022/02/17.
//

import Foundation
import SocketIO
import WebRTC
import WebKit

class RoomController:NSObject {
    

    
    let socket:SocketIOClient = SocketIO.sharedInstance.getSocket()
    
    func joinRoom(room: Int) {
        let userInfo = UserInfo()
        let user: AuthCodableStruct.userInfo = UserInfo.userInfo.getUserInfo()!
        
//        var userInfoString: String = "{'id' : \(user.id!), 'name' : '\(user.name!)', 'email' : '\(user.email!)', 'image' : '\(user.image)', 'created_at' : '\(user.created_at!)', 'updated_at' : '\(user.updated_at!)'}"
        
        let userData : [String: Any] = [
            "id" : user.id as Any,
            "name" : user.name as Any,
            "email" : user.email as Any,
            "image" : user.image as Any,
            "created_at" : user.created_at as Any,
            "updated_at" : user.updated_at as Any,
        ]
        let data : [String: Any] = [
            "room_id" : room,
            "user" : userData,
        ]
        socket.emit("join_room", data)
        
    }
    
    func allUsers(myWebView: WKWebView) {
        socket.on("all_users") {data, ack in
            print("[room] allUsers")
            let users: [Any] = data[0] as! [NSDictionary]
            
            for user in users {
                let userDictionary = user as! Dictionary<String, Any>
                
                self.createPeerConnection(name: userDictionary["name"] as! String, id: userDictionary["id"]! as! String, myWebView: myWebView)
                
            }
            
        }
    }
    
    func createPeerConnection(name: String, id: String, myWebView: WKWebView) {
        print("createPeerConnection('\(socket.sid)','\(id)', '\(name)')")
//        print(id)
        myWebView.evaluateJavaScript("createPeerConnection('\(socket.sid)','\(id)', '\(name)')", completionHandler: {result, error in
            if error != nil{
                print("에러")
                print(error)
            }
            print("함수 호출")
            print(result)
        })
    }
    
    func getWebViewData(data: Any) {
        let dataDic = data as! Dictionary<String, Any>
        
        print(dataDic["type"] as! String)
        
        switch dataDic["type"] as! String {
            
        case "offer" :
            let offer = dataDic["data"]!
//            print("offer [web]")
//            print(offer)
            self.socket.emit("offer", offer as! SocketData)
            break
            
        case "onicecandidate" :
            print("candidate web")
            let candidate = dataDic["data"]!
            print(candidate)
            self.socket.emit("candidate", candidate as! SocketData)
            break
            
        case "dataChannel" :
            print("dataChannel")
            break
            
            
        default:
            break
        }
    }
    
    func getOffer(myWebView: WKWebView) {
        socket.on("getOffer") {data, ack in
            print("getOffer")
//            print(data)
        }
    }
    
    func getAnswer(myWebView: WKWebView) {
        socket.on("getAnswer") {data, ack in
            print("getAnswer")
            let answerDic = data[0] as! Dictionary<String, Any>
            let sdpDic = answerDic["sdp"] as! Dictionary<String, Any>
            
//            print(sdpDic["sdp"]!)
            
            
            let sdpWeb:String = "{'type' : '\(sdpDic["type"]!)'}"
            
            
            let answerWeb: String = "{'answerSendID' : '\(answerDic["answerSendID"]!)', 'sdp' : \(sdpWeb)}"
            
            let convert = sdpDic["sdp"] as! String
    
            myWebView.evaluateJavaScript("getAnswer(`\(answerDic["answerSendID"]!)`, `\(sdpDic["type"]!)` ,`\(sdpDic["sdp"]!)`)", completionHandler: {result, error in
                if error != nil{
                    print("에러")
                    print(error)
                }
                print("getAnswer return")
                print(result)
            })
        }
    }
    
    func getCandidate(myWebView: WKWebView) {
        socket.on("getCandidate") {data, ack in
            print("getCandidate")
            print(data)
        }
        
    }
    
    
    
    
    
}
//    func peerConnection(_ peerConnection: RTCPeerConnection, didChange stateChanged: RTCSignalingState) {
//        debugPrint("peerConnection new signaling state: \(stateChanged)")
//    }
//
//    func peerConnection(_ peerConnection: RTCPeerConnection, didAdd stream: RTCMediaStream) {
//        debugPrint("peerConnection did add stream")
//    }
//
//    func peerConnection(_ peerConnection: RTCPeerConnection, didRemove stream: RTCMediaStream) {
//        debugPrint("peerConnection did remove stream")
//    }
//
//    func peerConnectionShouldNegotiate(_ peerConnection: RTCPeerConnection) {
//        debugPrint("peerConnection should negotiate")
//    }
//
//    func peerConnection(_ peerConnection: RTCPeerConnection, didChange newState: RTCIceConnectionState) {
//        debugPrint("peerConnection new connection state: \(newState)")
////        self.delegate?.webRTCClient(self, didChangeConnectionState: newState)
//    }
//
//    func peerConnection(_ peerConnection: RTCPeerConnection, didChange newState: RTCIceGatheringState) {
//        debugPrint("peerConnection new gathering state: \(newState)")
//    }
//
//    func peerConnection(_ peerConnection: RTCPeerConnection, didGenerate candidate: RTCIceCandidate) {
////        self.delegate?.webRTCClient(self, didDiscoverLocalCandidate: candidate)
//    }
//
//    func peerConnection(_ peerConnection: RTCPeerConnection, didRemove candidates: [RTCIceCandidate]) {
//        debugPrint("peerConnection did remove candidate(s)")
//    }
//
//    func peerConnection(_ peerConnection: RTCPeerConnection, didOpen dataChannel: RTCDataChannel) {
//        debugPrint("peerConnection did open data channel")
////        self.remoteDataChannel = dataChannel
//    }
    
//    private let mediaConstrains = [kRTCMediaConstraintsOfferToReceiveAudio: kRTCMediaConstraintsValueTrue,
//                                   kRTCMediaConstraintsOfferToReceiveVideo: kRTCMediaConstraintsValueTrue]
//
//
//    func peerConection() {
//
//        let factory: RTCPeerConnectionFactory
//        let videoEncoderFactory = RTCDefaultVideoEncoderFactory()
//        let videoDecoderFactory = RTCDefaultVideoDecoderFactory()
//        let peerConnection:RTCPeerConnection
//
//        print(1)
//
//        factory = RTCPeerConnectionFactory( encoderFactory:videoEncoderFactory, decoderFactory: videoDecoderFactory)
//
//
//        let iceServers:[RTCIceServer]
//        iceServers = [RTCIceServer.init( urlStrings: ["stun:stun.l.google.com:19302"])]
//
//        let config = RTCConfiguration()
//        config.iceServers = iceServers
//        print(2)
////      플랜 b
//        config.sdpSemantics = .unifiedPlan
//
////      gatherContinually는 WebRTC가 네트워크 변경 사항을 수신하고 새 후보를 다른 클라이언트로 보낼 수 있도록 합니다.
//        config.continualGatheringPolicy = .gatherContinually
//
////      미디어 제약을 정의합니다. 웹 브라우저와 연결하려면 DtlsSrtpKeyAgreement가 true여야 합니다.
//        let constraints = RTCMediaConstraints(mandatoryConstraints: nil, optionalConstraints: ["DtlsSrtpKeyAgreement":kRTCMediaConstraintsValueTrue])
//
//        peerConnection = factory.peerConnection(with: config, constraints: constraints, delegate: nil)
//
//        createMediaSenders(factory: factory, peerConnection: peerConnection)
//        configureAudioSession()
//        print(3)
//        self.offer(peerConnection: peerConnection) {data in
//
//        }
//
//
//
//    }
//
//    func createMediaSenders(factory: RTCPeerConnectionFactory, peerConnection: RTCPeerConnection) {
//
//        var localDataChannel: RTCDataChannel?
//
//        let streamId = "stream"
//
//        // Audio
//        let audioTrack = self.createAudioTrack(factory: factory)
//        peerConnection.add(audioTrack, streamIds: [streamId])
//
//
//        // Data
//        if let dataChannel = createDataChannel(peerConnection: peerConnection) {
////            dataChannel.delegate = self
//            localDataChannel = dataChannel
//        }
//    }
//
//    func createAudioTrack(factory: RTCPeerConnectionFactory) -> RTCAudioTrack {
//        let audioConstrains = RTCMediaConstraints(mandatoryConstraints: nil, optionalConstraints: nil)
//        let audioSource = factory.audioSource(with: audioConstrains)
//        let audioTrack = factory.audioTrack(with: audioSource, trackId: "audio0")
//        return audioTrack
//    }
//
//    func createDataChannel(peerConnection: RTCPeerConnection) -> RTCDataChannel? {
//        let config = RTCDataChannelConfiguration()
//        guard let dataChannel = peerConnection.dataChannel(forLabel: "WebRTCData", configuration: config) else {
//            debugPrint("Warning: Couldn't create data channel.")
//            return nil
//        }
//        return dataChannel
//    }
//
//
//    func configureAudioSession() {
//        let rtcAudioSession =  RTCAudioSession.sharedInstance()
//        rtcAudioSession.lockForConfiguration()
//        do {
//            try rtcAudioSession.setCategory(AVAudioSession.Category.playAndRecord.rawValue)
//            try rtcAudioSession.setMode(AVAudioSession.Mode.voiceChat.rawValue)
//        } catch let error {
//            debugPrint("Error changeing AVAudioSession category: \(error)")
//        }
//        rtcAudioSession.unlockForConfiguration()
//    }
//
//    func offer(peerConnection: RTCPeerConnection,completion: @escaping (_ sdp: RTCSessionDescription) -> Void) {
//
//        print(4)
//        let constrains = RTCMediaConstraints(mandatoryConstraints: mediaConstrains,
//                                             optionalConstraints: nil)
//
//        print(5)
//        peerConnection.offer(for: constrains) { (sdp, error) in
//            guard let sdp = sdp else {
//                return
//            }
//
//            peerConnection.setLocalDescription(sdp, completionHandler: { (error) in
//                print("OFfer")
//                print(sdp)
//                completion(sdp)
//            })
//        }
//    }
    
    
    
//    func offer2(peerConection: RTCPeerConnection, sdp:Any, haldner: @escaping (Any) -> Void) {
//
//    }
    
    
//    let socket:SocketIOClient = SocketIo.sharedInstance.getSocket()
//
//    var pcDic:[String: RTCPeerConnection] = [:]
//
//
//    func joinRoom() {
//            print("[room] joinRoom [swift] @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@2")
//            let user = UserInfo.userInfo.getUserInfo()
//            let userData : [String: Any] = [
//                "id" : user!.id as Any,
//                "name" : user!.name as Any ,
//                "email" : user!.email as Any ,
//                "image" : user!.image as Any ,
//                "created_at" : user!.created_at as Any ,
//                "updated_at" : user!.updated_at as Any
//            ]
//
//            let data: [String: Any] = [
//                "room_id" : 1,
//                "user" : userData
//            ]
//            socket.emit("join_room", data)
//        }
//
//        func allUsers() {
//            socket.on("all_users") {data, ack in
//                print("[room] allUsers [swift] @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@")
//    //            print(type(of: data[0]))
//    //            print(data[0])
//
//                var users: [Any] = data[0] as! [NSDictionary]
//    //            var user: [String: Any] = users[0] as! [String : Any]
//                for var user in users {
////                    user = user as! [String: String, Int]
//                    print("allusers")
////                    self.peerConection()
//                    var userDictionary = user as! Dictionary<String, Any>
//                    print(userDictionary["sdp"])
//
////                    print(user[0])
//
////                    print(user["id"] as? String)
//                    self.pcSettings(id: userDictionary["id"] as! String)
//
//                }
//
//            }
//
//
//
//        }
//
//    func getOffer() {
//        socket.on("getOffer") {data, ack in
//
//        }
//    }
//
//    func getAnswer() {
//        socket.on("getAnswer") {data, ack in
//            print("getAnswer")
//            var getAnswerData = data[0] as! Dictionary<String, Any>
//            var sdpData = getAnswerData["sdp"] as! Dictionary<String, Any>
//
//            let peerConnection: RTCPeerConnection = self.pcDic[getAnswerData["answerSendID"] as! String]!
//
//
////            let remoteSdp = RTCSessionDescription( type: RTCSdpType.offer, sdp: getAnswerData[)
//            let remoteSdp = RTCSessionDescription( type: RTCSdpType.answer , sdp: sdpData["sdp"] as! String)
//
//            peerConnection.setRemoteDescription( remoteSdp, completionHandler: {(e:Error?) in
//
//                // 응답을 위한 answer sdp 생성하기
//                var mandatoryConstraints:[String:String] = [
//                    kRTCMediaConstraintsOfferToReceiveVideo: kRTCMediaConstraintsValueTrue,
//                    kRTCMediaConstraintsOfferToReceiveAudio: kRTCMediaConstraintsValueTrue
//                ]
//                let constraints = RTCMediaConstraints( mandatoryConstraints: mandatoryConstraints, optionalConstraints:nil )
//                peerConnection.answer( for: constraints, completionHandler: { (sdp:RTCSessionDescription?, e:Error?) in
//
//                    // 시그널링 서버를 통해 sdp 전달
//
//                    print(sdp)
//                    print(e)
//                })
//            })
//
//
//
////            let peerConnection: RTCPeerConnection = self.pcDic[
//        }
//    }
//
//
//
//
//
//
//    func pcSettings(id: String) {
//        // 인코더, 디코더 생성
//        var encoderFactory: RTCDefaultVideoEncoderFactory = RTCDefaultVideoEncoderFactory()
//        var decoderFactory: RTCDefaultVideoDecoderFactory = RTCDefaultVideoDecoderFactory()
//
//
//        // 인코더, 디코더를 사용해 PeerConnectionFactory 생성
//        var factory:RTCPeerConnectionFactory = RTCPeerConnectionFactory( encoderFactory:encoderFactory, decoderFactory: decoderFactory)
//
//        // Ice 서버정보 배열
//        let iceServers:[RTCIceServer]
//        iceServers = [RTCIceServer.init( urlStrings: ["stun:stun.l.google.com:19302"])]
//
//        // connection constraints
//        let constraints:RTCMediaConstraints
//
//        let options:[String:String] = ["DtlsSrtpKeyAgreement": kRTCMediaConstraintsValueTrue]
//
//        constraints = RTCMediaConstraints.init( mandatoryConstraints: nil, optionalConstraints: options )
//
//        let config = RTCConfiguration()
//        config.iceServers = iceServers
//        config.iceTransportPolicy = .all
//        config.rtcpMuxPolicy = .negotiate
//        config.continualGatheringPolicy = .gatherContinually
//        config.bundlePolicy = .maxBundle
//
//        var peerConnection:RTCPeerConnection
//
////        var delegate:RTCPeerConnectionDelegate
//
//        peerConnection = factory.peerConnection( with: config, constraints: constraints, delegate: nil)
//        let dataChannelConfig: RTCDataChannelConfiguration
//        dataChannelConfig = RTCDataChannelConfiguration()
//
////        let config: = RTCDataChannelCoinfiguration()
//        let dataChannel = peerConnection.dataChannel( forLabel: id, configuration: dataChannelConfig)
//
//        let rtcAudioSession = RTCAudioSession.sharedInstance()
//
//        rtcAudioSession.lockForConfiguration()
//        do {
//            try rtcAudioSession.setCategory( AVAudioSession.Category.playAndRecord.rawValue )
//            try rtcAudioSession.setMode( AVAudioSession.Mode.voiceChat.rawValue )
//        } catch let error {
//
//        }
//        rtcAudioSession.unlockForConfiguration()
//
//        print(peerConnection)
//        setOffer(peerConnection: peerConnection, id: id)
//
//    }
//    func setOffer(peerConnection: RTCPeerConnection, id: String) {
//        var mandatoryConstraints:[String:String] = [
//            kRTCMediaConstraintsOfferToReceiveVideo: kRTCMediaConstraintsValueTrue,
//            kRTCMediaConstraintsOfferToReceiveAudio: kRTCMediaConstraintsValueTrue
//        ]
//        let constraints = RTCMediaConstraints( mandatoryConstraints: mandatoryConstraints, optionalConstraints:nil)
//
//        // offer
//        peerConnection.offer( for: constraints, completionHandler: { (sdp:RTCSessionDescription?, e:Error?) in
//
//            guard let sdp = sdp else {
//                return
//            }
////            print(sdp.type)
////            print(sdp)
//
////            peerConnection.setLocalDescription(sdp)
//
//            peerConnection.setLocalDescription( sdp, completionHandler: { (error) in
//
//                    // 시그널링 서버를 통해 sdp 전달
//                    let sdpSetting: [String: Any] = [
//                        "type" : "offer",
//                        "sdp" : sdp.sdp
//                    ]
//
//                    let data: [String: Any] = [
//                        "sdp" : sdpSetting,
//                        "offerSendID" : self.socket.sid,
//                        "offerReceiveID" : id
//                    ]
//
//                    print("dd")
//
//                self.pcDic[id] = peerConnection
//
//                    self.socket.emit("offer", data)
//            })
//
//
//
////
////            let data: [String: Any] = [
////                "sdp" : sdp,
////                "offerSendID" : self.socket.sid,
////                "offerReceiveID" : id
////            ] as Dictionary
////
////            do {
//////                let dataJson = try JSONSerialization.data(withJSONObject: data, options: .prettyPrinted)
////                print("dd")
////                self.socket.emit("offer", data)
////            } catch {
////                print("error")
////            }
////
//
//
//
//        })
//    }
//
//
//
//
//    func dataChannelDidChangeState(_ dataChannel: RTCDataChannel ) {
//    }
//
//    func dataChannel(_ dataChannel: RTCDataChannel, didReceiveMessageWith buffer: RTCDataBuffer) {
//        print(buffer)
//        print(dataChannel)
//    }
//
    
    

    
//    var socket: SocketIOClient
//
//
//
//    var factory:RTCPeerConnectionFactory
//    var peerConnection:RTCPeerConnection
//
//
//    // encoder, decoder
//    var encoderFactory:RTCDefaultVideoEncoderFactory
//    var decoderFactory:RTCDefaultVideoDecoderFactory
//
//    // delegate
//    var delegate:RTCPeerConnectionDelegate
//
//    // 카메라 캡처
//    var localVideoCapturer:RTCCameraVideoCapturer
//    // var localVideoCapturer:RTCFileVideoCapturer
//
//    // 미디어 스트림
//    var localStream:RTCMediaStream
//
//    // 로컬 트랙
//    var localVideoTrack:RTCVideoTrack
//    var localAudioTrack:RTCAudioTrack
//
//    // 원격지 트랙
//    var remoteVideoTrack:RTCVideoTrack
//    var remoteAudioTrack:RTCAudioTrack
//
//    let iceServers:[RTCIceServer]
//

//    override init() {
//        socket = SocketIo.sharedInstance.getSocket()
//
//        encoderFactory = RTCDefaultVideoEncoderFactory()
//        decoderFactory = RTCDefaultVideoDecoderFactory()
//        factory = RTCPeerConnectionFactory( encoderFactory:encoderFactory, decoderFactory: decoderFactory)
//
//        iceServers = [RTCIceServer.init( urlStrings: ["stun:stun.l.google.com:19302"])]
//
//        let constraints = RTCMediaConstraints(mandatoryConstraints: nil,
//                                              optionalConstraints: ["DtlsSrtpKeyAgreement":kRTCMediaConstraintsValueTrue])
//
//        let config = RTCConfiguration()
//        config.iceServers = iceServers
//        config.iceTransportPolicy = .all
//        config.rtcpMuxPolicy = .negotiate
//        config.continualGatheringPolicy = .gatherContinually
//        config.bundlePolicy = .maxBundle
//
//        peerConnection = factory.peerConnection( with: config, constraints: constraints, delegate: delegate)
//    }
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
//    func joinRoom() {
//        print("[room] joinRoom [swift] @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@2")
//        let user = UserInfo.userInfo.getUserInfo()
//        let userData : [String: Any] = [
//            "id" : user!.id as Any,
//            "name" : user!.name as Any ,
//            "email" : user!.email as Any ,
//            "image" : user!.image as Any ,
//            "created_at" : user!.created_at as Any ,
//            "updated_at" : user!.updated_at as Any
//        ]
//        
//        let data: [String: Any] = [
//            "room_id" : 1,
//            "user" : userData
//        ]
//        socket.emit("join_room", data)
//    }
//    
//    func allUsers() {
//        socket.on("all_users") {data, ack in
//            print("[room] allUsers [swift] @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@")
////            print(type(of: data[0]))
////            print(data[0])
//            
//            var users: [Any] = data[0] as! [Any]
////            var user: [String: Any] = users[0] as! [String : Any]
//            for var user in users {
//                user = user as! [String: Any]
//                
//                
//            }
//            
//        }
//        
//        
//        
//    }
//    
//    
//    
//   
//    
//    
//    
//    
//    
//    
//    
//    
//    
//            
//}
