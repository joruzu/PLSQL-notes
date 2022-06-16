Examine the code below

    1  DECLARE
    2    PROCEDURE proc1(p_parameter_id IN OUT NUMBER) IS
    3      v_email VARCHAR2(100);
    4      CURSOR c1(p_cur_param IN OUT NUMBER) IS
    5        SELECT email FROM employees WHERE employee_id = p_cur_param;
    6    BEGIN
    7      OPEN c1(p_parameter_id);
    8      FETCH c1 INTO v_email;
    9      CLOSE c1;
    10     END proc1;
    11 BEGIN
    12     proc1(100);
    13 END;
    14  /
What should be done to make the above code execute? (choose 2)
- [ ] a. change formal parameter "p_parameter_id" in line 2 to "p_cur_param"
- [ ] b. add DEFAULT 100 to the argument in line 2
- [ ] c. change the parameter mode of argument in line 4 to IN
- [ ] d. add DEFAULT 100 to argument in line 4
- [ ] e. change formal parameter "p_cur_param" in line 4 to "p_parameter_id"
- [ ] f. change the parameter mode or argument in line 2 to IN

----
Examine the code below

    1  DECLARE
    2      PROCEDURE proc1(UPPER(p1) IN VARCHAR2, p2 IN NUMBER) IS
    3          v_sal NUMBER := ROUND(p2);
    4      BEGIN
    5          DECODE(p1, 'HE', 'him', 'SHE', 'her');
    6          DBMS_OUTPUT.PUT_LINE(v_sal);
    7      END proc1;
    8  BEGIN
    9      proc1('he', 1199.95);
    10 END;
    11 /

Which lines of code would cause execution to fail? (choose 2)
- [ ] a. line 2
- [ ] b. line 3 
- [ ] c. line 5
- [ ] d. line 6
- [ ] e. line 9