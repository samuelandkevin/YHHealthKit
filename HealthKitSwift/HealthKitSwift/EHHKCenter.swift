//
//  EHHKCenter.swift
//  HealthKitSwift
//
//  Created by 黄坤鹏 on 2020/8/1.
//  Copyright © 2020 MOKO. All rights reserved.
//

import Foundation
import HealthKit
import HealthKitUI
///授权回调
enum HealthStorePermissionResponse:UInt {
    case error = 0
    case success
}
///授权回调
typealias HealthStorePermissionResponseBlock = (_ permissionResponse:HealthStorePermissionResponse) -> ()
class EHHealthKitCenter: NSObject {
    
    static let sharedCenter: EHHealthKitCenter = {
        let instance = EHHealthKitCenter()
        return instance
    }()
    
    fileprivate var sampleArr = [HKObject]()
    
    /// 保存在healthKit metadata的btt温度id
    let bbtTempID:String = "ID"
    var permissionResponseBlock:HealthStorePermissionResponseBlock?
    var store:HKHealthStore = HKHealthStore()
}


extension EHHealthKitCenter {
    
    // MARK: - 获取权限
    func requestHealthPermission(block:@escaping HealthStorePermissionResponseBlock) -> Void {
        if #available(iOS 8.0, *){
            if(!HKHealthStore.isHealthDataAvailable()){
                print("Skoal:该设备不支持HealthKit")
            }else{
                let store = HKHealthStore()
                let readObjectTypes:Set = self.readObjectTypes()
                let writeObjectTypes:Set = self.writeObjectTypes()
                store.requestAuthorization(toShare: (writeObjectTypes as! Set<HKSampleType>), read: readObjectTypes) { (success, error) in
                    if(success){
                        block(.success)
                    }else{
                        block(.error)
                    }
                }
            }
        }else{
            debugPrint("HealthKit暂不支持iOS8以下系统,请更新你的系统。")
        }
    }
    
    //---------------------------------------
    // MARK:权限集合
    //---------------------------------------
    //读权限集合
    func readObjectTypes() -> Set<HKObjectType> {
        let height = HKObjectType.quantityType(forIdentifier: .height)                     //身高
        let bodyMass = HKObjectType.quantityType(forIdentifier: .bodyMass)                 //体重
        let bodyMassIndex = HKObjectType.quantityType(forIdentifier: .bodyMassIndex)       //身体质量指数
        let bodyTemperature = HKObjectType.quantityType(forIdentifier: .bodyTemperature)   //体温
        let biologicalSex = HKObjectType.characteristicType(forIdentifier: .biologicalSex) //性别
        let bloodType = HKObjectType.characteristicType(forIdentifier: .bloodType)//血型
        let menstrualFlow = HKObjectType.categoryType(forIdentifier: .menstrualFlow)//月经
        let intermenstrualBleeding = HKObjectType.categoryType(forIdentifier: .intermenstrualBleeding)//点滴出血
        let sexualActivity = HKObjectType.categoryType(forIdentifier: .sexualActivity)//性行为
        let cervicalMucusQuality = HKObjectType.categoryType(forIdentifier: .cervicalMucusQuality)
        let ovulationTestResult = HKObjectType.categoryType(forIdentifier: .ovulationTestResult)
        
        let set:Set<HKObjectType> = [
            height!,
            bodyMass!,
            bodyMassIndex!,
            bodyTemperature!,
            biologicalSex!,
            bloodType!,
            menstrualFlow!,
            intermenstrualBleeding!,
            sexualActivity!,
            cervicalMucusQuality!,
            ovulationTestResult!
        ]
        return set
    }
    
    //写权限集合
    func writeObjectTypes() -> Set<HKObjectType> {
        let height = HKObjectType.quantityType(forIdentifier: .height)                     //身高
        let bodyMass = HKObjectType.quantityType(forIdentifier: .bodyMass)                 //体重
        let bodyMassIndex = HKObjectType.quantityType(forIdentifier: .bodyMassIndex)       //身体质量指数
        let bodyTemperature = HKObjectType.quantityType(forIdentifier: .bodyTemperature)   //体温
        let biologicalSex = HKObjectType.characteristicType(forIdentifier: .biologicalSex) //性别
        let bloodType = HKObjectType.characteristicType(forIdentifier: .bloodType)//血型
        let menstrualFlow = HKObjectType.categoryType(forIdentifier: .menstrualFlow)//月经
        let intermenstrualBleeding = HKObjectType.categoryType(forIdentifier: .intermenstrualBleeding)//点滴出血
        let sexualActivity = HKObjectType.categoryType(forIdentifier: .sexualActivity)//性行为
        let cervicalMucusQuality = HKObjectType.categoryType(forIdentifier: .cervicalMucusQuality)
        let ovulationTestResult = HKObjectType.categoryType(forIdentifier: .ovulationTestResult)
        
        let set:Set<HKObjectType> = [
            height!,
            bodyMass!,
            bodyMassIndex!,
            bodyTemperature!,
            biologicalSex!,
            bloodType!,
            menstrualFlow!,
            intermenstrualBleeding!,
            sexualActivity!,
            cervicalMucusQuality!,
            ovulationTestResult!
        ]
        return set
    }
    
    
    //MARK: -  BodyTemperature(体温)
    /// 从HK读取bbt温度
    func readBodyTemperatureFromHealthStore(completion:@escaping (_ value:Double,_ error:Error?) -> Void) -> Void {
        let bodyTemperatureType = HKSampleType.quantityType(forIdentifier: .bodyTemperature)
        let startSort = NSSortDescriptor(key: HKSampleSortIdentifierStartDate, ascending: false)
        let endSort = NSSortDescriptor(key: HKSampleSortIdentifierEndDate, ascending: false)
        let predicate = self.predicateSampleByLatestData()
        let query = HKSampleQuery(sampleType: bodyTemperatureType!, predicate: predicate, limit: 0, sortDescriptors: [startSort,endSort]) { (query, results, error) in
            if (results?.count)! > 0{
                let bodyTemperature = Double((String.init(format: "%@", (results?.first)!)).components(separatedBy: " ")[0])!
                completion(bodyTemperature, error)
            }else{
                completion(0, error)
            }
        }
        self.store.execute(query)
    }
    
    /// 写入bbt温度到HK
    func writeBodyTemperatureToHealthStore(bodyTemperature:Double,completion:@escaping (_ response:Bool,_ error:Error?) -> Void) -> Void {
        let bodyTemperatureType = HKSampleType.quantityType(forIdentifier: .bodyTemperature)
        let quantity = HKQuantity.init(unit: HKUnit.degreeCelsius(), doubleValue: bodyTemperature)
        let sample = HKQuantitySample(type: bodyTemperatureType!, quantity: quantity, start: Date(), end: Date(), metadata: nil)
        self.store.save(sample) { (success, error) in
            if(success){
                completion(true, error)
            }else{
                completion(false, error)
            }
        }
    }
    
    
    //MARK: -  MenstrualFlow(月经)
    /// 从HK读取月经
    func readMenstrualFlowFromHealthStore(completion:@escaping (_ value:Double?,_ error:Error?) -> Void) -> Void {
        let type = HKObjectType.categoryType(forIdentifier: .menstrualFlow)
        let startSort = NSSortDescriptor(key: HKSampleSortIdentifierStartDate, ascending: false)
        let endSort = NSSortDescriptor(key: HKSampleSortIdentifierEndDate, ascending: false)
        let predicate = self.predicateSampleByLatestData()
        let query = HKSampleQuery(sampleType: type!, predicate: predicate, limit: 0, sortDescriptors: [startSort,endSort]) { (query, results, error) in
            if(error != nil){
                completion(nil, error!)
            }else{
                if (results?.count)! > 0{
                    for o in results!{
                        self._print(obj: o)
                    }
                    let menstrualFlow = Double((String.init(format: "%@", (results?.first)!)).components(separatedBy: " ")[0])!
                    completion(menstrualFlow, error)
                }else{
                    completion(0, error)
                }
            }
        }
        self.store.execute(query)
    }
    
    
    //MARK: -  IntermenstrualBleeding(点滴出血)
    /// 从HK读取点滴出血
    func readIntermenstrualBleedingFromHealthStore(completion:@escaping (_ value:Double?,_ error:Error?) -> Void) -> Void {
        let type = HKObjectType.categoryType(forIdentifier: .intermenstrualBleeding)
        let startSort = NSSortDescriptor(key: HKSampleSortIdentifierStartDate, ascending: false)
        let endSort = NSSortDescriptor(key: HKSampleSortIdentifierEndDate, ascending: false)
        let predicate = self.predicateSampleByLatestData()
        let query = HKSampleQuery(sampleType: type!, predicate: predicate, limit: 0, sortDescriptors: [startSort,endSort]) { (query, results, error) in
            if(error != nil){
                completion(nil, error!)
            }else{
                if (results?.count)! > 0{
                    for o in results!{
                        self._print(obj: o)
                    }
                    let menstrualFlow = Double((String.init(format: "%@", (results?.first)!)).components(separatedBy: " ")[0])!
                    completion(menstrualFlow, error)
                }else{
                    completion(0, error)
                }
            }
        }
        self.store.execute(query)
    }
    
    //MARK: -  cervicalMucusQuality(宫颈黏液质量)
    /// 从HK读取宫颈黏液质量
    func readCervicalMucusQualityFromHealthStore(completion:@escaping (_ value:Double?,_ error:Error?) -> Void) -> Void {
        let type = HKObjectType.categoryType(forIdentifier: .cervicalMucusQuality)
        let startSort = NSSortDescriptor(key: HKSampleSortIdentifierStartDate, ascending: false)
        let endSort = NSSortDescriptor(key: HKSampleSortIdentifierEndDate, ascending: false)
        let predicate = self.predicateSampleByLatestData()
        let query = HKSampleQuery(sampleType: type!, predicate: predicate, limit: 0, sortDescriptors: [startSort,endSort]) { (query, results, error) in
            if(error != nil){
                completion(nil, error!)
            }else{
                if (results?.count)! > 0{
                    for o in results!{
                        self._print(obj: o)
                    }
                    let menstrualFlow = Double((String.init(format: "%@", (results?.first)!)).components(separatedBy: " ")[0])!
                    completion(menstrualFlow, error)
                }else{
                    completion(0, error)
                }
            }
        }
        self.store.execute(query)
    }
    
    /// 宫颈黏液质量写入到HK
    func writeBCervicalMucusQualityToHealthStore(cervicalMucusQuality:Int,completion:@escaping (_ response:Bool,_ error:Error?) -> Void) -> Void {

        let type = HKCategoryType.categoryType(forIdentifier: .cervicalMucusQuality)
        let sample = HKCategorySample(type: type!, value: cervicalMucusQuality, start: Date(), end:  Date(), metadata: nil)
        self.store.save(sample) { (success, error) in
            if(success){
                completion(true, error)
            }else{
                completion(false, error)
            }
        }
    }
    
    
    // MARK: - ovulationTestResult(排卵测试结果)
    /// 从HK读取排卵测试结果
    func readOvulationTestResultFromHealthStore(completion:@escaping (_ value:Double?,_ error:Error?) -> Void) -> Void {
        let type = HKObjectType.categoryType(forIdentifier: .ovulationTestResult)
        let startSort = NSSortDescriptor(key: HKSampleSortIdentifierStartDate, ascending: false)
        let endSort = NSSortDescriptor(key: HKSampleSortIdentifierEndDate, ascending: false)
        let predicate = self.predicateSampleByLatestData()
        let query = HKSampleQuery(sampleType: type!, predicate: predicate, limit: 0, sortDescriptors: [startSort,endSort]) { (query, results, error) in
            if(error != nil){
                completion(nil, error!)
            }else{
                if (results?.count)! > 0{
                    for o in results!{
                        self._print(obj: o)
                    }
                    let menstrualFlow = Double((String.init(format: "%@", (results?.first)!)).components(separatedBy: " ")[0])!
                    completion(menstrualFlow, error)
                }else{
                    completion(0, error)
                }
            }
        }
        self.store.execute(query)
    }
    
    /// 排卵测试结果写入到HK  ovulationTestResult: 1:弱阴 2:强阳 3:不确定 4:高
    func writeOvulationTestResultToHealthStore(ovulationTestResult:Int,completion:@escaping (_ response:Bool,_ error:Error?) -> Void) -> Void {
        let type = HKCategoryType.categoryType(forIdentifier: .ovulationTestResult)
        let sample = HKCategorySample(type: type!, value: ovulationTestResult, start: Date(), end:  Date(), metadata: nil)
        self.store.save(sample) { (success, error) in
            if(success){
                completion(true, error)
            }else{
                completion(false, error)
            }
        }
    }
    
    
    //MARK SexualActivity(性行为)
    func readSexualActivityFromHealthStore(completion:@escaping (_ value:Double?,_ error:Error?) -> Void) -> Void {
        let type = HKObjectType.categoryType(forIdentifier: .sexualActivity)
        let startSort = NSSortDescriptor.init(key: HKSampleSortIdentifierStartDate, ascending: false)
        let endSort = NSSortDescriptor.init(key: HKSampleSortIdentifierEndDate, ascending: false)
        let predicate = self.predicateSampleByLatestData()
        let query = HKSampleQuery.init(sampleType: type!, predicate: predicate, limit: 0, sortDescriptors: [startSort,endSort]) { (query, results, error) in
            if(error != nil){
                completion(nil, error!)
            }else{
                if (results?.count)! > 0{
                    for o in results!{
                        self._print(obj: o)
                    }
                   
                    let sexualActivity = Double((String.init(format: "%@", (results?.first)!)).components(separatedBy: " ")[0])!
                    completion(sexualActivity, error)
                }else{
                    completion(0, error)
                }
            }
        }
        self.store.execute(query)
    }
    
    //MARK: -  BBT
    /// 从HK读取bbt温度
    func readBBTFromHealthStore(completion:@escaping (_ value:Double,_ error:Error?) -> Void) -> Void {
//        let bodyTemperatureType = HKSampleType.quantityType(forIdentifier: .basalBodyTemperature)
//        let startSort = NSSortDescriptor(key: HKSampleSortIdentifierStartDate, ascending: false)
//        let endSort = NSSortDescriptor(key: HKSampleSortIdentifierEndDate, ascending: false)
//        let predicate = self.predicateSampleByLatestData()
//        let query = HKSampleQuery(sampleType: bodyTemperatureType!, predicate: predicate, limit: 0, sortDescriptors: [startSort,endSort]) { (query, results, error) in
//            if let r = results, r.count > 0{
//                for o in r{
//                    self._print(obj: o)
//                }
//                let bodyTemperature = Double((String.init(format: "%@", (r.first)!)).components(separatedBy: " ")[0])!
//                completion(bodyTemperature, error)
//            }else{
//                completion(0, error)
//            }
//        }
        
        guard let bundleId = Bundle.main.bundleIdentifier else {
            return
        }
        guard let sampleType = HKQuantityType.quantityType(forIdentifier: .basalBodyTemperature) else {
            return
        }
        
        let timeSortDescriptor = NSSortDescriptor(key: HKSampleSortIdentifierEndDate, ascending: false)
        let query = HKSampleQuery(sampleType: sampleType,
                                  predicate: nil,
                                  limit: HKObjectQueryNoLimit,
                                  sortDescriptors: [timeSortDescriptor]) { (_, results, error) in
                                    if error == nil ,let results = results as? [HKQuantitySample]{
                                        var retArr = [Double]()
                                        for sample in results {
                                            let bbtQuantity = (sample as? HKQuantitySample)!.quantity
                                            let bbt = bbtQuantity.doubleValue(for: HKUnit.degreeFahrenheit())
                                            retArr.append(bbt)
                                        }
                                        print("BBT: \(retArr)")
                                        completion(Double(retArr.count),error)
                                    }else{
                                        completion(0,error)
                                    }
        }
        self.store.execute(query)
        
        
        
    }
    
    /// 写入bbt温度到HK
    func writeBBTToHealthStore(bodyTemperature:Double,completion:@escaping (_ response:Bool,_ error:Error?) -> Void) -> Void {
        let bodyTemperatureType = HKSampleType.quantityType(forIdentifier: .basalBodyTemperature)
        let quantity = HKQuantity.init(unit: HKUnit.degreeCelsius(), doubleValue: bodyTemperature)
        let sample = HKQuantitySample(type: bodyTemperatureType!, quantity: quantity, start: Date(), end: Date(), metadata: nil)
        self.store.save(sample) { (success, error) in
            if(success){
                completion(true, error)
            }else{
                completion(false, error)
            }
        }
    }
    
    
    //MARK: predicate
    /// predicate sample is the latest data(谓词样本为最新数据)
    func predicateSampleByLatestData() -> NSPredicate {
        let calendar = NSCalendar.current
        let dateNow = Date()
        let set:Set<Calendar.Component> = [Calendar.Component.year,Calendar.Component.month,Calendar.Component.day]
        var components = calendar.dateComponents(set, from: dateNow)
        components.hour = 0
        components.minute = 0
        components.second = 0
        let startDate = calendar.date(from: components)
        let endDate = calendar.date(byAdding: Calendar.Component.day, value: 1, to: startDate!)
        let predicate = HKQuery.predicateForSamples(withStart: nil, end: endDate, options: HKQueryOptions.init(rawValue: 0))
        return predicate
    }
    
    /// predicate sample is time period data(谓词样本为时间段数据)
    func predicateSampleByPeriodOfTimeWithStartTime(startTime:String, endTime:String) -> NSPredicate {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm"
        formatter.locale = Locale.init(identifier: "zh_CN")
        let tmpStartTime = formatter.date(from: startTime)
        let tmpEndTime = formatter.date(from: endTime)
        let predicate = HKQuery.predicateForSamples(withStart: tmpStartTime, end: tmpEndTime, options: HKQueryOptions.init(rawValue: 0))
        return predicate
    }
    
    
}

extension EHHealthKitCenter {
    //kun调试
    func _print(obj:HKSample){
        // uuid
        let uuid = obj.uuid
        // sourceRevision
        let sourceRevision = obj.sourceRevision
        // device
        let device = obj.device
        // metadata
        let metadata = obj.metadata
        // sampleType
        let sampleType = obj.sampleType
        // startDate
        let startDate = obj.startDate
        // endDate
        let endDate = obj.endDate
        
        var value = ""
        if let categorySample = obj as? HKCategorySample {
            value = "\(categorySample.value)"
        }
        //        //bid
        //        let bundleIdentifier = obj.sourceRevision.source.bundleIdentifier
        //        //flo
        //        let name = obj.sourceRevision.source.name
        //        //用户输入
        //        let HKWasUserEntered = obj.metadata?["HKWasUserEntered"]
        
        let json:[String:Any] = ["value":value,"uuid":uuid,"sourceRevision":sourceRevision,"device":device ?? [:],"metadata":metadata ?? [:],"sampleType":sampleType,"startDate":startDate,"endDate":endDate]
        
        debugPrint(json)
        
        
        
        // 苹果健康app bundleid：com.apple.Health
        
        /*
        //  性行为key说明：
        //  HKWasUserEntered:1
        //  HKSexualActivityProtectionUsed  1:使用保护措施   0:未使用保护措施  HKSexualActivityProtectionUsed 不存在就是未指明
        */
        
        /*
        // 点滴出血
        // HKWasUserEntered:1  就是出血
        */
        
        /*
        // 月经 HKCategoryTypeIdentifierMenstrualFlow
        // 经期开始 -> HKMenstrualCycleStart:1
        // 出血量-> key是"value"
        // value值说明,value返回值可能是（1，2，3，4，5） 1:出血量未指明 2:量少 3:中等 4:量多 5:未出血
        */
 
        /*
        // 宫颈黏液质量  HKCategoryTypeIdentifierCervicalMucusQuality
        // key是"value"
        // value值说明,value返回值可能是（1，2，3，4，5） 1:发干 2:稠厚 3:乳液状 4:水状 5:蛋清状态
        */
        
        /*
        // 排卵测试结果 HKCategoryTypeIdentifierOvulationTestResult
        // key是"value"，value返回值可能是（1，2，3，4） 1:弱阴 2:强阳 3:不确定 4:高
        */
    }
    
    
    func requestBBTAuthorization() {
        if #available(iOS 9.0, *), HKHealthStore.isHealthDataAvailable() {
            let bbtType = HKObjectType.quantityType(forIdentifier: .basalBodyTemperature)
            let status = bbtType!.requiresPerObjectAuthorization()
//            let status: HKAuthorizationStatus = HKHealthStore().authorizationStatus(for: bbtType!)
            print("status: \(status)")
            let shareSet: Set<HKSampleType> = [
                
            ]
            let readSet: Set<HKObjectType> = [
                bbtType!
            ]
            if #available(iOS 12.0, *) {
                HKHealthStore().getRequestStatusForAuthorization(toShare: shareSet, read: readSet) { status, error in
                    print("status: \(status), error: \(error)")
                }
            } else {
                // Fallback on earlier versions
            }
          
        }
    }
}


