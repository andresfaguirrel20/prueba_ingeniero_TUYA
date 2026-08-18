use tuya_prueba_db;


SET @fecha_base = '2024-12-31';
SET @n = 4;

WITH RECURSIVE 
clientes AS (
    SELECT 
        s.identificacion,
        MIN(s.corte_mes) AS primera_aparicion,
        LEAST(DATE(@fecha_base), COALESCE(MAX(r.fecha_retiro), DATE(@fecha_base))) AS limite_mes -- hasta donde se mira un cliente
    FROM saldos_historicos s
    LEFT JOIN retiros r ON s.identificacion = r.identificacion
    GROUP BY s.identificacion
),
calendario_clientes AS (
    SELECT 
        identificacion, 
        primera_aparicion AS corte_mes, 
        limite_mes
    FROM clientes
    WHERE primera_aparicion <= limite_mes
    UNION ALL
    SELECT 
        identificacion, 
        LAST_DAY(corte_mes + INTERVAL 1 MONTH), 
        limite_mes
    FROM calendario_clientes
    WHERE LAST_DAY(corte_mes + INTERVAL 1 MONTH) <= limite_mes
),
clasificacion_niveles AS (
    SELECT 
        c.identificacion,
        c.corte_mes,
        COALESCE(s.saldo, 0) AS saldo_real,
        CASE 
            WHEN COALESCE(s.saldo, 0) >= 0 AND COALESCE(s.saldo, 0) < 300000 THEN 'N0'
            WHEN COALESCE(s.saldo, 0) >= 300000 AND COALESCE(s.saldo, 0) < 1000000 THEN 'N1'
            WHEN COALESCE(s.saldo, 0) >= 1000000 AND COALESCE(s.saldo, 0) < 3000000 THEN 'N2'
            WHEN COALESCE(s.saldo, 0) >= 3000000 AND COALESCE(s.saldo, 0) < 5000000 THEN 'N3'
            WHEN COALESCE(s.saldo, 0) >= 5000000 THEN 'N4'
        END AS nivel
    FROM calendario_clientes c
    LEFT JOIN saldos_historicos s 
        ON c.identificacion = s.identificacion 
        AND c.corte_mes = s.corte_mes
),
agrupacion_islas AS (
    SELECT 
        identificacion,
        corte_mes,
        nivel,
        -- AQUI OCURRE LA LOGICA DE LA GENERACION DE LOS GRUPOS
        ROW_NUMBER() OVER(PARTITION BY identificacion ORDER BY corte_mes) 
        - ROW_NUMBER() OVER(PARTITION BY identificacion, nivel ORDER BY corte_mes) AS id_racha
    FROM clasificacion_niveles
),
rachas AS (
    SELECT 
        identificacion,
        nivel,
        COUNT(*) AS racha,
        min(corte_mes) as fecha_inicio,
        MAX(corte_mes) AS fecha_fin
    FROM agrupacion_islas
    GROUP BY 
        identificacion,
        nivel,
        id_racha
),
ranking_final AS (
    SELECT 
        identificacion,
        racha,
        fecha_fin,
        nivel,
        ROW_NUMBER() OVER(
            PARTITION BY identificacion 
            ORDER BY racha DESC, fecha_fin DESC
        ) AS ranking_desempate
    FROM rachas
     WHERE racha >= @n -- or racha >= 1
)
SELECT 
    identificacion,
    racha,
    fecha_fin,
    nivel
FROM ranking_final
WHERE ranking_desempate = 1