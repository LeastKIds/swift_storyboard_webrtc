
const pc_config = {
    iceServers: [
        {
            urls: 'stun:stun.l.google.com:19302',
        },
    ],
}

let pcDic = {}
let dcDic = {}




function changeColor(data) {
    console.log(2)
    return data
}

function sendMessage() {
    window.webkit.messageHandlers.success.postMessage('ok')
}


 function createPeerConnection(socketIOId_my, socketIOId, name) {
     try {
        const pc = new RTCPeerConnection(pc_config)
        pc.onicecandidate = (e) => {
            if (!(e.candidate)) return
            const data = {
                "candidate": e.candidate,
                "candidateSendID": socketIOId_my,
                "candidateReceiveID": socketIOId
            }

            const sendData = {
                "type" : "onicecandidate",
                "data" : data
            }

            window.webkit.messageHandlers.success.postMessage(sendData)
        }


        pc.oniceconnectionstatechange = (e) => {
            // console.log('on ice connections state change', e)
        }

        pc.ontrack = (e) => {
            // if (!mixerRef.current) return
            // new Channel(name, socketId, e.streams[0], mixerRef.current)
            // dispatch(roomSlice.actions.addUser({ id: socketId, name }))
            console.log('pc ontrack')
        }

        pc.ondatachannel = (e) => {
            console.log('datachannel event:', e);
            if (e.type === 'datachannel') {
                initDataChannel(e.channel);
                // dcsRef.current = { ...dcsRef.current, [e.channel.label]: e.channel }

            }
        }


        const dc = openDataChannel(pc, socketIOId_my)


        // const localSdp = await pc.createOffer({
        //     offerToReceiveAudio: true,
        //     offerToReceiveVideo: false,
        // })

        pc.createOffer({
            offerToReceiveAudio: true,
            offerToReceiveVideo: false,
        }).then( localSdp => {

                pc.setLocalDescription(new RTCSessionDescription(localSdp)).then( () => {
                    pcDic[socketIOId] = pc
                    dcDic[socketIOId] = dc

                    const offer = {
                        "sdp" : localSdp,
                        "offerSendID" : socketIOId_my,
                        "offerSendName" : name,
                        "offerReceiveID" : socketIOId
                    }

                    const offerData = {
                        "type" : "offer",
                        "data" : offer
                    }

                    window.webkit.messageHandlers.success.postMessage(offerData)

                    // return offer
                    // return 11
                })

            })


        // console.log('create offer success')






    } catch (e) {
        console.log(e)
    }
}

const initDataChannel = (dc) => {
    dc.onerror = (err) => {
        console.error('datachannel error:', err);
    }

    dc.onmessage = (e) => {
        console.log(e.data)
        window.webkit.messageHandlers.dataChannel.postMessage(e.data)
    }

    dc.onopen = (e) => {
        // console.log('dc is opened', e);
    }

    dc.onclose = (e) => {
        // console.log('dc is disconnected', e);
    }

    return dc
}

const openDataChannel = (pc, socketIOId_my) => {
    // console.log('try to open datachannel');
    try {
        let dc = pc.createDataChannel(`${socketIOId_my}`);
        return initDataChannel(dc)
    } catch (err) {
        console.error('open datachannel error:', err);
    }
}

function getAnswer(answer) {
    return answer
}