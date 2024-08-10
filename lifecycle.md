# Ciclo de Vida de la Solicitud

- [Introducción](#introducción)
- [Descripción General del Ciclo de Vida](#descripción-general-del-ciclo-de-vida)
    - [Primeros Pasos](#primeros-pasos)
    - [Kernels HTTP / Consola](#kernels-http-consola)
    - [Proveedores de Servicios](#proveedores-de-servicios)
    - [Enrutamiento](#enrutamiento)
    - [Finalizando](#finalizando)
- [Enfoque en Proveedores de Servicios](#enfoque-en-proveedores-de-servicios)

<a name="introducción"></a>
## Introducción

Cuando usas cualquier herramienta en el "mundo real", te sientes más seguro si entiendes cómo funciona esa herramienta. El desarrollo de aplicaciones no es diferente. Cuando entiendes cómo funcionan tus herramientas de desarrollo, te sientes más cómodo y confiado usándolas.

El objetivo de este documento es darte una buena visión general de alto nivel de cómo funciona el framework Laravel. Al conocer mejor el framework en general, todo se siente menos "mágico" y tendrás más confianza al construir tus aplicaciones. Si no entiendes todos los términos de inmediato, ¡no te desanimes! Solo intenta tener una comprensión básica de lo que está sucediendo, y tu conocimiento crecerá a medida que explores otras secciones de la documentación.

<a name="descripción-general-del-ciclo-de-vida"></a>
## Descripción General del Ciclo de Vida

<a name="primeros-pasos"></a>
### Primeros Pasos

El punto de entrada para todas las solicitudes a una aplicación Laravel es el archivo `public/index.php`. Todas las solicitudes son dirigidas a este archivo por la configuración de tu servidor web (Apache / Nginx). El archivo `index.php` no contiene mucho código. Más bien, es un punto de partida para cargar el resto del framework.

El archivo `index.php` carga la definición del autoloader generado por Composer y luego recupera una instancia de la aplicación Laravel desde `bootstrap/app.php`. La primera acción realizada por Laravel es crear una instancia de la aplicación / [contenedor de servicios](/docs/{{version}}/container).

<a name="kernels-http-consola"></a>
### Kernels HTTP / Consola

A continuación, la solicitud entrante se envía al kernel HTTP o al kernel de consola, utilizando los métodos `handleRequest` o `handleCommand` de la instancia de la aplicación, dependiendo del tipo de solicitud que ingresa a la aplicación. Estos dos kernels sirven como el lugar central a través del cual fluyen todas las solicitudes. Por ahora, centrémonos en el kernel HTTP, que es una instancia de `Illuminate\Foundation\Http\Kernel`.

El kernel HTTP define un array de `bootstrappers` que se ejecutarán antes de que se ejecute la solicitud. Estos bootstrappers configuran el manejo de errores, configuran el registro, [detectan el entorno de la aplicación](/docs/{{version}}/configuration#environment-configuration), y realizan otras tareas que deben hacerse antes de que la solicitud sea realmente manejada. Típicamente, estas clases manejan la configuración interna de Laravel de la que no necesitas preocuparte.

El kernel HTTP también es responsable de pasar la solicitud a través de la pila de middleware de la aplicación. Estos middleware manejan la lectura y escritura de la [sesión HTTP](/docs/{{version}}/session), determinan si la aplicación está en modo de mantenimiento, [verifican el token CSRF](/docs/{{version}}/csrf), y más. Hablaremos más sobre esto pronto.

La firma del método para el método `handle` del kernel HTTP es bastante simple: recibe un `Request` y devuelve un `Response`. Piensa en el kernel como una gran caja negra que representa toda tu aplicación. Aliméntalo con solicitudes HTTP y devolverá respuestas HTTP.

<a name="proveedores-de-servicios"></a>
### Proveedores de Servicios

Una de las acciones de arranque más importantes del kernel es cargar los [proveedores de servicios](/docs/{{version}}/providers) para tu aplicación. Los proveedores de servicios son responsables de iniciar todos los diversos componentes del framework, como la base de datos, la cola, la validación y los componentes de enrutamiento.

Laravel iterará a través de esta lista de proveedores e instanciará cada uno de ellos. Después de instanciar los proveedores, se llamará al método `register` en todos los proveedores. Luego, una vez que todos los proveedores han sido registrados, se llamará al método `boot` en cada proveedor. Esto es para que los proveedores de servicios puedan depender de que cada enlace del contenedor esté registrado y disponible para cuando se ejecute su método `boot`.

Esencialmente, cada característica principal ofrecida por Laravel es iniciada y configurada por un proveedor de servicios. Dado que inician y configuran tantas características ofrecidas por el framework, los proveedores de servicios son el aspecto más importante de todo el proceso de arranque de Laravel.

Mientras que el framework utiliza internamente docenas de proveedores de servicios, también tienes la opción de crear los tuyos propios. Puedes encontrar una lista de los proveedores de servicios definidos por el usuario o de terceros que tu aplicación está utilizando en el archivo `bootstrap/providers.php`.

<a name="enrutamiento"></a>
### Enrutamiento

Una vez que la aplicación ha sido iniciada y todos los proveedores de servicios han sido registrados, el `Request` será entregado al enrutador para su despacho. El enrutador despachará la solicitud a una ruta o controlador, así como ejecutará cualquier middleware específico de la ruta.

Los middleware proporcionan un mecanismo conveniente para filtrar o examinar las solicitudes HTTP que ingresan a tu aplicación. Por ejemplo, Laravel incluye un middleware que verifica si el usuario de tu aplicación está autenticado. Si el usuario no está autenticado, el middleware redirigirá al usuario a la pantalla de inicio de sesión. Sin embargo, si el usuario está autenticado, el middleware permitirá que la solicitud continúe más adentro de la aplicación. Algunos middleware están asignados a todas las rutas dentro de la aplicación, como `PreventRequestsDuringMaintenance`, mientras que algunos solo están asignados a rutas específicas o grupos de rutas. Puedes aprender más sobre middleware leyendo la completa [documentación de middleware](/docs/{{version}}/middleware).

Si la solicitud pasa a través de todos los middleware asignados a la ruta coincidente, se ejecutará el método de la ruta o del controlador y la respuesta devuelta por el método de la ruta o del controlador será enviada de vuelta a través de la cadena de middleware de la ruta.

<a name="finalizando"></a>
### Finalizando

Una vez que el método de la ruta o del controlador devuelve una respuesta, la respuesta viajará de regreso a través del middleware de la ruta, dando a la aplicación la oportunidad de modificar o examinar la respuesta saliente.

Finalmente, una vez que la respuesta viaja de regreso a través del middleware, el método `handle` del kernel HTTP devuelve el objeto de respuesta al `handleRequest` de la instancia de la aplicación, y este método llama al método `send` en la respuesta devuelta. El método `send` envía el contenido de la respuesta al navegador web del usuario. ¡Ahora hemos completado nuestro viaje a través de todo el ciclo de vida de la solicitud de Laravel!

<a name="enfoque-en-proveedores-de-servicios"></a>
## Enfoque en Proveedores de Servicios

Los proveedores de servicios son realmente la clave para iniciar una aplicación Laravel. La instancia de la aplicación se crea, los proveedores de servicios se registran y la solicitud se entrega a la aplicación iniciada. ¡Es así de simple!

Tener una comprensión firme de cómo se construye y se inicia una aplicación Laravel a través de los proveedores de servicios es muy valioso. Los proveedores de servicios definidos por el usuario de tu aplicación se almacenan en el directorio `app/Providers`.

Por defecto, el `AppServiceProvider` está bastante vacío. Este proveedor es un gran lugar para agregar el arranque y los enlaces del contenedor de servicios de tu aplicación. Para aplicaciones grandes, es posible que desees crear varios proveedores de servicios, cada uno con un arranque más granular para servicios específicos utilizados por tu aplicación.
