# Instalación

- [Conoce Laravel](#meet-laravel)
    - [¿Por qué Laravel?](#why-laravel)
- [Creando un Proyecto Laravel](#creating-a-laravel-project)
- [Configuración Inicial](#initial-configuration)
    - [Configuración Basada en el Entorno](#environment-based-configuration)
    - [Bases de Datos y Migraciones](#databases-and-migrations)
    - [Configuración de Directorios](#directory-configuration)
- [Instalación Local Usando Herd](#local-installation-using-herd)
    - [Herd en macOS](#herd-on-macos)
    - [Herd en Windows](#herd-on-windows)
- [Instalación de Docker Usando Sail](#docker-installation-using-sail)
    - [Sail en macOS](#sail-on-macos)
    - [Sail en Windows](#sail-on-windows)
    - [Sail en Linux](#sail-on-linux)
    - [Eligiendo tus Servicios de Sail](#choosing-your-sail-services)
- [Soporte para IDE](#ide-support)
- [Próximos Pasos](#next-steps)
    - [Laravel el Framework Full Stack](#laravel-the-fullstack-framework)
    - [Laravel el Backend API](#laravel-the-api-backend)

<a name="meet-laravel"></a>
## Conoce Laravel

Laravel es un framework de aplicación web con una sintaxis expresiva y elegante. Un framework web proporciona una estructura y un punto de partida para crear tu aplicación, permitiéndote concentrarte en crear algo asombroso mientras nosotros nos ocupamos de los detalles.

Laravel se esfuerza por proporcionar una experiencia de desarrollador increíble mientras ofrece características poderosas como inyección de dependencias exhaustiva, una capa de abstracción de base de datos expresiva, colas y trabajos programados, pruebas unitarias e integración, y más.

Ya seas nuevo en los frameworks web de PHP o tengas años de experiencia, Laravel es un framework que puede crecer contigo. Te ayudaremos a dar tus primeros pasos como desarrollador web o te daremos un impulso mientras llevas tu experiencia al siguiente nivel. No podemos esperar a ver lo que construyes.

> [!NOTE]  
> ¿Nuevo en Laravel? Consulta el [Laravel Bootcamp](https://bootcamp.laravel.com) para un recorrido práctico por el framework mientras te guiamos en la construcción de tu primera aplicación Laravel.

<a name="why-laravel"></a>
### ¿Por qué Laravel?

Hay una variedad de herramientas y frameworks disponibles para ti al construir una aplicación web. Sin embargo, creemos que Laravel es la mejor opción para construir aplicaciones web modernas y full-stack.

#### Un Framework Progresivo

Nos gusta llamar a Laravel un framework "progresivo". Con esto, queremos decir que Laravel crece contigo. Si estás dando tus primeros pasos en el desarrollo web, la vasta biblioteca de documentación, guías y [tutoriales en video](https://laracasts.com) de Laravel te ayudarán a aprender lo básico sin sentirte abrumado.

Si eres un desarrollador senior, Laravel te proporciona herramientas robustas para [inyección de dependencias](/docs/{{version}}/container), [pruebas unitarias](/docs/{{version}}/testing), [colas](/docs/{{version}}/queues), [eventos en tiempo real](/docs/{{version}}/broadcasting), y más. Laravel está afinado para construir aplicaciones web profesionales y listo para manejar cargas de trabajo empresariales.

#### Un Framework Escalable

Laravel es increíblemente escalable. Gracias a la naturaleza amigable para la escalabilidad de PHP y el soporte incorporado de Laravel para sistemas de caché distribuidos y rápidos como Redis, la escalabilidad horizontal con Laravel es muy sencilla. De hecho, las aplicaciones Laravel se han escalado fácilmente para manejar cientos de millones de solicitudes por mes.

¿Necesitas escalabilidad extrema? Plataformas como [Laravel Vapor](https://vapor.laravel.com) te permiten ejecutar tu aplicación Laravel a una escala casi ilimitada en la última tecnología sin servidor de AWS.

#### Un Framework Comunitario

Laravel combina los mejores paquetes en el ecosistema PHP para ofrecer el framework más robusto y amigable para desarrolladores disponible. Además, miles de desarrolladores talentosos de todo el mundo han [contribuido al framework](https://github.com/laravel/framework). Quién sabe, tal vez incluso te conviertas en un contribuyente de Laravel.

<a name="creating-a-laravel-project"></a>
## Creando un Proyecto Laravel

Antes de crear tu primer proyecto Laravel, asegúrate de que tu máquina local tenga PHP y [Composer](https://getcomposer.org) instalados. Si estás desarrollando en macOS o Windows, PHP, Composer, Node y NPM se pueden instalar en minutos a través de [Laravel Herd](#local-installation-using-herd).

Después de haber instalado PHP y Composer, puedes crear un nuevo proyecto Laravel a través del comando `create-project` de Composer:

```nothing
composer create-project laravel/laravel example-app
```

O, puedes crear nuevos proyectos Laravel instalando globalmente [el instalador de Laravel](https://github.com/laravel/installer) a través de Composer. El instalador de Laravel te permite seleccionar tu framework de pruebas preferido, base de datos y kit de inicio al crear nuevas aplicaciones:

```nothing
composer global require laravel/installer

laravel new example-app
```

Una vez que se ha creado el proyecto, inicia el servidor de desarrollo local de Laravel usando el comando `serve` de Laravel Artisan:

```nothing
cd example-app

php artisan serve
```

Una vez que hayas iniciado el servidor de desarrollo Artisan, tu aplicación será accesible en tu navegador web en [http://localhost:8000](http://localhost:8000). A continuación, estás listo para [comenzar a dar tus próximos pasos en el ecosistema Laravel](#next-steps). Por supuesto, también puedes querer [configurar una base de datos](#databases-and-migrations).

> [!NOTE]  
> Si deseas un inicio rápido al desarrollar tu aplicación Laravel, considera usar uno de nuestros [kits de inicio](/docs/{{version}}/starter-kits). Los kits de inicio de Laravel proporcionan andamiaje de autenticación backend y frontend para tu nueva aplicación Laravel.

<a name="initial-configuration"></a>
## Configuración Inicial

Todos los archivos de configuración para el framework Laravel se almacenan en el directorio `config`. Cada opción está documentada, así que siéntete libre de revisar los archivos y familiarizarte con las opciones disponibles para ti.

Laravel necesita casi ninguna configuración adicional fuera de la caja. ¡Eres libre de comenzar a desarrollar! Sin embargo, es posible que desees revisar el archivo `config/app.php` y su documentación. Contiene varias opciones como `timezone` y `locale` que puedes querer cambiar de acuerdo a tu aplicación.

<a name="environment-based-configuration"></a>
### Configuración Basada en el Entorno

Dado que muchos de los valores de las opciones de configuración de Laravel pueden variar dependiendo de si tu aplicación se está ejecutando en tu máquina local o en un servidor web de producción, muchos valores de configuración importantes se definen utilizando el archivo `.env` que existe en la raíz de tu aplicación.

Tu archivo `.env` no debe ser comprometido en el control de versiones de tu aplicación, ya que cada desarrollador / servidor que use tu aplicación podría requerir una configuración de entorno diferente. Además, esto sería un riesgo de seguridad en caso de que un intruso obtenga acceso a tu repositorio de control de versiones, ya que cualquier credencial sensible estaría expuesta.

> [!NOTE]  
> Para más información sobre el archivo `.env` y la configuración basada en el entorno, consulta la [documentación completa de configuración](/docs/{{version}}/configuration#environment-configuration).

<a name="databases-and-migrations"></a>
### Bases de Datos y Migraciones

Ahora que has creado tu aplicación Laravel, probablemente quieras almacenar algunos datos en una base de datos. Por defecto, el archivo de configuración `.env` de tu aplicación especifica que Laravel interactuará con una base de datos SQLite.

Durante la creación del proyecto, Laravel creó un archivo `database/database.sqlite` para ti y ejecutó las migraciones necesarias para crear las tablas de la base de datos de la aplicación.

Si prefieres usar otro controlador de base de datos como MySQL o PostgreSQL, puedes actualizar el archivo de configuración `.env` para usar la base de datos apropiada. Por ejemplo, si deseas usar MySQL, actualiza las variables `DB_*` de tu archivo de configuración `.env` así:

```ini
DB_CONNECTION=mysql
DB_HOST=127.0.0.1
DB_PORT=3306
DB_DATABASE=laravel
DB_USERNAME=root
DB_PASSWORD=
```

Si eliges usar una base de datos diferente a SQLite, necesitarás crear la base de datos y ejecutar las [migraciones de base de datos](/docs/{{version}}/migrations) de tu aplicación:

```shell
php artisan migrate
```

> [!NOTE]  
> Si estás desarrollando en macOS o Windows y necesitas instalar MySQL, PostgreSQL o Redis localmente, considera usar [Herd Pro](https://herd.laravel.com/#plans).

<a name="directory-configuration"></a>
### Configuración de Directorios

Laravel siempre debe ser servido desde la raíz del "directorio web" configurado para tu servidor web. No debes intentar servir una aplicación Laravel desde un subdirectorio del "directorio web". Intentar hacerlo podría exponer archivos sensibles presentes dentro de tu aplicación.

<a name="local-installation-using-herd"></a>
## Instalación Local Usando Herd

[Laravel Herd](https://herd.laravel.com) es un entorno de desarrollo nativo de Laravel y PHP increíblemente rápido para macOS y Windows. Herd incluye todo lo que necesitas para comenzar con el desarrollo de Laravel, incluyendo PHP y Nginx.

Una vez que instales Herd, estarás listo para comenzar a desarrollar con Laravel. Herd incluye herramientas de línea de comandos para `php`, `composer`, `laravel`, `expose`, `node`, `npm`, y `nvm`.

> [!NOTE]  
> [Herd Pro](https://herd.laravel.com/#plans) complementa a Herd con características adicionales poderosas, como la capacidad de crear y gestionar bases de datos locales de MySQL, Postgres y Redis, así como la visualización de correos locales y monitoreo de registros.

<a name="herd-on-macos"></a>
### Herd en macOS

Si desarrollas en macOS, puedes descargar el instalador de Herd desde el [sitio web de Herd](https://herd.laravel.com). El instalador descarga automáticamente la última versión de PHP y configura tu Mac para ejecutar siempre [Nginx](https://www.nginx.com/) en segundo plano.

Herd para macOS utiliza [dnsmasq](https://en.wikipedia.org/wiki/Dnsmasq) para soportar directorios "estacionados". Cualquier aplicación Laravel en un directorio estacionado será servida automáticamente por Herd. Por defecto, Herd crea un directorio estacionado en `~/Herd` y puedes acceder a cualquier aplicación Laravel en este directorio en el dominio `.test` usando su nombre de directorio.

Después de instalar Herd, la forma más rápida de crear un nuevo proyecto Laravel es usando la CLI de Laravel, que está empaquetada con Herd:

```nothing
cd ~/Herd
laravel new my-app
cd my-app
herd open
```

Por supuesto, siempre puedes gestionar tus directorios estacionados y otras configuraciones de PHP a través de la interfaz de usuario de Herd, que se puede abrir desde el menú de Herd en la bandeja del sistema.

Puedes aprender más sobre Herd revisando la [documentación de Herd](https://herd.laravel.com/docs).

<a name="herd-on-windows"></a>
### Herd en Windows

Puedes descargar el instalador de Windows para Herd en el [sitio web de Herd](https://herd.laravel.com/windows). Después de que la instalación finalice, puedes iniciar Herd para completar el proceso de incorporación y acceder a la interfaz de usuario de Herd por primera vez.

La interfaz de usuario de Herd es accesible haciendo clic izquierdo en el ícono de la bandeja del sistema de Herd. Un clic derecho abre el menú rápido con acceso a todas las herramientas que necesitas a diario.

Durante la instalación, Herd crea un directorio "estacionado" en tu directorio personal en `%USERPROFILE%\Herd`. Cualquier aplicación Laravel en un directorio estacionado será servida automáticamente por Herd, y puedes acceder a cualquier aplicación Laravel en este directorio en el dominio `.test` usando su nombre de directorio.

Después de instalar Herd, la forma más rápida de crear un nuevo proyecto Laravel es usando la CLI de Laravel, que está empaquetada con Herd. Para comenzar, abre Powershell y ejecuta los siguientes comandos:

```nothing
cd ~\Herd
laravel new my-app
cd my-app
herd open
```

Puedes aprender más sobre Herd revisando la [documentación de Herd para Windows](https://herd.laravel.com/docs/windows).

<a name="docker-installation-using-sail"></a>
## Instalación de Docker Usando Sail

Queremos que sea lo más fácil posible comenzar con Laravel, independientemente de tu sistema operativo preferido. Así que, hay una variedad de opciones para desarrollar y ejecutar un proyecto Laravel en tu máquina local. Si bien puedes querer explorar estas opciones más adelante, Laravel proporciona [Sail](/docs/{{version}}/sail), una solución incorporada para ejecutar tu proyecto Laravel usando [Docker](https://www.docker.com).

Docker es una herramienta para ejecutar aplicaciones y servicios en pequeños "contenedores" ligeros que no interfieren con el software o la configuración instalada en tu máquina local. Esto significa que no tienes que preocuparte por configurar o establecer herramientas de desarrollo complicadas como servidores web y bases de datos en tu máquina local. Para comenzar, solo necesitas instalar [Docker Desktop](https://www.docker.com/products/docker-desktop).

Laravel Sail es una interfaz de línea de comandos ligera para interactuar con la configuración predeterminada de Docker de Laravel. Sail proporciona un gran punto de partida para construir una aplicación Laravel usando PHP, MySQL y Redis sin requerir experiencia previa en Docker.

> [!NOTE]  
> ¿Ya eres un experto en Docker? ¡No te preocupes! Todo sobre Sail se puede personalizar usando el archivo `docker-compose.yml` incluido con Laravel.

<a name="sail-on-macos"></a>
### Sail en macOS

Si estás desarrollando en un Mac y [Docker Desktop](https://www.docker.com/products/docker-desktop) ya está instalado, puedes usar un simple comando de terminal para crear un nuevo proyecto Laravel. Por ejemplo, para crear una nueva aplicación Laravel en un directorio llamado "example-app", puedes ejecutar el siguiente comando en tu terminal:

```shell
curl -s "https://laravel.build/example-app" | bash
```

Por supuesto, puedes cambiar "example-app" en esta URL por lo que desees; solo asegúrate de que el nombre de la aplicación contenga solo caracteres alfanuméricos, guiones y guiones bajos. El directorio de la aplicación Laravel se creará dentro del directorio desde el cual ejecutas el comando.

La instalación de Sail puede tardar varios minutos mientras se construyen los contenedores de la aplicación de Sail en tu máquina local.

Después de que se ha creado el proyecto, puedes navegar al directorio de la aplicación y comenzar Laravel Sail. Laravel Sail proporciona una interfaz de línea de comandos simple para interactuar con la configuración predeterminada de Docker de Laravel:

```shell
cd example-app

./vendor/bin/sail up
```

Una vez que los contenedores Docker de la aplicación se hayan iniciado, deberías ejecutar las [migraciones de base de datos](/docs/{{version}}/migrations) de tu aplicación:

```shell
./vendor/bin/sail artisan migrate
```

Finalmente, puedes acceder a la aplicación en tu navegador web en: http://localhost.

> [!NOTE]  
> Para seguir aprendiendo más sobre Laravel Sail, revisa su [documentación completa](/docs/{{version}}/sail).

<a name="sail-on-windows"></a>
### Sail en Windows

Antes de crear una nueva aplicación Laravel en tu máquina Windows, asegúrate de instalar [Docker Desktop](https://www.docker.com/products/docker-desktop). A continuación, debes asegurarte de que el Subsistema de Windows para Linux 2 (WSL2) esté instalado y habilitado. WSL te permite ejecutar ejecutables binarios de Linux de forma nativa en Windows 10. La información sobre cómo instalar y habilitar WSL2 se puede encontrar en la [documentación del entorno de desarrollador de Microsoft](https://docs.microsoft.com/en-us/windows/wsl/install-win10).

> [!NOTE]  
> Después de instalar y habilitar WSL2, debes asegurarte de que Docker Desktop esté [configurado para usar el backend WSL2](https://docs.docker.com/docker-for-windows/wsl/).

A continuación, estás listo para crear tu primer proyecto Laravel. Lanza [Windows Terminal](https://www.microsoft.com/en-us/p/windows-terminal/9n0dx20hk701?rtc=1&activetab=pivot:overviewtab) y comienza una nueva sesión de terminal para tu sistema operativo Linux WSL2. A continuación, puedes usar un simple comando de terminal para crear un nuevo proyecto Laravel. Por ejemplo, para crear una nueva aplicación Laravel en un directorio llamado "example-app", puedes ejecutar el siguiente comando en tu terminal:

```shell
curl -s https://laravel.build/example-app | bash
```

Por supuesto, puedes cambiar "example-app" en esta URL por cualquier cosa que desees; solo asegúrate de que el nombre de la aplicación contenga solo caracteres alfanuméricos, guiones y guiones bajos. El directorio de la aplicación Laravel se creará dentro del directorio desde el cual ejecutes el comando.

La instalación de Sail puede tardar varios minutos mientras se construyen los contenedores de la aplicación Sail en tu máquina local.

Después de que se haya creado el proyecto, puedes navegar al directorio de la aplicación y comenzar Laravel Sail. Laravel Sail proporciona una interfaz de línea de comandos simple para interactuar con la configuración predeterminada de Docker de Laravel:

```shell
cd example-app

./vendor/bin/sail up
```

Una vez que los contenedores Docker de la aplicación se hayan iniciado, deberías ejecutar las [migraciones de base de datos](/docs/{{version}}/migrations) de tu aplicación:

```shell
./vendor/bin/sail artisan migrate
```

Finalmente, puedes acceder a la aplicación en tu navegador web en: http://localhost.

> [!NOTE]  
> Para seguir aprendiendo más sobre Laravel Sail, revisa su [documentación completa](/docs/{{version}}/sail).

#### Desarrollo dentro de WSL2

Por supuesto, necesitarás poder modificar los archivos de la aplicación Laravel que se crearon dentro de tu instalación de WSL2. Para lograr esto, recomendamos usar el editor [Visual Studio Code](https://code.visualstudio.com) de Microsoft y su extensión de primera parte para [Desarrollo Remoto](https://marketplace.visualstudio.com/items?itemName=ms-vscode-remote.vscode-remote-extensionpack).

Una vez que estas herramientas estén instaladas, puedes abrir cualquier proyecto Laravel ejecutando el comando `code .` desde el directorio raíz de tu aplicación usando Windows Terminal.

<a name="sail-on-linux"></a>
### Sail en Linux

Si estás desarrollando en Linux y [Docker Compose](https://docs.docker.com/compose/install/) ya está instalado, puedes usar un simple comando de terminal para crear un nuevo proyecto Laravel.

Primero, si estás usando Docker Desktop para Linux, deberías ejecutar el siguiente comando. Si no estás usando Docker Desktop para Linux, puedes omitir este paso:

```shell
docker context use default
```

Luego, para crear una nueva aplicación Laravel en un directorio llamado "example-app", puedes ejecutar el siguiente comando en tu terminal:

```shell
curl -s https://laravel.build/example-app | bash
```

Por supuesto, puedes cambiar "example-app" en esta URL por cualquier cosa que desees; solo asegúrate de que el nombre de la aplicación contenga solo caracteres alfanuméricos, guiones y guiones bajos. El directorio de la aplicación Laravel se creará dentro del directorio desde el cual ejecutes el comando.

La instalación de Sail puede tardar varios minutos mientras se construyen los contenedores de la aplicación Sail en tu máquina local.

Después de que se haya creado el proyecto, puedes navegar al directorio de la aplicación y comenzar Laravel Sail. Laravel Sail proporciona una interfaz de línea de comandos simple para interactuar con la configuración predeterminada de Docker de Laravel:

```shell
cd example-app

./vendor/bin/sail up
```

Una vez que los contenedores Docker de la aplicación se hayan iniciado, deberías ejecutar las [migraciones de base de datos](/docs/{{version}}/migrations) de tu aplicación:

```shell
./vendor/bin/sail artisan migrate
```

Finalmente, puedes acceder a la aplicación en tu navegador web en: http://localhost.

> [!NOTE]  
> Para seguir aprendiendo más sobre Laravel Sail, revisa su [documentación completa](/docs/{{version}}/sail).

<a name="choosing-your-sail-services"></a>
### Elegir tus Servicios de Sail

Al crear una nueva aplicación Laravel a través de Sail, puedes usar la variable de cadena de consulta `with` para elegir qué servicios deben configurarse en el archivo `docker-compose.yml` de tu nueva aplicación. Los servicios disponibles incluyen `mysql`, `pgsql`, `mariadb`, `redis`, `memcached`, `meilisearch`, `typesense`, `minio`, `selenium` y `mailpit`:

```shell
curl -s "https://laravel.build/example-app?with=mysql,redis" | bash
```

Si no especificas qué servicios te gustaría configurar, se configurará un stack predeterminado de `mysql`, `redis`, `meilisearch`, `mailpit` y `selenium`.

Puedes instruir a Sail para que instale un [Devcontainer](/docs/{{version}}/sail#using-devcontainers) predeterminado agregando el parámetro `devcontainer` a la URL:

```shell
curl -s "https://laravel.build/example-app?with=mysql,redis&devcontainer" | bash
```

<a name="ide-support"></a>
## Soporte para IDE

Eres libre de usar cualquier editor de código que desees al desarrollar aplicaciones Laravel; sin embargo, [PhpStorm](https://www.jetbrains.com/phpstorm/laravel/) ofrece un amplio soporte para Laravel y su ecosistema, incluyendo [Laravel Pint](https://www.jetbrains.com/help/phpstorm/using-laravel-pint.html).

Además, el complemento de PhpStorm [Laravel Idea](https://laravel-idea.com/) mantenido por la comunidad ofrece una variedad de mejoras útiles para el IDE, incluyendo generación de código, autocompletado de sintaxis Eloquent, autocompletado de reglas de validación y más.

<a name="next-steps"></a>
## Próximos Pasos

Ahora que has creado tu proyecto Laravel, puedes preguntarte qué aprender a continuación. Primero, recomendamos encarecidamente familiarizarte con cómo funciona Laravel leyendo la siguiente documentación:

<div class="content-list" markdown="1">

- [Ciclo de Vida de la Solicitud](/docs/{{version}}/lifecycle)
- [Configuración](/docs/{{version}}/configuration)
- [Estructura de Directorios](/docs/{{version}}/structure)
- [Frontend](/docs/{{version}}/frontend)
- [Contenedor de Servicios](/docs/{{version}}/container)
- [Facades](/docs/{{version}}/facades)

</div>

Cómo deseas usar Laravel también dictará los próximos pasos en tu viaje. Hay una variedad de formas de usar Laravel, y exploraremos dos casos de uso principales para el framework a continuación.

> [!NOTE]  
> ¿Nuevo en Laravel? Consulta el [Laravel Bootcamp](https://bootcamp.laravel.com) para un recorrido práctico del framework mientras te guiamos en la construcción de tu primera aplicación Laravel.

<a name="laravel-the-fullstack-framework"></a>
### Laravel el Framework Full Stack

Laravel puede servir como un framework full stack. Por "framework full stack" nos referimos a que vas a usar Laravel para enrutar solicitudes a tu aplicación y renderizar tu frontend a través de [plantillas Blade](/docs/{{version}}/blade) o una tecnología híbrida de aplicación de una sola página como [Inertia](https://inertiajs.com). Esta es la forma más común de usar el framework Laravel y, en nuestra opinión, la forma más productiva de usar Laravel.

Si esta es la forma en que planeas usar Laravel, es posible que desees consultar nuestra documentación sobre [desarrollo frontend](/docs/{{version}}/frontend), [enrutamiento](/docs/{{version}}/routing), [vistas](/docs/{{version}}/views) o el [Eloquent ORM](/docs/{{version}}/eloquent). Además, podrías estar interesado en aprender sobre paquetes de la comunidad como [Livewire](https://livewire.laravel.com) y [Inertia](https://inertiajs.com). Estos paquetes te permiten usar Laravel como un framework full stack mientras disfrutas de muchos de los beneficios de UI proporcionados por aplicaciones JavaScript de una sola página.

Si estás usando Laravel como un framework full stack, también te animamos encarecidamente a aprender cómo compilar el CSS y JavaScript de tu aplicación usando [Vite](/docs/{{version}}/vite).

> [!NOTE]  
> Si deseas adelantarte en la construcción de tu aplicación, consulta uno de nuestros [kits de inicio de aplicación](/docs/{{version}}/starter-kits) oficiales.

<a name="laravel-the-api-backend"></a>
### Laravel el Backend API

Laravel también puede servir como un backend API para una aplicación de una sola página de JavaScript o una aplicación móvil. Por ejemplo, podrías usar Laravel como un backend API para tu aplicación [Next.js](https://nextjs.org). En este contexto, puedes usar Laravel para proporcionar [autenticación](/docs/{{version}}/sanctum) y almacenamiento / recuperación de datos para tu aplicación, mientras aprovechas los poderosos servicios de Laravel como colas, correos electrónicos, notificaciones y más.

Si esta es la forma en que planeas usar Laravel, es posible que desees consultar nuestra documentación sobre [enrutamiento](/docs/{{version}}/routing), [Laravel Sanctum](/docs/{{version}}/sanctum) y el [Eloquent ORM](/docs/{{version}}/eloquent).

> [!NOTE]  
> ¿Necesitas un impulso para estructurar tu backend de Laravel y frontend de Next.js? Laravel Breeze ofrece un [stack API](/docs/{{version}}/starter-kits#breeze-and-next) así como una [implementación de frontend de Next.js](https://github.com/laravel/breeze-next) para que puedas comenzar en minutos.

