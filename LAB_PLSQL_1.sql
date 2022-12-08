VARIABLE rezultat VARCHAR2(35)
VARIABLE nr NUMBER
BEGIN
 SELECT department_name, COUNT(*)
 INTO :rezultat, :nr
 FROM employees e, departments d
 WHERE e.department_id=d.department_id
 GROUP BY department_name
 HAVING COUNT(*) = (SELECT MAX(COUNT(*))
 FROM employees
GROUP BY department_id);
 DBMS_OUTPUT.PUT_LINE('Departamentul '|| :rezultat || :nr);
END;
/
PRINT rezultat
/
PRINT nr
/

SET VERIFY OFF
DECLARE
 v_cod employees.employee_id%TYPE:=&p_cod;
 v_bonus NUMBER(8);
 v_salariu_anual NUMBER(8);
BEGIN
 SELECT salary*12 INTO v_salariu_anual
 FROM employees
 WHERE employee_id = v_cod;
 IF v_salariu_anual>=200001
 THEN v_bonus:=20000;
 ELSIF v_salariu_anual BETWEEN 100001 AND 200000
 THEN v_bonus:=10000;
 ELSE v_bonus:=5000;
END IF;
DBMS_OUTPUT.PUT_LINE('Bonusul este ' || v_bonus);
END;
/
SET VERIFY ON

DEFINE p_cod_sal= 200
DEFINE p_cod_dept = 80
DEFINE p_procent =20
DECLARE
 v_cod_sal emp_fna.employee_id%TYPE:= &p_cod_sal;
 v_cod_dept emp_fna.department_id%TYPE:= &p_cod_dept;
 v_procent NUMBER(8):=&p_procent;
 BEGIN
 UPDATE emp_fna
 SET department_id = v_cod_dept,
 salary=salary + (salary* v_procent/100)
 WHERE employee_id= v_cod_sal;
 IF SQL%ROWCOUNT =0 THEN
 DBMS_OUTPUT.PUT_LINE('Nu exista un angajat cu acest cod');
 ELSE DBMS_OUTPUT.PUT_LINE('Actualizare realizata');
 END IF;
END;
/
ROLLBACK;

DECLARE
 contor NUMBER(6) := 1;
 v_data DATE;
 maxim NUMBER(2) := LAST_DAY(SYSDATE)-SYSDATE;
BEGIN
 LOOP
 v_data := sysdate+contor;
 INSERT INTO zile_fna
 VALUES (contor,v_data,to_char(v_data,'Day'));
 contor := contor + 1;
 EXIT WHEN contor > maxim;
 END LOOP;
END;
/
DECLARE
 i POSITIVE:=1;
 max_loop CONSTANT POSITIVE:=10;
BEGIN
 i:=1;
 LOOP
 i:=i+1;
 DBMS_OUTPUT.PUT_LINE('in loop i=' || i);
 EXIT WHEN i>max_loop;
 END LOOP;
 i:=1;
 DBMS_OUTPUT.PUT_LINE('dupa loop i=' || i);
END;
/


