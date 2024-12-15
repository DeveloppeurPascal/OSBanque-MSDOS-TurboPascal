unit banq_selection;
{
Auteur: Patrick Pr‚martin.
Date: 19/09/1993.
Langage: Borland Pascal 7.0
But: S‚lection des enregistrements dans une liste.
}

interface

const
     c_nb_max_elem = 18;
     ch_sortie = 255;
     ch_pgup = 254;
     ch_pgdn = 253;
     ch_haut = 252;
     ch_bas = 251;
     ch_creation = 250;

type
    string78 = string [78];
    t_liste = array [1..c_nb_max_elem] of string78;

var
   titre_ecran,
   entete_col1,
   entete_col2 : string78;
   liste : t_liste;

procedure choix_liste (nb_elem : byte; var posit, choix : byte; tst_pgup, tst_pgdn, tst_haut, tst_bas : boolean);

implementation

uses
    crt,
    u_code_clavier;

procedure lig_norm (posit : byte);
begin
  if (posit > 0)
  then
    begin
      textattr := 7;
      gotoxy (2, 4+posit);
      write (liste [posit]);
    end;
  {endif}
end; { lig_norm }

procedure lig_inv (posit : byte);
begin
  if (posit > 0)
  then
    begin
      textattr := $70;
      gotoxy (2, 4+posit);
      write (liste [posit]);
    end;
  {endif}
end; { lig_inv }

procedure choix_liste (nb_elem : byte; var posit, choix : byte; tst_pgup, tst_pgdn, tst_haut, tst_bas : boolean);
var
   res : byte;
   i : byte;
   fin : boolean;
   c : char;
begin
  res := ch_sortie;
  textattr := $f;
  clrscr;
  gotoxy (40-(length (titre_ecran) div 2)+1,1);
  write (titre_ecran);
  gotoxy (2, 3);
  writeln (entete_col1);
  gotoxy (2, 4);
  writeln (entete_col2);
  gotoxy (1, 24);
  write ('F6=Ajouter, Entr‚e=S‚lectionner, Esc=Sortie.');
  for i := 1 to nb_elem do
    begin
      lig_norm (i);
    end;
  {endfor}
  if (posit < 1)
  then
    posit := 1
  else
    if (posit > nb_elem)
    then
      posit := nb_elem;
    {endif}
  {endif}
  if (nb_elem = 0)
  then
    posit := 0;
  {endif}
  lig_inv (posit);
  fin := false;
  while not fin do
    begin
      c := readkey;
      case c of
        touche_escape : begin
                          fin := true;
                          res := ch_sortie;
        end;
        touche_return : begin
                          fin := true;
                          res := posit;
        end;
        carac_nul : begin
                      c := readkey;
                      case c of
                        touche_page_up : if tst_pgup
                                         then
                                           begin
                                             fin := true;
                                             res := ch_pgup;
                                           end;
                                         {endif}
                        touche_page_dn : if tst_pgdn
                                         then
                                           begin
                                             fin := true;
                                             res := ch_pgdn;
                                           end;
                                         {endif}
                        touche_haut : if ((posit = 1) and tst_haut)
                                      then
                                        begin
                                          fin := true;
                                          res := ch_haut;
                                        end
                                      else
                                        if (posit > 1)
                                        then
                                          begin
                                            lig_norm (posit);
                                            dec (posit);
                                            lig_inv (posit);
                                          end;
                                        {endif}
                                      {endif}
                        touche_bas : if ((posit = c_nb_max_elem) and tst_bas)
                                     then
                                       begin
                                         fin := true;
                                         res := ch_bas;
                                       end
                                     else
                                       if (posit < nb_elem)
                                       then
                                         begin
                                           lig_norm (posit);
                                           inc (posit);
                                           lig_inv (posit);
                                         end;
                                       {endif}
                                     {endif}
                        touche_f6 : begin
                                      fin := true;
                                      res := ch_creation;
                        end;
                      end;
        end;
      end;
    end;
  {endwhile}
  choix := res;
end; { choix_liste }

end.
