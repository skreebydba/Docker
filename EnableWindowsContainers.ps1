Enable-WindowsOptionalFeature -Online -FeatureName containers –All
Enable-WindowsOptionalFeature -Online -FeatureName Microsoft-Hyper-V –All
Disable-WindowsOptionalFeature -FeatureName containers
Disable-WindowsOptionalFeature -FeatureName Microsoft-Hyper-V 

#docker build -t sql2008:1.0 .
#Switch from Windows to Linux containers
#& $Env:ProgramFiles\Docker\Docker\DockerCli.exe -SwitchDaemon