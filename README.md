# Prueba Técnica - Ingeniería de Datos (Tuya)

Repositorio que contiene la solución desarrollada para la prueba técnica, abarcando la normalización de datos en Python y la resolución de consultas analíticas avanzadas en MySQL.

---

## 🛠️ Tecnologías Utilizadas
* **Python** (Pandas, SQLAlchemy, PyMySQL) para el preprocesamiento, limpieza e ingesta de los archivos de Excel.
* **MySQL 8.0+** como motor de base de datos relacional.
* **SQL Avanzado** (CTEs Recursivas, Funciones de Ventana y técnica *Gaps and Islands*).

---

## 🚀 Metodología y Desarrollo de los Ejercicios

### 1. Ingesta y Normalización (Python)
Se desarrolló un flujo en Python para garantizar la calidad de los datos antes de llevarlos a la base de datos:
* **Estandarización:** Normalización de campos de identificación.
* **Validación de Fechas:** Conversión estricta a formato de fecha para un control temporal preciso.
* **Limpieza de Saldos:** Tratamiento de valores faltantes y rellenado con ceros según las reglas de negocio.

### 2. Análisis de Rachas y Niveles de Deuda (SQL Avanzado)
La solución en SQL resuelve la lógica de negocio requerida:
* **Relleno de Meses (Gap Filling):** Uso de **CTEs Recursivas (`WITH RECURSIVE`)** para generar un calendario dinámico por cliente, respetando la excepción de la fecha de retiro (`LEAST` y `COALESCE`).
* **Clasificación de Niveles:** Evaluación de rangos de saldos (N0 a N4), asignando nivel `N0` por defecto a los períodos sin aparición.
* **Técnica de Rachas (*Gaps and Islands*):** Agrupación de meses consecutivos mediante la diferencia de funciones de ventana (`ROW_NUMBER()`).
* **Filtros y Desempates:** Uso de variables de sesión (`@fecha_base` y `@n`) y ordenamiento jerárquico (`ORDER BY racha DESC, fecha_fin DESC`) para resolver desempates.