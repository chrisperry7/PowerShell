$users = Get-ChildItem "C:\{user_area}"
$users = $users.fullname
foreach ($user in $users){
	$file = $user + "\appdata\Microsoft\Windows\SendTo\Compressed (zipped) folder.ZFSendToTarget"
	if (!(Test-Path $file)){
		$folder = $file.substring(0, $file.LastIndexOf('\'))
		Copy-Item "\\{server}\{user_area}\Compressed (zipped) folder.ZFSendToTarget" -Destination $folder
	}
	Else {
		$working_user = $user.substring(9)
		write-host $working_user "file exists"
	}
}
