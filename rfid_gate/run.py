from Window import *
from PyQt5.QtWidgets import *
from PyQt5.QtGui import *
from PyQt5.QtCore import *
from CheckPoint import CheckPoint
import sys
import time

# GUI VARIABLES
WINDOW_WIDTH = 900
WINDOW_HEIGHT = 600

# CHECKPOINT VARIABLES
GATE_ID = "Checkpoint Gate"

BUFFER_SIZE = 1 # Size of buffer that forces the post
POLLING_CONTROL_TIME = 2 # time period of control polling
TIME_WINDOW = 2 # time window to post when no new tag is detected
TIMEOUT = 0.5 # Queue timeout

class Worker(QObject):
    '''Working Thread Class'''
    ##### Signal for GUI Slots #####
    insertSignal = pyqtSignal(object)
    sendingRequestSignal = pyqtSignal(int)
    gateStatusSignal = pyqtSignal(int)
    logsAppendSignal = pyqtSignal(str)
    clearSignal = pyqtSignal()
    
    def __init__(self):
        super().__init__()
        
        # create instance of checkpoint gate
        self.checkPointGate = CheckPoint(GATE_ID, BUFFER_SIZE, TIMEOUT, TIME_WINDOW, POLLING_CONTROL_TIME)
        # set the signals for GUI communication
        self.checkPointGate.setSignals (self.insertSignal,
                                        self.sendingRequestSignal,
                                        self.gateStatusSignal,
                                        self.logsAppendSignal,
                                        self.clearSignal)

    @pyqtSlot()
    def run(self):
        '''The Main Process for the Thread'''
        while self.checkPointGate.getGateStatus() != 0:
            time.sleep(0.2)
            self.checkPointGate.process_RFID_batch()

class MainWindow(QMainWindow):
    '''GUI Class'''
    def __init__(self):
        '''MainWindow constructor'''
        super().__init__()
        
        # Window Setup
        self.ui = checkPoint_Window()
        self.ui.setupUi(self, WINDOW_WIDTH, WINDOW_HEIGHT, GATE_ID)
        self.show()

        # Create a worker object and a thread
        self.worker = Worker()
        self.workerThread = QThread()
        # Assign the worker to the thread
        self.worker.moveToThread(self.workerThread)

        # Connect signals & slots
        self.worker.insertSignal.connect(self.insertToGUI)
        self.worker.logsAppendSignal.connect(self.logsAppend)
        self.worker.clearSignal.connect(self.clearTable)
        self.worker.sendingRequestSignal.connect(self.sendingRequest)
        self.worker.gateStatusSignal.connect(self.gateStatus)

        self.ui.clearLogs_btn.clicked.connect(lambda: self.ui.logs_box.setPlainText(""))

        # Start the thread and its job
        self.workerThread.started.connect(self.worker.run)
        self.workerThread.start()

    def gateStatus(self, state):
        '''Updating Gate Control Status'''
        if   state == 0: # Offline
            self.ui.gate_statusText.setText("Offline")
            self.ui.gate_statusText.setStyleSheet("color: rgb(250,0,0);\nfont-weight: bold;")
        elif state == 1: # Online
            self.ui.gate_statusText.setText("Online")
            self.ui.gate_statusText.setStyleSheet("color: rgb(0,250,0);\nfont-weight: bold;")
        else:            # ready
            self.ui.gate_statusText.setText("-----")
            self.ui.gate_statusText.setStyleSheet("color: rgb(0,0,0);\nfont-weight: bold;")

    def sendingRequest(self, state):
        '''Updating Gate Post Status'''
        if   state == 1: # sending
            self.ui.startAnimation()
        elif state == 0: # success
            self.ui.stopAnimation()
            self.ui.request_statusText.setText("Success")
            self.ui.request_statusText.setStyleSheet("color: rgb(0,250,0);\nfont-weight: bold;")
        elif state == 2: # failed
            self.ui.stopAnimation()
            self.ui.request_statusText.setText("Failed")
            self.ui.request_statusText.setStyleSheet("color: rgb(250,0,0);\nfont-weight: bold;")
        else:            # ready
            self.ui.request_statusText.setText("-----")
            self.ui.request_statusText.setStyleSheet("color: rgb(0,0,0);\nfont-weight: bold;")

    def clearTable(self):
        '''Clear the GUI Grid table of cart'''
        self.ui.clearData()

    def logsAppend(self, data):
        '''Append a text to the logs box'''
        self.ui.logs_box.append(data)

    def __del__(self):
        '''Killing a thread'''
        self.workerThread.quit()
        self.workerThread.wait()

    def insertToGUI(self, data):
        '''Insert a cart into GUI Grid'''
        self.ui.addRow(data)

if __name__ == '__main__':
    app = QApplication(sys.argv)
    mainWindow = MainWindow()
    sys.exit(app.exec_())