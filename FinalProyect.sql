/*
Autor: Alejandro Borrego Megías

Creación de la base de datos, las tablas e inserción de datos
*/

DROP DATABASE IF EXISTS ProyectoMySQL;

CREATE DATABASE ProyectoMySQL;

USE ProyectoMySQL;

CREATE TABLE Artista (
    NombreArtista VARCHAR(50) PRIMARY KEY,
    Biografia VARCHAR(300)
);

-- Creación de la tabla Asistente
CREATE TABLE Asistente (
    Email VARCHAR(50) PRIMARY KEY,
    Nombre VARCHAR(50),
    Telefono VARCHAR(20)
);

-- Creación de la tabla Ubicación
CREATE TABLE Ubicacion (
    CodUbicacion INT AUTO_INCREMENT PRIMARY KEY,
    Nombre VARCHAR(50),
    Direccion VARCHAR(100),
    Ciudad VARCHAR(50),
    Aforo INT,
    Precio DECIMAL(10, 2),
    Caracteristicas VARCHAR(200)
);

-- Creación de la tabla Evento
CREATE TABLE Evento (
    CodEvento INT AUTO_INCREMENT PRIMARY KEY,
    Descripcion VARCHAR(200),
    Hora TIME,
    Fecha DATE,
    PrecioEntrada DECIMAL(10, 2),
    CodUbicacion INT,
    FOREIGN KEY (CodUbicacion) REFERENCES Ubicacion(CodUbicacion) ON DELETE NO ACTION
);

-- Creación de la tabla AsisteEvento
CREATE TABLE AsisteEvento (
    CodEvento INT,
    Email VARCHAR(50),
    PRIMARY KEY (CodEvento, Email),
    FOREIGN KEY (CodEvento) REFERENCES Evento(CodEvento) ON DELETE CASCADE,
    FOREIGN KEY (Email) REFERENCES Asistente(Email) ON DELETE CASCADE
);

CREATE TABLE Actividad (
    CodActividad INT AUTO_INCREMENT PRIMARY KEY,
    Nombre VARCHAR(255),
    Tipo ENUM('concierto', 'exposiciones', 'obra_de_teatro', 'conferencia', 'actividad_generica'),
    CodEvento INT,
    FOREIGN KEY (CodEvento) REFERENCES Evento(CodEvento) ON DELETE NO ACTION
);

CREATE TABLE Participa (
    NombreArtista VARCHAR(255),
    CodActividad INT,
    Cache DECIMAL(10, 2),
    PRIMARY KEY (NombreArtista, CodActividad),
    FOREIGN KEY (NombreArtista) REFERENCES Artista(NombreArtista) ON DELETE CASCADE,
    FOREIGN KEY (CodActividad) REFERENCES Actividad(CodActividad) ON DELETE CASCADE
);

CREATE TABLE Subtipo (
    CodSubtipo INT AUTO_INCREMENT PRIMARY KEY,
    Subtipo VARCHAR(255)
);

CREATE TABLE ActividadSubtipo (
    CodSubtipo INT,
    CodActividad INT,
    PRIMARY KEY (CodSubtipo, CodActividad),
    FOREIGN KEY (CodSubtipo) REFERENCES Subtipo(CodSubtipo) ON DELETE CASCADE,
    FOREIGN KEY (CodActividad) REFERENCES Actividad(CodActividad) ON DELETE CASCADE
);

-- Crea Trigger
DELIMITER //
CREATE TRIGGER CheckActividadTipo
BEFORE INSERT ON Actividad
FOR EACH ROW
BEGIN
    DECLARE tipoValido ENUM('concierto', 'exposiciones', 'obra_de_teatro', 'conferencia', 'actividad_generica');
    
    -- Comprueba si el tipo es válido
    IF NEW.Tipo NOT IN (tipoValido) THEN
        SET NEW.Tipo = 'actividad_generica'; -- Establece el valor predeterminado (o el que desees) si el tipo no es válido
    END IF;
END//

-- Inserción de datos de muestra
INSERT INTO Artista (NombreArtista, Biografia) VALUES
    ('Melendi', 'Artista español que lleva cantando muchos años'),
    ('Morat', 'Grupo Colombiano de música pop-country'),
    ('JaimeLlorente', 'Actor Español');

INSERT INTO Asistente (Email, Nombre, Telefono) VALUES
    ('juanPer34@example.com', 'Juan Pérez', '+1234567890'),
    ('M.gonzalez_99@example.com', 'María González', '+9876543210'),
    ('luisRodri98@example.com', 'Luis Rodríguez', '+1122334455');

INSERT INTO Ubicacion (Nombre, Direccion, Ciudad, Aforo, Precio, Caracteristicas) VALUES
    ('Ubicación1', 'Calle A, 123', 'Ciudad A', 1000, 50.00, 'Características de Ubicación 1'),
    ('Ubicación2', 'Avenida B, 456', 'Ciudad B', 1500, 40.00, 'Características de Ubicación 2'),
    ('Ubicación3', 'Calle C, 789', 'Ciudad C', 800, 60.00, 'Características de Ubicación 3');

INSERT INTO Evento (Descripcion, Hora, Fecha, PrecioEntrada, CodUbicacion) VALUES
    ('Madrid Sound', '19:00:00', '2023-12-15', 30.00, 1),
    ('Festival de Musica Granada', '14:00:00', '2023-11-20', 10.00, 2),
    ('Semana de Calderón', '20:30:00', '2023-12-05', 25.00, 3),
    ('Carrera F.Alonso', '20:30:00', '2023-12-08', 97.00, 3);

INSERT INTO AsisteEvento (CodEvento, Email) VALUES
    (1, 'juanPer34@example.com'), -- Juan Pérez asiste al Concierto de Rock
    (2, 'M.gonzalez_99@example.com'), -- María González asiste a la Exposición de Arte Contemporáneo
    (3, 'luisRodri98@example.com'); -- Luis Rodríguez asiste a la Obra de Teatro Clásica

INSERT INTO Actividad (Nombre, Tipo, CodEvento) VALUES
    ('Concierto en Vivo', 'concierto', 1),
    ('Exposición de Arte Moderno', 'exposiciones', 2),
    ('Obra de Teatro Clásica', 'obra_de_teatro', 3),
	('Carrera de Formula 1', 'carreras', 4);

INSERT INTO Participa (NombreArtista, CodActividad, Cache) VALUES
    ('Melendi', 1, 1000.00),
    ('Morat', 1, 800.00),
    ('Jaime Llorente', 2, 1200.00);

INSERT INTO Subtipo (Subtipo) VALUES
    ('Subtipo1'),
    ('Subtipo2'),
    ('Subtipo3');

INSERT INTO ActividadSubtipo (CodSubtipo, CodActividad) VALUES
    (1, 1),  -- Concierto en Vivo pertenece a Subtipo1
    (2, 2),  -- Exposición de Arte Moderno pertenece a Subtipo2
    (2, 3);  -- Obra de Teatro Clásica pertenece a Subtipo2





-- Trigger Ideas:


-- Create the Audit Trail table (if it doesn't already exist)
CREATE TABLE IF NOT EXISTS ArtistaAuditTrail (
    ChangeID INT AUTO_INCREMENT PRIMARY KEY,
    NombreArtista VARCHAR(50),
    BiografiaOld VARCHAR(300),
    BiografiaNew VARCHAR(300),
    ChangeTimestamp TIMESTAMP
);

-- Create the Audit Trail Trigger for the Artista table
-- 1. Artista AuditTrail
DELIMITER //
CREATE TRIGGER Artista_AuditTrail
AFTER UPDATE ON Artista
FOR EACH ROW
BEGIN
    INSERT INTO ArtistaAuditTrail (NombreArtista, BiografiaOld, BiografiaNew, ChangeTimestamp)
    VALUES (OLD.NombreArtista, OLD.Biografia, NEW.Biografia, NOW());
END;
//
DELIMITER ;
-- Update the Biografia column for an artist
UPDATE Artista
SET Biografia = 'Updated biography'
WHERE NombreArtista = 'ArtistName';

-- Check the ArtistaAuditTrail table to view the change log
SELECT * FROM ArtistaAuditTrail;


-- Ubication Price AuditTrail
-- Create the Price Change Audit Trail table (if it doesn't already exist)
CREATE TABLE IF NOT EXISTS UbicacionPriceAuditTrail (
    ChangeID INT AUTO_INCREMENT PRIMARY KEY,
    CodUbicacion INT,
    PrecioOld DECIMAL(10, 2),
    PrecioNew DECIMAL(10, 2),
    ChangeTimestamp TIMESTAMP
);

-- Create the Price Change Trigger for the Ubicacion table
DELIMITER //
CREATE TRIGGER Ubicacion_PriceChange
AFTER UPDATE ON Ubicacion
FOR EACH ROW
BEGIN
    IF OLD.Precio <> NEW.Precio THEN
        INSERT INTO UbicacionPriceAuditTrail (CodUbicacion, PrecioOld, PrecioNew, ChangeTimestamp)
        VALUES (OLD.CodUbicacion, OLD.Precio, NEW.Precio, NOW());
    END IF;
END;
//
DELIMITER ;

-- Update the Precio column for a location
UPDATE Ubicacion
SET Precio = 50.00
WHERE CodUbicacion = 1;

-- Check the UbicacionPriceAuditTrail table to view the price change log
SELECT * FROM UbicacionPriceAuditTrail;
