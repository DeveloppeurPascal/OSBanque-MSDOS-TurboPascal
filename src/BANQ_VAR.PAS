unit banq_var;
{
Auteur: Patrick Pr‚martin.
Date: 19/09/1993.
      25/09/1993.
Langage: Borland Pascal 7.0
But: D‚claration des variables et des types globaux utilis‚s par OSBANQUE.
}

interface
uses
    u_masq;

type
    string2 = string [2];
    string3 = string [3];
    string5 = string [5];
    string6 = string [6];
    string11 = string [11];
    string12 = string [12];
    string20 = string [20];
    string25 = string [25];
    string32 = string [32];
    string50 = string [50];
    t_etablissement = string5;
    t_guichet = string5;
    t_compte = string11;
    t_cle = string2;
    t_centre = string20;
    t_date = record
               siecle : boolean;
               annee : byte;
               mois : byte;
               jour : byte;
    end;
    t_heure = record
                heure : byte;
                minute : byte;
                seconde : byte;
    end;
    t_montant = record
                  mt_type : char; { D = D‚bit (-), C = Cr‚dit (+) }
                  ent : string6;
                  dec : string2;
    end;
    t_num_piece = string12;
    t_type_piece = string3;
    t_commentaire = record
                      lig0 : string50;
                      lig1 : string50;
                      lig2 : string50;
    end;
    t_compteur = longint;
    t_adresse = record
                  rs1,
                  rs2,
                  adr1,
                  adr2,
                  lieu_dit : string32;
                  code_postal : string5;
                  ville : string25;
                  pays : string2;
    end;

    t_fich_compte = record
                      numero : t_compteur;
                      etablissement : t_etablissement;
                      guichet : t_guichet;
                      compte : t_compte;
                      cle : t_cle;
                      adresse : t_adresse;
                      centre: t_centre;
                      cum_d, { Cumul des d‚bits }
                      cum_c, { Cumul des cr‚dits }
                      solde : t_montant; { Solde du compte d'aprŠs les
                                         op‚rations saisies. }
    end;
    f_compte = file of t_fich_compte;

    t_fich_operation = record
                         date_creation : t_date;
                         heure_creation : t_heure;
                         date_oper : t_date;
                         type_piece : t_type_piece;
                         num_piece : t_num_piece;
                         objet : string25;
                         montant_oper : t_montant;
                         date_releve : t_date;
                         num_releve : string6;
                         commentaire : t_commentaire;
    end;
    f_operation = file of t_fich_operation;

    t_fich_compteur = record
                        compteur : t_compteur;
    end;
    f_compteur = file of t_fich_compteur;

var
   masq1,
   masq2,
   masq3 : masque;

function n2s (n : longint; nb : byte) : string;
function s2n (ch : string) : longint;
function num (ch : string) : string;
procedure add_mt (mt1, mt2 : t_montant; var res : t_montant);
procedure sub_mt (mt1, mt2 : t_montant; var res : t_montant);

implementation

uses
    u_chaine;

function num (ch : string) : string;
var
   i : byte;
begin
  i := 1;
  while ((i < length (ch)) and (ch [i] = '0')) do
    begin
      ch [i] := ' ';
      inc (i);
    end;
  {endwhile}
  num := ch;
end; { num }

function n2s (n : longint; nb : byte) : string;
var
   res : string;
begin
  res := '';
  while (n > 0) do
    begin
      res := chr (48+(n mod 10)) + res;
      n := n div 10;
    end;
  {endwhile}
  res := trait ('0', nb)+res;
  n2s := copy (res, length (res)-nb+1, nb);
end; { n2s }

function s2n (ch : string) : longint;
var
   res : longint;
begin
  res := 0;
  while (length (ch) > 0) do
    begin
      if (ch [1] in ['0'..'9'])
      then
        res := res*10 + (ord (ch [1]) - ord ('0'));
      {endif}
      delete (ch, 1, 1);
    end;
  {endwhile}
  s2n := res;
end; { s2n }

procedure add_mt (mt1, mt2 : t_montant; var res : t_montant);
var
   i : longint;
begin
  if (mt1.mt_type = mt2.mt_type)
  then
    begin
      res.mt_type := mt1.mt_type;
      i := (s2n(mt1.ent)+s2n(mt2.ent))*100+(s2n(mt1.dec)+s2n(mt2.dec));
    end
  else
    if (mt1.mt_type = 'D')
    then
      begin
        i := (s2n(mt1.ent)-s2n(mt2.ent))*100+(s2n(mt1.dec)-s2n(mt2.dec));
        if (i < 0)
        then
          begin
            res.mt_type := 'C';
            i := -i;
          end
        else
          res.mt_type := 'D';
        {endif}
      end
    else
      begin
        i := (s2n(mt2.ent)-s2n(mt1.ent))*100+(s2n(mt2.dec)-s2n(mt1.dec));
        if (i < 0)
        then
          begin
            res.mt_type := 'C';
            i := -i;
          end
        else
          res.mt_type := 'D';
        {endif}
      end;
    {endif}
  {endif}
  res.dec := n2s (i mod 100, 2);
  res.ent := n2s (i div 100, 6);
end; { add_mt }

procedure sub_mt (mt1, mt2 : t_montant; var res : t_montant);
var
   i : longint;
begin
  if (mt1.mt_type = mt2.mt_type)
  then
    begin
      res.mt_type := mt1.mt_type;
      i := (s2n(mt1.ent)-s2n(mt2.ent))*100+(s2n(mt1.dec)-s2n(mt2.dec));
    end
  else
    if (mt1.mt_type = 'D')
    then
      begin
        i := (s2n(mt1.ent)+s2n(mt2.ent))*100+(s2n(mt1.dec)+s2n(mt2.dec));
        res.mt_type := 'D';
      end
    else
      begin
        i := (s2n(mt2.ent)+s2n(mt1.ent))*100+(s2n(mt2.dec)+s2n(mt1.dec));
        res.mt_type := 'C';
      end;
    {endif}
  {endif}
  res.dec := n2s (i mod 100, 2);
  res.ent := n2s (i div 100, 6);
end; { sub_mt }

begin
  lire_masque (masq1, 'osbanq1');
  lire_masque (masq2, 'osbanq2');
  lire_masque (masq3, 'osbanq3');
end.
