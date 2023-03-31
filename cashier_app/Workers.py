import importlib
import json
import sys
import time

# import the opencv library
import cv2
import requests
from PyQt5.QtCore import QThread, pyqtSignal, pyqtSlot


class Receipt_Worker(QThread):
    '''QR Worker Thread'''
    ##### Signal for GUI Slots #####
    response_signal = pyqtSignal(object)
    error_signal = pyqtSignal(int, object)

    def __init__(self):
        super().__init__()

    @pyqtSlot()
    def run(self):
        # initalize the cam
        cap = cv2.VideoCapture(0)
        # initialize the cv2 QRCode detector
        detector = cv2.QRCodeDetector()
        while True:
            # Capture the video frame by frame
            _, frame = cap.read()
            code, _, _ = detector.detectAndDecode(frame)
            if code:
                print(f"CODE {code}")
                try:
                    res = requests.get(f'http://localhost:1111/api/v1/bill/receipt/{code}')
                    print(f'status {res.status_code}')
                    if res.status_code == 200:
                        receipt = {"receipt_id" : code,
                                    "receipt_body" : res.json()}
                        print(f"JSON {json.dumps(receipt, indent=2)}")
                        self.response_signal.emit(receipt)
                        break
                    else:
                        self.error_signal.emit(res.status_code, res.json())
                        ...
                        # self.error_signal.emit(str(res.status_code), res.json()[0])
                        # break
                except Exception as e:
                    print(e)
                    ...
            # Display the resulting frame
            cv2.imshow('frame', frame)
            # 'q' is set as quitting button, you may use any
            if cv2.waitKey(1) == ord('q'):
                break
        # After the loop release the cap object
        cap.release()
        # Destroy all the windows
        cv2.destroyAllWindows()

class Payment_Worker(QThread):
    '''Payment Worker Thread'''
    ##### Signal for GUI Slots #####
    success_signal = pyqtSignal()
    error_signal = pyqtSignal(str)

    def __init__(self, receipt):
        super().__init__()
        self.receipt = receipt

    @pyqtSlot()
    def run(self):
        try:
            res = requests.get(f'http://localhost:1111/api/v1/bill/pay/{self.receipt}')
            if res.status_code == 200:
                print(f"{res.json()}")
                self.success_signal.emit()
            else:
                self.error_signal.emit(res.status_code, res.json())
        except Exception as e:
            print(e)

