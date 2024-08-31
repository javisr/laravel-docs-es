# Instalación

- [Conoce Laravel](#meet-laravel)
  - [¿Por qué Laravel?](#why-laravel)
- [Creando un Proyecto Laravel](#creating-a-laravel-project)
- [Configuración Inicial](#initial-configuration)
  - [Configuración Basada en el Entorno](#environment-based-configuration)
  - [Bases de Datos y Migraciones](#databases-and-migrations)
  - [Configuración del Directorio](#directory-configuration)
- [Instalación Local Usando Herd](#local-installation-using-herd)
  - [Herd en macOS](#herd-on-macos)
  - [Herd en Windows](#herd-on-windows)
- [Instalación de Docker Usando Sail](#docker-installation-using-sail)
  - [Sail en macOS](#sail-on-macos)
  - [Sail en Windows](#sail-on-windows)
  - [Sail en Linux](#sail-on-linux)
  - [Eligiendo tus Servicios de Sail](#choosing-your-sail-services)
- [Soporte para IDE](#ide-support)
- [Siguientes Pasos](#next-steps)
  - [Laravel el Framework Full Stack](#laravel-the-fullstack-framework)
  - [Laravel el Backend de API](#laravel-the-api-backend)

<a name="meet-laravel"></a>
## Conoce Laravel

Laravel es un framework de aplicaciones web con una sintaxis expresiva y elegante. Un framework web proporciona una estructura y un punto de partida para crear tu aplicación, lo que te permite centrarte en crear algo increíble mientras nosotros nos ocupamos de los detalles.
Laravel se esfuerza por ofrecer una experiencia de desarrollo increíble mientras proporciona características potentes como una profunda inyección de dependencias, una capa de abstracción de base de datos expresiva, colas y trabajos programados, pruebas unitarias e integradas, y más.
Ya sea que seas nuevo en los frameworks web de PHP o tengas años de experiencia, Laravel es un framework que puede crecer contigo. Te ayudaremos a dar tus primeros pasos como desarrollador web o a impulsar tu experiencia al siguiente nivel. No podemos esperar a ver lo que construirás.

<a name="why-laravel"></a>
### ¿Por qué Laravel?

Hay una variedad de herramientas y frameworks disponibles para ti al construir una aplicación web. Sin embargo, creemos que Laravel es la mejor opción para construir aplicaciones web modernas y de pila completa.
#### Un Framework Progresivo

Nos gusta llamar a Laravel un framework "progresivo". Con esto, queremos decir que Laravel crece contigo. Si estás dando tus primeros pasos en el desarrollo web, la vasta biblioteca de documentación, guías y [tutoriales en video](https://laracasts.com) de Laravel te ayudarán a aprender lo básico sin sentirte abrumado.
Si eres un desarrollador senior, Laravel te brinda herramientas robustas para [inyección de dependencias](/docs/%7B%7Bversion%7D%7D/container), [pruebas unitarias](/docs/%7B%7Bversion%7D%7D/testing), [colas](/docs/%7B%7Bversion%7D%7D/queues), [eventos en tiempo real](/docs/%7B%7Bversion%7D%7D/broadcasting) y más. Laravel está afinado para construir aplicaciones web profesionales y listo para manejar cargas de trabajo empresariales.
#### Un Framework Escalable

Laravel es increíblemente escalable. Gracias a la naturaleza amigable con el escalado de PHP y al soporte incorporado de Laravel para sistemas de caché distribuidos y rápidos como Redis, el escalado horizontal con Laravel es muy sencillo. De hecho, las aplicaciones Laravel se han escalado fácilmente para manejar cientos de millones de solicitudes por mes.
¿Necesitas escalado extremo? Plataformas como [Laravel Vapor](https://vapor.laravel.com) te permiten ejecutar tu aplicación Laravel a una escala casi ilimitada en la última tecnología serverless de AWS.
#### Un Framework Comunitario

Laravel combina los mejores paquetes en el ecosistema PHP para ofrecer el framework más robusto y amigable para desarrolladores disponible. Además, miles de desarrolladores talentosos de todo el mundo han [contribuido al framework](https://github.com/laravel/framework). Quién sabe, tal vez incluso te conviertas en un colaborador de Laravel.

<a name="creating-a-laravel-project"></a>
## Creando un Proyecto Laravel

Antes de crear tu primer proyecto Laravel, asegúrate de que tu máquina local tenga PHP y [Composer](https://getcomposer.org) instalados. Si estás desarrollando en macOS o Windows, PHP, Composer, Node y NPM se pueden instalar en minutos a través de [Laravel Herd](#local-installation-using-herd).
Después de haber instalado PHP y Composer, puedes crear un nuevo proyecto Laravel a través del comando `create-project` de Composer:


```nothing
composer create-project laravel/laravel example-app

```
O también puedes crear nuevos proyectos de Laravel instalando globalmente [el instalador de Laravel](https://github.com/laravel/installer) a través de Composer. El instalador de Laravel te permite seleccionar tu framework de pruebas preferido, base de datos y kit de inicio al crear nuevas aplicaciones:


```nothing
composer global require laravel/installer

laravel new example-app

```
Una vez que se haya creado el proyecto, inicia el servidor de desarrollo local de Laravel utilizando el comando `serve` de Laravel Artisan:


```nothing
cd example-app

php artisan serve

```
Una vez que hayas iniciado el servidor de desarrollo Artisan, tu aplicación será accesible en tu navegador web en [http://localhost:8000](http://localhost:8000). A continuación, estás listo para [comenzar a dar tus próximos pasos en el ecosistema de Laravel](#next-steps). Por supuesto, también puede que desees [configurar una base de datos](#databases-and-migrations).
> [!NOTA]
Si deseas un buen comienzo al desarrollar tu aplicación Laravel, considera usar uno de nuestros [starter kits](/docs/%7B%7Bversion%7D%7D/starter-kits). Los starter kits de Laravel proporcionan andamiaje de autenticación backend y frontend para tu nueva aplicación Laravel.

<a name="initial-configuration"></a>
## Configuración Inicial

Todos los archivos de configuración para el framework Laravel se almacenan en el directorio `config`. Cada opción está documentada, así que siéntete libre de revisar los archivos y familiarizarte con las opciones disponibles para ti.
Laravel casi no necesita configuración adicional desde el primer momento. ¡Puedes empezar a desarrollar! Sin embargo, es posible que desees revisar el archivo `config/app.php` y su documentación. Contiene varias opciones como `timezone` y `locale` que es posible que desees cambiar según tu aplicación.

<a name="environment-based-configuration"></a>
### Configuración Basada en el Entorno

Dado que muchos de los valores de opciones de configuración de Laravel pueden variar según si tu aplicación se está ejecutando en tu máquina local o en un servidor web de producción, muchos valores de configuración importantes se definen utilizando el archivo `.env` que existe en la raíz de tu aplicación.
Tu archivo `.env` no debería ser confirmado en el control de versiones de tu aplicación, ya que cada desarrollador / servidor que utiliza tu aplicación podría requerir una configuración de entorno diferente. Además, esto sería un riesgo de seguridad en caso de que un intruso acceda a tu repositorio de control de versiones, ya que cualquier credencial sensible quedaría expuesta.
> [!NOTA]
Para obtener más información sobre el archivo `.env` y la configuración basada en el entorno, consulta la [documentación de configuración](/docs/%7B%7Bversion%7D%7D/configuration#environment-configuration).

<a name="databases-and-migrations"></a>
### Bases de datos y migraciones

Ahora que has creado tu aplicación Laravel, probablemente quieras almacenar algunos datos en una base de datos. Por defecto, el archivo de configuración `.env` de tu aplicación especifica que Laravel estará interactuando con una base de datos SQLite.
Durante la creación del proyecto, Laravel creó un archivo `database/database.sqlite` para ti y ejecutó las migraciones necesarias para crear las tablas de la base de datos de la aplicación.
Si prefieres usar otro driver de base de datos como MySQL o PostgreSQL, puedes actualizar tu archivo de configuración `.env` para usar la base de datos apropiada. Por ejemplo, si deseas usar MySQL, actualiza las variables `DB_*` de tu archivo de configuración `.env` de la siguiente manera:


```ini
DB_CONNECTION=mysql
DB_HOST=127.0.0.1
DB_PORT=3306
DB_DATABASE=laravel
DB_USERNAME=root
DB_PASSWORD=

```
Si decides usar una base de datos diferente a SQLite, necesitarás crear la base de datos y ejecutar las [migraciones de base de datos](/docs/%7B%7Bversion%7D%7D/migrations) de tu aplicación:


```shell
php artisan migrate

```
> [!NOTA]
Si estás desarrollando en macOS o Windows y necesitas instalar MySQL, PostgreSQL o Redis localmente, considera usar [Herd Pro](https://herd.laravel.com/#plans).

<a name="directory-configuration"></a>
### Configuración de Directorios

Laravel siempre debe ser servido desde la raíz del "directorio web" configurado para su servidor web. No deberías intentar servir una aplicación Laravel desde un subdirectorio del "directorio web". Intentar hacerlo podría exponer archivos sensibles presentes dentro de tu aplicación.

<a name="local-installation-using-herd"></a>
## Instalación Local Usando Herd

[Laravel Herd](https://herd.laravel.com) es un entorno de desarrollo nativo de Laravel y PHP increíblemente rápido para macOS y Windows. Herd incluye todo lo que necesitas para comenzar con el desarrollo de Laravel, incluyendo PHP y Nginx.
Una vez que instales Herd, estás listo para comenzar a desarrollar con Laravel. Herd incluye herramientas de línea de comandos para `php`, `composer`, `laravel`, `expose`, `node`, `npm` y `nvm`.
> [!NOTE]
[Herd Pro](https://herd.laravel.com/#plans) mejora Herd con características adicionales poderosas, como la capacidad de crear y gestionar bases de datos locales de MySQL, Postgres y Redis, así como la visualización de correos locales y el monitoreo de registros.

<a name="herd-on-macos"></a>
### Herd en macOS

Si desarrollas en macOS, puedes descargar el instalador de Herd desde el [sitio web de Herd](https://herd.laravel.com). El instalador descarga automáticamente la última versión de PHP y configura tu Mac para que siempre ejecute [Nginx](https://www.nginx.com/) en segundo plano.
Herd para macOS utiliza [dnsmasq](https://es.wikipedia.org/wiki/Dnsmasq) para soportar directorios "estacionados". Cualquier aplicación Laravel en un directorio estacionado será servida automáticamente por Herd. Por defecto, Herd crea un directorio estacionado en `~/Herd` y puedes acceder a cualquier aplicación Laravel en este directorio en el dominio `.test` utilizando su nombre de directorio.
Después de instalar Herd, la forma más rápida de crear un nuevo proyecto Laravel es utilizando la CLI de Laravel, que viene incluida con Herd:


```nothing
cd ~/Herd
laravel new my-app
cd my-app
herd open

```
Por supuesto, siempre puedes gestionar tus directorios aparcados y otras configuraciones de PHP a través de la interfaz de usuario de Herd, que se puede abrir desde el menú de Herd en tu bandeja del sistema.
Puedes aprender más sobre Herd consultando la [documentación de Herd](https://herd.laravel.com/docs).

<a name="herd-on-windows"></a>
### Herd en Windows

Puedes descargar el instalador de Windows para Herd en el [sitio web de Herd](https://herd.laravel.com/windows). Después de que finalice la instalación, puedes iniciar Herd para completar el proceso de incorporación y acceder a la interfaz de usuario de Herd por primera vez.
La interfaz de usuario de Herd es accesible haciendo clic izquierdo en el icono de la bandeja del sistema de Herd. Un clic derecho abre el menú rápido con acceso a todas las herramientas que necesitas a diario.
Durante la instalación, Herd crea un directorio "parked" en tu directorio home en `%USERPROFILE%\Herd`. Cualquier aplicación Laravel en un directorio parked será servida automáticamente por Herd, y puedes acceder a cualquier aplicación Laravel en este directorio en el dominio `.test` utilizando su nombre de directorio.
Después de instalar Herd, la forma más rápida de crear un nuevo proyecto Laravel es utilizando la CLI de Laravel, que viene incluida con Herd. Para comenzar, abre Powershell y ejecuta los siguientes comandos:


```nothing
cd ~\Herd
laravel new my-app
cd my-app
herd open

```
Puedes aprender más sobre Herd consultando la [documentación de Herd para Windows](https://herd.laravel.com/docs/windows).

<a name="docker-installation-using-sail"></a>
## Instalación de Docker utilizando Sail

Queremos que sea lo más fácil posible comenzar con Laravel sin importar tu sistema operativo preferido. Así que, hay una variedad de opciones para desarrollar y ejecutar un proyecto Laravel en tu máquina local. Si bien es posible que desees explorar estas opciones en otro momento, Laravel ofrece [Sail](/docs/%7B%7Bversion%7D%7D/sail), una solución integrada para ejecutar tu proyecto Laravel utilizando [Docker](https://www.docker.com).
Docker es una herramienta para ejecutar aplicaciones y servicios en pequeños y ligeros "contenedores" que no interfieren con el software o la configuración instalada en tu máquina local. Esto significa que no tienes que preocuparte por configurar o instalar herramientas de desarrollo complicadas, como servidores web y bases de datos, en tu máquina local. Para comenzar, solo necesitas instalar [Docker Desktop](https://www.docker.com/products/docker-desktop).
Laravel Sail es una interfaz de línea de comandos ligera para interactuar con la configuración Docker predeterminada de Laravel. Sail ofrece un excelente punto de partida para construir una aplicación Laravel utilizando PHP, MySQL y Redis sin requerir experiencia previa en Docker.
> [!NOTE]
¿Ya eres un experto en Docker? ¡No te preocupes! Todo sobre Sail se puede personalizar utilizando el archivo `docker-compose.yml` incluido con Laravel.

<a name="sail-on-macos"></a>
### Sail en macOS

Si estás desarrollando en un Mac y [Docker Desktop](https://www.docker.com/products/docker-desktop) ya está instalado, puedes usar un simple comando en la terminal para crear un nuevo proyecto Laravel. Por ejemplo, para crear una nueva aplicación Laravel en un directorio llamado "example-app", puedes ejecutar el siguiente comando en tu terminal:


```shell
curl -s "https://laravel.build/example-app" | bash

```

<a name="sail-on-windows"></a>
### Navegar en Windows

Antes de crear una nueva aplicación Laravel en tu máquina Windows, asegúrate de instalar [Docker Desktop](https://www.docker.com/products/docker-desktop). A continuación, debes asegurarte de que Windows Subsystem for Linux 2 (WSL2) esté instalado y habilitado. WSL te permite ejecutar ejecutables binarios de Linux de manera nativa en Windows 10. La información sobre cómo instalar y habilitar WSL2 se puede encontrar en la [documentación del entorno de desarrollo de Microsoft](https://docs.microsoft.com/en-us/windows/wsl/install-win10).
> [!NOTA]
Después de instalar y habilitar WSL2, debes asegurarte de que Docker Desktop esté [configurado para usar el backend de WSL2](https://docs.docker.com/docker-for-windows/wsl/).
A continuación, estás listo para crear tu primer proyecto Laravel. Lanza [Windows Terminal](https://www.microsoft.com/en-us/p/windows-terminal/9n0dx20hk701?rtc=1&activetab=pivot:overviewtab) y comienza una nueva sesión de terminal para tu sistema operativo Linux WSL2. A continuación, puedes usar un simple comando de terminal para crear un nuevo proyecto Laravel. Por ejemplo, para crear una nueva aplicación Laravel en un directorio llamado "example-app", puedes ejecutar el siguiente comando en tu terminal:
#### Desarrollo en WSL2

Por supuesto, necesitarás poder modificar los archivos de la aplicación Laravel que fueron creados dentro de tu instalación de WSL2. Para lograr esto, recomendamos utilizar el editor [Visual Studio Code](https://code.visualstudio.com) de Microsoft y su extensión de primera clase para [Desarrollo Remoto](https://marketplace.visualstudio.com/items?itemName=ms-vscode-remote.vscode-remote-extensionpack).
Una vez que estas herramientas estén instaladas, puedes abrir cualquier proyecto Laravel ejecutando el comando `code .` desde el directorio raíz de tu aplicación utilizando Windows Terminal.

<a name="sail-on-linux"></a>
### Sail en Linux

Si estás desarrollando en Linux y [Docker Compose](https://docs.docker.com/compose/install/) ya está instalado, puedes usar un simple comando en la terminal para crear un nuevo proyecto Laravel.
Primero, si estás usando Docker Desktop para Linux, debes ejecutar el siguiente comando. Si no estás usando Docker Desktop para Linux, puedes saltarte este paso:


```shell
docker context use default

```
Entonces, para crear una nueva aplicación Laravel en un directorio llamado "example-app", puedes ejecutar el siguiente comando en tu terminal:


```shell
curl -s https://laravel.build/example-app | bash

```
Por supuesto, puedes cambiar "example-app" en esta URL a cualquier cosa que desees; solo asegúrate de que el nombre de la aplicación contenga solo caracteres alfanuméricos, guiones y guiones bajos. El directorio de la aplicación Laravel se creará dentro del directorio desde el cual ejecutes el comando.
La instalación de Sail puede tardar varios minutos mientras se construyen los contenedores de la aplicación de Sail en tu máquina local.
Después de que se haya creado el proyecto, puedes navegar al directorio de la aplicación y iniciar Laravel Sail. Laravel Sail proporciona una interfaz de línea de comandos simple para interactuar con la configuración Docker predeterminada de Laravel:


```shell
cd example-app

./vendor/bin/sail up

```
Una vez que se hayan iniciado los contenedores Docker de la aplicación, deberías ejecutar las [migraciones de base de datos](/docs/%7B%7Bversion%7D%7D/migrations) de tu aplicación:


```shell
./vendor/bin/sail artisan migrate

```
Finalmente, puedes acceder a la aplicación en tu navegador web en: http://localhost.
> [!NOTE]
Para seguir aprendiendo más sobre Laravel Sail, revisa su [documentación completa](/docs/%7B%7Bversion%7D%7D/sail).

<a name="choosing-your-sail-services"></a>
### Elegir tus Servicios de Sail

Al crear una nueva aplicación Laravel a través de Sail, puedes usar la variable de cadena de consulta `with` para elegir qué servicios deberían configurarse en el archivo `docker-compose.yml` de tu nueva aplicación. Los servicios disponibles incluyen `mysql`, `pgsql`, `mariadb`, `redis`, `memcached`, `meilisearch`, `typesense`, `minio`, `selenium` y `mailpit`:


```shell
curl -s "https://laravel.build/example-app?with=mysql,redis" | bash

```
Si no especificas qué servicios te gustaría configurar, se configurará una pila predeterminada de `mysql`, `redis`, `meilisearch`, `mailpit` y `selenium`.
Puedes instruir a Sail para que instale un [Devcontainer](/docs/%7B%7Bversion%7D%7D/sail#using-devcontainers) predeterminado añadiendo el parámetro `devcontainer` a la URL:


```shell
curl -s "https://laravel.build/example-app?with=mysql,redis&devcontainer" | bash

```

<a name="ide-support"></a>
## Soporte de IDE

Puedes usar cualquier editor de código que desees al desarrollar aplicaciones Laravel; sin embargo, [PhpStorm](https://www.jetbrains.com/phpstorm/laravel/) ofrece un amplio soporte para Laravel y su ecosistema, incluyendo [Laravel Pint](https://www.jetbrains.com/help/phpstorm/using-laravel-pint.html).
Además, el plugin PhpStorm [Laravel Idea](https://laravel-idea.com/) mantenido por la comunidad ofrece una variedad de mejoras útiles para el IDE, incluyendo generación de código, autocompletado de sintaxis Eloquent, autocompletado de reglas de validación y más.

<a name="next-steps"></a>
## Siguientes Pasos

Ahora que has creado tu proyecto Laravel, es posible que te estés preguntando qué aprender a continuación. Primero, te recomendamos encarecidamente que te familiarices con el funcionamiento de Laravel leyendo la siguiente documentación:
<div class="content-list" markdown="1">

- [Request Lifecycle](/docs/%7B%7Bversion%7D%7D/lifecycle)
- [Configuration](/docs/%7B%7Bversion%7D%7D/configuration)
- [Directory Structure](/docs/%7B%7Bversion%7D%7D/structure)
- [Frontend](/docs/%7B%7Bversion%7D%7D/frontend)
- [Service Container](/docs/%7B%7Bversion%7D%7D/container)
- [Facades](/docs/%7B%7Bversion%7D%7D/facades)
</div>
Cómo deseas usar Laravel también dictará los próximos pasos en tu viaje. Hay una variedad de maneras de usar Laravel, y exploraremos dos casos de uso principales para el framework a continuación.
> [!NOTE]
¿Nuevo en Laravel? Consulta el [Laravel Bootcamp](https://bootcamp.laravel.com) para un recorrido práctico por el framework mientras te guiamos en la construcción de tu primera aplicación Laravel.

<a name="laravel-the-fullstack-framework"></a>
### Laravel el Framework Completo

Laravel puede funcionar como un framework full stack. Por "framework full stack" nos referimos a que vas a usar Laravel para enrutar solicitudes a tu aplicación y renderizar tu frontend a través de [plantillas Blade](/docs/%7B%7Bversion%7D%7D/blade) o una tecnología híbrida de aplicación de una sola página como [Inertia](https://inertiajs.com). Esta es la forma más común de usar el framework Laravel y, en nuestra opinión, la forma más productiva de usar Laravel.
Si así es como planeas usar Laravel, puede que desees consultar nuestra documentación sobre [desarrollo frontend](/docs/%7B%7Bversion%7D%7D/frontend), [ruteo](/docs/%7B%7Bversion%7D%7D/routing), [vistas](/docs/%7B%7Bversion%7D%7D/views) o el [Eloquent ORM](/docs/%7B%7Bversion%7D%7D/eloquent). Además, puede que te interese aprender sobre paquetes de la comunidad como [Livewire](https://livewire.laravel.com) e [Inertia](https://inertiajs.com). Estos paquetes te permiten usar Laravel como un framework de pila completa mientras disfrutas de muchos de los beneficios de la interfaz de usuario que ofrecen las aplicaciones JavaScript de una sola página.
Si estás utilizando Laravel como un framework de stack completo, también te recomendamos encarecidamente que aprendas a compilar el CSS y JavaScript de tu aplicación utilizando [Vite](/docs/%7B%7Bversion%7D%7D/vite).
> [!NOTE]
Si quieres empezar a construir tu aplicación, echa un vistazo a uno de nuestros [kits de inicio de aplicación](/docs/%7B%7Bversion%7D%7D/starter-kits).

<a name="laravel-the-api-backend"></a>
### Laravel el Backend de la API

Laravel también puede funcionar como un backend API para una aplicación de una sola página en JavaScript o una aplicación móvil. Por ejemplo, podrías usar Laravel como un backend API para tu aplicación [Next.js](https://nextjs.org). En este contexto, puedes usar Laravel para proporcionar [autenticación](/docs/%7B%7Bversion%7D%7D/sanctum) y almacenamiento / recuperación de datos para tu aplicación, mientras también aprovechas los poderosos servicios de Laravel como colas, correos electrónicos, notificaciones y más.
Si así es como planeas usar Laravel, es posible que desees consultar nuestra documentación sobre [rutas](/docs/%7B%7Bversion%7D%7D/routing), [Laravel Sanctum](/docs/%7B%7Bversion%7D%7D/sanctum) y el [ORM Eloquent](/docs/%7B%7Bversion%7D%7D/eloquent).
> [!NOTE]
¿Necesitas un andamiaje inicial para tu backend de Laravel y tu frontend de Next.js? Laravel Breeze ofrece un [API stack](/docs/%7B%7Bversion%7D%7D/starter-kits#breeze-and-next) así como una [implementación de frontend de Next.js](https://github.com/laravel/breeze-next) para que puedas comenzar en minutos.