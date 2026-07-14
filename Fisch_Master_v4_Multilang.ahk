; ==============================================================================
; ФИНАЛЬНЫЙ ПРОЕКТ: Умный макрос для Roblox (Fisch) с поддержкой двух языков
; Язык: AutoHotkey v1.1+ (Windows)
; Версия: v4.0 Multilang
; ==============================================================================

#NoEnv
#SingleInstance Force
SetDefaultMouseSpeed, 0
SetTitleMatchMode, 2
CoordMode, Mouse, Screen
CoordMode, Pixel, Screen

; --- Инициализация переменных по умолчанию ---
Global MacroActive := False
Global AreaConfigured := False
Global SearchX1 := 0, SearchY1 := 0, SearchX2 := 0, SearchY2 := 0
Global CurrentLang := "RU" ; Текущий язык (по умолчанию Русский)

Global ColorBar := "0xFFFFFF"     ; Цвет белой полоски по умолчанию
Global ColorFish := "0x808080"    ; Цвет серой рыбки по умолчанию
Global ColorVariation := 25       ; Допустимая погрешность оттенка

Global KeyStart := "F1"
Global KeyStop := "F2"
Global KeyCalib := "F4"

; --- Создание графического интерфейса (GUI) ---
Gui, +AlwaysOnTop -MaximizeBox
Gui, Color, F0F0F0
Gui, Font, s10, Segoe UI

; Выбор языка в самом верху
Gui, Add, Text, x15 y15 w120 h20 vLblLang, Язык / Language:
Gui, Add, DropDownList, x140 y12 w195 gChangeLanguage vLangSelect Choose1, Русский|English

; Блок 1. Управление клавишами
Gui, Add, GroupBox, x10 y45 w340 h115 vGrpKeys, 1. Управление (Горячие клавиши)
Gui, Add, Text, x25 y70 w110 h20 vLblStart, Запуск рыбалки:
Gui, Add, Hotkey, x140 y67 w195 h20 vKeyStart, %KeyStart%
Gui, Add, Text, x25 y97 w110 h20 vLblStop, Остановка:
Gui, Add, Hotkey, x140 y94 w195 h20 vKeyStop, %KeyStop%
Gui, Add, Text, x25 y124 w110 h20 vLblCalib, Калибровка зоны:
Gui, Add, Hotkey, x140 y121 w195 h20 vKeyCalib, %KeyCalib%

; Блок 2. Настройка цветов с функцией "Пипетка"
Gui, Add, GroupBox, x10 y170 w340 h155 vGrpColors, 2. Цвета и Пипетка (Выбор с экрана)
Gui, Add, Text, x25 y195 w100 h20 vLblBar, Белая полоска:
Gui, Add, Edit, x120 y192 w100 h20 vColorBar, %ColorBar%
Gui, Add, Button, x225 y190 w110 h24 vBtnPickBar gPickBarColor, 🔍 Выбрать цвет

Gui, Add, Text, x25 y225 w100 h20 vLblFish, Серая рыбка:
Gui, Add, Edit, x120 y222 w100 h20 vColorFish, %ColorFish%
Gui, Add, Button, x225 y220 w110 h24 vBtnPickFish gPickFishColor, 🔍 Выбрать цвет

Gui, Add, Text, x25 y255 w100 h20 vLblVariation, Погрешность:
Gui, Add, Slider, x120 y255 w215 h25 vColorVariation Range0-100 ToolTip, %ColorVariation%
Gui, Add, Text, x25 y290 w310 h25 vColorStatus, Нажмите "Выбрать", затем кликните по объекту в игре.

; Кнопка активации
Gui, Add, Button, x10 y335 w340 h45 vBtnApply gApplySettings,  СОХРАНИТЬ И АКТИВИРОВАТЬ 

; Блок 3. Статус и информация
Gui, Add, GroupBox, x10 y390 w340 h90 vGrpStatus, 3. Текущее состояние
Gui, Add, Text, x25 y415 w310 h20 vStatusText, Status: Ожидание сохранения настроек...
Gui, Add, Text, x25 y445 w310 h20 vCoordText, Зона поиска: Не настроена

Gui, Show, w360 h495, Fisch Master Elite v4.0 (RU)
return

; ==============================================================================
; ДИНАМИЧЕСКАЯ СМЕНА ЯЗЫКА (ИНТЕРФЕЙС)
; ==============================================================================

ChangeLanguage:
    Gui, Submit, NoHide
    if (LangSelect = "Русский")
    {
        CurrentLang := "RU"
        GuiControl,, LblLang, Язык / Language:
        GuiControl,, GrpKeys, 1. Управление (Горячие клавиши)
        GuiControl,, LblStart, Запуск рыбалки:
        GuiControl,, LblStop, Остановка:
        GuiControl,, LblCalib, Калибровка зоны:
        
        GuiControl,, GrpColors, 2. Цвета и Пипетка (Выбор с экрана)
        GuiControl,, LblBar, Белая полоска:
        GuiControl,, LblFish, Серая рыбка:
        GuiControl,, BtnPickBar, 🔍 Выбрать цвет
        GuiControl,, BtnPickFish, 🔍 Выбрать цвет
        GuiControl,, LblVariation, Погрешность:
        GuiControl,, ColorStatus, Нажмите "Выбрать", затем кликните по объекту в игре.
        
        GuiControl,, BtnApply,  СОХРАНИТЬ И АКТИВИРОВАТЬ 
        GuiControl,, GrpStatus, 3. Текущее состояние
        
        if (!MacroActive)
            GuiControl,, StatusText, Статус: Ожидание сохранения настроек...
        else
            GuiControl,, StatusText, Статус: МАКРОС РАБОТАЕТ (Автоматическая рыбалка)
            
        if (!AreaConfigured)
            GuiControl,, CoordText, Зона поиска: Не настроена
        else
            GuiControl,, CoordText, Зона поиска: X[%SearchX1% - %SearchX2%] Y[%SearchY1% - %SearchY2%]
            
        WinSetTitle, Fisch Master Elite v4.0 (RU)
    }
    else
    {
        CurrentLang := "EN"
        GuiControl,, LblLang, Language / Язык:
        GuiControl,, GrpKeys, 1. Controls (Hotkeys)
        GuiControl,, LblStart, Start Fishing:
        GuiControl,, LblStop, Stop:
        GuiControl,, LblCalib, Calibrate Zone:
        
        GuiControl,, GrpColors, 2. Colors & Pipette (Screen Pick)
        GuiControl,, LblBar, White Bar:
        GuiControl,, LblFish, Grey Fish:
        GuiControl,, BtnPickBar, 🔍 Pick Color
        GuiControl,, BtnPickFish, 🔍 Pick Color
        GuiControl,, LblVariation, Tolerance:
        GuiControl,, ColorStatus, Click "Pick", then click on the object in the game.
        
        GuiControl,, BtnApply,  SAVE AND ACTIVATE 
        GuiControl,, GrpStatus, 3. Current Status
        
        if (!MacroActive)
            GuiControl,, StatusText, Status: Waiting for settings to be saved...
        else
            GuiControl,, StatusText, Status: MACRO IS ACTIVE (Auto Fishing)
            
        if (!AreaConfigured)
            GuiControl,, CoordText, Search Zone: Not configured
        else
            GuiControl,, CoordText, Search Zone: X[%SearchX1% - %SearchX2%] Y[%SearchY1% - %SearchY2%]
            
        WinSetTitle, Fisch Master Elite v4.0 (EN)
    }
return

; ==============================================================================
; ПОДПРОГРАММЫ И ЛОГИКА ИНТЕРФЕЙСА
; ==============================================================================

PickBarColor:
    if (CurrentLang = "RU")
        ToolTip, НАВЕДИТЕ КУРСОР НА БЕЛУЮ ПОЛОСКУ И КЛИКНИТЕ ЛКМ, 10, 10
    else
        ToolTip, HOVER CURSOR OVER THE WHITE BAR AND CLICK LBUTTON, 10, 10
        
    KeyWait, LButton, D
    MouseGetPos, MouseX, MouseY
    PixelGetColor, PickedColor, %MouseX%, %MouseY%, RGB
    ToolTip
    GuiControl,, ColorBar, %PickedColor%
    
    if (CurrentLang = "RU")
        GuiControl,, ColorStatus, Белая полоска успешно выбрана! (%PickedColor%)
    else
        GuiControl,, ColorStatus, White bar successfully picked! (%PickedColor%)
        
    KeyWait, LButton
return

PickFishColor:
    if (CurrentLang = "RU")
        ToolTip, НАВЕДИТЕ КУРСОР НА СЕРУЮ РЫБКУ И КЛИКНИТЕ ЛКМ, 10, 10
    else
        ToolTip, HOVER CURSOR OVER THE GREY FISH AND CLICK LBUTTON, 10, 10
        
    KeyWait, LButton, D
    MouseGetPos, MouseX, MouseY
    PixelGetColor, PickedColor, %MouseX%, %MouseY%, RGB
    ToolTip
    GuiControl,, ColorFish, %PickedColor%
    
    if (CurrentLang = "RU")
        GuiControl,, ColorStatus, Серая рыбка успешно выбрана! (%PickedColor%)
    else
        GuiControl,, ColorStatus, Grey fish successfully picked! (%PickedColor%)
        
    KeyWait, LButton
return

ApplySettings:
    Gui, Submit, NoHide
    if (OldKeyStart) {
        Hotkey, %OldKeyStart%, Off, UseErrorLevel
        Hotkey, %OldKeyStop%, Off, UseErrorLevel
        Hotkey, %OldKeyCalib%, Off, UseErrorLevel
    }
    
    Hotkey, %KeyStart%, StartMacro, On, UseErrorLevel
    if (ErrorLevel) {
        if (CurrentLang = "RU")
            MsgBox, 48, Ошибка, Не удалось зарегистрировать клавишу запуска: %KeyStart%
        else
            MsgBox, 48, Error, Failed to register start key: %KeyStart%
        return
    }
    Hotkey, %KeyStop%, StopMacro, On, UseErrorLevel
    Hotkey, %KeyCalib%, CalibrateArea, On, UseErrorLevel
    
    OldKeyStart := KeyStart
    OldKeyStop := KeyStop
    OldKeyCalib := KeyCalib
    
    if (CurrentLang = "RU") {
        GuiControl,, StatusText, Статус: Готов. Нажмите %KeyCalib% для калибровки шкалы!
        MsgBox, 64, Успешно, Настройки сохранены!`nЗапуск: %KeyStart%`nОстановка: %KeyStop%`nКалибровка: %KeyCalib%, 3
    } else {
        GuiControl,, StatusText, Status: Ready. Press %KeyCalib% to calibrate the bar!
        MsgBox, 64, Success, Settings saved!`nStart: %KeyStart%`nStop: %KeyStop%`nCalibrate: %KeyCalib%, 3
    }
return

CalibrateArea:
    MacroActive := False
    
    if (CurrentLang = "RU") {
        GuiControl,, StatusText, Статус: Калибровка... ШАГ 1
        ToolTip, ШАГ 1: Кликните ЛКМ по САМОМУ ЛЕВОМУ краю шкалы мини-игры., 10, 10
    } else {
        GuiControl,, StatusText, Status: Calibrating... STEP 1
        ToolTip, STEP 1: Left-click on the FAR-LEFT edge of the mini-game bar., 10, 10
    }
    KeyWait, LButton, D
    MouseGetPos, SearchX1, SearchY1
    KeyWait, LButton
    Sleep, 200
    
    if (CurrentLang = "RU") {
        GuiControl,, StatusText, Статус: Калибровка... ШАГ 2
        ToolTip, ШАГ 2: Кликните ЛКМ по САМОМУ ПРАВОМУ краю шкалы мини-игры., 10, 10
    } else {
        GuiControl,, StatusText, Status: Calibrating... STEP 2
        ToolTip, STEP 2: Left-click on the FAR-RIGHT edge of the mini-game bar., 10, 10
    }
    KeyWait, LButton, D
    MouseGetPos, SearchX2, SearchY2
    KeyWait, LButton
    
    AreaConfigured := True
    ToolTip
    
    if (CurrentLang = "RU") {
        GuiControl,, StatusText, Статус: Калибровка успешно завершена!
        GuiControl,, CoordText, Зона поиска: X[%SearchX1% - %SearchX2%] Y[%SearchY1% - %SearchY2%]
    } else {
        GuiControl,, StatusText, Status: Calibration successfully completed!
        GuiControl,, CoordText, Search Zone: X[%SearchX1% - %SearchX2%] Y[%SearchY1% - %SearchY2%]
    }
return

; ==============================================================================
; ОСНОВНОЙ АЛГОРИТМ РЫБАЛКИ
; ==============================================================================

StartMacro:
    if (!AreaConfigured) {
        if (CurrentLang = "RU")
            MsgBox, 48, Внимание, Сначала проведите калибровку шкалы в игре (Клавиша: %KeyCalib%)!, 3
        else
            MsgBox, 48, Attention, Calibrate the bar in game first (Key: %KeyCalib%)!, 3
        return
    }
    Gui, Submit, NoHide
    MacroActive := True
    
    if (CurrentLang = "RU")
        GuiControl,, StatusText, Статус: МАКРОС РАБОТАЕТ (Автоматическая рыбалка)
    else
        GuiControl,, StatusText, Status: MACRO IS ACTIVE (Auto Fishing)
    
    Loop
    {
        if (!MacroActive)
            break
            
        ; Заброс
        Click, Down
        Sleep, 1000
        Click, Up
        
        ; Ожидание поклевки
        Sleep, 4000 
        
        ; Shake
        Loop, 15 {
            if (!MacroActive)
                break
            Click
            Sleep, 150
        }
        
        ; Мини-игра (Удержание)
        StartTick := A_TickCount
        Loop
        {
            if (!MacroActive or (A_TickCount - StartTick > 15000))
                break
                
            PixelSearch, FishX, FishY, %SearchX1%, %SearchY1%, %SearchX2%, %SearchY2%, %ColorFish%, %ColorVariation%, Fast RGB
            FishFound := (ErrorLevel = 0)
            
            PixelSearch, BarX, BarY, %SearchX1%, %SearchY1%, %SearchX2%, %SearchY2%, %ColorBar%, %ColorVariation%, Fast RGB
            BarFound := (ErrorLevel = 0)
            
            if (FishFound and BarFound) 
            {
                Distance := FishX - BarX
                
                if (Distance > 30) {
                    Click, Down
                    Sleep, 65
                } 
                else if (Distance > 5) {
                    Click, Down
                    Sleep, 22
                    Click, Up
                    Sleep, 10
                }
                else if (Distance < -30) {
                    Click, Up
                    Sleep, 65
                }
                else if (Distance < -5) {
                    Click, Up
                    Sleep, 22
                }
                else {
                    Click, Down
                    Sleep, 12
                    Click, Up
                    Sleep, 12
                }
            }
            else if (FishFound and !BarFound)
            {
                Click, Down
                Sleep, 30
            }
            
            Sleep, 10 
        }
        
        Click, Up 
        Sleep, 2500 
    }
return

StopMacro:
    MacroActive := False
    Click, Up
    if (CurrentLang = "RU")
        GuiControl,, StatusText, Статус: Остановлен (Пауза)
    else
        GuiControl,, StatusText, Status: Stopped (Pause)
return

GuiClose:
    ExitApp
