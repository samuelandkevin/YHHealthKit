import UIKit
class EHAlertController: UIAlertController {
    
    typealias EHAlertAction = (title: String?, handler: ((UIAlertAction) -> Void)?)
    ///  普通弹窗
    public class func showAlert(currentVC:UIViewController, title: String?,
                                message: String?,
                                isLeftAlignment: Bool = false,
                                confirmActions: [EHAlertAction],
                                cancelAction: EHAlertAction?) {
        let alertC = EHAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.alert)
        if isLeftAlignment {
            let messageAtt: NSMutableAttributedString = NSMutableAttributedString(string: message!)
            let paraStyle = NSMutableParagraphStyle()
            paraStyle.alignment = .left
            messageAtt.addAttributes([NSAttributedStringKey.paragraphStyle: paraStyle,
                                      NSAttributedStringKey.font: UIFont.systemFont(ofSize: 15)],
                                     range: NSRange(location: 0, length: message!.count))
            alertC.setValue(messageAtt, forKey: "attributedMessage")
        }
        for confirmAction in confirmActions {
            let confirmAct = UIAlertAction(title: confirmAction.title,
                                           style: UIAlertActionStyle.default,
                                           handler: confirmAction.handler)
            alertC.addAction(confirmAct)
        }
        if cancelAction?.handler != nil {
            let cancelAct = UIAlertAction(title: cancelAction?.title,
                                          style: UIAlertActionStyle.default,
                                          handler: cancelAction?.handler)
            alertC.addAction(cancelAct)
        }
        
        DispatchQueue.main.async {
            //  判断 “是否是重复弹窗” 的代码必须和 present 放在同一个线程里
            //  否则多线程运行问题可能造成 “无法避免重复弹窗”
            //  避免重复弹出同一个弹窗
            
          
            currentVC.present(alertC, animated: true, completion: nil)
        }
    }
    
   
    
}
