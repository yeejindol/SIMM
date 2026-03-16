
-- 1. Crear el objeto de Dirección
CREATE OR REPLACE TYPE ADRECA AS OBJECT (
    carrer VARCHAR2(50),
    ciutat VARCHAR2(10),
    codi_postal NUMBER
);
/

-- 2. Crear el objeto de Teléfono 
CREATE OR REPLACE TYPE TELEFON AS OBJECT (
    tipus VARCHAR2(20),
    numero VARCHAR2(15)
);
/

-- 3. Crear el array de Teléfonos
CREATE OR REPLACE TYPE VEC_TELEFONS AS VARRAY(2) OF TELEFON;
/

-- 4. Crear el objeto Proveedor
CREATE OR REPLACE TYPE PROVEIDOR AS OBJECT (
    codi NUMBER,
    nom VARCHAR2(50),
    adreca ADRECA,
    vec_telefons VEC_TELEFONS,
    correu_electronic VARCHAR2(50)
);
/

-- 5. Crear el objeto Material
CREATE OR REPLACE TYPE MATERIAL AS OBJECT (
    codi NUMBER,
    nom VARCHAR2(50),
    descripcio VARCHAR2(200),
    cost_unitari NUMBER(5,2)
);
/

-- 6. Crear el objeto Línea de Compra (Se añade la declaración del método subtotal)
CREATE OR REPLACE TYPE LINIA_COMPRA AS OBJECT (
    codi NUMBER,
    ref_material REF MATERIAL,
    quantitat NUMBER,
    descompte NUMBER,
    MEMBER FUNCTION subtotal RETURN NUMBER -- Declaración de la función
);
/

-- 6-1. Implementar la lógica del método subtotal para calcular el precio de la línea
CREATE OR REPLACE TYPE BODY LINIA_COMPRA AS
    MEMBER FUNCTION subtotal RETURN NUMBER IS v_material MATERIAL;
    BEGIN
        -- Obtener los datos del material usando la referencia (REF)
        SELECT DEREF(ref_material) INTO v_material FROM DUAL;
        -- Calcular: (cantidad * coste unitario) - descuento
        RETURN (quantitat * v_material.cost_unitari) - descompte;
    END;
END;
/

-- 7. Crear el array para las líneas de compra  
CREATE OR REPLACE TYPE linies AS VARRAY(100) OF LINIA_COMPRA;
/

-- 8. Crear el objeto Compra (Se añade la declaración del método cost_total)
CREATE OR REPLACE TYPE COMPRA AS OBJECT (
    codi NUMBER, 
    data_compra NUMBER,
    ref_proveidor REF PROVEIDOR,
    taula_linies linies,
    MEMBER FUNCTION cost_total RETURN NUMBER -- Declaración de la función
);
/

-- 8-1. Implementar la lógica del método cost_total 
CREATE OR REPLACE TYPE BODY COMPRA AS
    MEMBER FUNCTION cost_total RETURN NUMBER IS
        v_total NUMBER; -- Declarar variable básica
    BEGIN
        -- Usar la función SUM
        SELECT SUM(l.subtotal()) INTO v_total
        FROM TABLE(taula_linies) l;
        
        RETURN v_total;
    END;
END;
/

-- 9. Crear las tablas físicas basadas en los objetos
CREATE TABLE Materiales OF MATERIAL(PRIMARY KEY(codi));
CREATE TABLE Proveidores OF PROVEIDOR(PRIMARY KEY(codi));

-- Crear la tabla Compras
CREATE TABLE Compras OF COMPRA(PRIMARY KEY(codi));

-- Task 3: Inserción de datos


INSERT INTO Materiales VALUES (MATERIAL(1, 'Cargol', 'Cargol de ferro 5mm', 0.50));
INSERT INTO Materiales VALUES (MATERIAL(2, 'Martell', 'Martell de fuster', 15.00));

-- Corregido el orden de ADRECA: carrer, ciutat, codi_postal
INSERT INTO Proveidores VALUES (
    PROVEIDOR(100, 'Ferreteria Central', 
    ADRECA('Carrer Major 10', 'BCN', 8001), 
    VEC_TELEFONS(TELEFON('Fix', '933445566'), TELEFON('Mobil', '600112233')),'info@ferreteria.com')
);

INSERT INTO Compras VALUES (
    COMPRA(5001, 20260311, 
    (SELECT REF(p) FROM Proveidores p WHERE codi = 100),
    linies(
        LINIA_COMPRA(1, (SELECT REF(m) FROM Materiales m WHERE codi = 1), 100, 5), -- 100 unidades, 5€ descuento
        LINIA_COMPRA(2, (SELECT REF(m) FROM Materiales m WHERE codi = 2), 2, 0)    -- 2 unidades, 0 descuento
    ))
);

COMMIT;

-- Task 4: Llamar a los métodos a través de una consulta

-- Consulta del coste total de la compra (Factura)
SELECT c.codi, c.cost_total() AS total_factura
FROM Compras c;

-- Consulta de los subtotales de cada línea de la compra
SELECT c.codi AS compra_id, l.codi AS linia_id, l.subtotal() AS subtotal_linia
FROM Compras c, TABLE(c.taula_linies) l;