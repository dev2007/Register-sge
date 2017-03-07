#获取当前脚本所在目录.
$current_dir = Split-Path -Parent $MyInvocation.MyCommand.Definition

#切换到当前目录
cd $current_dir

#定义配置匹配标签.
$winrar_match = "#winrar*"
$pulish_match = "#publish*"
$package_match = "#package*"
$install_match = "#install*"

#读取配置文件.
$content = Get-Content -Path "$current_dir/dev.config"

#获取配置文件值.
for($i = 0;$i -le $content.Length;$i++)
{
	if($content[$i] -match $winrar_match)
	{
		$i += 1
		$winrar = $content[$i] + "\WinRAR.exe"
		if(!(Test-Path $winrar))
		{
			"----winrar路径异常，请检查$winrar----"
			return
		}
	}
	elseif($content[$i] -match $pulish_match)
	{
		$i += 1
		$publish = $content[$i]
	}
	elseif($content[$i] -match $package_match)
	{
		$i += 1
		$package = $content[$i]
	}
	elseif($content[$i] -match $install_match)
	{
		$i += 1
		$install = $content[$i]
	}
}

if([String]::IsNullOrEmpty($winrar))
{
	"----winrar路径配置为空，请检查"
	return
}
else
{
	"----winrar路径 OK"
}

if([String]::IsNullOrEmpty($publish))
{
	"----publish目录配置为空，请检查"
	return
}
else
{
	if(!(Test-Path "$current_dir\$publish"))
	{
		"----创建publish目录"
		New-Item -path $current_dir -name $publish -type directory
	}
	else
	{
		"----publish目录配置 OK"
	}
}

$to_winrar_file = @()
Get-ChildItem -Path $current_dir|ForEach-Object -Process{

		if($_ -is [System.IO.FileInfo])
		{
			if($_.name -notlike ".project" -and
				$_.name -notlike "*.config" -and
				$_.name -notlike "*.ps1")
			{
				$to_winrar_file +=".\" + $_.name + " "
			}
		}
		else
		{
			if($_.name -notlike "publish" -and
				$_.name -notlike ".git")
			{
				$to_winrar_file +=".\" + $_.name + " "
			}
		}
		
	
}

#删除原有的打包文件
"----删除原有打包文件----"
if(Test-Path "$current_dir\$publish\$package")
{
	Remove-Item "$current_dir\$publish\$package"
}

#打包
"----打包文件----"
&$winrar a ".\$publish\target.zip" $to_winrar_file
Start-Sleep -Seconds 2
Rename-Item "$current_dir\$publish\target.zip" $package
"----打包文件OK----"

#安装
if($install)
{
	"----安装插件----"
	&"$current_dir\$publish\$package"
	"----安装插件OK----"
}