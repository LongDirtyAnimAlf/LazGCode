unit Tools;

{$mode ObjFPC}{$H+}

interface

uses
  Classes, SysUtils, TypInfo
  {$ifdef MSWindows}
  ,Windows, JvSetupApi
  {$endif}
  ;

type
  TCharSet = set of Char;

function  GetEnumNameSimple(aTypeInfo:PTypeInfo;const aEnum:integer):string;
function  GetEnumNameUnCamel(aTypeInfo:PTypeInfo;const aEnum:integer):string;
function  GetEnumValueSimple(aTypeInfo:PTypeInfo;const aEnum:string):integer;
procedure EnumerateCOMPorts(ComList: TStrings);
function  NowUTC: TDateTime;
function  OccurrencesOfChar(const ContentString: string; const CharToCount: char): integer;
function  HexToInt(Hex:String): Integer;
function  CountSetItems(SetValue: Integer): Byte;
procedure SetCountStringList(aSL:TSTringList;Value: Integer);
function  GetTargetCPU:string;
function  GetTargetOS:string;
function  GetTargetCPUOS:string;
function  ExtractWhileConforming(const S: string; const ValidChars: TCharSet): string;

implementation

{$ifdef UNIX}
uses
  Unix, BaseUnix;
{$endif}

function UnCamelString(value:string):string;
var
  s:string;
  len,i,j:integer;
begin
  result:='';
  len:=Length(value);
  if (len=0) then exit;

  SetLength({%H-}s,256);
  i:=1;

  while (i<=len) do
  begin
    if (value[i] in ['A'..'Z']) then break;
    Inc(i);
  end;

  j:=1;

  while (i<=len) do
  begin

    while (i<=len) do
    begin
      if (value[i] in ['A'..'Z']) then s[j]:=value[i] else break;
      Inc(i);
      Inc(j);
    end;
    if ((j>2) AND (i<=len)) then
    begin
      s[j]:=s[j-1];
      s[j-1]:=' ';
      Inc(j);
    end;
    while (i<=len) do
    begin
      if (NOT (value[i] in ['A'..'Z'])) then s[j]:=value[i] else break;
      Inc(i);
      Inc(j);
    end;

  end;

  SetLength(s,j-1);
  result:=s;
end;


function GetEnumNameSimple(aTypeInfo:PTypeInfo;const aEnum:integer):string;
begin
  begin
    if (aTypeInfo=nil) or (aTypeInfo^.Kind<>tkEnumeration) then
      result := '' else
      result := GetEnumName(aTypeInfo,aEnum);
  end;
end;

function GetEnumNameUnCamel(aTypeInfo:PTypeInfo;const aEnum:integer):string;
begin
  begin
    if (aTypeInfo=nil) or (aTypeInfo^.Kind<>tkEnumeration) then
      result := '' else
      result := UnCamelString(GetEnumName(aTypeInfo,aEnum));
  end;
end;

function GetEnumValueSimple(aTypeInfo:PTypeInfo;const aEnum:string):integer;
begin
  begin
    if (aTypeInfo=nil) or (aTypeInfo^.Kind<>tkEnumeration) then
      result := -1 else
      result:=GetEnumValue(aTypeInfo,aEnum);
  end;
end;

{$ifdef MSWindows}
procedure EnumerateCOMPorts(ComList: TStrings);
const
  GUID_DEVINTERFACE_COMPORT:TGUID='{86E0D1E0-8089-11D0-9CE4-08003E301F73}';
var
  cbRequired          : DWORD;
  hdev                : HDEVINFO;
  idev                : Integer;
  did                 : TSPDeviceInterfaceData;
  pdidd               : PSPDeviceInterfaceDetailData;
  s                   : string;
  PropertyBuffer      : array[0..255] of Char;
  DeviceInfoData      : TSPDevInfoData;
  PropertyRegDataType : DWORD;
  RequiredSize        : DWORD;
  Key                 : HKEY;
  PortName            : string;
  RegType,Count       : DWORD;
begin
  // enumerate the com ports
  LoadSetupApi;
  hdev :=  SetupDiGetClassDevs(@GUID_DEVINTERFACE_COMPORT, nil, 0,  DIGCF_PRESENT OR DIGCF_DEVICEINTERFACE);
  if (INVALID_HANDLE_VALUE<> THandle(hdev)) then
  begin
    try
      idev:=0;
      ZeroMemory(@did, SizeOf(did));
      did.cbSize := SizeOf(did);
      repeat
        if (SetupDiEnumDeviceInterfaces(hdev, nil, GUID_DEVINTERFACE_COMPORT, idev, did)) then
        begin
           cbRequired := 0;
           SetupDiGetDeviceInterfaceDetail(hdev, @did, nil, 0, cbRequired, nil);
           if (ERROR_INSUFFICIENT_BUFFER= GetLastError()) then
           begin
             pdidd:=AllocMem(cbRequired);
             try
               pdidd^.cbSize := SizeOf(TSPDeviceInterfaceDetailData);
               DeviceInfoData.cbSize:= SizeOf(DeviceInfoData);
               RequiredSize:=0;
               if (SetupDiGetDeviceInterfaceDetail(hdev, @did, pdidd, cbRequired, RequiredSize, @DeviceInfoData)) then
               begin

                 PropertyRegDataType:=0;
                 RequiredSize:=0;
                 s:='';

                 {
                 if SetupDiGetDeviceRegistryProperty(hdev, DeviceInfoData, SPDRP_FRIENDLYNAME, PropertyRegDataType,  PBYTE(@PropertyBuffer[0]), SizeOf(PropertyBuffer), RequiredSize) then
                 begin
                   s:=s+PropertyBuffer;
                 end;
                 s:=s+DefaultFormatSettings.ListSeparator;

                 if SetupDiGetDeviceRegistryProperty(hdev, DeviceInfoData, SPDRP_DEVICEDESC, PropertyRegDataType,  PBYTE(@PropertyBuffer[0]), SizeOf(PropertyBuffer), RequiredSize) then
                 begin
                   s:=s+PropertyBuffer;
                 end;
                 s:=s+DefaultFormatSettings.ListSeparator;

                 if SetupDiGetDeviceRegistryProperty(hdev, DeviceInfoData, SPDRP_MFG, PropertyRegDataType,  PBYTE(@PropertyBuffer[0]), SizeOf(PropertyBuffer), RequiredSize) then
                 begin
                   s:=s+PropertyBuffer;
                 end;
                 s:=s+DefaultFormatSettings.ListSeparator;
                 }

                 Key := SetupDiOpenDevRegKey(hdev, DeviceInfoData, DICS_FLAG_GLOBAL, 0, DIREG_DEV, KEY_QUERY_VALUE);
                 if (Key<>0) then
                 try
                   SetLength({%H-}PortName, MAX_PATH);
                   Count := Length(PortName);
                   Windows.RegQueryValueEx(Key, 'PortName', nil, @RegType, PByte(PChar(PortName)), @Count);
                   if (Count>0) AND (RegType=REG_SZ) then
                   begin
                     SetLength(PortName, Count - 1);
                     s:=s+PortName;
                   end;
                 finally
                   Windows.RegCloseKey(Key);
                 end;
                 s:=s+DefaultFormatSettings.ListSeparator;

                 if Length(s)>0 then
                 begin
                   SetLength(s,Length(s)-1);
                   ComList.Append(s);
                 end;
                end
                else
                begin
                  RaiseLastOSError;
                end;
              finally
                FreeMem(pdidd);
              end;
           end;
        end
        else
        begin
          break;
        end;
        inc(idev);
      until false;
    finally
      SetupDiDestroyDeviceInfoList(hdev);
    end;
  end;
  UnloadSetupApi;
end;
{$else}
procedure EnumerateCOMPorts(ComList: TStrings);
var
  sr : TSearchRec;
begin
  if FindFirst('/dev/ttyS*', $FFFFFFFF, sr) = 0 then
    repeat
      if (sr.Attr and $FFFFFFFF) = Sr.Attr then
      begin
        ComList.Append(sr.Name);
      end;
    until FindNext(sr) <> 0;
  FindClose(sr);
  if FindFirst('/dev/ttyUSB*', $FFFFFFFF, sr) = 0 then begin
    repeat
      if (sr.Attr and $FFFFFFFF) = Sr.Attr then begin
        ComList.Append(sr.Name);
      end;
    until FindNext(sr) <> 0;
  end;
  FindClose(sr);
  if FindFirst('/dev/ttyAM*', $FFFFFFFF, sr) = 0 then begin
    repeat
      if (sr.Attr and $FFFFFFFF) = Sr.Attr then begin
        ComList.Append(sr.Name);
      end;
    until FindNext(sr) <> 0;
  end;
  FindClose(sr);
end;
{$endif}

{$ifdef UNIX}
const // Date Translation - see http://en.wikipedia.org/wiki/Julian_day
  HoursPerDay = 24;
  MinsPerHour = 60;
  SecsPerMin  = 60;
  MinsPerDay  = HoursPerDay*MinsPerHour;
  SecsPerDay  = MinsPerDay*SecsPerMin;
  SecsPerHour = MinsPerHour*SecsPerMin;
  C1970       = 2440588;
  D0          = 1461;
  D1          = 146097;
  D2          = 1721119;

procedure JulianToGregorian(JulianDN: integer; out Year,Month,Day: Word);
var YYear,XYear,Temp,TempMonth: integer;
begin
  Temp := ((JulianDN-D2) shl 2)-1;
  JulianDN := Temp div D1;
  XYear := (Temp mod D1) or 3;
  YYear := (XYear div D0);
  Temp := ((((XYear mod D0)+4) shr 2)*5)-3;
  Day := ((Temp mod 153)+5) div 5;
  TempMonth := Temp div 153;
  if TempMonth>=10 then begin
    inc(YYear);
    dec(TempMonth,12);
  end;
  inc(TempMonth,3);
  Month := TempMonth;
  Year := YYear+(JulianDN*100);
end;

procedure EpochToLocal(epoch: integer; out year,month,day,hour,minute,second: Word);
begin
  JulianToGregorian((Epoch div SecsPerDay)+c1970,year,month,day);
  Epoch := abs(Epoch mod SecsPerDay);
  Hour := Epoch div SecsPerHour;
  Epoch := Epoch mod SecsPerHour;
  Minute := Epoch div SecsPerMin;
  Second := Epoch mod SecsPerMin;
end;

procedure GetNowUTCSystem(var result: TSystemTime);
var tz: timeval;
begin
  fpgettimeofday(@tz,nil);
  EpochToLocal(tz.tv_sec,result.year,result.month,result.day,result.hour,result.Minute,result.Second);
  result.MilliSecond := tz.tv_usec div 1000;
end;

function NowUTC: TDateTime;
var SystemTime: TSystemTime;
begin
  GetNowUTCSystem(SystemTime);
  result := SystemTimeToDateTime(SystemTime);
end;
{$else}
function NowUTC: TDateTime;
var
  st: TSystemTime;
begin
  GetSystemTime({%H-}st);
  //result := EncodeDateTime(st.wYear, st.wMonth, st.wDay, st.wHour, st.wMinute, st.wSecond, st.wMilliseconds);
  result := SysUtils.SystemTimeToDateTime (st);
  //result := TTimeZone.Local.ToUniversalTime(Now);
end;
{$endif}

function OccurrencesOfChar(const ContentString: string; const CharToCount: char): integer;
var
  C: Char;
begin
  result := 0;
  for C in ContentString do
    if C = CharToCount then
      Inc(result);
end;

function HexToInt(Hex:String) : Integer;
const
  HexSymbols : String = '0123456789ABCDEF';
var
  I,J : Integer;
begin
  Hex := UpperCase(Hex);
  Result := 0;
  J := Length(Hex);
  For I := 1 to J do
    Result := Result+((Pos(Hex[J-I+1],HexSymbols)-1) shl ((I-1)*4));
end;

function CountSetItems(SetValue: Integer): Byte;
var
  Mask: dword;
begin
  Mask := $80000000;
  Result := 0;
  while Mask <> 0 do begin
    if SetValue and Mask <> 0 then
      inc(Result);
    Mask := Mask shr 1;
  end;
end;

procedure SetCountStringList(aSL:TSTringList;Value: Integer);
begin
  aSL.BeginUpdate;
  try
    while (aSL.Count<Value) do
      aSL.Add('');
    while (aSL.Count>Value) do
      aSL.Delete(aSL.Count-1);
  finally
    aSL.EndUpdate;
  end;
end;

function GetTargetCPU:string;
begin
  result:=lowercase({$i %FPCTARGETCPU%});
end;

function GetTargetOS:string;
begin
  result:=lowercase({$i %FPCTARGETOS%});
end;

function GetTargetCPUOS:string;
begin
  result:=GetTargetCPU+'-'+GetTargetOS;
end;

function ExtractWhileConforming(const S: string; const ValidChars: TCharSet): string;
var
  DestI: Integer;
  SourceI: Integer;
begin
  SetLength(Result, Length(S));
  DestI := 0;
  for SourceI := 1 to Length(S) do
    if S[SourceI] in ValidChars then
    begin
      Inc(DestI);
      Result[DestI] := S[SourceI]
    end else break;
  SetLength(Result, DestI)
end;

end.

