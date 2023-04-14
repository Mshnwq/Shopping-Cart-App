import ctypes
import json
import os
import platform
import sys
from functools import partial

from PyQt5.QtGui import QIcon, QPixmap
from PyQt5.QtWidgets import QApplication, QFileDialog, QMainWindow, QMessageBox

import assets.qrc
from window import SuccessDialog, Ui_MainWindow
from Workers import Payment_Worker, Receipt_Worker


class MainWindow(QMainWindow):
    def __init__(self) -> None:
        super().__init__()

        self.setWindowIcon(QIcon(":SCFS"))
        if platform.system() == 'Windows':
            myappid = 'mycompany.myproduct.subproduct.version'  # arbitrary string
            ctypes.windll.shell32.SetCurrentProcessExplicitAppUserModelID(
                myappid) # type: ignore
        elif platform.system() == 'Linux':
            ...
        else:
            print(f"Taskbar Icon not supported in {platform.system()} OS")

        self.setWindowTitle("My Cashier")

        # initialize the ui
        self.init_ui()

    def init_ui(self) -> None:

        # Window Setup
        self.ui = Ui_MainWindow()
        self.ui.setup_ui(self)
        self.show()

        self._receipt = '4tQBX3VFgE5kTOMhpOjwDA7fu'

        ''' Button Events '''
        self.ui.extract_event_signal.connect(
            partial(self.handle_extract_receipt_event))
        self.ui.payment_event_signal.connect(
            partial(self.handle_payment_event))
        self.ui.excel_event_signal.connect(
            partial(self.handle_excel_event))
        
        # disable buttons until extract is done
        self.ui.excel_button.setDisabled(True) 
        self.ui.payment_button.setDisabled(True) 

    def handle_extract_receipt_event(self) -> None:
        # create worker and connect slots
        receipt_dict = {"receipt_id": "4tQBX3VFgE5kTOMhpOjwDA7fu",
            "receipt_body": {
                "bill": {
                "status": "unpaid",
                "created_at": "2023-03-31T21:14:45.539142",
                "num_of_items": 4,
                "total_price": 70.0,
                "user_id": 1
                },
                "items": [
                {
                    "1231231": {
                    "ar_name": "\u062a\u0628\u063a",
                    "en_name": "snus",
                    "count": 3,
                    "unit_price": 20.0
                    }
                },
                {
                    "12312ssssssssssssssssssssss38": {
                    "ar_name": "\u062a\u0628\u063a",
                    "en_name": "saanus",
                    "count": 1,
                    "unit_price": 10.0
                    }
                }
                ]
            }
        }
        # receipt_body = receipt_dict['receipt_body']
        # TODO list comprehension
        # self.ui.update_table(receipt_body)
        # dialog = SuccessDialog()
        # dialog.exec_()
        # return
        receipt_worker = Receipt_Worker() 
        receipt_worker.response_signal.connect(
            partial(self.on_extract_receipt_finish, receipt_worker))
        receipt_worker.error_signal.connect(
            partial(self.status_code))
        receipt_worker.start()
        ...

    def on_extract_receipt_finish(self, worker, receipt_dict) -> None:
        worker.terminate()
        self._receipt = receipt_dict['receipt_id']
        receipt_body = receipt_dict['receipt_body']
        # TODO list comprehension
        self.ui.update_table(receipt_body)
        # enable action buttons
        self.ui.excel_button.setDisabled(False) 
        self.ui.payment_button.setDisabled(False) 
        self.ui.showMessage('extract receipt finished')
        ...

    def handle_payment_event(self) -> None:
        # create worker and connect slots
        receipt_worker = Payment_Worker(self._receipt)
        receipt_worker.success_signal.connect(
            partial(self.on_payment_finish, receipt_worker))
        receipt_worker.error_signal.connect(
            partial(self.status_code))
        receipt_worker.start()
        ...

    def on_payment_finish(self, worker) -> None:
        worker.terminate()
        dialog = SuccessDialog()
        dialog.exec_()
        # enable action buttons
        self.ui.showMessage('payment finished')
        self.ui.clear_data()
        self.ui.payment_button.setDisabled(True) 
        ...

    def handle_excel_event(self) -> None:
        # get the selected albums to save and filter them
        table_selected = self.ui.get_table_selected()
        if len(table_selected) == 0:
            self.throw_dialog()
            return None
        _selected = self.filter_albums(table_selected)
        # Use QFileDialog to prompt the user for a excel file
        options = QFileDialog.Options()
        file_name, _ = QFileDialog.getOpenFileName(self,
            "QFileDialog.getOpenFileName()", "",
            "Text Files (*.xlsx);;All Files (*)", options=options)
        if file_name == '':
            return None
        # create worker and connect slots
        # excel_worker = Excel_Worker(file_name, _selected)
        # excel_worker.done_signal.connect(
        #     partial(self.on_excel_finish, excel_worker))
        # excel_worker.start()
        ...

    def on_excel_finish(self, worker) -> None:
        worker.terminate()
        self.ui.showMessage('excel work finished')
        ...

    def status_code(self, code, body):
        dialog = QMessageBox()
        dialog.setText(f"{code}!")
        dialog.setWindowTitle("Error!")
        dialog.setInformativeText(f'{body}')
        dialog.setIcon(QMessageBox.Critical)
        dialog.setStandardButtons(QMessageBox.Retry|QMessageBox.Cancel)
        dialog.exec_()

    def throw_dialog(self) -> None:
        dialog = QMessageBox()
        dialog.setWindowTitle("Error!")
        dialog.setText("Select entires from table")
        dialog.setIcon(QMessageBox.Critical)
        dialog.exec_()
        ...


if __name__ == '__main__':
    app = QApplication(sys.argv)
    window = MainWindow()
    window.show()
    app.exec_()
