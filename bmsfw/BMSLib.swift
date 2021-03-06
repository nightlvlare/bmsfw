//
//  BMSLib.swift
//  TestBMSRTCLib
//
//  Created by Admin on 3/13/2560 BE.
//  Copyright © 2560 Admin. All rights reserved.
//

import Foundation
import BMSRTCLib







extension Double {
    /// Rounds the double to decimal places value
    func roundTo(_ places:Int) -> Double {
        let divisor = pow(10.0, Double(places))
        return (self * divisor).rounded() / divisor
    }
}

open class StringMisc {
    
    // MARK: - Constants
    
    // This is used by the byteArrayToHexString() method
    fileprivate static let CHexLookup : [Character] =
        [ "0", "1", "2", "3", "4", "5", "6", "7", "8", "9", "A", "B", "C", "D", "E", "F" ]
    
    
    // Mark: - Public methods
    
    /// Method to convert a byte array into a string containing hex characters, without any
    /// additional formatting.
    open static func byteArrayToHexString(_ byteArray : [UInt8]) -> String {
        
        var stringToReturn = ""
        
        for oneByte in byteArray {
            let asInt = Int(oneByte)
            stringToReturn.append(StringMisc.CHexLookup[asInt >> 4])
            stringToReturn.append(StringMisc.CHexLookup[asInt & 0x0f])
        }
        return stringToReturn
    }
}

extension Data {
    
    // From http://stackoverflow.com/a/40278391:
    init?(fromHexEncodedString string: String) {
        
        // Convert 0 ... 9, a ... f, A ...F to their decimal value,
        // return nil for all other input characters
        func decodeNibble(u: UInt16) -> UInt8? {
            switch(u) {
            case 0x30 ... 0x39:
                return UInt8(u - 0x30)
            case 0x41 ... 0x46:
                return UInt8(u - 0x41 + 10)
            case 0x61 ... 0x66:
                return UInt8(u - 0x61 + 10)
            default:
                return nil
            }
        }
        
        self.init(capacity: string.utf16.count/2)
        var even = true
        var byte: UInt8 = 0
        for c in string.utf16 {
            guard let val = decodeNibble(u: c) else { return nil }
            if even {
                byte = val << 4
            } else {
                byte += val
                self.append(byte)
            }
            even = !even
        }
        guard even else { return nil }
    }
}


extension Data {
    func hexEncodedString() -> String {
        return map { String(format: "%02hhx", $0) }.joined();
    }
}


enum DataSetState : Int {
    case dsInactive, dsBrowse, dsEdit, dsInsert, dsSetKey,
    dsCalcFields, dsFilter, dsNewValue, dsOldValue, dsCurValue, dsBlockRead,
    dsInternalCalc, dsOpening
}

open class BMSRTCConnection {
    
    var aServer : String;
   // private var pascalObj :  PASCAL_POBJ;// uint;
    //private var strBuf: [CChar]  //CChar = Int8
    //private var strBufLen: UInt32  //UInt32
    
    init(withServer xServer : String,withPort xPort:uint) {
        self.aServer = xServer;
       // pascalObj=nil;
        
        PrepareRemoteConnection(xServer,xPort);
    }
    
    public class func checkRemoteConnection(withServer xServer : String,withPort xPort:uint) -> Bool {
        return CheckRemoteConnection(xServer,xPort)==1 ;
    }
    
    public class func setRTCLicenseKey(_ aKey:String) {
        SetRTCLicenseKey(aKey);
    }
    
}



open class BMSField {
    
    fileprivate var pascalObj :  PASCAL_POBJ;
    
    init(withPasObject obj:PASCAL_POBJ) {
        self.pascalObj = obj;
    }
    
    var asString : String {
        
        get {
            
         return String(cString: DB_FieldAsString(pascalObj));
            
        }
        
        set {
            DB_SetFieldAsString(self.pascalObj,newValue);
        }
        
        
    }
    
    var asBlobArray : Data {
        
        get {
            
            
            
           // let dataSize = DB_FieldAsBlobSize(pascalObj);
            
           // print("data Size = \(dataSize)");
            
            var data : UnsafeRawPointer? = nil;//.allocate(bytes: Int(dataSize), alignedTo: MemoryLayout<Int8>.alignment);
            //? = nil //UnsafePointer<Int8>? //UnsafeMutableRawPointer?  // OpaquePointer? //UnsafePointer<Int8>? = nil;
           // var aSize = Buffer();
            
            
            let newIntPtr = UnsafeMutablePointer<UInt32>.allocate(capacity: 1)
            
            newIntPtr.pointee = 0
            
            DB_FieldAsBlobByteArray(pascalObj, newIntPtr,&data);
            
           // let y = newIntPtr.pointee;
            
          //  print("aSize =\(y)");
            
           // NSLog("aSize = %@", y);
            
            
            let rdata = Data.init(bytes: data!, count: Int(newIntPtr.pointee));
            
           // let buffer = UnsafeBufferPointer(start: data!.assumingMemoryBound(to: Int8.self), count: Int(newIntPtr.pointee));
            
           // let buffer = UnsafeBufferPointer(start: &data!, count: Int(newIntPtr.pointee));
            
            FPC_FreeMem(&data, newIntPtr.pointee);
            
            newIntPtr.deallocate(capacity: 1);
            
            return rdata ; //Data.init(buffer: buffer);
            
           // return  Data(bytes:  Array(buffer) );
            
           //ß∫ Data.init
        }
        
        
        
    }
    
    var asBlob : Data {
        
        get {
            
            
           // let sData = ;
           // fatalError();
            
            
            var data : UnsafeRawPointer? = nil;
            let newIntPtr = UnsafeMutablePointer<UInt32>.allocate(capacity: 1)
            
            newIntPtr.pointee = 0
            
            DB_FieldAsBlobByteArray(pascalObj, newIntPtr,&data);
            let rdata = Data.init(bytes: data!, count: Int(newIntPtr.pointee));
            
            FPC_FreeMem(&data, newIntPtr.pointee);
            
            newIntPtr.deallocate(capacity: 1);
            
            return rdata ;
            
            
           // let rdata = Data.init(fromHexEncodedString: String(cString: DB_FieldAsBlob(pascalObj)));
            
          //  return rdata!;
            
         
        }
        
        set {
            
            let data = newValue;
            let newIntPtr = UnsafeMutablePointer<UInt32>.allocate(capacity: 1);
            newIntPtr.pointee = UInt32(data.count);
            
            data.withUnsafeBytes { (u8Ptr: UnsafePointer<UInt8>) in
                var rawPtr = UnsafeRawPointer(u8Ptr)
                DB_SetFieldAsBlobByteArray(pascalObj,newIntPtr,&rawPtr);
            }
            
          
            
            //DB_SetFieldAsBlobByteArray
            
           // DB_SetFieldAsBlob(self.pascalObj,  StringMisc.byteArrayToHexString(Array(newValue))  ) ; // newValue.hexEncodedString()  );
        }
        
        
    }
    
    
    var asInteger : Int {
        
        get {
           return Int(DB_FieldAsInteger(pascalObj))
        
        }
        
        set {
            
            
            
            DB_SetFieldAsInteger(pascalObj, NSNumber(value: newValue).uint32Value);
            
            
            
        }
        
        
    }
    
    var asNSNumber : NSNumber {
        
        get {
            return NSNumber(value: DB_FieldAsInteger(pascalObj))
        }
        
        set {
            DB_SetFieldAsInteger(pascalObj, newValue.uint32Value  );
            
            
           
        }
        
        
    }
    
    var asFloat : Double {
        
        get {
            return DB_FieldAsFloat(pascalObj);
        }
        
        set {
            DB_SetFieldAsFloat(pascalObj, newValue  );
        }
        
        
    }
    
    var asDateTime : Date {
        
        get {
            return  Date(timeIntervalSince1970: Double(DB_FieldAsMacDateTime(pascalObj)));
                
               // NSDate(timeIntervalSince1970: Double(DB_FieldAsMacDateTime(pascalObj)));
        }
        
        set {
            DB_SetFieldAsMacDateTime(pascalObj, Int64(ceil(newValue.timeIntervalSince1970))  );
        }
        
        
    }
    
    var asDateFormatString : String {
        
        get {
            return String(cString: BMSFormatDateTime("d mmmm yyyy", Int64(ceil(Double(DB_FieldAsMacDateTime(pascalObj))))));
        
        }
    }
    
    var pascalObject : PASCAL_POBJ {
        
        get {
            
            return pascalObj;
        }
        
    }

    
    
}

open class BMSDataSet {
    
    fileprivate var pascalObj :  PASCAL_POBJ;
    fileprivate var freeok : Bool;
    
    init(_ aPascalObj : PASCAL_POBJ) {
        freeok = false;
        pascalObj = aPascalObj;
        
    }
    
    deinit {
        Dataset_Free(pascalObj)
    }
    
    var SQL : String {
        
        get {
            return String(cString: DADataset_GetSQL(pascalObj));
        }
        
        set {
            DADataset_SetSQL(self.pascalObj,newValue);
        }
    }
    
    func open() {
        Dataset_Open(pascalObj)
        
    }
    
    func execSQL() {
        DADataset_ExecSQL(pascalObj)
    }
    
    func close() {
       Dataset_Close(pascalObj)
        
    }
    
    func recordCount() -> Int {
        
        return Int(Dataset_RecordCount(pascalObj));
    }
    
    func append() {
        RTCMemDataset_Append(pascalObj)
    }
    func delete() {
        RTCMemDataset_Delete(pascalObj)
    }
    func first() {
        RTCMemDataset_First(pascalObj)
    }
    func last() {
        RTCMemDataset_Last(pascalObj)
    }
    
    
    func edit() {
        RTCMemDataset_Edit(pascalObj)
    }
    
    func post() {
        RTCMemDataset_Post(pascalObj)
    }
    
    func fieldbyName(_ name:String) -> BMSField {
        
        return BMSField(withPasObject: RTCMemDataset_FieldByName(pascalObj,name ) );
    }
    
    func bof() -> Bool {
        
        if Dataset_BOF(pascalObj)==1 {
            return true;
        } else {
            return false;
        }
    }
    
    func eof() -> Bool {
        
        if Dataset_EOF(pascalObj)==1 {
            return true;
        } else {
            return false;
        }
    }
    
    func next() {
        
        Dataset_Next(pascalObj)
    }
    
    
    var filter : String {
        
        get {
            
           return String(cString: Dataset_Filter(pascalObj));
        }
        
        set {
            
            Dataset_SetFilter(pascalObj, newValue);
        }
        
    }
    
    var paramCheck : Bool {
        
        get {
            if DADataset_GetParamCheck(pascalObj)==1 {
                return true;
            } else {
                return false;
            }
        }
        
        set {
            if newValue {
                DADataset_SetParamCheck(pascalObj, 1)
            } else {
                DADataset_SetParamCheck(pascalObj, 0)
            }
        }
        
    }
    
    var filtered : Bool {
        
        get {
            if Dataset_Filtered(pascalObj)==1 {
                return true;
            } else {
                return false;
            }
        }
        
        set {
            
            if newValue {
                Dataset_SetFiltered(pascalObj, 1)
                
            } else {
                Dataset_SetFiltered(pascalObj, 0)
            }
            
        }
        
    }
    
    var recNo : Int {
        
        get {
            
            return Int(RTCMemDataset_GetRecNo(pascalObj))
            
        }
        
        set {
            Dataset_SetRecNo(pascalObj, UInt32( newValue))
            
        }
    }
    
    func setParamByName(_name : String,_ aValue : String) {
        DADataset_SetParamValueAsString(pascalObj, aValue);
    }
    func setParamByName(_name : String,_ aValue : Int) {
        DADataset_SetParamValueAsInteger(pascalObj, UInt32(aValue));
    }
    
    func locate(_ name:String,_ aValue : Int) -> Bool {
        if RTCMemDataset_Locate(pascalObj, name, String(aValue) )==1 {
            return true
        } else {
            return false
        }
    }
    
    func locate(_ name:String,_ aValue : String) -> Bool {
        if RTCMemDataset_Locate(pascalObj, name, aValue )==1 {
            return true
        } else {
            return false
        }
    }
    
}

open class BMSUniConnection {
    
    fileprivate var pascalObj :  PASCAL_POBJ;
    fileprivate var freeok : Bool;
    
    init() {
        pascalObj = UniConnection_Create();
        freeok = false;
    }
    
    deinit {
        if !freeok {
            UniConnection_Free(pascalObj) }
        
    }
    
    func connectString() -> String {
        return String(cString: UniConnection_ConnectString(pascalObj));
 
    }
    
    func prepareConnection(_ sConnection : String) {
        
        UniConnection_PrepareConnection(pascalObj, sConnection);
    }
    
    func setSpecificOptions(_ sOption : String, _ sValue : String) {
        UniConnection_SetSpecificOptions(pascalObj, sOption, sValue);
    }
    
    func open() {
        UniConnection_Open(pascalObj);
    }
    
    func close() {
        UniConnection_Close(pascalObj);
    }
    
    func createDataset() -> BMSDataSet {
        return BMSDataSet( UniConnection_CreateDataSet(pascalObj));
    }
}

open class BMSRTCMemDataSet {
    
    fileprivate var pascalObj :  PASCAL_POBJ;// uint;
    
    fileprivate var freeok : Bool;
    
    init() {
        pascalObj = RTCMemDataset_Create()
        freeok = false;
    }
    
    deinit {
        if !freeok {
            RTCMemDataset_Free(pascalObj) }
    
    }
    
    func getDataSet(_ sql:String)  {
        RTCMemDataset_GetData(pascalObj,sql,0);
   
    }
    
    func getDataSet(_ sql:String, _ useJSON : Bool )  {
        
      
        
        if useJSON {
            RTCMemDataset_GetData(pascalObj,sql,1 ) } else {
            RTCMemDataset_GetData(pascalObj,sql,0 )
        }
        
    }
    
    func updateData(_ aTableName : String)  {
         RTCMemDataset_UpdateData(pascalObj,aTableName) ;
    
    }
    
    func fieldbyName(_ name:String) -> BMSField {
        
        return BMSField(withPasObject: RTCMemDataset_FieldByName(pascalObj,name ) );
    }
    
    func locateIntegerField(_ name:String,_ aValue : NSNumber) -> Bool {
        
        if RTCMemDataset_LocateInteger1Field(pascalObj, name, aValue.uint32Value)==1 {
            return true
        } else {
            return false
        }
    }
    
    func append() {
        RTCMemDataset_Append(pascalObj) ;
    }
    
    func edit()  {
        RTCMemDataset_Edit(pascalObj) ;
    }
    
    func post()  {
        RTCMemDataset_Post(pascalObj) ;
    }
    
    func close()  {
        RTCMemDataset_Close(pascalObj) ;
    }
    
    func delete()  {
        RTCMemDataset_Delete(pascalObj);
    }
    
    func cancel() {
        RTCMemDataset_Cancel(pascalObj);

    }
    
    
    
    func recordCount() -> Int {
        
        return Int(RTCMemDataset_RecordCount(pascalObj));
    }
    
    var state : DataSetState {
        
        get {
            
            
            return DataSetState(rawValue: Int(RTCMemDataset_GetState(pascalObj)))!;
            
         
        }
        
        
        
    }
    
    var recNo : Int {
        
        get {
            
            return Int(RTCMemDataset_GetRecNo(pascalObj))
            
        }
        
        set {
            RTCMemDataset_SetRecNo(pascalObj, UInt32( newValue))
            
        }
    }
    
    func bof() -> Bool {
        
        if RTCMemDataset_BOF(pascalObj)==1 {
            return true;
        } else {
            return false;
        }
    }
    
    func eof() -> Bool {
        
        if RTCMemDataset_EOF(pascalObj)==1 {
            return true;
        } else {
            return false;
        }
    }
    
    func first() {
        
        RTCMemDataset_First(pascalObj)
    }
    
    func last() {
        
        RTCMemDataset_Last(pascalObj)
    }
    
    func next() {
        
        RTCMemDataset_Next(pascalObj)
    }
    
    func testString(StringToTest str:String) -> Bool {
        if RTCMemDataset_TestString(pascalObj,str)==1 {
            return true;
        } else {
            return false;
        }
    }
    
    func free() {
        
        RTCMemDataset_Free(pascalObj);
        freeok = true;
    }
}
