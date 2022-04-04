accept opgave number prompt 'Geef aan voor welke opgave van hoofdstuk 3 u het antwoord wilt zien (1-4): ';
declare
    opg pls_integer := &opgave;
begin
    case opg
        when 1 then
            begin
                dbms_output.put_line('For this opgave execute h3-1.sql, you can uncomment it below');
                return;
            end;
        else
            dbms_output.put_line('Invalide input voor opgave van hoofdstuk 3: kies tussen 1 en 4');
    end case;
end;
/

@h3-1