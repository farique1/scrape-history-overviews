;~ Scrape History Overviews v0.5
;~ Scans Gaming History’s History.dat to collect game information and export them in the Attract Mode
;~ overview format. SHO is compatible with revision 1.97 of History.dat but seems to work up to rev 1.99.
;~
;~ Copyright (C) 2018 - Fred Rique (farique) https://github.com/farique1

#include <Array.au3>
#include <File.au3>
#include <ButtonConstants.au3>
#include <ComboConstants.au3>
#include <EditConstants.au3>
#include <GUIConstantsEx.au3>
#include <StaticConstants.au3>
#include <WindowsConstants.au3>
#include <GuiComboBox.au3>

#Region GUI
$cSHO = GUICreate("Scrape History Overviews", 600, 190, -1, -1)
$bHistory = GUICtrlCreateButton("History File", 16, 12, 75, 25)
GUICtrlSetTip(-1, "Point to the History.dat file to read")
$hHistory = GUICtrlCreateInput("", 100, 13, 370, 23)
GUICtrlCreateLabel("Compatible with History.dat Rev 1.97", 480, 11, 100, 30)
;~ GUICtrlSetColor(-1, 0x707070)
$bRomsList = GUICtrlCreateButton("Roms List", 16, 50, 75, 25)
GUICtrlSetTip(-1, "A list of rom names to be read from the History.dat" & @CRLF & "If empty, all roms from the system will be read")
$hRomsList = GUICtrlCreateInput("", 100, 51, 370, 23)
$bClrRomsList = GUICtrlCreateButton("X", 479, 50, 25, 25)
GUICtrlSetTip(-1, "Clear the roms list field")
$bDumpFolder = GUICtrlCreateButton("Dump Folder", 16, 88, 75, 25)
GUICtrlSetTip(-1, "Folder to save the .cfg overview files")
$hDumpFolder = GUICtrlCreateInput("", 100, 89, 480, 23)
GUICtrlCreatePic("Data\Logo.gif", 16, 128, 126, 54)
GUICtrlCreateLabel("Systems", 170, 129)
GUICtrlSetTip(-1, "System to search - Edit the list at Data\Systems.dat")
GUICtrlCreateLabel("Manage at Data\Systems.dat", 235, 129)
$cSystem = GUICtrlCreateCombo("", 170, 145, 205, 25, BitOR($CBS_DROPDOWN, $CBS_AUTOHSCROLL, $WS_VSCROLL))
GUICtrlSetTip(-1, "System to search - Edit the list at Data\Systems.dat")
$cbGetSystems = GUICtrlCreateButton("Get Systems from History.dat", 169, 168, 207, 18)
GUICtrlSetTip(-1, "Get all the systems in History.dat")
$cbFileName = GUICtrlCreateCheckbox("List names", 512, 55, 90, 15)
GUICtrlSetState(-1, $GUI_UNCHECKED)
GUICtrlSetTip(-1, "Save the files with the rom names from the list" & @CRLF & "instead of the rom names found in the History.dat")
$cbAddN = GUICtrlCreateCheckbox("Add ""\n""", 395, 145)
GUICtrlSetState(-1, $GUI_CHECKED)
GUICtrlSetTip(-1, "Add an ""\n"" after ""overview"" and before the start of the text")
$cbAnalysis = GUICtrlCreateCheckbox("Analysis only", 395, 165)
GUICtrlSetTip(-1, "Perform the search and saves the log but not the overviews")
$bGo = GUICtrlCreateButton("Go", 504, 128, 75, 25)
$bHelp = GUICtrlCreateButton("Help", 504, 158, 75, 25)
;~ $cbOldStyle = GUICtrlCreateCheckbox("History v153", 375,128)
;~ GUICtrlSetState(-1,$GUI_DISABLE)
GUISetState(@SW_SHOW)
#EndRegion GUI

#Region Variables
Global $bQuit = False
Local $lHistory
Local $lRomsList
Local $nSizeH
Local $cPerL
Local $nTotalLines
Local $nFndSys
Local $lSystems[0][3]
Local $aSysList[0][3]
Local $nSysNum = 0
Local $sSysNamTemp = ""
Local $nMissingNames = 0
Local $aRemNames[8] = [" Video Game", " Game", " Cart.", " Cass.", " Soft.", " Disk.", " CD", " BS Pack."]
Local $sSzLRepl = ""

HotKeySet("^{q}", "Quit")

Local $iFileExists = FileExists("Data\Systems.dat")
If $iFileExists Then
	_FileReadToArray("Data\Systems.dat", $lSystems, 0, "|")
	ReDim $lSystems[UBound($lSystems)][3]
	For $f = 0 To UBound($lSystems) - 1
		$lSystems[$f][2] = $f
	Next
Else
	Dim $lSystems[1][3] = [["Mame", "$info", "0"]]
EndIf

$sComboFill = ""
For $f = 0 To UBound($lSystems) - 1
	$sComboFill = $sComboFill & $lSystems[$f][0] & " (" & $lSystems[$f][1] & ")" & "|"
Next
StringTrimRight($sComboFill, 1)

If StringInStr($sComboFill, "Arcade ($info)") > 0 Then
	GUICtrlSetData($cSystem, $sComboFill, "Arcade ($info)")
Else
	GUICtrlSetData($cSystem, $sComboFill, $lSystems[0][0] & " (" & $lSystems[0][1] & ")")
EndIf

if FileExists("history.dat") Then
	$fileH = @WorkingDir & "\history.dat"
	GUICtrlSetData($hHistory, $fileH)
EndIf
if FileExists("RomsList.txt") Then
	$fileL = @WorkingDir & "\RomsList.txt"
	GUICtrlSetData($hRomsList, $fileL)
	GUICtrlSetState($cbFileName, $GUI_CHECKED)
EndIf
if FileExists("Overviews") Then
	$dumpF = @WorkingDir & "\Overviews"
	GUICtrlSetData($hDumpFolder, $dumpF)
EndIf
#EndRegion Variables

While 1
	$nMsg = GUIGetMsg()
	Switch $nMsg
		Case $GUI_EVENT_CLOSE
			Exit
		Case $bHistory
			GetHistory()
		Case $bRomsList
			GetRomsList()
		Case $bClrRomsList
			ClearRomsList()
		Case $bDumpFolder
			GetDumpFolder()
		Case $cbFileName, $hRomsList
			If GUICtrlRead($hRomsList) = "" Then GUICtrlSetState($cbFileName, $GUI_UNCHECKED)
		Case $cbGetSystems
			GetSystems()
		Case $bGo
			Go()
		Case $bHelp
			If FileExists("Readme.txt") Then
				Run("notepad.exe " & "Readme.txt")
			Else
				MsgBox($MB_SYSTEMMODAL, "File not found", "Readme.txt was not found.")
			EndIf
	EndSwitch
WEnd

Func GetHistory()
	$fileH = FileOpenDialog("Open History File", "", "DAT (*.dat)", 3, "History.dat")
	If Not @error Then
		GUICtrlSetData($hHistory, $fileH)
	EndIf
EndFunc   ;==>GetHistory

Func GetRomsList()
	$fileL = FileOpenDialog("Open Roms List", "", "Text (*.txt)", 3, "RomsList.txt")
	If Not @error Then
		GUICtrlSetData($hRomsList, $fileL)
		GUICtrlSetState($cbFileName, $GUI_CHECKED)
	EndIf
EndFunc   ;==>GetRomsList

Func ClearRomsList()
	$fileL = ""
	GUICtrlSetData($hRomsList, $fileL)
	GUICtrlSetState($cbFileName, $GUI_UNCHECKED)
EndFunc   ;==>ClearRomsList

Func GetDumpFolder()
	$dumpF = FileSelectFolder("Pick Dump Folder", $dumpF, 0)
	If Not @error Then
		GUICtrlSetData($hDumpFolder, $dumpF)
	EndIf
EndFunc   ;==>GetDumpFolder

Func Go()
	$bQuit = False
	$fileH = GUICtrlRead($hHistory)
	$fileL = GUICtrlRead($hRomsList)
	$dumpF = GUICtrlRead($hDumpFolder)

	If $fileH = "" Then
		MsgBox(0, "Error", "No History.dat chosen")
		Return
	EndIf

	If $dumpF = "" and not _IsChecked($cbAnalysis) Then
		MsgBox(0, "Error", "No dump folder chosen")
		Return
	EndIf

	ProgressOn("Initializing", "Loading data", "", -1, -1, 18)

	_FileReadToArray($fileH, $lHistory)
	_FileReadToArray($fileL, $lRomsList)
	$nSysSel = _GUICtrlComboBox_GetCurSel($cSystem)

	$nSizeH = UBound($lHistory) - 1
;~ Local $nSizeH = 150000
	Global $nSizeL = UBound($lRomsList) - 1
	If $nSizeL = -1 Then $nSizeL = "no"

	$sAddN = ""
	If _IsChecked($cbAddN) Then $sAddN = "\n"

	ProgressOff()
	If $nSizeL = "no" Then
		$sSzLRepl = "No"
	Else
		$sSzLRepl = $nSizeL
	EndIf
	$mRequester = MsgBox(1, "Scrape History Overviews", "Searching " & $lSystems[$nSysSel][0] & " overviews" & @CRLF & $nSizeH & _
			" lines to search" & @CRLF & $sSzLRepl & " roms list" & @CRLF & @CRLF & _
			"Proceed?" & @CRLF & @CRLF & "( CTRL+Q to exit scrape )")
	If $mRequester = 2 Then Return

	Global $hTimer = TimerInit(), $nRoms = 0, $nScraped = 0, $sLog = "", $sAddEntry = "", $nTotalLines = 0
	Local $sGameName = "", $sGameNamePrev = "", $sRomName = "", $bFoundR = False
	If $nSizeL = "no" Then
		$sSzLRepl = ""
	Else
		$sSzLRepl = " of " & $nSizeL
	EndIf

	$sLog = "Searching for " & $lSystems[$nSysSel][0] & " roms" & @CRLF & @CRLF
	ConsoleWrite($sLog)
	ProgressOn("Searching " & $lSystems[$nSysSel][0] & " overviews", "Scaning History.dat", "", -1, -1, 18)
	For $h = 1 To $nSizeH
		If $bQuit Then
			$nTotalLines = $h
			WriteLog()
			Return
		EndIf
		$cPerL = $h / $nSizeH * 100
		$bFoundR = False
		$nSrtPos = 5 ; ** Ajustar para versão com e sem "A xx-year-old..."
		$nFndSys = StringInStr($lHistory[$h], $lSystems[$nSysSel][1])
		If $nFndSys > 0 Then ; Achou o sistema
			ProgressSet($cPerL, $h & " lines scanned of " & $nSizeH & " - " & Int($cPerL) & "%", $nScraped & " roms scraped" & $sSzLRepl)
			$sGameName = StringLeft($lHistory[$h + 5], StringInStr($lHistory[$h + 5], "(") - 2)
			If $sGameName = "" Then
				$sGameName = StringLeft($lHistory[$h + 3], StringInStr($lHistory[$h + 3], "(") - 2)
				$nSrtPos = 3
			EndIf
			$sAltName = ""
			if StringLeft($lHistory[$h + $nSrtPos + 1], 1) = "(" Then
				$sAltName = " - Alt name"
				ConsoleWrite("-- "&$lHistory[$h + $nSrtPos + 1]&@CRLF)
				$sGameName = StringMid($lHistory[$h + $nSrtPos + 1], 2, StringLen($lHistory[$h + $nSrtPos + 1])-2)
			EndIf
			$sGameName = StringRegExpReplace($sGameName,"(?U)\[.*\]","")
			$sChrChg = ""
			If StringRegExp($sGameName, '\\|/|:|\*|\?|\"|\<|\>|\|') Then
;~ 				MsgBox(16, "Bad char found", $sGameName)
				$sGameName = StringRegExpReplace($sGameName, '\\|/|:|\*|\?|\"|\<|\>|\|', "-")
				$sChrChg = " - Illegal char changed to ""-"""
			EndIf
			If $nSizeL = "no" Then ; Se NÃO tem lista de roms (salva todos)
				If $sGameName <> $sGameNamePrev Then ; Se o nome for diferente da achada anteriormente
					$bFoundR = True
				EndIf
			Else ; Se TEM lista de roms
				$aRomSrc = StringSplit($lHistory[$h], "=,")
				For $s = 2 To UBound($aRomSrc) - 1
					$nRomFnd = _ArraySearch($lRomsList, $aRomSrc[$s])
					If $nRomFnd <> -1 Then
						$bFoundR = True
						$sRomName = $lRomsList[$nRomFnd]
						_ArrayDelete($lRomsList, $nRomFnd)
					EndIf
				Next
			EndIf
			$sGameNamePrev = $sGameName
		EndIf

		If $bFoundR Then
			Dim $aOverTxt[0], $f = $h + $nSrtPos, $sHasInfo = " - No info"
			$nRoms += 1
			While $lHistory[$f] <> "$end"
				_ArrayAdd($aOverTxt, $lHistory[$f])
				$f += 1
			WEnd
			$nOvrSize = UBound($aOverTxt) - 1
			If _IsChecked($cbFileName) Then $sGameName = $sRomName
			If $nOvrSize > 5 Then
				$sHasInfo = ""
				$nScraped += 1
				If Not _IsChecked($cbAnalysis) Then
					$sOverTxt = _ArrayToString($aOverTxt, "\n", 0, $nOvrSize - 4)
					$sOverTxt = "overview " & $sAddN & StringTrimRight($sOverTxt, 2) ; ** Ajustar para versão com e sem "\n"
					$file = FileOpen($dumpF & "\" & $sGameName & ".cfg", 2)
					FileWrite($file, $sOverTxt)
					FileClose($file)
				EndIf
			EndIf
			$lLogEntry = "Found " & $sGameName & " @ " & $h & " to " & $f & " (" & $f - $h + 1 & " lines)" & $sAltName & $sChrChg & $sHasInfo & @CRLF
			$sLog = $sLog & $lLogEntry
			ConsoleWrite($lLogEntry)
			$h = $f
		EndIf
	Next
	$nTotalLines = $h
	WriteLog()
EndFunc   ;==>Go

Func WriteLog()
	ProgressOff()
	Local $fDiff = TimerDiff($hTimer)
	Local $time = $fDiff / 1000
	Local $sec = Int(Mod($time, 60))
	Local $min = Int(($time - $sec) / 60)
	If $nSizeL <> "no" Then $sAddEntry = $nSizeL & " roms searched " & @CRLF
	$lLogEntry = $sAddEntry & $nRoms & " roms found" & @CRLF & $nScraped & " roms scrapped" & @CRLF & $nSizeH & " total lines " _
			 & @CRLF & $nTotalLines - 1 & " lines scanned" & @CRLF & $min & ":" & $sec
	ConsoleWrite(@CRLF & $lLogEntry & @CRLF)
	$sLog = $sLog & @CRLF & $lLogEntry

	$file = FileOpen("SHO.log", 2)
	FileWrite($file, $sLog)
	FileClose($file)
	$nResponse = MsgBox(4, "Done", $lLogEntry & @CRLF & @CRLF & "View Log?")
	If $nResponse = 6 Then
		Run("notepad.exe " & "SHO.log")
	EndIf
EndFunc   ;==>WriteLog

Func GetSystems()
	$nButton = MsgBox(4, "Search systems", "Search for systems available in History.dat." & @CRLF & "Do you wish to continue?" & @CRLF & @CRLF & "( CTRL+Q to exit the search )")
	If $nButton = 7 Then Return

	$nSysNum = 0
	$nMissingNames = 0
	$fileH = GUICtrlRead($hHistory)
	Dim $aSysList[0][3]

	If $fileH = "" Then
		MsgBox(0, "Error", "No History.dat chosen")
		Return
	EndIf

	ProgressOn("Searching Systems", "Loading History.dat", "")

	_FileReadToArray($fileH, $lHistory)
	$nSizeH = UBound($lHistory) - 1

	AdlibRegister("Progress", 250)
	For $f = 1 To $nSizeH - 4
		If $bQuit Then
			SysStopped(True, $f)
			Return
		EndIf

		$sGetDol = StringLeft($lHistory[$f], 1)
		$nGetEqu = StringInStr($lHistory[$f], "=")

		$nTotalLines = $f
		$cPerL = $f / $nSizeH * 100
		If $sGetDol = "$" And $nGetEqu > 0 Then

			$sSysTokTemp = StringMid($lHistory[$f], 2, $nGetEqu - 2)
			If StringInStr($sSysTokTemp, ",") > 0 Then

				$aSysLine = StringSplit($sSysTokTemp, ",")

				For $i = 1 To UBound($aSysLine) - 1
					$sSysTokTemp = $aSysLine[$i]
					AddSys($sSysTokTemp, $f)
				Next
			Else
				AddSys($sSysTokTemp, $f)
			EndIf
		EndIf
	Next
	SysStopped(False, $f)
EndFunc   ;==>GetSystems

func Progress()
	ProgressSet($cPerL, $nTotalLines & " lines scanned of " & $nSizeH & " - " & Int($cPerL) & "%", $nSysNum & " systems found - " & $nMissingNames & " names missing")
EndFunc

Func AddSys($sSysTokTemp, $f)
	$nHasDash = StringInStr($sSysTokTemp, "_")
	If $nHasDash > 0 Then
		$sSysTokTemp = StringLeft($sSysTokTemp, $nHasDash - 1)
	EndIf
	$nSysIndex = _ArraySearch($aSysList, "$" & $sSysTokTemp, 0, 0, 0, 0, 1, 1)
;~ 	ConsoleWrite(">>> "&$sSysTokTemp&" - "&$nSysIndex&@CRLF)
	If $nSysIndex = -1 Then
		$sSysNamTemp = "$" & $sSysTokTemp ;***
		$nMissingNames += 1
		If StringInStr($lHistory[$f + 3], "year-old") > 0 Then
			GetName($sSysNamTemp, $f)
		EndIf
		_ArrayAdd($aSysList, $sSysNamTemp & "|" & "$" & $sSysTokTemp)
		$nSysNum += 1
		ConsoleWrite($sSysNamTemp & " - " & $sSysTokTemp & " " & $nMissingNames & @CRLF)
	ElseIf $aSysList[$nSysIndex][0] = "$" & $sSysTokTemp Then ;***
		If StringInStr($lHistory[$f + 3], "year-old") > 0 Then
			GetName($sSysNamTemp, $f)
			$aSysList[$nSysIndex][0] = $sSysNamTemp
			ConsoleWrite("- " & $sSysNamTemp & " - " & $aSysList[$nSysIndex][1] & " " & $nMissingNames & @CRLF)
		EndIf
	EndIf
EndFunc   ;==>AddSys

Func GetName(ByRef $sSysNamTemp, $f)
	$sSysNamTemp = StringMid($lHistory[$f + 3], 15) ; , StringLen($lHistory[$f+3])-14)
;~ 			ConsoleWrite("---- "&$sSysNamTemp&" - "&@CRLF)
	For $rep = 0 To UBound($aRemNames) - 1
;~ 				ConsoleWrite(StringInStr($sSysNamTemp, $aRemNames[$rep], 0, -1)&" - "&StringLen($sSysNamTemp)-StringLen($aRemNames[$rep])+1&@CRLF)
		If StringInStr($sSysNamTemp, $aRemNames[$rep], 0, -1) > 0 And _
				StringInStr($sSysNamTemp, $aRemNames[$rep], 0, -1) = StringLen($sSysNamTemp) - StringLen($aRemNames[$rep]) + 1 Then
			$sSysNamTemp = StringLeft($sSysNamTemp, StringLen($sSysNamTemp) - StringLen($aRemNames[$rep]))
			ExitLoop
		EndIf
	Next
	$nMissingNames -= 1
EndFunc   ;==>GetName

Func SysStopped($bCancelled, $f)
	AdlibUnRegister("Progress")
	$bQuit = False
	ProgressOff()
	_ArraySort($aSysList)
	_ArrayColDelete($aSysList, 2)
	_FileWriteFromArray("Data\SystemsList.txt", $aSysList)
	$nButton = MsgBox(4, "System search finnished", $f & " lines scanned of " & $nSizeH & " - " & Int($cPerL) & "%" & @CRLF & $nSysNum & " systems found - " & $nMissingNames & " names missing." _
			 & @CRLF & @CRLF & "List saved to Data\SystemsList.txt" & @CRLF & @CRLF & "Do you wish to view the list?" & @CRLF & "Save as Data\Systems.dat to use as an active list." _
			 & @CRLF & "(Restart needed)")
	If $nButton = 7 Then Return
	Run("notepad.exe " & "Data\SystemsList.txt")
EndFunc   ;==>SysStopped

Func Quit()
	$bQuit = True
EndFunc   ;==>Quit

Func _IsChecked($idControlID)
	Return BitAND(GUICtrlRead($idControlID), $GUI_CHECKED) = $GUI_CHECKED
EndFunc   ;==>_IsChecked

