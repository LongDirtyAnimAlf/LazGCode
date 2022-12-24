unit ParseClass;

{$mode Delphi}{$H+}

interface

uses
  OObjects, SysUtils;

const
  MaxArg = 6;
  Nan: Double = 0/0;

function isNan(const d:double):boolean;

type
  TVarType = (vtDouble, vtBoolean, vtString, vtLeftBracket, vtRightBracket,
    vtComma);
  PDouble = ^Double;
  EParserException = class(Exception);
  PExpressionRec = ^TExpressionRec;

  TExprWord = class;

  TArgsArray = record
    Res: Double;
    Args: array[0..MaxArg - 1] of PDouble;
    ExprWord: TExprWord; //can be used to notify the object to update
  end;

  TDoubleFunc = procedure(Expr: PExpressionRec);

  TStringFunc = function(s1, s2: string): Double;

  TExpressionRec = record
    //used both as linked tree and linked list for maximum evaluation efficiency
    Oper: TDoubleFunc;
    Next: PExpressionRec;
    Res: Double;
    ExprWord: TExprWord;
    case Byte of
      0: (
        Args: array[0..MaxArg - 1] of PDouble;
        //can be used to notify the object to update
        );
      1: (ArgList: array[0..MaxArg - 1] of PExpressionRec);
  end;

  TExprCollection = class(TNoOwnerCollection)
  public
    function NextOper(IStart: Integer): Integer;
    procedure Check;
    procedure EraseExtraBrackets;
  end;

  TExprWord = class
  private
    FName: string;
    FDoubleFunc: TDoubleFunc;
  protected
    function GetIsOper: Boolean; virtual;
    function GetAsString: string; virtual;
    function GetIsVariable: Boolean;
    function GetCanVary: Boolean; virtual;
    function GetVarType: TVarType; virtual;
    function GetNFunctionArg: Integer; virtual;
    function GetDescription: string; virtual;
  public
    constructor Create(AName: string; ADoubleFunc: TDoubleFunc);
    function AsPointer: PDouble; virtual;
    property AsString: string read GetAsString;
    property DoubleFunc: TDoubleFunc read FDoubleFunc;
    property IsOper: Boolean read GetIsOper;
    property CanVary: Boolean read GetCanVary;
    property isVariable: Boolean read GetIsVariable;
    property VarType: TVarType read GetVarType;
    property NFunctionArg: Integer read GetNFunctionArg;
    property Name: string read FName;
    property Description: string read GetDescription;
  end;

  TExpressList = class(TSortedCollection)
  public
    function KeyOf(Item: Pointer): Pointer; override;
    function Compare(Key1, Key2: Pointer): Integer; override;
  end;

  TDoubleConstant = class(TExprWord)
  private
    FValue: Double;
  public
    function AsPointer: PDouble; override;
    constructor Create(AName: string; AValue: string);
    constructor CreateAsDouble(AName: string; AValue: Double);
    // not overloaded to support older Delphi versions
    property Value: Double read FValue write FValue;
  end;

  TConstant = class(TDoubleConstant)
  private
    FDescription: string;
  protected
    function GetDescription: string; override;
  public
    constructor CreateAsDouble(AName, Descr: string; AValue: Double);
  end;

  TBooleanConstant = class(TDoubleConstant)
  protected
    function GetVarType: TVarType; override;
  end;

  TGeneratedVariable = class(TDoubleConstant)
  private
    FAsString: string;
    FVarType: TVarType;
  protected
    function GetVarType: TVarType; override;
    function GetAsString: string; override;
    function GetCanVary: Boolean; override;
  public
    constructor Create(AName: string);
    property VarType read GetVarType write FVarType;
    property AsString: string read GetAsString write FAsString;
  end;

  TDoubleVariable = class(TExprWord)
  private
    FValue: PDouble;
  protected
    function GetCanVary: Boolean; override;
  public
    function AsPointer: PDouble; override;
    constructor Create(AName: string; AValue: PDouble);
  end;

  TStringConstant = class(TExprWord)
  private
    FValue: string;
  protected
    function GetVarType: TVarType; override;
    function GetAsString: string; override;
  public
    constructor Create(AValue: string);
  end;

  TLeftBracket = class(TExprWord)
    function GetVarType: TVarType; override;
  end;

  TRightBracket = class(TExprWord)
  protected
    function GetVarType: TVarType; override;
  end;

  TComma = class(TExprWord)
  protected
    function GetVarType: TVarType; override;
  end;

  PString = ^string;
  TStringVariable = class(TExprWord)
  private
    FValue: PString;
  protected
    function GetVarType: TVarType; override;
    function GetAsString: string; override;
    function GetCanVary: Boolean; override;
  public
    constructor Create(AName: string; AValue: PString);
  end;

  TFunction = class(TExprWord)
  private
    FIsOper: Boolean;
    FOperPrec: Integer;
    FNFunctionArg: Integer;
    FDescription: string;
  protected
    function GetDescription: string; override;
    function GetIsOper: Boolean; override;
    function GetNFunctionArg: Integer; override;
  public
    constructor Create(AName, Descr: string; ADoubleFunc: TDoubleFunc;
      ANFunctionArg: Integer);
    constructor CreateOper(AName: string; ADoubleFunc: TDoubleFunc;
      ANFunctionArg: Integer; AIsOper: Boolean; AOperPrec: Integer);
    property OperPrec: Integer read FOperPrec;
  end;

  TVaryingFunction = class(TFunction)
    // Functions that can vary for ex. random generators
    // should be TVaryingFunction to be sure that they are
    // always evaluated
  protected
    function GetCanVary: Boolean; override;
  end;

  TBooleanFunction = class(TFunction)
  protected
    function GetVarType: TVarType; override;
  end;

  TOper = (op_eq, op_gt, op_lt, op_ge, op_le, op_in);

const
  ListChar = ','; {the delimiter used with the 'in' operator: e.g.,
  ('a' in 'a,b') =True
  ('c' in 'a,b') =False}
type
  TSimpleStringFunction = class(TFunction)
  private
    FStringFunc: TStringFunc;
    FLeftArg: TExprWord;
    FRightArg: TExprWord;
  protected
    function GetCanVary: Boolean; override;
  public
    constructor Create(AName, Descr: string; AStringFunc:TStringFunc; ALeftArg, ARightArg:
      TExprWord);
    function Evaluate: Double;
    property StringFunc:TStringFunc read FStringFunc;
  end;

  TVaryingStringFunction=class(TSimpleStringFunction)
  protected
    function GetCanVary: Boolean; override;
  end;

  TLogicalStringOper = class(TSimpleStringFunction)
  protected
    function GetVarType: TVarType; override;
  public
    constructor Create(AOper: string; ALeftArg: TExprWord;
      ARightArg: TExprWord);
  end;

procedure _Variable(Param: PExpressionRec);

//procedure _StringFunc(Param: PExpressionRec);

implementation

//function _StrIn(sLookfor, sData: string): Double;

//function _StrInt(a, b: string): Double;


function isNan(const d:double):boolean;
begin
  Result:=comp(d)=comp(nan);
  //slower alternative: CompareMem(@d, @Nan, SizeOf(Double))
end;

procedure _Variable(Param: PExpressionRec);
begin
  with Param^ do
    Res := Args[0]^;
end;

procedure _StringFunc(Param: PExpressionRec);
begin
  with Param^ do
    Res := TSimpleStringFunction(ExprWord).Evaluate;
end;

function _StrInt(a, b: string): Double;
begin
  result:=StrToInt(a);
end;

function _StrEq(s1, s2: string): Double;
begin
  Result := Byte(s1 = s2);
end;

function _StrGt(s1, s2: string): Double;
begin
  Result := Byte(s1 > s2);
end;

function _Strlt(s1, s2: string): Double;
begin
  Result := Byte(s1 < s2);
end;

function _StrGe(s1, s2: string): Double;
begin
  Result := Byte(s1 >= s2);
end;

function _Strle(s1, s2: string): Double;
begin
  Result := Byte(s1 <= s2);
end;

function _Strne(s1, s2: string): Double;
begin
  Result := Byte(s1 <> s2);
end;

function _StrIn(sLookfor, sData: string): Double;
var
  loop: Integer;
  subString: string;
begin
  Result := 0;
  loop := pos(ListChar, sData);
  while loop > 0 do
  begin
    subString := Copy(sData, 1, loop - 1);
    sData := Copy(sData, loop + 1, Length(sData));
    if subString = sLookfor then
    begin
      Result := 1;
      break;
    end;
    loop := pos(ListChar, sData);
  end;
  if sLookfor = sData then
    Result := 1;
end;


{ TExpressionWord }

function TExprWord.AsPointer: PDouble;
begin
  Result := nil;
end;

constructor TExprWord.Create(AName: string; ADoubleFunc: TDoubleFunc);
begin
  FName := LowerCase(AName);
  FDoubleFunc := ADoubleFunc;
end;

function TExprWord.GetAsString: string;
begin
  Result := '';
end;

function TExprWord.GetCanVary: Boolean;
begin
  Result := False;
end;

function TExprWord.GetDescription: string;
begin
  Result := '';
end;

function TExprWord.GetIsOper: Boolean;
begin
  Result := False;
end;

function TExprWord.GetIsVariable: Boolean;
begin
  Result := @FDoubleFunc = @_Variable
end;

function TExprWord.GetNFunctionArg: Integer;
begin
  Result := 0;
end;

function TExprWord.GetVarType: TVarType;
begin
  Result := vtDouble;
end;

{ TDoubleConstant }

function TDoubleConstant.AsPointer: PDouble;
begin
  Result := @FValue;
end;

constructor TDoubleConstant.Create(AName, AValue: string);
begin
  inherited Create(AName, _Variable);
  if AValue <> '' then
    FValue := StrToFloat(AValue)
  else
    FValue := Nan;
end;

constructor TDoubleConstant.CreateAsDouble(AName: string; AValue: Double);
begin
  inherited Create(AName, _Variable);
  FValue := AValue;
end;

{ TStringConstant }

function TStringConstant.GetAsString: string;
begin
  Result := FValue;
end;

constructor TStringConstant.Create(AValue: string);
begin
  inherited Create(AValue, _Variable);
  if (AValue[1] = '''') and (AValue[Length(AValue)] = '''') then
    FValue := Copy(AValue, 2, Length(AValue) - 2)
  else
    FValue := AValue;
end;

function TStringConstant.GetVarType: TVarType;
begin
  Result := vtString;
end;

{ TDoubleVariable }

function TDoubleVariable.AsPointer: PDouble;
begin
  Result := FValue;
end;

constructor TDoubleVariable.Create(AName: string; AValue: PDouble);
begin
  inherited Create(AName, _Variable);
  FValue := AValue;
end;

function TDoubleVariable.GetCanVary: Boolean;
begin
  Result := True;
end;

{ TFunction }

constructor TFunction.Create(AName, Descr: string; ADoubleFunc: TDoubleFunc;
  ANFunctionArg: Integer);
begin
  FDescription := Descr;
  CreateOper(AName, ADoubleFunc, ANFunctionArg, False, 0);
  //to increase compatibility don't use default parameters
end;

constructor TFunction.CreateOper(AName: string; ADoubleFunc: TDoubleFunc;
  ANFunctionArg: Integer; AIsOper: Boolean; AOperPrec: Integer);
begin
  inherited Create(AName, ADoubleFunc);
  FNFunctionArg := ANFunctionArg;
  if FNFunctionArg > MaxArg then
    raise EParserException.Create('Too many arguments');
  FIsOper := AIsOper;
  FOperPrec := AOperPrec;
end;

function TFunction.GetDescription: string;
begin
  Result := FDescription;
end;

function TFunction.GetIsOper: Boolean;
begin
  Result := FIsOper;
end;

function TFunction.GetNFunctionArg: Integer;
begin
  Result := FNFunctionArg;
end;

{ TLeftBracket }

function TLeftBracket.GetVarType: TVarType;
begin
  Result := vtLeftBracket;
end;

{ TExpressList }

function TExpressList.Compare(Key1, Key2: Pointer): Integer;
begin
  Result := StrIComp(Pchar(Key1), Pchar(Key2));
end;

function TExpressList.KeyOf(Item: Pointer): Pointer;
begin
  Result := Pchar(TExprWord(Item).Name);
end;

{ TRightBracket }

function TRightBracket.GetVarType: TVarType;
begin
  Result := vtRightBracket;
end;

{ TComma }

function TComma.GetVarType: TVarType;
begin
  Result := vtComma;
end;

{ TExprCollection }

procedure TExprCollection.Check;
var
  brCount, I: Integer;
begin
  brCount := 0;
  for I := 0 to Count - 1 do
  begin
    case TExprWord(Items[I]).VarType of
      vtLeftBracket: Inc(brCount);
      vtRightBracket: Dec(brCount);
    end;
  end;
  if brCount <> 0 then
    raise EParserException.Create('Unequal brackets');
end;

procedure TExprCollection.EraseExtraBrackets;
var
  I: Integer;
  brCount: Integer;
begin
  if (TExprWord(Items[0]).VarType = vtLeftBracket) then
  begin
    brCount := 1;
    I := 1;
    while (I < Count) and (brCount > 0) do
    begin
      case TExprWord(Items[I]).VarType of
        vtLeftBracket: Inc(brCount);
        vtRightBracket: Dec(brCount);
      end;
      Inc(I);
    end;
    if (brCount = 0) and (I = Count) and (TExprWord(Items[I - 1]).VarType =
      vtRightBracket) then
    begin
      for I := 0 to Count - 3 do
        Items[I] := Items[I + 1];
      Count := Count - 2;
      EraseExtraBrackets; //Check if there are still too many brackets
    end;
  end;
end;

function TExprCollection.NextOper(IStart: Integer): Integer;
var
  brCount: Integer;
begin
  brCount := 0;
  Result := IStart;
  while (Result < Count) and ((brCount > 0) or
    (TExprWord(Items[Result]).NFunctionArg <= 0)) do
  begin
    case TExprWord(Items[Result]).VarType of
      vtLeftBracket: Inc(brCount);
      vtRightBracket: Dec(brCount);
    end;
    Inc(Result);
  end;
end;

{ TStringVariable }

function TStringVariable.GetAsString: string;
begin
  if (FValue^[1] = '''') and (FValue^[Length(FValue^)] = '''') then
    Result := Copy(FValue^, 2, Length(FValue^) - 2)
  else
    Result := FValue^
end;

constructor TStringVariable.Create(AName: string; AValue: PString);
begin
  inherited Create(AName, _Variable);
  FValue := AValue;
end;

function TStringVariable.GetVarType: TVarType;
begin
  Result := vtString;
end;

function TStringVariable.GetCanVary: Boolean;
begin
  Result := True;
end;

{ TLogicalStringOper }

constructor TLogicalStringOper.Create(AOper: string; ALeftArg,
  ARightArg: TExprWord);
begin
  if AOper = '=' then
    FStringFunc := @_streq
  else if AOper = '>' then
    FStringFunc := @_strgt
  else if AOper = '<' then
    FStringFunc := @_strlt
  else if AOper = '>=' then
    FStringFunc := @_strge
  else if AOper = '<=' then
    FStringFunc := @_strle
  else if AOper = '<>' then
    FStringFunc := @_strne
  else if AOper = 'in' then
    FStringFunc := @_strin
  else
    raise EParserException.Create(AOper + ' is not a valid string operand');
  inherited Create(AOper,'',StringFunc,ALeftArg,ARightArg);
end;


function TLogicalStringOper.GetVarType: TVarType;
begin
  Result := vtBoolean;
end;

{ TBooleanFunction }

function TBooleanFunction.GetVarType: TVarType;
begin
  Result := vtBoolean;
end;

{ TGeneratedVariable }

constructor TGeneratedVariable.Create(AName: string);
begin
  inherited Create(AName, '');
  FAsString := '';
  FVarType := vtDouble;
end;

function TGeneratedVariable.GetAsString: string;
begin
  Result := FAsString;
end;

function TGeneratedVariable.GetCanVary: Boolean;
begin
  Result := True;
end;

function TGeneratedVariable.GetVarType: TVarType;
begin
  Result := FVarType;
end;

{ TVaryingFunction }

function TVaryingFunction.GetCanVary: Boolean;
begin
  Result := True;
end;

{ TBooleanConstant }

function TBooleanConstant.GetVarType: TVarType;
begin
  Result := vtBoolean;
end;

{ TConstant }

constructor TConstant.CreateAsDouble(AName, Descr: string; AValue: Double);
begin
  FDescription := Descr;
  inherited CreateAsDouble(AName, AValue);
end;

function TConstant.GetDescription: string;
begin
  Result := FDescription;
end;

{ TSimpleStringFunction }

constructor TSimpleStringFunction.Create(AName, Descr: string; AStringFunc:TStringFunc;
  ALeftArg, ARightArg: TExprWord);
begin
  FStringFunc := @AStringFunc;
  FLeftArg := ALeftArg;
  FRightArg := ARightArg;
  inherited Create(AName, Descr, _StringFunc,0)
end;

function TSimpleStringFunction.Evaluate: Double;
var
  s1, s2: string;
begin
  s1 := FLeftArg.AsString;
  if FRightArg <> nil then
    s2 := FRightArg.AsString
  else
    s2 := '';
  Result := StringFunc(s1, s2);
end;

function TSimpleStringFunction.GetCanVary: Boolean;
begin
  Result := ((FLeftArg<>nil) and FLeftArg.CanVary) or ((FRightArg<>nil) and FRightArg.CanVary);
end;
{ TVaryingStringFunction }

function TVaryingStringFunction.GetCanVary: Boolean;
begin
  Result:=True;
end;

end.

