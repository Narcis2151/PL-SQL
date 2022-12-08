--1 -> fara colectii si cursor
--Mod default pentru cursoare
/*
    1.Declarare
    2.Deschidere (si executare SELECT)
    3.Parcurgere linie cu linie si stocarea liniei
    4.Incheiere parcurgere
    5.Inchidere cursor
*/
DECLARE
 v_nr number(4);
 v_nume departments.department_name%TYPE;
 CURSOR c IS
 SELECT department_name nume, COUNT(employee_id) nr
 FROM departments d, employees e
 WHERE d.department_id=e.department_id(+)
 GROUP BY department_name;
BEGIN
 OPEN c;
 LOOP
 FETCH c INTO v_nume,v_nr;
 EXIT WHEN c%NOTFOUND;
 IF v_nr=0 THEN
 DBMS_OUTPUT.PUT_LINE('In departamentul '|| v_nume||
 ' nu lucreaza angajati');
 ELSIF v_nr=1 THEN
 DBMS_OUTPUT.PUT_LINE('In departamentul '|| v_nume||
 ' lucreaza un angajat');
 ELSE
 DBMS_OUTPUT.PUT_LINE('In departamentul '|| v_nume||
 ' lucreaza '|| v_nr||' angajati');
 END IF;
END LOOP;
CLOSE c;
END;
/

--2 -> 2 colectii si cursor
--Modul 2 pentru cursoare
/*
    1.Declarare
    2.Deschidere (si executare SELECT)
    3.Parcurgere tot odata si stocare in tabel cu BULK COLLECT INTO
    4.Inchidere cursor
*/
DECLARE
 TYPE tab_nume IS TABLE OF departments.department_name%TYPE;
 TYPE tab_nr IS TABLE OF NUMBER(4);
 t_nr tab_nr;
 t_nume tab_nume;
 CURSOR c IS
 SELECT department_name nume, COUNT(employee_id) nr
 FROM departments d, employees e
 WHERE d.department_id=e.department_id(+)
 GROUP BY department_name;
BEGIN
 OPEN c;
 FETCH c BULK COLLECT INTO t_nume, t_nr;
 CLOSE c;
 FOR i IN t_nume.FIRST..t_nume.LAST LOOP
 IF t_nr(i)=0 THEN
 DBMS_OUTPUT.PUT_LINE('In departamentul '|| t_nume(i)||
 ' nu lucreaza angajati');
 ELSIF t_nr(i)=1 THEN
 DBMS_OUTPUT.PUT_LINE('In departamentul '||t_nume(i)||
 ' lucreaza un angajat');
 ELSE
 DBMS_OUTPUT.PUT_LINE('In departamentul '|| t_nume(i)||
 ' lucreaza '|| t_nr(i)||' angajati');
 END IF;
 END LOOP;
END;
/

--2 -> 1 tabel si cursor

DECLARE
 TYPE tip_date IS RECORD (nume DEPARTMENTS.DEPARTMENT_NAME%TYPE, nr NUMBER(5));
 TYPE tip_tabel IS TABLE OF tip_date;
 CURSOR c IS
 SELECT department_name nume, COUNT(employee_id) nr
 FROM departments d, employees e
 WHERE d.department_id=e.department_id(+)
 GROUP BY department_name;
 tip tip_tabel;
BEGIN
 OPEN c;
 FETCH c BULK COLLECT INTO tip;
 CLOSE c;
 FOR i IN tip.FIRST..tip.LAST LOOP
 IF tip(i).nr=0 THEN
 DBMS_OUTPUT.PUT_LINE('In departamentul '|| tip(i).nume||
 ' nu lucreaza angajati');
 ELSIF tip(i).nr=1 THEN
 DBMS_OUTPUT.PUT_LINE('In departamentul '||tip(i).nume||
 ' lucreaza un angajat');
 ELSE
 DBMS_OUTPUT.PUT_LINE('In departamentul '|| tip(i).nume||
 ' lucreaza '|| tip(i).nr||' angajati');
 END IF;
 END LOOP;
END;
/

--2 -> 1 tabel si fara cursor
DECLARE
 TYPE tip_date IS RECORD (nume DEPARTMENTS.DEPARTMENT_NAME%TYPE, nr NUMBER(5));
 TYPE tip_tabel IS TABLE OF tip_date;
 tip tip_tabel;
BEGIN
 
 SELECT department_name nume, COUNT(employee_id) nr
 BULK COLLECT INTO tip
 FROM departments d, employees e
 WHERE d.department_id=e.department_id(+)
 GROUP BY department_name;
 FOR i IN tip.FIRST..tip.LAST LOOP
 IF tip(i).nr=0 THEN
 DBMS_OUTPUT.PUT_LINE('In departamentul '|| tip(i).nume||
 ' nu lucreaza angajati');
 ELSIF tip(i).nr=1 THEN
 DBMS_OUTPUT.PUT_LINE('In departamentul '||tip(i).nume||
 ' lucreaza un angajat');
 ELSE
 DBMS_OUTPUT.PUT_LINE('In departamentul '|| tip(i).nume||
 ' lucreaza '|| tip(i).nr||' angajati');
 END IF;
 END LOOP;
END;
/

--3 -> Ciclu cursor
--Mod pentru cclu-cursoare
/*
    1.Declarare
    2.Parcurgere cu for
*/
DECLARE
 CURSOR c IS
 SELECT department_name nume, COUNT(employee_id) nr
 FROM departments d, employees e
 WHERE d.department_id=e.department_id(+)
 GROUP BY department_name;
BEGIN
 FOR i in c LOOP
 IF i.nr=0 THEN
 DBMS_OUTPUT.PUT_LINE('In departamentul '|| i.nume||
 ' nu lucreaza angajati');
 ELSIF i.nr=1 THEN
 DBMS_OUTPUT.PUT_LINE('In departamentul '|| i.nume ||
 ' lucreaza un angajat');
 ELSE
 DBMS_OUTPUT.PUT_LINE('In departamentul '|| i.nume||
 ' lucreaza '|| i.nr||' angajati');
 END IF;
END LOOP;
END;
/
--4 Mod ciclu-cursor cu subcereri
/*
    Parcurgere direct cu for iterator in (SELECT statement)
*/
BEGIN
 FOR i in (SELECT department_name nume, COUNT(employee_id) nr
 FROM departments d, employees e
 WHERE d.department_id=e.department_id(+)
 GROUP BY department_name) LOOP
 IF i.nr=0 THEN
 DBMS_OUTPUT.PUT_LINE('In departamentul '|| i.nume||
 ' nu lucreaza angajati');
 ELSIF i.nr=1 THEN
 DBMS_OUTPUT.PUT_LINE('In departamentul '|| i.nume ||
 ' lucreaza un angajat');
 ELSE
 DBMS_OUTPUT.PUT_LINE('In departamentul '|| i.nume||
 ' lucreaza '|| i.nr||' angajati');
 END IF;
END LOOP;
END;
/

--5

/*SELECT *
FROM
    (SELECT COUNT(*) NR, e.MANAGER_ID, MAX(s.LAST_NAME)
    FROM EMPLOYEES e, EMPLOYEES s
    WHERE e.MANAGER_ID = s.EMPLOYEE_ID
    GROUP BY e.MANAGER_ID
    ORDER BY NR DESC)
WHERE ROWNUM <= 3;
*/

DECLARE
 v_cod employees.employee_id%TYPE;
 v_nume employees.last_name%TYPE;
 v_nr NUMBER(4);
 CURSOR c IS
 SELECT sef.employee_id cod, MAX(sef.last_name) nume,
 count(*) nr
 FROM employees sef, employees ang
 WHERE ang.manager_id = sef.employee_id
 GROUP BY sef.employee_id
 ORDER BY nr DESC;
BEGIN
 OPEN c;
 LOOP
 FETCH c INTO v_cod,v_nume,v_nr;
 EXIT WHEN c%ROWCOUNT>3 OR c%NOTFOUND;
 DBMS_OUTPUT.PUT_LINE('Managerul '|| v_cod ||
 ' avand numele ' || v_nume ||
 ' conduce ' || v_nr||' angajati');
 END LOOP;
 CLOSE c;
END;
/

--6
DECLARE
 CURSOR c IS
 SELECT sef.employee_id cod, MAX(sef.last_name) nume,
 count(*) nr
 FROM employees sef, employees ang
 WHERE ang.manager_id = sef.employee_id
 GROUP BY sef.employee_id
 ORDER BY nr DESC;
BEGIN
 FOR i IN c LOOP
 EXIT WHEN c%ROWCOUNT>3 OR c%NOTFOUND;
 DBMS_OUTPUT.PUT_LINE('Managerul '|| i.cod ||
 ' avand numele ' || i.nume ||
 ' conduce '|| i.nr||' angajati');
 END LOOP;
END;
/

--7
DECLARE
 top number(1):= 0;
BEGIN
 FOR i IN (SELECT sef.employee_id cod, MAX(sef.last_name) nume,
 count(*) nr
 FROM employees sef, employees ang
 WHERE ang.manager_id = sef.employee_id
 GROUP BY sef.employee_id
 ORDER BY nr DESC)
 LOOP
 DBMS_OUTPUT.PUT_LINE('Managerul '|| i.cod ||
 ' avand numele ' || i.nume ||
 ' conduce '|| i.nr||' angajati');
 Top := top+1;
 EXIT WHEN top=3;
 END LOOP;
END;
/

--8 -> Exercitiul 1 dar cu cursor cu parametru
DECLARE
 v_x number(4) := &p_x;
 v_nr number(4);
 v_nume departments.department_name%TYPE;
 CURSOR c (paramentru NUMBER) IS
 SELECT department_name nume, COUNT(employee_id) nr
 FROM departments d, employees e
 WHERE d.department_id=e.department_id
 GROUP BY department_name
 HAVING COUNT(employee_id)> paramentru;
BEGIN
 OPEN c(v_x);
 LOOP
 FETCH c INTO v_nume,v_nr;
 EXIT WHEN c%NOTFOUND;
 DBMS_OUTPUT.PUT_LINE('In departamentul '|| v_nume||
 ' lucreaza '|| v_nr||' angajati');
END LOOP;
CLOSE c;
END;
/

--SAU (ciclu cursor)
DECLARE
v_x number(4) := &p_x;
CURSOR c (paramentru NUMBER) IS
 SELECT department_name nume, COUNT(employee_id) nr
 FROM departments d, employees e
 WHERE d.department_id=e.department_id
 GROUP BY department_name
 HAVING COUNT(employee_id)> paramentru;
BEGIN
 FOR i in c(v_x) LOOP
 DBMS_OUTPUT.PUT_LINE('In departamentul '|| i.nume||
 ' lucreaza '|| i.nr||' angajati');
 END LOOP;
END;
/

--SAU (ciclu cursor cu subcereri)
DECLARE
v_x number(4) := &p_x;
BEGIN
 FOR i in (SELECT department_name nume, COUNT(employee_id) nr
 FROM departments d, employees e
 WHERE d.department_id=e.department_id
 GROUP BY department_name
 HAVING COUNT(employee_id)> v_x)
 LOOP
 DBMS_OUTPUT.PUT_LINE('In departamentul '|| i.nume||
 ' lucreaza '|| i.nr||' angajati');
END LOOP;
END;
/

--Cursor SELECT FOR UPDATE
SELECT last_name, hire_date, salary
FROM emp_fna
WHERE TO_CHAR(hire_date, 'yyyy') = 2000;

DECLARE
 CURSOR c IS
 SELECT *
 FROM emp_fna
 WHERE TO_CHAR(hire_date, 'YYYY') = 2000
 FOR UPDATE OF salary NOWAIT;
BEGIN
 FOR i IN c LOOP
 UPDATE emp_fna
 SET salary= salary+1000
 WHERE CURRENT OF c;
 END LOOP;
END;
/

--10 -> ciclu curosor cu subcereri

SELECT last_name, hire_date, salary
FROM emp_fna
WHERE TO_CHAR(hire_date, 'yyyy') = 2000;
ROLLBACK;

BEGIN
 FOR v_dept IN (SELECT department_id, department_name
 FROM departments
 WHERE department_id IN (10,20,30,40))
 LOOP
 DBMS_OUTPUT.PUT_LINE('-------------------------------------');
 DBMS_OUTPUT.PUT_LINE ('DEPARTAMENT '||v_dept.department_name);
 DBMS_OUTPUT.PUT_LINE('-------------------------------------');
 FOR v_emp IN (SELECT last_name
 FROM employees
WHERE department_id = v_dept.department_id)
 LOOP
 DBMS_OUTPUT.PUT_LINE (v_emp.last_name);
 END LOOP;
 END LOOP;
END;
/

--10. Varianta 2 -> expresii cursor
DECLARE
 TYPE refcursor IS REF CURSOR;
 CURSOR c_dept IS
 SELECT department_name,
 CURSOR (SELECT last_name
 FROM employees e
WHERE e.department_id = d.department_id)
 FROM departments d
 WHERE department_id IN (10,20,30,40);
 v_nume_dept departments.department_name%TYPE;
 v_cursor refcursor;
 v_nume_emp employees.last_name%TYPE;
BEGIN
 OPEN c_dept;
 LOOP
 FETCH c_dept INTO v_nume_dept, v_cursor;
 EXIT WHEN c_dept%NOTFOUND;
 DBMS_OUTPUT.PUT_LINE('-------------------------------------');
 DBMS_OUTPUT.PUT_LINE ('DEPARTAMENT '||v_nume_dept);
 DBMS_OUTPUT.PUT_LINE('-------------------------------------');
 LOOP
 FETCH v_cursor INTO v_nume_emp;
 EXIT WHEN v_cursor%NOTFOUND;
 DBMS_OUTPUT.PUT_LINE (v_nume_emp);
 END LOOP;
 END LOOP;
 CLOSE c_dept;
END;
/

--11 Cursor dinamic (poate fi deschis pentru mai multe tipuri de SELECT-uri)
DECLARE
 TYPE emp_tip IS REF CURSOR;
 v_emp emp_tip;
 v_optiune NUMBER := &p_optiune;
 v_ang employees%ROWTYPE;
BEGIN
 IF v_optiune = 1 THEN
 OPEN v_emp FOR SELECT *
 FROM employees;
 ELSIF v_optiune = 2 THEN
 OPEN v_emp FOR SELECT *
 FROM employees
 WHERE salary BETWEEN 10000 AND 20000;
 ELSIF v_optiune = 3 THEN
 OPEN v_emp FOR SELECT *
 FROM employees
 WHERE TO_CHAR(hire_date, 'YYYY') = 2000;
 ELSE
 DBMS_OUTPUT.PUT_LINE('Optiune incorecta');
 END IF;

 LOOP
 FETCH v_emp into v_ang;
 EXIT WHEN v_emp%NOTFOUND;
 DBMS_OUTPUT.PUT_LINE(v_ang.last_name);
 END LOOP;

 DBMS_OUTPUT.PUT_LINE('Au fost procesate '||v_emp%ROWCOUNT || ' linii');
 CLOSE v_emp;
END;
/


