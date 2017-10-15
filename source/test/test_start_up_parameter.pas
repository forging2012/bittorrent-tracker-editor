unit test_start_up_parameter;

{
  Tracker Editor can be started via parameter.
  The working of these parameter must be tested.

  ------------------------------------
  There are 4 txt files that are being used for this test
  All these files are place in the same folder as the executable files

  List of all the trackers that must added.
  add_trackers.txt

  remove_trackers.txt
  List of all the trackers that must removed
  note: if the file is empty then all trackers from the present torrent will be REMOVED.
  note: if the file is not present then no trackers will be automatic removed.

  Check if the program is working as expected:
  log.txt is only created in console mode.
  Show the in console mode the success/failure of the torrent update.
  First line status: 'OK' or 'ERROR: xxxxxxx' xxxxxxx = error description
  Second line files count: '1'
  Third line tracker count: 23
  Second and third line info are only valid if the first line is 'OK'

  Check what the torrent output is:
  export_trackers.txt

}

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, fpcunit, testregistry, newtrackon, torrent_miscellaneous,
  test_miscellaneous;

type

  { TTestStartUpParameter }

  TTestStartUpParameter = class(TTestCase)
  private
    FFullPathToRoot: string;
    FFullPathToTorrent: string;
    FFullPathToEndUser: string;
    FFullPathToBinary: string;

    FTorrentFilesNameStringList: TStringList;
    FNewTrackon: TNewTrackon;
    FVerifyTrackerResult: TVerifyTrackerResult;
    FExitCode: integer;
    FCommandLine: string;

    procedure TestParameter(TrackerListOrder: TTrackerListOrder);
    procedure DownloadPreTestTrackerList;
    procedure LoadTrackerListAddAndRemoved;
    procedure CallExecutableFile;
    procedure CopyTrackerEndResultToVerifyTrackerResult;
    procedure CreateEmptyTorrent(TrackerListOrder: TTrackerListOrder);
    procedure TestEmptyTorrentResult;
    procedure CreateFilledTorrent(TrackerListOrder: TTrackerListOrder);
    procedure DownloadNewTrackonTrackers;
    procedure Test_Paramater_Ux(TrackerListOrder: TTrackerListOrder);

  protected
    procedure SetUp; override;
    procedure TearDown; override;
  published
    procedure Test_Create_Empty_DHT_torrent;
    procedure Test_Create_Simple_Filled_torrent;
    procedure Test_Create_Filled_And_Empty_Torrent_All_Mode;

    procedure Test_Paramater_U0;
    procedure Test_Paramater_U1;
    procedure Test_Paramater_U2;
    procedure Test_Paramater_U3;
    procedure Test_Paramater_U4;
    procedure Test_Paramater_U5_TODO;
    procedure Test_Paramater_U6_TODO;
    procedure Test_Paramater_U7;

  end;

implementation

uses  LazUTF8;

const
  PROGRAME_TO_BE_TESTED_NAME = 'trackereditor';
  TORRENT_FOLDER = 'test_torrent';
  END_USER_FOLDER = 'enduser';

procedure TTestStartUpParameter.Test_Paramater_U0;
begin
  Test_Paramater_Ux(tloInsertNewBeforeAndKeepNewIntact);
end;

procedure TTestStartUpParameter.Test_Paramater_U1;
begin
  Test_Paramater_Ux(tloInsertNewBeforeAndKeepOriginalIntact);
end;

procedure TTestStartUpParameter.Test_Paramater_U2;
begin
  Test_Paramater_Ux(tloAppendNewAfterAndKeepNewIntact);
end;

procedure TTestStartUpParameter.Test_Paramater_U3;
begin
  Test_Paramater_Ux(tloAppendNewAfterAndKeepOriginalIntact);
end;

procedure TTestStartUpParameter.Test_Paramater_U4;
begin
  Test_Paramater_Ux(tloSort);
end;

procedure TTestStartUpParameter.Test_Paramater_U5_TODO;
begin
  //TODO: Must check every torrent file one by one
  //Test_Paramater_Ux(tloInsertNewBeforeAndKeepOriginalIntactAndRemoveNothing);
end;

procedure TTestStartUpParameter.Test_Paramater_U6_TODO;
begin
  //TODO: Must check every torrent file one by one
  //Test_Paramater_Ux(tloAppendNewAfterAndKeepOriginalIntactAndRemoveNothing);
end;

procedure TTestStartUpParameter.Test_Paramater_U7;
begin
  Test_Paramater_Ux(tloRandomize);
end;

procedure TTestStartUpParameter.TestParameter(TrackerListOrder: TTrackerListOrder);
begin
  FVerifyTrackerResult.TrackerListOrder := TrackerListOrder;

  //Fill in the command line parameter '-Ux', x = number
  FCommandLine := format('%s -U%d', [FFullPathToTorrent, Ord(TrackerListOrder)]);
end;

procedure TTestStartUpParameter.DownloadPreTestTrackerList;
begin
  DownloadNewTrackonTrackers;

  //copy all the download to txt file.

  //TrackerList_All have all the trackers available
  FNewTrackon.TrackerList_All.SaveToFile(FFullPathToEndUser + FILE_NAME_ADD_TRACKERS);

  //TrackerList_Dead must remove the dead one.
  FNewTrackon.TrackerList_Dead.SaveToFile(FFullPathToEndUser +
    FILE_NAME_REMOVE_TRACKERS);

end;

procedure TTestStartUpParameter.LoadTrackerListAddAndRemoved;
begin
  FVerifyTrackerResult.TrackerAdded.LoadFromFile(FFullPathToEndUser +
    FILE_NAME_ADD_TRACKERS);

  FVerifyTrackerResult.TrackerRemoved.LoadFromFile(FFullPathToEndUser +
    FILE_NAME_REMOVE_TRACKERS);
end;

procedure TTestStartUpParameter.CallExecutableFile;
begin
  //start the. This will return the Exit code
  FExitCode := SysUtils.ExecuteProcess(UTF8ToSys(FFullPathToBinary), FCommandLine, []);
end;

procedure TTestStartUpParameter.CopyTrackerEndResultToVerifyTrackerResult;
begin
  FVerifyTrackerResult.TrackerEndResult.LoadFromFile(FFullPathToEndUser +
    FILE_NAME_EXPORT_TRACKERS);

  //remove empty space
  RemoveLineSeperation(FVerifyTrackerResult.TrackerEndResult);

end;

procedure TTestStartUpParameter.CreateEmptyTorrent(
  TrackerListOrder: TTrackerListOrder);
begin
  //write a empty remove trackers
  FVerifyTrackerResult.TrackerRemoved.Clear;
  FVerifyTrackerResult.TrackerRemoved.SaveToFile(FFullPathToEndUser +
    FILE_NAME_REMOVE_TRACKERS);

  //write a empty add trackers
  FVerifyTrackerResult.TrackerAdded.Clear;
  FVerifyTrackerResult.TrackerAdded.SaveToFile(FFullPathToEndUser +
    FILE_NAME_ADD_TRACKERS);

  //Generate the command line parameter
  TestParameter(TrackerListOrder);

  //call the tracker editor exe file
  CallExecutableFile;
end;

procedure TTestStartUpParameter.TestEmptyTorrentResult;
begin
  //Copy test result into FVerifyTrackerResult
  CopyTrackerEndResultToVerifyTrackerResult;

  Check(FVerifyTrackerResult.TrackerEndResult.Count = 0,
    'The tracker list should be empty.');
end;

procedure TTestStartUpParameter.CreateFilledTorrent(TrackerListOrder: TTrackerListOrder);
begin
  DownloadNewTrackonTrackers;

  //write a empty remove trackers
  FVerifyTrackerResult.TrackerRemoved.Clear;
  FVerifyTrackerResult.TrackerRemoved.SaveToFile(FFullPathToEndUser +
    FILE_NAME_REMOVE_TRACKERS);

  //write a some trackers to add. This
  FVerifyTrackerResult.TrackerAdded.Clear;
  FVerifyTrackerResult.TrackerAdded.Add('udp://1.test/announce');

  //Add one torrent that later will be removed
  if FNewTrackon.TrackerList_Dead.Count > 0 then
  begin
    FVerifyTrackerResult.TrackerAdded.Add(FNewTrackon.TrackerList_Dead[0]);
  end;

  //Add one torrent that that must may be removed
  if FNewTrackon.TrackerList_Live.Count > 0 then
  begin
    FVerifyTrackerResult.TrackerAdded.Add(FNewTrackon.TrackerList_Live[0]);
  end;

  FVerifyTrackerResult.TrackerAdded.Add('udp://2.test/announce');
  FVerifyTrackerResult.TrackerAdded.SaveToFile(FFullPathToEndUser +
    FILE_NAME_ADD_TRACKERS);

  //Generate the command line parameter
  TestParameter(TrackerListOrder);

  //call the tracker editor exe file
  CallExecutableFile;

  //Copy test result into FVerifyTrackerResult
  CopyTrackerEndResultToVerifyTrackerResult;

  Check(FVerifyTrackerResult.TrackerEndResult.Count =
    FVerifyTrackerResult.TrackerAdded.Count,
    'TrackerEndResult should have the same count as TrackerAdded');

  //For the next test load the present content inside the torrent
  FVerifyTrackerResult.TrackerOriginal.Assign(FVerifyTrackerResult.TrackerAdded);

end;

procedure TTestStartUpParameter.DownloadNewTrackonTrackers;
begin
  Check(FNewTrackon.DownloadTrackers, 'Download Newtrackon failed');
end;

procedure TTestStartUpParameter.Test_Paramater_Ux(TrackerListOrder: TTrackerListOrder);

var
  OK: boolean;
begin
  //Create a torrent with fix torrent items
  //this is the pre test condition
  CreateFilledTorrent(tloInsertNewBeforeAndKeepNewIntact);

  //Download all the trackers .txt files
  DownloadPreTestTrackerList;

  //load all the txt file into memory
  LoadTrackerListAddAndRemoved;

  //Generate the command line parameter
  TestParameter(TrackerListOrder);

  //call the tracker editor exe file
  CallExecutableFile;

  //Copy test result into FVerifyTrackerResult
  CopyTrackerEndResultToVerifyTrackerResult;

  //check if the test result is correct
  OK := VerifyTrackerResult(FVerifyTrackerResult);
  Check(OK, FVerifyTrackerResult.ErrorString);

  //check the exit code
  CheckEquals(0, FExitCode);
end;

procedure TTestStartUpParameter.Test_Create_Empty_DHT_torrent;
begin
  CreateEmptyTorrent(tloInsertNewBeforeAndKeepNewIntact);
  TestEmptyTorrentResult;
end;

procedure TTestStartUpParameter.Test_Create_Simple_Filled_torrent;
begin
  CreateFilledTorrent(tloInsertNewBeforeAndKeepNewIntact);
end;

procedure TTestStartUpParameter.Test_Create_Filled_And_Empty_Torrent_All_Mode;
var
  TrackerListOrder: TTrackerListOrder;
begin
  //Test if all the mode that support empty torrent creation
  for TrackerListOrder in TTrackerListOrder do
  begin

    //todo: Is this by design that empty torrent is here rejected?
    if TrackerListOrder = tloInsertNewBeforeAndKeepOriginalIntactAndRemoveNothing then
      continue;

    //todo: Is this by design that empty torrent is here rejected?
    if TrackerListOrder = tloAppendNewAfterAndKeepOriginalIntactAndRemoveNothing then
      continue;

    CreateEmptyTorrent(TrackerListOrder);
    TestEmptyTorrentResult;
    CreateFilledTorrent(TrackerListOrder);
  end;
end;

procedure TTestStartUpParameter.SetUp;
begin
  //Create all the TStringList items
  FVerifyTrackerResult.TrackerOriginal := TStringList.Create;
  FVerifyTrackerResult.TrackerAdded := TStringList.Create;
  FVerifyTrackerResult.TrackerRemoved := TStringList.Create;
  FVerifyTrackerResult.TrackerEndResult := TStringList.Create;

  //Create some full path link
  FFullPathToRoot := GetProjectRootFolderWithPathDelimiter;
  FFullPathToTorrent := FFullPathToRoot + TORRENT_FOLDER + PathDelim;
  FFullPathToEndUser := FFullPathToRoot + END_USER_FOLDER + PathDelim;

  //fill with torrent file(s)
  FTorrentFilesNameStringList := TStringList.Create;
  torrent_miscellaneous.LoadTorrentViaDir(FFullPathToTorrent,
    FTorrentFilesNameStringList);

  FNewTrackon := TNewTrackon.Create;

  //path to the programe we want to test.
  FFullPathToBinary := FFullPathToEndUser + PROGRAME_TO_BE_TESTED_NAME +
    ExtractFileExt(ParamStr(0));

  //Delete all the previeus test result
  DeleteFile(FFullPathToEndUser + FILE_NAME_CONSOLE_LOG);
  DeleteFile(FFullPathToEndUser + FILE_NAME_EXPORT_TRACKERS);
  DeleteFile(FFullPathToEndUser + FILE_NAME_ADD_TRACKERS);
  DeleteFile(FFullPathToEndUser + FILE_NAME_REMOVE_TRACKERS);

end;

procedure TTestStartUpParameter.TearDown;
begin
  //Free the TStringList items
  FVerifyTrackerResult.TrackerOriginal.Free;
  FVerifyTrackerResult.TrackerAdded.Free;
  FVerifyTrackerResult.TrackerRemoved.Free;
  FVerifyTrackerResult.TrackerEndResult.Free;


  FTorrentFilesNameStringList.Free;
  FNewTrackon.Free;
end;


initialization

  RegisterTest(TTestStartUpParameter);
end.
