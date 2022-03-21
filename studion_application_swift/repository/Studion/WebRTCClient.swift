//
//  WebRTCClient.swift
//  studion_application_swift
//
//  Created by 김진홍 on 2022/03/21.
//

import Foundation
import WebRTC
import SocketIO

protocol WebRTCClientDelegate: AnyObject {
  func webRTCClient(_ client: WebRTCClient, didDiscoverLocalCandidate candidate: RTCIceCandidate)
  func webRTCClient(_ client: WebRTCClient, didChangeConnectionState state: RTCIceConnectionState)
  func webRTCClient(_ client: WebRTCClient, didReceiveData data: Data)
}

final class WebRTCClient: NSObject {
    
    private static let factory: RTCPeerConnectionFactory = {
      RTCInitializeSSL()
      let videoEncoderFactory = RTCDefaultVideoEncoderFactory()
      let videoDecoderFactory = RTCDefaultVideoDecoderFactory()
      return RTCPeerConnectionFactory(encoderFactory: videoEncoderFactory, decoderFactory: videoDecoderFactory)
    }()
    
    weak var delegate: WebRTCClientDelegate?
    private var peerConnection: RTCPeerConnection?
    private let rtcAudioSession =  RTCAudioSession.sharedInstance()
    private let audioQueue = DispatchQueue(label: "audio")
    private let mediaConstrains = [kRTCMediaConstraintsOfferToReceiveAudio: kRTCMediaConstraintsValueTrue,
                                   kRTCMediaConstraintsOfferToReceiveVideo: kRTCMediaConstraintsValueTrue]
    private var videoCapturer: RTCVideoCapturer?
    private var localVideoTrack: RTCVideoTrack?
    private var remoteVideoTrack: RTCVideoTrack?
    private var localDataChannel: RTCDataChannel?
    private var remoteDataChannel: RTCDataChannel?
    
    private var name: String?
    private var socketID: String?
    
    
    
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
    
    func allUsers() {
        socket.on("all_users") {data, ack in
            print("[room] allUsers")
            let users: [Any] = data[0] as! [NSDictionary]
            
            for user in users {
                let userDictionary = user as! Dictionary<String, Any>
                
                self.name = "1"
                self.socketID = userDictionary["id"] as? String
                
                self.createPeerConnection()
            }
            
        }
    }
    
    func createPeerConnection() {
        
        let iceServers:[RTCIceServer]
        iceServers = [RTCIceServer.init( urlStrings: ["stun:stun.l.google.com:19302"])]
        
        let config = RTCConfiguration()
        config.iceServers = iceServers
        config.sdpSemantics = .unifiedPlan
        
        // gatherContinually will let WebRTC to listen to any network changes and send any new candidates to the other client
        config.continualGatheringPolicy = .gatherContinually
        
        let constraints = RTCMediaConstraints(
          mandatoryConstraints: nil,
          optionalConstraints: ["DtlsSrtpKeyAgreement": kRTCMediaConstraintsValueTrue])
        self.peerConnection = WebRTCClient.factory.peerConnection(with: config, constraints: constraints, delegate: self)
        
        
        self.createMediaSenders()
        self.configureAudioSession()
        print("createPeerConnection end \(self.peerConnection)")
        
        self.offer() { data in
            print("offer end")
        }
        
        
    }
    
    func createMediaSenders() {
        let streamId = "stream"
        
        // Audio
        let audioTrack = self.createAudioTrack()
        self.peerConnection!.add(audioTrack, streamIds: [streamId])
        
        
        // Data
        if let dataChannel = createDataChannel() {
          dataChannel.delegate = self
          self.localDataChannel = dataChannel
        }
        
        print("createMediaSenders end")
    }
    
    func createDataChannel() -> RTCDataChannel?{
        let config = RTCDataChannelConfiguration()
        print("create data channel")
        guard let dataChannel = self.peerConnection!.dataChannel(forLabel: socketID!, configuration: config) else {
          debugPrint("Warning: Couldn't create data channel.")
          return nil
        }
        return dataChannel
    }
    
    
    func createAudioTrack() -> RTCAudioTrack {
        let audioConstrains = RTCMediaConstraints(mandatoryConstraints: nil, optionalConstraints: nil)
        let audioSource = WebRTCClient.factory.audioSource(with: audioConstrains)
        let audioTrack = WebRTCClient.factory.audioTrack(with: audioSource, trackId: "audio0")
        return audioTrack
    }
    
    func configureAudioSession() {
        self.rtcAudioSession.lockForConfiguration()
        do {
          try self.rtcAudioSession.setCategory(AVAudioSession.Category.playAndRecord.rawValue)
          try self.rtcAudioSession.setMode(AVAudioSession.Mode.voiceChat.rawValue)
        } catch let error {
          debugPrint("Error changeing AVAudioSession category: \(error)")
        }
        self.rtcAudioSession.unlockForConfiguration()
        
        print("configureAudioSession end")
    }
    
    
    func offer(completion: @escaping (_ sdp: RTCSessionDescription) -> Void) {
      let constrains = RTCMediaConstraints(
        mandatoryConstraints: self.mediaConstrains,
        optionalConstraints: nil)
      self.peerConnection!.offer(for: constrains) { (sdp, error) in
        guard let sdp = sdp else {
          return
        }
        
        self.peerConnection!.setLocalDescription(sdp, completionHandler: { (error) in
            
            
            let offerData: [String: Any] = [
                "type" : "offer",
                "sdp" : sdp.sdp
            ]
            
            let offer: [String: Any] = [
                "sdp" : offerData,
                "offerSendID" : self.socket.sid,
                "offerSendName" : self.name ,
                "offerReceiveID" : self.socketID
            ]
            
            self.socket.emit("offer", offer as! SocketData)
            
            completion(sdp)

        })
      }
    }
    
    func getAnswer() {
        self.socket.on("getAnswer") {data, ack in
            print("getAnswer")
            let answer = data[0] as! Dictionary<String, Any>
            let answerSDP = answer["sdp"] as! Dictionary<String, Any>
            
            let sdp: RTCSessionDescription = RTCSessionDescription(type: RTCSdpType.answer, sdp: answerSDP["sdp"] as! String)
            
            
            self.peerConnection!.setRemoteDescription(sdp) {data in
                print("daas")
            }
        }
    }
    
//    func set(remoteCandidate: RTCIceCandidate) {
//        print("set ice candidate")
//      self.peerConnection!.add(remoteCandidate)
//    }
//
    
    
}


extension WebRTCClient: RTCPeerConnectionDelegate {
  
  func peerConnection(_ peerConnection: RTCPeerConnection, didChange stateChanged: RTCSignalingState) {
//    debugPrint("peerConnection new signaling state: \(stateChanged)")
  }
  
  func peerConnection(_ peerConnection: RTCPeerConnection, didAdd stream: RTCMediaStream) {
//    debugPrint("peerConnection did add stream")
  }
  
  func peerConnection(_ peerConnection: RTCPeerConnection, didRemove stream: RTCMediaStream) {
//    debugPrint("peerConnection did remove stream")
  }
  
  func peerConnectionShouldNegotiate(_ peerConnection: RTCPeerConnection) {
//    debugPrint("peerConnection should negotiate")
  }
  
  func peerConnection(_ peerConnection: RTCPeerConnection, didChange newState: RTCIceConnectionState) {
    debugPrint("peerConnection new connection state: \(newState)")
    self.delegate?.webRTCClient(self, didChangeConnectionState: newState)
  }
  
  func peerConnection(_ peerConnection: RTCPeerConnection, didChange newState: RTCIceGatheringState) {
//    debugPrint("peerConnection new gathering state: \(newState)")
  }
  
  func peerConnection(_ peerConnection: RTCPeerConnection, didGenerate candidate: RTCIceCandidate) {
      print("peerConnection candidate ??11")
//      print(candidate)
      let sendCandidate: [String: Any] = [
        "candidate" : candidate.sdp,
        "sdpMid" : candidate.sdpMid,
        "sdpMLineIndex" : candidate.sdpMLineIndex
      ]
      
      let data: [String: Any] = [
        "candidate" : sendCandidate,
        "candidateSendID" : socket.sid,
        "candidateReceiveID" : socketID
      ]
      
      self.socket.emit("candidate", data)
      print("send")
      
      
//    self.delegate?.webRTCClient(self, didDiscoverLocalCandidate: candidate)
  }
  
  func peerConnection(_ peerConnection: RTCPeerConnection, didRemove candidates: [RTCIceCandidate]) {
//    debugPrint("peerConnection did remove candidate(s)")
  }
  
  func peerConnection(_ peerConnection: RTCPeerConnection, didOpen dataChannel: RTCDataChannel) {
    debugPrint("peerConnection did open data channel")
    self.remoteDataChannel = dataChannel
  }
}

extension WebRTCClient: RTCDataChannelDelegate {
  func dataChannelDidChangeState(_ dataChannel: RTCDataChannel) {
//    debugPrint("dataChannel did change state: \(dataChannel.readyState)")
  }
  
  func dataChannel(_ dataChannel: RTCDataChannel, didReceiveMessageWith buffer: RTCDataBuffer) {
      
      print("data channel ?? : \(buffer.data)")
      
      let decoder = JSONDecoder()
      
      do {
          let json = try decoder.decode(Drum.key.self, from: buffer.data)
          print(json)
      } catch {
          print("error")
      }
      self.delegate?.webRTCClient(self, didReceiveData: buffer.data)
  }
}
