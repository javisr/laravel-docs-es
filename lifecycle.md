# Ciclo de Vida de Solicitudes

- [Introducción](#introduction)
- [Resumen del Ciclo de Vida](#lifecycle-overview)
  - [Primeros Pasos](#first-steps)
  - [Kernels HTTP / Consola](#http-console-kernels)
  - [Proveedores de Servicios](#service-providers)
  - [Enrutamiento](#routing)
  - [Finalizando](#finishing-up)
- [Enfoque en los Proveedores de Servicios](#focus-on-service-providers)

<a name="introduction"></a>
## Introducción

Al utilizar cualquier herramienta en el "mundo real", te sientes más seguro si entiendes cómo funciona esa herramienta. El desarrollo de aplicaciones no es diferente. Cuando entiendes cómo funcionan tus herramientas de desarrollo, te sientes más cómodo y confiado usándolas.
El objetivo de este documento es darte una buena visión general de alto nivel sobre cómo funciona el framework Laravel. Al conocer mejor el framework en general, todo se siente menos "mágico" y tendrás más confianza al construir tus aplicaciones. Si no entiendes todos los términos de inmediato, ¡no te desanimes! Solo intenta tener una comprensión básica de lo que está sucediendo, y tu conocimiento crecerá a medida que explores otras secciones de la documentación.

<a name="lifecycle-overview"></a>
## Resumen del Ciclo de Vida


<a name="first-steps"></a>
### Primeros pasos

El punto de entrada para todas las solicitudes a una aplicación Laravel es el archivo `public/index.php`. Todas las solicitudes son dirigidas a este archivo por la configuración de tu servidor web (Apache / Nginx). El archivo `index.php` no contiene mucho código. Más bien, es un punto de partida para cargar el resto del framework.
El archivo `index.php` carga la definición del autoloader generado por Composer y luego recupera una instancia de la aplicación Laravel desde `bootstrap/app.php`. La primera acción que realiza Laravel es crear una instancia de la aplicación / [contenedor de servicios](/docs/%7B%7Bversion%7D%7D/container).

<a name="http-console-kernels"></a>
### Núcleos HTTP / Console

A continuación, la solicitud entrante se envía ya sea al núcleo HTTP o al núcleo de la consola, utilizando los métodos `handleRequest` o `handleCommand` de la instancia de la aplicación, dependiendo del tipo de solicitud que ingresa a la aplicación. Estos dos núcleos sirven como el lugar central a través del cual fluye todas las solicitudes. Por ahora, centrémonos en el núcleo HTTP, que es una instancia de `Illuminate\Foundation\Http\Kernel`.
El núcleo HTTP define un array de `bootstrappers` que se ejecutarán antes de que se ejecute la solicitud. Estos bootstrappers configuran el manejo de errores, configuran el registro, [detectan el entorno de la aplicación](/docs/%7B%7Bversion%7D%7D/configuration#environment-configuration) y realizan otras tareas que deben llevarse a cabo antes de que la solicitud sea realmente gestionada. Típicamente, estas clases manejan la configuración interna de Laravel de la que no necesitas preocuparte.
El kernel HTTP también es responsable de pasar la solicitud a través del stack de middleware de la aplicación. Estos middleware manejan la lectura y escritura de la [sesión HTTP](/docs/%7B%7Bversion%7D%7D/session), determinan si la aplicación está en modo de mantenimiento, [verifican el token CSRF](/docs/%7B%7Bversion%7D%7D/csrf) y más. Hablaremos más sobre esto pronto.
La firma del método del `handle` del núcleo HTTP es bastante simple: recibe una `Request` y devuelve una `Response`. Piensa en el núcleo como una gran caja negra que representa toda tu aplicación. Aliméntalo con solicitudes HTTP y devolverá respuestas HTTP.

<a name="service-providers"></a>
### Proveedores de Servicio

Una de las acciones de inicialización del núcleo más importantes es cargar los [proveedores de servicios](/docs/%7B%7Bversion%7D%7D/providers) para tu aplicación. Los proveedores de servicios son responsables de inicializar todos los varios componentes del framework, como la base de datos, la cola, la validación y los componentes de enrutamiento.
Laravel iterará a través de esta lista de proveedores e instanciará cada uno de ellos. Después de instanciar los proveedores, se llamará al método `register` en todos los proveedores. Luego, una vez que se hayan registrado todos los proveedores, se llamará al método `boot` en cada proveedor. Esto es para que los proveedores de servicios puedan depender de que cada vinculación del contenedor esté registrada y disponible para cuando se ejecute su método `boot`.
Esencialmente, cada función importante ofrecida por Laravel es inicializada y configurada por un proveedor de servicios. Dado que inicializan y configuran tantas características ofrecidas por el framework, los proveedores de servicios son el aspecto más importante de todo el proceso de inicialización de Laravel.
Mientras que el framework utiliza internamente docenas de proveedores de servicios, también tienes la opción de crear los tuyos propios. Puedes encontrar una lista de los proveedores de servicios definidos por el usuario o de terceros que está utilizando tu aplicación en el archivo `bootstrap/providers.php`.

<a name="routing"></a>
### Enrutamiento

Una vez que la aplicación ha sido inicializada y todos los proveedores de servicios han sido registrados, la `Request` será entregada al enrutador para su despacho. El enrutador despachará la solicitud a una ruta o controlador, así como ejecutará cualquier middleware específico de la ruta.
Middleware proporciona un mecanismo conveniente para filtrar o examinar las solicitudes HTTP que ingresan a su aplicación. Por ejemplo, Laravel incluye un middleware que verifica si el usuario de su aplicación está autenticado. Si el usuario no está autenticado, el middleware redirigirá al usuario a la pantalla de inicio de sesión. Sin embargo, si el usuario está autenticado, el middleware permitirá que la solicitud continúe dentro de la aplicación. Algunos middleware se asignan a todas las rutas dentro de la aplicación, como `PreventRequestsDuringMaintenance`, mientras que otros se asignan solo a rutas específicas o grupos de rutas. Puede aprender más sobre middleware leyendo la [documentación completa de middleware](/docs/%7B%7Bversion%7D%7D/middleware).
Si la solicitud pasa a través de todos los middleware asignados a la ruta coincidente, se ejecutará el método de la ruta o del controlador y la respuesta devuelta por el método de la ruta o del controlador será enviada de vuelta a través de la cadena de middleware de la ruta.

<a name="finishing-up"></a>
### Finalizando

Una vez que la ruta o el método del controlador devuelve una respuesta, la respuesta viajará de regreso a través del middleware de la ruta, dando a la aplicación la oportunidad de modificar o examinar la respuesta saliente.
Finalmente, una vez que la respuesta regresa a través del middleware, el método `handle` del kernel HTTP devuelve el objeto de respuesta al `handleRequest` de la instancia de la aplicación, y este método llama al método `send` en la respuesta devuelta. El método `send` envía el contenido de la respuesta al navegador web del usuario. ¡Ahora hemos completado nuestro recorrido a través de todo el ciclo de vida de la solicitud de Laravel!

<a name="focus-on-service-providers"></a>
## Enfoque en Proveedores de Servicios

Los proveedores de servicios son, de hecho, la clave para iniciar una aplicación Laravel. Se crea la instancia de la aplicación, se registran los proveedores de servicios y se entrega la solicitud a la aplicación inicializada. ¡Es realmente así de simple!
Tener una comprensión sólida de cómo se construye y se inicia una aplicación Laravel a través de los proveedores de servicios es muy valioso. Los proveedores de servicios definidos por el usuario de tu aplicación se almacenan en el directorio `app/Providers`.
Por defecto, el `AppServiceProvider` está bastante vacío. Este proveedor es un buen lugar para agregar el inicio y los enlaces del contenedor de servicios de tu aplicación. Para aplicaciones grandes, es posible que desees crear varios proveedores de servicios, cada uno con un inicio más específico para los servicios utilizados por tu aplicación.