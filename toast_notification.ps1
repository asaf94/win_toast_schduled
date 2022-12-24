Install-Module BurntToast

params(
$ToastTitle,
$ToastText
)

#New-BurntToastNotification -Text 'Example Script', 'The example script has run successfully.'


function Show-Notification {
    [cmdletbinding()]
    Param (
        [string]
        $ToastTitle,
        [string]
        [parameter(ValueFromPipeline)]
        $ToastText
    )

    [Windows.UI.Notifications.ToastNotificationManager, Windows.UI.Notifications, ContentType = WindowsRuntime] > $null
    $Template = [Windows.UI.Notifications.ToastNotificationManager]::GetTemplateContent([Windows.UI.Notifications.ToastTemplateType]::ToastText02)

    $RawXml = [xml] $Template.GetXml()
    ($RawXml.toast.visual.binding.text|where {$_.id -eq "1"}).AppendChild($RawXml.CreateTextNode($ToastTitle)) > $null
    ($RawXml.toast.visual.binding.text|where {$_.id -eq "2"}).AppendChild($RawXml.CreateTextNode($ToastText)) > $null

    $SerializedXml = New-Object Windows.Data.Xml.Dom.XmlDocument
    $SerializedXml.LoadXml($RawXml.OuterXml)

    $Toast = [Windows.UI.Notifications.ToastNotification]::new($SerializedXml)
    $Toast.Tag = "PowerShell"
    $Toast.Group = "PowerShell"
    $Toast.ExpirationTime = [DateTimeOffset]::Now.AddMinutes(1)

    $Notifier = [Windows.UI.Notifications.ToastNotificationManager]::CreateToastNotifier("PowerShell")
    $Notifier.Show($Toast);
}

function toast_list {

$all_tasks = Get-ScheduledTask |Where-Object {$_.TaskName -like "*toastTask_*"}
write-verbose $all_tasks -Verbose

}

function add_toast
(
[string]$toastName,
[string]$toastDesc,
[string]$toastTime
)

{
    
    # varibles toast\task

    $TASK_NAME = "toastTask_$toastName"

    # toast action



    #powershell.exe "New-BurntToastNotification -Text 'Hello', 'Hello world'"



    #$string = '"' + "$toastName" +', ' + "$toastDesc" + '"'
    #$new_string = "'" + $string + "'"
    $taskpreAction = "`'$toastName, $toastDesc'`'"
    $toastAction = "powershell.exe New-BurntToastNotification -Text $taskpreAction" # `'$toastName, $toastDesc'\`"" # powershell.exe `"New-BurntToastNotification -Text '$toastName, $toastDesc'`""
    
    

    # schdule task by task schduler

    if ($toastTime -like "*:*") {

    #$task = "schtasks /create /f /tn `"$TASK_NAME`" /tr `"'$toastAction'"" /sc daily /st $toastTime
    #$task = "schtasks.exe /create /f /tn `'$TASK_NAME' /tr $toastAction /sc daily /st $toastTime"
    #Invoke-Expression $task
    schtasks.exe /create /f /tn $TASK_NAME /tr $toastAction /sc daily /st $toastTime

    }

    else {

    #$task = "schtasks.exe /create /f /tn `'$TASK_NAME' /tr $toastAction /sc minute /mo $toastTime"
    #Invoke-Expression $task
    schtasks.exe /create /f /tn $TASK_NAME /tr $toastAction /sc minute /mo $toastTime

    }



}

function del_toast([string]$taskName){


schtasks /delete /tn $taskName /f


}

#task_list
#del_toast -taskName 'toastTask_Hello'

Show-Notification -ToastTitle $ToastText -ToastText $ToastTitle
#add_toast -toastName "Hello" -toastDesc "Hello world" -toastTime '16:55'