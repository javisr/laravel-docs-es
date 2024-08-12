# Instalación

- [Conozca Laravel](#meet-laravel)
  - [¿Por qué Laravel?](#why-laravel)
- [Tu primer proyecto Laravel](#your-first-laravel-project)
- [Laravel y Docker](#laravel-and-docker)
  - [Primeros pasos en macOS](#getting-started-on-macos)
  - [Primeros pasos en Windows](#getting-started-on-windows)
  - [Primeros pasos en Linux](#getting-started-on-linux)
  - [Elección de los servicios de Sail](#choosing-your-sail-services)
- [Configuración inicial](#initial-configuration)
  - [Configuración basada en el entorno](#environment-based-configuration)
  - [Bases de datos y migraciones](#databases-and-migrations)
- [Siguientes pasos](#next-steps)
  - [Laravel El Framework Full Stack](#laravel-the-fullstack-framework)
  - [Laravel El API Backend](#laravel-the-api-backend)

<a name="meet-laravel"></a>
## Conozca Laravel

Laravel es un framework de aplicaciones web con una sintaxis expresiva y elegante. Un framework web proporciona una estructura y un punto de partida para la creación de su aplicación, lo que le permite centrarse en la creación de algo increíble mientras nosotros nos ocupamos de los detalles.

Laravel se esfuerza por proporcionar una buena experiencia de desarrollado al tiempo que proporciona características muy potentes, tales como la inyección de dependencia, una capa de abstracción de base de datos expresiva, colas y trabajos programados, tests unitarios y de integración, y mucho más.

Tanto si eres nuevo en los frameworks web PHP como si tienes años de experiencia, Laravel es un framework que puede crecer contigo. Te ayudaremos a dar tus primeros pasos como desarrollador web o te daremos un empujón mientras llevas tu experiencia al siguiente nivel. No podemos esperar a ver lo que construyes.

> **Nota**
> ¿Es nuevo en Laravel? Echa un vistazo al [Laravel Bootcamp](https://bootcamp.laravel.com) para un tour práctico del framework mientras te guiamos en la construcción de tu primera aplicación Laravel.

<a name="why-laravel"></a>
### ¿Por qué Laravel?

Hay una gran variedad de herramientas y frameworks a su disposición a la hora de construir una aplicación web. Sin embargo, creemos que Laravel es la mejor opción para crear aplicaciones web modernas y completas.

#### Un Framework Progresivo

Nos gusta llamar a Laravel un framework "progresivo". Con esto queremos decir que Laravel crece contigo. Si estás dando tus primeros pasos en el desarrollo web, la amplia de documentación de Laravel, guías y [tutoriales en vídeo](https://laracasts.com) le ayudarán a aprender sin sentirse abrumado.

Si usted es un desarrollador senior, Laravel le da herramientas robustas para la [inyección de dependencia](/docs/{{version}}/container), [tests unitarios](/docs/{{version}}/testing), [colas](/docs/{{version}}/queues), [eventos en tiempo real](/docs/{{version}}/broadcasting), y mucho más. Laravel está afinado para la construcción de aplicaciones web profesionales y listo para manejar las cargas de trabajo de la empresa.

#### Un Framework Escalable

Laravel es increíblemente escalable. Gracias a la naturaleza escalable de PHP y al soporte integrado de Laravel para sistemas de cache rápidos y distribuidos como Redis, el escalado horizontal con Laravel es pan comido. De hecho, las aplicaciones Laravel se han escalado fácilmente para manejar cientos de millones de peticiones al mes.

¿Necesitas escalado extremo? Plataformas como [Laravel Vapor](https://vapor.laravel.com) le permiten ejecutar su aplicación Laravel a escala casi ilimitada en la última tecnología sin servidor (serverless) de AWS.

#### Un framework comunitario

Laravel combina los mejores paquetes en el ecosistema PHP para ofrecer el marco más robusto y amigable para el desarrollador disponible. Además, miles de desarrolladores con talento de todo el mundo han [contribuido al framework](https://github.com/laravel/framework). Quién sabe, tal vez incluso te conviertas en un colaborador de Laravel.

<a name="your-first-laravel-project"></a>
## Tu primer proyecto Laravel

Antes de crear tu primer proyecto Laravel, debes asegurarte de que tu máquina tiene PHP y [Composer](https://getcomposer.org) instalados. Si estás desarrollando en macOS, PHP y Composer se pueden instalar a través de [Homebrew](https://brew.sh/). Además, recomendamos [instalar Node y NPM](https://nodejs.org).

Después de haber instalado PHP y Composer, puedes crear un nuevo proyecto Laravel a través del comando `create-project` de Composer:

```nothing
composer create-project laravel/laravel example-app
```

O bien, puede crear nuevos proyectos Laravel mediante la instalación global del instalador de Laravel a través de Composer:

```nothing
composer global require laravel/installer

laravel new example-app
```

Una vez creado el proyecto, inicia el servidor de desarrollo local de Laravel mediante el comando `serve` de la CLI Artisan de Laravel:

```nothing
cd example-app

php artisan serve
```

Una vez que hayas iniciado el servidor de desarrollo Artisan, tu aplicación será accesible en tu navegador web en `http://localhost:8000.` A continuación, estás listo para [comenzar a dar tus siguientes pasos en el ecosistema Laravel](#next-steps). Por supuesto, es posible que también desees [configurar una base de datos](#databases-and-migrations).

> **Nota**  
> Si deseas tener una ventaja al desarrollar tu aplicación Laravel, considera usar uno de nuestros [kits de inicio](/docs/{{version}}/starter-kits). Los kits de inicio de Laravel proporcionan un código pre generado de autenticación backend y frontend para tu nueva aplicación Laravel.

<a name="laravel-and-docker"></a>
## Laravel & Docker

Queremos que sea lo más fácil posible empezar con Laravel independientemente de tu sistema operativo preferido. Por lo tanto, hay una variedad de opciones para desarrollar y ejecutar un proyecto Laravel en su máquina local. Si bien es posible que desees explorar estas opciones en un momento posterior, Laravel proporciona [Sail](/docs/{{version}}/sail), una solución integrada para ejecutar tu proyecto Laravel utilizando [Docker](https://www.docker.com).

Docker es una herramienta para ejecutar aplicaciones y servicios en "contenedores" pequeños y ligeros que no interfieren con el software instalado o la configuración de tu máquina local. Esto significa que no tienes que preocuparte de configurar o instalar complicadas herramientas de desarrollo como servidores web y bases de datos en tu máquina local. Para empezar, sólo tienes que instalar [Docker Desktop](https://www.docker.com/products/docker-desktop).

Laravel Sail es una interfaz de línea de comandos ligera para interactuar con la configuración Docker predeterminada de Laravel. Sail proporciona un gran punto de partida para la construcción de una aplicación Laravel utilizando PHP, MySQL y Redis sin necesidad de experiencia previa en Docker.

> **Nota**  
> ¿Ya eres un experto en Docker? No se preocupe. Todo sobre Sail se puede personalizar utilizando el archivo `docker-compose.yml` incluido con Laravel.

<a name="getting-started-on-macos"></a>
### Primeros pasos en macOS

Si estás desarrollando en un Mac y [Docker Desktop](https://www.docker.com/products/docker-desktop) ya está instalado, puedes utilizar un simple comando de terminal para crear un nuevo proyecto Laravel. Por ejemplo, para crear una nueva aplicación Laravel en un directorio llamado "example-app", puedes ejecutar el siguiente comando en tu terminal:

```shell
curl -s "https://laravel.build/example-app" | bash
```

Por supuesto, puedes cambiar "example-app" en esta URL por lo que quieras - sólo asegúrate de que el nombre de la aplicación sólo contenga caracteres alfanuméricos, guiones y guiones bajos. El directorio de la aplicación Laravel se creará dentro del directorio desde el que ejecutes el comando.

La instalación de Sail puede tardar varios minutos mientras los contenedores de aplicación de Sail se construyen en su máquina local.

Una vez creado el proyecto, puede navegar hasta el directorio de la aplicación e iniciar Laravel Sail. Laravel Sail proporciona una sencilla interfaz de línea de comandos para interactuar con la configuración Docker por defecto de Laravel:

```shell
cd example-app

./vendor/bin/sail up
```

Una vez iniciados los contenedores Docker de la aplicación, podrás acceder a ella desde tu navegador web en: [http://localhost](http://localhost).

> **Nota**  
> Para seguir aprendiendo más sobre Laravel Sail, revisa su [documentación completa](/docs/{{version}}/sail).

<a name="getting-started-on-windows"></a>
### Primeros pasos en Windows

Antes de crear una nueva aplicación Laravel en tu máquina Windows, asegúrate de instalar [Docker Desktop](https://www.docker.com/products/docker-desktop). A continuación, debes asegurarte de que Windows Subsystem for Linux 2 (WSL2) está instalado y habilitado. WSL le permite ejecutar ejecutables binarios de Linux de forma nativa en Windows 10 y 11. Puede encontrar información sobre cómo instalar y habilitar WSL2 en [la documentación del entorno de desarrollo](https://docs.microsoft.com/en-us/windows/wsl/install-win10) de Microsoft.

> **Nota**  
> Después de instalar y habilitar WSL2, debe asegurarse de que Docker Desktop está configurado [para utilizar el backend WSL2](https://docs.docker.com/docker-for-windows/wsl/).

A continuación, estás listo para crear tu primer proyecto Laravel. Inicia [Windows Terminal](https://www.microsoft.com/en-us/p/windows-terminal/9n0dx20hk701?rtc=1&activetab=pivot:overviewtab) y comienza una nueva sesión de terminal para tu sistema operativo Linux WSL2. A continuación, puede utilizar un simple comando de terminal para crear un nuevo proyecto Laravel. Por ejemplo, para crear una nueva aplicación Laravel en un directorio llamado "example-app", puedes ejecutar el siguiente comando en tu terminal:

```shell
curl -s https://laravel.build/example-app | bash
```

Por supuesto, puedes cambiar "example-app" en esta URL por lo que quieras - sólo asegúrate de que el nombre de la aplicación sólo contenga caracteres alfanuméricos, guiones y guiones bajos. El directorio de la aplicación Laravel se creará dentro del directorio desde el que ejecutes el comando.

La instalación de Sail puede tardar varios minutos mientras los contenedores de aplicaciones de Sail se construyen en tu máquina local.

Una vez creado el proyecto, puede navegar hasta el directorio de la aplicación e iniciar Laravel Sail. Laravel Sail proporciona una sencilla interfaz de línea de comandos para interactuar con la configuración Docker por defecto de Laravel:

```shell
cd example-app

./vendor/bin/sail up
```

Una vez iniciados los contenedores Docker de la aplicación, podrás acceder a ella desde tu navegador web en: [http://localhost](http://localhost).

> **Nota**  
> Para continuar aprendiendo más sobre Laravel Sail, revisa su [documentación completa](/docs/{{version}}/sail).

#### Desarrollo dentro de WSL2

Por supuesto, necesitarás poder modificar los archivos de la aplicación Laravel que fueron creados dentro de tu instalación WSL2. Para ello, te recomendamos que utilices el editor [Visual Studio Code](https://code.visualstudio.com) de Microsoft y su primera extensión para [Desarrollo Remoto](https://marketplace.visualstudio.com/items?itemName=ms-vscode-remote.vscode-remote-extensionpack).

Una vez instaladas estas herramientas, puedes abrir cualquier proyecto Laravel ejecutando el comando `code .` desde el directorio raíz de tu aplicación utilizando el Terminal de Windows.

<a name="getting-started-on-linux"></a>
### Primeros pasos en Linux

Si estás desarrollando en Linux y [Docker Compose](https://docs.docker.com/compose/install/) ya está instalado, puedes utilizar un simple comando de terminal para crear un nuevo proyecto Laravel. Por ejemplo, para crear una nueva aplicación Laravel en un directorio llamado "example-app", puedes ejecutar el siguiente comando en tu terminal:

```shell
curl -s https://laravel.build/example-app | bash
```

Por supuesto, puedes cambiar "example-app" en esta URL por lo que quieras - sólo asegúrate de que el nombre de la aplicación sólo contenga caracteres alfanuméricos, guiones y guiones bajos. El directorio de la aplicación Laravel se creará dentro del directorio desde el que ejecutes el comando.

La instalación de Sail puede tardar varios minutos mientras los contenedores de aplicaciones de Sail se construyen en su máquina local.

Una vez creado el proyecto, puede navegar hasta el directorio de la aplicación e iniciar Laravel Sail. Laravel Sail proporciona una sencilla interfaz de línea de comandos para interactuar con la configuración Docker por defecto de Laravel:

```shell
cd example-app

./vendor/bin/sail up
```

Una vez iniciados los contenedores Docker de la aplicación, podrás acceder a ella desde tu navegador web en: [http://localhost.](http://localhost)

> **Nota**  
> Para continuar aprendiendo más sobre Laravel Sail, revisa su [documentación completa](/docs/{{version}}/sail).

<a name="choosing-your-sail-services"></a>
### Elección de los servicios de Laravel

Al crear una nueva aplicación Laravel a través de Sail, puede utilizar la variable `with` query string para elegir qué servicios se deben configurar en el archivo `docker-compose.yml` de su nueva aplicación. Los servicios disponibles incluyen `mysql`, `pgsql`, `mariadb`, `redis`, `memcached`, `meilisearch`, `minio`, `selenium` y `mailhog`:

```shell
curl -s "https://laravel.build/example-app?with=mysql,redis" | bash
```

Si no especifica qué servicios desea configurar, se configurará un stack predeterminada de `mysql`, `redis`, `meilisearch`, `mailhog` y `selenium`.

Puedes indicar a Sail que instale un [Devcontainer](/docs/{{version}}/sail#using-devcontainers) por defecto añadiendo el parámetro `devcontainer` a la URL:

```shell
curl -s "https://laravel.build/example-app?with=mysql,redis&devcontainer" | bash
```

<a name="initial-configuration"></a>
## Configuración inicial

Todos los archivos de configuración para el framework Laravel se almacenan en el directorio `config`. Cada opción está documentada, así que siéntete libre de revisar los archivos y familiarizarte con las opciones disponibles.

Laravel casi no necesita configuración adicional fuera de la caja. ¡Eres libre de empezar a desarrollar! Sin embargo, es posible que desee revisar el archivo `config/app.php` y su documentación. Contiene varias opciones tales como la `timezone` (zona horaria) y la `locale` (configuración regional) que es posible que desee cambiar de acuerdo a su aplicación.

<a name="environment-based-configuration"></a>
### Configuración basada en el entorno

Dado que muchos de los valores de las opciones de configuración de Laravel pueden variar dependiendo de si tu aplicación se está ejecutando en tu máquina local o en un servidor web de producción, muchos valores de configuración importantes se definen utilizando el archivo `.env` que existe en la raíz de tu aplicación.

Su archivo `.env` no debe ser enviado al control de código fuente de su aplicación, ya que cada desarrollador / servidor que utilice su aplicación podría requerir una configuración de entorno diferente. Además, esto supondría un riesgo de seguridad en el caso de que un intruso accediera a su repositorio de control de código fuente, ya que cualquier credencial sensible quedaría expuesta.

> **Nota**  
> Para obtener más información sobre el archivo `.env` y la configuración basada en el entorno, consulte la documentación completa sobre [configuración](/docs/{{version}}/configuration#environment-configuration).

<a name="databases-and-migrations"></a>
### Bases de datos y migraciones

Ahora que has creado tu aplicación Laravel, probablemente quieras almacenar algunos datos en una base de datos. Por defecto, el archivo de configuración . `env` de tu aplicación especifica que Laravel interactuará con una base de datos MySQL y accederá a la base de datos en `127.0.0.1`. Si estás desarrollando en macOS y necesitas instalar MySQL, Postgres o Redis localmente, puede que te resulte conveniente utilizar [DBngin](https://dbngin.com/).

Si no quieres instalar MySQL o Postgres en tu máquina local, siempre puedes utilizar una base de datos [SQLite](https://www.sqlite.org/index.html). SQLite es un motor de base de datos pequeño, rápido y autónomo. Para empezar, crea una base de datos SQLite creando un archivo SQLite vacío. Normalmente, este archivo existirá dentro del directorio de `database` de tu aplicación Laravel:

```shell
touch database/database.sqlite
```

A continuación, actualiza tu archivo de configuración `.env` para utilizar el controlador de base de datos `sqlite` de Laravel. Puedes eliminar las otras opciones de configuración de la base de datos:

```ini
DB_CONNECTION=sqlite # [tl! add]
DB_CONNECTION=mysql # [tl! remove]
DB_HOST=127.0.0.1 # [tl! remove]
DB_PORT=3306 # [tl! remove]
DB_DATABASE=laravel # [tl! remove]
DB_USERNAME=root # [tl! remove]
DB_PASSWORD= # [tl! remove]
```

Una vez que hayas configurado tu base de datos SQLite, puedes ejecutar las [migraciones de base de datos](/docs/{{version}}/migrations) de tu aplicación, que crearán las tablas de base de datos de tu aplicación:

```shell
php artisan migrate
```

<a name="next-steps"></a>
## Siguientes Pasos:

Ahora que has creado tu proyecto Laravel, puede que te estés preguntando qué aprender a continuación. En primer lugar, te recomendamos que te familiarices con el funcionamiento de Laravel leyendo la siguiente documentación:

<div class="content-list" markdown="1">

- [Ciclo de vida de la solicitud](/docs/{{version}}/lifecycle)
- [Configuración](/docs/{{version}}/configuration)
- [Estructura del directorio](/docs/{{version}}/structure)
- [Frontend](/docs/{{version}}/frontend)
- [Contenedor de servicios](/docs/{{version}}/container)
- [Facades](/docs/{{version}}/facades)

</div>

La forma en que desea utilizar Laravel también dictará los próximos pasos en su viaje. Hay una variedad de maneras de utilizar Laravel, y vamos a explorar dos casos de uso principal para el marco de abajo.

> **Nota**
> ¿Nuevo en Laravel? Echa un vistazo al [Laravel Bootcamp](https://bootcamp.laravel.com) para un tour práctico del framework mientras te guiamos en la construcción de tu primera aplicación Laravel.

<a name="laravel-the-fullstack-framework"></a>
### Laravel El Framework de Pila Completa

Laravel puede servir como un framework full stack. Por framework "full stack" nos referimos a que vas a utilizar Laravel para enrutar las peticiones a tu aplicación y renderizar tu frontend a través de [plantillas Blade](/docs/{{version}}/blade) o una tecnología híbrida de aplicación de una sola página como [Inertia](https://inertiajs.com). Esta es la forma más común de utilizar el framework Laravel, y, en nuestra opinión, la forma más productiva de utilizar Laravel.

Si esta es la forma en que planeas utilizar Laravel, es posible que desees consultar nuestra documentación sobre [desarrollo frontend](/docs/{{version}}/frontend), [enrutamiento](/docs/{{version}}/routing), [vistas](/docs/{{version}}/views) o el [ORM Eloquent](/docs/{{version}}/eloquent). Además, puede que te interese conocer paquetes de la comunidad como [Livewire](https://laravel-livewire.com) e [Inertia](https://inertiajs.com). Estos paquetes le permiten utilizar Laravel como un framework full-stack mientras disfruta de muchos de los beneficios de interfaz que proporcionan las aplicaciones de una sola página (SPA) de JavaScript.

Si estás usando Laravel como un framework full-stack, también te recomendamos encarecidamente que aprendas a compilar el CSS y JavaScript de tu aplicación usando [Vite](/docs/{{version}}/vite).

> **Nota**  
> Si quieres empezar a construir tu aplicación, echa un vistazo a uno de nuestros [kits de inicio de aplicaciones](/docs/{{version}}/starter-kits) oficiales.

<a name="laravel-the-api-backend"></a>
### Laravel El API Backend

Laravel también puede servir como API backend para una aplicación JavaScript de una sola página o una aplicación móvil. Por ejemplo, puedes utilizar Laravel como API backend para tu aplicación [Next.js](https://nextjs.org). En este contexto, puede utilizar Laravel para proporcionar [autenticación](/docs/{{version}}/sanctum) y almacenamiento / recuperación de datos para su aplicación, al tiempo que aprovecha los potentes servicios de Laravel como colas, correos electrónicos, notificaciones y más.

Si esta es la forma en que planea utilizar Laravel, es posible que desee consultar nuestra documentación sobre [enrutamiento](/docs/{{version}}/routing), [Laravel Sanctum](/docs/{{version}}/sanctum), y el [ORM Eloquent](/docs/{{version}}/eloquent).

> **Nota**  
> ¿Necesitas empezar a construir tu backend Laravel y frontend Next.js? Laravel Breeze ofrece un [stack para API](/docs/{{version}}/starter-kits#breeze-and-next) así como una [implementación de frontend](https://github.com/laravel/breeze-next) Next.js para que puedas empezar en cuestión de minutos.
