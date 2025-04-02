-- 🔍 Procedimientos Almacenados (20 ejemplos)

DELIMITER //

-- 1. Registrar un nuevo camper
CREATE PROCEDURE sp_registrar_camper(
    IN p_numero_identificacion VARCHAR(20),
    IN p_nombres VARCHAR(50),
    IN p_apellidos VARCHAR(50),
    IN p_sede_campus_id INT,
    IN p_direccion_id INT,
    IN p_acudiente_id INT,
    IN p_nivel_riesgo_id INT,
    IN p_estado_id INT
)
BEGIN
    INSERT INTO camper (
        numero_identificacion, nombres, apellidos, sede_campus_id,
        direccion_id, acudiente_id, nivel_riesgo_id, estado_id
    ) VALUES (
        p_numero_identificacion, p_nombres, p_apellidos, p_sede_campus_id,
        p_direccion_id, p_acudiente_id, p_nivel_riesgo_id, p_estado_id
    );
END //

-- 2. Actualizar estado de un camper
CREATE PROCEDURE sp_actualizar_estado_camper(
    IN p_camper_id INT,
    IN p_nuevo_estado_id INT
)
BEGIN
    UPDATE camper 
    SET estado_id = p_nuevo_estado_id
    WHERE camper_id = p_camper_id;
END //

-- 3. Procesar inscripción de camper a ruta
CREATE PROCEDURE sp_inscribir_camper_ruta(
    IN p_camper_id INT,
    IN p_ruta_entrenamiento_id INT,
    IN p_modulo_id INT
)
BEGIN
    UPDATE camper 
    SET ruta_entrenamiento_id = p_ruta_entrenamiento_id,
        modulo_id = p_modulo_id,
        estado_id = 4  -- Estado "Cursando"
    WHERE camper_id = p_camper_id;
END //

-- 4. Registrar evaluación completa
CREATE PROCEDURE sp_registrar_evaluacion(
    IN p_camper_id INT,
    IN p_ruta_entrenamiento_id INT,
    IN p_modulo_id INT,
    IN p_nota_teorica DECIMAL(5,2),
    IN p_nota_practica DECIMAL(5,2),
    IN p_nota_trabajo DECIMAL(5,2)
)
BEGIN
    DECLARE v_nota_final DECIMAL(5,2);
    
    SET v_nota_final = (p_nota_teorica * 0.3) + 
                      (p_nota_practica * 0.6) + 
                      (p_nota_trabajo * 0.1);
    
    INSERT INTO evaluacion (
        camper_id, ruta_entrenamiento_id, modulo_id,
        nota_teorica, nota_practica, nota_trabajo, nota_final
    ) VALUES (
        p_camper_id, p_ruta_entrenamiento_id, p_modulo_id,
        p_nota_teorica, p_nota_practica, p_nota_trabajo, v_nota_final
    );
END //

-- 5. Calcular y registrar nota final
CREATE PROCEDURE sp_calcular_nota_final(
    IN p_camper_id INT,
    IN p_modulo_id INT
)
BEGIN
    DECLARE v_nota_final DECIMAL(5,2);
    
    SELECT (nota_teorica * 0.3) + (nota_practica * 0.6) + (nota_trabajo * 0.1)
    INTO v_nota_final
    FROM evaluacion
    WHERE camper_id = p_camper_id AND modulo_id = p_modulo_id;
    
    UPDATE evaluacion
    SET nota_final = v_nota_final
    WHERE camper_id = p_camper_id AND modulo_id = p_modulo_id;
END //

-- 6. Asignar campers aprobados a ruta
CREATE PROCEDURE sp_asignar_campers_aprobados(
    IN p_ruta_entrenamiento_id INT,
    IN p_area_id INT
)
BEGIN
    DECLARE v_capacidad_disponible INT;
    
    SELECT ae.capacidad - COALESCE(ac.capacidad_actual, 0)
    INTO v_capacidad_disponible
    FROM area_entrenamiento ae
    LEFT JOIN area_capacidad ac ON ae.area_id = ac.area_id
    WHERE ae.area_id = p_area_id;
    
    IF v_capacidad_disponible > 0 THEN
        UPDATE camper c
        JOIN evaluacion e ON c.camper_id = e.camper_id
        SET c.ruta_entrenamiento_id = p_ruta_entrenamiento_id
        WHERE e.nota_final >= 60
        AND c.estado_id = 3  -- Estado "Aprobado"
        LIMIT v_capacidad_disponible;
        
        UPDATE area_capacidad
        SET capacidad_actual = capacidad_actual + v_capacidad_disponible
        WHERE area_id = p_area_id;
    END IF;
END //

-- 7. Asignar trainer a ruta y área
CREATE PROCEDURE sp_asignar_trainer(
    IN p_trainer_id INT,
    IN p_ruta_entrenamiento_id INT,
    IN p_area_id INT,
    IN p_horario_id INT
)
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM asignacion_trainer
        WHERE trainer_id = p_trainer_id
        AND horario_id = p_horario_id
    ) THEN
        INSERT INTO asignacion_trainer (
            trainer_id, ruta_entrenamiento_id, horario_id
        ) VALUES (
            p_trainer_id, p_ruta_entrenamiento_id, p_horario_id
        );
        
        INSERT INTO area_ruta (
            area_id, ruta_entrenamiento_id, horario_id
        ) VALUES (
            p_area_id, p_ruta_entrenamiento_id, p_horario_id
        );
    END IF;
END //

-- 8. Registrar nueva ruta
CREATE PROCEDURE sp_registrar_ruta(
    IN p_nombre VARCHAR(50),
    IN p_horario_id INT,
    IN p_backend_id INT,
    IN p_programacion_formal_id INT,
    IN p_sistema_gestion_id INT,
    IN p_modulos JSON
)
BEGIN
    DECLARE v_ruta_id INT;
    
    INSERT INTO ruta_entrenamiento (
        nombre, horario_id, backend_id,
        programacion_formal_id, sistema_gestion_id
    ) VALUES (
        p_nombre, p_horario_id, p_backend_id,
        p_programacion_formal_id, p_sistema_gestion_id
    );
    
    SET v_ruta_id = LAST_INSERT_ID();
    
    -- Insertar módulos asociados
    INSERT INTO ruta_modulo (ruta_entrenamiento_id, modulo_id)
    SELECT v_ruta_id, JSON_EXTRACT(p_modulos, CONCAT('$[', n, ']'))
    FROM JSON_TABLE(
        CONCAT('[', REPEAT('0,', JSON_LENGTH(p_modulos)-1), '0]'),
        '$[*]' COLUMNS (n INT PATH '$')
    ) AS numbers;
END //

-- 9. Registrar nueva área
CREATE PROCEDURE sp_registrar_area(
    IN p_nombre VARCHAR(50),
    IN p_capacidad INT,
    IN p_salon VARCHAR(50),
    IN p_horarios JSON
)
BEGIN
    DECLARE v_area_id INT;
    
    INSERT INTO area_entrenamiento (
        nombre, capacidad, salon
    ) VALUES (
        p_nombre, p_capacidad, p_salon
    );
    
    SET v_area_id = LAST_INSERT_ID();
    
    -- Insertar horarios asociados
    INSERT INTO horario_area (area_id, hora_inicio, hora_fin)
    SELECT v_area_id,
           TIME(JSON_EXTRACT(p_horarios, CONCAT('$[', n, '].inicio'))),
           TIME(JSON_EXTRACT(p_horarios, CONCAT('$[', n, '].fin')))
    FROM JSON_TABLE(
        CONCAT('[', REPEAT('0,', JSON_LENGTH(p_horarios)-1), '0]'),
        '$[*]' COLUMNS (n INT PATH '$')
    ) AS numbers;
END //

-- 10. Consultar disponibilidad de horario
CREATE PROCEDURE sp_consultar_disponibilidad(
    IN p_area_id INT,
    IN p_fecha DATE,
    IN p_horario_id INT
)
BEGIN
    SELECT 
        ae.nombre AS area,
        h.hora_inicio,
        h.hora_fin,
        ac.capacidad_actual,
        ae.capacidad AS capacidad_maxima
    FROM area_entrenamiento ae
    JOIN horario h ON p_horario_id = h.horario_id
    LEFT JOIN area_capacidad ac ON ae.area_id = ac.area_id
    WHERE ae.area_id = p_area_id;
END //

-- 11. Reasignar camper por bajo rendimiento
CREATE PROCEDURE sp_reasignar_camper(
    IN p_camper_id INT,
    IN p_nueva_ruta_id INT
)
BEGIN
    UPDATE camper 
    SET ruta_entrenamiento_id = p_nueva_ruta_id,
        modulo_id = 1,
        estado_id = 1 
    WHERE camper_id = p_camper_id;
END //

-- 12. Cambiar estado a Graduado
CREATE PROCEDURE sp_graduar_camper(
    IN p_camper_id INT
)
BEGIN
    DECLARE v_total_modulos INT;
    DECLARE v_modulos_aprobados INT;
    
    SELECT COUNT(DISTINCT rm.modulo_id)
    INTO v_total_modulos
    FROM camper c
    JOIN ruta_modulo rm ON c.ruta_entrenamiento_id = rm.ruta_entrenamiento_id
    WHERE c.camper_id = p_camper_id;
    
    SELECT COUNT(DISTINCT e.modulo_id)
    INTO v_modulos_aprobados
    FROM evaluacion e
    WHERE e.camper_id = p_camper_id
    AND e.nota_final >= 60;
    
    IF v_modulos_aprobados = v_total_modulos THEN
        UPDATE camper 
        SET estado_id = 5
        WHERE camper_id = p_camper_id;
        
        INSERT INTO egresados (camper_id, ruta_entrenamiento_id)
        SELECT camper_id, ruta_entrenamiento_id
        FROM camper
        WHERE camper_id = p_camper_id;
    END IF;
END //

-- 13. Consultar rendimiento de camper
CREATE PROCEDURE sp_consultar_rendimiento(
    IN p_camper_id INT
)
BEGIN
    SELECT 
        CONCAT(c.nombres, ' ', c.apellidos) AS camper,
        r.nombre AS ruta,
        m.nombre AS modulo,
        e.nota_teorica,
        e.nota_practica,
        e.nota_trabajo,
        e.nota_final
    FROM camper c
    JOIN ruta_entrenamiento r ON c.ruta_entrenamiento_id = r.ruta_entrenamiento_id
    JOIN evaluacion e ON c.camper_id = e.camper_id
    JOIN modulo m ON e.modulo_id = m.modulo_id
    WHERE c.camper_id = p_camper_id
    ORDER BY m.modulo_id;
END //

-- 14. Registrar asistencia
CREATE PROCEDURE sp_registrar_asistencia(
    IN p_camper_id INT,
    IN p_area_id INT,
    IN p_fecha DATE,
    IN p_hora_ingreso TIME,
    IN p_turno ENUM('Mañana', 'Tarde')
)
BEGIN
    INSERT INTO asistencia (
        camper_id, fecha, hora_ingreso, turno
    ) VALUES (
        p_camper_id, p_fecha, p_hora_ingreso, p_turno
    );
END //

-- 15. Generar reporte mensual
CREATE PROCEDURE sp_reporte_mensual(
    IN p_ruta_id INT,
    IN p_mes INT,
    IN p_anio INT
)
BEGIN
    SELECT 
        r.nombre AS ruta,
        m.nombre AS modulo,
        COUNT(DISTINCT e.camper_id) AS total_campers,
        ROUND(AVG(e.nota_final), 2) AS promedio_nota,
        COUNT(DISTINCT CASE WHEN e.nota_final >= 60 THEN e.camper_id END) AS aprobados,
        COUNT(DISTINCT CASE WHEN e.nota_final < 60 THEN e.camper_id END) AS reprobados
    FROM ruta_entrenamiento r
    JOIN evaluacion e ON r.ruta_entrenamiento_id = e.ruta_entrenamiento_id
    JOIN modulo m ON e.modulo_id = m.modulo_id
    WHERE r.ruta_entrenamiento_id = p_ruta_id
    AND MONTH(e.fecha) = p_mes
    AND YEAR(e.fecha) = p_anio
    GROUP BY r.ruta_entrenamiento_id, r.nombre, m.modulo_id, m.nombre;
END //

-- 16. Validar y registrar asignación de salón
CREATE PROCEDURE sp_asignar_salon(
    IN p_area_id INT,
    IN p_ruta_id INT,
    IN p_horario_id INT
)
BEGIN
    DECLARE v_capacidad_disponible INT;
    
    SELECT ae.capacidad - COALESCE(ac.capacidad_actual, 0)
    INTO v_capacidad_disponible
    FROM area_entrenamiento ae
    LEFT JOIN area_capacidad ac ON ae.area_id = ac.area_id
    WHERE ae.area_id = p_area_id;
    
    IF v_capacidad_disponible > 0 THEN
        INSERT INTO area_ruta (
            area_id, ruta_entrenamiento_id, horario_id
        ) VALUES (
            p_area_id, p_ruta_id, p_horario_id
        );
    END IF;
END //

-- 17. Registrar cambio de horario trainer
CREATE PROCEDURE sp_cambiar_horario_trainer(
    IN p_trainer_id INT,
    IN p_ruta_id INT,
    IN p_nuevo_horario_id INT
)
BEGIN
    UPDATE asignacion_trainer
    SET horario_id = p_nuevo_horario_id
    WHERE trainer_id = p_trainer_id
    AND ruta_entrenamiento_id = p_ruta_id;
END //

-- 18. Eliminar inscripción de camper
CREATE PROCEDURE sp_eliminar_inscripcion(
    IN p_camper_id INT
)
BEGIN
    UPDATE camper 
    SET ruta_entrenamiento_id = NULL,
        modulo_id = NULL,
        estado_id = 7 
    WHERE camper_id = p_camper_id;
END //

-- 19. Recalcular estado de campers
CREATE PROCEDURE sp_recalcular_estados()
BEGIN
    UPDATE camper c
    JOIN (
        SELECT 
            camper_id,
            AVG(nota_final) as promedio_notas
        FROM evaluacion
        GROUP BY camper_id
    ) e ON c.camper_id = e.camper_id
    SET c.estado_id = CASE
        WHEN e.promedio_notas >= 60 THEN 4
        WHEN e.promedio_notas < 60 THEN 6
        ELSE c.estado_id
    END;
END //

-- 20. Asignar horarios automáticamente
CREATE PROCEDURE sp_asignar_horarios_automaticos()
BEGIN
    DECLARE v_trainer_id INT;
    DECLARE v_area_id INT;
    DECLARE v_horario_id INT;
    
    -- Cursor para trainers sin asignación
    DECLARE done INT DEFAULT FALSE;
    DECLARE trainer_cursor CURSOR FOR
        SELECT t.trainer_id, ar.area_id, h.horario_id
        FROM trainers t
        CROSS JOIN area_ruta ar
        CROSS JOIN horario h
        WHERE NOT EXISTS (
            SELECT 1 FROM asignacion_trainer at
            WHERE at.trainer_id = t.trainer_id
            AND at.horario_id = h.horario_id
        );
    
    DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = TRUE;
    
    OPEN trainer_cursor;
    
    read_loop: LOOP
        FETCH trainer_cursor INTO v_trainer_id, v_area_id, v_horario_id;
        IF done THEN
            LEAVE read_loop;
        END IF;
        
        -- Asignar trainer al horario
        INSERT INTO asignacion_trainer (
            trainer_id, ruta_entrenamiento_id, horario_id
        )
        SELECT v_trainer_id, r.ruta_entrenamiento_id, v_horario_id
        FROM ruta_entrenamiento r
        JOIN area_ruta ar ON r.ruta_entrenamiento_id = ar.ruta_entrenamiento_id
        WHERE ar.area_id = v_area_id
        LIMIT 1;
    END LOOP;
    
    CLOSE trainer_cursor;
END //

DELIMITER ; 