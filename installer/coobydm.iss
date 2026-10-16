; Cooby's Deathmatch installer (Inno Setup 6)
; Built by CI: ISCC /DSourceDir=<path to staged coobydm folder> /DVersion=<ver> installer\coobydm.iss

#ifndef SourceDir
  #define SourceDir "..\dist\coobys-deathmatch\coobydm"
#endif
#ifndef Version
  #define Version "0.1"
#endif

[Setup]
AppId={{6B0C1F3E-3D2A-4C55-9C4E-C00B1D3A7C11}
AppName=Cooby's Deathmatch
AppVersion={#Version}
AppPublisher=cooby
AppPublisherURL=https://github.com/coobyp/coobys-deathmatch
DefaultDirName={code:GetHalfLifeDir}
AppendDefaultDirName=no
DirExistsWarning=no
DisableProgramGroupPage=yes
UsePreviousAppDir=yes
UninstallFilesDir={app}\coobydm\uninstall
UninstallDisplayName=Cooby's Deathmatch
PrivilegesRequired=admin
OutputDir=Output
OutputBaseFilename=CoobysDeathmatch-Setup
Compression=lzma2
SolidCompression=yes
WizardStyle=modern

[Messages]
SelectDirLabel3=Setup will install Cooby's Deathmatch into your Half-Life folder (the one that contains "valve").
SelectDirBrowseLabel=If that's not where Half-Life lives, click Browse and pick your Half-Life folder.

[Tasks]
Name: "desktopicon"; Description: "Create a desktop shortcut"; GroupDescription: "Shortcuts:"

[Files]
Source: "{#SourceDir}\*"; DestDir: "{app}\coobydm"; Flags: recursesubdirs ignoreversion
#ifexist AddBackslash(SourcePath) + "vc_redist.x86.exe"
Source: "vc_redist.x86.exe"; DestDir: "{tmp}"; Flags: deleteafterinstall
#endif

[Icons]
Name: "{autodesktop}\Cooby's Deathmatch"; Filename: "{app}\hl.exe"; Parameters: "-game coobydm"; WorkingDir: "{app}"; Tasks: desktopicon

[Run]
#ifexist AddBackslash(SourcePath) + "vc_redist.x86.exe"
Filename: "{tmp}\vc_redist.x86.exe"; Parameters: "/install /quiet /norestart"; StatusMsg: "Installing Visual C++ runtime..."; Flags: waituntilterminated
#endif
Filename: "{app}\hl.exe"; Parameters: "-game coobydm"; WorkingDir: "{app}"; Description: "Launch Cooby's Deathmatch"; Flags: postinstall nowait skipifsilent

[UninstallDelete]
Type: filesandordirs; Name: "{app}\coobydm"

[Code]
function IsHalfLifeDir(Dir: String): Boolean;
begin
  Result := (Dir <> '') and DirExists(AddBackslash(Dir) + 'valve');
end;

function GetHalfLifeDir(Param: String): String;
var
  SteamPath, Line, LibPath, Candidate: String;
  Lines: TArrayOfString;
  I, P: Integer;
begin
  Result := ExpandConstant('{commonpf32}\Steam\steamapps\common\Half-Life');
  if not RegQueryStringValue(HKCU, 'Software\Valve\Steam', 'SteamPath', SteamPath) then
    SteamPath := ExpandConstant('{commonpf32}\Steam');
  StringChangeEx(SteamPath, '/', '\', True);

  Candidate := AddBackslash(SteamPath) + 'steamapps\common\Half-Life';
  if IsHalfLifeDir(Candidate) then
  begin
    Result := Candidate;
    exit;
  end;

  // Half-Life might live in another Steam library (another drive)
  if LoadStringsFromFile(AddBackslash(SteamPath) + 'steamapps\libraryfolders.vdf', Lines) then
    for I := 0 to GetArrayLength(Lines) - 1 do
    begin
      Line := Trim(Lines[I]);
      if Pos('"path"', Line) = 1 then
      begin
        LibPath := Trim(Copy(Line, 7, Length(Line)));
        P := Pos('"', LibPath);
        if P = 1 then
        begin
          LibPath := Copy(LibPath, 2, Length(LibPath) - 2);
          StringChangeEx(LibPath, '\\', '\', True);
          Candidate := AddBackslash(LibPath) + 'steamapps\common\Half-Life';
          if IsHalfLifeDir(Candidate) then
          begin
            Result := Candidate;
            exit;
          end;
        end;
      end;
    end;
end;

function NextButtonClick(CurPageID: Integer): Boolean;
begin
  Result := True;
  if (CurPageID = wpSelectDir) and not IsHalfLifeDir(WizardDirValue) then
  begin
    MsgBox('That folder doesn''t look like Half-Life (no "valve" folder inside).' + #13#10 +
      'Pick the folder that contains valve, usually Steam\steamapps\common\Half-Life.', mbError, MB_OK);
    Result := False;
  end;
end;
