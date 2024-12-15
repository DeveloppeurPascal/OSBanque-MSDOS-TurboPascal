unit banq_operation;
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

function selection_operation (num_compte : t_compteur) : boolean;

implementation

uses
    banq_selection,
    banq_compte,
    banq_cpt,
    u_date,
    u_time,
    u_masq,
    u_sgf;

var
   fichier : f_operation;
   rcd : longint;
   r : t_fich_operation;

procedure banq_operation_init (num : t_compteur);
var
   fich_name,
   ch : string;
begin
  fich_name := 'OPER_'+n2s (num, 3)+'.DTA';
  ch := get_file_name (fich_name);
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
          writeln ('Op‚ration d''‚criture/lecture sur '+fich_name+' impossible.');
          halt(1);
        end;
      {endif}
      close (fichier);
    end;
  {endif}
  {$i-}
  reset (fichier);
  {$i+}
end; { banq_operation_init }

procedure banq_operation_exit;
begin
  close (fichier);
end; { banq_operation_exit }

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
      seek(fichier, n);
      inc (nb);
      read (fichier, r);
{.x../../..x...x............x.........................x......,..x......,..xxxxx}
      if (r.num_releve <> '000000')
      then
        liste [nb] := 'x '
      else
        liste [nb] := '  ';
      {endif}
      liste [nb] := liste[nb]+num (n2s(r.date_oper.jour, 2))+'/'+n2s(r.date_oper.mois,2)+'/'+
                    n2s(r.date_oper.annee,2)+' '+r.type_piece+' '+num (r.num_piece)+' '+r.objet+' ';
      if (r.montant_oper.mt_type = 'D')
      then
        liste [nb] := liste [nb]+num (r.montant_oper.ent)+'.'+r.montant_oper.dec+'      0.00'
      else
        liste [nb] := liste [nb]+'     0.00 '+num (r.montant_oper.ent)+'.'+r.montant_oper.dec;
      {endif}
      dec (n);
    until ((n < 0) or (nb >= c_nb_max_elem));
  {endif}
end; { remplissage_ecran }

procedure creation_modif (num_record : longint);
var
   crt,
   raz,
   valid,
   abandon : boolean;
   jj, mm, aa, w : word;
   b : byte;
   ch : string;
   mt : t_montant;
begin
  abandon := false;
  valid := false;
  if (num_record < filesize (fichier))
  then
    begin
      crt := false;
      raz := false;
      seek (fichier, num_record);
      read (fichier, r);
      masq3.zone [3].valeur := n2s (r.date_oper.jour, 2);
      masq3.zone [5].valeur := n2s (r.date_oper.mois, 2);
      masq3.zone [7].valeur := n2s (r.date_oper.annee, 2);
      masq3.zone [9].valeur := r.type_piece;
      masq3.zone [12].valeur := r.num_piece;
      masq3.zone [14].valeur := r.objet;
      masq3.zone [16].valeur := r.montant_oper.mt_type;
      masq3.zone [18].valeur := r.montant_oper.ent;
      masq3.zone [20].valeur := r.montant_oper.dec;
      masq3.zone [22].valeur := r.commentaire.lig0;
      masq3.zone [23].valeur := r.commentaire.lig1;
      masq3.zone [24].valeur := r.commentaire.lig2;
      masq3.zone [26].valeur := n2s (r.date_releve.jour, 2);
      masq3.zone [28].valeur := n2s (r.date_releve.mois, 2);
      masq3.zone [30].valeur := n2s (r.date_releve.annee, 2);
      masq3.zone [32].valeur := r.num_releve;
      mt := r.montant_oper;
    end
  else
    crt := true;
  {endif}
  repeat
    if crt
    then
      begin
        get_date (jj, mm, aa, w);
        r.date_creation.jour := jj;
        r.date_creation.mois := mm;
        r.date_creation.siecle := (aa > 2000);
        while (aa > 100) do
          aa := aa - 100;
        {endwhile}
        r.date_creation.annee := aa;
        get_time (r.heure_creation.heure, r.heure_creation.minute, r.heure_creation.seconde, b);
        mt.mt_type := 'D';
        mt.ent := '000000';
        mt.dec := '00';
        num_record := filesize (fichier);
        raz := true;
        abandon := false;
        valid := false;
      end;
    {endif}
    repeat
      saisir_masque (masq3, raz, abandon);
      if not abandon
      then
        begin
          raz := false;
          valid := true;
        end;
      {endif}
    until (abandon or valid);
    if valid
    then
      begin
        r.date_oper.jour := s2n (masq3.zone [3].valeur);
        r.date_oper.mois := s2n (masq3.zone [5].valeur);
        r.date_oper.annee := s2n (masq3.zone [7].valeur);
        r.date_oper.siecle := false;
        r.type_piece := masq3.zone [9].valeur;
        r.num_piece := masq3.zone [12].valeur;
        r.objet := masq3.zone [14].valeur;
        r.montant_oper.mt_type := masq3.zone [16].valeur [1];
        r.montant_oper.ent := masq3.zone [18].valeur;
        r.montant_oper.dec := masq3.zone [20].valeur;
        r.commentaire.lig0 := masq3.zone [22].valeur;
        r.commentaire.lig1 := masq3.zone [23].valeur;
        r.commentaire.lig2 := masq3.zone [24].valeur;
        r.date_releve.jour := s2n (masq3.zone [26].valeur);
        r.date_releve.mois := s2n (masq3.zone [28].valeur);
        r.date_releve.annee := s2n (masq3.zone [30].valeur);
        r.num_releve := masq3.zone [32].valeur;
        if ((mt.mt_type <> r.montant_oper.mt_type)
           or (mt.ent <> r.montant_oper.ent)
           or (mt.dec <> r.montant_oper.dec))
        then
          modifier_solde (mt, r.montant_oper);
        {endif}
        seek (fichier, num_record);
        write (fichier, r);
      end;
    {endif}
  until (abandon or (not crt));
end; { creation_modif }

function selection_operation (num_compte : t_compteur) : boolean;
var
   nb,
   posit,
   choix : byte;
   res,
   fin : boolean;
begin
  if (num_compte = maxint)
  then
    res := false
  else
    begin
      res := true;
      banq_operation_init (num_compte);
      titre_ecran := 'Op‚rations sur le compte';
                     {000000000111111111122222222223333333333444444444455555555556666666666777777777}
                     {123456789012345678901234567890123456789012345678901234567890123456789012345678}
                     {.x../../..x...x............x.........................x......,..x......,..xxxxx}
      entete_col1 := '';
      entete_col2 := '    Date   Typ   Nø PiŠce     Objet de l''op‚ration    Mt D‚bit  Mt Cr‚dit';
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
            ch_sortie : fin := true;
            ch_creation : begin
                            creation_modif (filesize (fichier));
                            rcd := filesize (fichier);
                            posit := 1;
            end;
            1..c_nb_max_elem : creation_modif (succ (rcd-choix));
          end;
        end;
      {endwhile}
      banq_operation_exit;
    end;
  {endif}
  selection_operation := res;
end; { selection_operation }

end.
