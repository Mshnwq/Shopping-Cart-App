from PyQt5.QtCore import QMetaObject, QPoint, Qt, pyqtSignal
from PyQt5.QtWidgets import (QAction, QApplication, QCheckBox, QGroupBox,
                             QHBoxLayout, QHeaderView, QLabel, QLineEdit,
                             QMainWindow, QMenu, QPushButton, QStatusBar,
                             QTableWidget, QTableWidgetItem, QVBoxLayout,
                             QWidget)


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
        header.setSectionResizeMode(QHeaderView.Stretch)

        self.layout.addWidget(self.table)

        # Add action group and button
        self.action_group = QGroupBox(self.centralwidget)
        # Add search bar and button
        self.payment_button = QPushButton('Payment Confirm')
        self.payment_button.clicked.connect(
                                lambda: self._emit(
                                'payment_event_signal')) 
        self.excel_button = QPushButton('Excel')
        self.excel_button.clicked.connect(
                                lambda: self._emit(
                                'excel_event_signal'))
        action_layout = QHBoxLayout(self.action_group)
        action_layout.addWidget(self.excel_button)
        action_layout.addWidget(self.payment_button)

        self.layout.addWidget(self.action_group)

        # Create status bar
        self.statusbar = QStatusBar(MainWindow)
        self.statusbar.setObjectName("statusbar")
        MainWindow.setStatusBar(self.statusbar)

        MainWindow.setCentralWidget(self.centralwidget) 
        QMetaObject.connectSlotsByName(MainWindow)

    def customContextMenuRequested(self, point: QPoint):
        # Create context menu and actions
        menu = QMenu(self.table)

        # Create a QAction with a checkbox widget for the Full Length filter
        full_length_action = QAction("Full Length", menu)
        full_length_action.setCheckable(True)
        full_length_action.setChecked(self.full_length_bool)
        full_length_action.toggled.connect(lambda: self.toggle_filter('full_length'))
        full_length_action.setStatusTip("Filter by Full Length")
        full_length_action.setToolTip("Filter by Full Length")

        # Add checkboxes to menu
        menu.addAction(full_length_action)

        menu.exec_(self.table.viewport().mapToGlobal(point))

    def _emit(self, to_emit: str):
        print(f"Event Triggered: {to_emit}")
        eval(f"self.{to_emit}.emit()")

    def get_table_selected(self):
        selected = []
        for row_index in range(self.table.rowCount()):
            if self.table.isRowHidden(row_index):
                continue
            checkbox_widget = self.table.cellWidget(row_index, 3).layout().itemAt(0).widget()
            if checkbox_widget.isChecked():
                selected.append([self.table.item(row_index, column_index).text() for column_index in range(3)])
        return selected

    def update_table(self, data: list[str]):

        # Clear table
        self.table.setRowCount(0)

        # Filter and add rows to table
        for row_data in data:
            row_index = self.table.rowCount()
            self.table.insertRow(row_index)
            for column_index, column_data in enumerate(row_data):
                item = QTableWidgetItem(str(column_data))
                self.table.setItem(row_index, column_index, item)

                # Add checkbox to last column
                checkbox_container = QWidget()
                checkbox_layout = QHBoxLayout()
                checkbox_layout.setAlignment(Qt.AlignCenter) # type: ignore
                checkbox_layout.setContentsMargins(0,0,0,0)
                checkbox_widget = QCheckBox()
                checkbox_layout.addWidget(checkbox_widget)
                checkbox_container.setLayout(checkbox_layout)
                self.table.setCellWidget(row_index, 3, checkbox_container)
        ...


if __name__ == '__main__':
    app = QApplication([])
    main = QMainWindow()
    main.ui = Ui_MainWindow()
    main.ui.setup_ui(main)
    main.show()
    app.exec_()
    ...
