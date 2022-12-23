{****************************************************************}
{************** CNC G-Code Highlighter For SynEdit **************}
{*********************Create Date: 2020.06.01********************}
{****************************************************************}
//Author: Frank.Wu
//Version: 2.1
//E-mail: 6503597@qq.com
//GitHub: https://github.com/frankwu-delphi/CNC-Gcode-Highlighter
//SynEdit: https://github.com/SynEdit/SynEdit

// This version
// Author: DonAlfredo


unit SynHighlighterCNC;

{$I SynEdit.inc}

interface

uses
  LCLIntf, LCLType,
  SynEditHighlighter, SynEditTypes,// SynEditStrConst,
  Graphics, SysUtils, Classes;

type
  TtkTokenKind = (
  tkNone,
  tkNull,        //Null text

  tkReserved,    //Reserved text
  tkComment,     //Comment with( )
  tkNormal,      //Normal text
  tkText,        //String text
  tkParam,       //Parameter
  tkNumber,      //Number text
  tkSpace,       //Space
  tkEqual,       //Equal symbol
  tkAbstract,    //Abstract symbol

  tkAcode,       //A axis of machine
  tkBcode,       //B axis of machine
  tkCcode,       //C axis of machine
  tkDcode,       //Tool radius compensation number
  tkEcode,       //Used for the filament position 3D printing
  tkFcode,       //Feed rate
  tkGcode,       //General function
  tkHcode,       //Tool length offset index
  tkIcode,       //X offset for arcs and G87 canned cycles
  tkJcode,       //Y offset for arcs and G87 canned cycles
  tkKcode,       //Z offset for arcs and G87 canned cycles.
  tkLcode,       //generic parameter word for G10, M66 and others
  tkMcode,       //Miscellaneous function
  tkNcode,       //Line number
  tkOcode,       //provide for flow control in NC programs
  tkPcode,       //Dwell time in canned cycles and with G4.
  tkQcode,       //Feed increment in G73, G83 canned cycles
  tkRcode,       //Arc radius or canned cycle plane
  tkScode,       //Spindle speed
  tkTcode,       //Tool selection
  tkUcode,       //U axis of machine
  tkVcode,       //V axis of machine
  tkWcode,       //W axis of machine
  tkXcode,       //X axis of machine
  tkYcode,       //Y axis of machine
  tkZcode,       //Z axis of machine

  tkFunction,    //Functions
  tkIdentifier   //ID
  );

  TRangeState = (rsNormal, rsComment);

  TProcTableProc = procedure of object;

  PIdentFuncTableFunc = ^TIdentFuncTableFunc;
  TIdentFuncTableFunc = function (Index: Integer): TtkTokenKind of object;

type
  TSynCNCSyn = class(TSynCustomHighLighter)
  private
    FRange              : TRangeState;
    FTokenID            : TtkTokenKind;

    fLineStr            : string;
    FLine               : PChar;
    fCasedLineStr       : string;
    fCasedLine          : PChar;

    Run                 : Integer;
    fToIdent            : PChar;
    FLineLen            : Integer;
    FCaseSensitive      : boolean;
    fTokenPos           : integer;

    FIdentFuncTable: array[0..78] of TIdentFuncTableFunc;
    FIdentifierAttri: TSynHighlighterAttributes;
    FKeyAttri: TSynHighlighterAttributes;

    FCommentAttri: TSynHighlighterAttributes;
    FStringAttri: TSynHighlighterAttributes;
    FReservedAttri: TSynHighlighterAttributes;
    FNormalAttri: TSynHighlighterAttributes;
    FEqualAttri: TSynHighlighterAttributes;
    FParameterAttri: TSynHighlighterAttributes;
    FNumberAttri: TSynHighlighterAttributes;
    FSpaceAttri: TSynHighlighterAttributes;
    FSymbolAttri: TSynHighlighterAttributes;

    FAcodeAttri: TSynHighlighterAttributes;
    FBcodeAttri: TSynHighlighterAttributes;
    FCcodeAttri: TSynHighlighterAttributes;
    FDcodeAttri: TSynHighlighterAttributes;
    FEcodeAttri: TSynHighlighterAttributes;
    FFcodeAttri: TSynHighlighterAttributes;
    FGcodeAttri: TSynHighlighterAttributes;
    FHcodeAttri: TSynHighlighterAttributes;
    FIcodeAttri: TSynHighlighterAttributes;
    FJcodeAttri: TSynHighlighterAttributes;
    FKcodeAttri: TSynHighlighterAttributes;
    FLcodeAttri: TSynHighlighterAttributes;
    FMcodeAttri: TSynHighlighterAttributes;
    FNcodeAttri: TSynHighlighterAttributes;
    FOcodeAttri: TSynHighlighterAttributes;
    FPcodeAttri: TSynHighlighterAttributes;
    FQcodeAttri: TSynHighlighterAttributes;
    FRcodeAttri: TSynHighlighterAttributes;
    FScodeAttri: TSynHighlighterAttributes;
    FTcodeAttri: TSynHighlighterAttributes;
    FUcodeAttri: TSynHighlighterAttributes;
    FVcodeAttri: TSynHighlighterAttributes;
    FWcodeAttri: TSynHighlighterAttributes;
    FXcodeAttri: TSynHighlighterAttributes;
    FYcodeAttri: TSynHighlighterAttributes;
    FZcodeAttri: TSynHighlighterAttributes;

    procedure NormalProc;
    procedure NullProc;
    procedure SpaceProc;
    procedure CRProc;
    procedure LFProc;
    procedure CommentOpenProc;
    procedure CommentProc;
    procedure SymbolProc;
    procedure NumberProc;
    procedure ParameterProc;

    procedure ACodeProc;
    procedure BCodeProc;
    procedure CCodeProc;
    procedure DCodeProc;
    procedure ECodeProc;
    procedure FCodeProc;
    procedure GCodeProc;
    procedure HCodeProc;
    procedure ICodeProc;
    procedure JCodeProc;
    procedure KCodeProc;
    procedure LCodeProc;
    procedure MCodeProc;
    procedure NCodeProc;
    procedure OCodeProc;
    procedure PCodeProc;
    procedure QCodeProc;
    procedure RCodeProc;
    procedure SCodeProc;
    procedure TCodeProc;
    procedure UCodeProc;
    procedure VCodeProc;
    procedure WCodeProc;
    procedure XCodeProc;
    procedure YCodeProc;
    procedure ZCodeProc;

    function HashKey(Str: PChar): Cardinal;
    function IsCurrentToken(const Token: String): Boolean;
    function FuncAbs(Index: Integer): TtkTokenKind;
    function FuncAcos(Index: Integer): TtkTokenKind;
    function FuncAnd(Index: Integer): TtkTokenKind;
    function FuncAr(Index: Integer): TtkTokenKind;
    function FuncAsin(Index: Integer): TtkTokenKind;
    function FuncAtan(Index: Integer): TtkTokenKind;
    function FuncBcd(Index: Integer): TtkTokenKind;
    function FuncBin(Index: Integer): TtkTokenKind;
    function FuncCos(Index: Integer): TtkTokenKind;
    function FuncDo(Index: Integer): TtkTokenKind;
    function FuncElse(Index: Integer): TtkTokenKind;
    function FuncEnd(Index: Integer): TtkTokenKind;
    function FuncEndif(Index: Integer): TtkTokenKind;
    function FuncEndw(Index: Integer): TtkTokenKind;
    function FuncEq(Index: Integer): TtkTokenKind;
    function FuncExp(Index: Integer): TtkTokenKind;
    function FuncFalse(Index: Integer): TtkTokenKind;
    function FuncFix(Index: Integer): TtkTokenKind;
    function FuncFup(Index: Integer): TtkTokenKind;
    function FuncGe(Index: Integer): TtkTokenKind;
    function FuncGoto(Index: Integer): TtkTokenKind;
    function FuncGt(Index: Integer): TtkTokenKind;
    function FuncIf(Index: Integer): TtkTokenKind;
    function FuncInt(Index: Integer): TtkTokenKind;
    function FuncLe(Index: Integer): TtkTokenKind;
    function FuncLn(Index: Integer): TtkTokenKind;
    function FuncLt(Index: Integer): TtkTokenKind;
    function FuncNe(Index: Integer): TtkTokenKind;
    function FuncNext(Index: Integer): TtkTokenKind;
    function FuncNot(Index: Integer): TtkTokenKind;
    function FuncOr(Index: Integer): TtkTokenKind;
    function FuncPi(Index: Integer): TtkTokenKind;
    function FuncRepeart(Index: Integer): TtkTokenKind;
    function FuncRound(Index: Integer): TtkTokenKind;
    function FuncSign(Index: Integer): TtkTokenKind;
    function FuncSin(Index: Integer): TtkTokenKind;
    function FuncSqrt(Index: Integer): TtkTokenKind;
    function FuncTan(Index: Integer): TtkTokenKind;
    function FuncThen(Index: Integer): TtkTokenKind;
    function FuncTrue(Index: Integer): TtkTokenKind;
    function FuncWhile(Index: Integer): TtkTokenKind;
    function FuncXor(Index: Integer): TtkTokenKind;

    function IsIdentChar(AChar: Char): Boolean;
    procedure IdentProc;
    function AltFunc(Index: Integer): TtkTokenKind;
    procedure InitIdent;
    function IdentKind(MayBe: PChar): TtkTokenKind;
    function IsLineEnd(aRun: Integer): Boolean;

  protected
    function GetIdentChars: TSynIdentChars; override;
    function GetSampleSource: String; override;
    function IsFilterStored: Boolean; override;
  public
    constructor Create(AOwner: TComponent); override;
    class function GetLanguageName: string; override;
    function GetRange: Pointer; override;
    procedure ResetRange; override;
    procedure SetRange(Value: Pointer); override;
    function GetDefaultAttribute(Index: Integer): TSynHighlighterAttributes; override;
    function GetEol: Boolean; override;
    function GetTokenID: TtkTokenKind;
    function GetKeywordIdentifiers: TStringList; virtual;
    function GetTokenPos: Integer;override;
    function GetToken: string;override;
    procedure GetTokenEx(out TokenStart: PChar; out TokenLength: integer); override;
    function GetTokenAttribute: TSynHighlighterAttributes; override;
    function GetTokenKind: Integer; override;
    procedure Next; override;
    procedure SetLine(const NewValue: string; LineNumber: Integer); override;
    function GetHighlighterAttriAtRowColEx(XY: TPoint;
      out Token: string; out TokenType, Start: Integer;
      out Attri: TSynHighlighterAttributes): boolean;
  published
   property CommentAttri: TSynHighlighterAttributes read FCommentAttri write FCommentAttri;
   property StringAttri: TSynHighlighterAttributes read FStringAttri write FStringAttri;
   property ReservedAttri: TSynHighlighterAttributes read FReservedAttri write FReservedAttri;
   property NormalAttri: TSynHighlighterAttributes read FNormalAttri write FNormalAttri;
   property EqualAttri: TSynHighlighterAttributes read FEqualAttri write FEqualAttri;
   property ParameterAttri: TSynHighlighterAttributes read FParameterAttri write FParameterAttri;
   property NumberAttri: TSynHighlighterAttributes read FNumberAttri write FNumberAttri;
   property SpaceAttri: TSynHighlighterAttributes read FSpaceAttri write FSpaceAttri;
   property SymbolAttri: TSynHighlighterAttributes read FSymbolAttri write FSymbolAttri;

   property IdentifierAttri: TSynHighlighterAttributes read fIdentifierAttri write fIdentifierAttri;
   property KeyAttri: TSynHighlighterAttributes read fKeyAttri write fKeyAttri;

   property AcodeAttri: TSynHighlighterAttributes read FAcodeAttri write FAcodeAttri;
   property BcodeAttri: TSynHighlighterAttributes read FBcodeAttri write FBcodeAttri;
   property CcodeAttri: TSynHighlighterAttributes read FCcodeAttri write FCcodeAttri;
   property DcodeAttri: TSynHighlighterAttributes read FDcodeAttri write FDcodeAttri;
   property EcodeAttri: TSynHighlighterAttributes read FEcodeAttri write FEcodeAttri;
   property FcodeAttri: TSynHighlighterAttributes read FFcodeAttri write FFcodeAttri;
   property GcodeAttri: TSynHighlighterAttributes read FGcodeAttri write FGcodeAttri;
   property HcodeAttri: TSynHighlighterAttributes read FHcodeAttri write FHcodeAttri;
   property IcodeAttri: TSynHighlighterAttributes read FIcodeAttri write FIcodeAttri;
   property JcodeAttri: TSynHighlighterAttributes read FJcodeAttri write FJcodeAttri;
   property KcodeAttri: TSynHighlighterAttributes read FKcodeAttri write FKcodeAttri;
   property LcodeAttri: TSynHighlighterAttributes read FLcodeAttri write FLcodeAttri;
   property McodeAttri: TSynHighlighterAttributes read FMcodeAttri write FMcodeAttri;
   property NcodeAttri: TSynHighlighterAttributes read FNcodeAttri write FNcodeAttri;
   property OcodeAttri: TSynHighlighterAttributes read FOcodeAttri write FOcodeAttri;
   property PcodeAttri: TSynHighlighterAttributes read FPcodeAttri write FPcodeAttri;
   property QcodeAttri: TSynHighlighterAttributes read FQcodeAttri write FQcodeAttri;
   property RcodeAttri: TSynHighlighterAttributes read FRcodeAttri write FRcodeAttri;
   property ScodeAttri: TSynHighlighterAttributes read FScodeAttri write FScodeAttri;
   property TcodeAttri: TSynHighlighterAttributes read FTcodeAttri write FTcodeAttri;
   property UcodeAttri: TSynHighlighterAttributes read FUcodeAttri write FUcodeAttri;
   property VcodeAttri: TSynHighlighterAttributes read FVcodeAttri write FVcodeAttri;
   property WcodeAttri: TSynHighlighterAttributes read FWcodeAttri write FWcodeAttri;
   property XcodeAttri: TSynHighlighterAttributes read FXcodeAttri write FXcodeAttri;
   property YcodeAttri: TSynHighlighterAttributes read FYcodeAttri write FYcodeAttri;
   property ZcodeAttri: TSynHighlighterAttributes read FZcodeAttri write FZcodeAttri;

  end;

implementation

uses
  SynEdit, SynEditStrConstExtra;

resourcestring
  SYNS_FilterCNC = 'CNC Files (*.nc)|*.nc';
  SYNS_LangCNC = 'CNC';
  SYNS_FriendlyLangCNC = 'CNC G-Code';

const
  // as this language is case-insensitive keywords *must* be in lowercase
  KeyWords: array[0..41] of AnsiString = (
    'abs', 'acos', 'and', 'ar', 'asin', 'atan', 'bcd', 'bin', 'cos', 'do',
    'else', 'end', 'endif', 'endw', 'eq', 'exp', 'false', 'fix', 'fup', 'ge',
    'goto', 'gt', 'if', 'int', 'le', 'ln', 'lt', 'ne', 'next', 'not', 'or',
    'pi', 'repeart', 'round', 'sign', 'sin', 'sqrt', 'tan', 'then', 'true',
    'while', 'xor'
  );

  KeyIndices: array[0..78] of Integer = (
    4, 19, -1, -1, 26, 10, -1, 0, -1, -1, 27, -1, -1, -1, 23, -1, 14, -1, -1,
    -1, 6, -1, -1, 13, -1, -1, -1, -1, -1, 8, 24, -1, 1, 15, -1, -1, -1, 40, -1,
    -1, 9, 31, -1, -1, 28, 17, 25, 38, 7, 3, -1, 34, 41, 22, 21, 32, -1, -1, 33,
    11, 18, -1, 36, -1, -1, 12, -1, 30, 29, -1, 20, 2, -1, 16, 37, -1, 35, 5, 39
  );

var
  GlobalKeywords: TStringList;

function TSynCNCSyn.IsLineEnd(aRun: Integer): Boolean;
begin
  Result := (aRun >= FLineLen) or (FLine[aRun] = #10) or (FLine[aRun] = #13);
end;

procedure TSynCNCSyn.InitIdent;
var
  i: Integer;
begin
  for i := Low(fIdentFuncTable) to High(fIdentFuncTable) do
    if KeyIndices[i] = -1 then
      fIdentFuncTable[i] := @AltFunc;

  fIdentFuncTable[7] := @FuncAbs;
  fIdentFuncTable[32] := @FuncAcos;
  fIdentFuncTable[71] := @FuncAnd;
  fIdentFuncTable[49] := @FuncAr;
  fIdentFuncTable[0] := @FuncAsin;
  fIdentFuncTable[77] := @FuncAtan;
  fIdentFuncTable[20] := @FuncBcd;
  fIdentFuncTable[48] := @FuncBin;
  fIdentFuncTable[29] := @FuncCos;
  fIdentFuncTable[40] := @FuncDo;
  fIdentFuncTable[5] := @FuncElse;
  fIdentFuncTable[59] := @FuncEnd;
  fIdentFuncTable[65] := @FuncEndif;
  fIdentFuncTable[23] := @FuncEndw;
  fIdentFuncTable[16] := @FuncEq;
  fIdentFuncTable[33] := @FuncExp;
  fIdentFuncTable[73] := @FuncFalse;
  fIdentFuncTable[45] := @FuncFix;
  fIdentFuncTable[60] := @FuncFup;
  fIdentFuncTable[1] := @FuncGe;
  fIdentFuncTable[70] := @FuncGoto;
  fIdentFuncTable[54] := @FuncGt;
  fIdentFuncTable[53] := @FuncIf;
  fIdentFuncTable[14] := @FuncInt;
  fIdentFuncTable[30] := @FuncLe;
  fIdentFuncTable[46] := @FuncLn;
  fIdentFuncTable[4] := @FuncLt;
  fIdentFuncTable[10] := @FuncNe;
  fIdentFuncTable[44] := @FuncNext;
  fIdentFuncTable[68] := @FuncNot;
  fIdentFuncTable[67] := @FuncOr;
  fIdentFuncTable[41] := @FuncPi;
  fIdentFuncTable[55] := @FuncRepeart;
  fIdentFuncTable[58] := @FuncRound;
  fIdentFuncTable[51] := @FuncSign;
  fIdentFuncTable[76] := @FuncSin;
  fIdentFuncTable[62] := @FuncSqrt;
  fIdentFuncTable[74] := @FuncTan;
  fIdentFuncTable[47] := @FuncThen;
  fIdentFuncTable[78] := @FuncTrue;
  fIdentFuncTable[37] := @FuncWhile;
  fIdentFuncTable[52] := @FuncXor;
end;

{$Q-}
function TSynCNCSyn.HashKey(Str: PChar): Cardinal;
begin
  Result := 0;
  while IsIdentChar(Str^) do
  begin
    Result := Result * 577 + Ord(Str^) * 151;
    inc(Str);
  end;
  Result := Result mod 79;
  FLineLen := Str - fToIdent;
end;
{$Q+}

function TSynCNCSyn.IsCurrentToken(const Token: String): Boolean;
var
  I: Integer;
  Temp: PChar;
begin
  Temp := FToIdent;
  if Length(Token) = FLineLen then
  begin
    Result := True;
    for i := 1 to FLineLen do
    begin
      if Temp^ <> Token[i] then
      begin
        Result := False;
        Break;
      end;
      Inc(Temp);
    end;
  end
  else
    Result := False;
end;

function TSynCNCSyn.FuncAbs(Index: Integer): TtkTokenKind;
begin
  if IsCurrentToken(KeyWords[Index]) then
    Result := tkFunction
  else
    Result := tkIdentifier;
end;

function TSynCNCSyn.FuncAcos(Index: Integer): TtkTokenKind;
begin
  if IsCurrentToken(KeyWords[Index]) then
    Result := tkFunction
  else
    Result := tkIdentifier;
end;

function TSynCNCSyn.FuncAnd(Index: Integer): TtkTokenKind;
begin
  if IsCurrentToken(KeyWords[Index]) then
    Result := tkFunction
  else
    Result := tkIdentifier;
end;

function TSynCNCSyn.FuncAr(Index: Integer): TtkTokenKind;
begin
  if IsCurrentToken(KeyWords[Index]) then
    Result := tkFunction
  else
    Result := tkIdentifier;
end;

function TSynCNCSyn.FuncAsin(Index: Integer): TtkTokenKind;
begin
  if IsCurrentToken(KeyWords[Index]) then
    Result := tkFunction
  else
    Result := tkIdentifier;
end;

function TSynCNCSyn.FuncAtan(Index: Integer): TtkTokenKind;
begin
  if IsCurrentToken(KeyWords[Index]) then
    Result := tkFunction
  else
    Result := tkIdentifier;
end;

function TSynCNCSyn.FuncBcd(Index: Integer): TtkTokenKind;
begin
  if IsCurrentToken(KeyWords[Index]) then
    Result := tkFunction
  else
    Result := tkIdentifier;
end;

function TSynCNCSyn.FuncBin(Index: Integer): TtkTokenKind;
begin
  if IsCurrentToken(KeyWords[Index]) then
    Result := tkFunction
  else
    Result := tkIdentifier;
end;

function TSynCNCSyn.FuncCos(Index: Integer): TtkTokenKind;
begin
  if IsCurrentToken(KeyWords[Index]) then
    Result := tkFunction
  else
    Result := tkIdentifier;
end;

function TSynCNCSyn.FuncDo(Index: Integer): TtkTokenKind;
begin
  if IsCurrentToken(KeyWords[Index]) then
    Result := tkFunction
  else
    Result := tkIdentifier;
end;

function TSynCNCSyn.FuncElse(Index: Integer): TtkTokenKind;
begin
  if IsCurrentToken(KeyWords[Index]) then
    Result := tkFunction
  else
    Result := tkIdentifier;
end;

function TSynCNCSyn.FuncEnd(Index: Integer): TtkTokenKind;
begin
  if IsCurrentToken(KeyWords[Index]) then
    Result := tkFunction
  else
    Result := tkIdentifier;
end;

function TSynCNCSyn.FuncEndif(Index: Integer): TtkTokenKind;
begin
  if IsCurrentToken(KeyWords[Index]) then
    Result := tkFunction
  else
    Result := tkIdentifier;
end;

function TSynCNCSyn.FuncEndw(Index: Integer): TtkTokenKind;
begin
  if IsCurrentToken(KeyWords[Index]) then
    Result := tkFunction
  else
    Result := tkIdentifier;
end;

function TSynCNCSyn.FuncEq(Index: Integer): TtkTokenKind;
begin
  if IsCurrentToken(KeyWords[Index]) then
    Result := tkFunction
  else
    Result := tkIdentifier;
end;

function TSynCNCSyn.FuncExp(Index: Integer): TtkTokenKind;
begin
  if IsCurrentToken(KeyWords[Index]) then
    Result := tkFunction
  else
    Result := tkIdentifier;
end;

function TSynCNCSyn.FuncFalse(Index: Integer): TtkTokenKind;
begin
  if IsCurrentToken(KeyWords[Index]) then
    Result := tkFunction
  else
    Result := tkIdentifier;
end;

function TSynCNCSyn.FuncFix(Index: Integer): TtkTokenKind;
begin
  if IsCurrentToken(KeyWords[Index]) then
    Result := tkFunction
  else
    Result := tkIdentifier;
end;

function TSynCNCSyn.FuncFup(Index: Integer): TtkTokenKind;
begin
  if IsCurrentToken(KeyWords[Index]) then
    Result := tkFunction
  else
    Result := tkIdentifier;
end;

function TSynCNCSyn.FuncGe(Index: Integer): TtkTokenKind;
begin
  if IsCurrentToken(KeyWords[Index]) then
    Result := tkFunction
  else
    Result := tkIdentifier;
end;

function TSynCNCSyn.FuncGoto(Index: Integer): TtkTokenKind;
begin
  if IsCurrentToken(KeyWords[Index]) then
    Result := tkFunction
  else
    Result := tkIdentifier;
end;

function TSynCNCSyn.FuncGt(Index: Integer): TtkTokenKind;
begin
  if IsCurrentToken(KeyWords[Index]) then
    Result := tkFunction
  else
    Result := tkIdentifier;
end;

function TSynCNCSyn.FuncIf(Index: Integer): TtkTokenKind;
begin
  if IsCurrentToken(KeyWords[Index]) then
    Result := tkFunction
  else
    Result := tkIdentifier;
end;

function TSynCNCSyn.FuncInt(Index: Integer): TtkTokenKind;
begin
  if IsCurrentToken(KeyWords[Index]) then
    Result := tkFunction
  else
    Result := tkIdentifier;
end;

function TSynCNCSyn.FuncLe(Index: Integer): TtkTokenKind;
begin
  if IsCurrentToken(KeyWords[Index]) then
    Result := tkFunction
  else
    Result := tkIdentifier;
end;

function TSynCNCSyn.FuncLn(Index: Integer): TtkTokenKind;
begin
  if IsCurrentToken(KeyWords[Index]) then
    Result := tkFunction
  else
    Result := tkIdentifier;
end;

function TSynCNCSyn.FuncLt(Index: Integer): TtkTokenKind;
begin
  if IsCurrentToken(KeyWords[Index]) then
    Result := tkFunction
  else
    Result := tkIdentifier;
end;

function TSynCNCSyn.FuncNe(Index: Integer): TtkTokenKind;
begin
  if IsCurrentToken(KeyWords[Index]) then
    Result := tkFunction
  else
    Result := tkIdentifier;
end;

function TSynCNCSyn.FuncNext(Index: Integer): TtkTokenKind;
begin
  if IsCurrentToken(KeyWords[Index]) then
    Result := tkFunction
  else
    Result := tkIdentifier;
end;

function TSynCNCSyn.FuncNot(Index: Integer): TtkTokenKind;
begin
  if IsCurrentToken(KeyWords[Index]) then
    Result := tkFunction
  else
    Result := tkIdentifier;
end;

function TSynCNCSyn.FuncOr(Index: Integer): TtkTokenKind;
begin
  if IsCurrentToken(KeyWords[Index]) then
    Result := tkFunction
  else
    Result := tkIdentifier;
end;

function TSynCNCSyn.FuncPi(Index: Integer): TtkTokenKind;
begin
  if IsCurrentToken(KeyWords[Index]) then
    Result := tkFunction
  else
    Result := tkIdentifier;
end;

function TSynCNCSyn.FuncRepeart(Index: Integer): TtkTokenKind;
begin
  if IsCurrentToken(KeyWords[Index]) then
    Result := tkFunction
  else
    Result := tkIdentifier;
end;

function TSynCNCSyn.FuncRound(Index: Integer): TtkTokenKind;
begin
  if IsCurrentToken(KeyWords[Index]) then
    Result := tkFunction
  else
    Result := tkIdentifier;
end;

function TSynCNCSyn.FuncSign(Index: Integer): TtkTokenKind;
begin
  if IsCurrentToken(KeyWords[Index]) then
    Result := tkFunction
  else
    Result := tkIdentifier;
end;

function TSynCNCSyn.FuncSin(Index: Integer): TtkTokenKind;
begin
  if IsCurrentToken(KeyWords[Index]) then
    Result := tkFunction
  else
    Result := tkIdentifier;
end;

function TSynCNCSyn.FuncSqrt(Index: Integer): TtkTokenKind;
begin
  if IsCurrentToken(KeyWords[Index]) then
    Result := tkFunction
  else
    Result := tkIdentifier;
end;

function TSynCNCSyn.FuncTan(Index: Integer): TtkTokenKind;
begin
  if IsCurrentToken(KeyWords[Index]) then
    Result := tkFunction
  else
    Result := tkIdentifier;
end;

function TSynCNCSyn.FuncThen(Index: Integer): TtkTokenKind;
begin
  if IsCurrentToken(KeyWords[Index]) then
    Result := tkFunction
  else
    Result := tkIdentifier;
end;

function TSynCNCSyn.FuncTrue(Index: Integer): TtkTokenKind;
begin
  if IsCurrentToken(KeyWords[Index]) then
    Result := tkFunction
  else
    Result := tkIdentifier;
end;

function TSynCNCSyn.FuncWhile(Index: Integer): TtkTokenKind;
begin
  if IsCurrentToken(KeyWords[Index]) then
    Result := tkFunction
  else
    Result := tkIdentifier;
end;

function TSynCNCSyn.FuncXor(Index: Integer): TtkTokenKind;
begin
  if IsCurrentToken(KeyWords[Index]) then
    Result := tkFunction
  else
    Result := tkIdentifier;
end;

function TSynCNCSyn.AltFunc(Index: Integer): TtkTokenKind;
begin
  Result := tkIdentifier;
end;

function TSynCNCSyn.IdentKind(MayBe: PChar): TtkTokenKind;
var
  Key: Cardinal;
begin
  fToIdent := MayBe;
  Key := HashKey(MayBe);
  if Key <= High(fIdentFuncTable) then
    Result := fIdentFuncTable[Key](KeyIndices[Key])
  else
    Result := tkIdentifier;
end;

procedure TSynCNCSyn.SpaceProc;
begin
  inc(Run);
  FTokenID := tkSpace;
  while (FLine[Run] <= #32) and not IsLineEnd(Run) do
    inc(Run);
end;

procedure TSynCNCSyn.NullProc;
begin
  FTokenID := tkNull;
  inc(Run);
end;

procedure TSynCNCSyn.CRProc;
begin
  FTokenID := tkSpace;
  inc(Run);
  if FLine[Run] = #10 then
    inc(Run);
end;

procedure TSynCNCSyn.LFProc;
begin
  FTokenID := tkSpace;
  inc(Run);
end;

procedure TSynCNCSyn.CommentOpenProc;
begin
  inc(Run);
  FRange := rsComment;
  FTokenID := tkComment;
end;

procedure TSynCNCSyn.CommentProc;
begin
  case FLine[Run] of
    #0: NullProc;
    #10: LFProc;
    #13: CRProc;
  else
    begin
      FTokenID := tkComment;
      repeat
        if (FLine[Run] = ')') then
        begin
          inc(Run, 1);
          FRange := rsNormal;
          Break;
        end;
        if not IsLineEnd(Run) then
          inc(Run);
      until IsLineEnd(Run);
    end;
  end;
end;

procedure TSynCNCSyn.SymbolProc;
begin
  FTokenID := tkNormal;
  case FLine[Run] of
    '%','[',']','@','^','*':
      begin
        FTokenID := tkAbstract;
        inc(Run, 1);
      end;
     ';':
     begin
       FTokenID := tkComment;
       repeat
          inc(Run, 1);
       until IsLineEnd(Run);
     end;
     '=':
     begin
       FTokenID := tkEqual;
       inc(Run, 1);
     end
  else
    SpaceProc;
  end;
end;

procedure TSynCNCSyn.NumberProc;
  function ExpectDigit: Boolean;
  begin
    Result := CharInSet(FLine[Run], ['0' .. '9']);
    while CharInSet(FLine[Run], ['0' .. '9']) do
      inc(Run);
  end;
var
  DotFound:boolean;

begin
  FTokenID := tkNumber;

  if FLine[Run] = '-' then
    inc(Run);

  // check for dot
  DotFound:=(FLine[Run] = '.');
  if DotFound then
    inc(Run);

  // at least any digit must appear here
  if not ExpectDigit then
  begin
    FTokenID := tkNormal;
    while (FLine[Run] <> #32) and not IsLineEnd(Run) do
      inc(Run);
    Exit;
  end;

  // check again for dot
  if (NOT DotFound) then
  begin
    DotFound:=(FLine[Run] = '.');
    if DotFound then
    begin
      inc(Run);
      ExpectDigit;
    end;
  end;

  // check for an exponent
//  if CharInSet(FLine[Run], ['e', 'E']) then
//  begin
//    inc(Run);
//
//    // allow +/- here
//    if CharInSet(FLine[Run], ['+', '-']) then
//      inc(Run);
//
//    // at least any digit must appear here
//    if not ExpectDigit then
//    begin
//      FTokenID := tkNormal;
//      while (FLine[Run] <> #32) and not IsLineEnd(Run) do
//        inc(Run);
//      Exit;
//    end;
//  end;
end;

procedure TSynCNCSyn.ParameterProc;
begin
  case FLine[Run] of
    #0: NullProc;
    #10: LFProc;
    #13: CRProc;
  else
    begin
      FTokenID := tkNormal;
      case FLine[Run] of
        '#':
          begin
            if FLine[Run + 1]='<' then
            begin
              if not IsLineEnd(Run) then
                inc(Run);
              // We have a named param: get it !!
              repeat
                if (FLine[Run] = '>') then
                begin
                  FTokenID := tkParam;
                  inc(Run, 1);
                  Break;
                end;
                if not IsLineEnd(Run) then
                  inc(Run);
              until IsLineEnd(Run);
            end
            else
            begin
              // Normal numbered param
              while (FLine[Run + 1] in ['0'..'9']) and not IsLineEnd(Run) do
                inc(Run);
              FTokenID := tkParam;
              inc(Run, 1);
            end;
          end
      end;
    end;
  end;
end;

constructor TSynCNCSyn.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);

  FCaseSensitive := False;

  // comment
  FCommentAttri := TSynHighlighterAttributes.Create(SYNS_AttrComment,
    SYNS_FriendlyAttrComment);
  FCommentAttri.Style := [fsItalic];
  FCommentAttri.Foreground := $00FF8800;
  AddAttribute(FCommentAttri);

  // string
  FStringAttri := TSynHighlighterAttributes.Create(SYNS_AttrString,
    SYNS_FriendlyAttrString);
  FStringAttri.Foreground := clRed;
  AddAttribute(FStringAttri);

  // Normal
  FNormalAttri := TSynHighlighterAttributes.Create(SYNS_AttrAttribute,
    SYNS_FriendlyAttrAttribute);
  FNormalAttri.Foreground := $00CCCCCC;
  AddAttribute(FNormalAttri);

  // reserved words ("%")
  FReservedAttri := TSynHighlighterAttributes.Create(SYNS_AttrReservedWord,
    SYNS_FriendlyAttrReservedWord);
  FReservedAttri.Style := [fsBold];
  FReservedAttri.Foreground := $004A9AFF;
  AddAttribute(FReservedAttri);

  // equal
  FEqualAttri := TSynHighlighterAttributes.Create(SYNS_AttrEqual,
    SYNS_FriendlyAttrEqual);
  FEqualAttri.Foreground := TColor($FFFF00);
  AddAttribute(FEqualAttri);

  // parameters
  FParameterAttri := TSynHighlighterAttributes.Create(SYNS_AttrParameter,
    SYNS_FriendlyAttrParameter);
  FParameterAttri.Foreground := $00AA00FF;
  AddAttribute(FParameterAttri);

  // numbers
  FNumberAttri := TSynHighlighterAttributes.Create(SYNS_AttrNumber,
    SYNS_FriendlyAttrNumber);
  FNumberAttri.Foreground := $000000FF;
  AddAttribute(FNumberAttri);

  // spaces
  FSpaceAttri := TSynHighlighterAttributes.Create(SYNS_AttrSpace,
    SYNS_FriendlyAttrSpace);
  AddAttribute(FSpaceAttri);

  // symbols
  FSymbolAttri := TSynHighlighterAttributes.Create(SYNS_AttrSymbol,
    SYNS_FriendlyAttrSymbol);
  FSymbolAttri.Foreground := clGreen;
  AddAttribute(FSymbolAttri);

  // A-Code
  FAcodeAttri := TSynHighlighterAttributes.Create('CNC A', 'CNC A-Code');
  FAcodeAttri.Foreground := $002D902C;
  AddAttribute(FAcodeAttri);

  // B-Code
  FBcodeAttri := TSynHighlighterAttributes.Create('CNC B', 'CNC B-Code');
  FBcodeAttri.Foreground := $002D902C;
  AddAttribute(FBcodeAttri);

  // C-Code
  FCcodeAttri := TSynHighlighterAttributes.Create('CNC C', 'CNC C-Code');
  FCcodeAttri.Foreground := $002D902C;
  AddAttribute(FCcodeAttri);

  // D-Code
  FDcodeAttri := TSynHighlighterAttributes.Create('CNC D', 'CNC D-Code');
  FDcodeAttri.Foreground := $002D902C;
  AddAttribute(FDcodeAttri);

  // E-Code
  FEcodeAttri := TSynHighlighterAttributes.Create('CNC E', 'CNC E-Code');
  FEcodeAttri.Foreground := $002D902C;
  AddAttribute(FEcodeAttri);

  // F-Code
  FFcodeAttri := TSynHighlighterAttributes.Create('CNC F', 'CNC F-Code');
  FFcodeAttri.Foreground := $00CC9852;
  AddAttribute(FFcodeAttri);

  // G-Code
  FGcodeAttri := TSynHighlighterAttributes.Create('CNC G', 'CNC G-Code');
  FGcodeAttri.Foreground := $0000FF00;
  FReservedAttri.Style := [fsBold];
  AddAttribute(FGcodeAttri);

  // H-Code
  FHcodeAttri := TSynHighlighterAttributes.Create('CNC H', 'CNC H-Code');
  FHcodeAttri.Foreground := $003ACFAE;
  AddAttribute(FHcodeAttri);

  // I-Code
  FIcodeAttri := TSynHighlighterAttributes.Create('CNC I', 'CNC I-Code');
  FIcodeAttri.Foreground := $0093E7FF;
  AddAttribute(FIcodeAttri);

  // J-Code
  FJcodeAttri := TSynHighlighterAttributes.Create('CNC J', 'CNC J-Code');
  FJcodeAttri.Foreground := $0093E7FF;
  AddAttribute(FJcodeAttri);

  // K-Code
  FKcodeAttri := TSynHighlighterAttributes.Create('CNC K', 'CNC K-Code');
  FKcodeAttri.Foreground := $0093E7FF;
  AddAttribute(FKcodeAttri);

  // L-Code
  FLcodeAttri := TSynHighlighterAttributes.Create('CNC L', 'CNC L-Code');
  FLcodeAttri.Foreground := $00C7A78A;
  AddAttribute(FLcodeAttri);

  // M-Code
  FMcodeAttri := TSynHighlighterAttributes.Create('CNC M', 'CNC M-Code');
  FMcodeAttri.Foreground := $00FDDC57;
  AddAttribute(FMcodeAttri);

  // N-Code
  FNcodeAttri := TSynHighlighterAttributes.Create('CNC N', 'CNC N-Code');
  FNcodeAttri.Foreground := $009F907F;
  FNcodeAttri.Style := [fsItalic];
  AddAttribute(FNcodeAttri);

  // O-Code
  FOcodeAttri := TSynHighlighterAttributes.Create('CNC O', 'CNC O-Code');
  FOcodeAttri.Foreground := $0000AFFF;
  AddAttribute(FOcodeAttri);

  // P-Code
  FPcodeAttri := TSynHighlighterAttributes.Create('CNC P', 'CNC P-Code');
  FPcodeAttri.Foreground := $00CCCCCC;
  AddAttribute(FPcodeAttri);

  // Q-Code
  FQcodeAttri := TSynHighlighterAttributes.Create('CNC Q', 'CNC Q-Code');
  FQcodeAttri.Foreground := $00CCCCCC;
  AddAttribute(FQcodeAttri);

  // R-Code
  FRcodeAttri := TSynHighlighterAttributes.Create('CNC R', 'CNC R-Code');
  FRcodeAttri.Foreground := $00FFFFFF;
  AddAttribute(FRcodeAttri);

  // S-Code
  FScodeAttri := TSynHighlighterAttributes.Create('CNC S', 'CNC S-Code');
  FScodeAttri.Foreground := $00CCCCCC;
  AddAttribute(FScodeAttri);

  // T-Code
  FTcodeAttri := TSynHighlighterAttributes.Create('CNC T', 'CNC T-Code');
  FTcodeAttri.Foreground := $00FFFFFF;
  AddAttribute(FTcodeAttri);

  // U-Code
  FUcodeAttri := TSynHighlighterAttributes.Create('CNC U', 'CNC U-Code');
  FUcodeAttri.Foreground := $00FFAFC1;
  AddAttribute(FUcodeAttri);

  // V-Code
  FVcodeAttri := TSynHighlighterAttributes.Create('CNC V', 'CNC V-Code');
  FVcodeAttri.Foreground := $00FFAFC1;
  AddAttribute(FVcodeAttri);

  // W-Code
  FWcodeAttri := TSynHighlighterAttributes.Create('CNC W', 'CNC W-Code');
  FWcodeAttri.Foreground := $00FFAFC1;
  AddAttribute(FWcodeAttri);

  // X-Code
  FXcodeAttri := TSynHighlighterAttributes.Create('CNC X', 'CNC X-Code');
  FXcodeAttri.Foreground := $00FFAFC1;
  FXcodeAttri.Style := [fsBold];
  AddAttribute(FXcodeAttri);

  // Y-Code
  FYcodeAttri := TSynHighlighterAttributes.Create('CNC Y', 'CNC Y-Code');
  FYcodeAttri.Foreground := $00FFAFC1;
  FYcodeAttri.Style := [fsBold];
  AddAttribute(FYcodeAttri);

  // Z-Code
  FZcodeAttri := TSynHighlighterAttributes.Create('CNC Z', 'CNC Z-Code');
  FZcodeAttri.Foreground := $00FFAFC1;
  FZcodeAttri.Style := [fsBold];
  AddAttribute(FZcodeAttri);

  FIdentifierAttri := TSynHighLighterAttributes.Create(SYNS_AttrIdentifier, SYNS_FriendlyAttrIdentifier);
  AddAttribute(FIdentifierAttri);

  //Marco func
  FKeyAttri := TSynHighLighterAttributes.Create(SYNS_AttrFunction, SYNS_FriendlyAttrFunction);
  FKeyAttri.Foreground := $0000FFFF;
  FKeyAttri.Style := [fsBold];
  AddAttribute(FKeyAttri);

  SetAttributesOnChange(@DefHighlightChange);
  InitIdent;
  FDefaultFilter := SYNS_FilterCNC;
  FRange := rsNormal;
end;

procedure TSynCNCSyn.NormalProc;
begin
  inc(Run);
  FTokenID := tkNormal;
end;

procedure TSynCNCSyn.IdentProc;
begin
  FTokenID := IdentKind(FLine + Run);
  inc(Run, FLineLen);
  while IsIdentChar(FLine[Run]) do
    Inc(Run);
end;

procedure TSynCNCSyn.ACodeProc;
begin  //'abs', 'acos', 'and', 'ar', 'asin', 'atan'
  FTokenID := tkNormal;
  case FLine[Run] of
    'a':
      begin
      if ((FLine[Run+1] = 'b') and (FLine[Run+2] = 's'))then //abs
      begin
        FTokenID := tkFunction;
        inc(Run, 3);
      end else
      if ((FLine[Run+1] = 'c') and (FLine[Run+2] = 'o') and (FLine[Run+3] = 's'))then //acos
      begin
        FTokenID := tkFunction;
        inc(Run, 4);
      end else
      if ((FLine[Run+1] = 'n') and (FLine[Run+2] = 'd'))then  //and
      begin
        FTokenID := tkFunction;
        inc(Run, 3);
      end else
      if ((FLine[Run+1] = 'r'))then  //ar
      begin
        FTokenID := tkFunction;
        inc(Run, 2);
      end else
      if ((FLine[Run+1] = 's') and (FLine[Run+2] = 'i') and (FLine[Run+3] = 'n'))then  //asin
      begin
        FTokenID := tkFunction;
        inc(Run, 4);
      end else
      if ((FLine[Run+1] = 't') and (FLine[Run+2] = 'a') and (FLine[Run+3] = 'n'))then  //atan
      begin
        FTokenID := tkFunction;
        inc(Run, 4);
      end else
      begin
        FTokenID := tkAcode;
        inc(Run, 1);
      end;
      end
  else
    SpaceProc;
  end;
end;

procedure TSynCNCSyn.BCodeProc;
begin //'bcd', 'bin',
  FTokenID := tkNormal;
  case FLine[Run] of
    'b':
      begin
      if ((FLine[Run+1] = 'c') and (FLine[Run+2] = 'd'))then //bcd
      begin
        FTokenID := tkFunction;
        inc(Run, 3);
      end else
      if ((FLine[Run+1] = 'i') and (FLine[Run+2] = 'n'))then //bin
      begin
        FTokenID := tkFunction;
        inc(Run, 3);
      end else
      begin
        FTokenID := tkBcode;
        inc(Run, 1);
      end;
      end
  else
    SpaceProc;
  end;
end;

procedure TSynCNCSyn.CCodeProc;
begin //'cos'
  FTokenID := tkNormal;
  case FLine[Run] of
    'c':
      begin
      if ((FLine[Run+1] = 'o') and (FLine[Run+2] = 's'))then //cos
      begin
        FTokenID := tkFunction;
        inc(Run, 3);
      end else
      begin
        FTokenID := tkCcode;
        inc(Run, 1);
      end;
      end
  else
    SpaceProc;
  end;
end;

procedure TSynCNCSyn.DCodeProc;
begin //'do'
  FTokenID := tkNormal;
  case FLine[Run] of
    'd':
      begin
      if ((FLine[Run+1] = 'o'))then //do
      begin
        FTokenID := tkFunction;
        inc(Run, 2);
      end else
      begin
        FTokenID := tkDcode;
        inc(Run, 1);
      end;
      end
  else
    SpaceProc;
  end;
end;

procedure TSynCNCSyn.ECodeProc;
begin // 'else', 'end', 'endif', 'endw', 'eq', 'exp',
  FTokenID := tkNormal;
  case FLine[Run] of
    'e':
      begin
        if ((FLine[Run+1] = 'l') and (FLine[Run+2] = 's') and (FLine[Run+3] = 'e'))then //else
        begin
          FTokenID := tkFunction;
          inc(Run, 4);
        end else
        if ((FLine[Run+1] = 'n') and (FLine[Run+2] = 'd') and (FLine[Run+3] = 'i') and (FLine[Run+4] = 'f'))then //endif
        begin
          FTokenID := tkFunction;
          inc(Run, 5);
        end else
        if ((FLine[Run+1] = 'n') and (FLine[Run+2] = 'd') and (FLine[Run+3] = 'w'))then //endw
        begin
          FTokenID := tkFunction;
          inc(Run, 4);
        end else
        if ((FLine[Run+1] = 'n') and (FLine[Run+2] = 'd'))then //end
        begin
          FTokenID := tkFunction;
          inc(Run, 3);
        end else
        if ((FLine[Run+1] = 'q'))then //eq
        begin
          FTokenID := tkFunction;
          inc(Run, 2);
        end else
        if ((FLine[Run+1] = 'x') and (FLine[Run+2] = 'p'))then //exp
        begin
          FTokenID := tkFunction;
          inc(Run, 3);
        end else
        begin
          FTokenID := tkEcode;
          inc(Run, 1);
        end;
      end
  else
    SpaceProc;
  end;
end;

procedure TSynCNCSyn.FCodeProc;
begin  //'false', 'fix', 'fup',
  FTokenID := tkNormal;
  case FLine[Run] of
    'f':
      begin
        if ((FLine[Run+1] = 'a') and (FLine[Run+2] = 'l') and (FLine[Run+3] = 's')
          and (FLine[Run+4] = 'e')) then //false
        begin
          FTokenID := tkFunction;
          inc(Run, 5);
        end else
        if ((FLine[Run+1] = 'i') and (FLine[Run+2] = 'x')) then //fix
        begin
          FTokenID := tkFunction;
          inc(Run, 3);
        end else
        if ((FLine[Run+1] = 'u') and (FLine[Run+2] = 'p')) then //fup
        begin
          FTokenID := tkFunction;
          inc(Run, 3);
        end else
        begin
          FTokenID := tkFcode;
          inc(Run, 1);
        end;
      end
  else
    SpaceProc;
  end;
end;

procedure TSynCNCSyn.GCodeProc;
var
  i: Integer;
begin   //'ge', 'goto', 'gt',
  FTokenID := tkNormal;
  case FLine[Run] of
    'g':
      begin
        if ((FLine[Run+1] = 'e')) then //ge
        begin
          FTokenID := tkFunction;
            inc(Run, 2);
        end else
        if ((FLine[Run+1] = 'o') and (FLine[Run+2] = 't') and (FLine[Run+3] = 'o')) then //goto
        begin
          FTokenID := tkFunction;
            inc(Run, 4);
        end else
        if ((FLine[Run+1] = 't')) then //gt
        begin
          FTokenID := tkFunction;
            inc(Run, 2);
        end else
        begin
          while (FLine[Run + 1] in ['.','0'..'9']) and not IsLineEnd(Run) do
          inc(Run);
          FTokenID := tkGcode;
          inc(Run, 1);
        end;
      end
  else
    SpaceProc;
  end;
end;

procedure TSynCNCSyn.HCodeProc;
begin
  FTokenID := tkNormal;
  case FLine[Run] of
    'h':
      begin
        FTokenID := tkHcode;
        inc(Run, 1);
      end
  else
    SpaceProc;
  end;
end;

procedure TSynCNCSyn.ICodeProc;
begin  //'if', 'int'
  FTokenID := tkNormal;
  case FLine[Run] of
    'i':
      begin
        if ((FLine[Run+1] = 'f')) then //if
        begin
          FTokenID := tkFunction;
            inc(Run, 2);
        end else
        if ((FLine[Run+1] = 'n') and (FLine[Run+2] = 't')) then //int
        begin
          FTokenID := tkFunction;
            inc(Run, 3);
        end else
        begin
          FTokenID := tkIcode;
          inc(Run, 1);
        end;
      end
  else
    SpaceProc;
  end;
end;

procedure TSynCNCSyn.JCodeProc;
begin
  FTokenID := tkNormal;
  case FLine[Run] of
    'j':
      begin
        FTokenID := tkJcode;
        inc(Run, 1);
      end
  else
    SpaceProc;
  end;
end;

procedure TSynCNCSyn.KCodeProc;
begin
  FTokenID := tkNormal;
  case FLine[Run] of
    'k':
      begin
        FTokenID := tkKcode;
        inc(Run, 1);
      end
  else
    SpaceProc;
  end;
end;

procedure TSynCNCSyn.LCodeProc;
begin  //'le', 'ln', 'lt',
  FTokenID := tkNormal;
  case FLine[Run] of
    'l':
      begin
        if ((FLine[Run+1] = 'e')) then //le
        begin
          FTokenID := tkFunction;
            inc(Run, 2);
        end else
        if ((FLine[Run+1] = 'n')) then //ln
        begin
          FTokenID := tkFunction;
            inc(Run, 2);
        end else
        if ((FLine[Run+1] = 't')) then //lt
        begin
          FTokenID := tkFunction;
            inc(Run, 2);
        end else
        begin
          FTokenID := tkLcode;
          inc(Run, 1);
        end;
      end
  else
    SpaceProc;
  end;
end;

procedure TSynCNCSyn.MCodeProc;
begin
  FTokenID := tkNormal;
  case FLine[Run] of
    'm':
      begin
        FTokenID := tkMcode;
        inc(Run, 1);
      end
  else
    SpaceProc;
  end;
end;

procedure TSynCNCSyn.NCodeProc;
begin  //'ne', 'next', 'not'
  FTokenID := tkNormal;
  case FLine[Run] of
    'n':
      begin
        if ((FLine[Run+1] = 'e') and (FLine[Run+2] = 'x') and (FLine[Run+3] = 't')) then //next
        begin
          FTokenID := tkFunction;
            inc(Run, 4);
        end else
        if ((FLine[Run+1] = 'o') and (FLine[Run+2] = 't')) then //not
        begin
          FTokenID := tkFunction;
            inc(Run, 3);
        end else
        if ((FLine[Run+1] = 'e')) then //ne
        begin
          FTokenID := tkFunction;
            inc(Run, 2);
        end else
        begin
          while (FLine[Run + 1] in ['0'..'9']) and not IsLineEnd(Run) do
          inc(Run);
          FTokenID := tkNcode;
          inc(Run, 1);
        end;
      end
  else
    SpaceProc;
  end;
end;

procedure TSynCNCSyn.OCodeProc;
begin//'or'
  FTokenID := tkNormal;
  case FLine[Run] of
    'o':
      begin
        if ((FLine[Run+1] = 'r')) then //or
        begin
          FTokenID := tkFunction;
            inc(Run, 2);
        end else
        begin
          FTokenID := tkOcode;
          inc(Run, 1);
        end;
      end
  else
    SpaceProc;
  end;
end;


procedure TSynCNCSyn.PCodeProc;
begin //'pi'
  FTokenID := tkNormal;
  case FLine[Run] of
    'p':
      begin
        if ((FLine[Run+1] = 'i')) then //pi
        begin
          FTokenID := tkFunction;
            inc(Run, 2);
        end else
        begin
          FTokenID := tkPcode;
          inc(Run, 1);
        end;
      end
  else
    SpaceProc;
  end;
end;

procedure TSynCNCSyn.QCodeProc;
begin
  FTokenID := tkNormal;
  case FLine[Run] of
    'q':
      begin
        FTokenID := tkQcode;
        inc(Run, 1);
      end
  else
    SpaceProc;
  end;
end;

procedure TSynCNCSyn.RCodeProc;
begin   //'repeart', 'round'
  FTokenID := tkNormal;
  case FLine[Run] of
    'r':
      begin
        if ((FLine[Run+1] = 'e') and (FLine[Run+2] = 'p') and (FLine[Run+3] = 'e')
          and (FLine[Run+4] = 'a') and (FLine[Run+5] = 'r') and (FLine[Run+6] = 't')) then //repeart
          begin
            FTokenID := tkFunction;
              inc(Run, 7);
          end else
        if ((FLine[Run+1] = 'o') and (FLine[Run+2] = 'u') and (FLine[Run+3] = 'n')
          and (FLine[Run+4] = 'd')) then //round
          begin
            FTokenID := tkFunction;
              inc(Run, 5);
          end else
        begin
          FTokenID := tkRcode;
          inc(Run, 1);
        end;
      end
  else
    SpaceProc;
  end;
end;

procedure TSynCNCSyn.SCodeProc;
begin  //'sign', 'sin', 'sqrt'
  FTokenID := tkNormal;
  case FLine[Run] of
    's':
      begin
        if ((FLine[Run+1] = 'i') and (FLine[Run+2] = 'g') and (FLine[Run+3] = 'n')) then //sign
        begin
          FTokenID := tkFunction;
            inc(Run, 4);
        end else
        if ((FLine[Run+1] = 'i') and (FLine[Run+2] = 'n')) then //sin
        begin
          FTokenID := tkFunction;
            inc(Run, 3);
        end else
        if ((FLine[Run+1] = 'q') and (FLine[Run+2] = 'r') and (FLine[Run+3] = 't')) then //sqrt
        begin
          FTokenID := tkFunction;
            inc(Run, 4);
        end else
        begin
          FTokenID := tkScode;
          inc(Run, 1);
        end;
      end
  else
    SpaceProc;
  end;
end;

procedure TSynCNCSyn.TCodeProc;
begin   //'tan', 'then', 'true'
  FTokenID := tkNormal;
  case FLine[Run] of
    't':
      begin
        if ((FLine[Run+1] = 'a') and (FLine[Run+2] = 'n')) then //tan
        begin
          FTokenID := tkFunction;
            inc(Run, 3);
        end else
        if ((FLine[Run+1] = 'h') and (FLine[Run+2] = 'e') and (FLine[Run+3] = 'n')) then //then
        begin
          FTokenID := tkFunction;
            inc(Run, 4);
        end else
        if ((FLine[Run+1] = 'r') and (FLine[Run+2] = 'u') and (FLine[Run+3] = 'e')) then //true
        begin
          FTokenID := tkFunction;
            inc(Run, 4);
        end else
        begin
          FTokenID := tkTcode;
          inc(Run, 1);
        end;
      end
  else
    SpaceProc;
  end;
end;


procedure TSynCNCSyn.UCodeProc;
begin
  FTokenID := tkNormal;
  case FLine[Run] of
    'u':
      begin
        FTokenID := tkUcode;
        inc(Run, 1);
      end
  else
    SpaceProc;
  end;
end;

procedure TSynCNCSyn.VCodeProc;
begin
  FTokenID := tkNormal;
  case FLine[Run] of
    'v':
      begin
        FTokenID := tkVcode;
        inc(Run, 1);
      end
  else
    SpaceProc;
  end;
end;

procedure TSynCNCSyn.WCodeProc;
begin  // 'while'
  FTokenID := tkNormal;
  case FLine[Run] of
    'w':
      begin
        if ((FLine[Run+1] = 'h') and (FLine[Run+2] = 'i') and (FLine[Run+3] = 'l')
          and (FLine[Run+4] = 'e')) then //while
        begin
          FTokenID := tkFunction;
            inc(Run, 5);
        end else
        begin
          FTokenID := tkWcode;
          inc(Run, 1);
        end;
      end
  else
    SpaceProc;
  end;
end;

procedure TSynCNCSyn.XCodeProc;
begin //'xor'
  FTokenID := tkNormal;
  case FLine[Run] of
    'x':
      begin
      if ((FLine[Run+1] = 'o') and (FLine[Run+2] = 'r')) then //xor
        begin
          FTokenID := tkFunction;
          inc(Run, 3);
        end else
        begin
          FTokenID := tkXcode;
          inc(Run, 1);
        end;
      end
  else
    SpaceProc;
  end;
end;

procedure TSynCNCSyn.YCodeProc;
begin
  FTokenID := tkNormal;
  case FLine[Run] of
    'y':
      begin
        FTokenID := tkYcode;
        inc(Run, 1);
      end
  else
    SpaceProc;
  end;
end;

procedure TSynCNCSyn.ZCodeProc;
begin
  FTokenID := tkNormal;
  case FLine[Run] of
    'z':
      begin
        FTokenID := tkZcode;
        inc(Run, 1);
      end
  else
    SpaceProc;
  end;
end;

procedure TSynCNCSyn.Next;
begin
  fTokenPos := Run;
  case FRange of
    rsComment: CommentProc;
  else
    case FLine[Run] of
      #0: NullProc;
      #10: LFProc;
      #13: CRProc;
      '(': CommentOpenProc;
      #1 .. #9, #11, #12, #14 .. #32: SpaceProc;
      '.','-','0' .. '9': NumberProc;
      '%','[',']','@','^','*',';','=': SymbolProc;
//       'A'..'Z', 'a'..'z', '_': IdentProc;
      '#': ParameterProc;
      'a': ACodeProc;
      'b': BCodeProc;
      'c': CCodeProc;
      'd': DCodeProc;
      'e': ECodeProc;
      'f': FCodeProc;
      'g': GCodeProc;
      'h': HCodeProc;
      'i': ICodeProc;
      'j': JCodeProc;
      'k': KCodeProc;
      'l': LCodeProc;
      'm': MCodeProc;
      'n': NCodeProc;
      'o': OCodeProc;
      'p': PCodeProc;
      'q': QCodeProc;
      'r': RCodeProc;
      's': SCodeProc;
      't': TCodeProc;
      'u': UCodeProc;
      'v': VCodeProc;
      'w': WCodeProc;
      'x': XCodeProc;
      'y': YCodeProc;
      'z': ZCodeProc;
    else
      NormalProc;
    end;
  end;
  //inherited;
end;

function TSynCNCSyn.GetDefaultAttribute(Index: Integer)
  : TSynHighlighterAttributes;
begin
  case Index of
    SYN_ATTR_COMMENT: Result := FCommentAttri;
    SYN_ATTR_STRING: Result := FStringAttri;
    SYN_ATTR_WHITESPACE: Result := FSpaceAttri;
  else
    Result := nil;
  end;
end;

function TSynCNCSyn.GetEol: Boolean;
begin
  Result := Run = FLineLen + 1;
end;

function TSynCNCSyn.GetKeywordIdentifiers: TStringList;
var
  f: Integer;
begin
  if not Assigned (GlobalKeywords) then
  begin
    // Create the string list of keywords - only once
    GlobalKeywords := TStringList.Create;
    GlobalKeywords.CommaText:=
    'ABS,ACos,AND,AR,ASin,ATan,BCD,BIN,Cos,DO,ELSE,END,ENDIF,ENDW,EQ,EXP,F' +
    'alse,FIX,FUP,GE,GOTO,GT,IF,INT,LE,LN,LT,NE,NEXT,NOT,OR,PI,REPEART,ROUN' +
    'D,SIGN,Sin,SQRT,Tan,THEN,True,WHILE,XOR';
  end;
  Result := GlobalKeywords;
end;

function TSynCNCSyn.GetTokenID: TtkTokenKind;
begin
  Result := FTokenID;
end;

procedure TSynCNCSyn.GetTokenEx(out TokenStart: PChar;
  out TokenLength: integer);
begin
  TokenLength:=Run-fTokenPos;
  //TokenStart:=FLine + fTokenPos;
  TokenStart:=fCasedLine + fTokenPos;
end;


function TSynCNCSyn.GetTokenAttribute: TSynHighlighterAttributes;
begin
  case GetTokenID of
    tkComment: Result := FCommentAttri;
    tkText: Result := FStringAttri;
    tkNormal: Result := FNormalAttri;
    tkReserved: Result := FReservedAttri;
    tkParam: Result := FParameterAttri;
    tkNumber: Result := FNumberAttri;
    tkSpace: Result := FSpaceAttri;
    tkEqual: Result := FEqualAttri;
    tkAbstract: Result := FSymbolAttri;

    tkFunction: Result := FKeyAttri;
    tkIdentifier: Result := FIdentifierAttri;

    tkAcode: Result := FAcodeAttri;
    tkBcode: Result := FBcodeAttri;
    tkCcode: Result := FCcodeAttri;
    tkDcode: Result := FDcodeAttri;
    tkEcode: Result := FEcodeAttri;
    tkFcode: Result := FFcodeAttri;
    tkGcode: Result := FGcodeAttri;
    tkHcode: Result := FHcodeAttri;
    tkIcode: Result := FIcodeAttri;
    tkJcode: Result := FJcodeAttri;
    tkKcode: Result := FKcodeAttri;
    tkLcode: Result := FLcodeAttri;
    tkMcode: Result := FMcodeAttri;
    tkNcode: Result := FNcodeAttri;
    tkOcode: Result := FOcodeAttri;
    tkPcode: Result := FPcodeAttri;
    tkQcode: Result := FQcodeAttri;
    tkRcode: Result := FRcodeAttri;
    tkScode: Result := FScodeAttri;
    tkTcode: Result := FTcodeAttri;
    tkUcode: Result := FUcodeAttri;
    tkVcode: Result := FVcodeAttri;
    tkWcode: Result := FWcodeAttri;
    tkXcode: Result := FXcodeAttri;
    tkYcode: Result := FYcodeAttri;
    tkZcode: Result := FZcodeAttri;
  else
    Result := nil;
  end;
end;

function TSynCNCSyn.GetTokenKind: Integer;
begin
  Result := Ord(FTokenID);
end;

function TSynCNCSyn.IsIdentChar(AChar: Char): Boolean;
begin
  case AChar of
    {'=', }'-', '.', '+', '0' .. '9', 'a' .. 'z', 'A' .. 'Z':
      Result := True;
  else
    Result := False;
  end;
end;

function TSynCNCSyn.IsFilterStored: Boolean;
begin
  Result := fDefaultFilter <> SYNS_FilterCNC;
end;

class function TSynCNCSyn.GetLanguageName: string;
begin
  Result := SYNS_LangCNC;
end;

procedure TSynCNCSyn.ResetRange;
begin
  FRange := rsNormal;
end;

procedure TSynCNCSyn.SetRange(Value: Pointer);
begin
  FRange := TRangeState(PtrUInt(Value));
end;

function TSynCNCSyn.GetRange: Pointer;
begin
  Result := Pointer(PtrUInt(FRange));
end;

function TSynCNCSyn.GetIdentChars: TSynIdentChars;
begin
  Result := ['-', '.', '+', '0' .. '9', 'a' .. 'z', 'A' .. 'Z'];
end;

function TSynCNCSyn.GetSampleSource: String;
begin
  Result := '%                                           '+#13+
            '(0001 part1)                                '+#13+
            'N100 (FRANK.WU. CNC G-Code Test)            '+#13+
            'N102 (REV-0.70)                             '+#13+
            'N104 (JUN- 8-2020-11:30:12AM)               '+#13+
            '                                            '+#13+
            'N106 (TOOL 1 - DIA 2.)                      '+#13+
            '                                            '+#13+
            'N1 G90 G17 G40 G80 G00                      '+#13+
            'N108 M06 T1 ()                              '+#13+
            'N110 (2DE-轮廓)                             '+#13+
            'N112 G00 G54 G90 X-30.9498 Y9.2005 S3500 M03'+#13+
            'N114 G43 H1 Z50.                            '+#13+
            'N116 S4000                                  '+#13+
            'N118 Z25.                                   '+#13+
            'N120 Z2.                                    '+#13+
            'N122 G01 Z-1.5 F120.                        '+#13+
            'N124 X25.3927 Y-13.2166 F200.               '+#13+
            'N126 G00 Z25.                               '+#13+
            'N128 X-30.9498 Y9.2005                      '+#13+
            'N130 Z2.                                    '+#13+
            'N132 G01 Z-1.5 F120.                        '+#13+
            'N134 X25.3927 Y-13.2166 F200.               '+#13+
            'N136 G00 Z25.                               '+#13+
            'N138 M05                                    '+#13+
            'N140 G00 G28 G91 Z0                         '+#13+
            'N142 G00 G28 G91 X-15.0 Y0.                 '+#13+
            'N144 G90                                    '+#13+
            'N146 M06 T1                                 '+#13+
            'N148 M30                                    '+#13+
            '%'
;
end;

procedure TSynCNCSyn.SetLine(const NewValue: string; LineNumber:Integer);
begin
  inherited;
  fLineStr       := LowerCase(NewValue);
  fLineLen       := length(fLineStr);
  fLine          := PChar(fLineStr);
  Run            := 0;
  fCasedLineStr  := NewValue;
  fCasedLine     := PChar(FCasedLineStr);
  Next;
end; { SetLine }

function TSynCNCSyn.GetHighlighterAttriAtRowColEx(XY: TPoint;
  out Token: string; out TokenType, Start: Integer;
  out Attri: TSynHighlighterAttributes): boolean;
var
  PosX, PosY: integer;
  Line: string;
begin
  PosY := XY.Y -1;
  with TCustomSynEdit(Self.Owner) do
  if (PosY >= 0) and (PosY < Lines.Count) then
  begin
    Line := Lines[PosY];
    StartAtLineIndex(PosY);
    PosX := XY.X;
    if (PosX > 0) and (PosX <= Length(Line)) then begin
      while not GetEol do begin
        Start := GetTokenPos + 1;
        Token := GetToken;
        if (PosX >= Start) and (PosX < Start + Length(Token)) then begin
          Attri := GetTokenAttribute;
          TokenType := GetTokenKind;
          //Token := GetToken;
          exit(True);
        end;
        Next;
      end;
    end;
  end;
  Token := '';
  Attri := nil;
  TokenType := -1;
  Result := False;
end;

function TSynCNCSyn.GetTokenPos: Integer;
begin
  Result := fTokenPos;
end;

function TSynCNCSyn.GetToken: string;
var
  Len: LongInt;
begin
  Len := Run - fTokenPos;
  SetLength(Result,Len);
  if Len>0 then
    System.Move(fCasedLine[fTokenPos],Result[1],Len);
end;

initialization

{$IFNDEF SYN_CPPB_1}
  RegisterPlaceableHighlighter(TSynCNCSyn);
{$ENDIF}

end.
