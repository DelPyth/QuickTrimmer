/*!
	@name quick_trimmer.ahk
	@brief Quickly trim clips you've saved.
	@author TopHatCat
	@version 1.0.0
	@date 17-12-2022 [DD-MM-YYYY]
*/

;@Ahk2Exe-ExeName Quick Trimmer.exe
;@Ahk2Exe-SetDescription Quickly trim clips you've saved.
;@Ahk2Exe-SetFileVersion 1.0.0.0
;@Ahk2Exe-SetInternalName Quick Trimmer
;@Ahk2Exe-SetLanguage 0x409
;@Ahk2Exe-SetName Quick Timmmer
;@Ahk2Exe-SetOrigFilename quick_trimmer.ahk
;@Ahk2Exe-SetProductName Quick Trimmer
;@Ahk2Exe-SetProductVersion 1.0.0.0
;@Ahk2Exe-SetVersion 1.0.0.0

;@Ahk2Exe-SetMainIcon ..\assets\icon.ico
;@Ahk2Exe-AddResource ..\assets\icon.ico, 160  ; Replaces 'H on blue'
;@Ahk2Exe-AddResource ..\assets\icon.ico, 206  ; Replaces 'S on green'
;@Ahk2Exe-AddResource ..\assets\icon.ico, 207  ; Replaces 'H on red'
;@Ahk2Exe-AddResource ..\assets\icon.ico, 208  ; Replaces 'S on red'

;@Ahk2Exe-PostExec "MPRESS.exe" "%A_WorkFileName%" -q -x, 0,, 1

#NoEnv
#NoTrayIcon
#KeyHistory 0
#SingleInstance Force
SetBatchLines, -1
SetWorkingDir, % A_ScriptDir . "\.."

global APP := {}
APP.name := Format("{1:T}", StrReplace(StrReplace(A_ScriptName, ".ahk"), "_", " "))
APP.version := "1.0.0"

/*@Ahk2Exe-Keep
APP.name := StrReplace(A_ScriptName, ".exe")
FileGetVersion, ver, % A_ScriptFullPath
APP.version := ver
*/

ui := {}

main(args)
{
	global ui

	EM_SETCUEBANNER := (0x1500 + 1)

	opt := getInputValues(A_Args)

	Gui, 1:New, +hwndui_hwnd -MinimizeBox -DPIScale, % APP.name . " v" . APP.version
	ui.hwnd := ui_hwnd
	Gui, 1:Margin, 5, 5

	; Input video group...
	Gui, 1:Add, Text, xm ym w70 h22, Input Video:
	Gui, 1:Font,, Consolas
	Gui, 1:Add, Edit, x+m yp w250 h22 hwndbud1 +0x400, % opt.in_video
	Gui, 1:Font
	Gui, 1:Add, Button, x+m yp w22 h22 hwndbttn1 -TabStop
	fn := Func("setVideoParam").Bind(bud1)
	GuiControl, 1:+g, % bttn1, % fn
	guiButtonIcon(bttn1, "imageres.dll", 14)
	ui.in_video := bud1

	; Output video group...
	Gui, 1:Add, Text, xm y+m w70 h22, Output Video:
	Gui, 1:Font,, Consolas
	Gui, 1:Add, Edit, x+m yp w250 h22 hwndbud2 +0x400, % opt.out_video != "" ? opt.out_video : "%dir%\%name_no_ext% - trimmed.%ext%"
	Gui, 1:Font
	Gui, 1:Add, Button, x+m yp w22 h22 hwndbttn2 -TabStop
	fn := Func("setVideoParam").Bind(bud2)
	GuiControl, 1:+g, % bttn2, % fn
	guiButtonIcon(bttn2, "imageres.dll", 14)
	ui.out_video := bud2

	; Start of clip.
	Gui, 1:Add, Text, xm y+m w70 h22, Start of Clip:
	Gui, 1:Add, Edit, x+m yp w125 h22 Right Number hwndstart_time, % opt.time_start
	ui.start_time := start_time

	Gui, 1:Add, Text, x+m yp w20 h22 Center, to

	; End of clip.
	Gui, 1:Add, Edit, x+m yp w125 h22 Number hwndend_time, % opt.time_end == -1 ? ""
	DllCall("User32.dll\SendMessageW", "Ptr", end_time, "Uint", EM_SETCUEBANNER, "Ptr", True, "WStr", "end")
	ui.end_time := end_time

	; Buttons...
	Gui, 1:Add, Button, xm y+m w75 h23 Default hwndbttn3, &Trim Video
	fn := Func("startTrim").Bind(ui)
	GuiControl, 1:+g, % bttn3, % fn
	ui.trim_bttn := bttn3

	Gui, 1:Add, Button, x+m yp w75 h23 gcloseProgram hwndbttn4, &Close

	Gui, 1:Add, Button, x+m yp w75 h23 gshowHelp hwndbttn5, &Help

	Gui, 1:Show, Hide

	VarSetCapacity(rc, 16)
	DllCall("GetClientRect", "uint", ui_hwnd, "uint", &rc)
	client_width := NumGet(rc, 8, "int")
	client_height := NumGet(rc, 12, "int")

	GuiControl, 1:Move, % bttn3, % Format("x{1}", client_width - (75 * 3) - 15)
	GuiControl, 1:Move, % bttn4, % Format("x{1}", client_width - (75 * 2) - 10)
	GuiControl, 1:Move, % bttn5, % Format("x{1}", client_width - 75 - 5)

	Gui, 1:Show

	loop
	{
		if (!WinExist("ahk_id " . ui.hwnd))
		{
			break
		}
	}

	return 0
}

guiDropFiles(hui_hwnd, file_array, ctrl_hwnd, xpos, ypos)
{
	global ui
	GuiControl, 1:Text, % ui.in_video, % file_array[1]
}

startTrim()
{
	global ui
	Gui, 1:+OwnDialogs

	GuiControl, 1:Disable, % ui.trim_bttn

	GuiControlGet, in_video, 1:, % ui.in_video
	GuiControlGet, out_video, 1:, % ui.out_video
	GuiControlGet, start_time, 1:, % ui.start_time
	GuiControlGet, end_time, 1:, % ui.end_time

	if (!in_video || !FileExist(in_video))
	{
		showBalloonTip(ui.in_video, "Empty or Invalid File", "Input video file does not exist or input is empty.", 3)
		return
	}

	if (out_video == "")
	{
		showBalloonTip(ui.out_video, "Empty File", "Output video file does not exist or input is empty.", 3)
		return
	}

	if (start_time == "")
	{
		showBalloonTip(ui.start_time, "", "You must provide a valid video time for the start of the clip.", 3)
		return
	}

	if (end_time == "")
	{
		showBalloonTip(ui.end_time, "", "End of the video was left blank. Assuming end of video's time.", 2)
	}

	SplitPath, in_video, file_name, dir, ext, name_no_ext, drive
	FormatTime, date,, yyyy-MM-dd
	FormatTime, time,, HH-mm-ss
	Random, rand, 0, 100

	vars := {}

	; These vars may be overwritten via the custom vars config.
	vars["username"]    := A_UserName
	vars["documents"]   := A_MyDocuments
	vars["appdata"]     := A_AppData
	vars["desktop"]     := A_Desktop

	; Custom variables.
	fobj := FileOpen(A_WorkingDir . "/config/custom_vars.txt", "r `n")
	if (fobj)
	{
		while (!fobj.AtEOF)
		{
			line := fobj.ReadLine()

			; Remove hash comments and trim line of whitespace.
			line := Trim(RegExReplace(line, "im)((?:[\t ]+|)#.*)$"))

			; If this cleaner line is now empty, ignore it and continue on.
			if (!line)
			{
				continue
			}

			; I don't care for prettiness of what the key's names are... So just allow the reader to set the key into the object.
			if (RegExMatch(line, "iOS)^([\w_]+)\s*=\s*(.+)$", match_obj))
			{
				vars[match_obj.Value(1)] := match_obj.Value(2)
			}
		}
	}

	; These vars will NOT be overwritten.
	vars["file_name"]   := file_name
	vars["dir"]         := dir
	vars["ext"]         := ext
	vars["name_no_ext"] := name_no_ext
	vars["drive"]       := drive
	vars["date"]        := date
	vars["time"]        := time
	vars["date_time"]   := date . " " . time
	vars["now"]         := A_Now
	vars["now_utc"]     := A_NowUTC
	vars["rand"]        := rand

	out_video := replaceVars(out_video, vars)

	if (in_video = out_video)
	{
		MsgBox, 0x34, % APP.name, % "Are you sure you want to overwrite the current video?"
		IfMsgBox, Yes
		{
			tmp := dir . "\tmp" . A_Now . "." . ext
			FileMove, % in_video, % tmp
			in_video := tmp
		}
		IfMsgBox, No
		{
			return
		}
	}

	loop
	{
		trimVideo(in_video, out_video, start_time, end_time)

		Sleep 250

		if (tmp)
		{
			FileDelete, % tmp
		}

		if (!FileExist(out_video))
		{
			MsgBox, 0x15, % APP.name, % "Video was not clipped properly. Would you like to retry?"
			IfMsgBox, Cancel
			{
				break
			}
		}

		break
	}

	MsgBox, 0x40, % APP.name, % "Video was saved to:`n`n" . out_video
	GuiControl, 1:Enable, % ui.trim_bttn
	return
}

closeProgram()
{
	ExitApp 0
}

showHelp()
{
	Gui, 1:+OwnDialogs
	MsgBox, 0x41, % APP.name, % "This will open the help file in notepad."
	IfMsgBox, Cancel
	{
		return
	}

	try
	{
		Run notepad %A_WorkingDir%\readme.md
	}
	catch
	{
		MsgBox, 0x10, % APP.name, % "Could not open help file in notepad. Is notepad missing?"
	}
	return
}

setVideoParam(buddy_ctrl, ctrl_hwnd, gui_event, event_info, err_level := "")
{
	Gui, 1:+OwnDialogs
	FileSelectFile, result, 2,, Select a Video File, Video Files (*.mp4;*.mov;*.avi;*.wmv)
	if (ErrorLevel)
	{
		return
	}

	GuiControl, 1:Text, % buddy_ctrl, % result
	return
}

getInputValues(args)
{
	result := {}

	if (!FileExist(args[1]))
	{
		result.in_video := ""
		result.out_video := ""
		result.time_start := 0
		result.time_end := -1
		return result
	}

	result.in_video := args[1]
	result.out_video := args[2]

	if (RegExMatch(args[3], "iO)-time(.+)", match_obj))
	{
		if (RegExMatch(match_obj.Value(1), "iO)([0-9]+)-?([0-9]+?)", match_obj))
		{
			result.time_start := match_obj.Value(1)
			result.time_end := LTrim(match_obj.Value(2), "-")
		}
		else
		{
			result.time_start := match_obj.Value(1)
			result.time_end := -1
		}
	}

	return result
}

replaceVars(in_str, vars)
{
	while (RegExMatch(in_str, "iO)%([a-z\_]+)%", match_obj))
	{
		in_str := StrReplace(in_str, "%" . match_obj.Value(1) . "%", vars[match_obj.Value(1)])
	}

	return in_str
}

trimVideo(in_video, out_video, start_time, end_time := "")
{
	try
	{
		RunWait % Format("ffmpeg -i ""{1}"" -ss {3}{4} -c:v copy -c:a copy ""{2}""", in_video, out_video, start_time, end_time != "" ? (" -to " . end_time) : ""),, Hide
	}
	catch err
	{
		MsgBox, 0x14, % APP.name, % "Launch failed! Make sure you have ffmpeg not only installed, but also have the path to it added to the PATH environment variable.`nWould you like to go to the download page? Make sure to click for the executable and not the source code!"
		IfMsgBox, Yes
		{
			Run https://ffmpeg.org/download.html
		}
	}

	return ErrorLevel
}

getLengthOfVideo(path)
{
	static obj_shell := ComObjCreate("Shell.Application")

	SplitPath, path, file_name, dir

	oDir := obj_shell.NameSpace(dir)
	return oDir.GetDetailsOf(oDir.ParseName(file_name), 27)
}

guiButtonIcon(Handle, File, Index := 1, Options := "")
{
	RegExMatch(Options, "i)w\K\d+", W), (W="") ? W := 16 :
	RegExMatch(Options, "i)h\K\d+", H), (H="") ? H := 16 :
	RegExMatch(Options, "i)s\K\d+", S), S ? W := H := S :
	RegExMatch(Options, "i)l\K\d+", L), (L="") ? L := 0 :
	RegExMatch(Options, "i)t\K\d+", T), (T="") ? T := 0 :
	RegExMatch(Options, "i)r\K\d+", R), (R="") ? R := 0 :
	RegExMatch(Options, "i)b\K\d+", B), (B="") ? B := 0 :
	RegExMatch(Options, "i)a\K\d+", A), (A="") ? A := 4 :
	Psz := A_PtrSize = "" ? 4 : A_PtrSize, DW := "UInt", Ptr := A_PtrSize = "" ? DW : "Ptr"
	VarSetCapacity( button_il, 20 + Psz, 0 )
	NumPut( normal_il := DllCall( "ImageList_Create", DW, W, DW, H, DW, 0x21, DW, 1, DW, 1 ), button_il, 0, Ptr )	; Width & Height
	NumPut( L, button_il, 0 + Psz, DW )		; Left Margin
	NumPut( T, button_il, 4 + Psz, DW )		; Top Margin
	NumPut( R, button_il, 8 + Psz, DW )		; Right Margin
	NumPut( B, button_il, 12 + Psz, DW )	; Bottom Margin
	NumPut( A, button_il, 16 + Psz, DW )	; Alignment
	SendMessage, BCM_SETIMAGELIST := 5634, 0, &button_il,, AHK_ID %Handle%
	return IL_Add( normal_il, File, Index )
}

showBalloonTip(hEdit, Title, Text, Icon := 0)
{
	NumPut(VarSetCapacity(EDITBALLOONTIP, 4 * A_PtrSize, 0), EDITBALLOONTIP)
	NumPut(&Title, EDITBALLOONTIP, A_PtrSize, "Ptr")
	NumPut(&Text, EDITBALLOONTIP, A_PtrSize * 2, "Ptr")
	NumPut(Icon, EDITBALLOONTIP, A_PtrSize * 3, "UInt")
	SendMessage, 0x1503, 0, &EDITBALLOONTIP,, ahk_id %hEdit% ; EM_SHOWBALLOONTIP
	Return, ErrorLevel
}

ExitApp % main(A_Args)
