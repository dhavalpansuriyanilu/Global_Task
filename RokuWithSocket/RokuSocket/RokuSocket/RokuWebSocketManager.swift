
import Foundation
import CommonCrypto
import XMLMapper

class RokuWebSocketManager: NSObject, WebSocketDelegate{
    static let shared = RokuWebSocketManager()
    
    //MARK: - Variables
    private var socket: WebSocket!
    private var ipAddress = ""
    var isSocketConnect = false
    private var completion: ((Bool, [String: String]) -> ())?
    private var completionFetchApps: (([Apps]) -> ())?
    private var completionFetchIcon: ((Apps?) -> ())?
    private var deviceInfo: [String: String] = [:]
    private var currentApp: Apps?
    var maxTryToConnectToSocket = 3
    
    private override init(){
        
    }
    
    func configureRokuWebSocket(ip: String, completion: ((Bool, [String: String]) -> ())?){
        if self.ipAddress == ip && isSocketConnect{
            completion?(true, deviceInfo)
            return
        }else{
            if isSocketConnect{
                self.disconnectSocket()
            }
        }
        self.completion = completion
        var request = URLRequest(url: URL(string: "ws://\(ip):8060/ecp-session")!)
        request.timeoutInterval = 1
//        request.setValue("IOS", forHTTPHeaderField: "Sec-WebSocket-Origin")
        request.setValue("ecp-2", forHTTPHeaderField: "Sec-WebSocket-Protocol")
        
        socket = WebSocket(request: request)
        
        socket.delegate = self
        socket.connect()
    }
    
    func didReceive(event: WebSocketEvent, client: any WebSocketClient) {
        switch event {
        case .connected(_):
            self.maxTryToConnectToSocket = 3
            isSocketConnect = true
            print("Socket is connected")
        case .disconnected(let reason, let code):
            print("Socket is disconnected: \(reason) with code: \(code)")
            isSocketConnect = false
            self.callbackListner(status: false)
        case .text(let string):
            print("Received text: \(string)")
            self.handleStringMessage(msg: string)
        case .binary(let data):
            print("Received data: \(data.count)")
        case .ping(_):
            print("Ping started")
            break
        case .pong(_):
            print("Pong started")
            break
        case .viabilityChanged(_):
            print("viabilityChanged started")
            break
        case .reconnectSuggested(_):
            print("reconnectSuggested started")
            if self.socket != nil{
                self.socket.connect()
            }
            break
        case .cancelled:
            isSocketConnect = false
            self.callbackListner(status: false)
            print("Socket is Cancelled")
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1){
                if self.socket != nil{
                    self.socket.connect()
                }
            }
        case .error(let error):
            print("Socket is failed with:- \(error?.localizedDescription ?? "")")
            if ((error?.localizedDescription.lowercased().contains("socket is not connected")) != nil){
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1){
                    if self.maxTryToConnectToSocket == 0{
                        self.isSocketConnect = false
                        self.callbackListner(status: false)
                        self.disconnectSocket()
                        return
                    }else{
                        self.maxTryToConnectToSocket -= 1
                        if self.socket != nil{
                            self.socket.connect()
                        }
                    }
                }
            }else{
                self.isSocketConnect = false
                self.callbackListner(status: false)
                self.disconnectSocket()
            }
        case .peerClosed:
            print("Peer closed")
            break
        @unknown default:
            print("default")
            break
        }
    }
    
    func disconnectSocket(){
        if socket != nil{
            isSocketConnect = false
            socket.disconnect()
        }
    }
    
    private  func sendMessage(message: String?, completion: (() -> ())?){
        if isSocketConnect{
            if let value = message{
                socket?.write(string: value, completion: {
                    DispatchQueue.main.async {
                        completion?()
                    }
                })
            }
        }else{
            print("Device not connected. Please connect and try again")
        }
    }
}

extension RokuWebSocketManager{
    private  func callbackListner(status: Bool, value: [String: String] = [:]){
        if self.completion != nil{
            self.completion?(status, value)
        }
    }
    
    private func handleStringMessage(msg: String){
        guard let json = msg.toJson() else {
            return
        }
        
        if let val = json["notify"] as? String{
            if val == EventChecker.authenticate.rawValue{
                self.authenticateResponseReceived(json: json)
            }
        }else{
            if let val = json["response"] as? String, let status = json["status"] as? String, status == "200"{
                switch val {
                case EventChecker.authenticate.rawValue:
                    self.sendQueryDeviceInfoRequest()
                case EventChecker.query_device_info.rawValue:
                    guard let data = json["content-data"] as? String else {
                        return
                    }
                    self.callbackListner(status: true, value: convertXMLToDictionary(xmlString: data) ?? [:])
                case EventChecker.query_apps.rawValue:
                    guard let data = json["content-data"] as? String else {
                        return
                    }
                    do{
                        let xmlDictionary = try XMLSerialization.xmlObject(withString: data.decodeBase64()) as? [String: Any]
                        let appsData = XMLMapper<AppsList>().map(XMLObject: xmlDictionary)
                        self.completionFetchApps?(appsData?.app ?? [])
                        self.completionFetchApps = nil
                    }catch {
                        print("Serialization error occurred: \(error.localizedDescription)")
                    }
                case EventChecker.query_icon.rawValue:
                    guard let data = json["content-data"] as? String else {
                        return
                    }
                    let imgUrl = ImageManager.shared.saveImage(data.decodeBase64ToImageData(), withName: currentApp?.text ?? "\(Date())")
                    currentApp?.url = imgUrl
                    self.completionFetchIcon?(currentApp)
                default:
                    break
                }
            }
        }
    }
}

//MARK: -
//MARK:- RokuEvents manage
extension RokuWebSocketManager{
    private func authenticateResponseReceived(json: [String: Any]){
        guard let paramChallenge = json["param-challenge"] as? String else{
            return
        }
        let KEY = "F3A278B8-1C6F-44A9-9D89-F1979CA4C6F1"
        let paramChallengeWithKey = paramChallenge + KEY
        let hash = paramChallengeWithKey.sha1()
        let paramResponse = hash.base64EncodedString()

        let obj = ["param-response": paramResponse, "request": EventChecker.authenticate.rawValue, "request-id": Counter.increment()].toJsonString()
        self.sendMessage(message: obj) {
            
        }
    }
    
    private func sendQueryDeviceInfoRequest(){
        let obj = ["request": EventChecker.query_device_info.rawValue, "request-id": Counter.increment()].toJsonString()
        self.sendMessage(message: obj) {
            
        }
    }
    
    func sendButtonEvent(event: ButtonName){
        let obj = ["request": EventChecker.key_press.rawValue, "param-key": event.rawValue , "request-id": Counter.increment()].toJsonString()
        self.sendMessage(message: obj) {
            
        }
    }
    
    func longPressButtonEvent(event: ButtonName, isLongPress: Bool){
        let obj = ["request": isLongPress ? EventChecker.key_down.rawValue : EventChecker.key_up.rawValue, "param-key": event.rawValue, "request-id": Counter.increment()].toJsonString()
        self.sendMessage(message: obj) {
            
        }
    }
    
    func fetchAllApps(completionFetchApps: (([Apps]) -> ())?){
        let obj = ["request": EventChecker.query_apps.rawValue, "request-id": Counter.increment()].toJsonString()
        self.completionFetchApps = completionFetchApps
        self.sendMessage(message: obj) {
            
        }
    }
    
    func fetchAppIcons(app: Apps, completionFetchIcon: ((Apps?) -> ())?){
        if let imgUrl = ImageManager.shared.checkFileAvailable(withName: app.text ?? ""){
            self.currentApp = app
            self.currentApp?.url = imgUrl
            completionFetchIcon?(self.currentApp)
        }else{
            self.completionFetchIcon = completionFetchIcon
            self.currentApp = app
            let obj = ["request": EventChecker.query_icon.rawValue, "param-channel-id": app.id ?? "", "request-id": Counter.increment()].toJsonString()
            //        self.completionFetchApps = completionFetchApps
            self.sendMessage(message: obj) {
                
            }
        }
    }
    
    func openApp(id: String){
        let obj = ["request": EventChecker.launch.rawValue, "param-channel-id": id, "request-id": Counter.increment()].toJsonString()
        //        self.completionFetchApps = completionFetchApps
        self.sendMessage(message: obj) {
            
        }
    }
}


enum EventChecker: String{
    case authenticate = "authenticate"
    case query_device_info = "query-device-info"
    case key_press = "key-press"
    case key_up = "key-up"
    case key_down = "key-down"
    case query_apps = "query-apps"
    case query_icon = "query-icon"
    case launch = "launch"
}

enum ButtonName: String{
    case home = "Home"
    case enter = "Enter"
    case select = "Select"
    case up = "Up"
    case down = "Down"
    case left = "Left"
    case right = "Right"
    case back = "Back"
}

class Counter {
    private static var count = 0

    static func increment() -> String {
        count += 1
        return "\(count)"
    }
}

class XMLParserHandler: NSObject, XMLParserDelegate {
    var resultDict: [String: String] = [:]
    var currentElement: String = ""

    func parser(_ parser: XMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [String : String] = [:]) {
        currentElement = elementName
    }

    func parser(_ parser: XMLParser, foundCharacters string: String) {
        let trimmedString = string.trimmingCharacters(in: .whitespacesAndNewlines)
        if !trimmedString.isEmpty {
            resultDict[currentElement] = trimmedString
        }
    }
}

func convertXMLToDictionary(xmlString: String) -> [String: String]? {
    guard let data = xmlString.decodeBase64().data(using: .utf8) else { return nil }
    
    let parserDelegate = XMLParserHandler()
    let parser = XMLParser(data: data)
    parser.delegate = parserDelegate
    
    if parser.parse() {
        return parserDelegate.resultDict
    } else {
        return nil
    }
}

//MARK: - Apps Model
class AppsList: XMLMappable {
    var nodeName: String!
    
    var app: [Apps] = []
    var name: String?

    required init(map: XMLMap) {

    }
    init(){
        
    }
    func mapping(map: XMLMap) {
        app <- map["app"]
        name <- map["__name"]
    }
}


class Apps: XMLMappable {
    var nodeName: String!
    
    var id: String?
    var type: String?
    var subtype: String?
    var version: String?
    var name: String?
    var text: String?
    var url: URL?

    required init(map: XMLMap) {

    }
    init(){
        
    }
    func mapping(map: XMLMap) {
        id <- map["_id"]
        type <- map["_type"]
        subtype <- map["_subtype"]
        version <- map["_version"]
        name <- map["__name"]
        text <- map["__text"]
    }
}

//MARK: - Image Manager
class ImageManager {
    
    static let shared = ImageManager()
    private init() {
        
    }
    
    private var rokuAppsDirectory: URL {
        let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let rokuAppsDir = documentsDirectory.appendingPathComponent("rokuapps")
        
        if !FileManager.default.fileExists(atPath: rokuAppsDir.path) {
            do {
                try FileManager.default.createDirectory(at: rokuAppsDir, withIntermediateDirectories: true, attributes: nil)
            } catch {
                print("Error creating rokuapps directory: \(error)")
            }
        }
        
        return rokuAppsDir
    }
    
    // MARK: - Save Image
    func saveImage(_ imageData: Data?, withName name: String) -> URL? {
        let fileURL = rokuAppsDirectory.appendingPathComponent("\(name).jpg")
        
        if FileManager.default.fileExists(atPath: fileURL.path) {
            return fileURL
        }
                
        do {
            try imageData?.write(to: fileURL)
            print("Image saved successfully at: \(fileURL)")
            return fileURL
        } catch {
            print("Error saving image:", error)
            return nil
        }
    }
    
    func checkFileAvailable(withName name: String) -> URL? {
        let fileURL = rokuAppsDirectory.appendingPathComponent("\(name).jpg")
        
        if FileManager.default.fileExists(atPath: fileURL.path) {
            return fileURL
        }
        return nil
    }
    
    // MARK: - Get Image
    func getImage(named name: String) -> UIImage? {
        let fileURL = rokuAppsDirectory.appendingPathComponent("\(name).jpg")
        
        if FileManager.default.fileExists(atPath: fileURL.path) {
            return UIImage(contentsOfFile: fileURL.path)
        }
        
        return nil
    }
    
    // MARK: - Delete Image
    func deleteImage(named name: String) {
        let fileURL = rokuAppsDirectory.appendingPathComponent("\(name).jpg")
        
        if FileManager.default.fileExists(atPath: fileURL.path) {
            do {
                try FileManager.default.removeItem(at: fileURL)
                print("Image deleted successfully")
            } catch {
                print("Error deleting image:", error)
            }
        }
    }
    
    // MARK: - Delete Entire Directory
    func deleteDirectory() {
        let directoryURL = rokuAppsDirectory
        
        if FileManager.default.fileExists(atPath: directoryURL.path) {
            do {
                try FileManager.default.removeItem(at: directoryURL)
            } catch {
                print("Error deleting directory:", error)
            }
        } else {
            print("rokuapps directory does not exist")
        }
    }
}

extension String{
    func toJson()-> [String: Any]?{
        guard let jsonData = self.data(using: .utf8),
              let jsonDict = try? JSONSerialization.jsonObject(with: jsonData, options: []) as? [String: Any] else {
            print("Failed to parse JSON")
            return nil
        }
        return jsonDict
    }
    
    
    // MARK: - Utility Functions
    func sha1() -> Data {
        guard let data = self.data(using: .utf8) else { return Data() }
        var digest = [UInt8](repeating: 0, count: Int(CC_SHA1_DIGEST_LENGTH))
        
        data.withUnsafeBytes { bytes in
            _ = CC_SHA1(bytes.baseAddress, CC_LONG(data.count), &digest)
        }
        
        return Data(digest)
    }
    
    func decodeBase64() -> String {
        guard let data = Data(base64Encoded: self) else { return "" }
        return String(data: data, encoding: .utf8) ?? ""
    }

    func decodeBase64ToImageData() -> Data? {
        guard let data = Data(base64Encoded: self) else { return nil }
        return data
    }
}

extension Dictionary {
    func toJsonString() -> String? {
        if let jsonData = try? JSONSerialization.data(withJSONObject: self, options: []),
           let jsonString = String(data: jsonData, encoding: .utf8) {
            return jsonString
        }
        return nil
    }
}

