import multiprocessing
import platform
import ctypes
from ctypes import *
import os
from multiprocessing import Process, Queue
from queue import Empty
from time import time, sleep

###### SETTING, READ THE DATA SHEET ######
DEFAULT_SETTINGS =     [0x01,0x01,0x00,0x00,0x15,0x00,0x04]
SINGLE_READ_SETTINGS = [0x01,0x00,0x00,0x00,0x02,0x01,0x04]

class RFID_Reader():
    '''
    RFID Driver Class
    '''
    def __init__ (self, timeout=2):
        '''
        Driver Constructor
        Args:
            timeout (int): queue timeout
        '''
        self.q = Queue()       # Queue object for read tags
        self.timeout = timeout # timeout of queue
        self.p = Process(target=self._reading_job, args=(self.q,)) # a process for the job
        self.Exit_Flag = multiprocessing.Value('i', 0) # process flag  

#### PROCESS CONTROL METHODS ####
    def run(self):
        '''start the job'''
        self.Exit_Flag.value = 0
        self.p.start()

    def stop(self):
        '''stop the job'''
        self.Exit_Flag.value = 1
        self.p.join()
        self.p.close()

    def clear(self):
        '''Clear Job Queue'''
        while not self.q.empty():
            # print(f"cleared: {self.q.get()}")
            self.q.get()

    def _reading_job(self, q):
        '''
        Process of reeading Tags and Enqueuing to Queue
        Args: 
            q (Queueu): Queue being enqueued
        '''
        # Device Setup
        self.__setup_dll()
        self.setSettings(SINGLE_READ_SETTINGS, False)
        self.getSettings() #Use when needed

        print(f"Entering the Reading Loop, Flag = {self.Exit_Flag.value}")
        while self.Exit_Flag.value == 0:
            tagRead = self.singleReadSimEPC()
            if tagRead:
                q.put(tagRead)
        print(f"Exiting the Reading Loop, Flag = {self.Exit_Flag.value}")

    def readTag(self):
        '''Dequeue a Tag Read from Queue'''
        try:
            tagValue = self.q.get(block=True, timeout=self.timeout)
        except Empty:
            tagValue = None
        # print(tagValue)
        # if tagValue and self.checkSum(tagValue) == 1:
        return tagValue
        # else: 
            # return None

########### DEVICE INITIALIZATION METHODS ############

    def __setup_dll(self):
        '''Device setup'''
        absolutepath = os.path.abspath(__file__)
        fileDirectory = os.path.dirname(absolutepath)
        if platform.system() == 'Windows':
            self.Objdll = ctypes.windll.LoadLibrary(
                fileDirectory + '\\lib\\CFHidApi.dll') # load dll object

            iUsbNum = int(0)
            iUsbNum = self.Objdll.CFHid_GetUsbCount()
            if iUsbNum == 0:
                print("No USB Device")
            if self.Objdll.CFHid_OpenDevice(0) == 1:   # open device
                print("OpenSuccess")
            else:
                print("OpenError")

    def setSettings(self, settings = DEFAULT_SETTINGS, printOn = True):
        '''
        Set device settings as in SETTINGS LIST
        Args 
            settings (Hex[]): list of settingsfrom Data Sheet
            printOn (bool): wheathe to print success results
        '''
        # /******** Func: Set Device One Param**********/
        # //  Param: bDevAdr: 0xFF
        # //         pucDevParamAddr: Param Addr
        # //         bValue: Param

        # pucDevParamAddr = 0x01 #Transport
        if self.Objdll.CFHid_SetDeviceOneParam(0xff, 0x01, settings[0]) == 1:
            if printOn:
                print("#1 set Transport Success")
        else:
            print("#1 set Transport Failed")

        # pucDevParamAddr = 0x02 #WorkMode
        if self.Objdll.CFHid_SetDeviceOneParam(0xff, 0x02, settings[1]) == 1:
            if printOn:
                print("#2 set WorkMode Success")
        else:
            print("#2 set WorkMode Failed")

        # pucDevParamAddr = 0x03 #DeviceAddr
        if self.Objdll.CFHid_SetDeviceOneParam(0xff, 0x03, settings[2]) == 1:
            if printOn:
                print("#3 set DeviceAddr Success")
        else:
            print("#3 set DeviceAddr Failed")

        # pucDevParamAddr = 0x04 #FilterTime
        if self.Objdll.CFHid_SetDeviceOneParam(0xff, 0x04, settings[3]) == 1:
            print("#4 set FilterTime Success")
        else:
            print("#4 set FilterTime Failed")

        # pucDevParamAddr = 0x05 #RFpower
        if self.Objdll.CFHid_SetDeviceOneParam(0xff, 0x05, settings[4]) == 1:
            if printOn:
                print("#5 set RFpower Success")
        else:
            print("#5 set RFpower Failed")

        # pucDevParamAddr = 0x06 #BeepEnable
        if self.Objdll.CFHid_SetDeviceOneParam(0xff, 0x06, settings[5]) == 1:
            if printOn:
                print("#6 set BeepEnable Success")
        else:
            print("#6 set BeepEnable Failed")

        # pucDevParamAddr = 0x07 #BaudRate
        if self.Objdll.CFHid_SetDeviceOneParam(0xff, 0x07, settings[6]) == 1:
            if printOn:
                print("#7 set BaudRate Success")
        else:
            print("#7 set BaudRate Failed")

        print("***********")

        # set device frequency
        fromFreqList = [0x31, 0x80] # check data sheet
        pFreq = bytes(fromFreqList)
        if self.Objdll.CFHid_SetFreq(0xff, pFreq) == 1:   #0x31\0x80 is US Freq
            if printOn:
                print("set device frequency Success")
        else:
            print("set device frequency Failed")

    def getSettings(self):
        '''Get device settings'''
        # /******** Func: Get Device One Param**********/
        # //  Param: bDevAdr: 0xFF
        # //         pucDevParamAddr: Param Addr
        # //         pValue: Return Param Value

        pValues = []

        # pucDevParamAddr = 0x01 #Transport
        pValue1 = create_string_buffer(1)
        if self.Objdll.CFHid_ReadDeviceOneParam(0xff, 0x01, pValue1) == 1:
            print("#1 get Transport Success")
        else:
            print("#1 get Transport Failed")
        pValues.append(pValue1.value.hex())

        # pucDevParamAddr = 0x02 #WorkMode
        pValue2 = create_string_buffer(1)
        if self.Objdll.CFHid_ReadDeviceOneParam(0xff, 0x02, pValue2) == 1:
            print("#2 get WorkMode Success")
        else:
            print("#2 get WorkMode Failed")
        pValues.append(pValue2.value.hex())

        # pucDevParamAddr = 0x03 #DeviceAddr
        pValue3 = create_string_buffer(1)
        if self.Objdll.CFHid_ReadDeviceOneParam(0xff, 0x03, pValue3) == 1:
            print("#3 get DeviceAddr Success")
        else:
            print("#3 get DeviceAddr Failed")
        pValues.append(pValue3.value.hex())

        # pucDevParamAddr = 0x04 #FilterTime
        pValue4 = create_string_buffer(1)
        if self.Objdll.CFHid_ReadDeviceOneParam(0xff, 0x04, pValue4) == 1:
            print("#4 get FilterTime Success")
        else:
            print("#4 get FilterTime Failed")
        pValues.append(pValue4.value.hex())

        # pucDevParamAddr = 0x05 #RFpower
        pValue5 = create_string_buffer(1)
        if self.Objdll.CFHid_ReadDeviceOneParam(0xff, 0x05, pValue5) == 1:
            print("#5 get RFpower Success")
        else:
            print("#5 get RFpower Failed")
        pValues.append(pValue5.value.hex())

        # pucDevParamAddr = 0x06 #BeepEnable
        pValue6 = create_string_buffer(1)
        if self.Objdll.CFHid_ReadDeviceOneParam(0xff, 0x06, pValue6) == 1:
            print("#6 get BeepEnable Success")
        else:
            print("#6 get BeepEnable Failed")
        pValues.append(pValue6.value.hex())

        # pucDevParamAddr = 0x07 #BaudRate
        pValue7 = create_string_buffer(1)
        if self.Objdll.CFHid_ReadDeviceOneParam(0xff, 0x07, byref(pValue7)) == 1:
            print("#7 get BaudRate Success")
        else:
            print("#7 get BaudRate Failed")
        pValues.append(pValue7.value.hex())

        print("******************")
        for i in range(0, len(pValues)):
            match i:
                case 0:
                    print("Transport:", end = " ")
                    match pValues[i]:
                        case '':
                            print("USB")
                        case '01':
                            print("RS232")
                        case '02':
                            print("RJ45")
                        case '03':
                            print("WIFI")
                        case '04':
                            print("Weigand")
                case 1:
                    print("WorkMode:", end = " ")
                    match pValues[i]:
                        case '':
                            print("Answer")
                        case '01':
                            print("Active")
                        case '02':
                            print("Trigger")
                case 2:
                    print("DeviceAddr:", end = " ")
                    print(pValues[i], end = '\n')
                case 3:
                    print("FilterTime:", end = " ")
                    print(pValues[i], end = '\n')
                case 4:
                    print("RFPower:", end = " ")
                    print(str(int(pValues[i],16)) + "dBm")
                case 5:
                    print("BeepEnable:", end = " ")
                    match pValues[i]:
                        case '':
                            print("No")
                        case '01':
                            print("Yes")
                case 6:
                    print("BaudRate:", end = " ")
                    match pValues[i]:
                        case '':
                            print("9600")
                        case '01':
                            print("19200")
                        case '02':
                            print("38400")
                        case '03':
                            print("57600")
                        case '04':
                            print("115200")
        # read device frequency
        # fromFreqList = [0x31, 0x80] # check data sheet
        # pFreq = bytes(fromFreqList)
        # if self.Objdll.CFHid_ReadFreq(0xff, pFreq) == 1:   #0x31\0x80 is US Freq
        #     print("read device frequency Success")
        # else:
        #     print("read device frequency Failed")
        print("******************")

########## DEVICE OPERATION METHODS ##########
    def singleReadSimEPC(self, pswd = [0x00,0x00,0x00,0x00]):
        '''
        Reads RFID Tag EPC Content
        Args:
            pswd (Hex[]]): password if exists on tag, default is ZERO
        '''
        # /******** Func: Read Card**********/
        # //  Param: bDevAdr: 0xFF
        # //         Password: Password (4 bytes)
        # //         Mem:      0:Reserved 1:EPC 2:TID 3:USER
        # //         WordPtr:  Start Address
        # //         ReadEPClen: Read Length (in words) "2bytes"
        # //         Data: Read Data
        # /*********************************************************/
        passWrd = bytes(pswd)
        mem = 0x01 
        wordPtr = 0x02
        readLen = 0x08
        rsv_data = bytes(16)
        if self.Objdll.CFHid_ReadCardG2(0xff, passWrd, mem, wordPtr, readLen, rsv_data) == 1:
            print(rsv_data)
            return rsv_data

##### HELPER METHODS #####
    def checkSum(self, Data):
        '''sums all bytes previous of index 11 of arr'''
        desiredCheckSum = Data[11]
        checkSum = int(0)
        for i in range(0, 11):
            checkSum += Data[i]
        checkSumValByte = checkSum.to_bytes(2,'big')
        checkSumVal = checkSumValByte[1]

        if checkSumVal == desiredCheckSum: 
            return 1
        else:
            return 0

if __name__ == "__main__":
    # simple test script
    print(__name__)
    tags=[]
    rfid_reader = RFID_Reader(timeout=3)
    rfid_reader.run()
    while len(tags) <= 2:
        tag = rfid_reader.readTag()        
        if tag and tag not in tags:
            print(tag)
            tags.append(tag)

    print(tags)    
    rfid_reader.stop()
    print("Done")