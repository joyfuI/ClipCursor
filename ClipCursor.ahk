#NoEnv
#Persistent
#SingleInstance force	; 중복실행시 다시 실행

toggle = on

ClipCursor(x1,y1,x2,y2)	; 마우스 가두는 함수
{
	VarSetCapacity(Rect,16,0)
	coords:= x1 "|" y1 "|" x2 "|" y2
	Loop Parse,coords,|
		NumPut(A_LoopField,&Rect+Off:= a_index>1 ? Off+=4 : 0)
	DllCall("ClipCursor","str",Rect)
}

Menu,Tray,NoStandard	; 트레이 기본메뉴 제거
Menu,Tray,Add,동작,토글
Menu,Tray,Add,부팅시 자동 실행,레지스트리
Menu,Tray,Add,종료,종료
Menu,Tray,Default,동작	; 트레이 아이콘 클릭시 동작할 기본메뉴 지정
Menu,Tray,Click,1	; 트레이 아이콘을 한번만 눌러도 기본메뉴 작동
Menu,Tray,Check,동작
RegRead,reg,HKEY_CURRENT_USER,Software\Microsoft\Windows\CurrentVersion\Run,마우스가두기	; 자동실행 레지스트리가 있는지 확인
if ErrorLevel = 0	; 레지스트리가 있고
	if reg = %A_ScriptFullPath%	; 그 값이 이 파일이라면
		Menu,Tray,Check,부팅시 자동 실행	; 트레이 메뉴 체크
SetTimer,마우스가두기,on	; 마우스 가두기 반복 실행
Return

토글:
Menu,Tray,ToggleCheck,동작
If toggle = on
{
	Suspend on
	SetTimer,마우스가두기,off
	DllCall("ClipCursor","int",0)
	toggle = off
	Return
}
If toggle = off
{
	Suspend off
	SetTimer,마우스가두기,on
	toggle = on
	Return
}
Return

마우스가두기:
ClipCursor(0,0,A_ScreenWidth,A_ScreenHeight)	; 해상도 크기만큼 마우스 가두기
Return

레지스트리:
Menu,Tray,ToggleCheck,부팅시 자동 실행
RegRead,reg,HKEY_CURRENT_USER,Software\Microsoft\Windows\CurrentVersion\Run,마우스가두기	; 자동실행 레지스트리가 있는지 확인
if ErrorLevel = 0	; 레지스트리가 있고
	if reg = %A_ScriptFullPath%	; 그 값이 이 파일이라면
	{
		RegDelete,HKEY_CURRENT_USER,Software\Microsoft\Windows\CurrentVersion\Run,마우스가두기	; 레지스트리 삭제
		Return
	}
RegWrite,REG_SZ,HKEY_CURRENT_USER,Software\Microsoft\Windows\CurrentVersion\Run,마우스가두기,%A_ScriptFullPath%	; 레지스트리 생성
Return

종료:
ExitApp
Return
