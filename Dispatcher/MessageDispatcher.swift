//
//  MessageDispatcher.swift
//  POS
//
//  Created by Gal Blank on 1/15/16.
//

import UIKit

class MessageDispatcher: NSObject {
    
    fileprivate lazy var dispatchOnce: () -> Void = {
        DispatchQueue.main.async(execute: { () -> Void in
            if self.dispsatchTimer == nil {
                self.startDispatching()
            }
        })
        return {}
    }()
    
    @objc static let sharedDispacherInstance = MessageDispatcher()
    
    var dispsatchTimer:Timer?
    var messageBus         = [Message]()
    var dispatchedMessages = [Message]()
    
    struct Static {
        static var token: Int = 0
    }
    
    @objc func consumeMessage(_ notif:Foundation.Notification) {
        let msg:Message = notif.userInfo!["message"] as! Message
        switch(msg.routingKey){
        case "msg.selfdestruct":
            if let index = messageBus.index(of: msg) {
                if(index >= 0){
                    messageBus.remove(at: index)
                }
            }
            break
        default:
            break
        }
    }
    
    @objc func addMessageToBus(_ newmessage: Message) {
        
        DispatchQueue.main.async {
            if(newmessage.shouldselfdestruct == false && newmessage.routingKey.caseInsensitiveCompare("msg.selfdestruct") == ComparisonResult.orderedSame) {
                if let index = self.messageBus.index(of: newmessage) {
                    if(index >= 0 ) {
                        self.messageBus.remove(at: index)
                    }
                }
            }
            self.messageBus.append(newmessage)
            self.dispatchOnce()
        }
    }
    
    func clearDispastchedMessages() {
        
        DispatchQueue.main.async {
            for msg:Message in self.dispatchedMessages {
                if let index = self.messageBus.index(of: msg) {
                    if(index >= 0) {
                        self.messageBus.remove(at: index)
                    }
                }
            }
            self.dispatchedMessages.removeAll()
        }
    }
    
    
    func startDispatching() {
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(MessageDispatcher.consumeMessage(_:)),
                                               name: NSNotification.Name(rawValue: "msg.selfdestruct"), object: nil)
        
        dispsatchTimer = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(MessageDispatcher.leave), userInfo: nil, repeats: true)
    }
    
    func stopDispathing() {
        if dispsatchTimer != nil {
            dispsatchTimer!.invalidate()
            dispsatchTimer = nil
        }
    }
    
    @objc func leave() {
        DispatchQueue.main.async {
            let goingAwayBus = NSArray(array: self.messageBus) as! [Message]
            
            for msg: Message in goingAwayBus {
                if(msg.shouldselfdestruct == false) {
                    self.dispatchMessage(msg)
                    msg.shouldselfdestruct = true
                    
                    if let index = self.messageBus.index(of: msg) {
                        if(index != NSNotFound) {
                            self.messageBus.remove(at: index)
                        }
                    }
                }
            }
        }
    }
    
    func dispatchMessage(_ message: Message) {
        
        var messageDic = [AnyHashable: Any]()
        
        if message.routeFromRoutingKey().caseInsensitiveCompare("api") == ComparisonResult.orderedSame {
            MessageApiConverter.sharedInstance.messageTypeToApiCall(message)
        }
        
        messageDic["message"] = message
        NotificationCenter.default.post(name: Notification.Name(rawValue: message.routingKey), object: nil, userInfo: messageDic)
    }
    
    func routeMessageToServerWithType(_ message: Message) {
        
        if message.params == nil {
            message.params? = [AnyHashable: Any]() as AnyObject
        }
        
        if let sectoken = UserDefaults.standard.object(forKey: "securitytoken") as? String {
            if sectoken.lengthOfBytes(using: String.Encoding.utf8) > 0 {
                message.params?.set(sectoken, forKey: "securitytoken")
            }
        }
    }
    
    func canSendMessage(_ message: Message) -> Bool {
        return true
    }
}
