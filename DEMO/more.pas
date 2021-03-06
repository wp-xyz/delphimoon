unit More;
(*@/// interface *)
interface

(*@/// uses *)
uses
  SysUtils, WinTypes, WinProcs, Messages, Classes, Graphics, Controls,
  Forms, Dialogs, ExtCtrls, StdCtrls, Spin,
  ah_tool,
  moon, main, location, ComCtrls;
(*@\\\000000040B*)

type
  (*@/// Tfrm_more = class(TForm) *)
  Tfrm_more = class(TForm)
    val_latitude: TLabel;
    val_longitude: TLabel;
    lbl_latitude: TLabel;
    lbl_longitude: TLabel;
    cbx_location: TCombobox;
    lbl_location: TLabel;
    Timer: TTimer;
    page: TPageControl;
    page_sun: TTabSheet;
    page_moon: TTabSheet;
    page_calendar: TTabSheet;
    lbl_easter: TLabel;
    val_easter: TLabel;
    lbl_pesach: TLabel;
    val_pesach: TLabel;
    lbl_chinese: TLabel;
    val_chinese: TLabel;
    lbl_easter_julian: TLabel;
    val_easter_julian: TLabel;
    lbl_moonrise: TLabel;
    lbl_moontransit: TLabel;
    lbl_moonset: TLabel;
    val_moonrise: TLabel;
    val_moontransit: TLabel;
    val_moonset: TLabel;
    lbl_mooneclipse: TLabel;
    val_mooneclipse: TLabel;
    typ_mooneclipse: TLabel;
    lbl_perigee: TLabel;
    val_perigee: TLabel;
    lbl_apogee: TLabel;
    val_apogee: TLabel;
    saros_mooneclipse: TLabel;
    lbl_sunrise: TLabel;
    lbl_suntransit: TLabel;
    lbl_sunset: TLabel;
    val_sunrise: TLabel;
    val_suntransit: TLabel;
    val_sunset: TLabel;
    lbl_perihel: TLabel;
    val_perihel: TLabel;
    lbl_aphel: TLabel;
    val_aphel: TLabel;
    lbl_suneclipse: TLabel;
    val_suneclipse: TLabel;
    typ_suneclipse: TLabel;
    saros_suneclipse: TLabel;
    lbl_spring: TLabel;
    lbl_summer: TLabel;
    lbl_autumn: TLabel;
    lbl_winter: TLabel;
    val_spring: TLabel;
    val_summer: TLabel;
    val_autumn: TLabel;
    val_winter: TLabel;
    lbl_sun_rektaszension: TLabel;
    val_sun_rektaszension: TLabel;
    lbl_sun_declination: TLabel;
    val_sun_declination: TLabel;
    val_sun_zodiac: TLabel;
    lbl_moon_rektaszension: TLabel;
    lbl_moon_declination: TLabel;
    val_moon_rektaszension: TLabel;
    val_moon_declination: TLabel;
    val_moon_zodiac: TLabel;
    procedure FormShow(Sender: TObject);
    procedure locationChange(Sender: TObject);
    procedure FormHide(Sender: TObject);
    procedure FormCreate(Sender: TObject);
  private
    locations: TList;
    first_now: TDateTime;
  public
    start_time: TDateTime;
    procedure SetLanguage(Sender: TObject);
  end;
  (*@\\\0000003B05*)

var
  frm_more: Tfrm_more;
(*@\\\0000000801*)
(*@/// implementation *)
implementation

(*@/// function rektaszension2string(x:extended):string; *)
function rektaszension2string(x:extended):string;
var
  h,m,s: integer;
begin
  if x<0 then
    x:=x+360;
  x:=round(abs(x)*3600/15);
  s:=round(x) mod 60;
  m:=round((x-s)/60) mod 60;
  h:=round((x-s-m*60)/3600);
  result:=inttostr(h)+'h '+
          inttostr(m)+'m '+
          inttostr(s)+'s';
  end;
(*@\\\0000000D25*)


{$R *.DFM}
(*$i moontool.inc *)

var
  ChineseZodiac: array[TChineseZodiac] of string;

(*@/// procedure Tfrm_more.FormHide(Sender: TObject); *)
procedure Tfrm_more.FormHide(Sender: TObject);
begin
  save_locations(moontool_inifile,locations,cbx_location.itemindex);
  if locations<>NIL then begin
    while locations.count>0 do begin
      TObject(locations[0]).free;
      locations.delete(0);
      end;
    end;
  locations.free;
  locations:=NIL;
  end;
(*@\\\0000000322*)
(*@/// procedure Tfrm_more.FormShow(Sender: TObject); *)
procedure Tfrm_more.FormShow(Sender: TObject);
var
  current, i: integer;
begin
  load_locations(moontool_inifile,locations,current);
  cbx_location.items.clear;
  for i:=0 to locations.count-1 do
    cbx_location.items.add(TLocation(locations[i]).name);
  cbx_location.itemindex:=current;
  locationChange(NIL);
  end;
(*@\\\0000000B03*)
(*@/// procedure Tfrm_more.locationChange(Sender: TObject); *)
procedure Tfrm_more.locationChange(Sender: TObject);
var
  y,m,d: word;
  jetzt,jetzt2: TDateTime;
  date: TDateTime;
  j: longint;
  eclipse_value: TEclipseData;
  longitude, latitude: extended;
  rektaszension, declination: extended;
  chinese: TChineseDate;
  z: TZodiac;
begin
  jetzt:=start_time+(now-first_now)+TimeZoneBias/(60*24);

  DecodeDate(jetzt,y,m,d);
  (*@/// seasons *)
  { recalculate and show data }
  try
    val_spring.caption:=datestring(StartSeason(y,spring));
    val_summer.caption:=datestring(StartSeason(y,summer));
    val_autumn.caption:=datestring(StartSeason(y,autumn));
    val_winter.caption:=datestring(StartSeason(y,winter));
  except
    val_spring.caption:=LoadStr(SOutOfRange);
    val_summer.caption:=LoadStr(SOutOfRange);
    val_autumn.caption:=LoadStr(SOutOfRange);
    val_winter.caption:=LoadStr(SOutOfRange);
    end;
  lbl_spring.hint:='';
  lbl_summer.hint:='';
  lbl_autumn.hint:='';
  lbl_winter.hint:='';
  (*@\\\0000000D01*)
  val_perigee.caption:=datestring(NextPeriGee(jetzt));
  val_apogee.caption:=datestring(NextApoGee(jetzt));
  val_perihel.caption:=datestring(NextPerihel(jetzt));
  val_aphel.caption:=datestring(NextAphel(jetzt));
  (*@/// Sun eclipse *)
  jetzt2:=jetzt;
  eclipse_value:=NextEclipseEx(jetzt2,true);
  val_suneclipse.caption:=datestring(eclipse_value.date);
  case eclipse_value.eclipsetype of
    none, halfshadow: typ_suneclipse.caption:=LoadStr(SEclipseNone);
    partial:          typ_suneclipse.caption:=LoadStr(SEclipsePartial);
    total:            typ_suneclipse.caption:=LoadStr(SEclipseTotal);
    circular:         typ_suneclipse.caption:=LoadStr(SEclipseCircular);
    circulartotal:    typ_suneclipse.caption:=LoadStr(SEclipseCircularTotal);
    noncentral:       typ_suneclipse.caption:=LoadStr(SEclipseNonCentral);
    end;
  saros_suneclipse.caption:=exchange_s('%1%',inttostr(eclipse_value.saros),
                            exchange_s('%2%',inttostr(eclipse_value.inex),
                            exchange_s('%3%',inttostr(eclipse_value.sarosnumber),
                            LoadStr(SSaros))));

  (*@\\\000C000201000201*)
  (*@/// Moon eclipse *)
  jetzt2:=jetzt;
  eclipse_value:=NextEclipseEx(jetzt2,false);
  val_mooneclipse.caption:=datestring(eclipse_value.date);
  case eclipse_value.eclipsetype of
    none:             typ_mooneclipse.caption:=LoadStr(SEclipseNone);
    partial:          typ_mooneclipse.caption:=LoadStr(SEclipsePartial);
    total:            typ_mooneclipse.caption:=LoadStr(SEclipseTotal);
    halfshadow:       typ_mooneclipse.caption:=LoadStr(SEclipseHalfshadow);
  {   circular:         typ_mooneclipse.caption:=LoadStr(SEclipseCircular); }
  {   circulartotal:    typ_mooneclipse.caption:=LoadStr(SEclipseCircularTotal); }
  {   noncentral:       typ_mooneclipse.caption:=LoadStr(SEclipseNonCentral); }
    end;
  saros_mooneclipse.caption:=exchange_s('%1%',inttostr(eclipse_value.saros),
                            exchange_s('%2%',inttostr(eclipse_value.inex),
                            exchange_s('%3%',inttostr(eclipse_value.sarosnumber),
                            LoadStr(SSaros))));
  (*@\\\0030000201000201*)
  val_easter.caption:=formatdatetime('d mmmm yyyy',FalsifyTDateTime(Easterdate(y)));
  val_easter_julian.caption:=formatdatetime('d mmmm yyyy',FalsifyTDateTime(EasterdateJulian(y)));
  val_pesach.caption:=formatdatetime('d mmmm yyyy',FalsifyTDateTime(Pesachdate(y)));
  date:=ChineseNewYear(y);
  chinese:=ChineseDate(date);
  val_chinese.caption:=formatdatetime('d mmmm yyyy',FalsifyTDateTime(date))+
    ' ('+ChineseZodiac[chinese.yearcycle.zodiac]+')';

  (*@/// make rise/set/transit fields empty *)
  val_moonrise.caption:='---';
  val_moontransit.caption:='---';
  val_moonset.caption:='---';
  val_sunrise.caption:='---';
  val_suntransit.caption:='---';
  val_sunset.caption:='---';
  (*@\\\*)
  (*@/// location *)
  j:=cbx_location.itemindex;
  if j=-1 then  EXIT;
  if locations<>NIL then begin
    longitude:=TLocation(locations.items[j]).longitude;
    latitude :=TLocation(locations.items[j]).latitude;
    end
  else begin
    longitude:=0;
    latitude :=0;
    end;
  val_longitude.caption:=degree2string(abs(longitude));
  if longitude>=0 then
    val_longitude.caption:=val_longitude.caption+' '+LoadStr(SWest)
  else
    val_longitude.caption:=val_longitude.caption+' '+LoadStr(SEast);
  val_latitude.caption:=degree2string(abs(latitude));
  if latitude>=0 then
    val_latitude.caption:=val_latitude.caption+' '+LoadStr(SNorth)
  else
    val_latitude.caption:=val_latitude.caption+' '+LoadStr(SSouth);
  (*@\\\*)
  (*@/// season hints accoring to location *)
  if latitude>0 then begin
    lbl_spring.hint:=LoadStr(SSpringHint);
    lbl_summer.hint:=LoadStr(SSommerHint);
    lbl_autumn.hint:=LoadStr(SAutumnHint);
    lbl_winter.hint:=LoadStr(SWinterHint);
    end
  else begin
    lbl_autumn.hint:=LoadStr(SSpringHint);
    lbl_winter.hint:=LoadStr(SSommerHint);
    lbl_spring.hint:=LoadStr(SAutumnHint);
    lbl_summer.hint:=LoadStr(SWinterHint);
    end;
  (*@\\\*)
  (*@/// calc rise/set/transit *)
  j:=trunc(jetzt);
  try
    (*@/// date:=Moon_Rise(j,latitude,longitude); *)
    date:=Moon_Rise(j,latitude,longitude);
    if trunc(date)<j then
      date:=Moon_Rise(j+1,latitude,longitude);
    if trunc(date)>j then
      date:=Moon_Rise(j-1,latitude,longitude);
    if trunc(date)<>j then
      val_moonrise.caption:='---'
    else
      val_moonrise.caption:=datestring(date);
    (*@\\\*)
    (*@/// date:=Moon_Transit(j,latitude,longitude); *)
    date:=Moon_Transit(j,latitude,longitude);
    if trunc(date)<j then
      date:=Moon_Transit(j+1,latitude,longitude);
    if trunc(date)>j then
      date:=Moon_Transit(j-1,latitude,longitude);
    if trunc(date)<>j then
      val_moontransit.caption:='---'
    else
      val_moontransit.caption:=datestring(date);
    (*@\\\000000092D*)
    (*@/// date:=Moon_Set(j,latitude,longitude); *)
    date:=Moon_Set(j,latitude,longitude);
    if trunc(date)<j then
      date:=Moon_Set(j+1,latitude,longitude);
    if trunc(date)>j then
      date:=Moon_Set(j-1,latitude,longitude);
    if trunc(date)<>j then
      val_moonset.caption:='---'
    else
      val_moonset.caption:=datestring(date);
    (*@\\\0000000929*)
  except
    end;
  z:=MoonZodiac(jetzt);
  val_moon_zodiac.caption:=char(ord('^')+ord(z));
  val_moon_zodiac.hint:=LoadStr(SAries+ord(z));
  Moon_Position_Equatorial(jetzt,rektaszension,declination);
  val_moon_declination.caption:=degree2string(declination);
  val_moon_rektaszension.caption:=rektaszension2string(rektaszension);
  z:=SunZodiac(jetzt);
  val_sun_zodiac.caption:=char(ord('^')+ord(z));
  Sun_Position_Equatorial(jetzt,rektaszension,declination);
  val_sun_zodiac.hint:=LoadStr(SAries+ord(z));
  val_sun_declination.caption:=degree2string(declination);
  val_sun_rektaszension.caption:=rektaszension2string(rektaszension);
  try
    (*@/// date:=Sun_Rise(j,latitude,longitude); *)
    date:=Sun_Rise(j,latitude,longitude);
    if trunc(date)<j then
      date:=Sun_Rise(j+1,latitude,longitude);
    if trunc(date)>j then
      date:=Sun_Rise(j-1,latitude,longitude);
    if trunc(date)<>j then
      val_sunrise.caption:='---'
    else
      val_sunrise.caption:=datestring(date);
    (*@\\\*)
    (*@/// date:=Sun_Transit(j,latitude,longitude); *)
    date:=Sun_Transit(j,latitude,longitude);
    if trunc(date)<j then
      date:=Sun_Transit(j+1,latitude,longitude);
    if trunc(date)>j then
      date:=Sun_Transit(j-1,latitude,longitude);
    if trunc(date)<>j then
      val_suntransit.caption:='---'
    else
      val_suntransit.caption:=datestring(date);
    (*@\\\*)
    (*@/// date:=Sun_Set(j,latitude,longitude); *)
    date:=Sun_Set(j,latitude,longitude);
    if trunc(date)<j then
      date:=Sun_Set(j+1,latitude,longitude);
    if trunc(date)>j then
      date:=Sun_Set(j-1,latitude,longitude);
    if trunc(date)<>j then
      val_sunset.caption:='---'
    else
      val_sunset.caption:=datestring(date);
    (*@\\\0000000917*)
  except
    end;
  (*@\\\0000000307*)
  end;
(*@\\\0002001401001401*)
(*@/// procedure Tfrm_more.FormCreate(Sender: TObject); *)
procedure Tfrm_more.FormCreate(Sender: TObject);
begin
  start_time:=now;
  first_now:=now;
  helpcontext:=hc_moredata;
  SetLanguage(NIL);
  end;
(*@\\\0000000601*)
(*@/// procedure Tfrm_more.SetLanguage(Sender: TObject); *)
procedure Tfrm_more.SetLanguage(Sender: TObject);
const
  offset = 10;
var
  pos_x, pos_x_2, i: integer;
  z: TChineseZodiac;
begin
  self           .caption := LoadStr(SMoreData);
  lbl_latitude   .caption := LoadStr(SLatitude);
  lbl_longitude  .caption := LoadStr(SLongitude);
  lbl_spring     .caption := LoadStr(SSpring);
  lbl_summer     .caption := LoadStr(SSummer);
  lbl_autumn     .caption := LoadStr(SAutumn);
  lbl_winter     .caption := LoadStr(SWinter);
  lbl_sunrise    .caption := LoadStr(SSunRise);
  lbl_suntransit .caption := LoadStr(SSunTransit);
  lbl_sunset     .caption := LoadStr(SSunSet);
  lbl_moonrise   .caption := LoadStr(SMoonRise);
  lbl_moontransit.caption := LoadStr(SMoonTransit);
  lbl_moonset    .caption := LoadStr(SMoonSet);
  lbl_location   .caption := LoadStr(SLocation);
  lbl_perigee    .caption := LoadStr(SPerigee);
  lbl_apogee     .caption := LoadStr(SApogee);
  lbl_perihel    .caption := LoadStr(SPerihel);
  lbl_aphel      .caption := LoadStr(SAphel);
  lbl_mooneclipse.caption := LoadStr(SMoonEclipse);
  lbl_suneclipse .caption := LoadStr(SSunEclipse);
  lbl_easter     .caption := LoadStr(SEasterDate);
  lbl_pesach     .caption := LoadStr(SPesachDate);
  lbl_chinese    .caption := LoadStr(SChineseNewYear);
  lbl_easter_julian.caption:=LoadStr(SEasterDateOrthodox);
  lbl_sun_rektaszension.caption:=LoadStr(SRektaszension);
  lbl_sun_declination.caption:=LoadStr(SDeclination);
  lbl_moon_rektaszension.caption:=LoadStr(SRektaszension);
  lbl_moon_declination.caption:=LoadStr(SDeclination);
  page_sun       .Caption := LoadStr(SSun);
  page_moon      .Caption := LoadStr(SMoon);
  page_calendar  .Caption := LoadStr(SCalendar);
  for z:=low(TChineseZodiac) to high(TChineseZodiac) do
    ChineseZodiac[z]:=LoadStr(SChineseZodiac+ord(z));
  (* first: locations *)
  pos_x:=72;
  for i:=0 to self.componentcount-1 do
    if components[i].tag=1 then
      pos_x:=max(pos_x,TControl(components[i]).left+TControl(components[i]).width+offset);
  for i:=0 to self.componentcount-1 do
    if components[i].tag=2 then
      TControl(components[i]).left:=pos_x;
  (* second: first data row *)
  pos_x:=120;
  for i:=0 to self.componentcount-1 do
    if components[i].tag=3 then
      pos_x:=max(pos_x,TControl(components[i]).left+TControl(components[i]).width+offset);
  for i:=0 to self.componentcount-1 do
    if components[i].tag=4 then
      TControl(components[i]).left:=pos_x;
  (* third: second data row *)
  pos_x:=pos_x+time_max_width+offset;
  pos_x_2:=0;
  for i:=0 to self.componentcount-1 do
    if components[i].tag=5 then begin
      TControl(components[i]).left:=pos_x;
      pos_x_2:=max(pos_x_2,TControl(components[i]).left+TControl(components[i]).width+offset);
      end;
  for i:=0 to self.componentcount-1 do
    if components[i].tag=6 then
      TControl(components[i]).left:=pos_x_2;
  self.width:=pos_x_2+time_max_width+offset+2*page.left;
  page.width:=self.width-2*page.left;
  end;
(*@\\\0000000511*)
(*@\\\0000000B32*)
(*$ifndef ver80 *) (*$warnings off*) (*$endif *)
end.
(*@\\\0001000011000301*)
