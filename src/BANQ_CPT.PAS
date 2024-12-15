unit banq_cpt;
{
Auteur: Patrick Pr‚martin.
Date: 19/09/1993.
Langage: Borland Pascal 7.0
But: Gestion du nombre de comptes bancaires g‚r‚s par OSBANQUE.
}
interface

uses
    banq_var;

var
   compteur : t_compteur;

implementation

uses
    u_sgf;

var
   old_compteur : t_compteur;
   old_exitproc : pointer;

procedure banq_cpt_exit; far;
var
   f : f_compteur;
   r : t_fich_compteur;
begin
  exitproc := old_exitproc;
  if (old_compteur <> compteur)
  then
    begin
      assign (f, get_file_name ('OSBANQUE.DTA'));
      {$i-}
      rewrite (f);
      {$i+}
      if (ioresult = 0)
      then
        begin
          r.compteur := compteur;
          write (f, r);
          close (f);
        end;
      {endif}
    end;
  {endif}
end; { banq_cpt_exit }

procedure banq_cpt_init;
var
   f : f_compteur;
   r : t_fich_compteur;
begin
  assign (f, get_file_name ('OSBANQUE.DTA'));
  {$i-}
  reset (f);
  {$i+}
  if (ioresult = 0)
  then
    begin
      read (f, r);
      compteur := r.compteur;
      old_compteur := compteur;
      close (f);
    end
  else
    begin
      compteur := 0;
      old_compteur := 0;
    end;
  {endif}
end; { banq_cpt_init }

begin
  banq_cpt_init;
  old_exitproc := exitproc;
  exitproc := @banq_cpt_exit;
end.
