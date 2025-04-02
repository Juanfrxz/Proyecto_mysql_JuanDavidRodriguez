--🔍 Consultas con Subconsultas y Cálculos Avanzados (20 ejemplos)

-- 1. Obtener los campers con la nota más alta en cada módulo
WITH MaxNotas AS (
    SELECT 
        modulo_id,
        MAX(nota_final) as max_nota
    FROM evaluacion
    GROUP BY modulo_id
)
SELECT 
    m.nombre AS modulo,
    CONCAT(c.nombres, ' ', c.apellidos) AS camper,
    e.nota_final
FROM evaluacion e
JOIN camper c ON e.camper_id = c.camper_id
JOIN modulo m ON e.modulo_id = m.modulo_id
JOIN MaxNotas mn ON e.modulo_id = mn.modulo_id AND e.nota_final = mn.max_nota
ORDER BY m.nombre;

-- 2. Mostrar el promedio general de notas por ruta y comparar con el promedio global
WITH PromediosRuta AS (
    SELECT 
        r.nombre AS ruta,
        ROUND(AVG(e.nota_final), 2) AS promedio_ruta
    FROM evaluacion e
    JOIN ruta_entrenamiento r ON e.ruta_entrenamiento_id = r.ruta_entrenamiento_id
    GROUP BY r.ruta_entrenamiento_id, r.nombre
),
PromedioGlobal AS (
    SELECT ROUND(AVG(nota_final), 2) AS promedio_global
    FROM evaluacion
)
SELECT 
    pr.ruta,
    pr.promedio_ruta,
    pg.promedio_global,
    ROUND(pr.promedio_ruta - pg.promedio_global, 2) AS diferencia
FROM PromediosRuta pr
CROSS JOIN PromedioGlobal pg
ORDER BY diferencia DESC;

-- 3. Listar las áreas con más del 80% de ocupación
SELECT 
    ae.nombre AS area,
    ae.capacidad AS capacidad_maxima,
    COALESCE(ac.capacidad_actual, 0) AS ocupacion_actual,
    ROUND((COALESCE(ac.capacidad_actual, 0) * 100.0 / ae.capacidad), 2) AS porcentaje_ocupacion
FROM area_entrenamiento ae
LEFT JOIN area_capacidad ac ON ae.area_id = ac.area_id
HAVING porcentaje_ocupacion > 80
ORDER BY porcentaje_ocupacion DESC;

-- 4. Mostrar los trainers con menos del 70% de rendimiento promedio
SELECT 
    CONCAT(t.nombre, ' ', t.apellido) AS trainer,
    ROUND(AVG(e.nota_final), 2) AS promedio_rendimiento,
    COUNT(DISTINCT e.camper_id) AS total_campers
FROM trainers t
JOIN asignacion_trainer at ON t.trainer_id = at.trainer_id
JOIN evaluacion e ON at.ruta_entrenamiento_id = e.ruta_entrenamiento_id
GROUP BY t.trainer_id, t.nombre, t.apellido
HAVING promedio_rendimiento < 70
ORDER BY promedio_rendimiento;

-- 5. Consultar los campers cuyo promedio está por debajo del promedio general
WITH PromedioGlobal AS (
    SELECT AVG(nota_final) AS promedio_global
    FROM evaluacion
)
SELECT 
    CONCAT(c.nombres, ' ', c.apellidos) AS camper,
    ROUND(AVG(e.nota_final), 2) AS promedio_personal,
    pg.promedio_global
FROM camper c
JOIN evaluacion e ON c.camper_id = e.camper_id
CROSS JOIN PromedioGlobal pg
GROUP BY c.camper_id, c.nombres, c.apellidos, pg.promedio_global
HAVING promedio_personal < promedio_global
ORDER BY promedio_personal;

-- 6. Obtener los módulos con la menor tasa de aprobación
SELECT 
    m.nombre AS modulo,
    COUNT(DISTINCT CASE WHEN e.nota_final >= 60 THEN e.camper_id END) AS aprobados,
    COUNT(DISTINCT e.camper_id) AS total_campers,
    ROUND((COUNT(DISTINCT CASE WHEN e.nota_final >= 60 THEN e.camper_id END) * 100.0 / 
           COUNT(DISTINCT e.camper_id)), 2) AS tasa_aprobacion
FROM modulo m
JOIN evaluacion e ON m.modulo_id = e.modulo_id
GROUP BY m.modulo_id, m.nombre
ORDER BY tasa_aprobacion;

-- 7. Listar los campers que han aprobado todos los módulos de su ruta
WITH ModulosPorRuta AS (
    SELECT 
        r.ruta_entrenamiento_id,
        COUNT(DISTINCT rm.modulo_id) AS total_modulos
    FROM ruta_entrenamiento r
    JOIN ruta_modulo rm ON r.ruta_entrenamiento_id = rm.ruta_entrenamiento_id
    GROUP BY r.ruta_entrenamiento_id
),
ModulosAprobados AS (
    SELECT 
        c.camper_id,
        c.ruta_entrenamiento_id,
        COUNT(DISTINCT CASE WHEN e.nota_final >= 60 THEN e.modulo_id END) AS modulos_aprobados
    FROM camper c
    JOIN evaluacion e ON c.camper_id = e.camper_id
    GROUP BY c.camper_id, c.ruta_entrenamiento_id
)
SELECT 
    CONCAT(c.nombres, ' ', c.apellidos) AS camper,
    r.nombre AS ruta
FROM camper c
JOIN ruta_entrenamiento r ON c.ruta_entrenamiento_id = r.ruta_entrenamiento_id
JOIN ModulosPorRuta mpr ON c.ruta_entrenamiento_id = mpr.ruta_entrenamiento_id
JOIN ModulosAprobados ma ON c.camper_id = ma.camper_id
WHERE ma.modulos_aprobados = mpr.total_modulos;

-- 8. Mostrar rutas con más de 10 campers en bajo rendimiento
SELECT 
    r.nombre AS ruta,
    COUNT(DISTINCT CASE WHEN e.nota_final < 60 THEN e.camper_id END) AS campers_bajo_rendimiento
FROM ruta_entrenamiento r
JOIN evaluacion e ON r.ruta_entrenamiento_id = e.ruta_entrenamiento_id
GROUP BY r.ruta_entrenamiento_id, r.nombre
HAVING campers_bajo_rendimiento > 10
ORDER BY campers_bajo_rendimiento DESC;

-- 9. Calcular el promedio de rendimiento por SGDB principal
SELECT 
    sg.nombre AS sgbd,
    ROUND(AVG(e.nota_final), 2) AS promedio_rendimiento,
    COUNT(DISTINCT e.camper_id) AS total_campers
FROM sistema_gestion_bd sg
JOIN ruta_entrenamiento r ON sg.sistema_gestion_id = r.sistema_gestion_id
JOIN evaluacion e ON r.ruta_entrenamiento_id = e.ruta_entrenamiento_id
GROUP BY sg.sistema_gestion_id, sg.nombre
ORDER BY promedio_rendimiento DESC;

-- 10. Listar los módulos con al menos un 30% de campers reprobados
SELECT 
    m.nombre AS modulo,
    COUNT(DISTINCT CASE WHEN e.nota_final < 60 THEN e.camper_id END) AS reprobados,
    COUNT(DISTINCT e.camper_id) AS total_campers,
    ROUND((COUNT(DISTINCT CASE WHEN e.nota_final < 60 THEN e.camper_id END) * 100.0 / 
           COUNT(DISTINCT e.camper_id)), 2) AS porcentaje_reprobados
FROM modulo m
JOIN evaluacion e ON m.modulo_id = e.modulo_id
GROUP BY m.modulo_id, m.nombre
HAVING porcentaje_reprobados >= 30
ORDER BY porcentaje_reprobados DESC;

-- 11. Mostrar el módulo más cursado por campers con riesgo alto
SELECT 
    m.nombre AS modulo,
    COUNT(DISTINCT e.camper_id) AS total_campers_riesgo_alto
FROM modulo m
JOIN evaluacion e ON m.modulo_id = e.modulo_id
JOIN camper c ON e.camper_id = c.camper_id
JOIN nivel_riesgo nr ON c.nivel_riesgo_id = nr.nivel_riesgo_id
WHERE nr.nombre = 'Alto'
GROUP BY m.modulo_id, m.nombre
ORDER BY total_campers_riesgo_alto DESC
LIMIT 1;

-- 12. Consultar los trainers con más de 3 rutas asignadas
SELECT 
    CONCAT(t.nombre, ' ', t.apellido) AS trainer,
    COUNT(DISTINCT at.ruta_entrenamiento_id) AS total_rutas
FROM trainers t
JOIN asignacion_trainer at ON t.trainer_id = at.trainer_id
GROUP BY t.trainer_id, t.nombre, t.apellido
HAVING total_rutas > 3
ORDER BY total_rutas DESC;

-- 13. Listar los horarios más ocupados por áreas
SELECT 
    h.hora_inicio,
    h.hora_fin,
    COUNT(DISTINCT ar.area_id) AS areas_ocupadas,
    GROUP_CONCAT(DISTINCT ae.nombre) AS areas
FROM horario h
JOIN area_ruta ar ON h.horario_id = ar.horario_id
JOIN area_entrenamiento ae ON ar.area_id = ae.area_id
GROUP BY h.horario_id, h.hora_inicio, h.hora_fin
ORDER BY areas_ocupadas DESC;

-- 14. Consultar las rutas con el mayor número de módulos
SELECT 
    r.nombre AS ruta,
    COUNT(DISTINCT rm.modulo_id) AS total_modulos,
    GROUP_CONCAT(DISTINCT m.nombre) AS modulos
FROM ruta_entrenamiento r
JOIN ruta_modulo rm ON r.ruta_entrenamiento_id = rm.ruta_entrenamiento_id
JOIN modulo m ON rm.modulo_id = m.modulo_id
GROUP BY r.ruta_entrenamiento_id, r.nombre
ORDER BY total_modulos DESC;

-- 15. Obtener los campers que han cambiado de estado más de una vez
SELECT 
    CONCAT(c.nombres, ' ', c.apellidos) AS camper,
    COUNT(DISTINCT c.estado_id) AS cambios_estado,
    GROUP_CONCAT(DISTINCT e.nombre) AS estados
FROM camper c
JOIN estado e ON c.estado_id = e.estado_id
GROUP BY c.camper_id, c.nombres, c.apellidos
HAVING cambios_estado > 1
ORDER BY cambios_estado DESC;

-- 16. Mostrar las evaluaciones donde la nota teórica sea mayor a la práctica
SELECT 
    CONCAT(c.nombres, ' ', c.apellidos) AS camper,
    m.nombre AS modulo,
    e.nota_teorica,
    e.nota_practica,
    e.nota_final
FROM evaluacion e
JOIN camper c ON e.camper_id = c.camper_id
JOIN modulo m ON e.modulo_id = m.modulo_id
WHERE e.nota_teorica > e.nota_practica
ORDER BY (e.nota_teorica - e.nota_practica) DESC;

-- 17. Listar los módulos donde la media de quizzes supera el 9
SELECT 
    m.nombre AS modulo,
    ROUND(AVG(e.nota_trabajo), 2) AS promedio_quiz,
    COUNT(DISTINCT e.camper_id) AS total_campers
FROM modulo m
JOIN evaluacion e ON m.modulo_id = e.modulo_id
GROUP BY m.modulo_id, m.nombre
HAVING promedio_quiz > 9
ORDER BY promedio_quiz DESC;

-- 18. Consultar la ruta con mayor tasa de graduación
SELECT 
    r.nombre AS ruta,
    COUNT(DISTINCT CASE WHEN c.estado_id = 5 THEN c.camper_id END) AS graduados,
    COUNT(DISTINCT c.camper_id) AS total_campers,
    ROUND((COUNT(DISTINCT CASE WHEN c.estado_id = 5 THEN c.camper_id END) * 100.0 / 
           COUNT(DISTINCT c.camper_id)), 2) AS tasa_graduacion
FROM ruta_entrenamiento r
JOIN camper c ON r.ruta_entrenamiento_id = c.ruta_entrenamiento_id
GROUP BY r.ruta_entrenamiento_id, r.nombre
ORDER BY tasa_graduacion DESC;

-- 19. Mostrar los módulos cursados por campers de nivel de riesgo medio o alto
SELECT 
    m.nombre AS modulo,
    COUNT(DISTINCT e.camper_id) AS total_campers,
    COUNT(DISTINCT CASE WHEN nr.nombre IN ('Medio', 'Alto') THEN e.camper_id END) AS campers_riesgo
FROM modulo m
JOIN evaluacion e ON m.modulo_id = e.modulo_id
JOIN camper c ON e.camper_id = c.camper_id
JOIN nivel_riesgo nr ON c.nivel_riesgo_id = nr.nivel_riesgo_id
GROUP BY m.modulo_id, m.nombre
HAVING campers_riesgo > 0
ORDER BY campers_riesgo DESC;

-- 20. Obtener la diferencia entre capacidad y ocupación en cada área
SELECT 
    ae.nombre AS area,
    ae.capacidad AS capacidad_maxima,
    COALESCE(ac.capacidad_actual, 0) AS ocupacion_actual,
    ae.capacidad - COALESCE(ac.capacidad_actual, 0) AS espacios_disponibles,
    ROUND((COALESCE(ac.capacidad_actual, 0) * 100.0 / ae.capacidad), 2) AS porcentaje_ocupacion
FROM area_entrenamiento ae
LEFT JOIN area_capacidad ac ON ae.area_id = ac.area_id
ORDER BY espacios_disponibles DESC;