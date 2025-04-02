INSERT INTO sede_campus (lugar) VALUES
('Floridablanca'),
('Bucaramanga'),
('Bogotá');

INSERT INTO nivel_riesgo (nombre) VALUES
('Bajo'),
('Medio'),
('Alto');

INSERT INTO estado (nombre) VALUES
('Ingreso'),
('Inscrito'),
('Aprobado'),
('Cursando'),
('Graduado'),
('Expulsado'),
('Retirado');

INSERT INTO skill (nombre) VALUES
('Python'),
('Node.js'),
('Java'),
('JavaScript'),
('C#');

INSERT INTO fundamentos_programacion (nombre) VALUES
('Introducción a la algoritmia'),
('PSeInt'),
('Python básico');

INSERT INTO programacion_web (nombre) VALUES
('HTML'),
('CSS'),
('Bootstrap');

INSERT INTO backend (nombre) VALUES
('Spring Boot'),
('NodeJS'),
('NetCore'),
('Express');

INSERT INTO sistema_gestion_bd (nombre) VALUES
('MySQL'),
('PostgreSQL'),
('MongoDB');

INSERT INTO programacion_formal (nombre) VALUES
('Java'),
('Python'),
('JavaScript'),
('C#');

INSERT INTO modulo (nombre) VALUES
('Backend'),
('Introduccion'),
('SQL');

INSERT INTO horario (hora_inicio, hora_fin) VALUES
('06:00:00', '14:00:00'),
('14:00:00', '22:00:00');

INSERT INTO area_entrenamiento (nombre, capacidad, salon) VALUES
('Area 1', 33, 'A101'),
('Area 2', 33, 'B202');

INSERT INTO telefono (numero) VALUES
('3009876543'),
('3018765432'),
('3027654321'),
('3036543210'),
('3045432109'),
('3054321098'),
('3063210987'),
('3072109876'),
('3081098765'),
('3090987654'),
('3109876543'),
('3118765432'),
('3127654321'),
('3136543210'),
('3145432109'),
('3154321098'),
('3163210987'),
('3172109876'),
('3181098765'),
('3190987654'),
('3209876543'),
('3218765432'),
('3227654321'),
('3236543210'),
('3245432109'),
('3254321098'),
('3263210987'),
('3272109876'),
('3281098765'),
('3290987654'),
('3309876543'),
('3318765432'),
('3327654321'),
('3336543210'),
('3345432109'),
('3354321098'),
('3363210987'),
('3372109876'),
('3381098765'),
('3390987654'),
('3409876543'),
('3418765432'),
('3427654321'),
('3436543210'),
('3445432109'),
('3454321098'),
('3463210987'),
('3472109876'),
('3481098765'),
('3490987654');

INSERT INTO pais (nombre) VALUES
('Colombia');

INSERT INTO departamento (nombre, pais_id) VALUES
('Santander', 1),
('Norte de Santander', 1),
('Cundinamarca', 1);

INSERT INTO ciudad (nombre, zipcode, departamento_id)  
VALUES  
    ('Bucaramanga', '680001', 1),  
    ('Bogotá', '110111', 3),  
    ('Cúcuta', '540001', 2);

INSERT INTO direccion (direccion, ciudad_id) VALUES
('Avenida de la Unidad #100-10', 1),
('Calle del Progreso #101-11', 1),
('Carrera de la Libertad #102-12', 1),
('Diagonal de la Paz #103-13', 1),
('Transversal de la Esperanza #104-14', 1),
('Calle 5 de la Montaña #105-15', 1),
('Avenida Principal #111-21', 1),
('Carrera Nueva #112-22', 1),
('Avenida del Sol #120-30', 2),
('Calle del Renacer #121-31', 2),
('Carrera de la Vida #122-32', 2),
('Diagonal del Horizonte #123-33', 2),
('Transversal del Amanecer #124-34', 2),
('Avenida del Recuerdo #125-35', 2),
('Calle de la Victoria #126-36', 2),
('Carrera de la Esperanza #127-37', 2),
('Diagonal del Progreso #128-38', 3),
('Transversal de la Alegría #129-39', 3),
('Avenida del Progreso #130-40', 3),
('Calle del Futuro #131-41', 3),
('Carrera de los Sueños #132-42', 3),
('Diagonal de la Unidad #133-43', 3),
('Transversal del Sol #134-44', 3),
('Avenida del Pacífico #135-45', 3);

INSERT INTO acudiente (nombre, apellido, direccion_id, telefono_id) VALUES
('Luis', 'Pérez', 1, 1),
('Andrea', 'Martínez', 2, 2),
('Carlos', 'Rodríguez', 3, 3),
('Sofía', 'García', 4, 4),
('Fernando', 'López', 5, 5),
('Valeria', 'Torres', 6, 6),
('Javier', 'Ramírez', 7, 7),
('Camila', 'Flores', 8, 8);

INSERT INTO ruta_entrenamiento (nombre, horario_id, backend_id, programacion_formal_id, sistema_gestion_id) VALUES
('Ruta Full Stack', 1, 1, 1, 1),
('Ruta Backend', 2, 2, 2, 2),
('Ruta Frontend', 1, 3, 3, 3);

INSERT INTO camper (numero_identificacion, nombres, apellidos, sede_campus_id, direccion_id, acudiente_id, nivel_riesgo_id, ruta_entrenamiento_id, modulo_id, estado_id) VALUES
('1001', 'Lucas', 'Ramírez', 1, 1, 1, 1, 1, 1, 1),
('1002', 'Mariana', 'Torres', 2, 2, 2, 2, 1, 2, 2),
('1003', 'Diego', 'Herrera', 1, 3, 3, 3, 1, 3, 1),
('1004', 'Natalia', 'Mendoza', 2, 4, 4, 1, 1, 1, 2),
('1005', 'Santiago', 'González', 1, 5, 5, 2, 1, 1, 3),
('1006', 'Carlos', 'Sanchez', 1, 6, 2, 3, 1, 2, 4),
('1007', 'Mariana', 'Rodriguez', 2, 7, 3, 1, 1, 3, 5),
('1008', 'Laura', 'Torres', 1, 8, 4, 2, 1, 1, 6),
('1009', 'Jorge', 'Martinez', 2, 9, 5, 3, 1, 2, 7),
('1010', 'Sofia', 'Lopez', 1, 10, 6, 1, 1, 3, 1),
('1011', 'Miguel', 'Gomez', 2, 11, 7, 2, 1, 1, 2),
('1012', 'Elena', 'Ramirez', 1, 12, 8, 3, 1, 2, 3),
('1013', 'Andrés', 'Gómez', 3, 13, 1, 2, 1, 1, 4),
('1014', 'Beatriz', 'Lopez', 1, 14, 2, 3, 1, 2, 2),
('1015', 'Carlos', 'Vargas', 2, 15, 3, 1, 1, 3, 1),
('1016', 'Daniela', 'Perez', 1, 16, 4, 2, 1, 1, 3),
('1017', 'Eduardo', 'Ramirez', 2, 17, 5, 3, 1, 2, 6),
('1018', 'Fernanda', 'Gutierrez', 3, 18, 6, 2, 1, 3, 7),
('1019', 'Gabriel', 'Castro', 1, 19, 7, 1, 1, 1, 4),
('1020', 'Helena', 'Santos', 2, 20, 8, 2, 1, 2, 5),
('1021', 'Ismael', 'Paredes', 3, 21, 1, 3, 1, 3, 1),
('1022', 'Julia', 'Mendoza', 1, 22, 2, 2, 1, 1, 2),
('1023', 'Kevin', 'Ortiz', 2, 23, 3, 1, 1, 2, 3),
('1024', 'Lucia', 'Herrera', 3, 24, 4, 3, 1, 3, 4),
('1025', 'Martin', 'Rojas', 1, 1, 5, 2, 1, 1, 5),
('1026', 'Norma', 'Diaz', 2, 5, 6, 1, 1, 2, 6),
('1027', 'Olivia', 'Morales', 3, 2, 7, 2, 1, 3, 7),
('1028', 'Jose', 'Florez', 1, 3, 5, 2, 1, 1, 5),
('1029', 'Juan', 'Florez', 2, 5, 6, 1, 1, 2, 6),
('1030', 'Sara', 'Lozano', 3, 2, 7, 2, 1, 3, 7);

INSERT INTO trainers (nombre, apellido, direccion_id, telefono_id) VALUES
('Carlos', 'Lara', 1, 1),
('Johlver', 'Pardo', 2, 2),
('Miguel', 'García', 3, 3),
('Ana', 'Martínez', 4, 4);

INSERT INTO camper_telefono (camper_id, telefono_id) VALUES
(1, 1),
(2, 2),
(3, 3),
(4, 4);

INSERT INTO trainer_telefono (trainer_id, telefono_id) VALUES
(1, 1),
(2, 2),
(3, 3);

INSERT INTO conocimiento_trainer (trainer_id, skill_id) VALUES
(1, 1),
(2, 2),
(3, 3);

INSERT INTO asignacion_trainer (trainer_id, ruta_entrenamiento_id, horario_id) VALUES
(1, 1, 1),
(1, 2, 2),
(2, 1, 2),
(2, 3, 1),
(3, 2, 1);

INSERT INTO ruta_modulo (ruta_entrenamiento_id, modulo_id) VALUES
(1, 1),
(1, 2);

INSERT INTO ruta_fundamentos (ruta_entrenamiento_id, fundamentos_id) VALUES
(1, 1),
(1, 2),
(1, 3);

INSERT INTO ruta_web (ruta_entrenamiento_id, web_id) VALUES
(1, 1),
(1, 2),
(1, 3);

INSERT INTO area_ruta (area_id, ruta_entrenamiento_id, horario_id) VALUES
(1, 1, 1),
(2, 1, 2);

INSERT INTO area_capacidad (area_id, ruta_entrenamiento_id, capacidad_actual) VALUES
(1, 1, 33),
(2, 1, 33);

INSERT INTO asistencia (camper_id, fecha, hora_ingreso, turno) VALUES
(1, '2023-12-01', '06:00:00', 'Mañana'),
(1, '2023-12-01', '14:00:00', 'Tarde');

INSERT INTO evaluacion (camper_id, ruta_entrenamiento_id, modulo_id, nota_teorica, nota_practica, nota_trabajo, nota_final) VALUES
(2, 1, 1, 45.00, 50.00, 50.00, 48.50),
(5, 1, 2, 40.00, 45.00, 45.00, 43.50),
(8, 1, 3, 55.00, 48.00, 45.00, 49.90),
(10, 1, 1, 35.00, 45.00, 40.00, 41.50),
(12, 1, 1, 35.00, 42.00, 40.00, 39.70),
(3, 1, 1, 75.00, 60.00, 85.00, 68.50),
(4, 1, 2, 85.00, 58.00, 88.00, 70.90),
(6, 1, 3, 70.00, 55.00, 80.00, 63.50),
(7, 1, 1, 95.00, 60.00, 90.00, 75.50),
(9, 1, 2, 88.00, 59.00, 90.00, 72.70),
(13, 1, 2, 50.00, 45.00, 45.00, 46.50),
(14, 1, 1, 35.00, 40.00, 40.00, 38.50),
(15, 1, 2, 50.00, 48.00, 45.00, 48.30),
(16, 1, 1, 35.00, 42.00, 40.00, 39.70),
(17, 1, 2, 50.00, 46.00, 45.00, 47.10),
(18, 1, 3, 55.00, 48.00, 45.00, 49.90),
(19, 1, 1, 65.00, 58.00, 70.00, 62.40),
(20, 1, 2, 70.00, 59.00, 75.00, 65.45),
(21, 1, 3, 55.00, 47.00, 45.00, 49.20),
(22, 1, 1, 75.00, 60.00, 80.00, 68.50),
(23, 1, 2, 50.00, 45.00, 45.00, 46.50),
(24, 1, 3, 55.00, 48.00, 45.00, 49.90),
(25, 1, 1, 85.00, 60.00, 90.00, 73.50),
(26, 1, 2, 50.00, 46.00, 45.00, 47.10),
(27, 1, 3, 55.00, 47.00, 45.00, 49.20),
(28, 1, 1, 78.00, 58.00, 82.00, 69.20),
(29, 1, 2, 50.00, 45.00, 45.00, 46.50),
(30, 1, 3, 88.00, 60.00, 85.00, 73.90);

INSERT INTO egresados (camper_id, ruta_entrenamiento_id) VALUES
(1, 1);