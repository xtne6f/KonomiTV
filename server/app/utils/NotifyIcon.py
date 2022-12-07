
import threading
import win32api
import win32con
import win32gui
from typing import Callable


class NotifyIcon:
    """
    Windows の通知領域にアイコンを作成して管理する
    """

    def __init__(self, icon_path: str, tip: str, onclick: Callable | None = None, commands: dict | None = None) -> None:
        self.__icon_path = icon_path
        self.__tip = tip
        self.__onclick = onclick
        self.__commands: dict = commands or {}
        self.__hwnd = 0
        self.__thread = threading.Thread(target = self.__worker)
        self.__thread.start()
        while self.__hwnd == 0 and self.__thread.is_alive():
            self.__thread.join(0.01)
        if self.__hwnd == 0:
            raise RuntimeError('NotifyIcon creation failed')

    def close(self) -> None:
        """ オブジェクトを破棄する """
        if self.__thread.is_alive():
            win32gui.PostMessage(self.__hwnd, win32con.WM_CLOSE, 0, 0)
            self.__thread.join()

    @staticmethod
    def generateConsoleCtrlCEvent() -> None:
        """ プロセスグループ全体に Ctrl+C を送る """
        win32api.GenerateConsoleCtrlEvent(win32con.CTRL_C_EVENT, 0)

    @staticmethod
    def shellExecuteOpen(file: str, params: str | None = None, directory: str | None = None) -> bool:
        """ アプリケーションやファイルを開く """
        try:
            win32api.ShellExecute(0, 'open', file, params, directory, win32con.SW_SHOWNORMAL)
        except win32api.error:
            return False
        return True

    def __worker(self) -> None:
        msg_taskbar_created = win32gui.RegisterWindowMessage('TaskbarCreated')
        hinst = win32api.GetModuleHandle()
        self.__hicon = win32gui.LoadImage(hinst, self.__icon_path, win32con.IMAGE_ICON, 0, 0, win32con.LR_LOADFROMFILE | win32con.LR_DEFAULTSIZE)
        wc = win32gui.WNDCLASS()
        wc.hInstance = hinst
        # プロセス内のほかのクラス名と一致してはならないので乱数 UUID を付加
        wc.lpszClassName = 'PyNotifyIcon-FD546897-ECF0-4BFF-9845-0DE2AAECB33C'
        wc.lpfnWndProc = {
            msg_taskbar_created: self.__onTaskbarCreated,
            win32con.WM_DESTROY: self.__onDestroy,
            win32con.WM_COMMAND: self.__onCommand,
            win32con.WM_APP: self.__onTaskbarCreated,
            win32con.WM_APP + 1: self.__onNotify
        }
        atom = win32gui.RegisterClass(wc)
        try:
            self.__hwnd = win32gui.CreateWindow(atom, 'PyNotifyIcon', 0, 0, 0, 0, 0, 0, 0, hinst, None)
        except:
            win32gui.UnregisterClass(atom, hinst)
            raise
        win32gui.SendMessage(self.__hwnd, win32con.WM_APP, 0, 0)
        win32gui.PumpMessages()
        win32gui.UnregisterClass(atom, hinst)

    def __onTaskbarCreated(self, hwnd: int, msg: int, wparam: int, lparam: int) -> int:
        nid = (hwnd, 1, win32gui.NIF_MESSAGE | win32gui.NIF_ICON | win32gui.NIF_TIP, win32con.WM_APP + 1, self.__hicon, self.__tip)
        try:
            win32gui.Shell_NotifyIcon(win32gui.NIM_ADD, nid)
        except win32gui.error:
            pass
        return 0

    def __onDestroy(self, hwnd: int, msg: int, wparam: int, lparam: int) -> int:
        try:
            win32gui.Shell_NotifyIcon(win32gui.NIM_DELETE, (hwnd, 1))
        except win32gui.error:
            pass
        win32gui.PostQuitMessage(0)
        return 0

    def __onCommand(self, hwnd: int, msg: int, wparam: int, lparam: int) -> int:
        id = 1000
        for command in self.__commands.values():
            if win32api.LOWORD(wparam) == id:
                if command:
                    command()
                break
            id += 1
        return 0

    def __onNotify(self, hwnd: int, msg: int, wparam: int, lparam: int) -> int:
        submsg = win32api.LOWORD(lparam)
        if submsg == win32con.WM_LBUTTONUP:
            if self.__onclick:
                self.__onclick()
        elif submsg == win32con.WM_RBUTTONUP:
            menu = win32gui.CreatePopupMenu()
            id = 1000
            for name in self.__commands:
                win32gui.AppendMenu(menu, (win32con.MF_SEPARATOR if name.startswith('---') else win32con.MF_STRING), id, name)
                id += 1
            point = win32gui.GetCursorPos()
            win32gui.SetForegroundWindow(hwnd)
            win32gui.TrackPopupMenu(menu, win32con.TPM_LEFTALIGN, point[0], point[1], 0, hwnd, None)
        return 0
