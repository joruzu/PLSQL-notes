accept naam char prompt 'Toets de naam van de medewerker waarvan gegevens moet worden opgehaald: ';
declare 
    v_naam varchar2(50);
    v_mnr medewerkers.mnr%type;
    v_maandsal medewerkers.maandsal%type;
    onbekend exception;
    pragma exception_init(onbekend, -20001);
begin 
    v_naam := '&naam';
    select mnr, maandsal
    into v_mnr, v_maandsal
    from medewerkers
    where naam = upper(v_naam);
    dbms_output.put_line('Naam: ' || v_naam || ' MNR: ' || v_mnr || ' Maandsal: ' || v_maandsal);
exception 
    when no_data_found
        then --dbms_output.put_line('Onbekende medewerker');
        raise_application_error(-20001, 'Onbekende medewerker ' || v_naam);
    when too_many_rows
        then dbms_output.put_line('Er is meer dan 1 medewerker met die naam, alleen de gegevens van de oudste zal worden getoond');
        select mnr, maandsal into v_mnr, v_maandsal from medewerkers order by gbdatum fetch next 1 rows only;
        dbms_output.put_line('Naam: ' || v_naam || ' MNR: ' || v_mnr || ' Maandsal: ' || v_maandsal);
end;
/