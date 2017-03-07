#��ȡ��ǰ�ű�����Ŀ¼.
$current_dir = Split-Path -Parent $MyInvocation.MyCommand.Definition

#�л�����ǰĿ¼
cd $current_dir

#��������ƥ���ǩ.
$winrar_match = "#winrar*"
$pulish_match = "#publish*"
$package_match = "#package*"
$install_match = "#install*"

#��ȡ�����ļ�.
$content = Get-Content -Path "$current_dir/dev.config"

#��ȡ�����ļ�ֵ.
for($i = 0;$i -le $content.Length;$i++)
{
	if($content[$i] -match $winrar_match)
	{
		$i += 1
		$winrar = $content[$i] + "\WinRAR.exe"
		if(!(Test-Path $winrar))
		{
			"----winrar·���쳣������$winrar----"
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
	"----winrar·������Ϊ�գ�����"
	return
}
else
{
	"----winrar·�� OK"
}

if([String]::IsNullOrEmpty($publish))
{
	"----publishĿ¼����Ϊ�գ�����"
	return
}
else
{
	if(!(Test-Path "$current_dir\$publish"))
	{
		"----����publishĿ¼"
		New-Item -path $current_dir -name $publish -type directory
	}
	else
	{
		"----publishĿ¼���� OK"
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

#ɾ��ԭ�еĴ���ļ�
"----ɾ��ԭ�д���ļ�----"
if(Test-Path "$current_dir\$publish\$package")
{
	Remove-Item "$current_dir\$publish\$package"
}

#���
"----����ļ�----"
&$winrar a ".\$publish\target.zip" $to_winrar_file
Start-Sleep -Seconds 2
Rename-Item "$current_dir\$publish\target.zip" $package
"----����ļ�OK----"

#��װ
if($install)
{
	"----��װ���----"
	&"$current_dir\$publish\$package"
	"----��װ���OK----"
}