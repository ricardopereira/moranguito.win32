unit Moranguito.FormGUI;

interface

uses
  Classes, SysUtils, Moranguito.Controller,
  Windows, Controls, Forms;

type
  TMoranguitoFormGUIClass = class of TMoranguitoFormGUI;
  TMoranguitoFormGUI = class(TForm)
  private
    FOnRelease: TThreadProcedure;
  public
    destructor Destroy; override;
    procedure Init; virtual;
    procedure Reset; virtual;
    procedure ShowParented(AParent: TWinControl);
    property OnRelease: TThreadProcedure read FOnRelease write FOnRelease;
  end;

implementation

{ TMoranguitoFormGUI }

destructor TMoranguitoFormGUI.Destroy;
begin
  if Assigned(FOnRelease) then FOnRelease;
  inherited;
end;

procedure TMoranguitoFormGUI.Init;
begin

end;

procedure TMoranguitoFormGUI.Reset;
begin

end;

procedure TMoranguitoFormGUI.ShowParented(AParent: TWinControl);
begin
  if AParent = nil then Exit;
  Parent:= AParent;
  Align:= alClient;
  BorderStyle:= bsNone;
  Show;
end;

end.
