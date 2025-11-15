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

### Definiciones, acrónimos y abreviaturas

**Acto:** División narrativa de alto nivel que estructura la obra audiovisual en segmentos principales. Tradicionalmente las obras cinematográficas se organizan en tres actos, aunque pueden emplearse otras configuraciones según la propuesta narrativa.

**Secuencia:** Agrupación de escenas relacionadas temática o temporalmente que conforman una unidad narrativa dentro de un acto. Las secuencias permiten organizar el desarrollo dramático en bloques coherentes que facilitan la planificación de la producción.

**Escena:** Unidad narrativa mínima que ocurre en un tiempo y espacio continuos. Cada escena se caracteriza por su locación, momento del día y descripción de la acción dramática que se desarrolla en ella.

**Tratamiento:** Documento de preproducción que describe detalladamente la historia, personajes, locaciones y estructura dramática de una obra audiovisual antes de escribir el guión literario. El tratamiento sirve como base para la planificación narrativa y productiva del proyecto.

**Locación:** Espacio físico donde se desarrolla una escena. Las locaciones se clasifican en interiores o exteriores y pueden aparecer en múltiples escenas a lo largo de la obra.

**Fountain:** Lenguaje de marcado de texto plano diseñado específicamente para escribir guiones cinematográficos. Permite crear guiones con formato profesional utilizando sintaxis simple y es compatible con múltiples aplicaciones de guionismo de la industria.

**Logline:** Resumen extremadamente conciso de la premisa de una obra audiovisual, típicamente expresado en una o dos oraciones. El logline captura la esencia del conflicto central y los protagonistas principales.

**Storyline:** Línea argumental que describe la progresión narrativa de la obra de manera más extensa que el logline pero más concisa que la sinopsis. Presenta los acontecimientos principales y el arco dramático general.

**ERS:** Especificación de Requisitos de Software. Documento que detalla de manera formal y completa los requisitos funcionales y no funcionales de un sistema de software.

**PDF:** Formato de Documento Portátil. Formato de archivo desarrollado por Adobe que preserva la apariencia visual de documentos independientemente del software o hardware utilizado para visualizarlos.

**API:** Interfaz de Programación de Aplicaciones. Conjunto de definiciones y protocolos que permite la comunicación entre diferentes componentes de software.

**CRUD:** Acrónimo de Crear, Leer, Actualizar y Eliminar. Representa las cuatro operaciones básicas de gestión de datos en sistemas de información.

### Referencias

**ERD.md** - Diagrama de Entidad-Relación del sistema DreamInk. Ubicación: /docs/diagram_er/ERD.md. Este documento especifica la arquitectura de datos, entidades del dominio, atributos y relaciones entre las entidades que conforman el modelo de información del sistema.

**USE_CASE_DIAGRAMS.md** - Diagramas de Casos de Uso del sistema DreamInk. Ubicación: /docs/diagram_use_cases/USE_CASE_DIAGRAMS.md. Describe los actores del sistema y los casos de uso disponibles para cada módulo funcional, incluyendo relaciones de inclusión y extensión.

**STYLE_GUIDE.md** - Guía de Estilos de Desarrollo. Ubicación: /docs/STYLE_GUIDE.md. Establece las convenciones de código, patrones de diseño y mejores prácticas que deben seguirse durante la implementación del sistema.

**README.md** - Documento principal del proyecto. Ubicación: /README.md. Proporciona información general sobre el proyecto, instrucciones de instalación, configuración del entorno de desarrollo y guías de contribución.

**IEEE Std 830-1998** - IEEE Recommended Practice for Software Requirements Specifications. Estándar que define la estructura y contenido recomendado para documentos de especificación de requisitos de software.

### Visión general del documento

Este documento se organiza siguiendo la estructura recomendada por el estándar IEEE 830 para especificaciones de requisitos de software. La sección de Introducción que se presenta aquí establece el contexto general del sistema, define su alcance y proporciona la terminología necesaria para comprender el resto del documento.

La siguiente sección principal será la Descripción General del sistema, que caracteriza los factores que afectan al producto y sus requisitos. Esta sección incluye la perspectiva del producto dentro del contexto de sistemas relacionados, las funciones principales del producto, las características de los usuarios, las restricciones generales y los supuestos y dependencias que condicionan el desarrollo.

Posteriormente se presenta la sección de Requisitos Específicos, que constituye el núcleo técnico del documento. Esta sección detalla exhaustivamente los requisitos funcionales organizados por módulos del sistema, los requisitos de interfaces externas que especifican las interacciones con usuarios y otros sistemas, los requisitos de rendimiento que definen parámetros de desempeño, y las restricciones de diseño que limitan las opciones de implementación. También se incluyen los atributos del sistema relacionados con seguridad, mantenibilidad y portabilidad.

Cada requisito especificado en el documento es identificado de manera única, permitiendo su trazabilidad durante todo el ciclo de desarrollo. Los requisitos se redactan de forma verificable, empleando criterios objetivos que permiten validar su cumplimiento mediante pruebas de aceptación. Esta organización facilita tanto la implementación técnica como la posterior verificación de que el sistema construido satisface las especificaciones establecidas.

## Descripción General

### Perspectiva del producto

DreamInk es un producto de software completamente independiente que no forma parte de un sistema mayor. El sistema opera de manera autónoma como aplicación web, sin requerir integración obligatoria con otras plataformas o servicios externos para cumplir sus funciones principales. Los usuarios acceden al sistema mediante navegadores web estándar, interactuando directamente con la aplicación sin necesidad de instalar software adicional en sus dispositivos.

El producto se relaciona con el ecosistema de herramientas de guionismo profesional mediante mecanismos de exportación de datos. La funcionalidad de exportación a formato Fountain permite que el trabajo desarrollado en DreamInk pueda ser posteriormente importado y continuado en editores especializados de guiones literarios como Final Draft, Fade In, Writer Duet o Highland. Esta interoperabilidad posiciona a DreamInk como herramienta complementaria en la etapa inicial del flujo de trabajo de escritura audiovisual.

La arquitectura del sistema se compone de tres capas principales que operan de forma integrada. La capa de presentación ejecuta en el navegador del usuario y proporciona la interfaz gráfica interactiva mediante tecnologías web estándar. La capa de lógica de negocio reside en el servidor de aplicaciones y procesa las solicitudes, valida datos y ejecuta las reglas de negocio del dominio. La capa de persistencia almacena toda la información en una base de datos relacional PostgreSQL que garantiza la integridad y consistencia de los datos.

El sistema no mantiene interfaces directas con APIs externas ni sistemas de terceros para su funcionamiento operativo. Las exportaciones de documentos en formato PDF y Fountain se generan internamente mediante librerías especializadas integradas en el servidor de aplicaciones. Esta arquitectura autónoma simplifica el despliegue y reduce dependencias externas, aunque limita las posibilidades de sincronización o colaboración con otras plataformas.

DreamInk se posiciona como primer escalón en el proceso de desarrollo de guiones audiovisuales, ocupando específicamente la fase de preproducción y planificación estructural. El flujo típico de trabajo contempla que los usuarios desarrollen la estructura dramática completa en DreamInk y posteriormente exporten el resultado para continuar la escritura del guión literario en herramientas especializadas. Esta separación de responsabilidades permite optimizar cada herramienta para su propósito específico sin sobrecargar ningún sistema individual.

### Funciones del producto

El sistema permite gestionar proyectos audiovisuales con atributos narrativos como género, logline, sinopsis y temas. Proporciona una interfaz visual tipo Kanban para organizar la estructura dramática jerárquica mediante actos, secuencias y escenas con capacidades de reordenamiento mediante arrastrar y soltar. Incluye formularios estructurados para desarrollar perfiles completos de personajes con rasgos internos y externos.

La aplicación administra locaciones clasificadas por tipo y permite vincularlas con escenas específicas. Ofrece un banco de ideas con funcionalidades de búsqueda y categorización mediante etiquetas. Genera documentos de tratamiento, fichas de personajes, reportes de locaciones y listados de ideas en formato PDF.

Exporta la estructura dramática completa al formato Fountain para compatibilidad con editores profesionales de guiones. Implementa un sistema de autenticación que garantiza la privacidad de los datos, permitiendo que cada usuario acceda únicamente a sus propios proyectos.

### Características de los usuarios

Los usuarios principales son guionistas profesionales y estudiantes de guionismo que desarrollan proyectos para cine, televisión o medios digitales. Se espera que posean conocimientos sólidos sobre narrativa audiovisual, estructura dramática y terminología del dominio cinematográfico. No requieren experiencia técnica avanzada en informática, aunque deben manejar navegadores web y conceptos básicos de aplicaciones en línea.

Los usuarios trabajan de forma individual en sus proyectos sin necesidad de colaboración simultánea con otros guionistas. Acceden al sistema desde computadoras de escritorio, portátiles o dispositivos móviles según sus necesidades de movilidad. Se asume familiaridad con interfaces visuales de arrastrar y soltar similares a las utilizadas en herramientas de gestión de proyectos contemporáneas.

### Restricciones

El sistema debe ejecutarse en navegadores web modernos compatibles con estándares HTML5, CSS3 y JavaScript ES6. La base de datos PostgreSQL versión 16 o superior es obligatoria para garantizar compatibilidad con las extensiones y características empleadas. El servidor de aplicaciones requiere Ruby versión 3.4 o superior para aprovechar las funcionalidades del framework Rails 8.

La interfaz de usuario debe presentarse exclusivamente en idioma español para el público objetivo paraguayo y latinoamericano. Los documentos exportados deben cumplir con las especificaciones del formato Fountain versión 1.1 para asegurar interoperabilidad. El sistema debe operar bajo licencia MIT manteniendo su carácter de software libre y código abierto.

### Factores que se asumen y futuros requisitos

Se asume que los usuarios disponen de conexión estable a internet para acceder a la aplicación web. Se presupone que los navegadores de los usuarios tienen JavaScript habilitado y aceptan cookies para el funcionamiento de las sesiones. Se considera que los usuarios realizarán respaldos periódicos de sus proyectos mediante las funcionalidades de exportación disponibles.

Entre los futuros requisitos se contempla la posibilidad de colaboración en tiempo real entre múltiples guionistas en un mismo proyecto. Se prevé la incorporación de funcionalidades de importación desde formato Fountain para permitir el flujo bidireccional de datos. Adicionalmente se proyecta desarrollar capacidades de versionado que permitan rastrear la evolución histórica de la estructura dramática a lo largo del proceso creativo.

## Requisitos Específicos

### Requisitos funcionales

**Autenticación y gestión de usuarios:** El sistema debe permitir el registro de nuevos usuarios mediante correo electrónico y contraseña. Debe proporcionar funcionalidades de inicio y cierre de sesión, así como recuperación de contraseña. Cada usuario debe acceder únicamente a sus propios proyectos garantizando la privacidad de la información.

**Gestión de proyectos:** El sistema debe permitir crear, editar, visualizar y eliminar proyectos audiovisuales. Cada proyecto debe almacenar título, género, logline, idea, temas, tono, mundo narrativo, storyline, sinopsis corta y larga, y resumen de personajes. Debe generar documentos de tratamiento completo en formato PDF.

**Estructura dramática:** El sistema debe gestionar actos, secuencias y escenas en jerarquía de tres niveles. Debe permitir crear, editar, eliminar y reordenar elementos mediante interfaz Kanban con arrastrar y soltar. Las escenas deben incluir título, descripción, color, momento del día y vinculación con locaciones.

**Gestión de personajes:** El sistema debe permitir crear perfiles de personajes con rasgos internos y externos. Los rasgos internos incluyen aspectos psicológicos, valores, motivaciones y creencias. Los rasgos externos incluyen apariencia, historial médico, educación, profesión y situación económica. Debe generar fichas individuales y colectivas en PDF.

**Gestión de locaciones:** El sistema debe administrar locaciones clasificadas como interiores o exteriores. Debe permitir vincular múltiples locaciones a cada escena y filtrar escenas por locación. Debe generar reportes individuales y colectivos de locaciones en formato PDF.

**Banco de ideas:** El sistema debe proporcionar almacenamiento de ideas con título, descripción y etiquetas. Debe permitir búsqueda por palabra clave y filtrado por etiquetas. Debe generar reportes individuales y colectivos en PDF.

**Exportaciones:** El sistema debe exportar la estructura dramática completa al formato Fountain incluyendo actos, secuencias, escenas, personajes y locaciones. Los archivos generados deben ser compatibles con editores profesionales de guiones.

### Requisitos de interfaces externas

**Interfaz de usuario:** La interfaz debe ser responsive adaptándose a dispositivos de escritorio, tabletas y móviles. Debe presentar navegación intuitiva mediante menús desplegables y botones de acción claramente identificados. Los formularios deben incluir validaciones en tiempo real con mensajes de error descriptivos.

**Interfaz de hardware:** El sistema requiere dispositivos con capacidad de ejecutar navegadores web modernos y conexión a internet. Para funcionalidad completa de arrastrar y soltar se recomienda dispositivos con puntero de precisión, aunque debe ser operable mediante interfaces táctiles.

**Interfaz de software:** El sistema debe ser compatible con navegadores Chrome, Firefox, Safari y Edge en sus versiones actuales y las dos anteriores. Debe interactuar con el sistema de archivos del navegador para descargas de documentos PDF y Fountain.

**Interfaz de comunicación:** El sistema utiliza protocolo HTTPS para todas las comunicaciones entre cliente y servidor. Las peticiones emplean arquitectura REST mediante métodos HTTP estándar. Las actualizaciones en tiempo real utilizan tecnología Turbo Streams sobre conexiones persistentes.

### Requisitos de rendimiento

El sistema debe cargar la página principal en menos de dos segundos bajo condiciones normales de red. Las operaciones de creación, edición y eliminación de elementos deben completarse en menos de un segundo. La interfaz de arrastrar y soltar debe responder de forma fluida sin latencia perceptible durante el reordenamiento.

La generación de documentos PDF debe completarse en menos de cinco segundos para proyectos de tamaño moderado con hasta cincuenta escenas. La exportación a formato Fountain debe ejecutarse en menos de tres segundos. El sistema debe soportar al menos cincuenta usuarios concurrentes sin degradación significativa del rendimiento.

### Restricciones de diseño

El sistema debe implementarse utilizando el framework Ruby on Rails versión 8.1 o superior siguiendo el patrón arquitectónico MVC. La capa de presentación debe emplear Hotwire con Turbo y Stimulus evitando frameworks JavaScript pesados. Los estilos deben gestionarse mediante Tailwind CSS manteniendo consistencia visual en toda la aplicación.

La base de datos debe ser PostgreSQL versión 16 empleando migraciones de ActiveRecord para control de versiones del esquema. El código debe seguir las convenciones de estilo Ruby idiomáticas verificadas mediante RuboCop. La autenticación debe implementarse sin dependencias externas utilizando has_secure_password de Rails.

### Atributos del sistema

**Seguridad:** El sistema debe encriptar contraseñas mediante bcrypt con factor de trabajo apropiado. Debe implementar protección contra ataques CSRF y XSS. Las sesiones deben expirar después de período de inactividad razonable. Los datos de cada usuario deben estar aislados mediante scopes a nivel de base de datos.

**Mantenibilidad:** El código debe mantener cobertura de pruebas automatizadas para facilitar refactorizaciones futuras. La arquitectura debe separar responsabilidades en modelos, controladores, vistas y servicios. La documentación técnica debe incluir diagramas de entidad-relación y casos de uso actualizados.

**Portabilidad:** El sistema debe ser desplegable mediante contenedores Docker en cualquier plataforma que soporte dicha tecnología. La configuración debe externalizarse mediante variables de entorno. El código debe evitar dependencias específicas de sistemas operativos particulares.
