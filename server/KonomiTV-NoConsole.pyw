
from ctypes import windll, c_wchar_p
from pathlib import Path

SW_HIDE = 0

windll.shell32.ShellExecuteW(
    0,
    c_wchar_p('open'),
    c_wchar_p('.\\thirdparty\\Python\\python.exe'),
    c_wchar_p('-m poetry run python -X utf8 KonomiTV.py --notifyicon --delaysec 8'),
    c_wchar_p(str(Path(__file__).resolve().parent)),
    SW_HIDE
)
