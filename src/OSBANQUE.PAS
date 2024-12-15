program osbanque;
{
Auteur: Patrick Pr‚martin.
Date: 19/09/1993.
      25/09/1993.
Langage: Borland Pascal 7.0
But: Gestion de comptes en banque.
}

uses
    crt,
    banq_operation,
    banq_compte;

const
     num_ver : string [3] = '1.0';
     dat_ver : string [8] = '25/09/93';

begin
  textattr := 7;
  clrscr;
  while (selection_operation (selection_compte)) do
    begin
    end;
  {endwhile}
  textattr := 7;
  clrscr;
  writeln ('Gestion de compte bancaire (v', num_ver, ')');
  writeln ('(c) Patrick Pr‚martin ', dat_ver);
end.
