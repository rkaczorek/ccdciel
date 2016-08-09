unit pu_scriptengine;

{$mode objfpc}{$H+}
{
Copyright (C) 2016 Patrick Chevalley

http://www.ap-i.net
pch@ap-i.net

This program is free software; you can redistribute it and/or
modify it under the terms of the GNU General Public License
as published by the Free Software Foundation; either version 2
of the License, or (at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program; if not, write to the Free Software
Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA.
}
{
 Script engine with specific function for CCDciel
}

interface

uses  u_global, u_utils, cu_fits, indiapi, cu_planetarium, fu_ccdtemp, fu_devicesconnection,
  fu_capture, fu_preview, cu_wheel, cu_mount, cu_camera, cu_focuser, cu_autoguider, cu_astrometry,
  Classes, SysUtils, FileUtil, uPSComponent, uPSComponent_Default,
  uPSComponent_Forms, uPSComponent_Controls, uPSComponent_StdCtrls, Forms,
  Controls, Graphics, Dialogs, ExtCtrls;

type

  { Tf_scriptengine }

  Tf_scriptengine = class(TForm)
    PSImport_Classes1: TPSImport_Classes;
    PSImport_Controls1: TPSImport_Controls;
    PSImport_DateUtils1: TPSImport_DateUtils;
    PSImport_Forms1: TPSImport_Forms;
    PSImport_StdCtrls1: TPSImport_StdCtrls;
    ShutdownTimer: TTimer;
    TplPSScript: TPSScript;
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure ShutdownTimerTimer(Sender: TObject);
    procedure TplPSScriptCompile(Sender: TPSScript);
    procedure TplPSScriptLine(Sender: TObject);
  private
    { private declarations }
    FScriptFilename: string;
    Ffits : TFits;
    Fdevicesconnection:Tf_devicesconnection;
    Fcapture: Tf_capture;
    Fpreview: Tf_preview;
    Fccdtemp: Tf_ccdtemp;
    Ffilter: T_wheel;
    Fmount: T_mount;
    Fcamera: T_camera;
    FFocuser: T_focuser;
    Fautoguider: T_autoguider;
    Fastrometry: TAstrometry;
    Fplanetarium: TPlanetarium;
    FonMsg: TNotifyMsg;
    FonStartSequence: TNotifyMsg;
    ilist: array of Integer;
    dlist: array of Double;
    slist: array of String;
    LastErr:string;
    strllist: array of TStringList;
    function doGetS(varname:string; var str: string):Boolean;
    function doSetS(varname:string; str: string):Boolean;
    function doGetSL(varname:string; var strl: TStringList):Boolean;
    function doSetSL(varname:string; strl: TStringList):Boolean;
    function doGetI(varname:string; var i: Integer):Boolean;
    function doSetI(varname:string; i: Integer):Boolean;
    function doGetD(varname:string; var x: Double):Boolean;
    function doSetD(varname:string; x: Double):Boolean;
    function doGetB(varname:string; var x: Boolean):Boolean;
    function doOpenFile(fn:string):boolean;
    function doRun(cmdline:string):boolean;
    function doRunWait(cmdline:string):boolean;
    function doRunOutput(cmdline:string; var output:TStringlist):boolean;
    Function doJDtoStr(var jd: Double) : string;
    Function doStrtoJD(dt:string; var jdt: Double) : boolean;
    Function doARtoStr(var ar: Double) : string;
    Function doDEtoStr(var de: Double) : string;
    Function doStrtoAR(str:string; var ar: Double) : boolean;
    Function doStrtoDE(str:string; var de: Double) : boolean;
    Procedure doEq2Hz(var ra,de,a,h : double);
    Procedure doHz2Eq(var a,h,ra,de : double);
    function doFormatFloat(Const Format : String; var Value : double) : String;
    function doFormat(Const Fmt : String; const Args : Array of const) : String;
    Procedure doStrtoFloatD(str:string; var defval: Double; var val: Double);
    function doStringReplace(str,s1,s2: String): string;
    function doIsNumber(str: String): boolean;
    function doMsgBox(const aMsg: string):boolean;
    Procedure doShowMessage(const aMsg: string);
    procedure doLogmsg(str:string);
    procedure doWait(wt:integer);
    function Cmd(cname:string):string;
    function CmdArg(cname:string; var arg:Tstringlist):string;
    function CompileScripts: boolean;
    function cmd_DevicesConnection(onoff:string):string;
    function cmd_MountPark(onoff:string):string;
    function cmd_MountTrack:string;
    function cmd_MountSlew(RA,DE:string):string;
    function cmd_MountSync(RA,DE:string):string;
    function cmd_MountAbortMotion:string;
    function cmd_EqmodClearPoints:string;
    function cmd_EqmodClearSyncDelta:string;
    function cmd_EqmodStdSync:string;
    function cmd_EqmodAppendSync:string;
    function cmd_AutoguiderCalibrate:string;
    function cmd_AutoguiderStartGuiding:string;
    function cmd_AutoguiderStopGuiding:string;
    function cmd_AutoguiderPause:string;
    function cmd_AutoguiderUnPause:string;
    function cmd_AutoguiderDither:string;
    function cmd_Wheel_GetFilter:string;
    function cmd_Wheel_SetFilter(num:string):string;
    function cmd_Wheel_GetFiltersName(var fl:TStringList):string;
    function cmd_Wheel_SetFiltersName(fl:TStringList):string;
    function cmd_Ccd_SetTemperature(t:string):string;
    function cmd_Preview_SetExposure(exp:string):string;
    function cmd_Preview_SetBinning(bin:string):string;
    function cmd_Preview_Single:string;
    function cmd_Preview_Loop:string;
    function cmd_Preview_Stop:string;
    function cmd_Capture_SetExposure(exp:string):string;
    function cmd_Capture_SetBinning(bin:string):string;
    function cmd_Capture_SetObjectName(obj:string):string;
    function cmd_Capture_SetCount(num:string):string;
    function cmd_Capture_SetFrameType(typ:string):string;
    function cmd_Capture_SetDither(num:string):string;
    function cmd_Capture_Start:string;
    function cmd_Capture_Stop:string;
    function cmd_AstrometrySolve:string;
    function cmd_AstrometrySync:string;
    function cmd_PlanetariumConnect:string;
    function cmd_PlanetariumShowImage:string;
    function cmd_ProgramShutdown:string;
    function cmd_SequenceStart(seq:string):string;
  public
    { public declarations }
    dbgscr: TPSScriptDebugger;
    scr: TPSScript;
    procedure StopScript;
    property onMsg: TNotifyMsg read FonMsg write FonMsg;
    property onStartSequence: TNotifyMsg read FonStartSequence write FonStartSequence;
    property fits: TFits read Ffits write Ffits;
    property DevicesConnection: Tf_devicesconnection read Fdevicesconnection write Fdevicesconnection;
    property Ccdtemp: Tf_ccdtemp read Fccdtemp write Fccdtemp;
    property Preview: Tf_preview read Fpreview write Fpreview;
    property Capture: Tf_capture read Fcapture write Fcapture;
    property Mount: T_mount read Fmount write Fmount;
    property Camera: T_camera read Fcamera write Fcamera;
    property Focuser: T_focuser read FFocuser write FFocuser;
    property Filter: T_wheel read Ffilter write Ffilter;
    property Autoguider: T_autoguider read Fautoguider write Fautoguider;
    property Astrometry: TAstrometry read Fastrometry write Fastrometry;
    property Planetarium: TPlanetarium read Fplanetarium write Fplanetarium;
    property ScriptFilename: string read FScriptFilename;
  end;

var
  f_scriptengine: Tf_scriptengine;

implementation

{$R *.lfm}

{ Tf_scriptengine }

procedure Tf_scriptengine.FormCreate(Sender: TObject);
var i: integer;
begin
  SetLength(ilist,10);
  SetLength(dlist,10);
  SetLength(slist,10);
  SetLength(strllist,10);
  for i:=0 to 9 do strllist[i]:=TStringList.Create;
  scr:=TPSScriptDebugger.Create(self);
  scr.OnCompile:=@TplPSScriptCompile;
  scr.OnLine:=@TplPSScriptLine;
  scr.Plugins.Assign(TplPSScript.Plugins);
  dbgscr:=TPSScriptDebugger.Create(self);
  dbgscr.OnCompile:=@TplPSScriptCompile;
  dbgscr.OnLine:=@TplPSScriptLine;
  dbgscr.Plugins.Assign(TplPSScript.Plugins);
end;

procedure Tf_scriptengine.FormDestroy(Sender: TObject);
var i: integer;
begin
  scr.Free;
  dbgscr.Free;
  SetLength(ilist,0);
  SetLength(dlist,0);
  SetLength(slist,0);
  for i:=0 to 9 do strllist[i].Free;
  SetLength(strllist,0);
end;

procedure Tf_scriptengine.TplPSScriptLine(Sender: TObject);
begin
  Application.ProcessMessages;
end;

   function Tf_scriptengine.doGetS(varname:string; var str: string):Boolean;
begin
  result:=true;
  varname:=uppercase(varname);
  if varname='LASTERROR' then str:=LastErr
  else if varname='STR1' then str:=slist[0]
  else if varname='STR2' then str:=slist[1]
  else if varname='STR3' then str:=slist[2]
  else if varname='STR4' then str:=slist[3]
  else if varname='STR5' then str:=slist[4]
  else if varname='STR6' then str:=slist[5]
  else if varname='STR7' then str:=slist[6]
  else if varname='STR8' then str:=slist[7]
  else if varname='STR9' then str:=slist[8]
  else if varname='STR10' then str:=slist[9]
  else result:=false;
end;

function Tf_scriptengine.doSetS(varname:string; str: string):Boolean;
begin
  result:=true;
  varname:=uppercase(varname);
  if varname='STR1' then slist[0]:=str
  else if varname='STR2' then slist[1]:=str
  else if varname='STR3' then slist[2]:=str
  else if varname='STR4' then slist[3]:=str
  else if varname='STR5' then slist[4]:=str
  else if varname='STR6' then slist[5]:=str
  else if varname='STR7' then slist[6]:=str
  else if varname='STR8' then slist[7]:=str
  else if varname='STR9' then slist[8]:=str
  else if varname='STR10' then slist[9]:=str
  else result:=false;
end;

function Tf_scriptengine.doGetSL(varname:string; var strl: TStringList):Boolean;
begin
result:=true;
varname:=uppercase(varname);
if varname='STRL1' then strl:=strllist[0]
else if varname='STRL2' then strl:=strllist[1]
else if varname='STRL3' then strl:=strllist[2]
else if varname='STRL4' then strl:=strllist[3]
else if varname='STRL5' then strl:=strllist[4]
else if varname='STRL6' then strl:=strllist[5]
else if varname='STRL7' then strl:=strllist[6]
else if varname='STRL8' then strl:=strllist[7]
else if varname='STRL9' then strl:=strllist[8]
else if varname='STRL10' then strl:=strllist[9]
else result:=false;
end;

function Tf_scriptengine.doSetSL(varname:string; strl: TStringList):Boolean;
begin
result:=true;
varname:=uppercase(varname);
if varname='STRL1' then strllist[0]:=strl
else if varname='STRL2' then strllist[1]:=strl
else if varname='STRL3' then strllist[2]:=strl
else if varname='STRL4' then strllist[3]:=strl
else if varname='STRL5' then strllist[4]:=strl
else if varname='STRL6' then strllist[5]:=strl
else if varname='STRL7' then strllist[6]:=strl
else if varname='STRL8' then strllist[7]:=strl
else if varname='STRL9' then strllist[8]:=strl
else if varname='STRL10' then strllist[9]:=strl
else result:=false;
end;

function  Tf_scriptengine.doGetD(varname:string; var x: double):boolean;
begin
  result:=true;
  varname:=uppercase(varname);
  if varname='TELESCOPERA' then x:=Fmount.RA
  else if varname='TELESCOPEDE' then x:=Fmount.Dec
  else if varname='CCDTEMP' then x:=Fcamera.Temperature
  else if varname='TIMENOW' then x:=now
  else if varname='DOUBLE1' then x:=dlist[0]
  else if varname='DOUBLE2' then x:=dlist[1]
  else if varname='DOUBLE3' then x:=dlist[2]
  else if varname='DOUBLE4' then x:=dlist[3]
  else if varname='DOUBLE5' then x:=dlist[4]
  else if varname='DOUBLE6' then x:=dlist[5]
  else if varname='DOUBLE7' then x:=dlist[6]
  else if varname='DOUBLE8' then x:=dlist[7]
  else if varname='DOUBLE9' then x:=dlist[8]
  else if varname='DOUBLE10' then x:=dlist[9]
  else result:=false;
end;

function Tf_scriptengine.doSetD(varname:string; x: Double):Boolean;
begin
  result:=true;
  varname:=uppercase(varname);
  if varname='DOUBLE1' then dlist[0]:=x
  else if varname='DOUBLE2' then dlist[1]:=x
  else if varname='DOUBLE3' then dlist[2]:=x
  else if varname='DOUBLE4' then dlist[3]:=x
  else if varname='DOUBLE5' then dlist[4]:=x
  else if varname='DOUBLE6' then dlist[5]:=x
  else if varname='DOUBLE7' then dlist[6]:=x
  else if varname='DOUBLE8' then dlist[7]:=x
  else if varname='DOUBLE9' then dlist[8]:=x
  else if varname='DOUBLE10' then dlist[9]:=x
  else result:=false;
end;

function  Tf_scriptengine.doGetI(varname:string; var i: Integer):Boolean;
begin
  result:=true;
  varname:=uppercase(varname);
  if varname='INT1' then i:=ilist[0]
  else if varname='INT2' then i:=ilist[1]
  else if varname='INT3' then i:=ilist[2]
  else if varname='INT4' then i:=ilist[3]
  else if varname='INT5' then i:=ilist[4]
  else if varname='INT6' then i:=ilist[5]
  else if varname='INT7' then i:=ilist[6]
  else if varname='INT8' then i:=ilist[7]
  else if varname='INT9' then i:=ilist[8]
  else if varname='INT10' then i:=ilist[9]
  else result:=false;
end;

function Tf_scriptengine.doSetI(varname:string; i: Integer):Boolean;
begin
  result:=true;
  varname:=uppercase(varname);
  if varname='INT1' then ilist[0]:=i
  else if varname='INT2' then ilist[1]:=i
  else if varname='INT3' then ilist[2]:=i
  else if varname='INT4' then ilist[3]:=i
  else if varname='INT5' then ilist[4]:=i
  else if varname='INT6' then ilist[5]:=i
  else if varname='INT7' then ilist[6]:=i
  else if varname='INT8' then ilist[7]:=i
  else if varname='INT9' then ilist[8]:=i
  else if varname='INT10' then ilist[9]:=i
  else result:=false;
end;

function Tf_scriptengine.doGetB(varname:string; var x: Boolean):Boolean;
begin
  result:=true;
  varname:=uppercase(varname);
  if varname='TELESCOPE_CONNECTED' then x:=(mount.Status=devConnected)
  else if varname='TELESCOPE_PARKED' then x:=mount.Park
  else if varname='TELESCOPE_EQMOD' then x:=mount.IsEqmod
  else if varname='AUTOGUIDER_CONNECTED' then x:=(Autoguider.State<>GUIDER_DISCONNECTED)
  else if varname='AUTOGUIDER_RUNNING' then x:=Autoguider.Running
  else if varname='AUTOGUIDER_GUIDING' then x:=(Autoguider.State=GUIDER_GUIDING)
  else if varname='WHEEL_CONNECTED' then x:=(Filter.Status=devConnected)
  else if varname='FOCUSER_CONNECTED' then x:=(Focuser.Status=devConnected)
  else if varname='CAMERA_CONNECTED' then x:=(Camera.Status=devConnected)
  else if varname='PLANETARIUM_CONNECTED' then x:=Planetarium.Connected
  else if varname='PREVIEW_RUNNING' then x:=Preview.Running
  else if varname='PREVIEW_LOOP' then x:=Preview.Loop
  else if varname='CAPTURE_RUNNING' then x:=Capture.Running
  else result:=false;
end;

Procedure Tf_scriptengine.doEq2Hz(var ra,de,a,h : double);
begin
 cmdEq2Hz(ra,de,a,h);
end;

Procedure Tf_scriptengine.doHz2Eq(var a,h,ra,de : double);
begin
 cmdHz2Eq(a,h,ra,de);
end;

function Tf_scriptengine.doFormatFloat(Const Format : String; var Value : double) : String;
begin
  result:=FormatFloat(format, Value);
end;

Procedure Tf_scriptengine.doStrtoFloatD(str:string; var defval: Double; var val: Double);
begin
  val:=StrToFloatDef(str,defval);
end;

function Tf_scriptengine.doStringReplace(str,s1,s2: String): string;
begin
  result:=StringReplace(str,s1,s2,[rfReplaceAll]);
end;

function Tf_scriptengine.doFormat(Const Fmt : String; const Args : Array of const) : String;
begin
 result:=Format(Fmt,Args);
end;

function Tf_scriptengine.doIsNumber(str: String): boolean;
begin
  result:=IsNumber(str);
end;

function Tf_scriptengine.doMsgBox(const aMsg: string):boolean;
begin
  result:=MessageDlg(aMsg,mtConfirmation,mbYesNo,0)=mrYes;
end;

Procedure Tf_scriptengine.doShowMessage(const aMsg: string);
begin
  ShowMessage(aMsg);
end;

procedure Tf_scriptengine.doLogmsg(str:string);
begin
  if Assigned(FonMsg) then FonMsg(str);
end;

function Tf_scriptengine.doOpenFile(fn:string):boolean;
var i: integer;
begin
  i:=ExecuteFile(fn);
  result:=(i=0);
end;

function Tf_scriptengine.doRun(cmdline:string):boolean;
begin
  ExecNoWait(cmdline,'',true);
  wait(1);
  result:=true;
end;

function Tf_scriptengine.doRunWait(cmdline:string):boolean;
var i: integer;
begin
  i:=ExecProcess(cmdline,nil,false);
  wait(1);
  result:=(i=0);
end;

function Tf_scriptengine.doRunOutput(cmdline:string; var output:TStringlist):boolean;
var i: integer;
begin
  i:=ExecProcess(cmdline,output,false);
  wait(1);
  result:=(i=0);
end;

Function Tf_scriptengine.doARtoStr(var ar: Double) : string;
begin
  // script do not work if a float parameter is not var.
  result:=ARtoStr3(ar);
end;

Function Tf_scriptengine.doDEtoStr(var de: Double) : string;
begin
  result:=DEtoStr3(de);
end;

Function Tf_scriptengine.doStrtoAR(str:string; var ar: Double) : boolean;
begin
  if trim(str)<>'' then begin
    ar:=Str3ToAR(str);
    result:=(ar<>0);
  end
  else result:=false;
end;

Function Tf_scriptengine.doStrtoDE(str:string; var de: Double) : boolean;
begin
  if trim(str)<>'' then begin
    str:=StringReplace(str,ldeg,'d',[rfReplaceAll]);
    str:=StringReplace(str,lmin,'m',[rfReplaceAll]);
    str:=StringReplace(str,lsec,'s',[rfReplaceAll]);
    de:=Str3ToDE(str);
    result:=(de<>0);
  end
  else result:=false;
end;

Function Tf_scriptengine.doJDtoStr(var jd: Double) : string;
begin
  result:=jddate(jd);
end;

Function Tf_scriptengine.doStrtoJD(dt:string; var jdt: Double) : boolean;
var sy,y,m,d,p: integer;
    h:double;
begin
result:=false;
sy:=1;
h:=0;
dt:=trim(dt);
if length(dt)>2 then begin
 if dt[1]='-' then begin sy:=-1; delete(dt,1,1); end;
 if dt[1]='+' then begin sy:=1; delete(dt,1,1); end;
end;
p:=pos('-',dt);
if p=0 then exit;
y:=sy*strtoint(trim(copy(dt,1,p-1)));
dt:=copy(dt,p+1,999);
p:=pos('-',dt);
if p=0 then exit;
m:=strtoint(trim(copy(dt,1,p-1)));
dt:=copy(dt,p+1,999);
p:=pos('T',dt);
if p=0 then p:=pos(' ',dt);
if p=0 then d:=strtoint(trim(dt))     // no time part
   else begin
    d:=strtoint(trim(copy(dt,1,p-1)));

   end;
jdt:=jd(y,m,d,h);
end;

procedure Tf_scriptengine.doWait(wt:integer);
begin
  Wait(wt);
end;

Procedure Tf_scriptengine.StopScript;
begin
scr.Stop;
end;

function Tf_scriptengine.CompileScripts: boolean;
begin
 result:=scr.Compile;
end;

procedure Tf_scriptengine.TplPSScriptCompile(Sender: TPSScript);
begin
with Sender as TPSScript do begin
  comp.AddConstantN('deg2rad', 'extended').SetExtended(deg2rad);
  comp.AddConstantN('rad2deg', 'extended').SetExtended(rad2deg);
  comp.AddConstantN('msgOK', 'string').SetString(msgOK);
  comp.AddConstantN('msgFailed', 'string').SetString(msgFailed);
  AddMethod(self, @Tf_scriptengine.Cmd, 'function Cmd(cname:string):string;');
  AddMethod(self, @Tf_scriptengine.CmdArg, 'function CmdArg(cname:string; var arg:Tstringlist):string;');
  AddMethod(self, @Tf_scriptengine.doGetS, 'function GetS(varname:string; var str: string):Boolean;');
  AddMethod(self, @Tf_scriptengine.doSetS, 'function SetS(varname:string; str: string):Boolean;');
  AddMethod(self, @Tf_scriptengine.doSetSL, 'function SetSL(varname:string; strl: TStringList):Boolean;');
  AddMethod(self, @Tf_scriptengine.doGetSL, 'function GetSL(varname:string; var strl: TStringList):Boolean;');
  AddMethod(self, @Tf_scriptengine.doGetI, 'function GetI(varname:string; var i: Integer):Boolean;');
  AddMethod(self, @Tf_scriptengine.doSetI, 'function SetI(varname:string; i: Integer):Boolean;');
  AddMethod(self, @Tf_scriptengine.doGetD, 'function GetD(varname:string; var x: double):boolean;');
  AddMethod(self, @Tf_scriptengine.doSetD, 'function SetD(varname:string; x: Double):Boolean;');
  AddMethod(self, @Tf_scriptengine.doGetB, 'function GetB(varname:string; var x: Boolean):Boolean;');
  AddMethod(self, @Tf_scriptengine.doARtoStr, 'Function ARtoStr(var ar: Double) : string;');
  AddMethod(self, @Tf_scriptengine.doDEtoStr, 'Function DEtoStr(var de: Double) : string;');
  AddMethod(self, @Tf_scriptengine.doStrtoAR, 'Function StrtoAR(str:string; var ar: Double) : boolean;');
  AddMethod(self, @Tf_scriptengine.doStrtoDE, 'Function StrtoDE(str:string; var de: Double) : boolean;');
  AddMethod(self, @Tf_scriptengine.doJDtoStr, 'Function JDtoStr(var jd: Double) : string;');
  AddMethod(self, @Tf_scriptengine.doStrtoJD, 'Function StrtoJD(dt:string; var jdt: Double) : boolean;');
  AddMethod(self, @Tf_scriptengine.doEq2Hz, 'Procedure Eq2Hz(var ra,de,a,h : double);');
  AddMethod(self, @Tf_scriptengine.doHz2Eq, 'Procedure Hz2Eq(var a,h,ra,de : double);');
  AddMethod(self, @Tf_scriptengine.doFormatFloat, 'function FormatFloat(Const Format : String; var Value : double) : String;');
  AddMethod(self, @Tf_scriptengine.doStrtoFloatD, 'Procedure StrtoFloatD(str:string; var defval: Double; var val: Double);');
  AddMethod(self, @Tf_scriptengine.doStringReplace, 'function StringReplace(str,s1,s2: String): string;');
  AddMethod(self, @Tf_scriptengine.doFormat, 'Function Format(Const Fmt : String; const Args : Array of const) : String;');
  AddMethod(self, @Tf_scriptengine.doIsNumber, 'function IsNumber(str: String): boolean;');
  AddMethod(self, @Tf_scriptengine.doMsgBox,'function MsgBox(const aMsg: string):boolean;');
  AddMethod(self, @Tf_scriptengine.doShowMessage,'Procedure ShowMessage(const aMsg: string);');
  AddMethod(self, @Tf_scriptengine.doLogmsg,'procedure Logmsg(str:string);');
  AddMethod(self, @Tf_scriptengine.doOpenFile,'function OpenFile(fn:string):boolean;');
  AddMethod(self, @Tf_scriptengine.doRun,'function Run(cmdline:string):boolean;');
  AddMethod(self, @Tf_scriptengine.doRunWait,'function RunWait(cmdline:string):boolean;');
  AddMethod(self, @Tf_scriptengine.doRunOutput,'function RunOutput(cmdline:string; var output:TStringlist):boolean;');
  AddMethod(self, @Tf_scriptengine.doWait,'procedure Wait(wt:integer);');
end;
end;

function Tf_scriptengine.Cmd(cname:string):string;
begin
cname:=uppercase(cname);
result:=msgFailed;
if cname='TELESCOPE_ABORTMOTION' then result:=cmd_MountAbortMotion
else if cname='TELESCOPE_TRACK' then result:=cmd_MountTrack
else if cname='EQMOD_CLEARPOINTS' then result:= cmd_EqmodClearPoints
else if cname='EQMOD_CLEARSYNCDELTA' then result:= cmd_EqmodClearSyncDelta
else if cname='EQMOD_STDSYNC' then result:= cmd_EqmodStdSync
else if cname='EQMOD_APPENDSYNC' then result:= cmd_EqmodAppendSync
else if cname='AUTOGUIDER_CALIBRATE' then result:=cmd_AutoguiderCalibrate
else if cname='AUTOGUIDER_STARTGUIDING' then result:=cmd_AutoguiderStartGuiding
else if cname='AUTOGUIDER_STOPGUIDING' then result:=cmd_AutoguiderStopGuiding
else if cname='AUTOGUIDER_PAUSE' then result:=cmd_AutoguiderPause
else if cname='AUTOGUIDER_UNPAUSE' then result:=cmd_AutoguiderUnPause
else if cname='AUTOGUIDER_DITHER' then result:=cmd_AutoguiderDither
else if cname='WHEEL_GETFILTER' then result:=cmd_Wheel_GetFilter
else if cname='PREVIEW_SINGLE' then result:=cmd_Preview_Single
else if cname='PREVIEW_LOOP' then result:=cmd_Preview_Loop
else if cname='PREVIEW_STOP' then result:=cmd_Preview_Stop
else if cname='CAPTURE_START' then result:=cmd_Capture_Start
else if cname='CAPTURE_STOP' then result:=cmd_Capture_Stop
else if cname='ASTROMETRY_SOLVE' then result:=cmd_AstrometrySolve
else if cname='ASTROMETRY_SYNC' then result:=cmd_AstrometrySync
else if cname='PLANETARIUM_CONNECT' then result:=cmd_PlanetariumConnect
else if cname='PLANETARIUM_SHOWIMAGE' then result:=cmd_PlanetariumShowImage
else if cname='PROGRAM_SHUTDOWN' then result:=cmd_ProgramShutdown
;
LastErr:='cmd('+cname+'): '+result;
end;

function Tf_scriptengine.CmdArg(cname:string; var arg:Tstringlist):string;
var i: integer;
begin
cname:=uppercase(cname);
for i:=arg.count to MaxCmdArg do arg.add('');
result:=msgFailed;
if cname='DEVICES_CONNECTION' then result:=cmd_DevicesConnection(arg[0])
else if cname='TELESCOPE_SLEW' then result:=cmd_MountSlew(arg[0],arg[1])
else if cname='TELESCOPE_SYNC' then result:=cmd_MountSync(arg[0],arg[1])
else if cname='TELESCOPE_PARK' then result:=cmd_MountPark(arg[0])
else if cname='WHEEL_SETFILTER' then result:=cmd_Wheel_SetFilter(arg[0])
else if cname='WHEEL_GETFILTERSNAME' then result:=cmd_Wheel_GetFiltersName(arg)
else if cname='WHEEL_SETFILTERSNAME' then result:=cmd_Wheel_SetFiltersName(arg)
else if cname='CCD_SETTEMPERATURE' then result:=cmd_Ccd_SetTemperature(arg[0])
else if cname='PREVIEW_SETEXPOSURE' then result:=cmd_Preview_SetExposure(arg[0])
else if cname='PREVIEW_SETBINNING' then result:=cmd_Preview_SetBinning(arg[0])
else if cname='CAPTURE_SETEXPOSURE' then result:=cmd_Capture_SetExposure(arg[0])
else if cname='CAPTURE_SETBINNING' then result:=cmd_Capture_SetBinning(arg[0])
else if cname='CAPTURE_SETOBJECTNAME' then result:=cmd_Capture_SetObjectName(arg[0])
else if cname='CAPTURE_SETCOUNT' then result:=cmd_Capture_SetCount(arg[0])
else if cname='CAPTURE_SETFRAMETYPE' then result:=cmd_Capture_SetFrameType(arg[0])
else if cname='CAPTURE_SETDITHER' then result:=cmd_Capture_SetDither(arg[0])
else if cname='SEQUENCE_START' then result:=cmd_SequenceStart(arg[0])
;
LastErr:='cmdarg('+cname+'): '+result;
end;

function Tf_scriptengine.cmd_DevicesConnection(onoff:string):string;
var connect: boolean;
begin
try
result:=msgFailed;
connect:=(onoff='ON');
if connect then
 Fdevicesconnection.Connect
else
 Fdevicesconnection.Disconnect(false);
wait(10);
result:=msgOK;
except
  result:=msgFailed;
end;
end;

function Tf_scriptengine.cmd_MountPark(onoff:string):string;
var park: boolean;
begin
try
result:=msgFailed;
park:=(onoff='ON');
Fmount.park:=park;
wait(2);
result:=msgOK;
except
  result:=msgFailed;
end;
end;

function Tf_scriptengine.cmd_MountTrack:string;
begin
try
result:=msgFailed;
Fmount.Track;
wait(2);
result:=msgOK;
except
  result:=msgFailed;
end;
end;

function Tf_scriptengine.cmd_MountSlew(RA,DE:string):string;
var r,d: double;
begin
try
result:=msgFailed;
r:=StrToFloatDef(RA,9999);
d:=StrToFloatDef(DE,9999);
if (abs(r)<=24)and(abs(d)<=90) then begin
 if Fmount.Slew(r,d) then begin
   wait(2);
   result:=msgOK;
 end;
end
else result:=msgFailed+' out of range';
except
  result:=msgFailed;
end;
end;

function Tf_scriptengine.cmd_MountSync(RA,DE:string):string;
var r,d: double;
begin
try
result:=msgFailed;
r:=StrToFloatDef(RA,9999);
d:=StrToFloatDef(DE,9999);
if (abs(r)<=360)and(abs(d)<=90) then begin
 if Fmount.Sync(r,d) then begin
   wait(2);
   result:=msgOK;
 end;
end
else result:=msgFailed+' out of range';
except
  result:=msgFailed;
end;
end;

function Tf_scriptengine.cmd_MountAbortMotion:string;
begin
try
Fmount.AbortMotion;
wait(2);
result:=msgOK;
except
  result:=msgFailed;
end;
end;

function Tf_scriptengine.cmd_EqmodClearPoints:string;
begin
try
  result:=msgFailed;
  if mount.IsEqmod then begin
     if mount.ClearAlignment then
       result:=msgOK;
  end
  else result:=msgFailed+' not an eqmod mount';
except
  result:=msgFailed;
end;
end;

function Tf_scriptengine.cmd_EqmodClearSyncDelta:string;
begin
try
  result:=msgFailed;
  if mount.IsEqmod then begin
     if mount.ClearDelta then
       result:=msgOK;
  end
  else result:=msgFailed+' not an eqmod mount';
except
  result:=msgFailed;
end;
end;

function Tf_scriptengine.cmd_EqmodStdSync:string;
begin
try
  result:=msgFailed;
  if mount.IsEqmod then begin
     mount.SyncMode:=alSTDSYNC;
     result:=msgOK;
  end
  else result:=msgFailed+' not an eqmod mount';
except
  result:=msgFailed;
end;
end;

function Tf_scriptengine.cmd_EqmodAppendSync:string;
begin
try
  result:=msgFailed;
  if mount.IsEqmod then begin
     mount.SyncMode:=alADDPOINT;
     result:=msgOK;
  end
  else result:=msgFailed+' not an eqmod mount';
except
  result:=msgFailed;
end;
end;

function Tf_scriptengine.cmd_AutoguiderCalibrate:string;
begin
try
 result:=msgFailed;
 if Autoguider=nil then exit;
 Autoguider.Calibrate;
 if Autoguider.WaitBusy(CalibrationDelay+SettleMaxTime) then result:=msgOK;
 wait(2);
except
   result:=msgFailed;
 end;
end;

function Tf_scriptengine.cmd_AutoguiderStartGuiding:string;
begin
 try
 result:=msgFailed;
 if Autoguider=nil then exit;
 Autoguider.Guide(true);
 if Autoguider.WaitBusy(CalibrationDelay+SettleMaxTime) then result:=msgOK;
 wait(2);
except
   result:=msgFailed;
 end;
end;

function Tf_scriptengine.cmd_AutoguiderStopGuiding:string;
begin
 try
 result:=msgFailed;
 if Autoguider=nil then exit;
 Autoguider.Guide(false);
 if Autoguider.WaitBusy(SettleMaxTime) then result:=msgOK;
 wait(2);
 except
   result:=msgFailed;
 end;
end;

function Tf_scriptengine.cmd_AutoguiderPause:string;
begin
 try
 result:=msgFailed;
 if Autoguider=nil then exit;
 Autoguider.Pause(true);
 wait(2);
 result:=msgOK;
 except
   result:=msgFailed;
 end;
end;

function Tf_scriptengine.cmd_AutoguiderUnPause:string;
begin
 try
 result:=msgFailed;
 if Autoguider=nil then exit;
 Autoguider.Pause(false);
 wait(2);
 result:=msgOK;
 except
   result:=msgFailed;
 end;
end;

function Tf_scriptengine.cmd_AutoguiderDither:string;
begin
 try
 result:=msgFailed;
 if Autoguider=nil then exit;
 Autoguider.Dither(DitherPixel, DitherRAonly);
 if Autoguider.WaitBusy(SettleMaxTime) then result:=msgOK;
 wait(2);
 except
   result:=msgFailed;
 end;
end;

function Tf_scriptengine.cmd_Wheel_GetFilter:string;
var i:integer;
begin
try
i:=Ffilter.Filter;
result:=IntToStr(i);
except
  result:=msgFailed;
end;
end;

function Tf_scriptengine.cmd_Wheel_SetFilter(num:string):string;
var i,n:integer;
begin
try
result:=msgFailed;
val(num,i,n);
if n<>0 then exit;
Ffilter.Filter:=i;
if Ffilter.Filter=i then result:=msgOK;
wait(2);
except
  result:=msgFailed;
end;
end;

function Tf_scriptengine.cmd_Wheel_GetFiltersName(var fl:TStringList):string;
begin
try
result:=msgFailed;
fl.Clear;
fl.Assign(Ffilter.FilterNames);
result:=msgOK;
except
  result:=msgFailed;
end;
end;

function Tf_scriptengine.cmd_Wheel_SetFiltersName(fl:TStringList):string;
begin
try
result:=msgFailed;
Ffilter.FilterNames.Assign(fl);
result:=msgOK;
except
  result:=msgFailed;
end;
end;

function Tf_scriptengine.cmd_Ccd_SetTemperature(t:string):string;
var n:integer;
    tt:double;
begin
try
result:=msgFailed;
val(t,tt,n);
if n<>0 then exit;
Camera.Temperature:=tt;
result:=msgOK;
Ccdtemp.Setpoint.Text:=t;
except
  result:=msgFailed;
end;
end;

function Tf_scriptengine.cmd_Preview_SetExposure(exp:string):string;
begin
try
result:=msgFailed;
Preview.ExpTime.Text:=exp;
result:=msgOK;
except
  result:=msgFailed;
end;
end;

function Tf_scriptengine.cmd_Preview_SetBinning(bin:string):string;
begin
try
result:=msgFailed;
Preview.Binning.Text:=bin;
result:=msgOK;
except
  result:=msgFailed;
end;
end;

function Tf_scriptengine.cmd_Preview_Single:string;
begin
try
result:=msgFailed;
if Preview.Running or Preview.Loop then exit;
if Assigned(Preview.onStartExposure) then
  Preview.onStartExposure(Self)
 else
  exit;
Preview.Running:=true;
if Assigned(FonMsg) then FonMsg('Start single preview');
while Preview.Running do
  Application.ProcessMessages;
wait(1);
result:=msgOK;
except
  result:=msgFailed;
end;
end;

function Tf_scriptengine.cmd_Preview_Loop:string;
begin
try
result:=msgFailed;
if Preview.Running then exit;
Preview.Loop:=True;
if Assigned(Preview.onStartExposure) then
  Preview.onStartExposure(Self)
 else
  exit;
if Assigned(FonMsg) then FonMsg('Start preview loop');
wait(1);
result:=msgOK;
except
  result:=msgFailed;
end;
end;

function Tf_scriptengine.cmd_Preview_Stop:string;
begin
try
result:=msgFailed;
if not Preview.Running then exit;
Preview.Stop;
if Assigned(Preview.onAbortExposure) then
  Preview.onAbortExposure(Self);
wait(1);
result:=msgOK;
except
  result:=msgFailed;
end;
end;

function Tf_scriptengine.cmd_Capture_SetExposure(exp:string):string;
begin
try
result:=msgFailed;
Capture.ExpTime.Text:=exp;
result:=msgOK;
except
  result:=msgFailed;
end;
end;

function Tf_scriptengine.cmd_Capture_SetBinning(bin:string):string;
begin
try
result:=msgFailed;
Capture.Binning.Text:=bin;
result:=msgOK;
except
  result:=msgFailed;
end;
end;

function Tf_scriptengine.cmd_Capture_SetObjectName(obj:string):string;
begin
try
result:=msgFailed;
Capture.Fname.Text:=obj;
result:=msgOK;
except
  result:=msgFailed;
end;
end;

function Tf_scriptengine.cmd_Capture_SetCount(num:string):string;
begin
try
result:=msgFailed;
Capture.SeqNum.Text:=num;
result:=msgOK;
except
  result:=msgFailed;
end;
end;

function Tf_scriptengine.cmd_Capture_SetFrameType(typ:string):string;
begin
try
result:=msgFailed;
typ:=UpperCase(typ);
if typ='LIGHT' then Capture.FrameType.ItemIndex:=ord(LIGHT)
else if typ='BIAS' then Capture.FrameType.ItemIndex:=ord(BIAS)
else if typ='DARK' then Capture.FrameType.ItemIndex:=ord(DARK)
else if typ='FLAT' then Capture.FrameType.ItemIndex:=ord(FLAT)
else exit;
result:=msgOK;
except
  result:=msgFailed;
end;
end;

function Tf_scriptengine.cmd_Capture_SetDither(num:string):string;
var i,n: integer;
begin
try
result:=msgFailed;
val(num,i,n);
if n<>0 then exit;
Capture.CheckBoxDither.Checked:=(i>0);
if i>0 then Capture.DitherCount.Text:=num else Capture.DitherCount.Text:='1';
result:=msgOK;
except
  result:=msgFailed;
end;
end;

function Tf_scriptengine.cmd_Capture_Start:string;
begin
try
result:=msgFailed;
if Capture.Running then exit;
if Assigned(Capture.onStartExposure) then
  Capture.onStartExposure(Self)
 else
  exit;
wait(1);
result:=msgOK;
except
  result:=msgFailed;
end;
end;

function Tf_scriptengine.cmd_Capture_Stop:string;
begin
try
result:=msgFailed;
if not Capture.Running then exit;
Capture.Stop;
if Assigned(Capture.onAbortExposure) then
  Capture.onAbortExposure(Self);
wait(1);
result:=msgOK;
except
  result:=msgFailed;
end;
end;

function Tf_scriptengine.cmd_AstrometrySolve:string;
begin
try
result:=msgFailed;
if Astrometry.Busy then exit;
Astrometry.SolveCurrentImage(true);
if Astrometry.LastResult then begin
 wait(1);
 result:=msgOK;
end;
except
  result:=msgFailed;
end;
end;

function Tf_scriptengine.cmd_AstrometrySync:string;
begin
try
result:=msgFailed;
if Astrometry.Busy then exit;
Astrometry.SyncCurrentImage(true);
if Astrometry.LastResult then begin
 wait(1);
 result:=msgOK;
end;
except
  result:=msgFailed;
end;
end;

function Tf_scriptengine.cmd_PlanetariumConnect:string;
var i: integer;
begin
try
result:=msgFailed;
i:=config.GetValue('/Planetarium/Software',0);
case TPlanetariumType(i) of
  CDC:  planetarium.Connect(config.GetValue('/Planetarium/CdChostname','localhost'),
                   config.GetValue('/Planetarium/CdCport',''));
  SAMP: planetarium.Connect('');
end;
wait(1);
result:=msgOK;
except
  result:=msgFailed;
end;
end;

function Tf_scriptengine.cmd_PlanetariumShowImage:string;
begin
try
result:=msgFailed;
Astrometry.SolveCurrentImage(true);
if astrometry.LastResult and planetarium.Connected then begin
  planetarium.ShowImage(slash(TmpDir)+'ccdcielsolved.fits');
end;
wait(1);
result:=msgOK;
except
  result:=msgFailed;
end;
end;

function Tf_scriptengine.cmd_SequenceStart(seq:string):string;
begin
  if Assigned(FonStartSequence) then FonStartSequence(seq);
  result:=msgOK;
end;

function Tf_scriptengine.cmd_ProgramShutdown:string;
begin
  ConfirmClose:=false;
  ShutdownTimer.Enabled:=true;
  result:=msgOK;
end;

procedure Tf_scriptengine.ShutdownTimerTimer(Sender: TObject);
begin
 ShutdownTimer.Enabled:=false;
 Application.MainForm.Close;
end;

end.
