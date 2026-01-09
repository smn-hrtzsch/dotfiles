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

; Global (außer WezTerm): Alt+C -> Ctrl+C, Alt+V -> Ctrl+V
; Dies emuliert das Mac-Verhalten in allen anderen Windows-Apps
#HotIf not WinActive("ahk_exe wezterm-gui.exe")
!c::Send "^c"
!v::Send "^v"
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


; ==============================================================================
; APP SPECIFIC HOTKEYS
; ==============================================================================

; Shift+Enter Fix für CLI (Terminal, CMD, PowerShell)
#HotIf WinActive("ahk_exe WindowsTerminal.exe") or WinActive("ahk_class ConsoleWindowClass")

+Enter::
{
    Send "^j"
}

#HotIf
