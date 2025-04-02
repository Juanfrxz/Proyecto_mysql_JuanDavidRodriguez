-- 🔍 Consultas con JOINs Básicos (10 ejemplos)

-- 1. Obtener los nombres completos de los campers junto con el nombre de la ruta a la que están inscritos
SELECT 
    CONCAT(c.nombres, ' ', c.apellidos) AS nombre_completo,
    r.nombre AS ruta_entrenamiento
FROM camper c
LEFT JOIN ruta_entrenamiento r ON c.ruta_entrenamiento_id = r.ruta_entrenamiento_id
ORDER BY nombre_completo;

-- 2. Mostrar los campers con sus evaluaciones por cada módulo
SELECT 
    CONCAT(c.nombres, ' ', c.apellidos) AS camper,
    m.nombre AS modulo,
    e.nota_teorica,
    e.nota_practica,
    e.nota_trabajo AS quiz,
    e.nota_final
FROM camper c
JOIN evaluacion e ON c.camper_id = e.camper_id
JOIN modulo m ON e.modulo_id = m.modulo_id
ORDER BY camper, modulo;

-- 3. Listar todos los módulos que componen cada ruta de entrenamiento
SELECT 
    r.nombre AS ruta,
    GROUP_CONCAT(m.nombre) AS modulos
FROM ruta_entrenamiento r
JOIN ruta_modulo rm ON r.ruta_entrenamiento_id = rm.ruta_entrenamiento_id
JOIN modulo m ON rm.modulo_id = m.modulo_id
GROUP BY r.ruta_entrenamiento_id, r.nombre
ORDER BY ruta;

-- 4. Consultar las rutas con sus trainers asignados y las áreas
SELECT 
    r.nombre AS ruta,
    CONCAT(t.nombre, ' ', t.apellido) AS trainer,
    ae.nombre AS area
FROM ruta_entrenamiento r
JOIN asignacion_trainer at ON r.ruta_entrenamiento_id = at.ruta_entrenamiento_id
JOIN trainers t ON at.trainer_id = t.trainer_id
JOIN area_ruta ar ON r.ruta_entrenamiento_id = ar.ruta_entrenamiento_id
JOIN area_entrenamiento ae ON ar.area_id = ae.area_id
ORDER BY ruta, trainer, area;

-- 5. Mostrar los campers junto con el trainer responsable de su ruta actual
SELECT 
    CONCAT(c.nombres, ' ', c.apellidos) AS camper,
    r.nombre AS ruta,
    CONCAT(t.nombre, ' ', t.apellido) AS trainer
FROM camper c
JOIN ruta_entrenamiento r ON c.ruta_entrenamiento_id = r.ruta_entrenamiento_id
JOIN asignacion_trainer at ON r.ruta_entrenamiento_id = at.ruta_entrenamiento_id
JOIN trainers t ON at.trainer_id = t.trainer_id
ORDER BY camper;

-- 6. Obtener el listado de evaluaciones realizadas
SELECT 
    CONCAT(c.nombres, ' ', c.apellidos) AS camper,
    m.nombre AS modulo,
    r.nombre AS ruta,
    e.nota_final
FROM evaluacion e
JOIN camper c ON e.camper_id = c.camper_id
JOIN modulo m ON e.modulo_id = m.modulo_id
JOIN ruta_entrenamiento r ON e.ruta_entrenamiento_id = r.ruta_entrenamiento_id
ORDER BY camper, modulo;

-- 7. Listar los trainers y los horarios en que están asignados a las áreas
SELECT 
    CONCAT(t.nombre, ' ', t.apellido) AS trainer,
    ae.nombre AS area,
    h.hora_inicio,
    h.hora_fin
FROM trainers t
JOIN asignacion_trainer at ON t.trainer_id = at.trainer_id
JOIN area_ruta ar ON at.ruta_entrenamiento_id = ar.ruta_entrenamiento_id
JOIN area_entrenamiento ae ON ar.area_id = ae.area_id
JOIN horario h ON at.horario_id = h.horario_id
ORDER BY trainer, area;

-- 8. Consultar todos los campers junto con su estado actual y el nivel de riesgo
SELECT 
    CONCAT(c.nombres, ' ', c.apellidos) AS camper,
    e.nombre AS estado,
    nr.nombre AS nivel_riesgo
FROM camper c
JOIN estado e ON c.estado_id = e.estado_id
JOIN nivel_riesgo nr ON c.nivel_riesgo_id = nr.nivel_riesgo_id
ORDER BY camper;

-- 9. Obtener todos los módulos de cada ruta junto con sus porcentajes
SELECT 
    r.nombre AS ruta,
    m.nombre AS modulo,
    '30%' AS porcentaje_teorico,
    '60%' AS porcentaje_practico,
    '10%' AS porcentaje_quizzes
FROM ruta_entrenamiento r
JOIN ruta_modulo rm ON r.ruta_entrenamiento_id = rm.ruta_entrenamiento_id
JOIN modulo m ON rm.modulo_id = m.modulo_id
ORDER BY ruta, modulo;

-- 10. Mostrar los nombres de las áreas junto con los nombres de los campers
SELECT 
    ae.nombre AS area,
    GROUP_CONCAT(CONCAT(c.nombres, ' ', c.apellidos)) AS campers
FROM area_entrenamiento ae
JOIN area_ruta ar ON ae.area_id = ar.area_id
JOIN ruta_entrenamiento r ON ar.ruta_entrenamiento_id = r.ruta_entrenamiento_id
JOIN camper c ON r.ruta_entrenamiento_id = c.ruta_entrenamiento_id
GROUP BY ae.area_id, ae.nombre
ORDER BY area; 

-- 🔀 JOINs con condiciones específicas

-- 1. Listar los campers que han aprobado todos los módulos de su ruta
SELECT 
    CONCAT(c.nombres, ' ', c.apellidos) AS camper,
    r.nombre AS ruta,
    COUNT(DISTINCT e.modulo_id) AS modulos_aprobados,
    COUNT(DISTINCT rm.modulo_id) AS total_modulos
FROM camper c
JOIN ruta_entrenamiento r ON c.ruta_entrenamiento_id = r.ruta_entrenamiento_id
JOIN ruta_modulo rm ON r.ruta_entrenamiento_id = rm.ruta_entrenamiento_id
JOIN evaluacion e ON c.camper_id = e.camper_id AND e.modulo_id = rm.modulo_id
WHERE e.nota_final >= 60
GROUP BY c.camper_id, c.nombres, c.apellidos, r.ruta_entrenamiento_id, r.nombre
HAVING modulos_aprobados = total_modulos
ORDER BY camper;

-- 2. Mostrar las rutas que tienen más de 10 campers inscritos
SELECT 
    r.nombre AS ruta,
    COUNT(DISTINCT c.camper_id) AS total_campers
FROM ruta_entrenamiento r
JOIN camper c ON r.ruta_entrenamiento_id = c.ruta_entrenamiento_id
GROUP BY r.ruta_entrenamiento_id, r.nombre
HAVING total_campers > 10
ORDER BY total_campers DESC;

-- 3. Consultar las áreas que superan el 80% de su capacidad
SELECT 
    ae.nombre AS area,
    ae.capacidad AS capacidad_maxima,
    ac.capacidad_actual,
    ROUND((ac.capacidad_actual * 100.0 / ae.capacidad), 2) AS porcentaje_ocupacion
FROM area_entrenamiento ae
JOIN area_capacidad ac ON ae.area_id = ac.area_id
WHERE (ac.capacidad_actual * 100.0 / ae.capacidad) > 80
ORDER BY porcentaje_ocupacion DESC;

-- 4. Obtener los trainers que imparten más de una ruta
SELECT 
    CONCAT(t.nombre, ' ', t.apellido) AS trainer,
    COUNT(DISTINCT at.ruta_entrenamiento_id) AS total_rutas
FROM trainers t
JOIN asignacion_trainer at ON t.trainer_id = at.trainer_id
GROUP BY t.trainer_id, t.nombre, t.apellido
HAVING total_rutas > 1
ORDER BY total_rutas DESC;

-- 5. Listar las evaluaciones donde la nota práctica es mayor que la teórica
SELECT 
    CONCAT(c.nombres, ' ', c.apellidos) AS camper,
    m.nombre AS modulo,
    e.nota_teorica,
    e.nota_practica,
    e.nota_final
FROM evaluacion e
JOIN camper c ON e.camper_id = c.camper_id
JOIN modulo m ON e.modulo_id = m.modulo_id
WHERE e.nota_practica > e.nota_teorica
ORDER BY (e.nota_practica - e.nota_teorica) DESC;

-- 6. Mostrar campers que están en rutas con MySQL como SGDB principal
SELECT 
    CONCAT(c.nombres, ' ', c.apellidos) AS camper,
    r.nombre AS ruta,
    sg.nombre AS sgbd
FROM camper c
JOIN ruta_entrenamiento r ON c.ruta_entrenamiento_id = r.ruta_entrenamiento_id
JOIN sistema_gestion_bd sg ON r.sistema_gestion_id = sg.sistema_gestion_id
WHERE sg.nombre = 'MySQL'
ORDER BY camper;

-- 7. Obtener los módulos donde los campers han tenido bajo rendimiento
SELECT 
    m.nombre AS modulo,
    COUNT(DISTINCT CASE WHEN e.nota_final < 60 THEN e.camper_id END) AS campers_bajo_rendimiento,
    COUNT(DISTINCT e.camper_id) AS total_campers
FROM modulo m
JOIN evaluacion e ON m.modulo_id = e.modulo_id
GROUP BY m.modulo_id, m.nombre
HAVING campers_bajo_rendimiento > 0
ORDER BY campers_bajo_rendimiento DESC;

-- 8. Consultar las rutas con más de 3 módulos
SELECT 
    r.nombre AS ruta,
    COUNT(DISTINCT rm.modulo_id) AS total_modulos,
    GROUP_CONCAT(DISTINCT m.nombre) AS modulos
FROM ruta_entrenamiento r
JOIN ruta_modulo rm ON r.ruta_entrenamiento_id = rm.ruta_entrenamiento_id
JOIN modulo m ON rm.modulo_id = m.modulo_id
GROUP BY r.ruta_entrenamiento_id, r.nombre
HAVING total_modulos > 3
ORDER BY total_modulos DESC;

-- 9. Listar las inscripciones de los últimos 30 días
SELECT 
    CONCAT(c.nombres, ' ', c.apellidos) AS camper,
    r.nombre AS ruta,
    c.created_at AS fecha_inscripcion
FROM camper c
JOIN ruta_entrenamiento r ON c.ruta_entrenamiento_id = r.ruta_entrenamiento_id
WHERE c.created_at >= DATE_SUB(CURDATE(), INTERVAL 30 DAY)
ORDER BY fecha_inscripcion DESC;

-- 10. Obtener los trainers asignados a rutas con campers de alto riesgo
SELECT DISTINCT
    CONCAT(t.nombre, ' ', t.apellido) AS trainer,
    r.nombre AS ruta,
    COUNT(DISTINCT c.camper_id) AS campers_alto_riesgo
FROM trainers t
JOIN asignacion_trainer at ON t.trainer_id = at.trainer_id
JOIN ruta_entrenamiento r ON at.ruta_entrenamiento_id = r.ruta_entrenamiento_id
JOIN camper c ON r.ruta_entrenamiento_id = c.ruta_entrenamiento_id
JOIN nivel_riesgo nr ON c.nivel_riesgo_id = nr.nivel_riesgo_id
WHERE nr.nombre = 'Alto'
GROUP BY t.trainer_id, t.nombre, t.apellido, r.ruta_entrenamiento_id, r.nombre
ORDER BY campers_alto_riesgo DESC;

-- 🔎 JOINs con funciones de agregación

-- 1. Obtener el promedio de nota final por módulo
SELECT 
    m.nombre AS modulo,
    ROUND(AVG(e.nota_final), 2) AS promedio_nota,
    COUNT(DISTINCT e.camper_id) AS total_campers
FROM modulo m
JOIN evaluacion e ON m.modulo_id = e.modulo_id
GROUP BY m.modulo_id, m.nombre
ORDER BY promedio_nota DESC;

-- 2. Calcular la cantidad total de campers por ruta
SELECT 
    r.nombre AS ruta,
    COUNT(DISTINCT c.camper_id) AS total_campers,
    COUNT(DISTINCT CASE WHEN c.estado_id = 4 THEN c.camper_id END) AS campers_cursando
FROM ruta_entrenamiento r
LEFT JOIN camper c ON r.ruta_entrenamiento_id = c.ruta_entrenamiento_id
GROUP BY r.ruta_entrenamiento_id, r.nombre
ORDER BY total_campers DESC;

-- 3. Mostrar la cantidad de evaluaciones realizadas por cada trainer

SELECT 
    CONCAT(t.nombre, ' ', t.apellido) AS trainer,
    COUNT(DISTINCT CONCAT(e.camper_id, '-', e.ruta_entrenamiento_id, '-', e.modulo_id)) AS total_evaluaciones,
    COUNT(DISTINCT e.camper_id) AS campers_evaluados
FROM trainers t
JOIN asignacion_trainer at ON t.trainer_id = at.trainer_id
JOIN evaluacion e ON at.ruta_entrenamiento_id = e.ruta_entrenamiento_id
GROUP BY t.trainer_id, t.nombre, t.apellido
ORDER BY total_evaluaciones DESC;

-- 4. Consultar el promedio general de rendimiento por cada área
SELECT 
    ae.nombre AS area,
    ROUND(AVG(e.nota_final), 2) AS promedio_rendimiento,
    COUNT(DISTINCT e.camper_id) AS total_campers
FROM area_entrenamiento ae
JOIN area_ruta ar ON ae.area_id = ar.area_id
JOIN evaluacion e ON ar.ruta_entrenamiento_id = e.ruta_entrenamiento_id
GROUP BY ae.area_id, ae.nombre
ORDER BY promedio_rendimiento DESC;

-- 5. Obtener la cantidad de módulos asociados a cada ruta
SELECT 
    r.nombre AS ruta,
    COUNT(DISTINCT rm.modulo_id) AS total_modulos,
    GROUP_CONCAT(DISTINCT m.nombre) AS modulos
FROM ruta_entrenamiento r
LEFT JOIN ruta_modulo rm ON r.ruta_entrenamiento_id = rm.ruta_entrenamiento_id
LEFT JOIN modulo m ON rm.modulo_id = m.modulo_id
GROUP BY r.ruta_entrenamiento_id, r.nombre
ORDER BY total_modulos DESC;

-- 6. Mostrar el promedio de nota final de los campers en estado "Cursando"
SELECT 
    r.nombre AS ruta,
    ROUND(AVG(e.nota_final), 2) AS promedio_nota,
    COUNT(DISTINCT e.camper_id) AS total_campers
FROM ruta_entrenamiento r
JOIN camper c ON r.ruta_entrenamiento_id = c.ruta_entrenamiento_id
JOIN evaluacion e ON c.camper_id = e.camper_id
WHERE c.estado_id = 4 
GROUP BY r.ruta_entrenamiento_id, r.nombre
ORDER BY promedio_nota DESC;

-- 7. Listar el número de campers evaluados en cada módulo
SELECT 
    m.nombre AS modulo,
    COUNT(DISTINCT e.camper_id) AS campers_evaluados,
    COUNT(DISTINCT CASE WHEN e.nota_final >= 60 THEN e.camper_id END) AS campers_aprobados
FROM modulo m
JOIN evaluacion e ON m.modulo_id = e.modulo_id
GROUP BY m.modulo_id, m.nombre
ORDER BY campers_evaluados DESC;

-- 8. Consultar el porcentaje de ocupación actual por cada área
SELECT 
    ae.nombre AS area,
    ae.capacidad AS capacidad_maxima,
    ac.capacidad_actual,
    ROUND((ac.capacidad_actual * 100.0 / ae.capacidad), 2) AS porcentaje_ocupacion
FROM area_entrenamiento ae
JOIN area_capacidad ac ON ae.area_id = ac.area_id
ORDER BY porcentaje_ocupacion DESC;

-- 9. Mostrar cuántos trainers tiene asignados cada área
SELECT 
    ae.nombre AS area,
    COUNT(DISTINCT t.trainer_id) AS total_trainers,
    GROUP_CONCAT(DISTINCT CONCAT(t.nombre, ' ', t.apellido)) AS trainers
FROM area_entrenamiento ae
JOIN area_ruta ar ON ae.area_id = ar.area_id
JOIN asignacion_trainer at ON ar.ruta_entrenamiento_id = at.ruta_entrenamiento_id
JOIN trainers t ON at.trainer_id = t.trainer_id
GROUP BY ae.area_id, ae.nombre
ORDER BY total_trainers DESC;

-- 10. Listar las rutas que tienen más campers en riesgo alto
SELECT 
    r.nombre AS ruta,
    COUNT(DISTINCT CASE WHEN nr.nombre = 'Alto' THEN c.camper_id END) AS campers_riesgo_alto,
    COUNT(DISTINCT c.camper_id) AS total_campers,
    ROUND((COUNT(DISTINCT CASE WHEN nr.nombre = 'Alto' THEN c.camper_id END) * 100.0 / 
           COUNT(DISTINCT c.camper_id)), 2) AS porcentaje_riesgo_alto
FROM ruta_entrenamiento r
JOIN camper c ON r.ruta_entrenamiento_id = c.ruta_entrenamiento_id
JOIN nivel_riesgo nr ON c.nivel_riesgo_id = nr.nivel_riesgo_id
GROUP BY r.ruta_entrenamiento_id, r.nombre
HAVING campers_riesgo_alto > 0
ORDER BY campers_riesgo_alto DESC;