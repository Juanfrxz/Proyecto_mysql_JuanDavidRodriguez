-- 🔍 Funciones MySQL (20 ejemplos)

DELIMITER //

-- 1. Calcular promedio ponderado de evaluaciones
CREATE FUNCTION fn_calcular_promedio_ponderado(
    p_camper_id INT
) RETURNS DECIMAL(5,2)
DETERMINISTIC
BEGIN
    DECLARE v_promedio DECIMAL(5,2);
    
    SELECT AVG(
        (nota_teorica * 0.3) + 
        (nota_practica * 0.6) + 
        (nota_trabajo * 0.1)
    )
    INTO v_promedio
    FROM evaluacion
    WHERE camper_id = p_camper_id;
    
    RETURN v_promedio;
END //

-- 2. Determinar aprobación de módulo
CREATE FUNCTION fn_aprobacion_modulo(
    p_camper_id INT,
    p_modulo_id INT
) RETURNS BOOLEAN
DETERMINISTIC
BEGIN
    DECLARE v_nota_final DECIMAL(5,2);
    
    SELECT nota_final
    INTO v_nota_final
    FROM evaluacion
    WHERE camper_id = p_camper_id 
    AND modulo_id = p_modulo_id;
    
    RETURN v_nota_final >= 60;
END //

-- 3. Evaluar nivel de riesgo
CREATE FUNCTION fn_evaluar_nivel_riesgo(
    p_camper_id INT
) RETURNS INT
DETERMINISTIC
BEGIN
    DECLARE v_promedio DECIMAL(5,2);
    DECLARE v_nivel_riesgo INT;
    
    SELECT AVG(nota_final)
    INTO v_promedio
    FROM evaluacion
    WHERE camper_id = p_camper_id;
    
    SET v_nivel_riesgo = CASE
        WHEN v_promedio >= 80 THEN 1
        WHEN v_promedio >= 60 THEN 2
        ELSE 3
    END;
    
    RETURN v_nivel_riesgo;
END //

-- 4. Total de campers por ruta
CREATE FUNCTION fn_total_campers_ruta(
    p_ruta_id INT
) RETURNS INT
DETERMINISTIC
BEGIN
    DECLARE v_total INT;
    
    SELECT COUNT(*)
    INTO v_total
    FROM camper
    WHERE ruta_entrenamiento_id = p_ruta_id;
    
    RETURN v_total;
END //

-- 5. Módulos aprobados por camper
CREATE FUNCTION fn_modulos_aprobados(
    p_camper_id INT
) RETURNS INT
DETERMINISTIC
BEGIN
    DECLARE v_total INT;
    
    SELECT COUNT(*)
    INTO v_total
    FROM evaluacion
    WHERE camper_id = p_camper_id
    AND nota_final >= 60;
    
    RETURN v_total;
END //

-- 6. Validar cupos disponibles
CREATE FUNCTION fn_validar_cupos(
    p_area_id INT
) RETURNS BOOLEAN
DETERMINISTIC
BEGIN
    DECLARE v_capacidad_disponible INT;
    
    SELECT ae.capacidad - COALESCE(ac.capacidad_actual, 0)
    INTO v_capacidad_disponible
    FROM area_entrenamiento ae
    LEFT JOIN area_capacidad ac ON ae.area_id = ac.area_id
    WHERE ae.area_id = p_area_id;
    
    RETURN v_capacidad_disponible > 0;
END //

-- 7. Calcular porcentaje de ocupación
CREATE FUNCTION fn_porcentaje_ocupacion(
    p_area_id INT
) RETURNS DECIMAL(5,2)
DETERMINISTIC
BEGIN
    DECLARE v_porcentaje DECIMAL(5,2);
    
    SELECT (ac.capacidad_actual / ae.capacidad) * 100
    INTO v_porcentaje
    FROM area_entrenamiento ae
    LEFT JOIN area_capacidad ac ON ae.area_id = ac.area_id
    WHERE ae.area_id = p_area_id;
    
    RETURN v_porcentaje;
END //

-- 8. Nota más alta en módulo
CREATE FUNCTION fn_nota_maxima_modulo(
    p_modulo_id INT
) RETURNS DECIMAL(5,2)
DETERMINISTIC
BEGIN
    DECLARE v_nota_maxima DECIMAL(5,2);
    
    SELECT MAX(nota_final)
    INTO v_nota_maxima
    FROM evaluacion
    WHERE modulo_id = p_modulo_id;
    
    RETURN v_nota_maxima;
END //

-- 9. Calcular tasa de aprobación
CREATE FUNCTION fn_tasa_aprobacion(
    p_ruta_id INT
) RETURNS DECIMAL(5,2)
DETERMINISTIC
BEGIN
    DECLARE v_tasa DECIMAL(5,2);
    
    SELECT (COUNT(CASE WHEN nota_final >= 60 THEN 1 END) / COUNT(*)) * 100
    INTO v_tasa
    FROM evaluacion e
    JOIN camper c ON e.camper_id = c.camper_id
    WHERE c.ruta_entrenamiento_id = p_ruta_id;
    
    RETURN v_tasa;
END //

-- 10. Verificar disponibilidad de horario trainer
CREATE FUNCTION fn_horario_trainer_disponible(
    p_trainer_id INT,
    p_horario_id INT
) RETURNS BOOLEAN
DETERMINISTIC
BEGIN
    DECLARE v_disponible BOOLEAN;
    
    SELECT NOT EXISTS (
        SELECT 1 FROM asignacion_trainer
        WHERE trainer_id = p_trainer_id
        AND horario_id = p_horario_id
    ) INTO v_disponible;
    
    RETURN v_disponible;
END //

-- 11. Promedio de notas por ruta
CREATE FUNCTION fn_promedio_notas_ruta(
    p_ruta_id INT
) RETURNS DECIMAL(5,2)
DETERMINISTIC
BEGIN
    DECLARE v_promedio DECIMAL(5,2);
    
    SELECT AVG(e.nota_final)
    INTO v_promedio
    FROM evaluacion e
    JOIN camper c ON e.camper_id = c.camper_id
    WHERE c.ruta_entrenamiento_id = p_ruta_id;
    
    RETURN v_promedio;
END //

-- 12. Rutas asignadas a trainer
CREATE FUNCTION fn_rutas_trainer(
    p_trainer_id INT
) RETURNS INT
DETERMINISTIC
BEGIN
    DECLARE v_total INT;
    
    SELECT COUNT(DISTINCT ruta_entrenamiento_id)
    INTO v_total
    FROM asignacion_trainer
    WHERE trainer_id = p_trainer_id;
    
    RETURN v_total;
END //

-- 13. Verificar posibilidad de graduación
CREATE FUNCTION fn_puede_graduarse(
    p_camper_id INT
) RETURNS BOOLEAN
DETERMINISTIC
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
    
    RETURN v_modulos_aprobados = v_total_modulos;
END //

-- 14. Estado actual del camper
CREATE FUNCTION fn_estado_actual_camper(
    p_camper_id INT
) RETURNS INT
DETERMINISTIC
BEGIN
    DECLARE v_promedio DECIMAL(5,2);
    DECLARE v_estado INT;
    
    SELECT AVG(nota_final)
    INTO v_promedio
    FROM evaluacion
    WHERE camper_id = p_camper_id;
    
    SET v_estado = CASE
        WHEN v_promedio >= 80 THEN 4
        WHEN v_promedio >= 60 THEN 3
        ELSE 6
    END;
    
    RETURN v_estado;
END //

-- 15. Carga horaria semanal trainer
CREATE FUNCTION fn_carga_horaria_semanal(
    p_trainer_id INT
) RETURNS INT
DETERMINISTIC
BEGIN
    DECLARE v_horas INT;
    
    SELECT COUNT(*) * 8
    INTO v_horas
    FROM asignacion_trainer
    WHERE trainer_id = p_trainer_id;
    
    RETURN v_horas;
END //

-- 16. Módulos pendientes por evaluación
CREATE FUNCTION fn_modulos_pendientes(
    p_ruta_id INT
) RETURNS INT
DETERMINISTIC
BEGIN
    DECLARE v_pendientes INT;
    
    SELECT COUNT(DISTINCT rm.modulo_id) - COUNT(DISTINCT e.modulo_id)
    INTO v_pendientes
    FROM ruta_modulo rm
    LEFT JOIN evaluacion e ON rm.ruta_entrenamiento_id = e.ruta_entrenamiento_id
    WHERE rm.ruta_entrenamiento_id = p_ruta_id;
    
    RETURN v_pendientes;
END //

-- 17. Promedio general del programa
CREATE FUNCTION fn_promedio_general_programa() 
RETURNS DECIMAL(5,2)
DETERMINISTIC
BEGIN
    DECLARE v_promedio DECIMAL(5,2);
    
    SELECT AVG(nota_final)
    INTO v_promedio
    FROM evaluacion;
    
    RETURN v_promedio;
END //

-- 18. Verificar choque de horarios
CREATE FUNCTION fn_verificar_choque_horarios(
    p_area_id INT,
    p_horario_id INT
) RETURNS BOOLEAN
DETERMINISTIC
BEGIN
    DECLARE v_existe_choque BOOLEAN;
    
    SELECT EXISTS (
        SELECT 1 FROM area_ruta ar
        WHERE ar.area_id = p_area_id
        AND ar.horario_id = p_horario_id
    ) INTO v_existe_choque;
    
    RETURN v_existe_choque;
END //

-- 19. Campers en riesgo por ruta
CREATE FUNCTION fn_campers_en_riesgo(
    p_ruta_id INT
) RETURNS INT
DETERMINISTIC
BEGIN
    DECLARE v_total INT;
    
    SELECT COUNT(DISTINCT c.camper_id)
    INTO v_total
    FROM camper c
    JOIN evaluacion e ON c.camper_id = e.camper_id
    WHERE c.ruta_entrenamiento_id = p_ruta_id
    AND e.nota_final < 60;
    
    RETURN v_total;
END //

-- 20. Módulos evaluados por camper
CREATE FUNCTION fn_modulos_evaluados(
    p_camper_id INT
) RETURNS INT
DETERMINISTIC
BEGIN
    DECLARE v_total INT;
    
    SELECT COUNT(DISTINCT modulo_id)
    INTO v_total
    FROM evaluacion
    WHERE camper_id = p_camper_id;
    
    RETURN v_total;
END //

DELIMITER ;
