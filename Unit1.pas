unit Unit1;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ExtCtrls,ShlObj, FolderDialog,JPeg, Gauges;

Type TContenuPath=record
                    nbefile,nbedir:integer;
                  end;
  
type
  TRGBArray = array[Word] of TRGBTriple;
  pRGBArray = ^TRGBArray;
  TForm1 = class(TForm)
    GroupBoxsourcefolder: TGroupBox;
    GroupBoxdestfolder: TGroupBox;
    Panel1: TPanel;
    GroupBoxRules: TGroupBox;
    EditSource: TEdit;
    ButtonsourceExplore: TButton;
    EditDest: TEdit;
    ButtondestExplore: TButton;
    FolderDialog1: TFolderDialog;
    GroupBoxHeight: TGroupBox;
    GroupBoxWidth: TGroupBox;
    Labelnewwidth: TLabel;
    EditNewWidth: TEdit;
    EditNewHeight: TEdit;
    LabelNewHeight: TLabel;
    CheckBoxUnchangeHeight: TCheckBox;
    RadioGroupSmallerWidth: TRadioGroup;
    CheckBoxUnchangeWidth: TCheckBox;
    RadioGroupBiggerWidth: TRadioGroup;
    RadioGroupBiggerHeight: TRadioGroup;
    RadioGroupsmallerHeight: TRadioGroup;
    RadioGroupProportion: TRadioGroup;
    GroupBox6: TGroupBox;
    Buttontrt: TButton;
    StaticText1: TStaticText;
    Gauge1: TGauge;
    RadioGroupLanguage: TRadioGroup;
    procedure FormCreate(Sender: TObject);
    procedure ButtonsourceExploreClick(Sender: TObject);
    procedure ButtondestExploreClick(Sender: TObject);
    procedure RadioGroupProportionClick(Sender: TObject);
    procedure CheckBoxUnchangeWidthClick(Sender: TObject);
    procedure CheckBoxUnchangeHeightClick(Sender: TObject);
    procedure ButtontrtClick(Sender: TObject);
    procedure RadioGroupLanguageClick(Sender: TObject);
  private
    { Déclarations privées }
    function SpecialFolder(Folder: Integer): String;
    Function  GetParentDir(dir:String):String;
    Function  CountFilesInDir(Dir,ext:String):TContenuPath;
    Function  DeleteFilesInDir(Dir:String):Boolean;
    Function  Delete_File(Chemin,Nom:String):Boolean;
    Function  ResizeFilesAndDir(Source,dest,ext:String):Boolean;
    procedure SmoothResize(Src, Dst: TBitmap);
    function LoadJPEGPictureFile(Bitmap: TBitmap; FilePath, FileName: string): Boolean;
    function SaveJPEGPictureFile(Bitmap: TBitmap; FilePath, FileName: string;Quality: Integer): Boolean;
    procedure ResizeImage(OldFileName,NewFileName: string; NewWidth,NewHeight: Integer);
    function JPEGDimensions(Filename : string; var X, Y : word) : boolean;
    function CheckSourceDir(dir:string) : boolean;
    function CheckDestDir(dir:string) : boolean;
    procedure ResizeOneFile(oldf,newf:string);
    procedure ChangeLanguage(id:integer);    

  public
    { Déclarations publiques }
  end;

var
  Form1: TForm1;

implementation

{$R *.dfm}

procedure TForm1.ButtonsourceExploreClick(Sender: TObject);
begin
   FolderDialog1.Options:=[];
   if directoryExists(EditSource.Text) then  FolderDialog1.Directory:=EditSource.Text;
   if FolderDialog1.Execute then EditSource.Text:=FolderDialog1.Directory;
end;

procedure TForm1.ButtondestExploreClick(Sender: TObject);
begin
   FolderDialog1.Options:=[fdoNewDialogStyle];
   if directoryExists(EditDest.Text) then  FolderDialog1.Directory:=EditDest.Text;   
   if FolderDialog1.Execute then EditDest.Text:=FolderDialog1.Directory;
end;

function TForm1.CheckSourceDir(dir:string) : boolean;
var A,B:TContenuPath;
    Msg:string;
begin
   if Not DirectoryExists(dir) then
      begin
         Msg:='Directory '+dir+' not exists !';
         if RadioGroupLanguage.ItemIndex=1 then Msg:='Le dossier '+dir+' n''existe pas !';
         Showmessage(Msg);
         Result:=False;
         exit;
      end;
   A:=CountFilesInDir(dir,'jpg');
   B:=CountFilesInDir(dir,'jpeg');
   Gauge1.MaxValue:=A.nbefile+B.nbefile;
   if Gauge1.MaxValue=0 then
      begin
         Msg:='No Jpeg or jpg files in directory '+dir+' !';
         if RadioGroupLanguage.ItemIndex=1 then Msg:='Le dossier '+dir+' ne contien aucun fichier jpg/jpeg !';
         Showmessage(Msg);
         Result:=False;
         exit;
      end;
   Result:=True;      
end;


function TForm1.CheckDestDir(dir:string) : boolean;
var A:TContenuPath;
    Msg,s:string;

begin
   s:=GetParentDir(dir);
   if Not DirectoryExists(s) then
      begin
         Msg:='Directory '+s+' does not exists !';
         if RadioGroupLanguage.ItemIndex=1 then Msg:='Le dossier '+s+' n''existe pas !';
         Showmessage(Msg);
         Result:=False;
         exit;
      end;
   if DirectoryExists(dir) then
      begin
         A:=CountFilesInDir(dir,'*');
         if (A.nbefile+A.nbedir)>0 then
            begin
               Msg:=dir+' is not empty, delete ?';
               if RadioGroupLanguage.ItemIndex=1 then Msg:='Le dossier '+dir+' n''est pas vide, le vider ?';
               if (MessageDlg(Msg,mtConfirmation,[mbYes,mbNo],0)=idYes) then
                  DeleteFilesInDir(dir);
            end;
      end;
   if Not DirectoryExists(dir) then CreateDir(dir);
   if Not DirectoryExists(dir) then
      begin
         Msg:='Cannot create directory '+dir+' !';
         if RadioGroupLanguage.ItemIndex=1 then Msg:='Impossible de créer le doffier '+dir+' !';
         Showmessage(Msg);
         Result:=False;
         exit;
      end;
   Result:=True;
end;

procedure TForm1.ButtontrtClick(Sender: TObject);
var n:integer;
    Msg:String;
begin
   StaticText1.caption:='';
   Gauge1.Progress:=0;
   if (EditNewWidth.enabled) then
      begin
         Msg:='Incorrect new width';
         if RadioGroupLanguage.ItemIndex=1 then Msg:='Nouvelle largeure incorrecte';
         if Not (TryStrToInt(EditNewWidth.Text,n)) then
            begin
               Showmessage(Msg);
               Exit;
            end
         else
            begin
               if n<=0 then
                  begin
                     Showmessage(Msg);
                     Exit;
                  end;               
            end;
      end;
   if (EditNewHeight.enabled) then
      begin
         Msg:='Incorrect new Height';
         if RadioGroupLanguage.ItemIndex=1 then Msg:='Nouvelle hauteur incorrecte';
         if Not (TryStrToInt(EditNewHeight.Text,n)) then
            begin
               Showmessage(Msg);
               Exit;
            end
         else
            begin
               if n<=0 then
                  begin
                     Showmessage(Msg);
                     Exit;
                  end;               
            end;
      end;
   
   if Not CheckSourceDir(EditSource.text) then exit;
   if (trim(excludetrailingbackslash(EditSource.text))=trim(excludetrailingbackslash(EditDest.text))) then
      begin
         Msg:='Source and destination dir cannot be the same !';
         if RadioGroupLanguage.ItemIndex=1 then Msg:='Dossiers source et destination ne peuvent être les mêmes !';
         Showmessage(Msg);
         Exit;
      end;   
   if Not CheckDestDir(EditDest.text) then exit;
   if not ResizeFilesAndDir(EditSource.text,EditDest.text,'jpg') then exit;
   if not ResizeFilesAndDir(EditSource.text,EditDest.text,'jpeg') then exit
   else
      begin
         Msg:='Done !';
         if RadioGroupLanguage.ItemIndex=1 then Msg:='Terminé !';
         showmessage(Msg);
      end;
end;


Function TForm1.Delete_File(Chemin,Nom:String):Boolean;
var msg:string;
begin
   If fileExists(Includetrailingbackslash(Chemin)+Nom) then
      begin
          Msg:='Deleting '+Chemin+'\'+Nom;
          if RadioGroupLanguage.ItemIndex=1 then Msg:='Supprime '+Chemin+'\'+Nom;
          StaticText1.Caption:=Msg;
          Result:=DeleteFile(Chemin+'\'+Nom);
          If not Result then
             begin
                Msg:='Eoor whgile deleting '+Includetrailingbackslash(Chemin)+Nom;
                if RadioGroupLanguage.ItemIndex=1 then
                   Msg:='Erreur lors de la suppression du fichier '
                             +#13+Includetrailingbackslash(Chemin)+Nom;
                MessageDlg(Msg,mtwarning,[mbOK],0);
             end;
      end
   Else Result:=True;
end;

Function  TForm1.DeleteFilesInDir(Dir:String):Boolean;
var sr:TSearchRec;
    FileAttrs:Integer;
begin
   FileAttrs :=faAnyFile;
   Result:=True;
   if FindFirst(IncludeTrailingbackslash(Dir)+'*.*',FileAttrs,sr)=0 then
      begin
         repeat
            if ((sr.Attr and FileAttrs)>=0) and (sr.name<>'.') and (sr.name<>'..') then
               begin
                  If (sr.Attr and faDirectory)>0 then
                     begin
                        Result:=Result and (DeleteFilesInDir(IncludeTrailingbackslash(Dir)+sr.Name));
                     end
                  Else
                     Result:=Result and Delete_File(Dir,sr.Name);
               end;      
         until ((FindNext(sr)<>0) and Result);
      end;
   FindClose(sr);
   Result:=Result and (RemoveDir(Dir));
end;


procedure TForm1.CheckBoxUnchangeHeightClick(Sender: TObject);
begin
   if CheckBoxUnchangeHeight.checked then
      begin
         EditNewHeight.text:='';
         EditNewHeight.enabled:=False;
         RadioGroupBiggerHeight.ItemIndex:=0;
         RadioGroupBiggerHeight.Enabled:=False;
         RadioGroupSmallerHeight.Enabled:=False;
         RadioGroupSmallerHeight.ItemIndex:=0;
      end
   else
      begin
         RadioGroupBiggerHeight.Enabled:=True;
         RadioGroupSmallerHeight.Enabled:=True;
         EditNewHeight.enabled:=True;                 
      end;
end;

procedure TForm1.CheckBoxUnchangeWidthClick(Sender: TObject);
begin
   if CheckBoxUnchangeWidth.checked then
      begin
         EditNewWidth.text:='';
         EditNewWidth.enabled:=False;
         RadioGroupBiggerWidth.ItemIndex:=0;
         RadioGroupBiggerWidth.Enabled:=False;
         RadioGroupSmallerWidth.Enabled:=False;
         RadioGroupSmallerWidth.ItemIndex:=0;
      end
   else
      begin
         RadioGroupBiggerWidth.Enabled:=True;
         RadioGroupSmallerWidth.Enabled:=True;
         EditNewWidth.enabled:=True;              
      end;
end;

procedure TForm1.FormCreate(Sender: TObject);
begin
    RadioGroupLanguage.itemindex:=1;
    EditSource.Text:=SpecialFolder(CSIDL_PERSONAL);
    EditDest.Text:=includetrailingbackslash(EditSource.Text)+'out';
    StaticText1.caption:='';
end;

procedure TForm1.RadioGroupLanguageClick(Sender: TObject);
begin
   ChangeLanguage(RadioGroupLanguage.ItemIndex);
end;

procedure TForm1.RadioGroupProportionClick(Sender: TObject);
begin
   if not CheckBoxUnchangeHeight.enabled then CheckBoxUnchangeHeight.checked:=False;
   if not CheckBoxUnchangeWidth.enabled then CheckBoxUnchangeWidth.checked:=False;

   if radiogroupproportion.itemindex=0 then
      begin
        RadioGroupBiggerHeight.ItemIndex:=1;
        RadioGroupSmallerHeight.ItemIndex:=1;
        RadioGroupBiggerWidth.enabled:=True;
        RadioGroupSmallerWidth.enabled:=True;
        EditNewWidth.enabled:=True;
        CheckBoxUnchangeWidth.Enabled:=True;

        RadioGroupBiggerWidth.ItemIndex:=1;
        RadioGroupSmallerWidth.ItemIndex:=1;
        RadioGroupBiggerHeight.enabled:=True;
        RadioGroupSmallerHeight.enabled:=True;
        EditNewHeight.enabled:=True;
        CheckBoxUnchangeHeight.enabled:=True;


      end;
   if radiogroupproportion.itemindex=1 then
      begin
        RadioGroupBiggerHeight.ItemIndex:=1;
        RadioGroupSmallerHeight.ItemIndex:=1;
        RadioGroupBiggerHeight.enabled:=False;
        RadioGroupSmallerHeight.enabled:=False;
        RadioGroupBiggerWidth.enabled:=True;
        RadioGroupSmallerWidth.enabled:=True;
        EditNewWidth.enabled:=True;
        EditNewHeight.enabled:=False;
        EditNewHeight.Text:='';
        CheckBoxUnchangeWidth.enabled:=True;
        CheckBoxUnchangeWidth.Checked:=False;
        CheckBoxUnchangeHeight.enabled:=False;
        CheckBoxUnchangeHeight.Checked:=False;
      end;
   if radiogroupproportion.itemindex=2 then
      begin
        RadioGroupBiggerWidth.ItemIndex:=1;
        RadioGroupSmallerWidth.ItemIndex:=1;
        RadioGroupBiggerWidth.enabled:=False;
        RadioGroupSmallerWidth.enabled:=False;
        RadioGroupBiggerHeight.enabled:=True;
        RadioGroupSmallerHeight.enabled:=True;
        EditNewWidth.enabled:=False;
        EditNewWidth.Text:='';
        CheckBoxUnchangeWidth.enabled:=False;
        EditNewHeight.enabled:=True;
        CheckBoxUnchangeHeight.enabled:=True;
        CheckBoxUnchangeHeight.Checked:=False;
        CheckBoxUnchangeWidth.enabled:=False;
        CheckBoxUnchangeWidth.Checked:=False;
      end;

end;

function TForm1.SpecialFolder(Folder: Integer): String;
var
  SFolder : pItemIDList;
  SpecialPath : Array[0..MAX_PATH] Of Char;
begin
  SHGetSpecialFolderLocation(Application.Handle, Folder, SFolder);
  SHGetPathFromIDList(SFolder, SpecialPath);
  Result := StrPas(SpecialPath);
end;

procedure TForm1.SmoothResize(Src, Dst: TBitmap);
var
  x, y: Integer;
  xP, yP: Integer;
  xP2, yP2: Integer;
  SrcLine1, SrcLine2: pRGBArray;
  t3: Integer;
  z, z2, iz2: Integer;
  DstLine: pRGBArray;
  DstGap: Integer;
  w1, w2, w3, w4: Integer;
begin
  Src.PixelFormat := pf24Bit;
  Dst.PixelFormat := pf24Bit;

  if (Src.Width = Dst.Width) and (Src.Height = Dst.Height) then
    Dst.Assign(Src)
  else
  begin
    DstLine := Dst.ScanLine[0];
    DstGap  := Integer(Dst.ScanLine[1]) - Integer(DstLine);

    xP2 := MulDiv(pred(Src.Width), $10000, Dst.Width);
    yP2 := MulDiv(pred(Src.Height), $10000, Dst.Height);
    yP  := 0;

    for y := 0 to pred(Dst.Height) do
    begin
      xP := 0;

      SrcLine1 := Src.ScanLine[yP shr 16];

      if (yP shr 16 < pred(Src.Height)) then
        SrcLine2 := Src.ScanLine[succ(yP shr 16)]
      else
        SrcLine2 := Src.ScanLine[yP shr 16];

      z2  := succ(yP and $FFFF);
      iz2 := succ((not yp) and $FFFF);
      for x := 0 to pred(Dst.Width) do
      begin
        t3 := xP shr 16;
        z  := xP and $FFFF;
        w2 := MulDiv(z, iz2, $10000);
        w1 := iz2 - w2;
        w4 := MulDiv(z, z2, $10000);
        w3 := z2 - w4;
        DstLine[x].rgbtRed := (SrcLine1[t3].rgbtRed * w1 +
          SrcLine1[t3 + 1].rgbtRed * w2 +
          SrcLine2[t3].rgbtRed * w3 + SrcLine2[t3 + 1].rgbtRed * w4) shr 16;
        DstLine[x].rgbtGreen :=
          (SrcLine1[t3].rgbtGreen * w1 + SrcLine1[t3 + 1].rgbtGreen * w2 +

          SrcLine2[t3].rgbtGreen * w3 + SrcLine2[t3 + 1].rgbtGreen * w4) shr 16;
        DstLine[x].rgbtBlue := (SrcLine1[t3].rgbtBlue * w1 +
          SrcLine1[t3 + 1].rgbtBlue * w2 +
          SrcLine2[t3].rgbtBlue * w3 +
          SrcLine2[t3 + 1].rgbtBlue * w4) shr 16;
        Inc(xP, xP2);
      end; {for}
      Inc(yP, yP2);
      DstLine := pRGBArray(Integer(DstLine) + DstGap);
    end; {for}
  end; {if}
end; {SmoothResize}

function TForm1.LoadJPEGPictureFile(Bitmap: TBitmap; FilePath, FileName: string): Boolean;
var
  JPEGImage: TJPEGImage;
begin
  Result := True;
  if (FileName = '') then    // No FileName so nothing
    Result := False  //to load - return False...
  else
  begin
    try  // Start of try except
      JPEGImage := TJPEGImage.Create;  // Create the JPEG image... try  // now
      try  // to load the file but
        JPEGImage.LoadFromFile(IncludeTrailingbackslash(FilePath) + FileName);
        // might fail...with an Exception.
        Bitmap.Assign(JPEGImage);
        // Assign the image to our bitmap.Result := True;
        // Got it so return True.
      finally
        JPEGImage.Free;  // ...must get rid of the JPEG image. finally
      end; {try}
    except
      Result := False; // Oops...never Loaded, so return False.
    end; {try}
  end; {if}
end; {LoadJPEGPictureFile}




function TForm1.SaveJPEGPictureFile(Bitmap: TBitmap; FilePath, FileName: string;
  Quality: Integer): Boolean;
begin
  Result := True;
  try
    if ForceDirectories(FilePath) then
    begin
      with TJPegImage.Create do
      begin
        try
          Assign(Bitmap);
          CompressionQuality := Quality;
          SaveToFile(FilePath + FileName);
        finally
          Free;
        end; {try}
      end; {with}
    end; {if}
  except
    raise;
    Result := False;
  end; {try}
end; {SaveJPEGPictureFile}


procedure TForm1.ResizeImage(OldFileName,NewFileName: string; NewWidth,NewHeight: Integer);
var
  OldBitmap: TBitmap;
  NewBitmap: TBitmap;
begin
  OldBitmap := TBitmap.Create;
  try
    if LoadJPEGPictureFile(OldBitmap, ExtractFilePath(OldFileName),
      ExtractFileName(OldFileName)) then
    begin
      NewBitmap := TBitmap.Create;
        try
          NewBitmap.Height := NewHeight;
          NewBitmap.Width := NewWidth;
          SmoothResize(OldBitmap, NewBitmap);
          if OldFileName=NewFileName then
             CopyFile(pchar(OldFileName),pchar(ChangeFileExt(OldFileName, '.$$$')),False);
          if SaveJPEGPictureFile(NewBitmap, ExtractFilePath(NewFileName),
            ExtractFileName(NewFileName), 75) then
               begin
                 if OldFileName=NewFileName then
                    DeleteFile(ChangeFileExt(OldFileName, '.$$$'));
               end
          else
               begin
                 if OldFileName=NewFileName then
                    RenameFile(ChangeFileExt(OldFileName, '.$$$'), OldFileName);
               end;
        finally
          NewBitmap.Free;
        end; {try}
      end; {if}
  finally
    OldBitmap.Free;
  end; {try}
end;


//Redimensionne en appliquant les règles paramétrées
procedure TForm1.ResizeOneFile(oldf,newf:string);
var oldwidth,oldheight:integer;
    newwidth,newheight:integer;
    x,y:word;
    Msg:string;
begin
//1) Récupérer la taille actuelle
   if not FileExists(oldf) then exit;
   if not JPEGDimensions(oldf,x,y) then exit;
   oldwidth:=x;
   oldheight:=y;
   if Not TryStrToInt(EditNewWidth.Text,newwidth) then  newwidth:=oldwidth;
   if Not TryStrToInt(EditNewHeight.Text,newheight) then  newheight:=oldheight;

//1) On commence par le width, il ne faut pas qu'il soit variable   
   if RadioGroupProportion.itemindex<2 then
      begin
         //Plus grand et on change
         if (oldwidth>=newwidth) and (RadioGroupBiggerWidth.itemindex=1) then
            newwidth:=StrToInt(EditNewWidth.Text);
         if (oldwidth>=newwidth) and (RadioGroupBiggerWidth.itemindex=0) then
            newwidth:=oldwidth;
         //Plus petit et on change
         if (oldwidth<newwidth) and (RadioGroupSmallerWidth.itemindex=1) then
            newwidth:=StrToInt(EditNewWidth.Text);
         if (oldwidth<newwidth) and (RadioGroupSmallerWidth.itemindex=0) then
            newwidth:=oldwidth;
      end;
//2) On traite le height, il ne faut pas qu'il soit variable      
   if RadioGroupProportion.itemindex<>1 then
      begin
         //Plus grand et on change
         if (oldheight>=newheight) and (RadioGroupBiggerHeight.itemindex=1) then
            newheight:=StrToInt(EditNewHeight.Text);
         if (oldheight>=newheight) and (RadioGroupBiggerHeight.itemindex=0) then
            newheight:=OldHeight;
         //Plus petit et on change            
         if (oldheight<newheight) and (RadioGroupSmallerHeight.itemindex=1) then
            newheight:=StrToInt(EditNewHeight.Text);
         if (oldheight<newheight) and (RadioGroupSmallerHeight.itemindex=0) then
            newheight:=OldHeight;
      end;      
//3) On traite le width variable   
   if RadioGroupProportion.itemindex=2 then
      begin
         newwidth:=MulDiv(newheight, oldWidth, oldHeight);
         //Plus grand et on garde
         if (oldwidth>=newwidth) and (RadioGroupBiggerWidth.itemindex=0) then
            newwidth:=oldwidth;
         //Plus petit et on garde
         if (oldwidth<newwidth) and (RadioGroupSmallerWidth.itemindex=0) then
            newwidth:=oldwidth;
      end;
//4) On traite le height variable
   if RadioGroupProportion.itemindex=1 then
      begin
         newheight:=MulDiv(newwidth, oldHeight, oldwidth);
         //Plus grand et on garde
         if (oldheight>=newheight) and (RadioGroupBiggerHeight.itemindex=0) then
            newheight:=oldheight;
         //Plus petit et on garde
         if (oldheight<newheight) and (RadioGroupSmallerHeight.itemindex=0) then
            newheight:=oldheight;
      end;
   Msg:='Resizing picture '+extractfilename(newf);
   if radiogrouplanguage.itemindex=1 then Msg:='Redimensionne '+extractfilename(newf);
   StaticText1.Caption:=Msg;
   Application.ProcessMessages;
   ResizeImage(oldf,newf,newwidth,newheight);
   Gauge1.Progress:=Gauge1.Progress+1;
   Application.ProcessMessages;   
end;

function TForm1.JPEGDimensions(Filename : string; var X, Y : word) : boolean;
var
  SegmentPos : Integer;
  SOIcount : Integer;
  b : byte;
begin
  Result  := False;
  with TFileStream.Create(Filename, fmOpenRead or fmShareDenyNone) do
  begin
    try
      Position := 0;
      Read(X, 2);
      if (X <> $D8FF) then
        exit;
      SOIcount  := 0;
      Position  := 0;
      while (Position + 7 < Size) do
      begin
        Read(b, 1);
        if (b = $FF) then begin
          Read(b, 1);
          if (b = $D8) then
            inc(SOIcount);
          if (b = $DA) then
            break;
        end; {if}
      end; {while}
      if (b <> $DA) then
        exit;
      SegmentPos  := -1;
      Position    := 0;
      while (Position + 7 < Size) do
      begin
        Read(b, 1);
        if (b = $FF) then
        begin
          Read(b, 1);
          if (b in [$C0, $C1, $C2]) then
          begin
            SegmentPos  := Position;
            dec(SOIcount);
            if (SOIcount = 0) then
              break;
          end; {if}
        end; {if}
      end; {while}
      if (SegmentPos = -1) then
        exit;
      if (Position + 7 > Size) then
        exit;
      Position := SegmentPos + 3;
      Read(Y, 2);
      Read(X, 2);
      X := Swap(X);
      Y := Swap(Y);
      Result  := true;
    finally
      Free;
    end; {try}
  end; {with}
end; {JPEGDimensions}


Function  TForm1.CountFilesInDir(Dir,ext:String):TContenuPath;
var sr:TSearchRec;
    FileAttrs:Integer;
    A:TContenuPath;
begin
   FileAttrs :=faAnyFile;
   Result.nbefile:=0;
   Result.nbedir:=0;
   if FindFirst(IncludeTrailingbackslash(Dir)+'*.*',FileAttrs,sr)=0 then
      begin
         repeat
            if ((sr.Attr and FileAttrs)>=0) and (sr.name<>'.') and (sr.name<>'..') then
               begin
                  If (sr.Attr and faDirectory)>0 then
                     begin
                        Result.nbedir:=1+Result.nbedir;
                        A:=CountFilesInDir(IncludeTrailingbackslash(Dir)+sr.Name,ext);
                        Result.nbefile:=Result.nbefile+A.nbeFile;
                        Result.nbedir:=Result.nbedir+A.nbedir;
                     end
                  Else
                     if (uppercase(ExtractFileExt(sr.Name))='.'+uppercase(ext)) then
                        Result.nbefile:=Result.nbefile+1;
               end;      
         until (FindNext(sr)<>0);
      end;
   FindClose(sr);
end;



Function  TForm1.GetParentDir(dir:String):String;
begin
   result:=excludetrailingbackslash(dir);
   while (result<>'') and (copy(result,length(result),1)<>'\') do
      result:=copy(result,1,length(result)-1);
   if (copy(result,length(result),1)<>'\') then result:=''
   else result:=copy(result,1,length(result)-1);
end;



Function  TForm1.ResizeFilesAndDir(Source,dest,ext:String):Boolean;
var sr:TSearchRec;
    FileAttrs:Integer;
    extension:String;
begin
   Result:=True;
   if uppercase(source)=uppercase(editdest.Text) then exit;
   If Not DirectoryExists(dest) then
      begin
         StaticText1.Caption:='Creating : '+dest;
         Result:=ForceDirectories(lowercase(dest));
      end;
   If Not result then Exit;

   FileAttrs :=faAnyFile;
   if FindFirst(IncludeTrailingbackslash(Source)+'*.*',FileAttrs,sr)=0 then
      begin
         repeat
            if ((sr.Attr and FileAttrs)>0) and (sr.name<>'.') and (sr.name<>'..') and (sr.name<>'_history') then
               begin
                  If (sr.Attr and faDirectory)>0 then
                     begin
                         Result:=Result and ResizeFilesAndDir(IncludeTrailingbackslash(Source)+sr.Name,IncludeTrailingbackslash(dest)+sr.Name,ext);
                     end
                  Else if (uppercase(ExtractFileExt(sr.Name))='.'+uppercase(ext)) then
                     begin
                        statictext1.Caption:='Resizing file to '+IncludeTrailingbackslash(dest)+sr.Name;
                        ResizeOneFile(IncludeTrailingbackslash(Source)+sr.Name,IncludeTrailingbackslash(dest)+sr.Name);
                        Gauge1.Progress:=Gauge1.Progress+1;
                     end;
               end;
         until (FindNext(sr)<>0);
      end;
   FindClose(sr);
end;


procedure TForm1.ChangeLanguage(id:integer);
begin
   if (id=0) then
      begin
         Caption:='Batch JPEG Files resizer';
         GroupBoxsourcefolder.Caption:='Source Folder';
         GroupBoxdestfolder.Caption:='Destination Folder';
         ButtonsourceExplore.Hint:='Explore';
         ButtondestExplore.Hint:='Explore';
         Buttontrt.Caption:='Start';
         GroupBoxRules.Caption:='Rules';
         RadioGroupProportion.Caption:='Proportionnal master';
         RadioGroupProportion.Items[0]:='None (force resize both)';
         RadioGroupProportion.Items[1]:='Width, but keep proportions';
         RadioGroupProportion.Items[2]:='Height, but keep proportions';
         GroupboxWidth.Caption:='Width';
         GroupboxHeight.Caption:='Height';
         Labelnewwidth.Caption:='New Width';
         LabelNewHeight.Caption:='New Height';
         CheckBoxUnchangeWidth.Caption:='Keep Unchanged';
         RadioGroupBiggerWidth.Caption:='If bigger or equal';
         RadioGroupBiggerWidth.Items[0]:='Keep Unchanged';
         RadioGroupBiggerWidth.Items[1]:='Resize';
         RadioGroupSmallerWidth.Caption:='If smaller';
         RadioGroupSmallerWidth.Items[0]:='Keep Unchanged';
         RadioGroupSmallerWidth.Items[1]:='Resize';
         RadioGroupBiggerHeight.Caption:='If bigger or equal';
         RadioGroupBiggerHeight.Items[0]:='Keep Unchanged';
         RadioGroupBiggerHeight.Items[1]:='Resize';
         RadioGroupSmallerHeight.Caption:='If smaller';
         RadioGroupSmallerHeight.Items[0]:='Keep Unchanged';
         RadioGroupSmallerHeight.Items[1]:='Resize';
         RadioGroupLanguage.Items[0]:='English';
         RadioGroupLanguage.Items[1]:='French';
         CheckBoxUnchangeHeight.Caption:='Keep Unchanged';
      end;
   if (id=1) then
      begin
         Caption:='Redimensionnement de masse de fichiers JPEG';
         GroupBoxsourcefolder.Caption:='Dossier source';
         GroupBoxdestfolder.Caption:='Dossier de destination';
         ButtonsourceExplore.Hint:='Explorer';
         ButtondestExplore.Hint:='Explorer';
         Buttontrt.Caption:='Démarrer';
         GroupBoxRules.Caption:='Règles';
         RadioGroupProportion.Caption:='Règles de proportions';
         RadioGroupProportion.Items[0]:='Aucune (redimensionnement en largeur et hauteur)';
         RadioGroupProportion.Items[1]:='Largeur, calculer une hauteur proportionnelle';
         RadioGroupProportion.Items[2]:='Hauteur, calculer une largeur proportionnelle';
         GroupboxWidth.Caption:='Largeur';
         GroupboxHeight.Caption:='Hauteur';
         Labelnewwidth.Caption:='Nouvelle largeur';
         LabelNewHeight.Caption:='Nouvelle hauteur';
         CheckBoxUnchangeWidth.Caption:='Garder la valeur d''origine';
         RadioGroupBiggerWidth.Caption:='Si valeur d''origine>=';
         RadioGroupBiggerWidth.Items[0]:='Ne pas modifier';
         RadioGroupBiggerWidth.Items[1]:='Redimensionner';
         RadioGroupSmallerWidth.Caption:='Si valeur d''origine<';
         RadioGroupSmallerWidth.Items[0]:='Ne pas modifier';
         RadioGroupSmallerWidth.Items[1]:='Redimensionner';
         RadioGroupBiggerHeight.Caption:='Si valeur d''origine>=';
         RadioGroupBiggerHeight.Items[0]:='Ne pas modifier';
         RadioGroupBiggerHeight.Items[1]:='Redimensionner';
         RadioGroupSmallerHeight.Caption:='Si valeur d''origine<';
         RadioGroupSmallerHeight.Items[0]:='Ne pas modifier';
         RadioGroupSmallerHeight.Items[1]:='Redimensionner';
         CheckBoxUnchangeHeight.Caption:='Garder la valeur d''origine';
         RadioGroupLanguage.Items[0]:='Anglais';
         RadioGroupLanguage.Items[1]:='Français';

      end;
end;

end.
