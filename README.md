# Test_NTT
# Preguntas teóricas:

## 1. ¿Qué es PL/SQL y cuál es su propósito en el desarrollo de aplicaciones?
**Respuesta:** PL/SQL es un lenguaje de programación diseñado para trabajar con bases de datos relacionales, utilizando el motor de bases de datos de Oracle. Su propósito principal es facilitar el desarrollo de procedimientos almacenados, funciones, triggers y consultas optimizadas.

## 2. Explique la diferencia entre un procedimiento almacenado y una función en PL/SQL.
**Respuesta:** Los procedimientos almacenados pueden aceptar diferentes tipos de parámetros tanto de entrada como de salida y no necesariamente devuelven valores. En cambio, las funciones sí retornan un valor que se puede utilizar en una consulta posteriormente.

## 3. ¿Qué es una excepción en PL/SQL y cómo se manejan?
**Respuesta:** Las excepciones son manejadores de errores que permiten validar el correcto funcionamiento en las transacciones principalmente. Se pueden condicionar estas excepciones para determinar cómo activar la excepción. Se manejan dentro de bloques con 'BEGIN' y 'END'.

# Ejercicios Prácticos:

## 4. Creación de una Tabla:
```sql
BEGIN
    EXECUTE IMMEDIATE ('drop table Empleados cascade constraints');
EXCEPTION
    WHEN OTHERS THEN
        NULL;
END;
/

CREATE TABLE Empleados (
    ID NUMBER PRIMARY KEY,
    Nombre VARCHAR2(50),
    Puesto VARCHAR2(50),
    Salario NUMBER
);
/
```
## 5. Procedimiento Almacenado: Aumentar Salario
```sql
CREATE OR REPLACE PROCEDURE AumentarSalario (
    p_id NUMBER,
    p_porcentaje_aumento NUMBER
)
AS
    v_salario_actual NUMBER;
BEGIN
    -- Primero consultamos y obtenemos el salario actual del empleado
    SELECT Salario INTO v_salario_actual FROM Empleados WHERE ID = p_id;

    -- Validamos que el empleado exista en la tabla
    IF v_salario_actual IS NULL THEN
        DBMS_OUTPUT.PUT_LINE('No existe el empleado con ID: ' || p_id);
        RETURN;
    END IF;

    -- Actualizamos el salario en la variable local
    v_salario_actual := v_salario_actual + (v_salario_actual * p_porcentaje_aumento / 100);

    -- Actualizamos el salario del empleado en la tabla
    UPDATE Empleados SET Salario = v_salario_actual WHERE ID = p_id;

EXCEPTION
    WHEN NO_DATA_FOUND THEN
        DBMS_OUTPUT.PUT_LINE('No existe el empleado con ID: ' || p_id);
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Ha ocurrido un error.');
END AumentarSalario;
/
```
## 6. Función: Calcular Bonificación
```sql
CREATE OR REPLACE FUNCTION CalcularBonificacion(
    p_Salario NUMBER
) RETURN NUMBER AS
    v_Bonificacion NUMBER;
BEGIN
    -- Calculamos la bonificación
    IF p_Salario <= 30000 THEN
        v_Bonificacion := p_Salario * 0.20;
    ELSIF p_Salario <= 50000 THEN
        v_Bonificacion := p_Salario * 0.15;
    ELSE
        v_Bonificacion := p_Salario * 0.10;
    END IF;

    -- Devolvemos el valor de la bonificación
    RETURN v_Bonificacion;
END CalcularBonificacion;
/
```
## 7. Triggers: Antes de Insertar Empleado
```sql
-- Primero creamos una secuencia para generar automáticamente el ID del empleado
CREATE SEQUENCE seq_empleados
    START WITH 1
    INCREMENT BY 1
    NOMAXVALUE
    NOCYCLE;
/

-- Creamos el trigger
CREATE OR REPLACE TRIGGER antes_de_insertar_empleado
BEFORE INSERT ON Empleados
FOR EACH ROW
BEGIN
    -- Se asigna el próximo valor de la secuencia al nuevo ID del empleado
    :NEW.ID := seq_empleados.NEXTVAL;
END antes_de_insertar_empleado;
/
```
## 8. Cursores y Colecciones: Obtener Ventas de Empleado
```sql
BEGIN
    EXECUTE IMMEDIATE ('drop table Ventas cascade constraints');
EXCEPTION
    WHEN OTHERS THEN
        NULL;
END;
/

-- Creamos la tabla Ventas
CREATE TABLE Ventas (
    ID_Venta NUMBER PRIMARY KEY,
    ID_Empleado NUMBER,
    Descripcion_Venta VARCHAR2(200),
    Valor_Venta NUMBER,
    FOREIGN KEY (ID_Empleado) REFERENCES Empleados(ID)
);
/

-- Creamos un tipo de registro para almacenar los resultados
CREATE OR REPLACE TYPE venta_registro AS OBJECT (
  ID_Venta NUMBER,
  Valor_Venta NUMBER
);
/

-- Creamos un tipo de tabla de registros
CREATE OR REPLACE TYPE venta_tabla AS TABLE OF venta_registro;
/

-- Creamos la función
CREATE OR REPLACE FUNCTION obtener_ventas_empleado(p_ID_Empleado NUMBER)
  RETURN venta_tabla
  PIPELINED
AS
  -- Declarar el cursor
  CURSOR cur_ventas IS
    SELECT ID_Venta, Valor_Venta
    FROM Ventas
    WHERE ID_Empleado = p_ID_Empleado;

  -- Declarar una variable del tipo de registro
  v_venta venta_registro;

BEGIN
  -- Recorrer el cursor y devolver los resultados como una colección
  FOR r_venta IN cur_ventas LOOP
    v_venta := venta_registro(r_venta.ID_Venta, r_venta.Valor_Venta);
    PIPE ROW(v_venta);
  END LOOP;

  -- Cerrar el cursor
  CLOSE cur_ventas;

  -- Terminar la función
  RETURN;
END obtener_ventas_empleado;
/
```
# 9. Consultas SQL:

## a. Seleccionar empleados con salarios entre 40000 y 60000
```sql
SELECT *
FROM Empleados
WHERE Salario BETWEEN 40000 AND 60000;
```
## b. Obtener salario promedio de todos los empleados
```sql
SELECT AVG(Salario) AS SalarioPromedio
FROM Empleados;
```
## c. Contar empleados con salario superior a 70000
```sql
SELECT COUNT(*) AS EmpleadosConSalarioSuperior
FROM Empleados
WHERE Salario > 70000;
```
