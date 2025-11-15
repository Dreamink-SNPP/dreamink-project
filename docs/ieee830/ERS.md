# Especificación de Requisitos de Software

**Proyecto:** DreamInk - Sistema de Gestión de Estructura Dramática
**Versión:** 1.0
**Fecha:** 15 de noviembre de 2025
**Autores:** Equipo DreamInk

## Introducción

### Propósito

Este documento establece la especificación completa de requisitos del sistema DreamInk, una aplicación web para la gestión de estructura dramática en obras audiovisuales durante la fase de preproducción. El presente documento describe de manera detallada los requisitos funcionales y no funcionales que el sistema debe cumplir para satisfacer las necesidades de los usuarios finales.

El documento está dirigido principalmente al equipo de desarrollo de software responsable de la implementación y mantenimiento del sistema DreamInk. Adicionalmente, sirve como referencia para los evaluadores de calidad, testers y analistas que participan en las pruebas de aceptación y validación del producto. También puede ser utilizado por stakeholders técnicos que requieran comprender el alcance y las capacidades del sistema.

La especificación aquí presentada sigue el estándar IEEE 830 para documentación de requisitos de software. Este estándar garantiza que la descripción de requisitos sea completa, verificable y trazable durante todo el ciclo de vida del desarrollo. El documento mantiene un nivel de detalle suficiente para permitir la implementación técnica sin ambigüedades, facilitando la validación posterior de que el sistema cumple con las expectativas establecidas.

### Ámbito del sistema

El sistema descrito en este documento se denomina **DreamInk**. Se trata de una aplicación web diseñada para gestionar la estructura dramática de obras audiovisuales durante la fase de preproducción. El sistema permite a los guionistas organizar proyectos mediante una jerarquía narrativa de actos, secuencias y escenas, desarrollar perfiles detallados de personajes con rasgos internos y externos, administrar locaciones y sus relaciones con las escenas, mantener un banco de ideas creativas, y exportar toda la información a formatos profesionales como PDF y Fountain.

DreamInk **no** es un editor de guiones literarios ni un procesador de texto especializado para la escritura del documento final de guión. El sistema se enfoca exclusivamente en la fase de planificación y estructuración previa, sin incluir funcionalidades de formato de diálogos, acotaciones escénicas o generación automática de páginas de guión según estándares de la industria. Tampoco incluye herramientas de colaboración en tiempo real entre múltiples usuarios ni gestión de producción o postproducción.

Los beneficios que se alcanzan con DreamInk incluyen la organización sistemática de ideas narrativas mediante una interfaz visual tipo Kanban, la posibilidad de reordenar elementos estructurales mediante arrastrar y soltar, y la generación automática de documentos de tratamiento completos. El sistema facilita el desarrollo profundo de personajes a través de formularios estructurados que cubren aspectos psicológicos y observables, permitiendo exportar fichas individuales o colectivas. La exportación a formato Fountain garantiza compatibilidad con software profesional de guionismo utilizado en la industria audiovisual.

Este documento mantiene consistencia con la especificación de arquitectura del sistema documentada en el diagrama de entidad-relación (ERD.md) y los casos de uso (USE_CASE_DIAGRAMS.md). Estos documentos de nivel superior definen la estructura de datos y los flujos de interacción que sustentan los requisitos aquí especificados. Adicionalmente, se mantiene coherencia con las guías de estilo de desarrollo (STYLE_GUIDE.md) que norman la implementación técnica del sistema.
