#Requires AutoHotkey v2.0

; ==============================================================================
; SETTINGS & INITIALIZATION
; ==============================================================================

; Caps Lock deaktivieren, damit es nicht blinkt
SetCapsLockState "AlwaysOff"

; ==============================================================================
; HYPER KEY (CapsLock -> Ctrl+Shift+Alt+Win) + ESCAPE (bei kurzem Tippen)
; ==============================================================================

*CapsLock::
{
    Send "{Blind}{Ctrl Down}{Shift Down}{Alt Down}{LWin Down}"
    KeyWait "CapsLock"
    Send "{Blind}{Ctrl Up}{Shift Up}{Alt Up}{LWin Up}"

    if (A_PriorKey == "CapsLock")
    {
        Send "{Esc}"
    }
}

; Hyper + H: Minimiert aktuelles Fenster
!h::WinMinimize "A"

; Hyper + PgDn: Minimiert ALLE Fenster
^+!#PgDn::WinMinimizeAll


; ==============================================================================
; MAC-STYLE COPY & PASTE (Alt+C / Alt+V)
; ==============================================================================

; In WezTerm: Alt+C -> Ctrl+Shift+C (Copy), Alt+V -> Ctrl+Shift+V (Paste)
; Voraussetzung: WezTerm ist so konfiguriert, dass Ctrl+Shift+C/V Copy/Paste sind
#HotIf WinActive("ahk_exe wezterm-gui.exe")
!c::Send "^+c"
!v::Send "^+v"
#HotIf

; Global (außer Terminals): Alt+C -> Ctrl+C, Alt+V -> Ctrl+V, etc.
; Dies emuliert das Mac-Verhalten in allen anderen Windows-Apps
#HotIf not (WinActive("ahk_exe wezterm-gui.exe") or WinActive("ahk_exe WindowsTerminal.exe") or WinActive("ahk_class ConsoleWindowClass"))
!c::Send "^c"
!v::Send "^v"
!a::Send "^a"
!z::Send "^z"
!y::Send "^y"
#HotIf


; ==============================================================================
; SONDERZEICHEN & TEXT
; ==============================================================================

; 1. Win + L für @ Zeichen
; VORAUSSETZUNG: Windows-Sperre muss in Registry deaktiviert sein!
#l::Send "{Text} @"

; Optionale Backup-Lösung (Mac-Style Alt+L)
!l::Send "{Text} @"


; 2. Tilde (~) Mapping
; Variante A: Alt + n (Mac-Style)
!n::Send "{Text}~"

; Variante B: AltGr + n (Dein neuer Wunsch)
; <^>! steht für AltGr (Left Ctrl + Right Alt)
<^>!n::Send "{Text}~"


; 3. Mac-Style Screenshot (Alt+Shift+S -> Win+Shift+S)
!+s::Send "#+s"

; 4. Vertikaler Strich mit Alt + 7
!7:: Send "{Text}|" 

; 5. Backslash mit Alt + Shift + 7
!+7:: Send "{Text}\"
#HotIf

; ==============================================================================
; NAVIGATION & DELETION (Mac-Style)
; ==============================================================================

; 1. Zeilenanfang/Ende mit ALT + PFEIL (Global)
!Left::Send "{Home}"
!Right::Send "{End}"
!+Left::Send "+{Home}"
!+Right::Send "+{End}"

; 2. Zeile löschen mit ALT + BACKSPACE (Global)
!Backspace::
{
    if WinActive("ahk_exe wezterm-gui.exe") or WinActive("ahk_exe WindowsTerminal.exe") or WinActive("ahk_class ConsoleWindowClass")
    {
        Send "^u"
    }
    else
    {
        Send "{Home}+{End}{BackSpace}"
    }
}

; Nur für Terminals (WezTerm, Windows Terminal, CMD/PowerShell)
#HotIf WinActive("ahk_exe wezterm-gui.exe") or WinActive("ahk_exe WindowsTerminal.exe") or WinActive("ahk_class ConsoleWindowClass")

; 1. Wortweise springen mit WIN + PFEIL (statt Option+Pfeil auf Mac)
; Überschreibt Windows Snap (Win+Left/Right)!
*#Left::Send "^{Left}"
*#Right::Send "^{Right}"

; 2. Wort löschen mit WIN + BACKSPACE
; Sendet Ctrl+W (Standard in Unix Shells)
#Backspace::Send "^w"

; 3. Shift+Enter -> Neue Zeile ohne Ausführen (Ctrl+J)
+Enter::Send "^j"

#HotIf


