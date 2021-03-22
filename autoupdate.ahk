﻿
#Persistent 
;MsgBox, 有人调用了我
Menu, Tray, NoIcon
SetWorkingDir %A_ScriptDir%
FileReadLine, oUrl, %A_ScriptDir%\App\tmp.vbs, 1
config := StrSplit(oUrl, "Profile\")
config := config[2]
config := StrSplit(config, "yaml")
config := config[1] 
Needle := "provider"
If InStr(config, Needle) ;Provider定时更新
{
    ;ruleprovider定时更新
    IniRead, ifautoupdate, %A_ScriptDir%\api\default.ini, SET, providerupdatetime
    if ( ifautoupdate = "0" Or  ifautoupdate = "" )
        MsgBox, 0, , 没有设置ruleprovider更新时间 ,3
    else
    {
        While 1
        {
            ;MsgBox, 0, , 成功设置ruleprovider定时更新，更新间隔为：%ifautoupdate%s  ,3
            IniRead, temptime, %A_ScriptDir%\api\default.ini, SET, providerlastupdatetime  
            ;MsgBox %temptime%
            timetemp = %A_Now%
            ;MsgBox %timetemp%
            timetemp -= %temptime%,Seconds
            ;MsgBox %timetemp%
            timetemp2 = %ifautoupdate%
            timetemp2 -= %timetemp%
            ;MsgBox %timetemp2%
            if ( timetemp2<0 )
            {
                timetemp2 = 1
            }
            timetemp2 = %timetemp2%000
            Sleep %timetemp2%
            IniRead, temp, %A_ScriptDir%\api\default.ini, SET, autoupdate
            if ( temp = "provider" ) ;
            {
                MsgBox, 0, , Provider定时更新，更新间隔为：%ifautoupdate%s ,3
                Gosub, updateruleprovider
                Gosub, updateproxyprovider
                IniWrite, %A_Now%, %A_ScriptDir%\api\default.ini, SET, providerlastupdatetime 
            }
            else
                Break
        }  
    }
}
else ;普通定时更新
{
    IniRead, ifautoupdate, %A_ScriptDir%\api\default.ini, SET, configupdatetime
    if ( ifautoupdate = "0" Or ifautoupdate = "" ) 
        MsgBox, 0, , 没有设置普通模式更新时间 ,3
    else
    {
        While 1
        {
            path = %A_ScriptDir%\Profile\%config%yaml  
            timetype=M 
            FileGetTime,temptime,%path%,%timetype%   
            ;MsgBox %temptime%
            timetemp = %A_Now%
            ;MsgBox %timetemp%
            timetemp -= %temptime%,Seconds
            ;MsgBox %timetemp%
            timetemp2 = %ifautoupdate%
            timetemp2 -= %timetemp%
            ;MsgBox %timetemp2%
            if ( timetemp2<0 )
            {
                timetemp2 = 1
            }
            timetemp2 = %timetemp2%000
            Sleep %timetemp2%
            IniRead, temp, %A_ScriptDir%\api\default.ini, SET, autoupdate
            if ( temp = "nomal" ) ;检测到停止自动更新，退出循环
            {
                MsgBox, 0, , 普通配置文件定时更新，更新间隔为：%ifautoupdate%s ,3
                Gosub, updateconfig
                IniWrite, %A_Now%, %A_ScriptDir%\api\default.ini, SET, configlastupdatetime 
                ;MsgBox 定时任务                   
            }
            else
                Break
        }               
    }
}
Return
;定时任务结束

;自动更新ruleprovider
updateruleprovider:
;MsgBox,自动更新
RunWait, ahkclashweb.bat updateruleprovider,,Hide
RunWait, ahkclashweb.bat restartconfig,,Hide
return

;自动更新proxyprovider
updateproxyprovider:
RunWait, ahkclashweb.bat updateproxyprovider,,Hide
return

;更新当前配置
updateconfig:
RunWait, ahkclashweb.bat save,,Hide
FileDelete, %A_ScriptDir%\App\tmptmp.vbs
FileCopy, %A_ScriptDir%\App\tmp.vbs, %A_ScriptDir%\App\tmptmp.vbs
RunWait, ahkclashweb.bat updateconfig,,Hide
IniRead, ifsuccess, %A_ScriptDir%\api\default.ini, SET, configdownload
if (ifsuccess = "success")
{
    RunWait, ahkclashweb.bat restartconfig,,Hide
    TrayTip % Format("📢通知📢"),更新当前配置并重启操作完成！ 
}
else
{
    TrayTip % Format("📢通知📢"),下载失败
}
Return