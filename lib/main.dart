
import sys
import os 

from PySide6.QtWidgets import (
    QApplication, QWidget, QVBoxLayout,
    QPushButton, QTextEdit, QLabel, QSplashScreen
)

from PySide6.QtGui import QPixmap, QIcon 
from PySide6.QtCore import QTimer

from analyzer import analyze
def resource_path(relative_path):
    base_path = getattr(sys, "_MEIPASS", os.path.abspath("."))
    return os.path.join(base_path, relative_path)



class QRApp(QWidget):
    def __init__(self):
        super().__init__()
        self.setWindowTitle("QR Anti-Scam")
        self.setWindowIcon(QIcon(resource_path("assets/icon.png")))
        self.setMinimumWidth(420)

        layout = QVBoxLayout()

        self.info = QLabel("Paste QR content or link below:")
        layout.addWidget(self.info)

        self.input = QTextEdit()
        self.input.setPlaceholderText("https://example.com")
        layout.addWidget(self.input)

        self.scan_btn = QPushButton("Analyze")
        self.scan_btn.clicked.connect(self.run_analysis)
        layout.addWidget(self.scan_btn)

        self.result = QLabel("")
        self.result.setWordWrap(True)
        layout.addWidget(self.result)

        self.setLayout(layout)
        self.apply_dark_theme()

    def run_analysis(self):
        text = self.input.toPlainText().strip()
        if not text:
            self.result.setText("")
            return

        result = analyze(text)

        verdict = result["verdict"]
        reasons_list = result.get("reasons", [])
        reasons =  "<br>• ".join(reasons_list) if reasons_list else ""
        score = result.get("score", 0)

        # IMPORTANT: cheile trebuie să fie EXACT ca verdict-ul returnat din analyzer.py
        color = {
            "SAFE": "#00ff9c",
            "LOW RISK": "#00ff9c",
            "SUSPICIOUS": "#ffcc00",
            "DANGEROUS": "#ff4c4c",
        }.get(verdict, "#e6e6e6")

        self.result.setText(
            f"<div style='margin-top:10px;'>"
            f"<h2 style='color:{color};'>{verdict}</h2>"
            f"<p style='margin:0; opacity:0.9;'><b>Score:</b> {score}</p>"
            f"<b>Details:</b>{reasons}"
            f"</div>"
        )




    def apply_dark_theme(self):
        self.setStyleSheet("""
            QWidget {
                background-color: #0b0b0f;
                color: #e6e6e6;
                font-size: 14px;
            }
            QPushButton {
                background-color: #1a1a22;
                padding: 10px;
                border-radius: 6px;
            }
            QTextEdit {
                background-color: #111118;
                border: 1px solid #222;
            }
        """)

if __name__ == "__main__":
    app = QApplication(sys.argv)

    # Splash screen
    splash_pix = QPixmap(resource_path("assets/splash.png"))  # imaginea ta
    splash = QSplashScreen(splash_pix)
    splash.show()

    # Fereastra principală
    window = QRApp()

    # După 1.5 secunde se închide splash-ul și apare aplicația
    def show_main():
        window.show()
        splash.finish(window)

    QTimer.singleShot(2000, show_main)


    sys.exit(app.exec())
