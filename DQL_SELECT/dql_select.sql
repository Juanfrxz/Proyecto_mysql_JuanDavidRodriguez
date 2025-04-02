-- Campers

-- Consulta 1: Obtener todos los campers inscritos actualmente.
SELECT c.camper_id,
       CONCAT(c.nombres, ' ', c.apellidos) AS nombre_completo,
       e.nombre AS estado
FROM camper c
JOIN estado e ON c.estado_id = e.estado_id
WHERE e.nombre = 'Inscrito';


-- Consulta 2: Listar los campers con estado "Aprobado".
SELECT c.camper_id,
       CONCAT(c.nombres, ' ', c.apellidos) AS nombre_completo,
       e.nombre AS estado
FROM camper c
JOIN estado e ON c.estado_id = e.estado_id
WHERE e.nombre = 'Aprobado';


-- Consulta 3: Mostrar los campers que ya están cursando alguna ruta.
SELECT c.camper_id,
       CONCAT(c.nombres, ' ', c.apellidos) AS nombre_completo
FROM camper c
JOIN estado e ON c.estado_id = e.estado_id
WHERE e.nombre = 'Cursando';


-- Consulta 4: Consultar los campers graduados por cada ruta.
SELECT rt.nombre AS ruta,
       c.camper_id,
       CONCAT(c.nombres, ' ', c.apellidos) AS nombre_completo
FROM camper c
JOIN ruta_entrenamiento rt ON c.ruta_entrenamiento_id = rt.ruta_entrenamiento_id
JOIN estado e ON c.estado_id = e.estado_id
WHERE e.nombre = 'Graduado'
ORDER BY rt.nombre;


-- Consulta 5: Obtener los campers que se encuentran en estado "Expulsado" o "Retirado".
SELECT c.camper_id,
       CONCAT(c.nombres, ' ', c.apellidos) AS nombre_completo,
       e.nombre AS estado
FROM camper c
JOIN estado e ON c.estado_id = e.estado_id
WHERE e.nombre IN ('Expulsado', 'Retirado');


-- Consulta 6: Listar campers con nivel de riesgo "Alto".
SELECT c.camper_id,
       CONCAT(c.nombres, ' ', c.apellidos) AS nombre_completo,
       nr.nombre AS nivel_riesgo
FROM camper c
JOIN nivel_riesgo nr ON c.nivel_riesgo_id = nr.nivel_riesgo_id
WHERE nr.nombre = 'Alto';


-- Consulta 7: Mostrar el total de campers por cada nivel de riesgo.
SELECT nr.nombre AS nivel_riesgo,
       COUNT(*) AS total_campers
FROM camper c
JOIN nivel_riesgo nr ON c.nivel_riesgo_id = nr.nivel_riesgo_id
GROUP BY nr.nombre;


-- Consulta 8: Obtener campers con más de un número telefónico registrado.
SELECT c.camper_id,
       CONCAT(c.nombres, ' ', c.apellidos) AS nombre_completo,
       COUNT(ct.telefono_id) AS total_telefonos
FROM camper c
JOIN camper_telefono ct ON c.camper_id = ct.camper_id
GROUP BY c.camper_id, c.nombres, c.apellidos
HAVING COUNT(ct.telefono_id) > 1;


-- Consulta 9: Listar campers y sus respectivos acudientes y teléfonos.
SELECT c.camper_id,
       CONCAT(c.nombres, ' ', c.apellidos) AS camper,
       CONCAT(a.nombre, ' ', a.apellido) AS acudiente,
       t.numero AS telefono
FROM camper c
JOIN acudiente a ON c.acudiente_id = a.acudiente_id
JOIN camper_telefono ct ON c.camper_id = ct.camper_id
JOIN telefono t ON ct.telefono_id = t.telefono_id;


-- Consulta 10: Mostrar campers que aún no han sido asignados a una ruta.
SELECT camper_id,
       CONCAT(nombres, ' ', apellidos) AS nombre_completo
FROM camper
WHERE ruta_entrenamiento_id IS NULL;

-- 📊 Evaluaciones

-- 1. Obtener las notas teóricas, prácticas y quizzes de cada camper por módulo
SELECT 
    CONCAT(c.nombres, ' ', c.apellidos) AS camper,
    m.nombre AS modulo,
    e.nota_teorica,
    e.nota_practica,
    e.nota_trabajo AS nota_quiz
FROM evaluacion e
JOIN camper c ON e.camper_id = c.camper_id
JOIN modulo m ON e.modulo_id = m.modulo_id
ORDER BY camper, modulo;

-- 2. Calcular la nota final de cada camper por módulo
SELECT 
    CONCAT(c.nombres, ' ', c.apellidos) AS camper,
    m.nombre AS modulo,
    ROUND((e.nota_teorica * 0.3 + e.nota_practica * 0.6 + e.nota_trabajo * 0.1), 2) AS nota_final
FROM evaluacion e
JOIN camper c ON e.camper_id = c.camper_id
JOIN modulo m ON e.modulo_id = m.modulo_id
ORDER BY nota_final DESC;

-- 3. Mostrar los campers que reprobaron algún módulo (nota < 60)
SELECT 
    CONCAT(c.nombres, ' ', c.apellidos) AS camper,
    m.nombre AS modulo,
    e.nota_final
FROM evaluacion e
JOIN camper c ON e.camper_id = c.camper_id
JOIN modulo m ON e.modulo_id = m.modulo_id
WHERE e.nota_final < 60
ORDER BY e.nota_final;

-- 4. Listar los módulos con más campers en bajo rendimiento
SELECT 
    m.nombre AS modulo,
    COUNT(*) AS campers_reprobados
FROM evaluacion e
JOIN modulo m ON e.modulo_id = m.modulo_id
WHERE e.nota_final < 60
GROUP BY m.modulo_id, m.nombre
ORDER BY campers_reprobados DESC;

-- 5. Obtener el promedio de notas finales por cada módulo
SELECT 
    m.nombre AS modulo,
    ROUND(AVG(e.nota_final), 2) AS promedio_modulo
FROM evaluacion e
JOIN modulo m ON e.modulo_id = m.modulo_id
GROUP BY m.modulo_id, m.nombre
ORDER BY promedio_modulo DESC;

-- 6. Consultar el rendimiento general por ruta de entrenamiento
SELECT 
    r.nombre AS ruta,
    ROUND(AVG(e.nota_final), 2) AS promedio_ruta,
    MIN(e.nota_final) AS nota_minima,
    MAX(e.nota_final) AS nota_maxima,
    COUNT(DISTINCT e.camper_id) AS total_campers
FROM evaluacion e
JOIN ruta_entrenamiento r ON e.ruta_entrenamiento_id = r.ruta_entrenamiento_id
GROUP BY r.ruta_entrenamiento_id, r.nombre
ORDER BY promedio_ruta DESC;

-- 7. Mostrar los trainers responsables de campers con bajo rendimiento
SELECT 
    CONCAT(t.nombre, ' ', t.apellido) AS trainer,
    COUNT(DISTINCT e.camper_id) AS campers_reprobados
FROM evaluacion e
JOIN asignacion_trainer at ON e.ruta_entrenamiento_id = at.ruta_entrenamiento_id
JOIN trainers t ON at.trainer_id = t.trainer_id
WHERE e.nota_final < 60
GROUP BY t.trainer_id, t.nombre, t.apellido
ORDER BY campers_reprobados DESC;

-- 8. Comparar el promedio de rendimiento por trainer
SELECT 
    CONCAT(t.nombre, ' ', t.apellido) AS trainer,
    ROUND(AVG(e.nota_final), 2) AS promedio_notas,
    COUNT(DISTINCT e.camper_id) AS total_campers
FROM evaluacion e
JOIN asignacion_trainer at ON e.ruta_entrenamiento_id = at.ruta_entrenamiento_id
JOIN trainers t ON at.trainer_id = t.trainer_id
GROUP BY t.trainer_id, t.nombre, t.apellido
ORDER BY promedio_notas DESC;

-- 9. Listar los mejores 5 campers por nota final en cada ruta
WITH RankedCampers AS (
    SELECT 
        r.nombre AS ruta,
        CONCAT(c.nombres, ' ', c.apellidos) AS camper,
        e.nota_final,
        ROW_NUMBER() OVER (PARTITION BY r.ruta_entrenamiento_id ORDER BY e.nota_final DESC) AS rn
    FROM evaluacion e
    JOIN camper c ON e.camper_id = c.camper_id
    JOIN ruta_entrenamiento r ON e.ruta_entrenamiento_id = r.ruta_entrenamiento_id
)
SELECT 
    ruta,
    camper,
    nota_final
FROM RankedCampers
WHERE rn <= 5
ORDER BY ruta, nota_final DESC;

-- 10. Mostrar cuántos campers pasaron cada módulo por ruta
SELECT 
    r.nombre AS ruta,
    m.nombre AS modulo,
    COUNT(DISTINCT CASE WHEN e.nota_final >= 60 THEN e.camper_id END) AS campers_aprobados,
    COUNT(DISTINCT e.camper_id) AS total_campers,
    ROUND((COUNT(DISTINCT CASE WHEN e.nota_final >= 60 THEN e.camper_id END) * 100.0 / 
           COUNT(DISTINCT e.camper_id)), 2) AS porcentaje_aprobacion
FROM evaluacion e
JOIN ruta_entrenamiento r ON e.ruta_entrenamiento_id = r.ruta_entrenamiento_id
JOIN modulo m ON e.modulo_id = m.modulo_id
GROUP BY r.ruta_entrenamiento_id, r.nombre, m.modulo_id, m.nombre
ORDER BY r.nombre, porcentaje_aprobacion DESC;

-- 🧭 Rutas y Áreas de Entrenamiento

-- 1. Mostrar todas las rutas de entrenamiento disponibles
SELECT 
    r.ruta_entrenamiento_id,
    r.nombre AS nombre_ruta,
    h.hora_inicio,
    h.hora_fin
FROM ruta_entrenamiento r
JOIN horario h ON r.horario_id = h.horario_id;

-- 2. Obtener las rutas con su SGDB principal y alternativo
SELECT 
    r.nombre AS ruta,
    sg.nombre AS sgbd_principal,
    GROUP_CONCAT(DISTINCT sg2.nombre) AS sgbd_alternativos
FROM ruta_entrenamiento r
JOIN sistema_gestion_bd sg ON r.sistema_gestion_id = sg.sistema_gestion_id
LEFT JOIN ruta_modulo rm ON r.ruta_entrenamiento_id = rm.ruta_entrenamiento_id
LEFT JOIN modulo m ON rm.modulo_id = m.modulo_id
LEFT JOIN sistema_gestion_bd sg2 ON sg2.sistema_gestion_id != r.sistema_gestion_id
GROUP BY r.ruta_entrenamiento_id, sg.nombre;

-- 3. Listar los módulos asociados a cada ruta
SELECT 
    r.nombre AS ruta,
    GROUP_CONCAT(m.nombre) AS modulos
FROM ruta_entrenamiento r
JOIN ruta_modulo rm ON r.ruta_entrenamiento_id = rm.ruta_entrenamiento_id
JOIN modulo m ON rm.modulo_id = m.modulo_id
GROUP BY r.ruta_entrenamiento_id, r.nombre;

-- 4. Consultar cuántos campers hay en cada ruta
SELECT 
    r.nombre AS ruta,
    COUNT(c.camper_id) AS total_campers
FROM ruta_entrenamiento r
LEFT JOIN camper c ON r.ruta_entrenamiento_id = c.ruta_entrenamiento_id
GROUP BY r.ruta_entrenamiento_id, r.nombre;

-- 5. Mostrar las áreas de entrenamiento y su capacidad máxima
SELECT 
    nombre AS area,
    capacidad AS capacidad_maxima,
    salon
FROM area_entrenamiento
ORDER BY capacidad DESC;

-- 6. Obtener las áreas que están ocupadas al 100%
SELECT 
    ae.nombre AS area,
    ae.capacidad AS capacidad_maxima,
    ac.capacidad_actual,
    ROUND((ac.capacidad_actual * 100.0 / ae.capacidad), 2) AS porcentaje_ocupacion
FROM area_entrenamiento ae
JOIN area_capacidad ac ON ae.area_id = ac.area_id
WHERE ac.capacidad_actual = ae.capacidad;

-- 7. Verificar la ocupación actual de cada área
SELECT 
    ae.nombre AS area,
    ae.capacidad AS capacidad_maxima,
    COALESCE(ac.capacidad_actual, 0) AS ocupacion_actual,
    ROUND((COALESCE(ac.capacidad_actual, 0) * 100.0 / ae.capacidad), 2) AS porcentaje_ocupacion
FROM area_entrenamiento ae
LEFT JOIN area_capacidad ac ON ae.area_id = ac.area_id
ORDER BY porcentaje_ocupacion DESC;

-- 8. Consultar los horarios disponibles por cada área
SELECT 
    ae.nombre AS area,
    h.hora_inicio,
    h.hora_fin,
    CASE 
        WHEN ar.area_id IS NULL THEN 'Disponible'
        ELSE 'Ocupado'
    END AS estado
FROM area_entrenamiento ae
CROSS JOIN horario h
LEFT JOIN area_ruta ar ON ae.area_id = ar.area_id AND h.horario_id = ar.horario_id
ORDER BY ae.nombre, h.hora_inicio;

-- 9. Mostrar las áreas con más campers asignados
SELECT 
    ae.nombre AS area,
    COUNT(DISTINCT c.camper_id) AS total_campers
FROM area_entrenamiento ae
JOIN area_ruta ar ON ae.area_id = ar.area_id
JOIN ruta_entrenamiento r ON ar.ruta_entrenamiento_id = r.ruta_entrenamiento_id
JOIN camper c ON r.ruta_entrenamiento_id = c.ruta_entrenamiento_id
GROUP BY ae.area_id, ae.nombre
ORDER BY total_campers DESC;

-- 10. Listar las rutas con sus respectivos trainers y áreas asignadas
SELECT 
    r.nombre AS ruta,
    GROUP_CONCAT(DISTINCT CONCAT(t.nombre, ' ', t.apellido)) AS trainers,
    GROUP_CONCAT(DISTINCT ae.nombre) AS areas_asignadas
FROM ruta_entrenamiento r
LEFT JOIN asignacion_trainer at ON r.ruta_entrenamiento_id = at.ruta_entrenamiento_id
LEFT JOIN trainers t ON at.trainer_id = t.trainer_id
LEFT JOIN area_ruta ar ON r.ruta_entrenamiento_id = ar.ruta_entrenamiento_id
LEFT JOIN area_entrenamiento ae ON ar.area_id = ae.area_id
GROUP BY r.ruta_entrenamiento_id, r.nombre;

-- 🤵 Trainers

-- 1. Listar todos los entrenadores registrados
SELECT 
    t.trainer_id,
    CONCAT(t.nombre, ' ', t.apellido) AS nombre_completo,
    tel.numero AS telefono,
    d.direccion
FROM trainers t
JOIN trainer_telefono tt ON t.trainer_id = tt.trainer_id
JOIN telefono tel ON tt.telefono_id = tel.telefono_id
JOIN direccion d ON t.direccion_id = d.direccion_id;

-- 2. Mostrar los trainers con sus horarios asignados
SELECT 
    CONCAT(t.nombre, ' ', t.apellido) AS trainer,
    h.hora_inicio,
    h.hora_fin,
    r.nombre AS ruta
FROM trainers t
JOIN asignacion_trainer at ON t.trainer_id = at.trainer_id
JOIN horario h ON at.horario_id = h.horario_id
JOIN ruta_entrenamiento r ON at.ruta_entrenamiento_id = r.ruta_entrenamiento_id
ORDER BY trainer, hora_inicio;

-- 3. Consultar los trainers asignados a más de una ruta
SELECT 
    CONCAT(t.nombre, ' ', t.apellido) AS trainer,
    COUNT(DISTINCT at.ruta_entrenamiento_id) AS total_rutas
FROM trainers t
JOIN asignacion_trainer at ON t.trainer_id = at.trainer_id
GROUP BY t.trainer_id, t.nombre, t.apellido
HAVING COUNT(DISTINCT at.ruta_entrenamiento_id) > 1;

-- 4. Obtener el número de campers por trainer
SELECT 
    CONCAT(t.nombre, ' ', t.apellido) AS trainer,
    COUNT(DISTINCT c.camper_id) AS total_campers
FROM trainers t
JOIN asignacion_trainer at ON t.trainer_id = at.trainer_id
JOIN ruta_entrenamiento r ON at.ruta_entrenamiento_id = r.ruta_entrenamiento_id
JOIN camper c ON r.ruta_entrenamiento_id = c.ruta_entrenamiento_id
GROUP BY t.trainer_id, t.nombre, t.apellido
ORDER BY total_campers DESC;

-- 5. Mostrar las áreas en las que trabaja cada trainer
SELECT 
    CONCAT(t.nombre, ' ', t.apellido) AS trainer,
    GROUP_CONCAT(DISTINCT ae.nombre) AS areas
FROM trainers t
JOIN asignacion_trainer at ON t.trainer_id = at.trainer_id
JOIN area_ruta ar ON at.ruta_entrenamiento_id = ar.ruta_entrenamiento_id
JOIN area_entrenamiento ae ON ar.area_id = ae.area_id
GROUP BY t.trainer_id, t.nombre, t.apellido;

-- 6. Listar los trainers sin asignación de área o ruta
SELECT 
    CONCAT(t.nombre, ' ', t.apellido) AS trainer
FROM trainers t
LEFT JOIN asignacion_trainer at ON t.trainer_id = at.trainer_id
WHERE at.trainer_id IS NULL;

-- 7. Mostrar cuántos módulos están a cargo de cada trainer
SELECT 
    CONCAT(t.nombre, ' ', t.apellido) AS trainer,
    COUNT(DISTINCT m.modulo_id) AS total_modulos,
    GROUP_CONCAT(DISTINCT m.nombre) AS modulos
FROM trainers t
JOIN asignacion_trainer at ON t.trainer_id = at.trainer_id
JOIN ruta_modulo rm ON at.ruta_entrenamiento_id = rm.ruta_entrenamiento_id
JOIN modulo m ON rm.modulo_id = m.modulo_id
GROUP BY t.trainer_id, t.nombre, t.apellido;

-- 8. Obtener el trainer con mejor rendimiento promedio de campers
SELECT 
    CONCAT(t.nombre, ' ', t.apellido) AS trainer,
    ROUND(AVG(e.nota_final), 2) AS promedio_rendimiento,
    COUNT(DISTINCT e.camper_id) AS total_campers
FROM trainers t
JOIN asignacion_trainer at ON t.trainer_id = at.trainer_id
JOIN evaluacion e ON at.ruta_entrenamiento_id = e.ruta_entrenamiento_id
GROUP BY t.trainer_id, t.nombre, t.apellido
ORDER BY promedio_rendimiento DESC;

-- 9. Consultar los horarios ocupados por cada trainer
SELECT 
    CONCAT(t.nombre, ' ', t.apellido) AS trainer,
    h.hora_inicio,
    h.hora_fin,
    r.nombre AS ruta,
    ae.nombre AS area
FROM trainers t
JOIN asignacion_trainer at ON t.trainer_id = at.trainer_id
JOIN horario h ON at.horario_id = h.horario_id
JOIN ruta_entrenamiento r ON at.ruta_entrenamiento_id = r.ruta_entrenamiento_id
JOIN area_ruta ar ON r.ruta_entrenamiento_id = ar.ruta_entrenamiento_id
JOIN area_entrenamiento ae ON ar.area_id = ae.area_id
ORDER BY trainer, hora_inicio;

-- 10. Mostrar la disponibilidad semanal de cada trainer
SELECT 
    CONCAT(t.nombre, ' ', t.apellido) AS trainer,
    GROUP_CONCAT(DISTINCT CONCAT(h.hora_inicio, ' - ', h.hora_fin) ORDER BY h.hora_inicio) AS horarios_asignados,
    COUNT(DISTINCT at.horario_id) AS total_horarios
FROM trainers t
LEFT JOIN asignacion_trainer at ON t.trainer_id = at.trainer_id
LEFT JOIN horario h ON at.horario_id = h.horario_id
GROUP BY t.trainer_id, t.nombre, t.apellido
ORDER BY total_horarios DESC;



