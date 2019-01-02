#NoEnv
#Persistent
#SingleInstance force	; 중복 실행 시 다시 실행

ClipCursor(x1, y1, x2, y2)	; 마우스 가두는 함수
{
	VarSetCapacity(rect, 16, 0)
	args := x1 . "|" . y1 . "|" . x2 . "|" . y2
	Loop, Parse, args, |
		NumPut(A_LoopField, &rect, (a_index - 1) * 4)
	DllCall("ClipCursor", "Str", rect)
	Return
}

Monitor(ItemName, ItemPos, MenuName)
{
	static toggle := ""	; 마우스 가두기 상태인 모니터 이름. 빈 문자열은 해제 상태
	static timer	; 작동 중인 타이머
	ItemPos -= 1	; 모니터 번호. 트레이 메뉴가 위에 하나 더 있기 때문에 1을 뺌

	If (toggle != "" && (MenuName != "hotkey" || (ItemPos = 0 || toggle != ItemName)))
	{
		Menu, Tray, Uncheck, %toggle%	; 기존 체크표시 해제
		SetTimer, %timer%, Delete	; 마우스 가두기 off
		DllCall("ClipCursor", "Int", 0)
	}
	If ((MenuName = "hotkey" && ItemPos = 0 && toggle != "") || (MenuName != "hotkey" && toggle = ItemName))
	{
		toggle := ""
		TrayTip("마우스 가두기 off")
	}
	If (toggle != ItemName && (MenuName != "hotkey" || ItemPos != 0))
	{
		SysGet, monitor, Monitor, %ItemPos%
		timer := Func("ClipCursor").Bind(monitorLeft, monitorTop, monitorRight, monitorBottom)	; 해상도 크기만큼 마우스 가두기
		SetTimer, %timer%, On	; 마우스 가두기 on
		toggle := ItemName
		TrayTip(ItemName . "`n마우스 가두기 on")
		Menu, Tray, Check, %ItemName%
	}
	Return
}

TrayTip(text)	; 트레이 메시지 띄우는 함수
{
	TrayTip	; 이전 메시지는 지우고
	TrayTip, , %text%
}

Menu, Tray, NoStandard	; 트레이 기본메뉴 제거
Menu, Tray, Add, 마우스 가두기, Null
Menu, Tray, Disable, 마우스 가두기	; 선택불가. 그냥 제목

SysGet, monitorcount, MonitorCount	; 모니터 개수 가져오기
SysGet, monitorprimary, MonitorPrimary	; 기본 모니터 번호 가져오기
Loop, %monitorcount%
{
	SysGet, monitorname, MonitorName, %A_Index%	; 모니터 이름 가져오기
	SysGet, monitor, Monitor, %A_Index%	; 모니터 해상도 가져오기
	Menu, Tray, Add, %monitorname%, Monitor
	If (A_Index = monitorprimary)
		Menu, Tray, Default, %monitorname%	; 트레이 아이콘 클릭 시 동작할 기본메뉴. 기본 모니터로 설정
	Hotkey, #^%A_Index%, Hotkey	; 단축키 지정. 컨트롤키 + 윈도우키 + 모니터번호
}
Hotkey, #^0, Hotkey	; off 단축키 지정. 컨트롤키 + 윈도우키 + 0

Menu, Tray, Add
Menu, Tray, Add, 부팅 시 자동 실행, Autorun
Menu, Tray, Add, 종료, Close
Menu, Tray, Click, 1	; 트레이 아이콘을 한번만 눌러도 기본메뉴 작동

RegRead, reg, HKEY_CURRENT_USER, Software\Microsoft\Windows\CurrentVersion\Run, ClipCursor	; 자동실행 레지스트리가 있는지 확인
If (ErrorLevel = 0)	; 레지스트리가 있고
	If (reg = A_ScriptFullPath)	; 그 값이 이 파일이라면
		Menu, Tray, Check, 부팅 시 자동 실행	; 트레이 메뉴 체크

SysGet, monitorname, MonitorName, %monitorprimary%
Monitor(monitorname, monitorprimary + 1, "Tray")	; 실행 시 기본 모니터 마우스 잠그기 동작
Return

Hotkey:
num := RegExReplace(A_ThisHotkey, "\D")	; 단축키에서 숫자(모니터번호)만 추출
SysGet, monitorname, MonitorName, %num%
Monitor(monitorname, num + 1, "hotkey")
Return

Autorun:
Menu, Tray, ToggleCheck, 부팅 시 자동 실행
RegRead, reg, HKEY_CURRENT_USER, Software\Microsoft\Windows\CurrentVersion\Run, ClipCursor	; 자동실행 레지스트리가 있는지 확인
if (ErrorLevel = 0)	; 레지스트리가 있고
	if (reg = A_ScriptFullPath)	; 그 값이 이 파일이라면
	{
		RegDelete, HKEY_CURRENT_USER, Software\Microsoft\Windows\CurrentVersion\Run, ClipCursor	; 레지스트리 삭제
		Return
	}
RegWrite, REG_SZ, HKEY_CURRENT_USER, Software\Microsoft\Windows\CurrentVersion\Run, ClipCursor, %A_ScriptFullPath%	; 레지스트리 생성
Return

Close:
ExitApp

Null:
Return
