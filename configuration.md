# Configuración

- [Introducción](#introduction)
- [Configuración del entorno](#environment-configuration)
  - [Tipos de variables de entorno](#environment-variable-types)
  - [Recuperación de la configuración de entorno](#retrieving-environment-configuration)
  - [Determinación del entorno actual](#determining-the-current-environment)
  - [Cifrado de archivos de entorno](#encrypting-environment-files)
- [Acceso a los valores de configuración](#accessing-configuration-values)
- [Almacenamiento en caché de la configuración](#configuration-caching)
- [Modo depuración](#debug-mode)
- [Modo Mantenimiento](#maintenance-mode)

<a name="introduction"></a>
## Introducción

Todos los archivos de configuración para el framework Laravel se almacenan en el directorio `config`. Cada opción está documentada, así que siéntete libre de revisar los archivos y familiarizarte con las opciones disponibles.

Estos archivos de configuración te permiten configurar cosas como la información de conexión a la base de datos, la información del servidor de correo, así como otros valores de configuración básicos como la zona horaria de la aplicación y la clave de cifrado.

<a name="application-overview"></a>
#### Visión general de la aplicación

¿Tiene prisa? Puedes obtener una rápida visión general de la configuración, controladores y entorno de tu aplicación a través del comando `about` Artisan:

```shell
php artisan about
```

Si sólo está interesado en una sección en particular de la vista general de la aplicación, puede filtrar esa sección usando la opción `--only`:

```shell
php artisan about --only=environment
```

<a name="environment-configuration"></a>
## Configuración del entorno

A menudo es útil tener diferentes valores de configuración basados en el entorno donde se ejecuta la aplicación. Por ejemplo, es posible que desee utilizar un controlador de cache diferente a nivel local que lo hace en su servidor de producción.

Para hacer esto más fácil, Laravel utiliza la librería PHP [DotEnv](https://github.com/vlucas/phpdotenv). En una nueva instalación de Laravel, el directorio raíz de su aplicación contendrá un archivo `.env.example` que define muchas variables de entorno comunes. Durante el proceso de instalación de Laravel, este archivo se copiará automáticamente a `.env`.

El archivo `.env` por defecto de Laravel contiene algunos valores de configuración comunes que pueden diferir en función de si la aplicación se ejecuta localmente o en un servidor web de producción. Estos valores se recuperan de varios archivos de configuración de Laravel dentro del directorio `config` utilizando la función `env` de Laravel.

Si usted está desarrollando con un equipo, es posible que desee seguir incluyendo un archivo `.env.example` con su aplicación. Al poner valores de marcador de posición en el archivo de configuración de ejemplo, otros desarrolladores de tu equipo pueden ver claramente qué variables de entorno son necesarias para ejecutar tu aplicación.

> **Nota**  
> Cualquier variable en su archivo `.env` puede ser sobreescrita por variables de entorno externas, tales como variables de entorno a nivel de servidor o a nivel de sistema.

<a name="environment-file-security"></a>
#### Seguridad del archivo de entorno

Su archivo `.env` no debe ser enviado al control de código fuente de su aplicación, ya que cada desarrollador / servidor que utilice su aplicación podría requerir una configuración de entorno diferente. Además, esto supondría un riesgo de seguridad en el caso de que un intruso accediera a su repositorio de control de código fuente, ya que cualquier credencial sensible quedaría expuesta.

Sin embargo, es posible cifrar tu archivo de entorno utilizando el [cifrado de entorno](#encrypting-environment-files) incorporado de Laravel. Los archivos de entorno cifrados se pueden colocar en el control de código fuente de forma segura.

<a name="additional-environment-files"></a>
#### Archivos de entorno adicionales

Antes de cargar las variables de entorno de tu aplicación, Laravel determina si se ha proporcionado externamente una variable de entorno `APP_ENV` o si se ha especificado el argumento `--env` CLI. Si es así, Laravel intentará cargar un archivo `.env.[APP_ENV]` si existe. Si no existe, se cargará el archivo `.env` por defecto.

<a name="environment-variable-types"></a>
### Tipos de variables de entorno

Todas las variables en sus archivos `.env` son típicamente analizadas como cadenas, por lo que se han creado algunos valores reservados para permitirle devolver un rango más amplio de tipos desde la función `env()`:

| `.env` Value | `env()` Value |
|--------------|---------------|
| true         | (bool) true   |
| (true)       | (bool) true   |
| false        | (bool) false  |
| (false)      | (bool) false  |
| empty        | (string) ''   |
| (empty)      | (string) ''   |
| null         | (null) null   |
| (null)       | (null) null   |

Si necesita definir una variable de entorno con un valor que contenga espacios, puede hacerlo encerrando el valor entre comillas dobles:

```ini
APP_NAME="My Application"
```

<a name="retrieving-environment-configuration"></a>
### Recuperación de la configuración de entorno

Todas las variables listadas en el archivo `.env` serán cargadas en el superglobal PHP `$_ENV` cuando su aplicación reciba una petición. Sin embargo, puede usar la función `env` para recuperar valores de estas variables en sus archivos de configuración. De hecho, si revisas los archivos de configuración de Laravel, notarás que muchas de las opciones ya utilizan esta función:

    'debug' => env('APP_DEBUG', false),

El segundo valor pasado a la función `env` es el "valor por defecto". Este valor será devuelto si no existe ninguna variable de entorno para la clave dada.

<a name="determining-the-current-environment"></a>
### Determinación del entorno actual

El entorno actual de la aplicación se determina a través de la variable `APP_ENV` de su archivo `.env`. Puede acceder a este valor mediante el método `environment` de la [facade](/docs/{{version}}/facades) `App`:

    use Illuminate\Support\Facades\App;

    $environment = App::environment();

También puedes pasar argumentos al método `env` para determinar si el entorno coincide con un valor dado. El método devolverá `true` si el entorno coincide con alguno de los valores dados:

    if (App::environment('local')) {
        // The environment is local
    }

    if (App::environment(['local', 'staging'])) {
        // The environment is either local OR staging...
    }

> **Nota**  
> La detección del entorno actual de la aplicación se puede sobreescribir definiendo una variable de entorno `APP_ENV` a nivel de servidor.

<a name="encrypting-environment-files"></a>
### Cifrado de archivos de entorno

Los ficheros de entorno sin cifrar nunca deben almacenarse en el control de código fuente. Sin embargo, Laravel te permite encriptar tus ficheros de entorno para que puedan ser añadidos de forma segura al control de código fuente con el resto de tu aplicación.

<a name="encryption"></a>
#### Cifrado

Para cifrar un fichero de entorno, puedes utilizar el comando `env:encrypt`:

```shell
php artisan env:encrypt
```

Ejecutar el comando `env:encrypt` encriptará su archivo `.env` y colocará el contenido encriptado en un archivo `.env.encrypted`. La clave de descifrado se presenta en la salida del comando y debe guardarse en un gestor de contraseñas seguro. Si desea proporcionar su propia clave de cifrado puede utilizar la opción `--key` al invocar el comando:

```shell
php artisan env:encrypt --key=3UVsEgGVK36XN82KKeyLFMhvosbZN1aF
```

> **Nota**  
> La longitud de la clave proporcionada debe coincidir con la longitud de clave requerida por el cifrado utilizado. Por defecto, Laravel utilizará el cifrado `AES-256-CBC` que requiere una clave de 32 caracteres. Eres libre de utilizar cualquier cifrado soportado por el [cifrador](/docs/{{version}}/encryption) de Laravel pasando la opción `--cipher` al invocar el comando.

Si su aplicación tiene varios archivos de entorno, como `.env` y `.env.staging`, puede especificar el archivo de entorno que debe cifrarse proporcionando el nombre del entorno mediante la opción `--env`:

```shell
php artisan env:encrypt --env=staging
```

<a name="decryption"></a>
#### Descifrado

Para descifrar un archivo de entorno, puede utilizar el comando `env:decrypt`. Este comando requiere una clave de descifrado, que Laravel recuperará de la variable de entorno `LARAVEL_ENV_ENCRYPTION_KEY`:

```shell
php artisan env:decrypt
```

O bien, la clave puede ser proporcionada directamente al comando a través de la opción `--key`:

```shell
php artisan env:decrypt --key=3UVsEgGVK36XN82KKeyLFMhvosbZN1aF
```

Cuando se invoca el comando `env:decrypt`, Laravel descifrará el contenido del fichero `.env.encrypted` y colocará el contenido descifrado en el fichero `.env`.

Se puede proporcionar la opción `--cipher` al comando env: `decrypt` para utilizar un cifrado personalizado:

```shell
php artisan env:decrypt --key=qUWuNRdfuImXcKxZ --cipher=AES-128-CBC
```

Si su aplicación tiene varios archivos de entorno, como `.env` y `.env.staging`, puede especificar el archivo de entorno que debe descifrarse proporcionando el nombre del entorno mediante la opción `--env`:

```shell
php artisan env:decrypt --env=staging
```

Para sobrescribir un archivo de entorno existente, puede proporcionar la opción `--force` al comando `env:decrypt`:

```shell
php artisan env:decrypt --force
```

<a name="accessing-configuration-values"></a>
## Acceso a los valores de configuración

Puedes acceder fácilmente a tus valores de configuración usando la función global `config` desde cualquier parte de tu aplicación. Se puede acceder a los valores de configuración utilizando la sintaxis "dot", que incluye el nombre del archivo y la opción a la que se desea acceder. También puede especificarse un valor por defecto, que se devolverá si la opción de configuración no existe:

    $value = config('app.timezone');

    // Retrieve a default value if the configuration value does not exist...
    $value = config('app.timezone', 'Asia/Seoul');

Para establecer valores de configuración en tiempo de ejecución, pase una array a la función `config`:

    config(['app.timezone' => 'America/Chicago']);

<a name="configuration-caching"></a>
## Almacenamiento en caché de la configuración

Para aumentar la velocidad de su aplicación, debe cachear todos sus archivos de configuración en un único archivo utilizando el comando `config:cache` Artisan. Esto combinará todas las opciones de configuración para tu aplicación en un solo archivo que puede ser cargado rápidamente por el framework.

Normalmente debe ejecutar el comando `php artisan config:cache` como parte de su proceso de despliegue de producción. El comando no debe ser ejecutado durante el desarrollo local ya que las opciones de configuración necesitarán ser cambiadas frecuentemente durante el curso del desarrollo de su aplicación.

> **Advertencia**  
> Si ejecutas el comando `config:cache` durante tu proceso de despliegue, debes asegurarte de que sólo estás llamando a la función `env` desde dentro de tus archivos de configuración. Una vez que la configuración ha sido almacenada en caché, el archivo `.env` no será cargado; por lo tanto, la función `env` sólo devolverá variables de entorno externas, a nivel de sistema.

<a name="debug-mode"></a>
## Modo depuración

La opción `debug` en su archivo de configuración `config/app.php` determina cuanta información sobre un error es mostrada al usuario. Por defecto, esta opción está configurada para respetar el valor de la variable de entorno `APP_DEBUG`, que está almacenada en su archivo `.env`.

Para el desarrollo local, debe establecer la variable de entorno `APP_DEBUG` en `true`. **En su entorno de producción, este valor debe ser siempre `false`. Si la variable se establece en `true` en producción, corre el riesgo de exponer valores de configuración sensibles a los usuarios finales de su aplicación.**

<a name="maintenance-mode"></a>
## Modo Mantenimiento

Cuando su aplicación está en modo de mantenimiento, se mostrará una vista personalizada para todas las peticiones que entren en su aplicación. Esto facilita la "desactivación" de su aplicación mientras se actualiza o cuando está realizando tareas de mantenimiento. Se incluye una comprobación del modo de mantenimiento en la pila de middleware predeterminada para su aplicación. Si la aplicación está en modo de mantenimiento, se lanzará una instancia de `SymfonyComponent\HttpKernel\Exception\HttpException` con un código de estado 503.

Para habilitar el modo de mantenimiento, ejecute el comando `down` de Artisan:

```shell
php artisan down
```

Si deseas que la cabecera `Refresh` HTTP sea enviada con todas las respuestas del modo de mantenimiento, puedes proporcionar la opción `refresh` cuando invoques el comando `down`. La cabecera `Refresh` indicará al navegador que actualice automáticamente la página tras el número de segundos especificado:

```shell
php artisan down --refresh=15
```

También puede proporcionar una opción de `retry` al comando `down`, que se establecerá como el valor de la cabecera `Retry-After` HTTP, aunque los navegadores generalmente ignoran esta cabecera:

```shell
php artisan down --retry=60
```

<a name="bypassing-maintenance-mode"></a>
#### Pasar por alto el modo de mantenimiento

Para permitir que el modo de mantenimiento sea evitado utilizando una clave secreta, puede utilizar la opción `secret` para especificar una clave de evasión del modo de mantenimiento:

```shell
php artisan down --secret="1630542a-246b-4b66-afa1-dd72a4c43515"
```

Después de poner la aplicación en modo de mantenimiento, puede navegar a la URL de la aplicación que coincida con este token y Laravel emitirá una cookie de bypass de modo de mantenimiento a su navegador:

```shell
https://example.com/1630542a-246b-4b66-afa1-dd72a4c43515
```

Cuando acceda a esta ruta oculta, será redirigido a la ruta `/` de la aplicación. Una vez que la cookie haya sido emitida a tu navegador, podrás navegar por la aplicación normalmente como si no estuviera en modo mantenimiento.

> **Nota**  
> Su clave secreta de modo de mantenimiento debe consistir normalmente en caracteres alfanuméricos y, opcionalmente, guiones. Evite utilizar caracteres que tengan un significado especial en las URL, como `?`

<a name="pre-rendering-the-maintenance-mode-view"></a>
#### Pre-representación de la vista del modo de mantenimiento

Si usted utiliza el comando `php artisan down` durante el despliegue, sus usuarios pueden aún ocasionalmente encontrar errores si acceden a la aplicación mientras sus dependencias de Composer u otros componentes de infraestructura se están actualizando. Esto ocurre porque una parte significativa del framework Laravel debe arrancar para determinar que tu aplicación está en modo mantenimiento y renderizar la vista de modo mantenimiento usando el motor de plantillas.

Por esta razón, Laravel permite pre-renderizar una vista en modo mantenimiento que será devuelta al principio del ciclo de petición. Esta vista se renderiza antes de que se haya cargado ninguna de las dependencias de tu aplicación. Puedes pre-renderizar una plantilla de tu elección usando la opción `render` del comando `down`:

```shell
php artisan down --render="errors::503"
```

<a name="redirecting-maintenance-mode-requests"></a>
#### Redireccionamiento de peticiones en modo mantenimiento

En modo mantenimiento, Laravel mostrará la vista de modo mantenimiento para todas las URLs de la aplicación a las que el usuario intente acceder. Si lo desea, puede indicar a Laravel que redirija todas las peticiones a una URL específica. Esto se puede lograr utilizando la opción de `redirect`. Por ejemplo, es posible que desee redirigir todas las solicitudes a la `/` URI:

```shell
php artisan down --redirect=/
```

<a name="disabling-maintenance-mode"></a>
#### Desactivación del modo de mantenimiento

Para desactivar el modo de mantenimiento, utilice el comando `up`:

```shell
php artisan up
```

> **Nota**  
> Puede personalizar la plantilla predeterminada del modo de mantenimiento definiendo su propia plantilla en `resources/views/errors/503.blade.php`.

<a name="maintenance-mode-queues"></a>
#### Modo de mantenimiento y colas

Mientras la aplicación esté en modo de mantenimiento, no se gestionarán los [trabajos en cola](/docs/{{version}}/queues). Los trabajos se seguirán gestionando de forma normal una vez que la aplicación salga del modo de mantenimiento.

<a name="alternatives-to-maintenance-mode"></a>
#### Alternativas al modo de mantenimiento

Dado que el modo de mantenimiento requiere que su aplicación tenga varios segundos de tiempo de inactividad, considere alternativas como [Laravel Vapor](https://vapor.laravel.com) y [Envoyer](https://envoyer.io) para lograr un despliegue sin tiempo de inactividad con Laravel.
