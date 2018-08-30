$docker_provider = "ee"
$docker_version = "18-03-1-ee-2"
if (Test-Path env:docker_provider) {
  $docker_provider = $env:docker_provider  
}
if (Test-Path env:docker_version) {
  $docker_version = $env:docker_version  
}

$ProgressPreference = 'SilentlyContinue'
if ($docker_provider -eq "ce") {
  Set-ExecutionPolicy Bypass -scope Process
  New-Item -Type Directory -Path "$($env:ProgramFiles)\docker"
  Write-Output "Downloading docker $docker_version ..."
  wget -outfile $env:TEMP\docker.zip $("https://download.docker.com/win/static/edge/x86_64/docker-{0}-ce.zip" -f $docker_version)
  Expand-Archive -Path $env:TEMP\docker.zip -DestinationPath $env:TEMP -Force
  copy $env:TEMP\docker\*.exe $env:ProgramFiles\docker
  Remove-Item $env:TEMP\docker.zip
  [Environment]::SetEnvironmentVariable("Path", $env:Path + ";$($env:ProgramFiles)\docker", [EnvironmentVariableTarget]::Machine)
  $env:Path = $env:Path + ";$($env:ProgramFiles)\docker"
  Write-Output "Registering docker service ..."
  . dockerd --register-service
} elseif ($docker_provider -eq "ee") {
  Set-ExecutionPolicy Bypass -scope Process
  New-Item -Type Directory -Path "$($env:ProgramFiles)\docker"
  Write-Output "Downloading docker $docker_version ..."
  wget -outfile $env:TEMP\docker.zip $("https://dockermsft.blob.core.windows.net/dockercontainer/docker-{0}.zip" -f $docker_version)
  Expand-Archive -Path $env:TEMP\docker.zip -DestinationPath $env:TEMP -Force
  copy $env:TEMP\docker\*.exe $env:ProgramFiles\docker
  Remove-Item $env:TEMP\docker.zip
  [Environment]::SetEnvironmentVariable("Path", $env:Path + ";$($env:ProgramFiles)\docker", [EnvironmentVariableTarget]::Machine)
  $env:Path = $env:Path + ";$($env:ProgramFiles)\docker"
  Write-Output "Registering docker service ..."
  . dockerd --register-service
} else {
  Write-Output "Install-PackageProvider ..."
  Install-PackageProvider -Name NuGet -MinimumVersion 2.8.5.201 -Force
  Write-Output "Install-Module $docker_provider ..."
  Install-Module -Name $docker_provider -Repository PSGallery -Force
  Write-Output "Install-Package docker version $docker_version ..."
  Set-PSRepository -InstallationPolicy Trusted -Name PSGallery
  $ErrorActionStop = 'SilentlyContinue'
  Install-Package -Name docker -ProviderName $docker_provider -RequiredVersion $docker_version -Force
  Set-PSRepository -InstallationPolicy Untrusted -Name PSGallery  
}

$ErrorActionPreference = 'Stop'
Write-Output "Starting docker ..."
Start-Service docker
