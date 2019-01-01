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
}

Menu, Tray, NoStandard	; 트레이 기본메뉴 제거
Menu, Tray, Add, 동작, Toggle
Menu, Tray, Add, 부팅 시 자동 실행, Autorun
Menu, Tray, Add, 종료, Close
Menu, Tray, Default, 동작	; 트레이 아이콘 클릭 시 동작할 기본메뉴
Menu, Tray, Click, 1	; 트레이 아이콘을 한번만 눌러도 기본메뉴 작동

RegRead, reg, HKEY_CURRENT_USER, Software\Microsoft\Windows\CurrentVersion\Run, ClipCursor	; 자동실행 레지스트리가 있는지 확인
If (ErrorLevel = 0)	; 레지스트리가 있고
	If (reg = A_ScriptFullPath)	; 그 값이 이 파일이라면
		Menu, Tray, Check, 부팅 시 자동 실행	; 트레이 메뉴 체크

Hotkey, Pause, Toggle	; Pause 키에 단축키 지정

Gosub, Toggle	; 마우스 가두기 동작
Return

Toggle:
Menu, Tray, ToggleCheck, 동작
If (toggle)
{
	SetTimer, Cursor, off
	DllCall("ClipCursor", "Int", 0)
	toggle := false
}
Else
{
	SetTimer, Cursor, on
	toggle := true
}
Return

Cursor:
ClipCursor(0, 0, A_ScreenWidth, A_ScreenHeight)	; 해상도 크기만큼 마우스 가두기
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
