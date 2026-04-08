CREATE OR REPLACE TYPE Client AS OBJECT(
    nif VARCHAR2(10),
    nom VARCHAR2(10),
    adreca VARCHAR2(10),
    telefon VARCHAR2(12),
    MEMBER FUNCTION numCursos RETURN NUMBER 
);
/

CREATE TABLE taula_clients OF Client (
    nif PRIMARY KEY
);
/

CREATE OR REPLACE TYPE Curs AS OBJECT(
    idCurs VARCHAR2(10),
    nom VARCHAR2(10),
    hores NUMBER,
    preu NUMBER,
    MEMBER FUNCTION coordinador RETURN VARCHAR2,
    MEMBER FUNCTION actiu RETURN VARCHAR2
)NOT FINAL;
/

CREATE TABLE taula_cursos OF Curs (
    idCurs PRIMARY KEY
);
/

CREATE OR REPLACE TYPE Empleat AS OBJECT(
    dni VARCHAR2(10),
    nom VARCHAR2(10),
    cognoms VARCHAR2(10),
    dataContracte DATE,
    telefon VARCHAR2(12),
    MEMBER FUNCTION antiguitat RETURN NUMBER

) NOT FINAL;
/

CREATE TABLE taula_empleats OF Empleat (
    dni PRIMARY KEY
);
/

CREATE OR REPLACE TYPE CursActiu UNDER Curs(
dataInici DATE, 
dataFiPrevista DATE,
modalitat VARCHAR2(10),
MEMBER FUNCTION modulActual RETURN VARCHAR2
);
/

CREATE OR REPLACE TYPE CursHistoric UNDER Curs(
 dataFinal DATE,
 valoracio NUMBER
);
/

CREATE OR REPLACE TYPE Formador UNDER Empleat(
    especialitat VARCHAR2(10),
    nivell VARCHAR2(10)
);
/

CREATE OR REPLACE TYPE Coordinador UNDER Empleat(
   area VARCHAR2(10),
   despatx VARCHAR2(10)
);
/

CREATE OR REPLACE TYPE Tecnic UNDER Empleat(
 certificacio VARCHAR2(10),
 sistema VARCHAR2(10)
);
/

CREATE OR REPLACE TYPE Modul AS OBJECT(
idModul VARCHAR2(10),
nom VARCHAR2(10),
dataInici DATE,
dataFi DATE,
MEMBER FUNCTION numCursos RETURN NUMBER
);
/

CREATE TABLE taula_moduls OF Modul (
    idModul PRIMARY KEY
);
/

CREATE OR REPLACE TYPE Coordina AS OBJECT (
    ref_curs REF Curs,
    ref_empleat REF Empleat
);
/

CREATE OR REPLACE TYPE Participa AS OBJECT (
    ref_curs REF Curs,
    ref_empleat REF Empleat
);
/

CREATE OR REPLACE TYPE ModulsCurs AS OBJECT (
    ref_cursActiu REF CursActiu,
    ref_modul REF Modul
);
/

CREATE TABLE taula_coordina OF Coordina;
/

CREATE TABLE taula_participa OF Participa;
/

CREATE TABLE taula_moduls_curs OF ModulsCurs;
/

--Insertar datos en clientes
INSERT INTO taula_clientes VALUES ('Y12345678' ,'Ana', 'Calle Marina 134', '12345678');
INSERT INTO taula_clientes VALUES ('Z12368692', 'Joan', 'Avenida Selva 14' , '11223344');

--Insertar datos en módulos
INSERT INTO taula_moduls VALUES ('M123', 'Base de datos', '01-02-2026','01-05-2026');
INSERT INTO taula_moduls VALUES ('M122', 'Multimedia', '05-02-2026', '10-06-2026');

--Insertar datos en Empleados
INSERT INTO taula_empleats VALUES (Formador('17382S8N', 'Jose', 'Luis','10-10-2025','1123389'));
INSERT INTO taula_empleats VALUES (Coordinador('2678273B', 'Gerard', 'Perez','12-03-2026', '18392628'));
INSERT INTO taula_empleats VALUES (Tecnic('3782627G', 'Jordi', 'Vila','22-02-2022', '67822828'));

-- Insertar datos en Cursos (incluyendo CursActiu y CursHistoric)
INSERT INTO taula_cursos VALUES (CursActiu('C01', 'Java OO', 100, 500, TO_DATE('01-01-2026','DD-MM-YYYY'), TO_DATE('01-06-2026','DD-MM-YYYY'), 'Online'));
INSERT INTO taula_cursos VALUES (CursHistoric('C02', 'SQL Basic', 40, 150, TO_DATE('20-12-2025','DD-MM-YYYY'), 9));

-- Insertar datos en la tabla Coordina (Asociación Curs y Empleat)
INSERT INTO taula_coordina SELECT REF(c), REF(e) 
FROM taula_cursos c, taula_empleats e 
WHERE c.idCurs = 'C01' AND e.dni = '2678273B';

-- Insertar datos en la tabla Participa (Asociación Curs y Empleat)
INSERT INTO taula_participa SELECT REF(c), REF(e) 
FROM taula_cursos c, taula_empleats e 
WHERE c.idCurs = 'C01' AND e.dni = '17382S8N';

-- Insertar datos en la tabla ModulsCurs (Asociación CursActiu y Modul)
INSERT INTO taula_moduls_curs SELECT TREAT(REF(c) AS REF CursActiu), REF(m) 
FROM taula_cursos c, taula_moduls m 
WHERE c.idCurs = 'C01' AND m.idModul = 'M123';


-- IMPLEMENTAR LOS METODOS DE LAS CLASES CON CREATE OR REPLACE TYPE BODY

-- 1. Metodo coordinador, muestrará el nombre y apellidos del coordinador del curso.
CREATE OR REPLACE TYPE BODY Curs AS 
    MEMBER FUNCTION coordinador RETURN VARCHAR2 IS 
        nombre VARCHAR2(25);
        apellidos VARCHAR2(25); 
    BEGIN
         SELECT DEREF(tc.ref_empleat).nom, DEREF(tc.ref_empleat).cognoms
        INTO nombre, apellidos
        FROM taula_coordina tc
        WHERE DEREF(tc.ref_curs).idCurs = SELF.idCurs;
        
        RETURN nombre || ' ' || apellidos;
        
    EXCEPTION WHEN NO_DATA_FOUND THEN RETURN 'Sin asignar';
    END;
     MEMBER FUNCTION actiu RETURN VARCHAR2 IS
        v_conteo NUMBER;
    BEGIN
         SELECT COUNT(*) INTO v_conteo 
        FROM taula_cursos c 
        WHERE c.idCurs = SELF.idCurs 
        AND VALUE(c) IS OF (CursActiu);

        IF v_conteo > 0 THEN 
            RETURN 'T'; 
        ELSE 
            RETURN 'F'; 
        END IF;
    END;
END;
/


--2. Metodo antiguidad, calculará la diferencia en años entre sysdate(hoy) y dataContracte
CREATE OR REPLACE TYPE BODY Empleat AS
    MEMBER FUNCTION antiguitat RETURN NUMBER IS
        BEGIN
            RETURN FLOOR(MONTHS_BETWEEN(SYSDATE, SELF.dataContracte) / 12);
        END;
    END;

--4. Metodo ModulActual, torna el nombre del modulo del curso activo que tiene como dataFi= null

CREATE OR REPLACE TYPE BODY CursActiu AS
    MEMBER FUNCTION ModulActual RETURN VARCHAR IS
        nom VARCHAR(50);
    BEGIN
        SELECT DEREF(t.ref_modul).nom INTO nom
        FROM taula_moduls_curs t
        WHERE DEREF(t.ref_cursActiu).idCurs = SELF.idCurs
        AND DEREF(t.ref_modul).dataFi IS NULL;
        
        RETURN nom;
    
    EXCEPTION WHEN NO_DATA_FOUND THEN RETURN 'Cap';
    END;
    
END;

--6. Metodo numCursos de Modul que cuenta cuantos cursos aparece

CREATE OR REPLACE TYPE BODY Client AS
   MEMBER FUNCTION numCursos RETURN NUMBER IS
        v_total NUMBER;
    BEGIN
        SELECT COUNT(*) INTO v_total 
        FROM taula_participa tp
        WHERE DEREF(tp.ref_curs).idCurs IS NOT NULL;
        
        RETURN v_total;
    END;
END;
/
-- 7. Mètode numCursos de Modul (Correcció)
CREATE OR REPLACE TYPE BODY Modul AS
    MEMBER FUNCTION numCursos RETURN NUMBER IS
        v_total NUMBER;
    BEGIN
        SELECT COUNT(*) INTO v_total 
        FROM taula_moduls_curs
        WHERE DEREF(ref_modul).idModul = SELF.idModul;
        
        RETURN v_total;
    END;
END;
/

--COMPROBAR QUE FUNCIONAN BIEN


--1. Ver cuantos cursos tiene cada cliente
SELECT nom, nif, numCursos()
FROM taula_cursos c
WHERE VALUE(c) IS OF (CursActiu);

--2. Ver si los cursos están activos o no

SELECT nom, actiu() AS es_activo
FROM taula_cursos;

--3. Ver modulo actual de los cursos que si estan activos
SELECT c.nom, TREAT(VALUE(c) AS CursActiu).modulActual() AS modulo_hoy
FROM taula_cursos c
WHERE VALUE(c) IS OF (CursActiu);

--4.Ver modulo actual de los cursos activos
SELECT nom, TREAT(VALUE(c) AS CursActiu).modulActual() AS modulo_activo
FROM taula_cursos c
WHERE VALUE(c) IS OF (CursActiu);

--5. Ver en cuantos cursos aperece cada modulo
SELECT nom, numCursos() AS aparecido
FROM taula_moduls

--6. Ver nombre del coordinado y si el curso es activo
SELECT nom, coordinadir() AS responsable, actiu() AS activo
FROM taula_cursos;





