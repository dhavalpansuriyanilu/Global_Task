import OSLog

class Logs{
    private static let osLog = Logger()
    static func printLog(type: LogType = .other, message: String){
        if AppConfigurable.isLogEnabled{
            switch type {
            case .Error:
                osLog.error("\(message)")
            case .Critical:
                osLog.critical("\(message)")
            case .other:
                osLog.info("\(message)")
            }
        }
    }
}

enum LogType{
    case Error
    case Critical
    case other
}
