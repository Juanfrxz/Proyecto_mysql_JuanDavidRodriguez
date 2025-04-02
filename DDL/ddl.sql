-- Base de datos principal de CampusLands
DROP DATABASE IF EXISTS dbcampuslands;
CREATE DATABASE dbcampuslands;
USE dbcampuslands;
-- Tabla para almacenar las diferentes sedes de Campus
-- Ejemplo: Bucaramanga, Floridablanca, etc.
CREATE TABLE sede_campus (
    sede_campus_id INT PRIMARY KEY AUTO_INCREMENT,
    lugar VARCHAR(50)
) ENGINE=InnoDB;
-- Tabla para clasificar el nivel de riesgo académico de los campers
-- Valores: Bajo, Medio, Alto
CREATE TABLE nivel_riesgo (
    nivel_riesgo_id INT PRIMARY KEY AUTO_INCREMENT,
    nombre VARCHAR(15)
) ENGINE=InnoDB;
-- Tabla para almacenar números telefónicos
-- Se usa como tabla independiente para permitir múltiples teléfonos por persona
CREATE TABLE telefono (
    telefono_id INT PRIMARY KEY AUTO_INCREMENT,
    numero VARCHAR(15)
) ENGINE=InnoDB;
-- Tabla para tecnologías de backend disponibles en las rutas
-- Ejemplo: Spring Boot, NodeJS, NetCore, Express
CREATE TABLE backend (
    backend_id INT PRIMARY KEY AUTO_INCREMENT,
    nombre VARCHAR(50)
) ENGINE=InnoDB;
-- Tabla para sistemas de gestión de bases de datos
-- Ejemplo: MySQL, MongoDB, PostgreSQL
CREATE TABLE sistema_gestion_bd (
    sistema_gestion_id INT PRIMARY KEY AUTO_INCREMENT,
    nombre VARCHAR(50)
) ENGINE=InnoDB;
-- Tabla para lenguajes de programación formal
-- Ejemplo: Java, JavaScript, C#, Python
CREATE TABLE programacion_formal (
    programacion_formal_id INT PRIMARY KEY AUTO_INCREMENT,
    nombre VARCHAR(50)
) ENGINE=InnoDB;
-- Tabla para estados posibles de un camper
-- Estados: En proceso de ingreso, Inscrito, Aprobado, Cursando, Graduado, Expulsado, Retirado
CREATE TABLE estado (
    estado_id INT PRIMARY KEY AUTO_INCREMENT,
    nombre VARCHAR(20)
) ENGINE=InnoDB;
-- Tabla para módulos de aprendizaje
-- Ejemplo: Backend, Introducción, SQL, etc.
CREATE TABLE modulo (
    modulo_id INT PRIMARY KEY AUTO_INCREMENT,
    nombre VARCHAR(50)
) ENGINE=InnoDB;
-- Tabla para definir los horarios de clases
-- Turnos: 6:00-14:00 y 14:00-22:00
CREATE TABLE horario (
    horario_id INT PRIMARY KEY AUTO_INCREMENT,
    hora_inicio TIME,
    hora_fin TIME
) ENGINE=InnoDB;
-- Tabla para habilidades/tecnologías que pueden tener los trainers
-- Ejemplo: Python, Node.js, Java, JavaScript, C#
CREATE TABLE skill (
    skill_id INT PRIMARY KEY AUTO_INCREMENT,
    nombre VARCHAR(50)
) ENGINE=InnoDB;
CREATE TABLE pais (
    id INT PRIMARY KEY AUTO_INCREMENT,
    nombre VARCHAR(50)
) ENGINE=InnoDB;
-- Tabla para departamentos de Colombia
-- Utilizada para la gestión de direcciones
CREATE TABLE departamento (
    departamento_id INT PRIMARY KEY AUTO_INCREMENT,
    nombre VARCHAR(50),
    pais_id INT,
    CONSTRAINT fk_departamento_pais FOREIGN KEY (pais_id) REFERENCES pais(id)
) ENGINE=InnoDB;
-- Tabla para ciudades, relacionada con departamentos
-- Utilizada para la gestión de direcciones
CREATE TABLE ciudad (
    ciudad_id INT PRIMARY KEY AUTO_INCREMENT,
    nombre VARCHAR(50),
    zipcode VARCHAR(10),
    departamento_id INT,
    CONSTRAINT fk_ciudad_departamento FOREIGN KEY (departamento_id) REFERENCES departamento(departamento_id)
) ENGINE=InnoDB;
-- Tabla para tecnologías de fundamentos de programación
-- Ejemplo: Introducción a la algoritmia, PSeInt, Python básico
CREATE TABLE fundamentos_programacion (
    fundamentos_id INT PRIMARY KEY AUTO_INCREMENT,
    nombre VARCHAR(50)
) ENGINE=InnoDB;
-- Tabla para tecnologías de programación web
-- Ejemplo: HTML, CSS, Bootstrap
CREATE TABLE programacion_web (
    web_id INT PRIMARY KEY AUTO_INCREMENT,
    nombre VARCHAR(50)
) ENGINE=InnoDB;
-- Tabla para áreas físicas de entrenamiento
-- Gestiona los salones y su capacidad máxima (33 campers)
CREATE TABLE area_entrenamiento (
    area_id INT PRIMARY KEY AUTO_INCREMENT,
    nombre VARCHAR(50) NOT NULL,
    capacidad INT DEFAULT 33,
    salon VARCHAR(50)
) ENGINE=InnoDB;
-- Tabla para direcciones físicas
-- Almacena las direcciones de campers, trainers y acudientes
CREATE TABLE direccion (
    direccion_id INT PRIMARY KEY AUTO_INCREMENT,
    direccion VARCHAR(100),
    ciudad_id INT,
    CONSTRAINT fk_direccion_ciudad FOREIGN KEY (ciudad_id) REFERENCES ciudad(ciudad_id)
) ENGINE=InnoDB;
-- Tabla principal para rutas de entrenamiento
-- Define las rutas disponibles con sus tecnologías asociadas
CREATE TABLE ruta_entrenamiento (
    ruta_entrenamiento_id INT PRIMARY KEY AUTO_INCREMENT,
    nombre VARCHAR(50) NOT NULL,
    horario_id INT,
    backend_id INT,
    programacion_formal_id INT,
    sistema_gestion_id INT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    CONSTRAINT fk_ruta_horario FOREIGN KEY (horario_id) REFERENCES horario(horario_id),
    CONSTRAINT fk_ruta_backend FOREIGN KEY (backend_id) REFERENCES backend(backend_id),
    CONSTRAINT fk_ruta_prog_formal FOREIGN KEY (programacion_formal_id) REFERENCES programacion_formal(programacion_formal_id),
    CONSTRAINT fk_ruta_sistema_gestion FOREIGN KEY (sistema_gestion_id) REFERENCES sistema_gestion_bd(sistema_gestion_id)
) ENGINE=InnoDB;
-- Tabla para información de acudientes de los campers
CREATE TABLE acudiente (
    acudiente_id INT PRIMARY KEY AUTO_INCREMENT,
    nombre VARCHAR(50),
    apellido VARCHAR(50),
    direccion_id INT,
    telefono_id INT,
    CONSTRAINT fk_acudiente_direccion FOREIGN KEY (direccion_id) REFERENCES direccion(direccion_id),
    CONSTRAINT fk_acudiente_telefono FOREIGN KEY (telefono_id) REFERENCES telefono(telefono_id)
) ENGINE=InnoDB;
-- Tabla principal de campers (estudiantes)
-- Almacena toda la información personal y académica del camper
CREATE TABLE camper (
    camper_id INT PRIMARY KEY AUTO_INCREMENT,
    numero_identificacion VARCHAR(20) UNIQUE NOT NULL,
    nombres VARCHAR(50) NOT NULL,
    apellidos VARCHAR(50) NOT NULL,
    sede_campus_id INT NOT NULL,
    direccion_id INT,
    acudiente_id INT,
    nivel_riesgo_id INT NOT NULL,
    ruta_entrenamiento_id INT,
    modulo_id INT,
    estado_id INT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    CONSTRAINT fk_camper_estado FOREIGN KEY (estado_id) REFERENCES estado(estado_id),
    CONSTRAINT fk_camper_sede FOREIGN KEY (sede_campus_id) REFERENCES sede_campus(sede_campus_id),
    CONSTRAINT fk_camper_direccion FOREIGN KEY (direccion_id) REFERENCES direccion(direccion_id),
    CONSTRAINT fk_camper_acudiente FOREIGN KEY (acudiente_id) REFERENCES acudiente(acudiente_id),
    CONSTRAINT fk_camper_nivel_riesgo FOREIGN KEY (nivel_riesgo_id) REFERENCES nivel_riesgo(nivel_riesgo_id),
    CONSTRAINT fk_camper_ruta FOREIGN KEY (ruta_entrenamiento_id) REFERENCES ruta_entrenamiento(ruta_entrenamiento_id),
    CONSTRAINT fk_camper_modulo FOREIGN KEY (modulo_id) REFERENCES modulo(modulo_id)
) ENGINE=InnoDB;
-- Tabla para relacionar campers con múltiples teléfonos
CREATE TABLE camper_telefono (
    camper_id INT,
    telefono_id INT,
    PRIMARY KEY (camper_id, telefono_id),
    CONSTRAINT fk_camper_tel_camper FOREIGN KEY (camper_id) REFERENCES camper(camper_id),
    CONSTRAINT fk_camper_tel_telefono FOREIGN KEY (telefono_id) REFERENCES telefono(telefono_id)
) ENGINE=InnoDB;
-- Tabla para información de trainers (profesores)
CREATE TABLE trainers (
    trainer_id INT PRIMARY KEY AUTO_INCREMENT,
    nombre VARCHAR(50),
    apellido VARCHAR(50),
    direccion_id INT,
    telefono_id INT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    CONSTRAINT fk_trainer_direccion FOREIGN KEY (direccion_id) REFERENCES direccion(direccion_id),
    CONSTRAINT fk_trainer_telefono FOREIGN KEY (telefono_id) REFERENCES telefono(telefono_id)
) ENGINE=InnoDB;
-- Tabla para relacionar trainers con múltiples teléfonos
CREATE TABLE trainer_telefono (
    trainer_id INT,
    telefono_id INT,
    PRIMARY KEY (trainer_id, telefono_id),
    CONSTRAINT fk_trainer_tel_trainer FOREIGN KEY (trainer_id) REFERENCES trainers(trainer_id),
    CONSTRAINT fk_trainer_tel_telefono FOREIGN KEY (telefono_id) REFERENCES telefono(telefono_id)
) ENGINE=InnoDB;
-- Tabla para registrar las habilidades/tecnologías de cada trainer
CREATE TABLE conocimiento_trainer (
    trainer_id INT,
    skill_id INT,
    PRIMARY KEY (trainer_id, skill_id),
    CONSTRAINT fk_conocimiento_trainer FOREIGN KEY (trainer_id) REFERENCES trainers(trainer_id),
    CONSTRAINT fk_conocimiento_skill FOREIGN KEY (skill_id) REFERENCES skill(skill_id)
) ENGINE=InnoDB;
-- Tabla para asignar trainers a rutas y horarios específicos
CREATE TABLE asignacion_trainer (
    asignacion_trainer_id INT PRIMARY KEY AUTO_INCREMENT,
    trainer_id INT,
    ruta_entrenamiento_id INT,
    horario_id INT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    CONSTRAINT fk_asignacion_trainer FOREIGN KEY (trainer_id) REFERENCES trainers(trainer_id),
    CONSTRAINT fk_asignacion_ruta FOREIGN KEY (ruta_entrenamiento_id) REFERENCES ruta_entrenamiento(ruta_entrenamiento_id),
    CONSTRAINT fk_asignacion_horario FOREIGN KEY (horario_id) REFERENCES horario(horario_id)
) ENGINE=InnoDB;
-- Tabla para relacionar rutas con sus módulos correspondientes
CREATE TABLE ruta_modulo (
    ruta_entrenamiento_id INT,
    modulo_id INT,
    PRIMARY KEY (ruta_entrenamiento_id, modulo_id),
    CONSTRAINT fk_ruta_modulo_ruta FOREIGN KEY (ruta_entrenamiento_id) REFERENCES ruta_entrenamiento(ruta_entrenamiento_id),
    CONSTRAINT fk_ruta_modulo_modulo FOREIGN KEY (modulo_id) REFERENCES modulo(modulo_id)
) ENGINE=InnoDB;
-- Tabla para gestionar los horarios específicos de cada área
CREATE TABLE horario_area (
    horario_area_id INT PRIMARY KEY AUTO_INCREMENT,
    area_id INT,
    hora_inicio TIME,
    hora_fin TIME,
    CONSTRAINT fk_horario_area_area FOREIGN KEY (area_id) REFERENCES area_entrenamiento(area_id)
) ENGINE=InnoDB;
-- Tabla para registro de asistencia de campers
-- Incluye fecha, hora de ingreso y turno
CREATE TABLE asistencia (
    asistencia_id INT PRIMARY KEY AUTO_INCREMENT,
    camper_id INT,
    fecha DATE,
    hora_ingreso TIME,
    turno ENUM('Mañana', 'Tarde'),
    CONSTRAINT fk_asistencia_camper FOREIGN KEY (camper_id) REFERENCES camper(camper_id)
) ENGINE=InnoDB;
-- Tabla para registrar campers graduados y su ruta completada
CREATE TABLE egresados (
    camper_id INT,
    ruta_entrenamiento_id INT,
    PRIMARY KEY (camper_id, ruta_entrenamiento_id),
    CONSTRAINT fk_egresados_camper FOREIGN KEY (camper_id) REFERENCES camper(camper_id),
    CONSTRAINT fk_egresados_ruta FOREIGN KEY (ruta_entrenamiento_id) REFERENCES ruta_entrenamiento(ruta_entrenamiento_id)
) ENGINE=InnoDB;
-- Tabla para registro de evaluaciones de los campers
-- Incluye notas teóricas (30%), prácticas (60%) y trabajos (10%)
CREATE TABLE evaluacion (
    camper_id INT,
    ruta_entrenamiento_id INT,
    modulo_id INT,
    nota_teorica DECIMAL(5,2),
    nota_practica DECIMAL(5,2),
    nota_trabajo DECIMAL(5,2),
    nota_final DECIMAL(5,2),
    PRIMARY KEY (camper_id, ruta_entrenamiento_id, modulo_id),
    CONSTRAINT fk_evaluacion_camper FOREIGN KEY (camper_id) REFERENCES camper(camper_id),
    CONSTRAINT fk_evaluacion_ruta FOREIGN KEY (ruta_entrenamiento_id) REFERENCES ruta_entrenamiento(ruta_entrenamiento_id),
    CONSTRAINT fk_evaluacion_modulo FOREIGN KEY (modulo_id) REFERENCES modulo(modulo_id),
    CONSTRAINT chk_nota_teorica CHECK (nota_teorica BETWEEN 0 AND 100),
    CONSTRAINT chk_nota_practica CHECK (nota_practica BETWEEN 0 AND 100),
    CONSTRAINT chk_nota_trabajo CHECK (nota_trabajo BETWEEN 0 AND 100),
    CONSTRAINT chk_nota_final CHECK (nota_final BETWEEN 0 AND 100)
) ENGINE=InnoDB;
-- Tabla para relacionar rutas con tecnologías de fundamentos
CREATE TABLE ruta_fundamentos (
    ruta_entrenamiento_id INT,
    fundamentos_id INT,
    PRIMARY KEY (ruta_entrenamiento_id, fundamentos_id),
    CONSTRAINT fk_ruta_fund_ruta FOREIGN KEY (ruta_entrenamiento_id) REFERENCES ruta_entrenamiento(ruta_entrenamiento_id),
    CONSTRAINT fk_ruta_fund_fundamentos FOREIGN KEY (fundamentos_id) REFERENCES fundamentos_programacion(fundamentos_id)
) ENGINE=InnoDB;
-- Tabla para relacionar rutas con tecnologías web
CREATE TABLE ruta_web (
    ruta_entrenamiento_id INT,
    web_id INT,
    PRIMARY KEY (ruta_entrenamiento_id, web_id),
    CONSTRAINT fk_ruta_web_ruta FOREIGN KEY (ruta_entrenamiento_id) REFERENCES ruta_entrenamiento(ruta_entrenamiento_id),
    CONSTRAINT fk_ruta_web_web FOREIGN KEY (web_id) REFERENCES programacion_web(web_id)
) ENGINE=InnoDB;
-- Tabla para controlar la capacidad actual de cada área
-- Asegura que no se exceda el límite de 33 campers
CREATE TABLE area_capacidad (
    area_capacidad_id INT PRIMARY KEY AUTO_INCREMENT,
    area_id INT,
    ruta_entrenamiento_id INT,
    capacidad_actual INT DEFAULT 0,
    fecha_actualizacion TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_area_cap_area FOREIGN KEY (area_id) REFERENCES area_entrenamiento(area_id),
    CONSTRAINT fk_area_cap_ruta FOREIGN KEY (ruta_entrenamiento_id) REFERENCES ruta_entrenamiento(ruta_entrenamiento_id),
    CONSTRAINT chk_capacidad CHECK (capacidad_actual <= 33)
) ENGINE=InnoDB;
-- Tabla para relacionar áreas con rutas y horarios
CREATE TABLE area_ruta (
    area_id INT,
    ruta_entrenamiento_id INT,
    horario_id INT,
    PRIMARY KEY (area_id, ruta_entrenamiento_id, horario_id),
    CONSTRAINT fk_area_ruta_area FOREIGN KEY (area_id) REFERENCES area_entrenamiento(area_id),
    CONSTRAINT fk_area_ruta_ruta FOREIGN KEY (ruta_entrenamiento_id) REFERENCES ruta_entrenamiento(ruta_entrenamiento_id),
    CONSTRAINT fk_area_ruta_horario FOREIGN KEY (horario_id) REFERENCES horario(horario_id)
) ENGINE=InnoDB;
