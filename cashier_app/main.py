from PyQt5.QtWidgets import *
from PyQt5.QtCore import *
from PyQt5.QtGui import *
from window import Ui_MainWindow
from mettalum import Metallum_Worker
from excel import XSL_Worker
from youtube import Youtube_Worker
from folder import Folder_Worker
from functools import partial
import time, sys, importlib, os, platform, ctypes

fileDirectory = os.path.dirname(__file__)
# import all UI
package = 'UI'
__ui__ = dict()
# for file_name in os.listdir(f"{fileDirectory}\\{package}"):
#     if file_name.endswith('.py') and file_name.startswith('Ui_') and file_name != '__init__.py':
#         module_name = file_name[:-3]
#         # print(f"{module_name[3:]}")
#         __ui__[module_name[3:]] = importlib.import_module(
#             f"{package}.{module_name}", '.')
        
class MainWindow(QMainWindow):
    def __init__(self):
        super().__init__()

        self.setWindowIcon(QIcon(":SCFS"))
        if platform.system() == 'Windows':
            myappid = 'mycompany.myproduct.subproduct.version' # arbitrary string
            ctypes.windll.shell32.SetCurrentProcessExplicitAppUserModelID(myappid)
        elif platform.system() == 'Linux':
            ...
        else:
            print(f"Taskbar Icon not supported in {platform.system()} OS")

        self.setWindowTitle("My Metallum")

        # initialize the ui
        self.init_ui()
    
    def init_ui(self):

        # Window Setup
        self.ui = Ui_MainWindow()
        self.ui.setup_ui(self)
        self.show()

        ''' Button Events '''
        self.ui.extract_event_signal.connect(
                            partial(self.handle_extract_event))
        self.ui.youtube_event_signal.connect(
                            partial(self.handle_youtube_event))
        self.ui.folder_event_signal .connect(
                            partial(self.handle_folder_event))
        self.ui.excel_event_signal  .connect(
                            partial(self.handle_excel_event))

    def handle_extract_event(self):
        data = [['Setting of the Sun', 'Demo', '2015'], ['Their Malice, Intertwines.', 'Compilation', '2018'], ['Sepitus / Spleen', 'Split', '2019']]
        self.ui.update_table(data)
        return
        _query = self.ui.search_input.text()
        if _query == '':
            print("empty")
            return
        print(_query)
        metallum_worker = Metallum_Worker(_query)
        metallum_worker.albums_json_signal.connect(
                            partial(self.on_extract_finish, metallum_worker))
        metallum_worker.start()
        ...

    def on_extract_finish(self, worker, albums,):
        worker.terminate()
        print("DONE")
        data = self.store_albums(albums)
        print(data)
        self.ui.update_table(data)
        ...

    def store_albums(self, albums: dict):
        self.all_albums_dict = albums
        # print(self.all_albums_dict)
        self.all_albums_list = []
        all_albums = albums['albums']
        for album in all_albums:
            self.all_albums_list.append([album['name'], album['type'], album['year']])
        return self.all_albums_list

    def handle_excel_event(self):
        xsl_worker = XSL_Worker()
        ...

    def handle_youtube_event(self):
        youtube_worker = Youtube_Worker()
        ...

    def handle_folder_event(self):
        selected = self.ui.get_table_selected()
        # folder_worker = Folder_Worker()
        ...


if __name__ == '__main__':
    app = QApplication(sys.argv)
    window = MainWindow()
    window.show()
    app.exec_()
