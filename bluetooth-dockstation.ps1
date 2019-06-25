function Check-Dock {
	$dock_audio='Edifier Spinnaker Stereo'
	$undock_audio = 'High Definition Audio Device'
	#dock ethernet device
	$dock_device = 'USB\VID_17EF&PID_3062\1018C2672'
	$dock_comm_device = 'BCC950 ConferenceCam' 
	$undock_comm_device = 'High Definition Audio Device' 
	$dir = Split-Path $PSCommandpath

	Push-Location $dir

	$wasdocked = $false
	Try { 
		$wasdocked = [Convert]::ToBoolean(( Get-Content "state.txt" ))
	}
	Catch {
	}
	Write-Host "Was docked $wasdocked" 


	$docked = $false
	if ( Get-PnpDeviceProperty -InstanceId $dock_device | Where-Object {$_.KeyName -eq "DEVPKEY_Device_IsPresent"} | Select -ExpandProperty "Data") {
		$docked=$true;
		}
	if ($docked -eq $wasdocked)
	{
		Write-Host "Docked state not changed"
		return
	} else { Write-Host "Docked state has been changed"}

	$switched=$false;
	if ($docked)  {
		if (Get-PnpDevice -PresentOnly -Status 'OK' | Where-Object {$_.Name -eq $dock_audio} )
		{
			$audio = '"'+$dock_audio+'"'
			$params = "/SetDefault " + $audio + " 1"
			Start-Process -NoNewWindow "SoundVolumeView.exe" -ArgumentList $params
			$audio = '"'+$dock_audio+'"'
			$params = "/SetDefault " + $audio + " 0"
			Start-Process -NoNewWindow "SoundVolumeView.exe" -ArgumentList $params
			$audio = '"'+$dock_comm_device+'"'
			$params = "/SetDefault " + $audio + " 2"
			Start-Process -NoNewWindow "SoundVolumeView.exe" -ArgumentList $params
			$switched=$true;

		}
	}
	else {
		if ( Get-PnpDevice -PresentOnly -Status 'OK' | Where-Object {$_.Name -eq $undock_audio} )
		{
			$audio = '"'+$undock_audio+'"'
			$params = " /SetDefault " + $audio + " 1"
			Start-Process -NoNewWindow "SoundVolumeView.exe" -ArgumentList $params
			$audio = '"'+$undock_audio+'"'
			$params = " /SetDefault " + $audio + " 0"
			Start-Process -NoNewWindow "SoundVolumeView.exe" -ArgumentList $params
			$audio = '"'+$undock_comm_device+'"'
			$params = " /SetDefault " + $audio + " 2"
			Start-Process -NoNewWindow "SoundVolumeView.exe" -ArgumentList $params
			$switched=$true;
		}
	}
	if ($switched){
			$docked | Out-File "$dir\state.txt"
		}
	Pop-Location
}

$ErrorActionPreference="SilentlyContinue"
Stop-Transcript | out-null
$ErrorActionPreference = "Continue"
$log = $Env:Temp +"\pslogs\bluetooth-dockstation.log"
Start-Transcript -path $log -append
while ($true){
		Check-Dock
		Start-Sleep -Seconds 10
	}
Stop-Transcript