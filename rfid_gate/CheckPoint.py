from RFID_Driver import RFID_Reader
from circularQueue import circularQueue
import multiprocessing
import threading
import json
import requests
import time

class CheckPoint():
    '''
    Check Point Gate Class
    '''
    def __init__(self, GATE_ID, buffer_size=4, timeout=2, time_window=2, polling_time=5):
        '''
        init method or constructor
        Args:
            GATE_ID (TODO):
            buffer_size (int): size of circular queue buffer that forces a post
            timeout (int): the timeout for reader read job queue
            time_window (int): time window that if no tags are read will make request
            polling_time (int): time window of when a get request of the gate status is done
        '''
        # initialize instance data
        self.data = [] # temp array emptied after
        self.cartsList = [] # temp array for JSON

        self.__GATE_ID = GATE_ID # unique for the gate
        self.time_window = time_window # time window to start processing when no new tag is detected
        self.polling_time = polling_time # polling delay
        self.timeout = timeout # queue timeout window
        self.forceCache = circularQueue(buffer_size) # tags buffer

        # The Control Polling
        self.thread = threading.Thread(target=self.control, args=(self.polling_time,)) # gate control on a thread
        # self.gateLock = threading.Lock()
        self.gateStatus = multiprocessing.Value('i', 1) # default gate state
        self.thread.start()
       
        self.reader = RFID_Reader(timeout=timeout) # RFID reader object
        self.reader.run() # run reading job

    def setSignals(self,insertSignal,
                        sendingRequestSignal,
                        gateStatusSignal,
                        logsAppendSignal,
                        clearSignal):
        '''
        Set GUI signals to emit 
        '''
        self.insertSignal         = insertSignal
        self.sendingRequestSignal = sendingRequestSignal
        self.gateStatusSignal     = gateStatusSignal
        self.logsAppendSignal     = logsAppendSignal
        self.clearSignal          = clearSignal

    def getGateStatus(self):
        '''get gate status
            Returns (int): 
        '''
        return self.gateStatus.value

    def process_RFID_batch(self):
        '''
        Accumulate a batch of RFID Tags, process and send to DB
        Emits:
            sendingRequestSignal:
                3: Ready to accumalate
            insertSignal:
                insert a tag onto GUI grid
            clearSignal:
                when a batch is complete this will send signal to clear accumalated tags on GUI grid
        '''
        # An infinte loop in the case of nothing is detected
        while True:
            tagRead = self.reader.readTag() 
            # print(tagRead)
            if tagRead == None: # no read
                continue
            else:
                # print("break")
                self.sendingRequestSignal.emit(3) # start collecting mode
                break

        print("ENTERING THE LOOOOP")   

        NoFlagTime = 0                 
        Window_Start_time = time.time()
        while NoFlagTime <= self.time_window: # if nothing is detected for this time break
            if self.forceCache.isFull(): # breakout if buffer fills up
                # print("FULL")
                break
            tagRead = self.reader.readTag()   
            if tagRead == None: # corrupt read or no read
                NoFlagTime = time.time() - Window_Start_time
                continue
            if tagRead not in self.data:
                self.data.append(tagRead) # for Filter
                #TODO
                cartInfoDict = {}
                cartInfoDict["key"] = (str(int.from_bytes(tagRead[:], 'big'))) # cart key
                print("adding: ", end='')
                # print(tagRead[:])
                print(cartInfoDict)
                # self.q.put(cartInfoDict)
                self.logsAppendSignal.emit(f"adding: {cartInfoDict}")
                self.insertSignal.emit(cartInfoDict) # for GUI
                self.cartsList.append(cartInfoDict) # for JSON
                self.forceCache.enqueue(cartInfoDict) # for Buffer
                Window_Start_time = time.time()
            else:
                Window_Start_time = time.time()

        print("EXITING THE LOOOOP")

        # send data to DB
        self.sendData()

        # clear data
        self.data.clear()
        self.cartsList.clear()
        self.forceCache.clearCQ()
        self.reader.clear() # clear reader data
        self.clearSignal.emit() # clear GUI data

    def sendData(self):
        '''
        Constrcut JSON and attempt to send to DB
        Emits:
            sendingRequestSignal:
                0: Send Success
                1: Sending
                2: Send Failed
        '''
        self.logsAppendSignal.emit("sending")
        self.sendingRequestSignal.emit(1)

        # construct JSON
        checkPointInfoDict = dict()
        checkPointInfoDict["gate_id"] = self.__GATE_ID
        if (len(self.cartsList) == 0):
            return
        checkPointInfoDict["carts"] = self.cartsList

        # Serializing json  
        json_object = json.dumps(checkPointInfoDict, indent = 4) 
        print(json_object)

        # TODO request link
        # Attempt Post Rquest
        try:
            r = requests.post(f'http://192.168.239.66:1111/api/v1/cart/checkpoint/{checkPointInfoDict["carts"][0]["key"]}')
            if r.status_code == 200:
                print(f"Status Code: {r.status_code}, Response: {r.json()}")
                self.logsAppendSignal.emit("Success")
                self.sendingRequestSignal.emit(0)
            else:
                print(f"Status Code: {r.status_code}, Response: {r.json()}")
                self.logsAppendSignal.emit("Failed")
                self.sendingRequestSignal.emit(2)
        except:
            print(f"Status Code: , Response:")
        pass
    
    def control(self, polling_time):
        '''
        Continuous Gate Status Control over from back end
        Args:
            polling_time (int): the delay between each get attempt
        Emits:
            gateStatusSignal:
                0: Offline
                1: Online
        '''
        while True:
            time.sleep(polling_time) # not to overload get request
            Status = ""
            # print("control")
            # get attempt
            # try:
            #     r = requests.get(f'http://38.54.61.211:8989/api/v1/gate/status/{self.GATE_ID}')
            #     if r.status_code == 200:
            #         response = json.loads(r.text)
            #         Status = response["gate_status"]
            # except:
            #     pass
            
            # case of turing off gate
            if Status == "Offline":
                self.gateStatus.value = 0
                self.reader.stop()
                self.gateStatusSignal.emit(0)
            # case of working gate
            else:
                if self.reader.Exit_Flag.value == 1: # if reader is off
                    self.reader.start()              # restart it
                self.gateStatus.value = 1
                self.gateStatusSignal.emit(1)