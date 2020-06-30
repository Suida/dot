; Remap `Ctrl` to `Caps`
CapsLock::RCtrl
AppsKey & 0::CapsLock

; On 60%-size keyboard, ~/` and Esc are the same key and their
; input mode is altered by Fn which is really noob. So, it is 
; better to remap them.
AppsKey & Escape::`
Shift & Escape::~

; There is no Del key on my keyboard
AppsKey & BS::Delete

; Directional keys are also hard to type.
LAlt & k::Send {Up}
LAlt & j::Send {Down}
LAlt & h::Send {Left}
LAlt & l::Send {Right}
LCtrl & h::Send {Ctrl down}{LWin down}{Left}{LWin up}{Ctrl up}
LCtrl & l::Send {Ctrl down}{LWin down}{Right}{LWin up}{Ctrl up}
