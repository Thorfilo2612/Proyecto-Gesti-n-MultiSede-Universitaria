📘 Sistema de Gestión Académica Multisede – Base de Datos (PostgreSQL)

Este proyecto corresponde al desarrollo completo de una base de datos relacional para un Sistema de Gestión Académica Multisede, siguiendo las especificaciones del documento oficial de la Fase II – Proyecto de Base de Datos I (UNIMET).
El sistema está diseñado para administrar información académica, administrativa y operativa de una universidad con múltiples sedes, incluyendo estudiantes, profesores, programas académicos, inventario, facturación, evaluaciones y más.

🚀 Contenido del Proyecto
  - Este repositorio incluye:
  - Script SQL completo (.sql) con:
  - Creación de dominios personalizados
  - Creación de tablas base y tablas dependientes
  - Llaves primarias, llaves foráneas y restricciones de integridad
  - Inserts coherentes y validados según el modelo
  - Funciones en PL/pgSQL
  - Triggers de control y automatización
  - Modelo Entidad–Relación (MER)
  - Modelo Relacional completo
  - Consultas SQL solicitadas en el proyecto
  - Validaciones de integridad y consistencia
  - Documentación del proceso

🧱 Tecnologías Utilizadas
  - PostgreSQL (versión recomendada: 14+)
  - pgAdmin 4 para gestión y ejecución del script
  - PL/pgSQL para triggers y funciones
  - Modelo diseñado con herramientas E-R (Draw.io, diagrams.net, etc.)

🛠️ Instalación y Ejecución
  1. Crear la base de datos
    En pgAdmin:
    CREATE DATABASE gestion_academica;
    Luego con clic derecho sobre la base → Query Tool.

  2. Ejecutar el script completo
    Ejecuta ProyectoBDD_DEF.sql en el Query Tool.
    
    El script:
    Crea los dominios
    Genera las tablas en orden correcto
    Inserta los datos
    Crea todas las funciones y triggers
    Verifica consistencia

  3. Validar el contenido
    Ejemplo:
    SELECT * FROM Persona;
    SELECT * FROM Estudiante;
    SELECT * FROM Factura;

📊 Principales Funcionalidades Implementadas
✔ Gestión de Personas
  Estudiantes
  Profesores
  Personal administrativo

✔ Gestión Académica
  Facultades
  Programas académicos
  Asignaturas y prerrequisitos
  Secciones y horarios
  Inscripciones
  Evaluaciones y notas

✔ Gestión Financiera
  Facturación
  Pagos y estados automáticos (trigger)
  Facturas de estudiantes y empresas

✔ Gestión de Recursos e Inventario
  Recursos académicos
  Materiales de laboratorio
  Equipos tecnológicos
  Software educativo
  Compras e inventario por sede

✔ Automatizaciones (Triggers)
  Actualización automática del estado de facturas
  Validaciones internas de integridad

🔍 Consultas Importantes
  Incluidas en el proyecto:
  Listado de estudiantes por sede y programa
  Profesores con contratos
  Inventario por sede
  Facturas vencidas y días restantes para pagar
  Inscripciones activas por sección
  Evaluaciones por asignatura
  Mucho más

👤 Autores
Anthony Flamez, Atacho Santiago y Martinez Fernando
Proyecto realizado para la asignatura Base de Datos I – UNIMET.

📄 Licencia
Este proyecto es únicamente para fines académicos. No se autoriza su copia o uso en otros cursos sin permiso del autor.
