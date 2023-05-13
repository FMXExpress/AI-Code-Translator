unit uMainForm;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs,
  FireDAC.Stan.Intf, FireDAC.Stan.Option, FireDAC.Stan.Param,
  FireDAC.Stan.Error, FireDAC.DatS, FireDAC.Phys.Intf, FireDAC.DApt.Intf,
  FireDAC.Stan.StorageBin, FMX.Memo.Types, FMX.Controls.Presentation,
  FMX.ScrollBox, FMX.Memo, FMX.ListBox, FMX.StdCtrls, FMX.Layouts, Data.DB,
  FireDAC.Comp.DataSet, FireDAC.Comp.Client, System.Rtti,
  System.Bindings.Outputs, Fmx.Bind.Editors, Data.Bind.EngExt,
  Fmx.Bind.DBEngExt, Data.Bind.Components, Data.Bind.DBScope, REST.Types,
  FMX.Edit, FMX.Effects, REST.Response.Adapter, REST.Client,
  Data.Bind.ObjectScope, FMX.ListView.Types, FMX.ListView.Appearances,
  FMX.ListView.Adapters.Base, FMX.EditBox, FMX.ComboTrackBar, FMX.ComboEdit,
  FMX.ListView, FMX.TabControl, System.Threading
  {$IFDEF MSWINDOWS}
  , WinApi.Windows, FMX.MultiView, FMX.Grid.Style, Fmx.Bind.Grid,
  Data.Bind.Controls, Fmx.Bind.Navigator, Data.Bind.Grid, FMX.Grid
  {$ENDIF}
  ;

type
  TMainForm = class(TForm)
    LanguageMT: TFDMemTable;
    Layout1: TLayout;
    Layout2: TLayout;
    InputCB: TComboBox;
    InputMemo: TMemo;
    PromptMemo: TMemo;
    MaterialOxfordBlueSB: TStyleBook;
    OutputMemo: TMemo;
    BindSourceDB1: TBindSourceDB;
    BindingsList1: TBindingsList;
    LinkListControlToField1: TLinkListControlToField;
    ToolBar1: TToolBar;
    ShadowEffect4: TShadowEffect;
    Label1: TLabel;
    APIKeyButton: TButton;
    OAAPIKeyEdit: TEdit;
    StatusBar1: TStatusBar;
    TranslateButton: TButton;
    RESTClient1: TRESTClient;
    RESTRequest1: TRESTRequest;
    RESTResponse1: TRESTResponse;
    RESTResponseDataSetAdapter1: TRESTResponseDataSetAdapter;
    FDMemTable1: TFDMemTable;
    VerifyCodeButton: TButton;
    PlatformFDMemTable: TFDMemTable;
    ProjectsFDMemTable: TFDMemTable;
    RSVarsFDMemTable: TFDMemTable;
    TabControl1: TTabControl;
    TabItem1: TTabItem;
    ListView1: TListView;
    Layout3: TLayout;
    PathEdit: TEdit;
    SearchEditButton1: TSearchEditButton;
    ScanButton: TButton;
    BuildButton: TButton;
    TabItem2: TTabItem;
    VertScrollBox1: TVertScrollBox;
    Layout4: TLayout;
    ExecParamsEdit: TEdit;
    Label7: TLabel;
    Layout5: TLayout;
    PlatformComboEdit: TComboEdit;
    Label4: TLabel;
    Layout6: TLayout;
    RSVArsComboEdit: TComboEdit;
    Label5: TLabel;
    Layout7: TLayout;
    CPUTB: TComboTrackBar;
    Label6: TLabel;
    Layout9: TLayout;
    Layout10: TLayout;
    CleanSwitch: TSwitch;
    Label2: TLabel;
    TabItem3: TTabItem;
    ErrorLogMemo: TMemo;
    BindSourceDB2: TBindSourceDB;
    LinkFillControlToField: TLinkFillControlToField;
    BindSourceDB3: TBindSourceDB;
    LinkFillControlToField1: TLinkFillControlToField;
    BindSourceDB4: TBindSourceDB;
    LinkListControlToField2: TLinkListControlToField;
    StatusLabel: TLabel;
    OutputCB: TComboBox;
    LanguageMT2: TFDMemTable;
    BindSourceDB5: TBindSourceDB;
    LinkListControlToField3: TLinkListControlToField;
    TabControl2: TTabControl;
    TabItem4: TTabItem;
    TabItem5: TTabItem;
    HistoryGrid: TStringGrid;
    HistoryMT: TFDMemTable;
    BindSourceDB6: TBindSourceDB;
    LinkGridToDataSourceBindSourceDB6: TLinkGridToDataSource;
    BindNavigator1: TBindNavigator;
    Layout8: TLayout;
    AutoVerifySwitch: TSwitch;
    Label3: TLabel;
    ModelsMT: TFDMemTable;
    VersionEdit: TComboEdit;
    BindSourceDB7: TBindSourceDB;
    ProgressBar: TProgressBar;
    Timer: TTimer;
    Splitter1: TSplitter;
    Splitter2: TSplitter;
    LinkFillControlToField2: TLinkFillControlToField;
    procedure APIKeyButtonClick(Sender: TObject);
    procedure TranslateButtonClick(Sender: TObject);
    procedure BuildButtonClick(Sender: TObject);
    procedure ScanButtonClick(Sender: TObject);
    procedure VerifyCodeButtonClick(Sender: TObject);
    procedure SearchEditButton1Click(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure OutputMemoChange(Sender: TObject);
    procedure OutputCBChange(Sender: TObject);
    procedure TimerTimer(Sender: TObject);
  private
    { Private declarations }
    FCancel: Boolean;
    function ProcessTask(const AId: Integer): ITask;
    procedure BuildProject(const AId: Integer; const APath: String);
    procedure BuildEnd;
    function CreateOpenAIChatJSON(const AModel, APrompt: string; AMaxTokens: Integer): string;
  public
    { Public declarations }
    {$IFDEF MSWINDOWS}
    function ExeAndWait(ExeNameAndParams: string; ncmdShow: Integer = SW_SHOWNORMAL): Integer;
    {$ENDIF}
  end;
  const
    STS_READY = 'Ready';
    STS_BUILDING = 'Building...';
    STS_SUCCESS = 'Complete';
    STS_FAIL = 'Failed';

var
  MainForm: TMainForm;

implementation

{$R *.fmx}

uses
  System.JSON, System.IOUtils, StrUtils;

procedure TMainForm.BuildButtonClick(Sender: TObject);
var
  LTasks: array of ITask;
  LThreadCount: Integer;
  LIndex: Integer;
begin
  case BuildButton.Tag of
   0: begin
      FCancel := False;

      ErrorLogMemo.Lines.Clear;

      while not ProjectsFDMemTable.EOF do
      begin
        ProjectsFDMemTable.Edit;
        ProjectsFDMemTable.FieldByName('Status').AsString := STS_READY;
        ProjectsFDMemTable.Post;
        ProjectsFDMemTable.Next;
      end;

      BuildButton.Tag := 1;
      BuildButton.Text := 'Cancel';

      StatusLabel.Text := '';

      LThreadCount := Trunc(CPUTB.Value);

      for LIndex := 1 to LThreadCount do
        begin
          LTasks := LTasks + [ProcessTask(LIndex)];
          LTasks[High(LTasks)].Start;
        end;

        TTask.Run(procedure begin
          TTask.WaitForAll(LTasks);
          TThread.Synchronize(nil,procedure begin
           BuildEnd;
          end);
        end);
   end;
   1: begin
     FCancel := True;
   end;
  end;

end;

procedure TMainForm.BuildProject(const AId: Integer; const APath: String);
var
  LCurrentFile: String;
  LReturnCode: integer;
  SL: TStringList;
  OutBat: TStringList;
  LAdditionalPath: String;
  LPlatform: String;
  LName: String;
begin

  SL := TStringList.Create;
  SL.LoadFromFile(RSVArsComboEdit.Text);

  LPlatform := 'Win32';
  LName := ExtractFileName(APath).Replace(ExtractFileExt(APath),'');

  OutBat := TStringList.Create;
  try
        LAdditionalPath := '';
        OutBat.Text := Trim(SL.Text);

        if APath.ToUpper.IndexOf('FLATBOX2D')>0 then
          LAdditionalPath := ';DCC_UnitSearchPath=$(DCC_UnitSearchPath)\FlatBox2d;$(DCC_UnitSearchPath)';

        OutBat.Append(Format(ExecParamsEdit.Text, [APAth, AId.ToString, PlatformComboEdit.Text, LAdditionalPath, CPUTB.Text]) + ' > ' + 'list'+AId.ToString + '.log');
        if CleanSwitch.IsChecked then OutBat.Append(Format('msbuild "%s" /t:Clean /p:Platform=%s ', [APath, PlatformComboEdit.Text]));
        OutBat.SaveToFile(ExtractFilePath(ParamStr(0)) + 'list'+AId.ToString + '.bat');
        LCurrentFile := 'cmd /c call '+ExtractFilePath(ParamStr(0))+'list'+AId.ToString+'.bat';
        {$IFDEF MSWINDOWS}
        LReturnCode := ExeAndWait(LCurrentFile, SW_HIDE);
        {$ENDIF}
        OutBat.LoadFromFile(ExtractFilePath(ParamStr(0)) + 'list'+AId.ToString + '.log');
        if OutBat.Text.IndexOf('Build succeeded.')>0 then
          begin
            TThread.Synchronize(nil,procedure begin
              if ProjectsFDMemTable.Locate('FullPath',VarArrayOf([APath]),[]) then
              begin
                ProjectsFDMemTable.Edit;
                ProjectsFDMemTable.FieldByName('Status').AsString := STS_SUCCESS;
                ProjectsFDMemTable.Post;
              end;
            end);
          end
        else
          begin
            TThread.Synchronize(nil,procedure begin
              if ProjectsFDMemTable.Locate('FullPath',VarArrayOf([APath]),[]) then
              begin
                ProjectsFDMemTable.Edit;
                ProjectsFDMemTable.FieldByName('Status').AsString := STS_FAIL;
                ProjectsFDMemTable.Post;
              end;
              ErrorLogMemo.Lines.Append(OutBat.Text);
              var LDeleteLine := False;
              for var I := ErrorLogMemo.Lines.Count-1 downto 0 do
              begin


                if ErrorLogMemo.Lines[I].Contains('_PasCoreCompile target') then
                  LDeleteLine := True
                else
                begin
                  if LDeleteLine=False then
                  begin
                    if ErrorLogMemo.Lines[I].Contains('error') then
                    begin
                      ErrorLogMemo.Lines[I] := Trim(LeftStr(ErrorLogMemo.Lines[I], Pos('[', ErrorLogMemo.Lines[I]) - 1));
                    end
                    else
                      ErrorLogMemo.Lines.Delete(I);
                  end;
                end;
                if LDeleteLine then
                  ErrorLogMemo.Lines.Delete(I);
              end;
            end);
          end;
        TThread.Synchronize(nil,procedure begin
          Application.ProcessMessages;
        end);


    finally
      OutBat.Free;
      SL.Free;
    end;

end;

procedure TMainForm.FormCreate(Sender: TObject);
begin
  PathEdit.Text := ExtractFilePath(ParamStr(0));
  ScanButtonClick(Sender);

  InputCB.ItemIndex := 4;
end;

procedure TMainForm.OutputCBChange(Sender: TObject);
begin
  OutputMemoChange(Sender);
end;

procedure TMainForm.OutputMemoChange(Sender: TObject);
begin
  if OutputMemo.Lines.Text<>'' then
  begin
    if ((OutputCB.Selected.Text='Delphi Object Pascal') OR (OutputCB.Selected.Text='C++')) then
      VerifyCodeButton.Enabled := True
    else
      VerifyCodeButton.Enabled := False;
    TranslateButton.Text := 'Refine Output Code';
  end
  else
  begin
    VerifyCodeButton.Enabled := False;
    TranslateButton.Text := 'Translate Input Code';
  end;
end;

function TMainForm.ProcessTask(const AId: Integer): ITask;
begin
  Result := TTask.Create(procedure var LIndex: Integer; LPath: String; begin
    for LIndex := 0 to ProjectsFDMemTable.RecordCount-1 do
    begin
      LPath := '';

      TThread.Synchronize(nil,procedure begin
        if ProjectsFDMemTable.Locate('Status',VarArrayOf([STS_READY]),[])=True then
          begin
            LPath := ProjectsFDMemTable.FieldByName('FullPath').AsString;
            ProjectsFDMemTable.Edit;
            ProjectsFDMemTable.FieldByName('Status').AsString := STS_BUILDING;
            ProjectsFDMemTable.Post;
          end;
      end);

      if LPath='' then Exit;

      BuildProject(AId, LPath);

      if FCancel then
        Break;
    end;
  end);
end;

procedure TMainForm.BuildEnd;
begin
  if FCancel=False then
    StatusLabel.Text := 'Complete!'
  else
    StatusLabel.Text := 'Canceled';

  BuildButton.Tag := 0;
  BuildButton.Text := BuildButton.Hint;

  FCancel := False;
end;

procedure TMainForm.VerifyCodeButtonClick(Sender: TObject);
begin
  OutPutMemo.Lines.SaveToFile(ExtractFilePath(ParamStr(0)) + 'ConsoleProgram.dpr');
  BuildButtonClick(Sender);
end;

procedure TMainForm.ScanButtonClick(Sender: TObject);
var
  LList: TStringDynArray;
  LSearchOption: TSearchOption;
  LItem: String;
begin
  LSearchOption := TSearchOption.soAllDirectories;
  LList := TDirectory.GetFiles(PathEdit.Text, '*.dproj', LSearchOption);
  LList := LList + TDirectory.GetFiles(PathEdit.Text, '*.cbproj', LSearchOption);
  ProjectsFDMemTable.EmptyDataSet;
  ProjectsFDMemTable.BeginBatch;
  for LItem in LList do
    begin
      ProjectsFDMemTable.Append;
      ProjectsFDMemTable.Edit;
      ProjectsFDMemTable.FieldByName('Filename').AsString := ExtractFileName(LItem);
      ProjectsFDMemTable.FieldByName('FullPath').AsString := LItem;
      ProjectsFDMemTable.FieldByName('Status').AsString := STS_READY;
      ProjectsFDMemTable.Post;
    end;
  ProjectsFDMemTable.EndBatch;
end;


procedure TMainForm.SearchEditButton1Click(Sender: TObject);
var
  LDirectory: String;
begin
  if SelectDirectory('Open Projects',ExtractFilePath(ParamStr(0)),LDirectory) then
  begin
    PathEdit.Text := LDirectory;
  end;
end;

function TMainForm.CreateOpenAIChatJSON(const AModel, APrompt: string; AMaxTokens: Integer): string;
var
  RootObj, SystemMessageObj, UserMessageObj: TJSONObject;
  MessagesArray: TJSONArray;
begin
  RootObj := TJSONObject.Create;
  try
    RootObj.AddPair('model', AModel);

    MessagesArray := TJSONArray.Create;
    try
      SystemMessageObj := TJSONObject.Create;
      SystemMessageObj.AddPair('role', 'system');
      SystemMessageObj.AddPair('content', 'You are the best and most experienced 10x programmer in all programming languages.');
      MessagesArray.AddElement(SystemMessageObj);

      if OutPutMemo.Lines.Text='' then
      begin
        UserMessageObj := TJSONObject.Create;
        UserMessageObj.AddPair('role', 'user');
        UserMessageObj.AddPair('content', APrompt);
        MessagesArray.AddElement(UserMessageObj);
      end;

      if OutPutMemo.Lines.Text<>'' then
      begin
        UserMessageObj := TJSONObject.Create;
        UserMessageObj.AddPair('role', 'assistant');
        UserMessageObj.AddPair('content', OutPutMemo.Lines.Text);
        MessagesArray.AddElement(UserMessageObj);
      end;

      if ErrorLogMemo.Lines.Text<>'' then
      begin
        UserMessageObj := TJSONObject.Create;
        UserMessageObj.AddPair('role', 'user');
        UserMessageObj.AddPair('content', 'Fix your mistakes. Only return code. Do not include \`\`\`. Tried to build. Got these errors: ' + ErrorLogMemo.Lines.Text);
        MessagesArray.AddElement(UserMessageObj);
      end;

      RootObj.AddPair('messages', MessagesArray);
    except
      MessagesArray.Free;
      raise;
    end;

  //  RootObj.AddPair('max_tokens', TJSONNumber.Create(AMaxTokens));

    Result := RootObj.Format(2); // The number 2 is to specify the formatting indent size
  finally
    RootObj.Free;
  end;
end;

procedure TMainForm.APIKeyButtonClick(Sender: TObject);
begin
  OAAPIKeyEdit.Visible := not OAAPIKeyEdit.Visible;
end;

function GetMessageContent(const JSONArray: string): string;
var
  JSONData: TJSONArray;
  MessageObj: TJSONObject;
begin
  Result := '';
  JSONData := TJSONObject.ParseJSONValue(JSONArray) as TJSONArray;
  try
    MessageObj := (JSONData.Items[0] as TJSONObject).GetValue<TJSONObject>('message');
    Result := MessageObj.GetValue<string>('content');
  finally
    JSONData.Free;
  end;
end;

procedure TMainForm.TimerTimer(Sender: TObject);
begin
  if ProgressBar.Visible = False then
  begin
    Timer.Enabled := False;
  end
  else
  begin
    if ProgressBar.Value=ProgressBar.Max then
      ProgressBar.Value := ProgressBar.Min
    else
      ProgressBar.Value := ProgressBar.Value+5;
  end;
end;

procedure TMainForm.TranslateButtonClick(Sender: TObject);
begin
  if OAAPIKeyEdit.Text='' then
  begin
    ShowMessage('Enter an OpenAI API key.');
    Exit;
  end;

  TranslateButton.Enabled := False;
  ProgressBar.Visible := True;
  Timer.Enabled := True;

  TTask.Run(procedure begin
    RESTRequest1.Params[0].Value := 'Bearer ' + OAAPIKeyEdit.Text;
    RESTRequest1.Params[1].Value := CreateOpenAIChatJSON(VersionEdit.Text, PromptMemo.Lines.Text.Replace('%inputlang%',InputCB.Selected.Text)
    .Replace('%outputlang%',OutputCB.Selected.Text)
    .Replace('%code%',InputMemo.Lines.Text), 2000);
    RESTRequest1.Execute;

    if FDMemTable1.FindField('choices')<>nil then
    begin
      TThread.Synchronize(nil,procedure begin
        OutputMemo.Lines.Text :=  GetMessageContent(FDMemTable1.FieldByName('choices').AsWideString);
        StatusLabel.Text := FDMemTable1.FieldByName('usage').AsWideString;

        if AutoVerifySwitch.IsChecked=True then
        begin
          VerifyCodeButtonClick(Sender);
        end;

        HistoryMT.AppendRecord([InputMemo.Lines.Text,OutputMemo.Lines.Text,ErrorLogMemo.Lines.Text]);
      end);
    end;

      TThread.Synchronize(nil,procedure begin
        TranslateButton.Enabled := True;
        ProgressBar.Visible := False;
      end);
  end);
end;


{$IFDEF MSWINDOWS}
function TMainForm.ExeAndWait(ExeNameAndParams: string; ncmdShow: Integer = SW_SHOWNORMAL): Integer;
var
    StartupInfo: TStartupInfo;
    ProcessInformation: TProcessInformation;
    Res: Bool;
    lpExitCode: DWORD;
begin
    with StartupInfo do //you can play with this structure
    begin
        cb := SizeOf(TStartupInfo);
        lpReserved := nil;
        lpDesktop := nil;
        lpTitle := nil;
        dwFlags := STARTF_USESHOWWINDOW;
        wShowWindow := ncmdShow;
        cbReserved2 := 0;
        lpReserved2 := nil;
    end;
    Res := CreateProcess(nil, PChar(ExeNameAndParams), nil, nil, True,
        CREATE_DEFAULT_ERROR_MODE
        or NORMAL_PRIORITY_CLASS, nil, nil, StartupInfo, ProcessInformation);
    while True do
    begin
        GetExitCodeProcess(ProcessInformation.hProcess, lpExitCode);
        if lpExitCode <> STILL_ACTIVE then
            Break;
        Application.ProcessMessages;
    end;
    Result := Integer(lpExitCode);
end;
{$ENDIF}


end.
