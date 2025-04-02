-- 1. Calcular nota final automáticamente al insertar evaluación
DELIMITER //
CREATE TRIGGER tr_calcular_nota_final
BEFORE INSERT ON evaluacion
FOR EACH ROW
BEGIN
    SET NEW.nota_final = (NEW.nota_teorica * 0.30) + (NEW.nota_practica * 0.60) + (NEW.nota_trabajo * 0.10);
END;
//
DELIMITER ;

-- 2. Verificar aprobación/reprobación al actualizar nota final
DELIMITER //
CREATE TRIGGER tr_verificar_aprobacion
AFTER UPDATE ON evaluacion
FOR EACH ROW
BEGIN
    IF NEW.nota_final < 60 THEN
        UPDATE camper 
        SET estado_id = (SELECT estado_id FROM estado WHERE nombre = 'Reprobado')
        WHERE camper_id = NEW.camper_id;
    ELSE
        UPDATE camper 
        SET estado_id = (SELECT estado_id FROM estado WHERE nombre = 'Aprobado')
        WHERE camper_id = NEW.camper_id;
    END IF;
END;
//
DELIMITER ;

-- 3. Cambiar estado a "Inscrito" al insertar inscripción
DELIMITER //
CREATE TRIGGER tr_cambiar_estado_inscrito
AFTER INSERT ON camper
FOR EACH ROW
BEGIN
    UPDATE camper 
    SET estado_id = (SELECT estado_id FROM estado WHERE nombre = 'Inscrito')
    WHERE camper_id = NEW.camper_id;
END;
//
DELIMITER ;

-- 4. Recalcular promedio al actualizar evaluación
DELIMITER //
CREATE TRIGGER tr_recalcular_promedio
AFTER UPDATE ON evaluacion
FOR EACH ROW
BEGIN
    SET @promedio = (
        SELECT AVG(nota_final)
        FROM evaluacion
        WHERE camper_id = NEW.camper_id
    );
    
    UPDATE camper
    SET nivel_riesgo_id = CASE
        WHEN @promedio >= 80 THEN (SELECT nivel_riesgo_id FROM nivel_riesgo WHERE nombre = 'Bajo')
        WHEN @promedio >= 60 THEN (SELECT nivel_riesgo_id FROM nivel_riesgo WHERE nombre = 'Medio')
        ELSE (SELECT nivel_riesgo_id FROM nivel_riesgo WHERE nombre = 'Alto')
    END
    WHERE camper_id = NEW.camper_id;
END;
//
DELIMITER ;

-- 5. Marcar como "Retirado" al eliminar inscripción
DELIMITER //
CREATE TRIGGER tr_marcar_retirado
BEFORE DELETE ON camper
FOR EACH ROW
BEGIN
    INSERT INTO camper_historico (camper_id, estado_id, fecha_retiro)
    VALUES (OLD.camper_id, 
            (SELECT estado_id FROM estado WHERE nombre = 'Retirado'),
            NOW());
END;
//
DELIMITER ;

-- 6. Registrar SGDB al insertar módulo
DELIMITER //
CREATE TRIGGER tr_registrar_sgdb
AFTER INSERT ON modulo
FOR EACH ROW
BEGIN
    IF NEW.nombre LIKE '%SQL%' OR NEW.nombre LIKE '%Base de Datos%' THEN
        INSERT INTO modulo_sgbd (modulo_id, sistema_gestion_id)
        SELECT NEW.modulo_id, sistema_gestion_id
        FROM sistema_gestion_bd
        WHERE nombre = 'MySQL';
    END IF;
END;
//
DELIMITER ;

-- 7. Verificar duplicados de trainer
DELIMITER //
CREATE TRIGGER tr_verificar_trainer_duplicado
BEFORE INSERT ON trainers
FOR EACH ROW
BEGIN
    IF EXISTS (SELECT 1 FROM trainers WHERE nombre = NEW.nombre AND apellido = NEW.apellido) THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Trainer ya existe en el sistema';
    END IF;
END;
//
DELIMITER ;

-- 8. Validar capacidad del área
DELIMITER //
CREATE TRIGGER tr_validar_capacidad_area
BEFORE INSERT ON area_capacidad
FOR EACH ROW
BEGIN
    DECLARE capacidad_maxima INT;
    SELECT capacidad INTO capacidad_maxima 
    FROM area_entrenamiento 
    WHERE area_id = NEW.area_id;
    
    IF NEW.capacidad_actual > capacidad_maxima THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Capacidad máxima del área excedida';
    END IF;
END;
//
DELIMITER ;

-- 9. Marcar bajo rendimiento
DELIMITER //
CREATE TRIGGER tr_marcar_bajo_rendimiento
AFTER INSERT ON evaluacion
FOR EACH ROW
BEGIN
    IF NEW.nota_final < 60 THEN
        UPDATE camper
        SET nivel_riesgo_id = (SELECT nivel_riesgo_id FROM nivel_riesgo WHERE nombre = 'Alto')
        WHERE camper_id = NEW.camper_id;
    END IF;
END;
//
DELIMITER ;

-- 10. Mover a egresados
DELIMITER //
CREATE TRIGGER tr_mover_egresados
AFTER UPDATE ON camper
FOR EACH ROW
BEGIN
    IF NEW.estado_id = (SELECT estado_id FROM estado WHERE nombre = 'Graduado') 
    AND OLD.estado_id != NEW.estado_id THEN
        INSERT INTO egresados (camper_id, ruta_entrenamiento_id)
        VALUES (NEW.camper_id, NEW.ruta_entrenamiento_id);
    END IF;
END;
//
DELIMITER ;

-- 11. Verificar solapamiento de horarios
DELIMITER //
CREATE TRIGGER tr_verificar_solapamiento
BEFORE INSERT ON asignacion_trainer
FOR EACH ROW
BEGIN
    IF EXISTS (
        SELECT 1 FROM asignacion_trainer
        WHERE trainer_id = NEW.trainer_id
        AND horario_id = NEW.horario_id
        AND ruta_entrenamiento_id != NEW.ruta_entrenamiento_id
    ) THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Existe solapamiento de horarios';
    END IF;
END;
//
DELIMITER ;

-- 12. Liberar asignaciones al eliminar trainer
DELIMITER //
CREATE TRIGGER tr_liberar_asignaciones
BEFORE DELETE ON trainers
FOR EACH ROW
BEGIN
    DELETE FROM asignacion_trainer WHERE trainer_id = OLD.trainer_id;
    DELETE FROM conocimiento_trainer WHERE trainer_id = OLD.trainer_id;
END;
//
DELIMITER ;

-- 13. Actualizar módulos al cambiar ruta (Versión corregida)
DELIMITER //
CREATE TRIGGER tr_actualizar_modulos_ruta
BEFORE UPDATE ON camper
FOR EACH ROW
BEGIN
    IF NEW.ruta_entrenamiento_id != OLD.ruta_entrenamiento_id THEN
        SET NEW.modulo_id = (
            SELECT MIN(modulo_id) 
            FROM ruta_modulo 
            WHERE ruta_entrenamiento_id = NEW.ruta_entrenamiento_id
        );
    END IF;
END;
//
DELIMITER ;

-- 14. Verificar documento duplicado
DELIMITER //
CREATE TRIGGER tr_verificar_documento
BEFORE INSERT ON camper
FOR EACH ROW
BEGIN
    IF EXISTS (SELECT 1 FROM camper WHERE numero_identificacion = NEW.numero_identificacion) THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Número de documento ya existe';
    END IF;
END;
//
DELIMITER ;

-- 15. Recalcular estado del módulo
DELIMITER //
CREATE TRIGGER tr_recalcular_estado_modulo
AFTER UPDATE ON evaluacion
FOR EACH ROW
BEGIN
    IF NEW.nota_final != OLD.nota_final THEN
        UPDATE camper
        SET estado_id = CASE
            WHEN NEW.nota_final >= 60 THEN (SELECT estado_id FROM estado WHERE nombre = 'Aprobado')
            ELSE (SELECT estado_id FROM estado WHERE nombre = 'Reprobado')
        END
        WHERE camper_id = NEW.camper_id;
    END IF;
END;
//
DELIMITER ;

-- 16. Verificar conocimiento del trainer
DELIMITER //
CREATE TRIGGER tr_verificar_conocimiento_trainer
BEFORE INSERT ON asignacion_trainer
FOR EACH ROW
BEGIN
    IF NOT EXISTS (
        SELECT 1 
        FROM conocimiento_trainer ct
        JOIN ruta_modulo rm ON rm.ruta_entrenamiento_id = NEW.ruta_entrenamiento_id
        WHERE ct.trainer_id = NEW.trainer_id
    ) THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Trainer no tiene los conocimientos requeridos';
    END IF;
END;
//
DELIMITER ;

-- 17. Liberar campers de área inactiva
DELIMITER //
CREATE TRIGGER tr_liberar_area_inactiva
AFTER UPDATE ON area_entrenamiento
FOR EACH ROW
BEGIN
    IF NEW.capacidad = 0 AND OLD.capacidad > 0 THEN
        DELETE FROM area_capacidad WHERE area_id = NEW.area_id;
    END IF;
END;
//
DELIMITER ;

-- 18. Clonar plantilla base
DELIMITER //
CREATE TRIGGER tr_clonar_plantilla
AFTER INSERT ON ruta_entrenamiento
FOR EACH ROW
BEGIN
    INSERT INTO ruta_modulo (ruta_entrenamiento_id, modulo_id)
    SELECT NEW.ruta_entrenamiento_id, modulo_id
    FROM modulo
    WHERE modulo_id IN (1, 2, 3); -- módulos base
END;
//
DELIMITER ;

-- 19. Verificar nota práctica
DELIMITER //
CREATE TRIGGER tr_verificar_nota_practica
BEFORE INSERT ON evaluacion
FOR EACH ROW
BEGIN
    IF NEW.nota_practica > 60 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Nota práctica no puede superar el 60%';
    END IF;
END;
//
DELIMITER ;

-- 20. Notificar cambios de ruta
DELIMITER //
CREATE TRIGGER tr_notificar_cambios_ruta
AFTER UPDATE ON ruta_entrenamiento
FOR EACH ROW
BEGIN
    INSERT INTO notificaciones_trainer (trainer_id, mensaje, fecha)
    SELECT trainer_id, 
           CONCAT('Cambios en ruta: ', NEW.nombre), 
           NOW()
    FROM asignacion_trainer
    WHERE ruta_entrenamiento_id = NEW.ruta_entrenamiento_id;
END;
//
DELIMITER ;
