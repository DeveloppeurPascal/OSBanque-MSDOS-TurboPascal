unit banq_compte;
{
Auteur: Patrick Pr‚martin.
Date: 19/09/1993.
      25/09/1993.
Langage: Borland Pascal 7.0
But: Gestion des comptes (cr‚ation, modification, affichage de la liste).
}

interface

uses
    banq_var;

function selection_compte : t_compteur;

procedure modifier_solde (old_mt, new_mt : t_montant);

implementation

uses
    banq_selection,
    banq_cpt,
    u_chaine,
    u_masq,
    u_sgf;

var
   fichier : f_compte;
   operation_sur_banque,
   rcd : longint;
   r : t_fich_compte;

procedure remplissage_ecran (var rcd : longint; var nb : byte);
var
   n : longint;
begin
  nb := 0;
  if (rcd < 0)
  then
    rcd := 0
  else
    if (rcd >= filesize (fichier))
    then
      rcd := pred (filesize (fichier));
    {endif}
  {endif}
  n := rcd;
  if (filesize (fichier) > 0)
  then
    repeat
      seek (fichier, n);
      read (fichier, r);
      inc (nb);
{................................x...........x......,..x......,..x......,..x..x}
      liste [nb] := r.adresse.rs1+' '+r.compte+' '+
                    num (r.cum_d.ent)+'.'+r.cum_d.dec+' '+
                    num (r.cum_c.ent)+'.'+r.cum_c.dec+' '+
                    num (r.solde.ent)+'.'+r.solde.dec+' ';
      if (r.solde.mt_type = 'C')
      then
        liste [nb] := liste [nb]+'-'
      else
        if ((r.solde.ent = '000000') and (r.solde.dec = '00'))
        then
          liste [nb] := liste [nb]+'*'
        else
          liste [nb] := liste [nb]+' ';
        {endif}
      {endif}
      dec (n);
    until ((nb >= c_nb_max_elem) or (n < 0));
  {endif}
end; { remplissage_ecran }

procedure creation;
var
   raz,
   valid,
   abandon : boolean;
begin
  raz := true;
  abandon := false;
  valid := false;
  repeat
    saisir_masque (masq2, raz, abandon);
    if not abandon
    then
      begin
        raz := false;
        valid := true;
      end;
    {endif}
  until (valid or abandon);
  if valid
  then
    begin
      inc (compteur);
      r.numero := compteur;
      r.etablissement := masq2.zone [3].valeur;
      r.guichet := masq2.zone [5].valeur;
      r.compte := masq2.zone [7].valeur;
      r.cle := masq2.zone [9].valeur;
      r.adresse.rs1 := masq2.zone [11].valeur;
      r.adresse.rs2 := masq2.zone [12].valeur;
      r.adresse.adr1 := masq2.zone [14].valeur;
      r.adresse.adr2 := masq2.zone [15].valeur;
      r.adresse.lieu_dit := masq2.zone [16].valeur;
      r.adresse.code_postal := masq2.zone [17].valeur;
      r.adresse.ville := masq2.zone [18].valeur;
      r.adresse.pays := masq2.zone [20].valeur;
      r.centre := masq2.zone [22].valeur;
      r.solde.mt_type := 'D';
      r.solde.ent := '000000';
      r.solde.dec := '00';
      r.cum_d.mt_type := 'D';
      r.cum_d.ent := '000000';
      r.cum_d.dec := '00';
      r.cum_d.mt_type := 'D';
      r.cum_c.mt_type := 'C';
      r.cum_c.mt_type := 'C';
      r.cum_c.ent := '000000';
      r.cum_c.dec := '00';
      seek (fichier, filesize (fichier));
      write (fichier, r);
      rcd := pred (filesize (fichier));
    end;
  {endif}
end; { creation }

function selection_compte : t_compteur;
var
   res : t_compteur;
   nb,
   posit,
   choix : byte;
   fin,
   pgup,
   pgdn : boolean;
begin
  titre_ecran := 'Liste des comptes en banque';
                 {000000000111111111122222222223333333333444444444455555555556666666666777777777}
                 {123456789012345678901234567890123456789012345678901234567890123456789012345678}
                 {................................x...........x......,..x......,..x......,..x..x}
  entete_col1 := '             Banque                Compte    Cumul        Cumul  Solde compte';
  entete_col2 := '                                             D‚bit        Cr‚dit          C/D';
  res := 0;
  rcd := pred (filesize (fichier));
  fin := false;
  posit := 1;
  while not fin do
    begin
      remplissage_ecran (rcd, nb);
      choix_liste (nb, posit, choix, (rcd+1 < filesize (fichier)), (rcd-c_nb_max_elem >= 0),
                                     (rcd+1 < filesize (fichier)), (rcd-c_nb_max_elem >= 0));
      case choix of
        ch_pgup : rcd := rcd + c_nb_max_elem;
        ch_pgdn : rcd := rcd - c_nb_max_elem;
        ch_haut : rcd := rcd + 1;
        ch_bas : rcd := rcd - 1;
        ch_sortie : begin
                      fin := true;
                      res := maxint;
        end;
        ch_creation : begin
                        posit := 1;
                        rcd := filesize (fichier);
                        creation;
        end;
        1..c_nb_max_elem : begin
                             operation_sur_banque := succ (rcd-choix);
                             seek (fichier, operation_sur_banque);
                             read (fichier, r);
                             res := r.numero;
                             fin := true;
        end;
      end;
    end;
  {endwhile}
  selection_compte := res;
end; { Selection_compte }

procedure modifier_solde (old_mt, new_mt : t_montant);
begin
  seek (fichier, operation_sur_banque);
  read (fichier, r);
  if (old_mt.mt_type = 'D')
  then
    sub_mt (r.cum_d, old_mt, r.cum_d)
  else
    sub_mt (r.cum_c, old_mt, r.cum_c);
  {endif}
  if (new_mt.mt_type = 'D')
  then
    add_mt (new_mt, r.cum_d, r.cum_d)
  else
    add_mt (new_mt, r.cum_c, r.cum_c);
  {endif}
  add_mt (r.cum_d, r.cum_c, r.solde);
  seek (fichier, operation_sur_banque);
  write (fichier, r);
end; { modifier_solde }

var
   old_exitproc : pointer;

procedure banq_compte_exit; far;
begin
  exitproc := old_exitproc;
  close (fichier);
end; { banq_compte_exit }

procedure banq_compte_init;
var
   ch : string;
begin
  ch := get_file_name ('COMPTE.DTA');
  filemode := 2;
  assign (fichier, ch);
  if not exist (ch)
  then
    begin
      {$i-}
      rewrite (fichier);
      {$i+}
      if (ioresult <> 0)
      then
        begin
          writeln ('Op‚ration d''‚criture/lecture sur COMPTE.DTA impossible.');
          halt(1);
        end;
      {endif}
      close (fichier);
    end;
  {endif}
  {$i-}
  reset (fichier);
  {$i+}
  operation_sur_banque := filesize (fichier);
end; { banq_compte_init }

begin
  banq_compte_init;
  old_exitproc := exitproc;
  exitproc := @banq_compte_exit;
end.
