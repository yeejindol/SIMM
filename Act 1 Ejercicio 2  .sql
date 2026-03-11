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
-- 5. Subtypes of Alumne: AlumneGrau & AlumneMaster
CREATE OR REPLACE TYPE AlumneGrau UNDER Alumne (
    titulacio VARCHAR2(100),
    durada NUMBER,
    any_1a_matricula NUMBER,
    MEMBER FUNCTION anys_restants RETURN NUMBER,
    CONSTRUCTOR FUNCTION AlumneGrau(
        codi NUMBER, dni VARCHAR2, nom VARCHAR2, adreca VARCHAR2, telefon VARCHAR2, 
        num_expedient VARCHAR2, correu VARCHAR2, data_naixement DATE, titulacio VARCHAR2
    ) RETURN SELF AS RESULT
);
/
CREATE OR REPLACE TYPE BODY AlumneGrau AS
    MEMBER FUNCTION anys_restants RETURN NUMBER IS
        anys_transcorreguts NUMBER;
    BEGIN
        anys_transcorreguts := EXTRACT(YEAR FROM SYSDATE) - self.any_1a_matricula;
        RETURN self.durada - anys_transcorreguts;
    END;

    -- Constructor setting default values for durada and any_1a_matricula
    CONSTRUCTOR FUNCTION AlumneGrau(
        codi NUMBER, dni VARCHAR2, nom VARCHAR2, adreca VARCHAR2, telefon VARCHAR2, 
        num_expedient VARCHAR2, correu VARCHAR2, data_naixement DATE, titulacio VARCHAR2
    ) RETURN SELF AS RESULT IS
    BEGIN
        self.codi := codi;
        self.dni := dni;
        self.nom := nom;
        self.adreca := adreca;
        self.telefon := telefon;
        self.num_expedient := num_expedient;
        self.correu := correu;
        self.data_naixement := data_naixement;
        self.titulacio := titulacio;
        self.durada := 4;
        self.any_1a_matricula := EXTRACT(YEAR FROM SYSDATE);
        RETURN;
    END;
END;
/

CREATE OR REPLACE TYPE AlumneMaster UNDER Alumne (
    programa VARCHAR2(100),
    especialitat VARCHAR2(100),
    num_moduls NUMBER,
    MEMBER FUNCTION resum_estudis RETURN VARCHAR2,
    -- Custom Constructor
    CONSTRUCTOR FUNCTION AlumneMaster(
        codi NUMBER, dni VARCHAR2, nom VARCHAR2, adreca VARCHAR2, telefon VARCHAR2, 
        num_expedient VARCHAR2, correu VARCHAR2, data_naixement DATE
    ) RETURN SELF AS RESULT
);
/

CREATE OR REPLACE TYPE BODY AlumneMaster AS
    MEMBER FUNCTION resum_estudis RETURN VARCHAR2 IS
    BEGIN
        RETURN self.programa || ' - ' || self.especialitat || ' (' || self.num_moduls || ' moduls)';
    END;

    -- Constructor setting default values for programa, especialitat and num_moduls
    CONSTRUCTOR FUNCTION AlumneMaster(
        codi NUMBER, dni VARCHAR2, nom VARCHAR2, adreca VARCHAR2, telefon VARCHAR2, 
        num_expedient VARCHAR2, correu VARCHAR2, data_naixement DATE
    ) RETURN SELF AS RESULT IS
    BEGIN
        self.codi := codi;
        self.dni := dni;
        self.nom := nom;
        self.adreca := adreca;
        self.telefon := telefon;
        self.num_expedient := num_expedient;
        self.correu := correu;
        self.data_naixement := data_naixement;
        self.programa := 'Màster en Enginyeria del Software';
        self.especialitat := 'Arquitectura';
        self.num_moduls := 10;
        RETURN;
    END;
END;
/


-- Create an object table for each class
CREATE TABLE Taula_Persona OF PERSONA;
CREATE TABLE Taula_Empleat OF Empleat;
CREATE TABLE Taula_Alumne OF Alumne;
CREATE TABLE Taula_Investigador OF Investigador;
CREATE TABLE Taula_Administratiu OF Administratiu;
CREATE TABLE Taula_AlumneGrau OF AlumneGrau;
CREATE TABLE Taula_AlumneMaster OF AlumneMaster;


-- Insert data using standard and custom constructors
INSERT INTO Taula_Persona VALUES (
    PERSONA(1, '11111111A', 'Joan', 'Carrer 1', '600111111')
);

INSERT INTO Taula_Empleat VALUES (
    Empleat(2, '22222222B', 'Maria', 'Carrer 2', '600222222', 2000, TO_DATE('2015-05-10', 'YYYY-MM-DD'), 'maria@corp.com', 'IT')
);

INSERT INTO Taula_Alumne VALUES (
    Alumne(3, '33333333C', 'Pere', 'Carrer 3', '600333333', 'EXP-001', 'pere@uni.edu', TO_DATE('2000-08-20', 'YYYY-MM-DD'))
);

INSERT INTO Taula_Investigador VALUES (
    Investigador(4, '44444444D', 'Anna', 'Carrer 4', '600444444', 2500, TO_DATE('2018-01-15', 'YYYY-MM-DD'), 'anna@corp.com', 'Recerca', 'IA', 12)
);

INSERT INTO Taula_Administratiu VALUES (
    Administratiu(5, '55555555E', 'Lluis', 'Carrer 5', '600555555', 1500, TO_DATE('2020-03-01', 'YYYY-MM-DD'), 'lluis@corp.com', 'RRHH', 'Secretari', 'Completa')
);

-- Using the custom constructors for Grau and Master
INSERT INTO Taula_AlumneGrau VALUES (
    AlumneGrau(6, '66666666F', 'Laura', 'Carrer 6', '600666666', 'EXP-002', 'laura@uni.edu', TO_DATE('2004-11-10', 'YYYY-MM-DD'), 'Enginyeria Informatica')
);

INSERT INTO Taula_AlumneMaster VALUES (
    AlumneMaster(7, '77777777G', 'Pol', 'Carrer 7', '600777777', 'EXP-003', 'pol@uni.edu', TO_DATE('1998-02-25', 'YYYY-MM-DD'))
);




     

