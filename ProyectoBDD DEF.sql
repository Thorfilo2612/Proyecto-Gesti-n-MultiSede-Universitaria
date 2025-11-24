-- ===================================================================
-- PROYECTO BDD Gestión Academica Multi-Sede
-- Integrantes: Atacho Santiago, Martinez Fernando, Flamez Anthony
-- ===================================================================

-- ==========================================================
-- 1) DOMINIOS
-- ==========================================================
CREATE DOMAIN SX AS VARCHAR(15)
CHECK (VALUE IN ('femenino', 'masculino', 'N/A'));

CREATE DOMAIN TP AS VARCHAR(20)
CHECK (VALUE IN ('especializacion', 'maestria', 'doctorado'));

CREATE DOMAIN Mod AS VARCHAR(15)
CHECK (VALUE IN ('presencial', 'virtual', 'hibrida'));

CREATE DOMAIN TA AS VARCHAR(15)
CHECK (VALUE IN ('teorica', 'practica', 'mixta'));

CREATE DOMAIN TC AS VARCHAR(25)
CHECK (VALUE IN ('tiempo completo', 'medio tiempo', 'por horas'));

CREATE DOMAIN EA AS VARCHAR(15)
CHECK (VALUE IN ('activo', 'egresado', 'suspendido'));

CREATE DOMAIN EI AS VARCHAR(15)
CHECK (VALUE IN ('inscrito', 'retirado', 'reprobado', 'aprobado'));

CREATE DOMAIN EF AS VARCHAR(15)
CHECK (VALUE IN ('pagada', 'pendiente', 'vencida'));

CREATE DOMAIN MP AS VARCHAR(15)
CHECK (VALUE IN ('transferencia', 'efectivo', 'tarjeta', 'mixto'));

CREATE DOMAIN TE AS VARCHAR(15)
CHECK (VALUE IN ('parcial', 'practica', 'proyecto'));

CREATE DOMAIN TAU AS VARCHAR(20)
CHECK (VALUE IN ('auditorio', 'salon', 'laboratorio'));

CREATE DOMAIN Str AS VARCHAR(100);
CREATE DOMAIN Int AS INTEGER;
CREATE DOMAIN Float AS DECIMAL(10,2);
CREATE DOMAIN Bool AS BOOLEAN;

-- ==========================================================
-- 2) CREACIÓN DE TABLAS 
-- ==========================================================

CREATE TABLE Persona (
    CI INT PRIMARY KEY,
    nombre Str NOT NULL,
    apellido Str NOT NULL,
    fecha_nac DATE,
    direccion Str,
    correo Str UNIQUE
);

CREATE TABLE Sede_Universitaria (
    IDSede SERIAL PRIMARY KEY,
    nombre Str NOT NULL,
    ubicacion Str NOT NULL,
    cantidad_labs INT CHECK (cantidad_labs >= 0),
    cantidad_oficinas INT CHECK (cantidad_oficinas >= 0),
    cantidad_aulas INT CHECK (cantidad_aulas >= 0)
);

CREATE TABLE Proveedor (
    IDProv SERIAL PRIMARY KEY,
    nombre Str NOT NULL,
    ubicacion Str
);

CREATE TABLE Cargo_Admin (
    IDCargo SERIAL PRIMARY KEY,
    nombre Str NOT NULL
);

CREATE TABLE Periodo_Academico (
    periodo INT,
    trimestre INT,
    fecha_inicio DATE,
    fecha_fin DATE,
    PRIMARY KEY (periodo, trimestre)
);

CREATE TABLE Aula (
    numero SERIAL,
    tipo TAU NOT NULL,
    PRIMARY KEY (numero, tipo)
);

CREATE TABLE Horario (
    hora_inicio TIME,
    hora_fin TIME,
    dia_semana Str,
    PRIMARY KEY (hora_inicio, hora_fin, dia_semana)
);

CREATE TABLE Factura (
    num_factura SERIAL PRIMARY KEY,
    estado EF NOT NULL,
    monto_pagado FLOAT DEFAULT 0,
    fecha DATE NOT NULL,
    fecha_vencimiento DATE NOT NULL, 
    metodo MP,
    monto FLOAT CHECK (monto >= 0),
    CHECK (fecha_vencimiento >= fecha) -- Valida que no venza antes de emitirse
);

CREATE TABLE Empresa_Patrocinadora (
    RIF Str PRIMARY KEY,
    nombre Str NOT NULL,
    direccion Str,
    tipo_convenio Str,
    contacto Str
);

CREATE TABLE Recursos_Academicos (
    IDRec SERIAL PRIMARY KEY,
    nombre Str NOT NULL,
    descripcion Str
);

-- ==========================================================
-- TABLAS DEPENDIENTES
-- ==========================================================

CREATE TABLE Telefono_Persona (
    CI_Persona INT PRIMARY KEY,
    Telefono_Principal Str NOT NULL,
    Telefono_Secundario Str,
    FOREIGN KEY (CI_Persona) REFERENCES Persona(CI)
);

CREATE TABLE Personal (
    CI_Personal INT PRIMARY KEY,
    annios_exp INT CHECK (annios_exp >= 0),
    FOREIGN KEY (CI_Personal) REFERENCES Persona(CI)
);

CREATE TABLE Profesor (
    CI_Profesor INT PRIMARY KEY,
    FOREIGN KEY (CI_Profesor) REFERENCES Personal(CI_Personal)
);

CREATE TABLE Administrativo (
    CI_Admin INT PRIMARY KEY,
    FOREIGN KEY (CI_Admin) REFERENCES Personal(CI_Personal)
);

CREATE TABLE Facultad (
    codigoFacultad SERIAL PRIMARY KEY,
    CI_Profesor_Resp INT,
    nombre Str NOT NULL,
    FOREIGN KEY (CI_Profesor_Resp) REFERENCES Profesor(CI_Profesor)
);

CREATE TABLE Programa_Academico (
    IDPrograma SERIAL PRIMARY KEY,
    codigoFacultad INT,
    nombre Str NOT NULL,
    requisitos_ingreso Str,
    modalidad Mod NOT NULL,
    duracion INT CHECK (duracion > 0),
    tipo_programa Str NOT NULL,
    tipo_postgrado TP,
    FOREIGN KEY (codigoFacultad) REFERENCES Facultad(codigoFacultad)
);

CREATE TABLE Libro (
    ID_Libro INT PRIMARY KEY,
    ISBN Str,
    autor Str,
    edicion Str,
    editorial Str,
    FOREIGN KEY (ID_Libro) REFERENCES Recursos_Academicos(IDRec)
);

CREATE TABLE Software_Educativo (
    ID_Software INT PRIMARY KEY,
    licencia Str NOT NULL,
    fecha_expiracion DATE NOT NULL,
    FOREIGN KEY (ID_Software) REFERENCES Recursos_Academicos(IDRec)
);

CREATE TABLE Material_Lab (
    ID_Mat_Lab INT PRIMARY KEY,
    tipo Str NOT NULL,
    FOREIGN KEY (ID_Mat_Lab) REFERENCES Recursos_Academicos(IDRec)
);

CREATE TABLE Equipos_Tecnologicos (
    ID_Equipo_Tec INT PRIMARY KEY,
    CI_Profesor INT,
    modelo Str,
    tipo Str,
    marca Str,
    FOREIGN KEY (ID_Equipo_Tec) REFERENCES Recursos_Academicos(IDRec),
    FOREIGN KEY (CI_Profesor) REFERENCES Profesor(CI_Profesor)
);

CREATE TABLE Asignatura (
    codigoAsignatura SERIAL PRIMARY KEY,
    nombre Str NOT NULL,
    tipo TA NOT NULL,
    nro_creditos INT CHECK (nro_creditos > 0),
    codigoAsignaturaPrerrequisito INT,
    FOREIGN KEY (codigoAsignaturaPrerrequisito) REFERENCES Asignatura(codigoAsignatura)
);

CREATE TABLE Evaluacion (
    IDEvaluacion SERIAL PRIMARY KEY,
    codigoAsignatura INT,
    tipo TE NOT NULL,
    descripcion Str,
    ponderacion Float CHECK (ponderacion >= 0),
    FOREIGN KEY (codigoAsignatura) REFERENCES Asignatura(codigoAsignatura)
);

CREATE TABLE Estudiante (
    CI_Estudiante INT PRIMARY KEY,
    IDSede INT,
    fecha_ingreso DATE,
    nro_carnet Str UNIQUE,
    estado_aca EA NOT NULL,
    sexo SX NOT NULL,
    CIRep INT,
    parentesco Str,
    FOREIGN KEY (CI_Estudiante) REFERENCES Persona(CI),
    FOREIGN KEY (IDSede) REFERENCES Sede_Universitaria(IDSede),
    FOREIGN KEY (CIRep) REFERENCES Persona(CI)
);

-- ==========================================================
-- RELACIONES ENTRE ENTIDADES EXISTENTES
-- ==========================================================

CREATE TABLE Compra (
    IDSede INT,
    IDRec INT,
    IDProv INT,
    fecha_adq DATE,
    cantidad INT CHECK (cantidad > 0),
    PRIMARY KEY (IDSede, IDRec, IDProv),
    FOREIGN KEY (IDSede) REFERENCES Sede_Universitaria(IDSede),
    FOREIGN KEY (IDRec) REFERENCES Recursos_Academicos(IDRec),
    FOREIGN KEY (IDProv) REFERENCES Proveedor(IDProv)
);

CREATE TABLE Inventario (
    IDRec INT,
    IDSede INT,
    cantidad_disponible INT CHECK (cantidad_disponible >= 0),
    PRIMARY KEY (IDRec, IDSede),
    FOREIGN KEY (IDRec) REFERENCES Recursos_Academicos(IDRec),
    FOREIGN KEY (IDSede) REFERENCES Sede_Universitaria(IDSede)
);

CREATE TABLE Sede_Tiene_Facultad (
    IDSede INT,
    codigoFacultad INT,
    PRIMARY KEY (IDSede, codigoFacultad),
    FOREIGN KEY (IDSede) REFERENCES Sede_Universitaria(IDSede),
    FOREIGN KEY (codigoFacultad) REFERENCES Facultad(codigoFacultad)
);

CREATE TABLE Plan_Estudio (
    IDPrograma INT,
    codigoAsignatura INT,
    es_obligatoria Bool,
    PRIMARY KEY (IDPrograma, codigoAsignatura),
    FOREIGN KEY (IDPrograma) REFERENCES Programa_Academico(IDPrograma),
    FOREIGN KEY (codigoAsignatura) REFERENCES Asignatura(codigoAsignatura)
);

CREATE TABLE Cursa (
    CI_Estudiante INT,
    IDPrograma INT,
    fecha_inicio DATE,
    promedio Float CHECK (promedio >= 0 AND promedio <= 20),
    PRIMARY KEY (CI_Estudiante, IDPrograma),
    FOREIGN KEY (CI_Estudiante) REFERENCES Estudiante(CI_Estudiante),
    FOREIGN KEY (IDPrograma) REFERENCES Programa_Academico(IDPrograma)
);

CREATE TABLE Presenta (
    CI_Estudiante INT,
    IDEvaluacion INT,
    calificacion Float CHECK (calificacion >= 0 AND calificacion <= 20),
    PRIMARY KEY (CI_Estudiante, IDEvaluacion),
    FOREIGN KEY (CI_Estudiante) REFERENCES Estudiante(CI_Estudiante),
    FOREIGN KEY (IDEvaluacion) REFERENCES Evaluacion(IDEvaluacion)
);

CREATE TABLE Seccion (
    numero SERIAL,
    codigoAsignatura INT,
    CI_Profesor INT,
    periodo INT,
    trimestre INT,
    numero_aula INT,
    tipo TAU,
    hora_inicio TIME,
    hora_fin TIME,
    dia_semana Str,
    capacidad INT CHECK (capacidad > 0),
    PRIMARY KEY (numero, codigoAsignatura, periodo, trimestre),
    FOREIGN KEY (codigoAsignatura) REFERENCES Asignatura(codigoAsignatura),
    FOREIGN KEY (CI_Profesor) REFERENCES Profesor(CI_Profesor),
    FOREIGN KEY (periodo, trimestre) REFERENCES Periodo_Academico(periodo, trimestre),
    FOREIGN KEY (numero_aula, tipo) REFERENCES Aula(numero, tipo),
    FOREIGN KEY (hora_inicio, hora_fin, dia_semana) REFERENCES Horario(hora_inicio, hora_fin, dia_semana)
);

CREATE TABLE Inscribe (
    CI_Estudiante INT,
    codigoAsignatura INT,
    numeroSeccion INT,
    periodo INT,
    trimestre INT,
    fecha DATE,
    estado_ins EI,
    calificacion_final Float CHECK (calificacion_final >= 0 AND calificacion_final <= 20),
    PRIMARY KEY (CI_Estudiante, codigoAsignatura, numeroSeccion, periodo, trimestre),
    FOREIGN KEY (CI_Estudiante) REFERENCES Estudiante(CI_Estudiante),
    FOREIGN KEY (codigoAsignatura) REFERENCES Asignatura(codigoAsignatura),
    FOREIGN KEY (periodo, trimestre) REFERENCES Periodo_Academico(periodo, trimestre)
);

CREATE TABLE Contrato (
    CI_Profesor INT,
    IDCargo INT,
    IDSede INT,
    codigoFacultad INT,
    tipo_contrato TC,
    salario FLOAT CHECK (salario >= 0),
    fecha_inicio DATE NOT NULL, 
    fecha_fin DATE,             
    PRIMARY KEY (CI_Profesor, IDCargo, IDSede, codigoFacultad),
    FOREIGN KEY (CI_Profesor) REFERENCES Profesor(CI_Profesor),
    FOREIGN KEY (IDCargo) REFERENCES Cargo_Admin(IDCargo),
    FOREIGN KEY (IDSede) REFERENCES Sede_Universitaria(IDSede),
    FOREIGN KEY (codigoFacultad) REFERENCES Facultad(codigoFacultad),
    CHECK (fecha_fin IS NULL OR fecha_fin >= fecha_inicio) -- Valida consistencia de fechas
);

CREATE TABLE Emite (
    CI_Admin INT,
    num_factura INT,
    PRIMARY KEY (CI_Admin, num_factura),
    FOREIGN KEY (CI_Admin) REFERENCES Administrativo(CI_Admin),
    FOREIGN KEY (num_factura) REFERENCES Factura(num_factura)
);

CREATE TABLE Factura_Empresa (
    RIF Str,
    num_factura INT,
    PRIMARY KEY (RIF, num_factura),
    FOREIGN KEY (RIF) REFERENCES Empresa_Patrocinadora(RIF),
    FOREIGN KEY (num_factura) REFERENCES Factura(num_factura)
);

CREATE TABLE Factura_Estudiante (
    CI_Estudiante INT,
    num_factura INT,
    PRIMARY KEY (CI_Estudiante, num_factura),
    FOREIGN KEY (CI_Estudiante) REFERENCES Estudiante(CI_Estudiante),
    FOREIGN KEY (num_factura) REFERENCES Factura(num_factura)
);

-- ==========================================================
-- 3) INSERTS 
-- ==========================================================

-- Insertar Personas
INSERT INTO Persona (CI, nombre, apellido, fecha_nac, direccion, correo) VALUES
(10000001, 'Ricardo', 'Gomez', '1980-05-15', 'Av. Principal, Caracas', 'rgomez@unimet.edu'),
(10000002, 'Ana', 'Martinez', '1975-11-20', 'Calle Luna, Caracas', 'amartinez@unimet.edu'),
(10000003, 'Luis', 'Hernandez', '1985-02-10', 'Av. Sol, Baruta', 'lhernandez@unimet.edu'),
(10000004, 'Maria', 'Perez', '1990-07-30', 'Calle 4, Chacao', 'mperez@unimet.edu'),
(10000005, 'Javier', 'Sosa', '1982-01-25', 'Av. America, Valencia', 'jsosa@unimet.edu'),
(10000006, 'Elena', 'Rivas', '1979-09-12', 'Calle 7, Maracaibo', 'erivas@unimet.edu'),
(15000001, 'Carlos', 'Rodriguez', '1988-03-12', 'Av. Urdaneta, Caracas', 'crodriguez@unimet.edu'),
(15000002, 'Laura', 'Sanchez', '1992-09-05', 'Calle 5, El Hatillo', 'lsanchez@unimet.edu'),
(15000003, 'Andres', 'Bello', '1970-01-01', 'Plaza Venezuela, Caracas', 'abello@unimet.edu'),
(15000004, 'Lucia', 'Mendez', '1995-04-18', 'Av. Bolivar, Valencia', 'lmendez@unimet.edu'),
(20000001, 'Miguel', 'Suarez', '1970-06-20', 'Av. Libertador, Caracas', 'msuarez@rep.com'),
(20000002, 'Isabel', 'Castro', '1972-08-30', 'Av. Casanova, Caracas', 'icastro@rep.com'),
(20000003, 'Roberto', 'Silva', '1968-12-10', 'Calle Real, La Castellana', 'rsilva@rep.com'),
(20000004, 'Patricia', 'Nuñez', '1975-03-05', 'El Viñedo, Valencia', 'pnunez@rep.com'),
(30000001, 'Juan', 'Suarez', '2005-04-10', 'Av. Libertador, Caracas', 'jsuarez@unimet.edu'),
(30000002, 'Sofia', 'Castro', '2006-02-15', 'Av. Casanova, Caracas', 'scastro@unimet.edu'),
(30000003, 'Diego', 'Silva', '2004-11-05', 'Calle Real, La Castellana', 'dsilva@unimet.edu'),
(30000004, 'Camila', 'Diaz', '2003-08-20', 'Av. Panteon, Caracas', 'cdiaz@unimet.edu'),
(30000005, 'Mateo', 'Rojas', '2002-01-30', 'Calle Vzla, Bello Monte', 'mrojas@unimet.edu'),
(30000006, 'Valentina', 'Mora', '2006-03-12', 'Av. Este 6, Caracas', 'vmora@unimet.edu'),
(30000007, 'Lucas', 'Nuñez', '2005-07-22', 'El Viñedo, Valencia', 'lnunez@unimet.edu'),
(30000008, 'Gabriela', 'Peña', '2004-09-01', 'Av. Cedeño, Valencia', 'gpena@unimet.edu');

-- Insertar Sedes Universitarias
INSERT INTO Sede_Universitaria (nombre, ubicacion, cantidad_labs, cantidad_oficinas, cantidad_aulas) VALUES
('Sede Caracas', 'Urb. Terrazas del Ávila, Caracas', 30, 50, 60),
('Sede Valencia', 'Urb. Prebo, Valencia', 20, 30, 40),
('Sede Maracaibo', 'Av. 5 de Julio, Maracaibo', 15, 25, 30),
('Sede Guayana', 'Puerto Ordaz, Bolívar', 10, 15, 20);

-- Insertar Proveedores
INSERT INTO Proveedor (nombre, ubicacion) VALUES
('Suministros Tecnológicos C.A.', 'Boleíta Sur, Caracas'),
('Papelería y Libros El Sol', 'Centro, Valencia'),
('Equipos de Laboratorio LabTech', 'Zona Industrial, Maracaibo'),
('Muebles de Oficina J&M', 'Las Mercedes, Caracas'),
('Software Solutions Inc.', 'Palo Alto, CA, USA');

-- Insertar Cargos Administrativos
INSERT INTO Cargo_Admin (nombre) VALUES
('Rector'), ('Decano'), ('Director de Escuela'), ('Coordinador Académico'),
('Asistente Administrativo'), ('Gerente de Finanzas');

-- Insertar Períodos Académicos
INSERT INTO Periodo_Academico (periodo, trimestre, fecha_inicio, fecha_fin) VALUES
(2023, 3, '2023-09-18', '2023-12-15'),
(2024, 1, '2024-01-15', '2024-04-12'),
(2024, 2, '2024-05-06', '2024-08-02'),
(2024, 3, '2024-09-16', '2024-12-13'),
(2025, 1, '2025-01-13', '2025-04-11'),
(2025, 2, '2025-05-05', '2025-08-01');

-- Insertar Aulas
INSERT INTO Aula (tipo) VALUES
('salon'), ('salon'), ('salon'), ('salon'), ('salon'),
('laboratorio'), ('laboratorio'), ('laboratorio'),
('auditorio'), ('salon'), ('salon'), ('laboratorio');

-- Insertar Horarios
INSERT INTO Horario (hora_inicio, hora_fin, dia_semana) VALUES
('07:00:00', '08:45:00', 'Lunes'), ('08:45:00', '10:30:00', 'Lunes'), ('10:45:00', '12:30:00', 'Lunes'), ('13:30:00', '15:15:00', 'Lunes'),
('07:00:00', '08:45:00', 'Martes'), ('08:45:00', '10:30:00', 'Martes'), ('10:45:00', '12:30:00', 'Martes'), ('13:30:00', '15:15:00', 'Martes'),
('07:00:00', '08:45:00', 'Miercoles'), ('08:45:00', '10:30:00', 'Miercoles'), ('10:45:00', '12:30:00', 'Miercoles'),
('07:00:00', '08:45:00', 'Jueves'), ('08:45:00', '10:30:00', 'Jueves'),
('07:00:00', '08:45:00', 'Viernes'), ('08:45:00', '10:30:00', 'Viernes');

-- Insertar Facturas (ACTUALIZADAS: Incluye columna fecha_vencimiento)
-- ATENCIÓN: Se actualizaron las últimas 2 para que estén VIGENTES en Noviembre 2025
INSERT INTO Factura (estado, monto_pagado, fecha, fecha_vencimiento, metodo, monto) VALUES
('pagada', 1500.00, '2025-01-10', '2025-02-10', 'transferencia', 1500.00),
('pagada', 1450.00, '2025-01-11', '2025-02-11', 'tarjeta', 1450.00),
('pagada', 1500.00, '2025-01-12', '2025-02-12', 'mixto', 1500.00),
('pagada', 1600.00, '2025-05-01', '2025-06-01', 'transferencia', 1600.00),
('pendiente', 500.00, '2025-05-02', '2025-06-02', 'efectivo', 1600.00),
('vencida', 0.00, '2025-01-05', '2025-02-05', 'tarjeta', 1400.00),
('pagada', 250.00, '2025-03-10', '2025-04-10', 'transferencia', 250.00),
('pagada', 300.00, '2025-03-11', '2025-04-11', 'transferencia', 300.00),
('pagada', 1600.00, '2025-09-10', '2025-10-10', 'tarjeta', 1600.00),
('pagada', 1600.00, '2025-09-11', '2025-10-11', 'tarjeta', 1600.00),
-- DATOS PARA CONSULTA F (Vencen en Diciembre 2025)
-- Se cambiaron de Mayo a Noviembre para que sean "días restantes" positivos
('pendiente', 1000.00, '2025-11-20', '2025-12-05', 'mixto', 2500.00),
('pendiente', 0.00, '2025-11-20', '2025-12-15', 'mixto', 2200.00);

-- Insertar Empresas Patrocinadoras
INSERT INTO Empresa_Patrocinadora (RIF, nombre, direccion, tipo_convenio, contacto) VALUES
('J-12345678-1', 'Empresas Polar', 'Av. Principal, Los Cortijos', 'Pasantías y Becas', 'rrhh@polar.com'),
('J-23456789-2', 'Bancaribe', 'Av. Tamanaco, El Rosal', 'Beca Mérito', 'fundacion@bancaribe.com'),
('J-34567890-3', 'Microsoft Venezuela', 'Torre HP, Los Palos Grandes', 'Convenio Tecnológico', 'contacto@microsoft.com');

-- Insertar Recursos Académicos
INSERT INTO Recursos_Academicos (nombre, descripcion) VALUES
('Libro: Cálculo I de Stewart', 'Libro de texto para Cálculo Básico'),
('Libro: Física I de Serway', 'Libro de texto para Física Mecánica'),
('Software: AutoCAD 2024', 'Licencia educacional de software de diseño'),
('Software: MATLAB', 'Licencia de campus para software matemático'),
('Material: Kit de Química Orgánica', 'Reactivos y material de vidrio'),
('Material: Osciloscopio Digital', 'Equipo para laboratorio de física/electrónica'),
('Equipo: Proyector Epson', 'Proyector para aulas'),
('Equipo: Laptop Dell Vostro', 'Laptop para uso de profesores'),
('Libro: Introducción a la Programación', 'Libro de texto para Algoritmos'),
('Software: Adobe Creative Cloud', 'Suite de diseño gráfico y video');

-- Teléfonos
INSERT INTO Telefono_Persona (CI_Persona, Telefono_Principal, Telefono_Secundario) VALUES
(10000001, '0414-1112233', '0212-2112233'), (10000002, '0412-2223344', NULL), (10000003, '0416-3334455', '0212-3334455'),
(10000004, '0414-5556677', NULL), (10000005, '0424-6667788', '0241-6667788'), (15000001, '0414-4445566', NULL),
(15000002, '0412-5556677', NULL), (15000004, '0424-8889900', NULL), (20000001, '0416-6667788', '0212-6667788'),
(20000002, '0414-7778899', NULL), (20000004, '0424-1112233', '0241-1112233'), (30000001, '0412-8889900', '0212-8889900'),
(30000002, '0414-9990011', NULL), (30000003, '0416-0001122', NULL), (30000004, '0412-1112233', '0212-1112233'),
(30000007, '0424-2223344', NULL), (30000008, '0414-3334455', '0241-3334455');

-- Personal
INSERT INTO Personal (CI_Personal, annios_exp) VALUES
(10000001, 15), (10000002, 20), (10000003, 10), (10000004, 5), (10000005, 13), (10000006, 16),
(15000001, 7), (15000002, 3), (15000003, 30), (15000004, 2);

-- Estudiantes
INSERT INTO Estudiante (CI_Estudiante, IDSede, fecha_ingreso, nro_carnet, estado_aca, sexo, CIRep, parentesco) VALUES
(30000001, 1, '2023-09-15', '2023-0001', 'activo', 'masculino', 20000001, 'Padre'),
(30000002, 1, '2024-01-15', '2024-0002', 'activo', 'femenino', 20000002, 'Madre'),
(30000003, 2, '2022-09-10', '2022-0003', 'activo', 'masculino', 20000003, 'Padre'),
(30000004, 1, '2021-09-12', '2021-0004', 'egresado', 'femenino', NULL, NULL),
(30000005, 2, '2020-05-10', '2020-0005', 'egresado', 'masculino', NULL, NULL),
(30000006, 1, '2023-09-15', '2023-0006', 'suspendido', 'femenino', 20000002, 'Madre'),
(30000007, 2, '2023-01-10', '2023-0007', 'activo', 'masculino', 20000004, 'Padre'),
(30000008, 2, '2024-01-15', '2024-0008', 'activo', 'femenino', NULL, NULL);

-- Libros, Software, Material
INSERT INTO Libro (ID_Libro, ISBN, autor, edicion, editorial) VALUES
(1, '978-0538497817', 'James Stewart', '7ma', 'Cengage Learning'), (2, '978-1305952300', 'Serway, Jewett', '10ma', 'Cengage Learning'), (9, '978-8448156649', 'Luis Joyanes Aguilar', '1ra', 'McGraw-Hill');
INSERT INTO Software_Educativo (ID_Software, licencia, fecha_expiracion) VALUES
(3, 'EDU-12345-AUTOCAD', '2025-12-31'), (4, 'CAMPUS-98765-MATLAB', '2026-06-30'), (10, 'ADOBE-CAMPUS-77889', '2025-08-31');
INSERT INTO Material_Lab (ID_Mat_Lab, tipo) VALUES (5, 'Químico'), (6, 'Electrónico');

-- Asignaturas
INSERT INTO Asignatura (nombre, tipo, nro_creditos, codigoAsignaturaPrerrequisito) VALUES
('Cálculo I', 'teorica', 5, NULL), ('Física I', 'mixta', 4, NULL), ('Programación I', 'practica', 4, NULL), ('Química General', 'mixta', 4, NULL), ('Cálculo II', 'teorica', 5, 1), ('Física II', 'mixta', 4, 2), ('Programación II', 'practica', 4, 3), ('Cálculo III', 'teorica', 5, 5), ('Estructuras Discretas', 'teorica', 4, NULL), ('Introducción a la Economía', 'teorica', 3, NULL), ('Psicología General', 'teorica', 3, NULL);

-- Profesores y Admin
INSERT INTO Profesor (CI_Profesor) VALUES (10000001),(10000002),(10000003),(10000004),(10000005),(10000006);
INSERT INTO Administrativo (CI_Admin) VALUES (15000001),(15000002),(15000003),(15000004);

-- Equipos
INSERT INTO Equipos_Tecnologicos (ID_Equipo_Tec, CI_Profesor, modelo, tipo, marca) VALUES
(7, 10000001, 'PowerLite S39', 'Proyector', 'Epson'), (8, 10000002, 'Vostro 3400', 'Laptop', 'Dell');

-- Compras
INSERT INTO Compra (IDSede, IDRec, IDProv, fecha_adq, cantidad) VALUES
(1, 1, 2, '2024-01-05', 150), (1, 3, 5, '2024-01-10', 100), (1, 4, 5, '2024-01-10', 100), (2, 7, 1, '2024-03-01', 50),
(1, 5, 3, '2024-02-15', 30), (2, 2, 2, '2024-01-06', 50), (3, 6, 3, '2024-02-20', 10), (1, 10, 5, '2024-05-10', 75);

-- Inventario
INSERT INTO Inventario (IDRec, IDSede, cantidad_disponible) VALUES
(1, 1, 20), (3, 1, 10), (4, 1, 25), (7, 2, 40), (5, 1, 15), (2, 2, 30), (6, 3, 5), (10, 1, 20);

-- Facultades
INSERT INTO Facultad (CI_Profesor_Resp, nombre) VALUES
(10000001, 'Facultad de Ingeniería'), (10000002, 'Facultad de Ciencias y Artes'),
(10000003, 'Facultad de Ciencias Económicas y Sociales'), (10000004, 'Facultad de Estudios Jurídicos y Políticos');

-- Evaluaciones
INSERT INTO Evaluacion (codigoAsignatura, tipo, descripcion, ponderacion) VALUES
(1, 'parcial', 'Primer Parcial de Cálculo I', 0.25), (1, 'parcial', 'Segundo Parcial de Cálculo I', 0.30),
(1, 'practica', 'Examen Práctico Cálculo I', 0.35), (3, 'proyecto', 'Proyecto Final de Programación I', 0.40),
(3, 'parcial', 'Parcial 1 de Programación I', 0.20), (2, 'practica', 'Práctica de Laboratorio 1 de Física I', 0.15),
(2, 'parcial', 'Parcial de Física I', 0.25), (5, 'parcial', 'Parcial 1 de Cálculo II', 0.30),
(7, 'proyecto', 'Proyecto 1 de Programación II', 0.50);

-- Programas
INSERT INTO Programa_Academico (codigoFacultad, nombre, requisitos_ingreso, modalidad, duracion, tipo_programa, tipo_postgrado) VALUES
(1, 'Ingeniería de Sistemas', 'Título de Bachiller, Prueba Interna', 'presencial', 5, 'Pregrado', NULL),
(1, 'Ingeniería Civil', 'Título de Bachiller, Prueba Interna', 'presencial', 5, 'Pregrado', NULL),
(1, 'Ingeniería Mecánica', 'Título de Bachiller, Prueba Interna', 'presencial', 5, 'Pregrado', NULL),
(1, 'Maestría en Ingeniería Gerencial', 'Título de Pregrado, Entrevista', 'hibrida', 2, 'Postgrado', 'maestria'),
(1, 'Doctorado en Ingeniería', 'Título de Maestría', 'presencial', 3, 'Postgrado', 'doctorado'),
(2, 'Psicología', 'Título de Bachiller, Prueba Interna', 'presencial', 5, 'Pregrado', NULL),
(2, 'Matemáticas', 'Título de Bachiller, Prueba Interna', 'presencial', 5, 'Pregrado', NULL),
(3, 'Economía', 'Título de Bachiller, Prueba Interna', 'presencial', 5, 'Pregrado', NULL),
(3, 'Especialización en Finanzas', 'Título de Pregrado', 'virtual', 1, 'Postgrado', 'especializacion');

-- Sede-Facultad
INSERT INTO Sede_Tiene_Facultad (IDSede, codigoFacultad) VALUES (1,1),(1,2),(1,3),(1,4),(2,1),(2,3),(3,2),(4,1);

-- Contratos (ACTUALIZADO: Incluye columnas fecha_inicio y fecha_fin)
-- Si no agregamos estas columnas, el INSERT fallará.
INSERT INTO Contrato (CI_Profesor, IDCargo, IDSede, codigoFacultad, tipo_contrato, salario, fecha_inicio, fecha_fin) VALUES
-- Caso Ricardo Gomez: 2 Cargos para que cumpla Query D
(10000001, 2, 1, 1, 'tiempo completo', 2500.00, '2023-01-01', NULL),
(10000001, 4, 1, 1, 'por horas', 500.00, '2020-01-01', '2022-12-31'), -- Cargo viejo

(10000002, 3, 1, 2, 'tiempo completo', 2200.00, '2022-05-15', NULL),
(10000003, 4, 1, 1, 'medio tiempo', 1500.00, '2023-03-01', NULL),
(10000004, 3, 1, 3, 'por horas', 1000.00, '2024-01-15', NULL),
(10000005, 3, 2, 1, 'tiempo completo', 2100.00, '2021-09-01', NULL),
(10000006, 4, 3, 2, 'medio tiempo', 1400.00, '2023-06-20', NULL);

-- Plan de Estudio
INSERT INTO Plan_Estudio (IDPrograma, codigoAsignatura, es_obligatoria) VALUES
(1,1, TRUE),(2,1, TRUE),(3,1, TRUE),(1,3, TRUE),(6,3, FALSE),(1,2, TRUE),(2,2, TRUE),
(8,10, TRUE),(1,10, FALSE),(1,5, TRUE),(1,6, TRUE),(1,7, TRUE),(1,9, TRUE),(2,4, TRUE),(2,5, TRUE);

-- Cursa
INSERT INTO Cursa (CI_Estudiante, IDPrograma, fecha_inicio, promedio) VALUES
(30000001, 1, '2023-09-15', 18.50), (30000002, 1, '2024-01-15', 17.00), (30000003, 2, '2022-09-10', 16.20),
(30000004, 6, '2021-09-12', 19.10), (30000005, 8, '2020-05-10', 15.00), (30000006, 1, '2023-09-15', 10.50),
(30000007, 2, '2023-01-10', 14.80), (30000008, 3, '2024-01-15', 17.20);

-- Secciones
INSERT INTO Seccion (codigoAsignatura, CI_Profesor, periodo, trimestre, numero_aula, tipo, hora_inicio, hora_fin, dia_semana, capacidad) VALUES
(1,10000001,2024,1,1,'salon','07:00:00','08:45:00','Lunes',30),
(1,10000001,2024,1,2,'salon','08:45:00','10:30:00','Lunes',30),
(1,10000002,2024,2,1,'salon','07:00:00','08:45:00','Lunes',30),
(1,10000001,2024,3,2,'salon','07:00:00','08:45:00','Lunes',30),
(1,10000003,2025,1,1,'salon','07:00:00','08:45:00','Lunes',30),
(3,10000003,2024,1,6,'laboratorio','07:00:00','08:45:00','Martes',25),
(3,10000003,2024,1,6,'laboratorio','08:45:00','10:30:00','Martes',25),
(2,10000002,2024,1,3,'salon','07:00:00','08:45:00','Miercoles',30),
(5,10000001,2024,2,4,'salon','07:00:00','08:45:00','Lunes',30),
(7,10000003,2024,2,7,'laboratorio','07:00:00','08:45:00','Martes',25),
(4,10000006,2024,1,8,'laboratorio','10:45:00','12:30:00','Martes',20),
(10,10000004,2024,3,5,'salon','08:45:00','10:30:00','Miercoles',40);

-- Inscribe
INSERT INTO Inscribe (CI_Estudiante, codigoAsignatura, numeroSeccion, periodo, trimestre, fecha, estado_ins, calificacion_final) VALUES
(30000001,1,1,2024,1,'2024-01-10','aprobado',19.00),
(30000001,3,7,2024,1,'2024-01-12','aprobado',18.00),
(30000001,5,9,2024,2,'2024-05-01','aprobado',18.50),
(30000001,7,10,2024,2,'2024-05-01','aprobado',19.00),
(30000002,1,2,2024,1,'2024-01-11','aprobado',17.50),
(30000002,5,9,2024,2,'2024-05-02','retirado',NULL),
(30000003,2,8,2024,1,'2024-01-10','aprobado',16.00),
(30000004,3,6,2024,1,'2024-01-12','aprobado',20.00),
(30000006,1,1,2024,1,'2024-01-10','reprobado',8.00),
(30000006,3,6,2024,1,'2024-01-12','reprobado',10.00),
(30000007,2,8,2024,1,'2024-01-11','aprobado',15.00),
(30000007,4,11,2024,1,'2024-01-11','retirado',NULL);

-- Presenta
INSERT INTO Presenta (CI_Estudiante, IDEvaluacion, calificacion) VALUES
(30000001,1,18.00),(30000001,2,19.00),(30000001,3,20.00),
(30000002,1,17.00),(30000002,2,16.00),(30000002,3,19.00),
(30000004,4,20.00),(30000004,5,20.00),(30000001,8,18.00),(30000001,9,19.00);

-- Emite
INSERT INTO Emite (CI_Admin, num_factura) VALUES
(15000001,1),(15000001,2),(15000002,3),(15000002,4),
(15000001,5),(15000001,6),(15000004,9),(15000004,10),
(15000001,11),(15000002,12);

-- Factura_Empresa
INSERT INTO Factura_Empresa (RIF, num_factura) VALUES ('J-12345678-1',7),('J-23456789-2',8);

-- Factura_Estudiante
INSERT INTO Factura_Estudiante (CI_Estudiante, num_factura) VALUES
(30000001,1),(30000002,2),(30000003,3),(30000004,4),
(30000005,5),(30000006,6),(30000007,9),(30000008,10),
(30000001,11),(30000002,12);

-- ==========================================================
-- 4) PARCHE / VALIDACIÓN 
--    Ejecuta el SELECT; si devuelve 0, el ALTER siguiente se aplicará correctamente.
-- ==========================================================
SELECT COUNT(*) AS secciones_sin_profesor FROM Seccion WHERE CI_Profesor IS NULL;

-- Si el resultado anterior es 0, el siguiente ALTER hará que CI_Profesor sea NOT NULL en Seccion.
-- (Si devuelve > 0, corrige esos registros antes de ejecutar el ALTER)
ALTER TABLE Seccion
    ALTER COLUMN CI_Profesor SET NOT NULL;

-- ==========================================================
-- 5) FUNCIONES 
-- ==========================================================

-- 5.1 Actualizar Inventario 
CREATE OR REPLACE FUNCTION fn_actualizar_inventario()
RETURNS TRIGGER AS $$
BEGIN
    UPDATE Inventario
    SET cantidad_disponible = cantidad_disponible + NEW.cantidad
    WHERE IDRec = NEW.IDRec AND IDSede = NEW.IDSede;

    IF NOT FOUND THEN
        INSERT INTO Inventario (IDRec, IDSede, cantidad_disponible)
        VALUES (NEW.IDRec, NEW.IDSede, NEW.cantidad);
    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- 5.2 Egresar Estudiante (verifica créditos del programa)
CREATE OR REPLACE FUNCTION fn_egresar_estudiante()
RETURNS TRIGGER AS $$
DECLARE
    total_creditos_programa INT := 0;
    total_creditos_aprobados INT := 0;
BEGIN
    -- Total de créditos exigidos por el programa NEW.IDPrograma
    SELECT COALESCE(SUM(A.nro_creditos),0)
    INTO total_creditos_programa
    FROM Plan_Estudio PE
    JOIN Asignatura A ON PE.codigoAsignatura = A.codigoAsignatura
    WHERE PE.IDPrograma = NEW.IDPrograma;

    -- Total de créditos aprobados por el estudiante en asignaturas del programa NEW.IDPrograma
    SELECT COALESCE(SUM(A.nro_creditos),0)
    INTO total_creditos_aprobados
    FROM Inscribe I
    JOIN Asignatura A ON I.codigoAsignatura = A.codigoAsignatura
    JOIN Plan_Estudio PE ON A.codigoAsignatura = PE.codigoAsignatura AND PE.IDPrograma = NEW.IDPrograma
    WHERE I.CI_Estudiante = NEW.CI_Estudiante
      AND I.estado_ins = 'aprobado';

    IF total_creditos_programa > 0 AND total_creditos_aprobados >= total_creditos_programa THEN
        UPDATE Estudiante
        SET estado_aca = 'egresado'
        WHERE CI_Estudiante = NEW.CI_Estudiante;
    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- 5.3 Actualizar Estado Factura 
CREATE OR REPLACE FUNCTION fn_actualizar_estado_factura()
RETURNS TRIGGER AS $$
BEGIN
    IF NEW.monto_pagado >= NEW.monto THEN
        NEW.estado := 'pagada';
    ELSIF NEW.monto_pagado IS NULL OR NEW.monto_pagado = 0 THEN
        NEW.estado := 'pendiente';
    ELSE
        NEW.estado := 'pendiente';
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- 5.4 Validar Inscripción (duplicados y prerrequisitos transitivos)
CREATE OR REPLACE FUNCTION fn_validar_inscripcion()
RETURNS TRIGGER AS $$
DECLARE
    existe INT;
    prereq INT;
    aprobado INT;
BEGIN
    -- 1) Evitar duplicado exacto en misma sección/periodo/trimestre
    SELECT COUNT(*) INTO existe
    FROM Inscribe
    WHERE CI_Estudiante = NEW.CI_Estudiante
      AND codigoAsignatura = NEW.codigoAsignatura
      AND periodo = NEW.periodo
      AND trimestre = NEW.trimestre
      AND numeroSeccion = NEW.numeroSeccion;

    IF existe > 0 THEN
        RAISE EXCEPTION 'El estudiante % ya está inscrito en la asignatura % en la misma sección/periodo.', NEW.CI_Estudiante, NEW.codigoAsignatura;
    END IF;

    -- 2) Verificar prerrequisitos transitivos
    SELECT codigoAsignaturaPrerrequisito INTO prereq
    FROM Asignatura
    WHERE codigoAsignatura = NEW.codigoAsignatura;

    WHILE prereq IS NOT NULL LOOP
        SELECT COUNT(*) INTO aprobado
        FROM Inscribe
        WHERE CI_Estudiante = NEW.CI_Estudiante
          AND codigoAsignatura = prereq
          AND estado_ins = 'aprobado';

        IF aprobado = 0 THEN
            RAISE EXCEPTION 'El estudiante % no cumple el prerrequisito % para la asignatura %', NEW.CI_Estudiante, prereq, NEW.codigoAsignatura;
        END IF;

        SELECT codigoAsignaturaPrerrequisito INTO prereq
        FROM Asignatura
        WHERE codigoAsignatura = prereq;
    END LOOP;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- ==========================================================
-- 6) TRIGGERS 
-- ==========================================================

-- TR_ActualizarInventario (usando fn_actualizar_inventario)
DROP TRIGGER IF EXISTS TR_ActualizarInventario ON Compra;
CREATE TRIGGER TR_ActualizarInventario
AFTER INSERT ON Compra
FOR EACH ROW
EXECUTE FUNCTION fn_actualizar_inventario();

-- TR_EgresarEstudiante (usando fn_egresar_estudiante)
DROP TRIGGER IF EXISTS TR_EgresarEstudiante ON Cursa;
CREATE TRIGGER TR_EgresarEstudiante
AFTER INSERT OR UPDATE ON Cursa
FOR EACH ROW
EXECUTE FUNCTION fn_egresar_estudiante();

-- TR_ActualizarEstadoFactura (BEFORE insert/update)
DROP TRIGGER IF EXISTS TR_ActualizarEstadoFactura ON Factura;
CREATE TRIGGER TR_ActualizarEstadoFactura
BEFORE INSERT OR UPDATE ON Factura
FOR EACH ROW
EXECUTE FUNCTION fn_actualizar_estado_factura();

-- TR_ValidarInscripcion (BEFORE insert)
DROP TRIGGER IF EXISTS TR_ValidarInscripcion ON Inscribe;
CREATE TRIGGER TR_ValidarInscripcion
BEFORE INSERT ON Inscribe
FOR EACH ROW
EXECUTE FUNCTION fn_validar_inscripcion();

-- ==========================================================
-- 5. CONSULTAS (4 Pts)
-- ==========================================================

/* A. Presentar, por sede y facultad, el número total de programas de pregrado y
    postgrado ofrecidos, agrupando resultados por tipo de programa.
*/
SELECT 
    S.nombre AS Sede, 
    F.nombre AS Facultad, 
    P.tipo_programa, 
    COUNT(P.IDPrograma) AS Cantidad
FROM Sede_Universitaria S
JOIN Sede_Tiene_Facultad SF ON S.IDSede = SF.IDSede
JOIN Facultad F ON SF.codigoFacultad = F.codigoFacultad
JOIN Programa_Academico P ON F.codigoFacultad = P.codigoFacultad
GROUP BY S.nombre, F.nombre, P.tipo_programa
ORDER BY S.nombre, F.nombre;

/* B. Listar los nombres y estados de los estudiantes que han reprobado o se han
    retirado de al menos una asignatura en el último año académico.
*/
SELECT DISTINCT 
    P.nombre, 
    P.apellido, 
    I.estado_ins
FROM Estudiante E
JOIN Persona P ON E.CI_Estudiante = P.CI
JOIN Inscribe I ON E.CI_Estudiante = I.CI_Estudiante
WHERE I.periodo = 2024 
  AND I.estado_ins IN ('reprobado', 'retirado');

/* C. Top 3 recursos más utilizados, indicando la sede, proveedor, cantidad
    comprada y cantidad restante (Inventario).
*/
SELECT 
    R.nombre AS Recurso,
    S.nombre AS Sede,
    P.nombre AS Proveedor,
    C.cantidad AS Cantidad_Comprada,
    I.cantidad_disponible AS Cantidad_Restante
FROM Compra C
JOIN Recursos_Academicos R ON C.IDRec = R.IDRec
JOIN Sede_Universitaria S ON C.IDSede = S.IDSede
JOIN Proveedor P ON C.IDProv = P.IDProv
JOIN Inventario I ON C.IDRec = I.IDRec AND C.IDSede = I.IDSede
ORDER BY C.cantidad DESC
LIMIT 3;

/* D. Listar los profesores que han tenido al menos dos cargos diferentes y el
    tiempo que han permanecido en cada uno.
*/
SELECT 
    P.nombre, 
    P.apellido, 
    CA.nombre AS Cargo,
    C.fecha_inicio,
    COALESCE(C.fecha_fin, CURRENT_DATE) AS fecha_fin,
    AGE(COALESCE(C.fecha_fin, CURRENT_DATE), C.fecha_inicio) AS Tiempo_En_Cargo
FROM Contrato C
JOIN Persona P ON C.CI_Profesor = P.CI
JOIN Cargo_Admin CA ON C.IDCargo = CA.IDCargo
WHERE C.CI_Profesor IN (
    SELECT CI_Profesor
    FROM Contrato
    GROUP BY CI_Profesor
    HAVING COUNT(DISTINCT IDCargo) >= 2
);

/* E. Listar todas las asignaturas que se encuentran inscritas en más de un
    programa académico y cuántas veces han sido dictadas por profesores
    distintos en diferentes periodos.
*/
SELECT 
    A.nombre AS Asignatura,
    COUNT(DISTINCT PE.IDPrograma) AS Num_Programas,
    COUNT(DISTINCT (S.CI_Profesor, S.periodo)) AS Dictada_Por_Prof_Distintos
FROM Asignatura A
JOIN Plan_Estudio PE ON A.codigoAsignatura = PE.codigoAsignatura
JOIN Seccion S ON A.codigoAsignatura = S.codigoAsignatura
GROUP BY A.codigoAsignatura, A.nombre
HAVING COUNT(DISTINCT PE.IDPrograma) > 1;

/* F. Listar las facturas cuyo método de pago sea ‘mixto’, que aún presentan
    saldo pendiente, mostrando para cada una los días restantes hasta su vencimiento.
*/
SELECT 
    F.num_factura,
    F.monto,
    F.monto_pagado,
    (F.monto - F.monto_pagado) AS Saldo_Pendiente,
    F.fecha_vencimiento,
    (F.fecha_vencimiento - CURRENT_DATE) AS Dias_Restantes
FROM Factura F
WHERE F.metodo = 'mixto'
  AND F.estado = 'pendiente'
  AND F.fecha_vencimiento >= CURRENT_DATE;

/* G. Obtener los estudiantes egresados con honores ‘Cum Laude’ 
    (promedio general mayor o igual a 17,5)
*/
SELECT 
    P.nombre, 
    P.apellido, 
    C.promedio
FROM Cursa C
JOIN Estudiante E ON C.CI_Estudiante = E.CI_Estudiante
JOIN Persona P ON E.CI_Estudiante = P.CI
WHERE E.estado_aca = 'egresado'
  AND C.promedio >= 17.5;