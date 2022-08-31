#include <WindowsConstants.au3>
#Include <GUIConstantsEx.au3>
#include <GDIPlus.au3>
#include <TrayConstants.au3> ; Required for the $TRAY_ICONSTATE_SHOW constant.
#include <WinAPISysWin.au3>
#include <Misc.au3>
#include <SendMessage.au3>

#Region
#AutoIt3Wrapper_Icon = pin_icon.ico
#EndRegion

Opt("TrayMenuMode", 3) ; The default tray menu items will not be shown and items are not checked when selected. These are options 1 and 2 for TrayMenuMode.
Opt("TrayOnEventMode", 1)
Opt("GUIEventOptions", 1)
Opt("GUIOnEventMode", 1)

HotKeySet("{ESC}", "_Exit")

If _Singleton("test", 1) = 0 Then
	MsgBox(48  + 262144, "Warning", "Running!")
	Exit
EndIf

Global $hGUI = 0
Global $hImage, $iWidth, $iHeight, $hBitmap, $hContext, $hGraphics
Global $drag ;= GUICtrlCreateLabel("", 0, 0, $iWidth, $iHeight, -1, $GUI_WS_EX_PARENTDRAG)
Global $ImageUrl = Null ;= "TK B_221.jpg"
Global Const $iMargin = 4

If FileExists("config.ini") Then
	$ImageUrl = IniRead("config.ini", "Path image", "URLImage", Default)
EndIf

If $ImageUrl = "" Then
	$ImageUrl = FileOpenDialog('Open Image', @ScriptDir, "Images (*.jpg;*.bmp)", BitOR($FD_FILEMUSTEXIST, $FD_PATHMUSTEXIST))
	;_Open_image()
EndIf

_Display()

Func _Display()
	_GDIPlus_Startup()

	_Read_Image()

	Global $hGUI = GUICreate("  ", $iWidth, $iHeight,  @DesktopWidth - $iWidth,  0 , $WS_POPUP, $WS_EX_TOOLWINDOW)
	GUISetState(@SW_SHOW)

	;GUICtrlSetBkColor(-1, 0x000000)

	Global $iHide = TrayCreateItem("Open File")
	TrayItemSetOnEvent(-1, "_Open_image")

	TrayCreateItem("") ; Create a separator line.
	Global $iLock = TrayCreateItem("Lock")
	TrayItemSetOnEvent(-1, "_Lock")
	$drag = GUICtrlCreateLabel("", 0, 0, $iWidth, $iHeight, -1, $GUI_WS_EX_PARENTDRAG)
	GUICtrlSetBkColor(-1, 0x000000)
	;TrayItemSetState($iLock, $TRAY_CHECKED)

	TrayCreateItem("") ; Create a separator line.
	Global $iHide = TrayCreateItem("Hide")
	TrayItemSetOnEvent(-1, "_Hide")

	TrayCreateItem("") ; Create a separator line.
	Global $iOnTop = TrayCreateItem("Set on top")
	TrayItemSetOnEvent(-1, "_SetOnTop")
	;_SetOnTop()

	TrayCreateItem("") ; Create a separator line.
	Global $idAbout = TrayCreateItem("About")
	TrayItemSetOnEvent(-1, "_About")

	TrayCreateItem("") ; Create a separator line.
	Global $idExit = TrayCreateItem("Exit")
	TrayItemSetOnEvent(-1, "_Exit")
	TraySetState($TRAY_ICONSTATE_SHOW) ; Show the tray menu.
	WinSetTrans($hGUI, "", 150)

	$hGraphics = _GDIPlus_GraphicsCreateFromHWND($hGui)

	;~ _GDIPlus_GraphicsDrawImage($hGraphics, $hBitmap, 0,0)
	display_image()

	While 1
		Sleep(1000)
;~ 		Local $pos = WinGetPos($hGUI)
;~ 		WinMove($hGUI, "", $pos[0]-20, $pos[1], $iWidth, $iHeight, 1)
	WEnd

	_GDIPlus_GraphicsDispose($hContext)
	_GDIPlus_BitmapDispose($hBitmap)
	_GDIPlus_ImageDispose($hImage)
	_GDIPlus_GraphicsDispose($hGraphics)
	_GDIPlus_Shutdown()


	Exit
EndFunc

Func _Read_Image()
	ConsoleWrite($ImageUrl)
	$hImage = _GDIPlus_ImageLoadFromFile($ImageUrl)
	$iWidth = _GDIPlus_ImageGetWidth($hImage)*0.7
	$iHeight = _GDIPlus_ImageGetHeight($hImage)*0.7

	$hBitmap = _GDIPlus_BitmapCreateFromScan0($iWidth, $iHeight)
	$hContext = _GDIPlus_ImageGetGraphicsContext($hBitmap)
	_GDIPlus_GraphicsDrawImageRect($hContext, $hImage, 0, 0, $iWidth, $iHeight)
	_GDIPlus_ImageDispose($hImage)
;~ 	If $hGUI <> 0 Then
;~ 		Local $pos = WinGetPos($hGUI)
;~ 		WinMove($hGUI, "", @DesktopWidth - $iWidth, $pos[1], $iWidth, $iHeight, 1)
;~ 		$hGraphics = _GDIPlus_GraphicsCreateFromHWND($hGui)
;~ 	EndIf
EndFunc

Func display_image()
	GUISetState(@SW_SHOW, $hGUI)
	_GDIPlus_GraphicsDrawImage($hGraphics, $hBitmap, 0,0)
	_WinAPI_SetWindowPos($hGUI, $HWND_BOTTOM,0, 0, 0, 0, BitOR($SWP_FRAMECHANGED, $SWP_NOMOVE, $SWP_NOSIZE))
EndFunc

Func _Open_image()
	$ImageUrl = FileOpenDialog('Open Image', @ScriptDir, "Images (*.jpg;*.bmp)", BitOR($FD_FILEMUSTEXIST, $FD_PATHMUSTEXIST))
	If Not @error Then
		_GDIPlus_GraphicsDispose($hContext)
		_GDIPlus_BitmapDispose($hBitmap)
		_GDIPlus_ImageDispose($hImage)
		_GDIPlus_GraphicsDispose($hGraphics)
	 	_Read_Image()
;~ 		Local $pos = WinGetPos($hGUI)
;~ 		WinMove($hGUI, "", $pos[0], $pos[1], $iWidth, $iHeight, 1)
	 	display_image()
		TrayItemSetState($iHide, $TRAY_UNCHECKED)
	EndIf
EndFunc

Func _Lock()
	If TrayItemGetState($iLock) = ($TRAY_ENABLE + $TRAY_UNCHECKED) Then
		ConsoleWrite("UnLooked" & @CRLF)
		GUICtrlDelete($drag)
		TrayItemSetState($iLock, $TRAY_CHECKED)
	ElseIf TrayItemGetState($iLock) = ($TRAY_ENABLE + $TRAY_CHECKED) Then
		ConsoleWrite("Looked" & @CRLF)
		$drag = GUICtrlCreateLabel("", 0, 0, $iWidth, $iHeight, -1, $GUI_WS_EX_PARENTDRAG)
		GUICtrlSetBkColor(-1, 0x000000)
		TrayItemSetState($iLock, $TRAY_UNCHECKED)
	EndIf
	display_image()
EndFunc

; Hide funciton
Func _Hide()
	If TrayItemGetState($iHide) = ($TRAY_ENABLE + $TRAY_CHECKED) Then
		ConsoleWrite("UnHide")
		display_image()
		TrayItemSetState($iHide, $TRAY_UNCHECKED)
		TrayItemSetState($iLock, $TRAY_ENABLE)
	ElseIf TrayItemGetState($iHide) = ($TRAY_ENABLE + $TRAY_UNCHECKED) Then
		ConsoleWrite("Hide")
		GUISetState(@SW_HIDE, $hGUI)
		TrayItemSetState($iHide, $TRAY_CHECKED)
		TrayItemSetState($iLock, $TRAY_DISABLE)
	EndIf
EndFunc

;Set programe on Top
Func _SetOnTop()
	If TrayItemGetState($iOnTop) = ($TRAY_ENABLE  + $TRAY_CHECKED) Then
		WinSetOnTop($hGUI,"", $WINDOWS_NOONTOP)
		TrayItemSetState($iOnTop, $TRAY_UNCHECKED)
	ElseIf TrayItemGetState($iOnTop) = ($TRAY_ENABLE  + $TRAY_UNCHECKED) Then
		WinSetOnTop($hGUI, "",$WINDOWS_ONTOP)
		TrayItemSetState($iOnTop, $TRAY_CHECKED)
	EndIf
EndFunc

;About funciton
Func _About()
	MsgBox($MB_SYSTEMMODAL, "",	"Version: " & @AutoItVersion & @CRLF & _
					"Install Path: " & StringLeft(@AutoItExe, StringInStr(@AutoItExe, "\", $STR_NOCASESENSEBASIC, -1) - 1)) ; Find the folder of a full path.
EndFunc

;Exit funciton
Func _Exit()
	IniWrite( @ScriptDir & "\config.ini", "Path image", "URLImage", $ImageUrl)
	FileSetAttrib("config.ini", "+H")
	_GDIPlus_GraphicsDispose($hContext)
	_GDIPlus_BitmapDispose($hBitmap)
	_GDIPlus_ImageDispose($hImage)
	_GDIPlus_GraphicsDispose($hGraphics)
	_GDIPlus_Shutdown()
	GUIDelete($hGUI)
	Exit
EndFunc
