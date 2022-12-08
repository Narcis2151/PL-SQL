SET SERVEROUTPUT ON

DECLARE
    X NUMBER(1) := 5;
    Y X%TYPE := NULL;
BEGIN
    IF X <> Y THEN
        DBMS_OUTPUT.PUT_LINE ('valoare <> null este = true');
    ELSE
        DBMS_OUTPUT.PUT_LINE ('valoare <> null este != true');
    END IF;
    X := NULL;
    IF X = Y THEN
        DBMS_OUTPUT.PUT_LINE ('null = null este = true');
    ELSE
        DBMS_OUTPUT.PUT_LINE ('null = null este != true');
    END IF;
END;
/


CREATE OR REPLACE TYPE SUBORDONATI_FNA AS
    VARRAY(
        10
    ) OF NUMBER(
        4
    );
/

CREATE TABLE MANAGERI_FNA (
    COD_MGR NUMBER(10),
    NUME VARCHAR2(20),
    LISTA SUBORDONATI_FNA
);

DECLARE
    V_SUB   SUBORDONATI_FNA:= SUBORDONATI_FNA(100, 200, 300);
    V_LISTA MANAGERI_FNA.LISTA%TYPE;
BEGIN
    INSERT INTO MANAGERI_FNA VALUES (
        1,
        'Mgr 1',
        V_SUB
    );
    INSERT INTO MANAGERI_FNA VALUES (
        2,
        'Mgr 2',
        NULL
    );
    INSERT INTO MANAGERI_FNA VALUES (
        3,
        'Mgr 3',
        SUBORDONATI_FNA(400, 500)
    );
    SELECT
        LISTA INTO V_LISTA
    FROM
        MANAGERI_FNA
    WHERE
        COD_MGR=1;
    FOR J IN V_LISTA.FIRST..V_LISTA.LAST LOOP
        DBMS_OUTPUT.PUT_LINE (V_LISTA(J));
    END LOOP;
END;
/
SELECT * FROM EMP_FNA;
/

DROP TABLE MANAGERI_FNA;

DROP TYPE SUBORDONATI_FNA;

SELECT
    *
FROM
    DEPARTMENTS;
SET SERVEROUTPUT OFF;


DECLARE
 TYPE tablou_indexat IS TABLE OF NUMBER INDEX BY PLS_INTEGER;
 t tablou_indexat;
BEGIN
-- punctul a
 FOR i IN 1..10 LOOP
 t(i):=i;
 END LOOP;
 DBMS_OUTPUT.PUT('Tabloul are ' || t.COUNT ||' elemente: ');
 FOR i IN t.FIRST..t.LAST LOOP
 DBMS_OUTPUT.PUT(t(i) || ' ');
 END LOOP;
 DBMS_OUTPUT.NEW_LINE;
-- punctul b
 FOR i IN 1..10 LOOP
 IF i mod 2 = 1 THEN t(i):=null;
 END IF;
 END LOOP;
 DBMS_OUTPUT.PUT('Tabloul are ' || t.COUNT ||' elemente: ');
FOR i IN t.FIRST..t.LAST LOOP
 DBMS_OUTPUT.PUT(nvl(t(i), 0) || ' ');
 END LOOP;
 DBMS_OUTPUT.NEW_LINE;
-- punctul c
 t.DELETE(t.first);
 t.DELETE(5,7);
 t.DELETE(t.last);
 DBMS_OUTPUT.PUT_LINE('Primul element are indicele ' || t.first ||
 ' si valoarea ' || nvl(t(t.first),0));
DBMS_OUTPUT.PUT_LINE('Ultimul element are indicele ' || t.last ||
 ' si valoarea ' || nvl(t(t.last),0));
 DBMS_OUTPUT.PUT('Tabloul are ' || t.COUNT ||' elemente: ');
 FOR i IN t.FIRST..t.LAST LOOP
 IF t.EXISTS(i) THEN
 DBMS_OUTPUT.PUT(nvl(t(i), 0)|| ' ');
 END IF;
 END LOOP;
 DBMS_OUTPUT.NEW_LINE;
-- punctul d
 t.delete;
 DBMS_OUTPUT.PUT_LINE('Tabloul are ' || t.COUNT ||' elemente.');
END;
/