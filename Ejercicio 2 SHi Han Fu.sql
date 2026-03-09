-- 1. Base Type: PERSONA
CREATE OR REPLACE TYPE PERSONA AS OBJECT (
    codi NUMBER,
    dni VARCHAR2(20),
    nom VARCHAR2(100),
    adreca VARCHAR2(200),
    telefon VARCHAR2(20)
) NOT FINAL;
/

-- 2. Subtype: Empleat
CREATE OR REPLACE TYPE Empleat UNDER PERSONA (
     sou   NUMBER,
     data_contracte DATE,
     correu_corporatiu VARCHAR2(100),
     departament VARCHAR2(50),
    MEMBER FUNCTION antiguitat RETURN NUMBER
) NOT FINAL;
/


CREATE OR REPLACE TYPE BODY Empleat AS
 
    MEMBER FUNCTION antiguitat RETURN NUMBER IS
    BEGIN
        RETURN EXTRACT(YEAR FROM SYSDATE) - EXTRACT(YEAR FROM self.data_contracte);
    END;
END;
/

-- 3. Subtype: Alumne
CREATE OR REPLACE TYPE Alumne UNDER PERSONA (
    num_expedient VARCHAR2(20),
    correu VARCHAR2(100),
    data_naixement DATE,
    MEMBER FUNCTION edat RETURN NUMBER
) NOT FINAL;
/

CREATE OR REPLACE TYPE BODY Alumne AS
  
    MEMBER FUNCTION edat RETURN NUMBER IS
    BEGIN
        RETURN EXTRACT(YEAR FROM SYSDATE) - EXTRACT(YEAR FROM self.data_naixement);
    END;
END;
/

-- 4. Subtypes of Empleat: Investigador & Administratiu
CREATE OR REPLACE TYPE Investigador UNDER Empleat (
    especialitat VARCHAR2(100),
    num_publicacions NUMBER,
    MEMBER FUNCTION nivell_recerca RETURN VARCHAR2
);
/

CREATE OR REPLACE TYPE BODY Investigador AS
    
    MEMBER FUNCTION nivell_recerca RETURN VARCHAR2 IS
    BEGIN
        IF self.num_publicacions < 5 THEN
            RETURN 'Inicial';
        ELSIF self.num_publicacions <= 15 THEN
            RETURN 'Consolidat';
        ELSE
            RETURN 'Senior';
        END IF;
    END;
END;
/

CREATE OR REPLACE TYPE Administratiu UNDER Empleat (
    carrec VARCHAR2(50),
    tipus_jornada VARCHAR2(50),
    MEMBER FUNCTION sou_anual RETURN NUMBER
);
/

CREATE OR REPLACE TYPE BODY Administratiu AS
   
    MEMBER FUNCTION sou_anual RETURN NUMBER IS
    BEGIN
        RETURN self.sou * 14;
    END;
END;
/



     
