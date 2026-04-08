-- 1. Crear el objeto de Dirección
CREATE OR REPLACE TYPE T_ADRECA AS OBJECT (
    carrer VARCHAR2(50),
    ciutat VARCHAR2(10),
    codi_postal NUMBER
);
/

-- 2. Crear el objeto de Teléfono
CREATE OR REPLACE TYPE T_TELEFON AS OBJECT (
    tipus VARCHAR2(20),
    numero VARCHAR2(15)
);
/

-- 3. Crear el array de Teléfonos
CREATE OR REPLACE TYPE T_VEC_TELEFONS AS VARRAY(2) OF T_TELEFON;
/

-- 4. Crear el objeto Proveedor
CREATE OR REPLACE TYPE T_PROVEIDOR AS OBJECT (
    codi NUMBER,
    nom VARCHAR2(50),
    adreca T_ADRECA,
    vec_telefons T_VEC_TELEFONS,
    correu_electronic VARCHAR2(50)
);
/

-- 5. Crear el objeto Material
CREATE OR REPLACE TYPE T_MATERIAL AS OBJECT (
    codi NUMBER,
    nom VARCHAR2(50),
    descripcio VARCHAR2(200),
    cost_unitari NUMBER(5,2)
);
/

-- 6. Crear el objeto Línea de Compra
CREATE OR REPLACE TYPE T_LINIA_COMPRA AS OBJECT (
    codi NUMBER,
    ref_material REF T_MATERIAL,
    quantitat NUMBER,
    descompte NUMBER,
    MEMBER FUNCTION subtotal RETURN NUMBER 
);
/

-- 6-1. Implementar la lógica del método subtotal
CREATE OR REPLACE TYPE BODY T_LINIA_COMPRA AS
    MEMBER FUNCTION subtotal RETURN NUMBER IS v_material T_MATERIAL;
    BEGIN
        SELECT DEREF(ref_material) INTO v_material FROM DUAL;
        RETURN (quantitat * v_material.cost_unitari) - descompte;
    END;
END;
/

-- 7. Crear el array para las líneas de compra
CREATE OR REPLACE TYPE T_linies AS VARRAY(100) OF T_LINIA_COMPRA;
/

-- 8. Crear el objeto Compra
CREATE OR REPLACE TYPE T_COMPRA AS OBJECT (
    codi NUMBER, 
    data_compra NUMBER,
    ref_proveidor REF T_PROVEIDOR,
    taula_linies T_linies,
    MEMBER FUNCTION cost_total RETURN NUMBER 
);
/

-- 8-1. Implementar la lógica del método cost_total
CREATE OR REPLACE TYPE BODY T_COMPRA AS
    MEMBER FUNCTION cost_total RETURN NUMBER IS v_total NUMBER; 
    BEGIN
        SELECT SUM(l.subtotal()) INTO v_total
        FROM TABLE(self.taula_linies) l;
        RETURN v_total;
    END;
END;
/

-- 9. Crear las tablas físicas basadas en los objetos
CREATE TABLE TB_Materiales OF T_MATERIAL(PRIMARY KEY(codi));
CREATE TABLE TB_Proveidores OF T_PROVEIDOR(PRIMARY KEY(codi));
CREATE TABLE TB_Compras OF T_COMPRA(PRIMARY KEY(codi));

-- T3: Inserción de datos
INSERT INTO TB_Materiales VALUES (T_MATERIAL(1, 'Cargol', 'Cargol de ferro 5mm', 0.50));
INSERT INTO TB_Materiales VALUES (T_MATERIAL(2, 'Martell', 'Martell de fuster', 15.00));

INSERT INTO TB_Proveidores VALUES (
    T_PROVEIDOR(100, 'Ferreteria Central', 
    T_ADRECA('Carrer Major 10', 'BCN', 8001), 
    T_VEC_TELEFONS(T_TELEFON('Fix', '933445566'), T_TELEFON('Mobil', '600112233')),'info@ferreteria.com')
);

INSERT INTO TB_Compras VALUES (
    T_COMPRA(5001, 20260311, 
    (SELECT REF(p) FROM TB_Proveidores p WHERE codi = 100),
    T_linies(
        T_LINIA_COMPRA(1, (SELECT REF(m) FROM TB_Materiales m WHERE codi = 1), 100, 5),
        T_LINIA_COMPRA(2, (SELECT REF(m) FROM TB_Materiales m WHERE codi = 2), 2, 0)
    ))
);

COMMIT;

-- T4: Llamar a los métodos a través de una consulta

-- Consulta del coste total de la compra (Factura)
SELECT c.codi AS factura_id, c.cost_total() AS total_factura
FROM TB_Compras c;

-- Consulta de los subtotales de cada línea de la compra
SELECT c.codi AS compra_id, l.codi AS linia_id, l.subtotal() AS subtotal_linia
FROM TB_Compras c, TABLE(c.taula_linies) l;