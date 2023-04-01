from functools import partial

from PyQt5.QtCore import QMetaObject, QPoint, Qt, pyqtSignal
from PyQt5.QtGui import QColor, QFont, QIcon, QPixmap
from PyQt5.QtWidgets import (QAction, QApplication, QCheckBox, QDialog,
                             QDialogButtonBox, QGridLayout, QGroupBox,
                             QHBoxLayout, QHeaderView, QLabel, QLineEdit,
                             QMainWindow, QMenu, QMenuBar, QPushButton,
                             QStatusBar, QTableWidget, QTableWidgetItem,
                             QVBoxLayout, QWidget)


class Ui_MainWindow(QMainWindow):
    ##### Event Signal to be handled in Main #####
    extract_event_signal = pyqtSignal()
    payment_event_signal = pyqtSignal()
    excel_event_signal = pyqtSignal()

    def __init__(self):
        super().__init__()

    def setup_ui(self, MainWindow):
        # Initialize window
        MainWindow.setGeometry(100, 100, 800, 600)
        MainWindow.setMinimumSize(800, 600)
        self.centralwidget = QWidget(MainWindow)
        
        # Initialize layout
        self.layout = QVBoxLayout(self.centralwidget) # type: ignore

        # Add search bar and button
        self.extract_button = QPushButton('Scan Receipt')
        self.extract_button.setIcon(QIcon(":barcode"))
        self.extract_button.clicked.connect(
                                lambda: self._emit(
                                'extract_event_signal'))

        self.layout.addWidget(self.extract_button)

        # Add table widget
        self.table = QTableWidget()
        self.table.setColumnCount(4)
        self.table.setHorizontalHeaderLabels(['Barcode', 'Name', 'Price', 'Quantity'])
        self.table.setSortingEnabled(True)
        self.table.setContextMenuPolicy(Qt.CustomContextMenu)
        self.table.customContextMenuRequested.connect(self.customContextMenuRequested)
        header = self.table.horizontalHeader()
        header.setSectionsClickable(True)
        header.setSectionsMovable(True)
        # header.setSectionResizeMode(QHeaderView.Stretch)

        self.layout.addWidget(self.table)

        self.summary_group = QGroupBox(self.centralwidget)
        self.summary_layout = QHBoxLayout(self.summary_group)
        self.layout.addWidget(self.summary_group)

        # Add action group and button
        self.action_group = QGroupBox(self.centralwidget)
        # Add search bar and button
        self.payment_button = QPushButton('Payment Confirm')
        self.payment_button.setIcon(QIcon(":scan"))
        self.payment_button.clicked.connect(
                                lambda: self._emit(
                                'payment_event_signal')) 
        self.excel_button = QPushButton('Excel')
        self.excel_button.setIcon(QIcon(":eye"))
        self.excel_button.clicked.connect(
                                lambda: self._emit(
                                'excel_event_signal'))
        action_layout = QHBoxLayout(self.action_group)
        action_layout.addWidget(self.excel_button)
        action_layout.addWidget(self.payment_button)

        self.layout.addWidget(self.action_group)

        # Create actions to attach to menu bar
        self._createActions(MainWindow)
        # Create menu bar and populate with actions
        self._createMenuBar(MainWindow)
        # Create status bar
        self.statusbar = QStatusBar(MainWindow)
        self.statusbar.setObjectName("statusbar")
        MainWindow.setStatusBar(self.statusbar)

        MainWindow.setCentralWidget(self.centralwidget) 
        QMetaObject.connectSlotsByName(MainWindow)

    def _createMenuBar(self, MainWindow):
        self.menuBar = QMenuBar(MainWindow)

        # Help menu
        helpMenu = self.menuBar.addMenu(QIcon(":info"), "&Help")
        helpMenu.addAction(self.helpContentAction)
        helpMenu.addAction(self.aboutAction)

        MainWindow.setMenuBar(self.menuBar)

    def _createActions(self, MainWindow):
        self.helpContentAction = QAction("&Help Content", MainWindow)
        self.helpContentAction.triggered.connect(
            lambda: self.showMessage("Help Later"))
        self.aboutAction = QAction("&About", MainWindow)
        self.aboutAction.triggered.connect(self.aboutActionButtonClick)

    def aboutActionButtonClick(self):
        dlg = AboutDialog()
        dlg.exec_()

    def showMessage(self, message: str):
        self.statusbar.showMessage(message)

    def _emit(self, to_emit: str):
        print(f"Event Triggered: {to_emit}")
        eval(f"self.{to_emit}.emit()")

    def clear_data(self):
        # Clear existing items in table
        self.table.clearContents()
        child = self.summary_layout.itemAt(0)
        if child is not None:
            child.widget().deleteLater()

    def update_table(self, receipt_body_dict: dict):
        self.clear_data()

        # Get the 'items' list from the receipt_body_dict
        items_list = receipt_body_dict['items']

        # Set the number of rows in the table to the number of items
        self.table.setRowCount(len(items_list))

        # Iterate over the items and insert them into the table
        for i, item in enumerate(items_list):
            # Get the key (i.e., the item ID) and the value (i.e., the item info dictionary)
            item_id = list(item.keys())[0]
            item_info = item[item_id]

            # Insert the item ID into the first column
            item_id_item = QTableWidgetItem(item_id)
            item_id_item.setTextAlignment(Qt.AlignCenter)
            self.table.setItem(i, 0, item_id_item)

            # Insert the item name (in English) into the second column
            item_name_item = QTableWidgetItem(item_info['en_name'])
            item_name_item.setTextAlignment(Qt.AlignCenter)
            self.table.setItem(i, 1, item_name_item)

            # Insert the item price into the third column
            item_price_item = QTableWidgetItem(str(item_info['unit_price']))
            item_price_item.setTextAlignment(Qt.AlignCenter)
            self.table.setItem(i, 2, item_price_item)

            # Insert the item count into the fourth column
            item_count_item = QTableWidgetItem(str(item_info['count']))
            item_count_item.setTextAlignment(Qt.AlignCenter)
            self.table.setItem(i, 3, item_count_item)

        # Create bottom header
        bill_data = receipt_body_dict['bill']
        bottom_header = BottomBox(bill_data)

        # Update bottom header
        self.summary_layout.addWidget(bottom_header)


class BottomBox(QWidget):
    def __init__(self, bill_data: dict):
        super().__init__()

        # Create the layout for the box
        layout = QHBoxLayout(self)

        # Create a vertical layout for each piece of bill data
        for label_text, value_text in bill_data.items():
            vlayout = QVBoxLayout()

            # Create the label widget
            label = QLabel(label_text, self)
            label.setAlignment(Qt.AlignCenter)
            vlayout.addWidget(label)

            # Create the value widget
            value = QLabel(str(value_text), self)
            value.setAlignment(Qt.AlignCenter)
            vlayout.addWidget(value)

            # Add the vertical layout to the horizontal layout
            layout.addLayout(vlayout)

        # Set color of status
        status = bill_data['status']
        if status == 'paid':
            layout.itemAt(0).itemAt(1).widget().setStyleSheet("QLabel { color: green;}")
        elif status == 'unpaid':
            layout.itemAt(0).itemAt(1).widget().setStyleSheet("QLabel { color: red;}")
        else:
            layout.itemAt(0).itemAt(1).widget().setStyleSheet("QLabel { color: blue;}")

        # Set font of total price
        layout.itemAt(3).itemAt(1).widget().setFont(QFont('Arial', 14, QFont.Bold))

        # Set the layout for the widget
        self.setLayout(layout)


class AboutDialog(QDialog):
    def __init__(self):
        super().__init__()
        self.setWindowTitle("About")
        self.buttonBox = QDialogButtonBox()
        self.setWindowIcon(QIcon(":SCFS"))
        self.layout = QGridLayout()
        message = QLabel("Licensed by SCFS")
        self.layout.addWidget(message, 0, 0)
        version = QLabel("Version: {\"Beta\"}")
        self.layout.addWidget(version, 2, 0)
        icon = QPixmap(":SCFS")
        image = QLabel()
        image.setPixmap(icon.scaled(100, 100))
        self.layout.addWidget(image, 1, 1)
        self.layout.addWidget(self.buttonBox)
        self.setLayout(self.layout)

class SuccessDialog(QDialog):
    def __init__(self):
        super().__init__()
        self.setWindowTitle("Payment Success")
        self.setWindowIcon(QIcon(":SCFS"))
        
        # Create the layout for the dialog
        layout = QVBoxLayout(self)
        
        # Create the icon widget
        icon = QLabel()
        icon.setPixmap(QPixmap(":unlock").scaled(100, 100))
        icon.setAlignment(Qt.AlignCenter)
        layout.addWidget(icon)

        text = QLabel('Payment Success')
        text.setFont(QFont('Arial', 14, QFont.Bold))
        text.setStyleSheet("QLabel { color: green;}")
        text.setAlignment(Qt.AlignCenter)
        layout.addWidget(text)
        
        # Create the OK button
        ok_button = QPushButton("OK", self)
        ok_button.setDefault(True)
        ok_button.clicked.connect(self.accept)
        layout.addWidget(ok_button)
        
        # Set the layout for the dialog
        self.setLayout(layout)

if __name__ == '__main__':
    app = QApplication([])
    main = QMainWindow()
    main.ui = Ui_MainWindow()
    main.ui.setup_ui(main)
    main.show()
    app.exec_()
    ...
