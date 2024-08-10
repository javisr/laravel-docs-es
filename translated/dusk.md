# Laravel Dusk

- [Introducción](#introduction)
- [Instalación](#installation)
    - [Gestionando Instalaciones de ChromeDriver](#managing-chromedriver-installations)
    - [Usando Otros Navegadores](#using-other-browsers)
- [Comenzando](#getting-started)
    - [Generando Pruebas](#generating-tests)
    - [Restableciendo la Base de Datos Después de Cada Prueba](#resetting-the-database-after-each-test)
    - [Ejecutando Pruebas](#running-tests)
    - [Manejo del Entorno](#environment-handling)
- [Conceptos Básicos del Navegador](#browser-basics)
    - [Creando Navegadores](#creating-browsers)
    - [Navegación](#navigation)
    - [Redimensionando Ventanas del Navegador](#resizing-browser-windows)
    - [Macros del Navegador](#browser-macros)
    - [Autenticación](#authentication)
    - [Cookies](#cookies)
    - [Ejecutando JavaScript](#executing-javascript)
    - [Tomando una Captura de Pantalla](#taking-a-screenshot)
    - [Almacenando Salida de Consola en Disco](#storing-console-output-to-disk)
    - [Almacenando Fuente de Página en Disco](#storing-page-source-to-disk)
- [Interacción con Elementos](#interacting-with-elements)
    - [Selectores de Dusk](#dusk-selectors)
    - [Texto, Valores y Atributos](#text-values-and-attributes)
    - [Interacción con Formularios](#interacting-with-forms)
    - [Adjuntando Archivos](#attaching-files)
    - [Presionando Botones](#pressing-buttons)
    - [Haciendo Clic en Enlaces](#clicking-links)
    - [Usando el Teclado](#using-the-keyboard)
    - [Usando el Ratón](#using-the-mouse)
    - [Diálogos de JavaScript](#javascript-dialogs)
    - [Interacción con Iframes](#interacting-with-iframes)
    - [Selectores de Alcance](#scoping-selectors)
    - [Esperando Elementos](#waiting-for-elements)
    - [Desplazando un Elemento a la Vista](#scrolling-an-element-into-view)
- [Aserciones Disponibles](#available-assertions)
- [Páginas](#pages)
    - [Generando Páginas](#generating-pages)
    - [Configurando Páginas](#configuring-pages)
    - [Navegando a Páginas](#navigating-to-pages)
    - [Selectores Abreviados](#shorthand-selectors)
    - [Métodos de Página](#page-methods)
- [Componentes](#components)
    - [Generando Componentes](#generating-components)
    - [Usando Componentes](#using-components)
- [Integración Continua](#continuous-integration)
    - [Heroku CI](#running-tests-on-heroku-ci)
    - [Travis CI](#running-tests-on-travis-ci)
    - [GitHub Actions](#running-tests-on-github-actions)
    - [Chipper CI](#running-tests-on-chipper-ci)

<a name="introduction"></a>
## Introducción

[Laravel Dusk](https://github.com/laravel/dusk) proporciona una API de automatización y pruebas de navegador expresiva y fácil de usar. Por defecto, Dusk no requiere que instales JDK o Selenium en tu computadora local. En su lugar, Dusk utiliza una instalación independiente de [ChromeDriver](https://sites.google.com/chromium.org/driver). Sin embargo, eres libre de utilizar cualquier otro controlador compatible con Selenium que desees.

<a name="installation"></a>
## Instalación

Para comenzar, debes instalar [Google Chrome](https://www.google.com/chrome) y agregar la dependencia de Composer `laravel/dusk` a tu proyecto:

```shell
composer require laravel/dusk --dev
```

> [!WARNING]  
> Si estás registrando manualmente el proveedor de servicios de Dusk, **nunca** debes registrarlo en tu entorno de producción, ya que hacerlo podría permitir que usuarios arbitrarios se autentiquen con tu aplicación.

Después de instalar el paquete Dusk, ejecuta el comando Artisan `dusk:install`. El comando `dusk:install` creará un directorio `tests/Browser`, un ejemplo de prueba de Dusk e instalará el binario de Chrome Driver para tu sistema operativo:

```shell
php artisan dusk:install
```

A continuación, establece la variable de entorno `APP_URL` en el archivo `.env` de tu aplicación. Este valor debe coincidir con la URL que utilizas para acceder a tu aplicación en un navegador.

> [!NOTE]  
> Si estás utilizando [Laravel Sail](/docs/{{version}}/sail) para gestionar tu entorno de desarrollo local, consulta también la documentación de Sail sobre [configuración y ejecución de pruebas Dusk](/docs/{{version}}/sail#laravel-dusk).

<a name="managing-chromedriver-installations"></a>
### Gestionando Instalaciones de ChromeDriver

Si deseas instalar una versión diferente de ChromeDriver a la que está instalada por Laravel Dusk a través del comando `dusk:install`, puedes usar el comando `dusk:chrome-driver`:

```shell
# Install the latest version of ChromeDriver for your OS...
php artisan dusk:chrome-driver

# Install a given version of ChromeDriver for your OS...
php artisan dusk:chrome-driver 86

# Install a given version of ChromeDriver for all supported OSs...
php artisan dusk:chrome-driver --all

# Install the version of ChromeDriver that matches the detected version of Chrome / Chromium for your OS...
php artisan dusk:chrome-driver --detect
```

> [!WARNING]  
> Dusk requiere que los binarios de `chromedriver` sean ejecutables. Si tienes problemas para ejecutar Dusk, debes asegurarte de que los binarios sean ejecutables utilizando el siguiente comando: `chmod -R 0755 vendor/laravel/dusk/bin/`.

<a name="using-other-browsers"></a>
### Usando Otros Navegadores

Por defecto, Dusk utiliza Google Chrome y una instalación independiente de [ChromeDriver](https://sites.google.com/chromium.org/driver) para ejecutar tus pruebas de navegador. Sin embargo, puedes iniciar tu propio servidor Selenium y ejecutar tus pruebas en cualquier navegador que desees.

Para comenzar, abre tu archivo `tests/DuskTestCase.php`, que es el caso de prueba base de Dusk para tu aplicación. Dentro de este archivo, puedes eliminar la llamada al método `startChromeDriver`. Esto evitará que Dusk inicie automáticamente el ChromeDriver:

    /**
     * Preparar la ejecución de la prueba Dusk.
     *
     * @beforeClass
     */
    public static function prepare(): void
    {
        // static::startChromeDriver();
    }

A continuación, puedes modificar el método `driver` para conectarte a la URL y puerto de tu elección. Además, puedes modificar las "capacidades deseadas" que deben pasarse al WebDriver:

    use Facebook\WebDriver\Remote\RemoteWebDriver;

    /**
     * Crear la instancia de RemoteWebDriver.
     */
    protected function driver(): RemoteWebDriver
    {
        return RemoteWebDriver::create(
            'http://localhost:4444/wd/hub', DesiredCapabilities::phantomjs()
        );
    }

<a name="getting-started"></a>
## Comenzando

<a name="generating-tests"></a>
### Generando Pruebas

Para generar una prueba de Dusk, utiliza el comando Artisan `dusk:make`. La prueba generada se colocará en el directorio `tests/Browser`:

```shell
php artisan dusk:make LoginTest
```

<a name="resetting-the-database-after-each-test"></a>
### Restableciendo la Base de Datos Después de Cada Prueba

La mayoría de las pruebas que escribas interactuarán con páginas que recuperan datos de la base de datos de tu aplicación; sin embargo, tus pruebas de Dusk nunca deben usar el trait `RefreshDatabase`. El trait `RefreshDatabase` aprovecha las transacciones de base de datos que no serán aplicables o disponibles a través de solicitudes HTTP. En su lugar, tienes dos opciones: el trait `DatabaseMigrations` y el trait `DatabaseTruncation`.

<a name="reset-migrations"></a>
#### Usando Migraciones de Base de Datos

El trait `DatabaseMigrations` ejecutará tus migraciones de base de datos antes de cada prueba. Sin embargo, eliminar y recrear tus tablas de base de datos para cada prueba es típicamente más lento que truncar las tablas:

```php tab=Pest
<?php

use Illuminate\Foundation\Testing\DatabaseMigrations;
use Laravel\Dusk\Browser;

uses(DatabaseMigrations::class);

//
```

```php tab=PHPUnit
<?php

namespace Tests\Browser;

use Illuminate\Foundation\Testing\DatabaseMigrations;
use Laravel\Dusk\Browser;
use Tests\DuskTestCase;

class ExampleTest extends DuskTestCase
{
    use DatabaseMigrations;

    //
}
```

> [!WARNING]  
> Las bases de datos SQLite en memoria no pueden ser utilizadas al ejecutar pruebas Dusk. Dado que el navegador se ejecuta dentro de su propio proceso, no podrá acceder a las bases de datos en memoria de otros procesos.

<a name="reset-truncation"></a>
#### Usando Truncamiento de Base de Datos

El trait `DatabaseTruncation` migrará tu base de datos en la primera prueba para asegurarse de que tus tablas de base de datos se hayan creado correctamente. Sin embargo, en pruebas posteriores, las tablas de la base de datos simplemente serán truncadas, proporcionando un aumento de velocidad en comparación con volver a ejecutar todas tus migraciones de base de datos:

```php tab=Pest
<?php

use Illuminate\Foundation\Testing\DatabaseTruncation;
use Laravel\Dusk\Browser;

uses(DatabaseTruncation::class);

//
```

```php tab=PHPUnit
<?php

namespace Tests\Browser;

use App\Models\User;
use Illuminate\Foundation\Testing\DatabaseTruncation;
use Laravel\Dusk\Browser;
use Tests\DuskTestCase;

class ExampleTest extends DuskTestCase
{
    use DatabaseTruncation;

    //
}
```

Por defecto, este trait truncará todas las tablas excepto la tabla `migrations`. Si deseas personalizar las tablas que deben ser truncadas, puedes definir una propiedad `$tablesToTruncate` en tu clase de prueba:

> [!NOTE]  
> Si estás utilizando Pest, debes definir propiedades o métodos en la clase base `DuskTestCase` o en cualquier clase que tu archivo de prueba extienda.

    /**
     * Indica qué tablas deben ser truncadas.
     *
     * @var array
     */
    protected $tablesToTruncate = ['users'];

Alternativamente, puedes definir una propiedad `$exceptTables` en tu clase de prueba para especificar qué tablas deben ser excluidas del truncamiento:

    /**
     * Indica qué tablas deben ser excluidas del truncamiento.
     *
     * @var array
     */
    protected $exceptTables = ['users'];

Para especificar las conexiones de base de datos que deben tener sus tablas truncadas, puedes definir una propiedad `$connectionsToTruncate` en tu clase de prueba:

    /**
     * Indica qué conexiones deben tener sus tablas truncadas.
     *
     * @var array
     */
    protected $connectionsToTruncate = ['mysql'];

Si deseas ejecutar código antes o después de que se realice el truncamiento de la base de datos, puedes definir métodos `beforeTruncatingDatabase` o `afterTruncatingDatabase` en tu clase de prueba:

    /**
     * Realizar cualquier trabajo que deba llevarse a cabo antes de que la base de datos comience a truncar.
     */
    protected function beforeTruncatingDatabase(): void
    {
        //
    }

    /**
     * Realizar cualquier trabajo que deba llevarse a cabo después de que la base de datos haya terminado de truncar.
     */
    protected function afterTruncatingDatabase(): void
    {
        //
    }

<a name="running-tests"></a>
### Ejecutando Pruebas

Para ejecutar tus pruebas de navegador, ejecuta el comando Artisan `dusk`:

```shell
php artisan dusk
```

Si tuviste fallos en las pruebas la última vez que ejecutaste el comando `dusk`, puedes ahorrar tiempo volviendo a ejecutar primero las pruebas fallidas utilizando el comando `dusk:fails`:

```shell
php artisan dusk:fails
```

El comando `dusk` acepta cualquier argumento que normalmente es aceptado por el ejecutor de pruebas Pest / PHPUnit, como permitirte ejecutar solo las pruebas para un [grupo](https://docs.phpunit.de/en/10.5/annotations.html#group) dado:

```shell
php artisan dusk --group=foo
```

> [!NOTE]  
> Si estás utilizando [Laravel Sail](/docs/{{version}}/sail) para gestionar tu entorno de desarrollo local, consulta la documentación de Sail sobre [configuración y ejecución de pruebas Dusk](/docs/{{version}}/sail#laravel-dusk).

<a name="manually-starting-chromedriver"></a>
#### Iniciando ChromeDriver Manualmente

Por defecto, Dusk intentará iniciar automáticamente ChromeDriver. Si esto no funciona para tu sistema particular, puedes iniciar ChromeDriver manualmente antes de ejecutar el comando `dusk`. Si decides iniciar ChromeDriver manualmente, debes comentar la siguiente línea de tu archivo `tests/DuskTestCase.php`:

    /**
     * Preparar la ejecución de la prueba Dusk.
     *
     * @beforeClass
     */
    public static function prepare(): void
    {
        // static::startChromeDriver();
    }

Además, si inicias ChromeDriver en un puerto diferente a 9515, debes modificar el método `driver` de la misma clase para reflejar el puerto correcto:

    use Facebook\WebDriver\Remote\RemoteWebDriver;

    /**
     * Crear la instancia de RemoteWebDriver.
     */
    protected function driver(): RemoteWebDriver
    {
        return RemoteWebDriver::create(
            'http://localhost:9515', DesiredCapabilities::chrome()
        );
    }

<a name="environment-handling"></a>
### Manejo del Entorno

Para forzar a Dusk a usar su propio archivo de entorno al ejecutar pruebas, crea un archivo `.env.dusk.{environment}` en la raíz de tu proyecto. Por ejemplo, si vas a iniciar el comando `dusk` desde tu entorno `local`, debes crear un archivo `.env.dusk.local`.

Al ejecutar pruebas, Dusk hará una copia de seguridad de tu archivo `.env` y renombrará tu entorno Dusk a `.env`. Una vez que las pruebas se hayan completado, tu archivo `.env` será restaurado.

<a name="browser-basics"></a>
## Conceptos Básicos del Navegador

<a name="creating-browsers"></a>
### Creando Navegadores

Para comenzar, escribamos una prueba que verifique que podemos iniciar sesión en nuestra aplicación. Después de generar una prueba, podemos modificarla para navegar a la página de inicio de sesión, ingresar algunas credenciales y hacer clic en el botón "Iniciar sesión". Para crear una instancia de navegador, puedes llamar al método `browse` desde dentro de tu prueba Dusk:

```php tab=Pest
<?php

use App\Models\User;
use Illuminate\Foundation\Testing\DatabaseMigrations;
use Laravel\Dusk\Browser;

uses(DatabaseMigrations::class);

test('basic example', function () {
    $user = User::factory()->create([
        'email' => 'taylor@laravel.com',
    ]);

    $this->browse(function (Browser $browser) use ($user) {
        $browser->visit('/login')
                ->type('email', $user->email)
                ->type('password', 'password')
                ->press('Login')
                ->assertPathIs('/home');
    });
});
```

```php tab=PHPUnit
<?php

namespace Tests\Browser;

use App\Models\User;
use Illuminate\Foundation\Testing\DatabaseMigrations;
use Laravel\Dusk\Browser;
use Tests\DuskTestCase;

class ExampleTest extends DuskTestCase
{
    use DatabaseMigrations;

    /**
     * A basic browser test example.
     */
    public function test_basic_example(): void
    {
        $user = User::factory()->create([
            'email' => 'taylor@laravel.com',
        ]);

        $this->browse(function (Browser $browser) use ($user) {
            $browser->visit('/login')
                    ->type('email', $user->email)
                    ->type('password', 'password')
                    ->press('Login')
                    ->assertPathIs('/home');
        });
    }
}
```

Como puedes ver en el ejemplo anterior, el método `browse` acepta una función anónima. Una instancia de navegador se pasará automáticamente a esta función anónima por Dusk y es el objeto principal utilizado para interactuar y hacer aserciones contra tu aplicación.

<a name="creating-multiple-browsers"></a>
#### Creando Múltiples Navegadores

A veces, puedes necesitar múltiples navegadores para llevar a cabo correctamente una prueba. Por ejemplo, se pueden necesitar múltiples navegadores para probar una pantalla de chat que interactúa con websockets. Para crear múltiples navegadores, simplemente agrega más argumentos de navegador a la firma de la función anónima dada al método `browse`:

    $this->browse(function (Browser $first, Browser $second) {
        $first->loginAs(User::find(1))
              ->visit('/home')
              ->waitForText('Message');

        $second->loginAs(User::find(2))
               ->visit('/home')
               ->waitForText('Message')
               ->type('message', 'Hey Taylor')
               ->press('Send');

        $first->waitForText('Hey Taylor')
              ->assertSee('Jeffrey Way');
    });

<a name="navigation"></a>
### Navegación

El método `visit` puede ser utilizado para navegar a una URI dada dentro de tu aplicación:

    $browser->visit('/login');

Puedes usar el método `visitRoute` para navegar a una [ruta nombrada](/docs/{{version}}/routing#named-routes):

    $browser->visitRoute($routeName, $parameters);

Puedes navegar "hacia atrás" y "hacia adelante" usando los métodos `back` y `forward`:

    $browser->back();

    $browser->forward();

Puedes usar el método `refresh` para refrescar la página:

    $browser->refresh();

<a name="resizing-browser-windows"></a>
### Redimensionando Ventanas del Navegador

Puedes usar el método `resize` para ajustar el tamaño de la ventana del navegador:

    $browser->resize(1920, 1080);

El método `maximize` puede ser utilizado para maximizar la ventana del navegador:

    $browser->maximize();

El método `fitContent` redimensionará la ventana del navegador para que coincida con el tamaño de su contenido:

    $browser->fitContent();

Cuando una prueba falla, Dusk redimensionará automáticamente el navegador para que se ajuste al contenido antes de tomar una captura de pantalla. Puedes desactivar esta función llamando al método `disableFitOnFailure` dentro de tu prueba:

    $browser->disableFitOnFailure();

Puedes usar el método `move` para mover la ventana del navegador a una posición diferente en tu pantalla:

    $browser->move($x = 100, $y = 100);

<a name="browser-macros"></a>
### Macros del Navegador

Si deseas definir un método de navegador personalizado que puedas reutilizar en varias de tus pruebas, puedes usar el método `macro` en la clase `Browser`. Típicamente, debes llamar a este método desde el método `boot` de un [proveedor de servicios](/docs/{{version}}/providers):

    <?php

    namespace App\Providers;

    use Illuminate\Support\ServiceProvider;
    use Laravel\Dusk\Browser;

    class DuskServiceProvider extends ServiceProvider
    {
        /**
         * Registrar las macros del navegador de Dusk.
         */
        public function boot(): void
        {
            Browser::macro('scrollToElement', function (string $element = null) {
                $this->script("$('html, body').animate({ scrollTop: $('$element').offset().top }, 0);");

                return $this;
            });
        }
    }

La función `macro` acepta un nombre como su primer argumento, y una función anónima como su segundo. La función anónima de la macro se ejecutará al llamar a la macro como un método en una instancia de `Browser`:

```markdown
    $this->browse(function (Browser $browser) use ($user) {
        $browser->visit('/pay')
                ->scrollToElement('#credit-card-details')
                ->assertSee('Ingrese los detalles de la tarjeta de crédito');
    });

<a name="authentication"></a>
### Autenticación

A menudo, estarás probando páginas que requieren autenticación. Puedes usar el método `loginAs` de Dusk para evitar interactuar con la pantalla de inicio de sesión de tu aplicación durante cada prueba. El método `loginAs` acepta una clave primaria asociada con tu modelo autenticable o una instancia de modelo autenticable:

    use App\Models\User;
    use Laravel\Dusk\Browser;

    $this->browse(function (Browser $browser) {
        $browser->loginAs(User::find(1))
              ->visit('/home');
    });

> [!WARNING]  
> Después de usar el método `loginAs`, la sesión del usuario se mantendrá para todas las pruebas dentro del archivo.

<a name="cookies"></a>
### Cookies

Puedes usar el método `cookie` para obtener o establecer el valor de una cookie encriptada. Por defecto, todas las cookies creadas por Laravel están encriptadas:

    $browser->cookie('name');

    $browser->cookie('name', 'Taylor');

Puedes usar el método `plainCookie` para obtener o establecer el valor de una cookie sin encriptar:

    $browser->plainCookie('name');

    $browser->plainCookie('name', 'Taylor');

Puedes usar el método `deleteCookie` para eliminar la cookie dada:

    $browser->deleteCookie('name');

<a name="executing-javascript"></a>
### Ejecutando JavaScript

Puedes usar el método `script` para ejecutar declaraciones JavaScript arbitrarias dentro del navegador:

    $browser->script('document.documentElement.scrollTop = 0');

    $browser->script([
        'document.body.scrollTop = 0',
        'document.documentElement.scrollTop = 0',
    ]);

    $output = $browser->script('return window.location.pathname');

<a name="taking-a-screenshot"></a>
### Tomando una Captura de Pantalla

Puedes usar el método `screenshot` para tomar una captura de pantalla y almacenarla con el nombre de archivo dado. Todas las capturas de pantalla se almacenarán dentro del directorio `tests/Browser/screenshots`:

    $browser->screenshot('filename');

El método `responsiveScreenshots` puede ser utilizado para tomar una serie de capturas de pantalla en varios puntos de ruptura:

    $browser->responsiveScreenshots('filename');

El método `screenshotElement` puede ser utilizado para tomar una captura de pantalla de un elemento específico en la página:

    $browser->screenshotElement('#selector', 'filename');

<a name="storing-console-output-to-disk"></a>
### Almacenando la Salida de la Consola en Disco

Puedes usar el método `storeConsoleLog` para escribir la salida de la consola del navegador actual en disco con el nombre de archivo dado. La salida de la consola se almacenará dentro del directorio `tests/Browser/console`:

    $browser->storeConsoleLog('filename');

<a name="storing-page-source-to-disk"></a>
### Almacenando el Código Fuente de la Página en Disco

Puedes usar el método `storeSource` para escribir el código fuente de la página actual en disco con el nombre de archivo dado. El código fuente de la página se almacenará dentro del directorio `tests/Browser/source`:

    $browser->storeSource('filename');

<a name="interacting-with-elements"></a>
## Interactuando con Elementos

<a name="dusk-selectors"></a>
### Selectores de Dusk

Elegir buenos selectores CSS para interactuar con elementos es una de las partes más difíciles de escribir pruebas de Dusk. Con el tiempo, los cambios en el frontend pueden hacer que selectores CSS como los siguientes rompan tus pruebas:

    // HTML...

    <button>Iniciar sesión</button>

    // Prueba...

    $browser->click('.login-page .container div > button');

Los selectores de Dusk te permiten concentrarte en escribir pruebas efectivas en lugar de recordar selectores CSS. Para definir un selector, agrega un atributo `dusk` a tu elemento HTML. Luego, al interactuar con un navegador Dusk, precede el selector con `@` para manipular el elemento adjunto dentro de tu prueba:

    // HTML...

    <button dusk="login-button">Iniciar sesión</button>

    // Prueba...

    $browser->click('@login-button');

Si lo deseas, puedes personalizar el atributo HTML que utiliza el selector de Dusk a través del método `selectorHtmlAttribute`. Típicamente, este método debe ser llamado desde el método `boot` del `AppServiceProvider` de tu aplicación:

    use Laravel\Dusk\Dusk;

    Dusk::selectorHtmlAttribute('data-dusk');

<a name="text-values-and-attributes"></a>
### Texto, Valores y Atributos

<a name="retrieving-setting-values"></a>
#### Recuperando y Estableciendo Valores

Dusk proporciona varios métodos para interactuar con el valor actual, el texto mostrado y los atributos de los elementos en la página. Por ejemplo, para obtener el "valor" de un elemento que coincide con un selector CSS o Dusk dado, usa el método `value`:

    // Recuperar el valor...
    $value = $browser->value('selector');

    // Establecer el valor...
    $browser->value('selector', 'value');

Puedes usar el método `inputValue` para obtener el "valor" de un elemento de entrada que tiene un nombre de campo dado:

    $value = $browser->inputValue('field');

<a name="retrieving-text"></a>
#### Recuperando Texto

El método `text` puede ser utilizado para recuperar el texto mostrado de un elemento que coincide con el selector dado:

    $text = $browser->text('selector');

<a name="retrieving-attributes"></a>
#### Recuperando Atributos

Finalmente, el método `attribute` puede ser utilizado para recuperar el valor de un atributo de un elemento que coincide con el selector dado:

    $attribute = $browser->attribute('selector', 'value');

<a name="interacting-with-forms"></a>
### Interactuando con Formularios

<a name="typing-values"></a>
#### Escribiendo Valores

Dusk proporciona una variedad de métodos para interactuar con formularios y elementos de entrada. Primero, veamos un ejemplo de escribir texto en un campo de entrada:

    $browser->type('email', 'taylor@laravel.com');

Ten en cuenta que, aunque el método acepta uno si es necesario, no estamos obligados a pasar un selector CSS al método `type`. Si no se proporciona un selector CSS, Dusk buscará un campo `input` o `textarea` con el atributo `name` dado.

Para agregar texto a un campo sin borrar su contenido, puedes usar el método `append`:

    $browser->type('tags', 'foo')
            ->append('tags', ', bar, baz');

Puedes borrar el valor de una entrada usando el método `clear`:

    $browser->clear('email');

Puedes instruir a Dusk para que escriba lentamente usando el método `typeSlowly`. Por defecto, Dusk pausará 100 milisegundos entre pulsaciones de teclas. Para personalizar la cantidad de tiempo entre pulsaciones de teclas, puedes pasar el número apropiado de milisegundos como el tercer argumento al método:

    $browser->typeSlowly('mobile', '+1 (202) 555-5555');

    $browser->typeSlowly('mobile', '+1 (202) 555-5555', 300);

Puedes usar el método `appendSlowly` para agregar texto lentamente:

    $browser->type('tags', 'foo')
            ->appendSlowly('tags', ', bar, baz');

<a name="dropdowns"></a>
#### Desplegables

Para seleccionar un valor disponible en un elemento `select`, puedes usar el método `select`. Al igual que el método `type`, el método `select` no requiere un selector CSS completo. Al pasar un valor al método `select`, debes pasar el valor de la opción subyacente en lugar del texto mostrado:

    $browser->select('size', 'Large');

Puedes seleccionar una opción aleatoria omitiendo el segundo argumento:

    $browser->select('size');

Al proporcionar un array como segundo argumento al método `select`, puedes instruir al método para seleccionar múltiples opciones:

    $browser->select('categories', ['Art', 'Music']);

<a name="checkboxes"></a>
#### Casillas de Verificación

Para "marcar" una entrada de casilla de verificación, puedes usar el método `check`. Al igual que muchos otros métodos relacionados con entradas, no se requiere un selector CSS completo. Si no se puede encontrar una coincidencia de selector CSS, Dusk buscará una casilla de verificación con un atributo `name` coincidente:

    $browser->check('terms');

El método `uncheck` puede ser utilizado para "desmarcar" una entrada de casilla de verificación:

    $browser->uncheck('terms');

<a name="radio-buttons"></a>
#### Botones de Opción

Para "seleccionar" una opción de entrada `radio`, puedes usar el método `radio`. Al igual que muchos otros métodos relacionados con entradas, no se requiere un selector CSS completo. Si no se puede encontrar una coincidencia de selector CSS, Dusk buscará una entrada `radio` con atributos `name` y `value` coincidentes:

    $browser->radio('size', 'large');

<a name="attaching-files"></a>
### Adjuntando Archivos

El método `attach` puede ser utilizado para adjuntar un archivo a un elemento de entrada `file`. Al igual que muchos otros métodos relacionados con entradas, no se requiere un selector CSS completo. Si no se puede encontrar una coincidencia de selector CSS, Dusk buscará una entrada `file` con un atributo `name` coincidente:

    $browser->attach('photo', __DIR__.'/photos/mountains.png');

> [!WARNING]  
> La función attach requiere que la extensión `Zip` de PHP esté instalada y habilitada en tu servidor.

<a name="pressing-buttons"></a>
### Presionando Botones

El método `press` puede ser utilizado para hacer clic en un elemento de botón en la página. El argumento dado al método `press` puede ser ya sea el texto mostrado del botón o un selector CSS / Dusk:

    $browser->press('Iniciar sesión');

Al enviar formularios, muchas aplicaciones deshabilitan el botón de envío del formulario después de que se presiona y luego vuelven a habilitar el botón cuando se completa la solicitud HTTP de envío del formulario. Para presionar un botón y esperar a que el botón se vuelva a habilitar, puedes usar el método `pressAndWaitFor`:

    // Presiona el botón y espera un máximo de 5 segundos para que se habilite...
    $browser->pressAndWaitFor('Guardar');

    // Presiona el botón y espera un máximo de 1 segundo para que se habilite...
    $browser->pressAndWaitFor('Guardar', 1);

<a name="clicking-links"></a>
### Haciendo Clic en Enlaces

Para hacer clic en un enlace, puedes usar el método `clickLink` en la instancia del navegador. El método `clickLink` hará clic en el enlace que tiene el texto mostrado dado:

    $browser->clickLink($linkText);

Puedes usar el método `seeLink` para determinar si un enlace con el texto mostrado dado es visible en la página:

    if ($browser->seeLink($linkText)) {
        // ...
    }

> [!WARNING]  
> Estos métodos interactúan con jQuery. Si jQuery no está disponible en la página, Dusk lo inyectará automáticamente en la página para que esté disponible durante la duración de la prueba.

<a name="using-the-keyboard"></a>
### Usando el Teclado

El método `keys` te permite proporcionar secuencias de entrada más complejas a un elemento dado que las normalmente permitidas por el método `type`. Por ejemplo, puedes instruir a Dusk para que mantenga presionadas las teclas modificadoras mientras ingresa valores. En este ejemplo, la tecla `shift` se mantendrá presionada mientras se ingresa `taylor` en el elemento que coincide con el selector dado. Después de que se escriba `taylor`, se escribirá `swift` sin ninguna tecla modificadora:

    $browser->keys('selector', ['{shift}', 'taylor'], 'swift');

Otro caso de uso valioso para el método `keys` es enviar una combinación de "atajo de teclado" al selector CSS principal de tu aplicación:

    $browser->keys('.app', ['{command}', 'j']);

> [!NOTE]  
> Todas las teclas modificadoras como `{command}` están envueltas en caracteres `{}`, y coinciden con las constantes definidas en la clase `Facebook\WebDriver\WebDriverKeys`, que se puede [encontrar en GitHub](https://github.com/php-webdriver/php-webdriver/blob/master/lib/WebDriverKeys.php).

<a name="fluent-keyboard-interactions"></a>
#### Interacciones de Teclado Fluida

Dusk también proporciona un método `withKeyboard`, que te permite realizar interacciones complejas con el teclado de manera fluida a través de la clase `Laravel\Dusk\Keyboard`. La clase `Keyboard` proporciona métodos `press`, `release`, `type` y `pause`:

    use Laravel\Dusk\Keyboard;

    $browser->withKeyboard(function (Keyboard $keyboard) {
        $keyboard->press('c')
            ->pause(1000)
            ->release('c')
            ->type(['c', 'e', 'o']);
    });

<a name="keyboard-macros"></a>
#### Macros de Teclado

Si deseas definir interacciones personalizadas del teclado que puedas reutilizar fácilmente en toda tu suite de pruebas, puedes usar el método `macro` proporcionado por la clase `Keyboard`. Típicamente, deberías llamar a este método desde el método `boot` de un [proveedor de servicios](/docs/{{version}}/providers):

    <?php

    namespace App\Providers;

    use Facebook\WebDriver\WebDriverKeys;
    use Illuminate\Support\ServiceProvider;
    use Laravel\Dusk\Keyboard;
    use Laravel\Dusk\OperatingSystem;

    class DuskServiceProvider extends ServiceProvider
    {
        /**
         * Registrar los macros del navegador de Dusk.
         */
        public function boot(): void
        {
            Keyboard::macro('copy', function (string $element = null) {
                $this->type([
                    OperatingSystem::onMac() ? WebDriverKeys::META : WebDriverKeys::CONTROL, 'c',
                ]);

                return $this;
            });

            Keyboard::macro('paste', function (string $element = null) {
                $this->type([
                    OperatingSystem::onMac() ? WebDriverKeys::META : WebDriverKeys::CONTROL, 'v',
                ]);

                return $this;
            });
        }
    }

La función `macro` acepta un nombre como su primer argumento y una función anónima como su segundo. La función anónima del macro se ejecutará al llamar al macro como un método en una instancia de `Keyboard`:

    $browser->click('@textarea')
        ->withKeyboard(fn (Keyboard $keyboard) => $keyboard->copy())
        ->click('@another-textarea')
        ->withKeyboard(fn (Keyboard $keyboard) => $keyboard->paste());

<a name="using-the-mouse"></a>
### Usando el Ratón

<a name="clicking-on-elements"></a>
#### Haciendo Clic en Elementos

El método `click` puede ser utilizado para hacer clic en un elemento que coincide con el selector CSS o Dusk dado:

    $browser->click('.selector');

El método `clickAtXPath` puede ser utilizado para hacer clic en un elemento que coincide con la expresión XPath dada:

    $browser->clickAtXPath('//div[@class = "selector"]');

El método `clickAtPoint` puede ser utilizado para hacer clic en el elemento superior en un par de coordenadas dado en relación con el área visible del navegador:

    $browser->clickAtPoint($x = 0, $y = 0);

El método `doubleClick` puede ser utilizado para simular el doble clic de un ratón:

    $browser->doubleClick();

    $browser->doubleClick('.selector');

El método `rightClick` puede ser utilizado para simular el clic derecho de un ratón:

    $browser->rightClick();

    $browser->rightClick('.selector');

El método `clickAndHold` puede ser utilizado para simular que un botón del ratón se hace clic y se mantiene presionado. Una llamada posterior al método `releaseMouse` deshará este comportamiento y liberará el botón del ratón:

    $browser->clickAndHold('.selector');

    $browser->clickAndHold()
            ->pause(1000)
            ->releaseMouse();

El método `controlClick` puede ser utilizado para simular el evento `ctrl+click` dentro del navegador:

    $browser->controlClick();

    $browser->controlClick('.selector');

<a name="mouseover"></a>
#### Pasar el Ratón

El método `mouseover` puede ser utilizado cuando necesitas mover el ratón sobre un elemento que coincide con el selector CSS o Dusk dado:

    $browser->mouseover('.selector');

<a name="drag-drop"></a>
#### Arrastrar y Soltar

El método `drag` puede ser utilizado para arrastrar un elemento que coincide con el selector dado a otro elemento:

    $browser->drag('.from-selector', '.to-selector');

O, puedes arrastrar un elemento en una sola dirección:

    $browser->dragLeft('.selector', $pixels = 10);
    $browser->dragRight('.selector', $pixels = 10);
    $browser->dragUp('.selector', $pixels = 10);
    $browser->dragDown('.selector', $pixels = 10);

Finalmente, puedes arrastrar un elemento por un desplazamiento dado:

    $browser->dragOffset('.selector', $x = 10, $y = 10);

<a name="javascript-dialogs"></a>
### Diálogos de JavaScript
```

Dusk proporciona varios métodos para interactuar con los diálogos de JavaScript. Por ejemplo, puedes usar el método `waitForDialog` para esperar a que aparezca un diálogo de JavaScript. Este método acepta un argumento opcional que indica cuántos segundos esperar para que aparezca el diálogo:

    $browser->waitForDialog($seconds = null);

El método `assertDialogOpened` se puede usar para afirmar que un diálogo se ha mostrado y contiene el mensaje dado:

    $browser->assertDialogOpened('Dialog message');

Si el diálogo de JavaScript contiene un aviso, puedes usar el método `typeInDialog` para escribir un valor en el aviso:

    $browser->typeInDialog('Hello World');

Para cerrar un diálogo de JavaScript abierto haciendo clic en el botón "OK", puedes invocar el método `acceptDialog`:

    $browser->acceptDialog();

Para cerrar un diálogo de JavaScript abierto haciendo clic en el botón "Cancel", puedes invocar el método `dismissDialog`:

    $browser->dismissDialog();

<a name="interacting-with-iframes"></a>
### Interactuando Con Iframes

Si necesitas interactuar con elementos dentro de un iframe, puedes usar el método `withinFrame`. Todas las interacciones de elementos que se realicen dentro de la función anónima proporcionada al método `withinFrame` estarán limitadas al contexto del iframe especificado:

    $browser->withinFrame('#credit-card-details', function ($browser) {
        $browser->type('input[name="cardnumber"]', '4242424242424242')
            ->type('input[name="exp-date"]', '1224')
            ->type('input[name="cvc"]', '123')
            ->press('Pay');
    });

<a name="scoping-selectors"></a>
### Limitando Selectores

A veces, puedes desear realizar varias operaciones mientras limitas todas las operaciones dentro de un selector dado. Por ejemplo, puedes desear afirmar que algún texto existe solo dentro de una tabla y luego hacer clic en un botón dentro de esa tabla. Puedes usar el método `with` para lograr esto. Todas las operaciones realizadas dentro de la función anónima dada al método `with` estarán limitadas al selector original:

    $browser->with('.table', function (Browser $table) {
        $table->assertSee('Hello World')
              ->clickLink('Delete');
    });

Ocasionalmente, puede que necesites ejecutar afirmaciones fuera del alcance actual. Puedes usar los métodos `elsewhere` y `elsewhereWhenAvailable` para lograr esto:

     $browser->with('.table', function (Browser $table) {
        // El alcance actual es `body .table`...

        $browser->elsewhere('.page-title', function (Browser $title) {
            // El alcance actual es `body .page-title`...
            $title->assertSee('Hello World');
        });

        $browser->elsewhereWhenAvailable('.page-title', function (Browser $title) {
            // El alcance actual es `body .page-title`...
            $title->assertSee('Hello World');
        });
     });

<a name="waiting-for-elements"></a>
### Esperando Elementos

Al probar aplicaciones que utilizan JavaScript extensivamente, a menudo se vuelve necesario "esperar" a que ciertos elementos o datos estén disponibles antes de continuar con una prueba. Dusk hace que esto sea muy fácil. Usando una variedad de métodos, puedes esperar a que los elementos se vuelvan visibles en la página o incluso esperar hasta que una expresión de JavaScript dada evalúe a `true`.

<a name="waiting"></a>
#### Esperando

Si solo necesitas pausar la prueba por un número dado de milisegundos, usa el método `pause`:

    $browser->pause(1000);

Si necesitas pausar la prueba solo si una condición dada es `true`, usa el método `pauseIf`:

    $browser->pauseIf(App::environment('production'), 1000);

Del mismo modo, si necesitas pausar la prueba a menos que una condición dada sea `true`, puedes usar el método `pauseUnless`:

    $browser->pauseUnless(App::environment('testing'), 1000);

<a name="waiting-for-selectors"></a>
#### Esperando Selectores

El método `waitFor` se puede usar para pausar la ejecución de la prueba hasta que el elemento que coincide con el selector CSS o Dusk dado se muestre en la página. Por defecto, esto pausará la prueba por un máximo de cinco segundos antes de lanzar una excepción. Si es necesario, puedes pasar un umbral de tiempo de espera personalizado como segundo argumento al método:

    // Espera un máximo de cinco segundos para que el selector...
    $browser->waitFor('.selector');

    // Espera un máximo de un segundo para que el selector...
    $browser->waitFor('.selector', 1);

También puedes esperar hasta que el elemento que coincide con el selector dado contenga el texto dado:

    // Espera un máximo de cinco segundos para que el selector contenga el texto dado...
    $browser->waitForTextIn('.selector', 'Hello World');

    // Espera un máximo de un segundo para que el selector contenga el texto dado...
    $browser->waitForTextIn('.selector', 'Hello World', 1);

También puedes esperar hasta que el elemento que coincide con el selector dado falte en la página:

    // Espera un máximo de cinco segundos hasta que el selector falte...
    $browser->waitUntilMissing('.selector');

    // Espera un máximo de un segundo hasta que el selector falte...
    $browser->waitUntilMissing('.selector', 1);

O, puedes esperar hasta que el elemento que coincide con el selector dado esté habilitado o deshabilitado:

    // Espera un máximo de cinco segundos hasta que el selector esté habilitado...
    $browser->waitUntilEnabled('.selector');

    // Espera un máximo de un segundo hasta que el selector esté habilitado...
    $browser->waitUntilEnabled('.selector', 1);

    // Espera un máximo de cinco segundos hasta que el selector esté deshabilitado...
    $browser->waitUntilDisabled('.selector');

    // Espera un máximo de un segundo hasta que el selector esté deshabilitado...
    $browser->waitUntilDisabled('.selector', 1);

<a name="scoping-selectors-when-available"></a>
#### Limitando Selectores Cuando Estén Disponibles

Ocasionalmente, puedes desear esperar a que aparezca un elemento que coincida con un selector dado y luego interactuar con el elemento. Por ejemplo, puedes desear esperar hasta que una ventana modal esté disponible y luego presionar el botón "OK" dentro de la modal. El método `whenAvailable` se puede usar para lograr esto. Todas las operaciones de elementos realizadas dentro de la función anónima dada estarán limitadas al selector original:

    $browser->whenAvailable('.modal', function (Browser $modal) {
        $modal->assertSee('Hello World')
              ->press('OK');
    });

<a name="waiting-for-text"></a>
#### Esperando Texto

El método `waitForText` se puede usar para esperar hasta que el texto dado se muestre en la página:

    // Espera un máximo de cinco segundos para que el texto...
    $browser->waitForText('Hello World');

    // Espera un máximo de un segundo para que el texto...
    $browser->waitForText('Hello World', 1);

Puedes usar el método `waitUntilMissingText` para esperar hasta que el texto mostrado haya sido eliminado de la página:

    // Espera un máximo de cinco segundos para que el texto sea eliminado...
    $browser->waitUntilMissingText('Hello World');

    // Espera un máximo de un segundo para que el texto sea eliminado...
    $browser->waitUntilMissingText('Hello World', 1);

<a name="waiting-for-links"></a>
#### Esperando Enlaces

El método `waitForLink` se puede usar para esperar hasta que el texto del enlace dado se muestre en la página:

    // Espera un máximo de cinco segundos para el enlace...
    $browser->waitForLink('Create');

    // Espera un máximo de un segundo para el enlace...
    $browser->waitForLink('Create', 1);

<a name="waiting-for-inputs"></a>
#### Esperando Entradas

El método `waitForInput` se puede usar para esperar hasta que el campo de entrada dado sea visible en la página:

    // Espera un máximo de cinco segundos para la entrada...
    $browser->waitForInput($field);

    // Espera un máximo de un segundo para la entrada...
    $browser->waitForInput($field, 1);

<a name="waiting-on-the-page-location"></a>
#### Esperando En La Ubicación De La Página

Al hacer una afirmación de ruta como `$browser->assertPathIs('/home')`, la afirmación puede fallar si `window.location.pathname` se está actualizando de manera asíncrona. Puedes usar el método `waitForLocation` para esperar a que la ubicación sea un valor dado:

    $browser->waitForLocation('/secret');

El método `waitForLocation` también se puede usar para esperar a que la ubicación de la ventana actual sea una URL completamente calificada:

    $browser->waitForLocation('https://example.com/path');

También puedes esperar la ubicación de una [ruta nombrada](/docs/{{version}}/routing#named-routes):

    $browser->waitForRoute($routeName, $parameters);

<a name="waiting-for-page-reloads"></a>
#### Esperando Recargas De Página

Si necesitas esperar a que una página se recargue después de realizar una acción, usa el método `waitForReload`:

    use Laravel\Dusk\Browser;

    $browser->waitForReload(function (Browser $browser) {
        $browser->press('Submit');
    })
    ->assertSee('Success!');

Dado que la necesidad de esperar a que la página se recargue ocurre típicamente después de hacer clic en un botón, puedes usar el método `clickAndWaitForReload` por conveniencia:

    $browser->clickAndWaitForReload('.selector')
            ->assertSee('something');

<a name="waiting-on-javascript-expressions"></a>
#### Esperando En Expresiones De JavaScript

A veces puedes desear pausar la ejecución de una prueba hasta que una expresión de JavaScript dada evalúe a `true`. Puedes lograr esto fácilmente usando el método `waitUntil`. Al pasar una expresión a este método, no necesitas incluir la palabra clave `return` o un punto y coma al final:

    // Espera un máximo de cinco segundos para que la expresión sea verdadera...
    $browser->waitUntil('App.data.servers.length > 0');

    // Espera un máximo de un segundo para que la expresión sea verdadera...
    $browser->waitUntil('App.data.servers.length > 0', 1);

<a name="waiting-on-vue-expressions"></a>
#### Esperando En Expresiones De Vue

Los métodos `waitUntilVue` y `waitUntilVueIsNot` se pueden usar para esperar hasta que un atributo de un [componente Vue](https://vuejs.org) tenga un valor dado:

    // Espera hasta que el atributo del componente contenga el valor dado...
    $browser->waitUntilVue('user.name', 'Taylor', '@user');

    // Espera hasta que el atributo del componente no contenga el valor dado...
    $browser->waitUntilVueIsNot('user.name', null, '@user');

<a name="waiting-for-javascript-events"></a>
#### Esperando Eventos De JavaScript

El método `waitForEvent` se puede usar para pausar la ejecución de una prueba hasta que ocurra un evento de JavaScript:

    $browser->waitForEvent('load');

El oyente de eventos se adjunta al alcance actual, que es el elemento `body` por defecto. Al usar un selector limitado, el oyente de eventos se adjuntará al elemento coincidente:

    $browser->with('iframe', function (Browser $iframe) {
        // Espera el evento de carga del iframe...
        $iframe->waitForEvent('load');
    });

También puedes proporcionar un selector como segundo argumento al método `waitForEvent` para adjuntar el oyente de eventos a un elemento específico:

    $browser->waitForEvent('load', '.selector');

También puedes esperar eventos en los objetos `document` y `window`:

    // Espera hasta que el documento se desplace...
    $browser->waitForEvent('scroll', 'document');

    // Espera un máximo de cinco segundos hasta que la ventana se redimensione...
    $browser->waitForEvent('resize', 'window', 5);

<a name="waiting-with-a-callback"></a>
#### Esperando Con Un Callback

Muchos de los métodos de "espera" en Dusk dependen del método subyacente `waitUsing`. Puedes usar este método directamente para esperar a que una función anónima dada devuelva `true`. El método `waitUsing` acepta el número máximo de segundos para esperar, el intervalo en el que se debe evaluar la función anónima, la función anónima y un mensaje de error opcional:

    $browser->waitUsing(10, 1, function () use ($something) {
        return $something->isReady();
    }, "Something wasn't ready in time.");

<a name="scrolling-an-element-into-view"></a>
### Desplazando Un Elemento A La Vista

A veces, puede que no puedas hacer clic en un elemento porque está fuera del área visible del navegador. El método `scrollIntoView` desplazará la ventana del navegador hasta que el elemento en el selector dado esté dentro de la vista:

    $browser->scrollIntoView('.selector')
            ->click('.selector');

<a name="available-assertions"></a>
## Afirmaciones Disponibles

Dusk proporciona una variedad de afirmaciones que puedes hacer contra tu aplicación. Todas las afirmaciones disponibles están documentadas en la lista a continuación:

<style>
    .collection-method-list > p {
        columns: 10.8em 3; -moz-columns: 10.8em 3; -webkit-columns: 10.8em 3;
    }

    .collection-method-list a {
        display: block;
        overflow: hidden;
        text-overflow: ellipsis;
        white-space: nowrap;
    }
</style>

<div class="collection-method-list" markdown="1">

[assertTitle](#assert-title)
[assertTitleContains](#assert-title-contains)
[assertUrlIs](#assert-url-is)
[assertSchemeIs](#assert-scheme-is)
[assertSchemeIsNot](#assert-scheme-is-not)
[assertHostIs](#assert-host-is)
[assertHostIsNot](#assert-host-is-not)
[assertPortIs](#assert-port-is)
[assertPortIsNot](#assert-port-is-not)
[assertPathBeginsWith](#assert-path-begins-with)
[assertPathEndsWith](#assert-path-ends-with)
[assertPathContains](#assert-path-contains)
[assertPathIs](#assert-path-is)
[assertPathIsNot](#assert-path-is-not)
[assertRouteIs](#assert-route-is)
[assertQueryStringHas](#assert-query-string-has)
[assertQueryStringMissing](#assert-query-string-missing)
[assertFragmentIs](#assert-fragment-is)
[assertFragmentBeginsWith](#assert-fragment-begins-with)
[assertFragmentIsNot](#assert-fragment-is-not)
[assertHasCookie](#assert-has-cookie)
[assertHasPlainCookie](#assert-has-plain-cookie)
[assertCookieMissing](#assert-cookie-missing)
[assertPlainCookieMissing](#assert-plain-cookie-missing)
[assertCookieValue](#assert-cookie-value)
[assertPlainCookieValue](#assert-plain-cookie-value)
[assertSee](#assert-see)
[assertDontSee](#assert-dont-see)
[assertSeeIn](#assert-see-in)
[assertDontSeeIn](#assert-dont-see-in)
[assertSeeAnythingIn](#assert-see-anything-in)
[assertSeeNothingIn](#assert-see-nothing-in)
[assertScript](#assert-script)
[assertSourceHas](#assert-source-has)
[assertSourceMissing](#assert-source-missing)
[assertSeeLink](#assert-see-link)
[assertDontSeeLink](#assert-dont-see-link)
[assertInputValue](#assert-input-value)
[assertInputValueIsNot](#assert-input-value-is-not)
[assertChecked](#assert-checked)
[assertNotChecked](#assert-not-checked)
[assertIndeterminate](#assert-indeterminate)
[assertRadioSelected](#assert-radio-selected)
[assertRadioNotSelected](#assert-radio-not-selected)
[assertSelected](#assert-selected)
[assertNotSelected](#assert-not-selected)
[assertSelectHasOptions](#assert-select-has-options)
[assertSelectMissingOptions](#assert-select-missing-options)
[assertSelectHasOption](#assert-select-has-option)
[assertSelectMissingOption](#assert-select-missing-option)
[assertValue](#assert-value)
[assertValueIsNot](#assert-value-is-not)
[assertAttribute](#assert-attribute)
[assertAttributeContains](#assert-attribute-contains)
[assertAttributeDoesntContain](#assert-attribute-doesnt-contain)
[assertAriaAttribute](#assert-aria-attribute)
[assertDataAttribute](#assert-data-attribute)
[assertVisible](#assert-visible)
[assertPresent](#assert-present)
[assertNotPresent](#assert-not-present)
[assertMissing](#assert-missing)
[assertInputPresent](#assert-input-present)
[assertInputMissing](#assert-input-missing)
[assertDialogOpened](#assert-dialog-opened)
[assertEnabled](#assert-enabled)
[assertDisabled](#assert-disabled)
[assertButtonEnabled](#assert-button-enabled)
[assertButtonDisabled](#assert-button-disabled)
[assertFocused](#assert-focused)
[assertNotFocused](#assert-not-focused)
[assertAuthenticated](#assert-authenticated)
[assertGuest](#assert-guest)
[assertAuthenticatedAs](#assert-authenticated-as)
[assertVue](#assert-vue)
[assertVueIsNot](#assert-vue-is-not)
[assertVueContains](#assert-vue-contains)
[assertVueDoesntContain](#assert-vue-doesnt-contain)

</div>

<a name="assert-title"></a>
#### assertTitle

Asegúrate de que el título de la página coincida con el texto dado:

    $browser->assertTitle($title);

<a name="assert-title-contains"></a>
#### assertTitleContains

Asegúrate de que el título de la página contenga el texto dado:

    $browser->assertTitleContains($title);

<a name="assert-url-is"></a>
#### assertUrlIs

Asegúrate de que la URL actual (sin la cadena de consulta) coincida con la cadena dada:

    $browser->assertUrlIs($url);

<a name="assert-scheme-is"></a>
#### assertSchemeIs

Asegúrate de que el esquema de la URL actual coincida con el esquema dado:

    $browser->assertSchemeIs($scheme);

<a name="assert-scheme-is-not"></a>
#### assertSchemeIsNot

Asegúrate de que el esquema de la URL actual no coincida con el esquema dado:

    $browser->assertSchemeIsNot($scheme);

<a name="assert-host-is"></a>
#### assertHostIs

Asegúrate de que el host de la URL actual coincida con el host dado:

    $browser->assertHostIs($host);

<a name="assert-host-is-not"></a>
#### assertHostIsNot

Asegúrate de que el host de la URL actual no coincida con el host dado:

    $browser->assertHostIsNot($host);

<a name="assert-port-is"></a>
#### assertPortIs

Asegúrate de que el puerto de la URL actual coincida con el puerto dado:

    $browser->assertPortIs($port);

<a name="assert-port-is-not"></a>
#### assertPortIsNot

Asegúrate de que el puerto de la URL actual no coincida con el puerto dado:

    $browser->assertPortIsNot($port);

<a name="assert-path-begins-with"></a>
#### assertPathBeginsWith

Asegúrate de que la ruta de la URL actual comience con la ruta dada:

    $browser->assertPathBeginsWith('/home');

<a name="assert-path-ends-with"></a>
#### assertPathEndsWith

Asegúrate de que la ruta de la URL actual termine con la ruta dada:

    $browser->assertPathEndsWith('/home');

<a name="assert-path-contains"></a>
#### assertPathContains

Asegúrate de que la ruta de la URL actual contenga la ruta dada:

    $browser->assertPathContains('/home');

<a name="assert-path-is"></a>
#### assertPathIs

Asegúrate de que la ruta actual coincida con la ruta dada:

    $browser->assertPathIs('/home');

<a name="assert-path-is-not"></a>
#### assertPathIsNot

Asegúrate de que la ruta actual no coincida con la ruta dada:

    $browser->assertPathIsNot('/home');

<a name="assert-route-is"></a>
#### assertRouteIs

Asegúrate de que la URL actual coincida con la URL de la [ruta nombrada](/docs/{{version}}/routing#named-routes):

    $browser->assertRouteIs($name, $parameters);

<a name="assert-query-string-has"></a>
#### assertQueryStringHas

Asegúrate de que el parámetro de cadena de consulta dado esté presente:

    $browser->assertQueryStringHas($name);

Asegúrate de que el parámetro de cadena de consulta dado esté presente y tenga un valor dado:

    $browser->assertQueryStringHas($name, $value);

<a name="assert-query-string-missing"></a>
#### assertQueryStringMissing

Asegúrate de que el parámetro de cadena de consulta dado esté ausente:

    $browser->assertQueryStringMissing($name);

<a name="assert-fragment-is"></a>
#### assertFragmentIs

Asegúrate de que el fragmento hash actual de la URL coincida con el fragmento dado:

    $browser->assertFragmentIs('anchor');

<a name="assert-fragment-begins-with"></a>
#### assertFragmentBeginsWith

Asegúrate de que el fragmento hash actual de la URL comience con el fragmento dado:

    $browser->assertFragmentBeginsWith('anchor');

<a name="assert-fragment-is-not"></a>
#### assertFragmentIsNot

Asegúrate de que el fragmento hash actual de la URL no coincida con el fragmento dado:

    $browser->assertFragmentIsNot('anchor');

<a name="assert-has-cookie"></a>
#### assertHasCookie

Asegúrate de que la cookie cifrada dada esté presente:

    $browser->assertHasCookie($name);

<a name="assert-has-plain-cookie"></a>
#### assertHasPlainCookie

Asegúrate de que la cookie no cifrada dada esté presente:

    $browser->assertHasPlainCookie($name);

<a name="assert-cookie-missing"></a>
#### assertCookieMissing

Asegúrate de que la cookie cifrada dada no esté presente:

    $browser->assertCookieMissing($name);

<a name="assert-plain-cookie-missing"></a>
#### assertPlainCookieMissing

Asegúrate de que la cookie no cifrada dada no esté presente:

    $browser->assertPlainCookieMissing($name);

<a name="assert-cookie-value"></a>
#### assertCookieValue

Asegúrate de que una cookie cifrada tenga un valor dado:

    $browser->assertCookieValue($name, $value);

<a name="assert-plain-cookie-value"></a>
#### assertPlainCookieValue

Asegúrate de que una cookie no cifrada tenga un valor dado:

    $browser->assertPlainCookieValue($name, $value);

<a name="assert-see"></a>
#### assertSee

Asegúrate de que el texto dado esté presente en la página:

    $browser->assertSee($text);

<a name="assert-dont-see"></a>
#### assertDontSee

Asegúrate de que el texto dado no esté presente en la página:

    $browser->assertDontSee($text);

<a name="assert-see-in"></a>
#### assertSeeIn

Asegúrate de que el texto dado esté presente dentro del selector:

    $browser->assertSeeIn($selector, $text);

<a name="assert-dont-see-in"></a>
#### assertDontSeeIn

Asegúrate de que el texto dado no esté presente dentro del selector:

    $browser->assertDontSeeIn($selector, $text);

<a name="assert-see-anything-in"></a>
#### assertSeeAnythingIn

Asegúrate de que cualquier texto esté presente dentro del selector:

    $browser->assertSeeAnythingIn($selector);

<a name="assert-see-nothing-in"></a>
#### assertSeeNothingIn

Asegúrate de que no haya texto presente dentro del selector:

    $browser->assertSeeNothingIn($selector);

<a name="assert-script"></a>
#### assertScript

Asegúrate de que la expresión JavaScript dada evalúe al valor dado:

    $browser->assertScript('window.isLoaded')
            ->assertScript('document.readyState', 'complete');

<a name="assert-source-has"></a>
#### assertSourceHas

Asegúrate de que el código fuente dado esté presente en la página:

    $browser->assertSourceHas($code);

<a name="assert-source-missing"></a>
#### assertSourceMissing

Asegúrate de que el código fuente dado no esté presente en la página:

    $browser->assertSourceMissing($code);

<a name="assert-see-link"></a>
#### assertSeeLink

Asegúrate de que el enlace dado esté presente en la página:

    $browser->assertSeeLink($linkText);

<a name="assert-dont-see-link"></a>
#### assertDontSeeLink

Asegúrate de que el enlace dado no esté presente en la página:

    $browser->assertDontSeeLink($linkText);

<a name="assert-input-value"></a>
#### assertInputValue

Asegúrate de que el campo de entrada dado tenga el valor dado:

    $browser->assertInputValue($field, $value);

<a name="assert-input-value-is-not"></a>
#### assertInputValueIsNot

Asegúrate de que el campo de entrada dado no tenga el valor dado:

    $browser->assertInputValueIsNot($field, $value);

<a name="assert-checked"></a>
#### assertChecked

Asegúrate de que la casilla de verificación dada esté marcada:

    $browser->assertChecked($field);

<a name="assert-not-checked"></a>
#### assertNotChecked

Asegúrate de que la casilla de verificación dada no esté marcada:

    $browser->assertNotChecked($field);

<a name="assert-indeterminate"></a>
#### assertIndeterminate

Asegúrate de que la casilla de verificación dada esté en un estado indeterminado:

    $browser->assertIndeterminate($field);

<a name="assert-radio-selected"></a>
#### assertRadioSelected

Asegúrate de que el campo de radio dado esté seleccionado:

    $browser->assertRadioSelected($field, $value);

<a name="assert-radio-not-selected"></a>
#### assertRadioNotSelected

Asegúrate de que el campo de radio dado no esté seleccionado:

    $browser->assertRadioNotSelected($field, $value);

<a name="assert-selected"></a>
#### assertSelected

Asegúrate de que el desplegable dado tenga el valor dado seleccionado:

    $browser->assertSelected($field, $value);

<a name="assert-not-selected"></a>
#### assertNotSelected

Asegúrate de que el desplegable dado no tenga el valor dado seleccionado:

    $browser->assertNotSelected($field, $value);

<a name="assert-select-has-options"></a>
#### assertSelectHasOptions

Asegúrate de que el array de valores dado esté disponible para ser seleccionado:

    $browser->assertSelectHasOptions($field, $values);

<a name="assert-select-missing-options"></a>
#### assertSelectMissingOptions

Asegúrate de que el array de valores dado no esté disponible para ser seleccionado:

    $browser->assertSelectMissingOptions($field, $values);

<a name="assert-select-has-option"></a>
#### assertSelectHasOption

Asegúrate de que el valor dado esté disponible para ser seleccionado en el campo dado:

    $browser->assertSelectHasOption($field, $value);

<a name="assert-select-missing-option"></a>
#### assertSelectMissingOption

Asegúrate de que el valor dado no esté disponible para ser seleccionado:

    $browser->assertSelectMissingOption($field, $value);

<a name="assert-value"></a>
#### assertValue

Asegúrate de que el elemento que coincide con el selector dado tenga el valor dado:

    $browser->assertValue($selector, $value);

<a name="assert-value-is-not"></a>
#### assertValueIsNot

Asegúrate de que el elemento que coincide con el selector dado no tenga el valor dado:

    $browser->assertValueIsNot($selector, $value);

<a name="assert-attribute"></a>
#### assertAttribute

Asegúrate de que el elemento que coincide con el selector dado tenga el valor dado en el atributo proporcionado:

    $browser->assertAttribute($selector, $attribute, $value);

<a name="assert-attribute-contains"></a>
#### assertAttributeContains

Asegúrate de que el elemento que coincide con el selector dado contenga el valor dado en el atributo proporcionado:

    $browser->assertAttributeContains($selector, $attribute, $value);

<a name="assert-attribute-doesnt-contain"></a>
#### assertAttributeDoesntContain

Asegúrate de que el elemento que coincide con el selector dado no contenga el valor dado en el atributo proporcionado:

    $browser->assertAttributeDoesntContain($selector, $attribute, $value);

<a name="assert-aria-attribute"></a>
#### assertAriaAttribute

Asegúrate de que el elemento que coincide con el selector dado tenga el valor dado en el atributo aria proporcionado:

    $browser->assertAriaAttribute($selector, $attribute, $value);

Por ejemplo, dado el marcado `<button aria-label="Add"></button>`, puedes afirmar contra el atributo `aria-label` así:

    $browser->assertAriaAttribute('button', 'label', 'Add')

<a name="assert-data-attribute"></a>
#### assertDataAttribute

Asegúrate de que el elemento que coincide con el selector dado tenga el valor dado en el atributo de datos proporcionado:

    $browser->assertDataAttribute($selector, $attribute, $value);

Por ejemplo, dado el marcado `<tr id="row-1" data-content="attendees"></tr>`, puedes afirmar contra el atributo `data-label` así:

    $browser->assertDataAttribute('#row-1', 'content', 'attendees')

<a name="assert-visible"></a>
#### assertVisible

Asegúrate de que el elemento que coincide con el selector dado sea visible:

    $browser->assertVisible($selector);

<a name="assert-present"></a>
#### assertPresent

Asegúrate de que el elemento que coincide con el selector dado esté presente en el código fuente:

    $browser->assertPresent($selector);

<a name="assert-not-present"></a>
#### assertNotPresent

Asegúrate de que el elemento que coincide con el selector dado no esté presente en el código fuente:

    $browser->assertNotPresent($selector);

<a name="assert-missing"></a>
#### assertMissing

Asegúrate de que el elemento que coincide con el selector dado no sea visible:

    $browser->assertMissing($selector);

<a name="assert-input-present"></a>
#### assertInputPresent

Asegúrate de que un input con el nombre dado esté presente:

    $browser->assertInputPresent($name);

<a name="assert-input-missing"></a>
#### assertInputMissing

Asegúrate de que un input con el nombre dado no esté presente en el código fuente:

    $browser->assertInputMissing($name);

<a name="assert-dialog-opened"></a>
#### assertDialogOpened

Asegúrate de que un diálogo de JavaScript con el mensaje dado se haya abierto:

    $browser->assertDialogOpened($message);

<a name="assert-enabled"></a>
#### assertEnabled

Asegúrate de que el campo dado esté habilitado:

    $browser->assertEnabled($field);

<a name="assert-disabled"></a>
#### assertDisabled

Asegúrate de que el campo dado esté deshabilitado:

    $browser->assertDisabled($field);

<a name="assert-button-enabled"></a>
#### assertButtonEnabled

Asegúrate de que el botón dado esté habilitado:

    $browser->assertButtonEnabled($button);

<a name="assert-button-disabled"></a>
#### assertButtonDisabled

Asegúrate de que el botón dado esté deshabilitado:

    $browser->assertButtonDisabled($button);

<a name="assert-focused"></a>
#### assertFocused

Asegúrate de que el campo dado esté enfocado:

    $browser->assertFocused($field);

<a name="assert-not-focused"></a>
#### assertNotFocused

Asegúrate de que el campo dado no esté enfocado:

    $browser->assertNotFocused($field);

<a name="assert-authenticated"></a>
#### assertAuthenticated

Asegúrate de que el usuario esté autenticado:

    $browser->assertAuthenticated();

<a name="assert-guest"></a>
#### assertGuest

Asegúrate de que el usuario no esté autenticado:

    $browser->assertGuest();

<a name="assert-authenticated-as"></a>
#### assertAuthenticatedAs

Asegúrate de que el usuario esté autenticado como el usuario dado:

    $browser->assertAuthenticatedAs($user);

<a name="assert-vue"></a>
#### assertVue

Dusk incluso te permite hacer afirmaciones sobre el estado de los datos de un [componente Vue](https://vuejs.org). Por ejemplo, imagina que tu aplicación contiene el siguiente componente Vue:

    // HTML...

    <profile dusk="profile-component"></profile>

    // Definición del Componente...

    Vue.component('profile', {
        template: '<div>{{ user.name }}</div>',

        data: function () {
            return {
                user: {
                    name: 'Taylor'
                }
            };
        }
    });

Puedes afirmar sobre el estado del componente Vue así:

```php tab=Pest
test('vue', function () {
    $this->browse(function (Browser $browser) {
        $browser->visit('/')
                ->assertVue('user.name', 'Taylor', '@profile-component');
    });
});
```

```php tab=PHPUnit
/**
 * A basic Vue test example.
 */
public function test_vue(): void
{
    $this->browse(function (Browser $browser) {
        $browser->visit('/')
                ->assertVue('user.name', 'Taylor', '@profile-component');
    });
}
```

<a name="assert-vue-is-not"></a>
#### assertVueIsNot

Asegúrate de que una propiedad de datos de un componente Vue dado no coincida con el valor dado:

    $browser->assertVueIsNot($property, $value, $componentSelector = null);

<a name="assert-vue-contains"></a>
#### assertVueContains

Asegúrate de que una propiedad de datos de un componente Vue dado sea un array y contenga el valor dado:

    $browser->assertVueContains($property, $value, $componentSelector = null);

<a name="assert-vue-doesnt-contain"></a>
#### assertVueDoesntContain

Asegúrate de que una propiedad de datos de un componente Vue dado sea un array y no contenga el valor dado:

    $browser->assertVueDoesntContain($property, $value, $componentSelector = null);

<a name="pages"></a>
## Pages

A veces, las pruebas requieren que se realicen varias acciones complicadas en secuencia. Esto puede hacer que tus pruebas sean más difíciles de leer y entender. Las Páginas de Dusk te permiten definir acciones expresivas que luego pueden ser realizadas en una página dada a través de un solo método. Las Páginas también te permiten definir accesos directos a selectores comunes para tu aplicación o para una sola página.

<a name="generating-pages"></a>
### Generating Pages

Para generar un objeto de página, ejecuta el comando Artisan `dusk:page`. Todos los objetos de página se colocarán en el directorio `tests/Browser/Pages` de tu aplicación:

    php artisan dusk:page Login

<a name="configuring-pages"></a>
### Configuring Pages

Por defecto, las páginas tienen tres métodos: `url`, `assert` y `elements`. Discutiremos los métodos `url` y `assert` ahora. El método `elements` se [discutirá en más detalle a continuación](#shorthand-selectors).

<a name="the-url-method"></a>
#### The `url` Method

El método `url` debe devolver la ruta de la URL que representa la página. Dusk utilizará esta URL al navegar a la página en el navegador:

```php
    /**
     * Obtener la URL para la página.
     */
    public function url(): string
    {
        return '/login';
    }

<a name="the-assert-method"></a>
#### El Método `assert`

El método `assert` puede hacer cualquier afirmación necesaria para verificar que el navegador está realmente en la página dada. No es realmente necesario colocar nada dentro de este método; sin embargo, eres libre de hacer estas afirmaciones si lo deseas. Estas afirmaciones se ejecutarán automáticamente al navegar a la página:

    /**
     * Afirmar que el navegador está en la página.
     */
    public function assert(Browser $browser): void
    {
        $browser->assertPathIs($this->url());
    }

<a name="navigating-to-pages"></a>
### Navegando a Páginas

Una vez que se ha definido una página, puedes navegar a ella utilizando el método `visit`:

    use Tests\Browser\Pages\Login;

    $browser->visit(new Login);

A veces, ya puedes estar en una página dada y necesitar "cargar" los selectores y métodos de la página en el contexto de prueba actual. Esto es común al presionar un botón y ser redirigido a una página dada sin navegar explícitamente a ella. En esta situación, puedes usar el método `on` para cargar la página:

    use Tests\Browser\Pages\CreatePlaylist;

    $browser->visit('/dashboard')
            ->clickLink('Create Playlist')
            ->on(new CreatePlaylist)
            ->assertSee('@create');

<a name="shorthand-selectors"></a>
### Selectores Abreviados

El método `elements` dentro de las clases de página te permite definir accesos directos rápidos y fáciles de recordar para cualquier selector CSS en tu página. Por ejemplo, definamos un acceso directo para el campo de entrada "email" de la página de inicio de sesión de la aplicación:

    /**
     * Obtener los accesos directos de elementos para la página.
     *
     * @return array<string, string>
     */
    public function elements(): array
    {
        return [
            '@email' => 'input[name=email]',
        ];
    }

Una vez que se ha definido el acceso directo, puedes usar el selector abreviado en cualquier lugar donde normalmente usarías un selector CSS completo:

    $browser->type('@email', 'taylor@laravel.com');

<a name="global-shorthand-selectors"></a>
#### Selectores Abreviados Globales

Después de instalar Dusk, se colocará una clase base `Page` en tu directorio `tests/Browser/Pages`. Esta clase contiene un método `siteElements` que se puede usar para definir selectores abreviados globales que deberían estar disponibles en cada página de tu aplicación:

    /**
     * Obtener los accesos directos de elementos globales para el sitio.
     *
     * @return array<string, string>
     */
    public static function siteElements(): array
    {
        return [
            '@element' => '#selector',
        ];
    }

<a name="page-methods"></a>
### Métodos de Página

Además de los métodos predeterminados definidos en las páginas, puedes definir métodos adicionales que se pueden usar en todas tus pruebas. Por ejemplo, imaginemos que estamos construyendo una aplicación de gestión de música. Una acción común para una página de la aplicación podría ser crear una lista de reproducción. En lugar de reescribir la lógica para crear una lista de reproducción en cada prueba, puedes definir un método `createPlaylist` en una clase de página:

    <?php

    namespace Tests\Browser\Pages;

    use Laravel\Dusk\Browser;
    use Laravel\Dusk\Page;

    class Dashboard extends Page
    {
        // Otros métodos de página...

        /**
         * Crear una nueva lista de reproducción.
         */
        public function createPlaylist(Browser $browser, string $name): void
        {
            $browser->type('name', $name)
                    ->check('share')
                    ->press('Create Playlist');
        }
    }

Una vez que se ha definido el método, puedes usarlo dentro de cualquier prueba que utilice la página. La instancia del navegador se pasará automáticamente como el primer argumento a los métodos de página personalizados:

    use Tests\Browser\Pages\Dashboard;

    $browser->visit(new Dashboard)
            ->createPlaylist('My Playlist')
            ->assertSee('My Playlist');

<a name="components"></a>
## Componentes

Los componentes son similares a los "objetos de página" de Dusk, pero están destinados a piezas de UI y funcionalidad que se reutilizan en toda tu aplicación, como una barra de navegación o una ventana de notificación. Como tal, los componentes no están vinculados a URL específicas.

<a name="generating-components"></a>
### Generando Componentes

Para generar un componente, ejecuta el comando Artisan `dusk:component`. Los nuevos componentes se colocan en el directorio `tests/Browser/Components`:

    php artisan dusk:component DatePicker

Como se muestra arriba, un "selector de fecha" es un ejemplo de un componente que podría existir en toda tu aplicación en una variedad de páginas. Puede volverse engorroso escribir manualmente la lógica de automatización del navegador para seleccionar una fecha en docenas de pruebas en toda tu suite de pruebas. En su lugar, podemos definir un componente Dusk para representar el selector de fecha, lo que nos permite encapsular esa lógica dentro del componente:

    <?php

    namespace Tests\Browser\Components;

    use Laravel\Dusk\Browser;
    use Laravel\Dusk\Component as BaseComponent;

    class DatePicker extends BaseComponent
    {
        /**
         * Obtener el selector raíz para el componente.
         */
        public function selector(): string
        {
            return '.date-picker';
        }

        /**
         * Afirmar que la página del navegador contiene el componente.
         */
        public function assert(Browser $browser): void
        {
            $browser->assertVisible($this->selector());
        }

        /**
         * Obtener los accesos directos de elementos para el componente.
         *
         * @return array<string, string>
         */
        public function elements(): array
        {
            return [
                '@date-field' => 'input.datepicker-input',
                '@year-list' => 'div > div.datepicker-years',
                '@month-list' => 'div > div.datepicker-months',
                '@day-list' => 'div > div.datepicker-days',
            ];
        }

        /**
         * Seleccionar la fecha dada.
         */
        public function selectDate(Browser $browser, int $year, int $month, int $day): void
        {
            $browser->click('@date-field')
                    ->within('@year-list', function (Browser $browser) use ($year) {
                        $browser->click($year);
                    })
                    ->within('@month-list', function (Browser $browser) use ($month) {
                        $browser->click($month);
                    })
                    ->within('@day-list', function (Browser $browser) use ($day) {
                        $browser->click($day);
                    });
        }
    }

<a name="using-components"></a>
### Usando Componentes

Una vez que se ha definido el componente, podemos seleccionar fácilmente una fecha dentro del selector de fecha desde cualquier prueba. Y, si la lógica necesaria para seleccionar una fecha cambia, solo necesitamos actualizar el componente:

```php tab=Pest
<?php

use Illuminate\Foundation\Testing\DatabaseMigrations;
use Laravel\Dusk\Browser;
use Tests\Browser\Components\DatePicker;

uses(DatabaseMigrations::class);

test('basic example', function () {
    $this->browse(function (Browser $browser) {
        $browser->visit('/')
                ->within(new DatePicker, function (Browser $browser) {
                    $browser->selectDate(2019, 1, 30);
                })
                ->assertSee('January');
    });
});
```

```php tab=PHPUnit
<?php

namespace Tests\Browser;

use Illuminate\Foundation\Testing\DatabaseMigrations;
use Laravel\Dusk\Browser;
use Tests\Browser\Components\DatePicker;
use Tests\DuskTestCase;

class ExampleTest extends DuskTestCase
{
    /**
     * A basic component test example.
     */
    public function test_basic_example(): void
    {
        $this->browse(function (Browser $browser) {
            $browser->visit('/')
                    ->within(new DatePicker, function (Browser $browser) {
                        $browser->selectDate(2019, 1, 30);
                    })
                    ->assertSee('January');
        });
    }
}
```

<a name="continuous-integration"></a>
## Integración Continua

> [!WARNING]  
> La mayoría de las configuraciones de integración continua de Dusk esperan que tu aplicación Laravel se sirva utilizando el servidor de desarrollo PHP integrado en el puerto 8000. Por lo tanto, antes de continuar, debes asegurarte de que tu entorno de integración continua tenga un valor de variable de entorno `APP_URL` de `http://127.0.0.1:8000`.

<a name="running-tests-on-heroku-ci"></a>
### Heroku CI

Para ejecutar pruebas Dusk en [Heroku CI](https://www.heroku.com/continuous-integration), agrega el siguiente buildpack de Google Chrome y scripts a tu archivo `app.json` de Heroku:

    {
      "environments": {
        "test": {
          "buildpacks": [
            { "url": "heroku/php" },
            { "url": "https://github.com/heroku/heroku-buildpack-google-chrome" }
          ],
          "scripts": {
            "test-setup": "cp .env.testing .env",
            "test": "nohup bash -c './vendor/laravel/dusk/bin/chromedriver-linux > /dev/null 2>&1 &' && nohup bash -c 'php artisan serve --no-reload > /dev/null 2>&1 &' && php artisan dusk"
          }
        }
      }
    }

<a name="running-tests-on-travis-ci"></a>
### Travis CI

Para ejecutar tus pruebas Dusk en [Travis CI](https://travis-ci.org), utiliza la siguiente configuración de `.travis.yml`. Dado que Travis CI no es un entorno gráfico, necesitaremos tomar algunos pasos adicionales para lanzar un navegador Chrome. Además, utilizaremos `php artisan serve` para lanzar el servidor web integrado de PHP:

```yaml
language: php

php:
  - 7.3

addons:
  chrome: stable

install:
  - cp .env.testing .env
  - travis_retry composer install --no-interaction --prefer-dist
  - php artisan key:generate
  - php artisan dusk:chrome-driver

before_script:
  - google-chrome-stable --headless --disable-gpu --remote-debugging-port=9222 http://localhost &
  - php artisan serve --no-reload &

script:
  - php artisan dusk
```

<a name="running-tests-on-github-actions"></a>
### GitHub Actions

Si estás utilizando [GitHub Actions](https://github.com/features/actions) para ejecutar tus pruebas Dusk, puedes usar el siguiente archivo de configuración como punto de partida. Al igual que TravisCI, utilizaremos el comando `php artisan serve` para lanzar el servidor web integrado de PHP:

```yaml
name: CI
on: [push]
jobs:

  dusk-php:
    runs-on: ubuntu-latest
    env:
      APP_URL: "http://127.0.0.1:8000"
      DB_USERNAME: root
      DB_PASSWORD: root
      MAIL_MAILER: log
    steps:
      - uses: actions/checkout@v4
      - name: Prepare The Environment
        run: cp .env.example .env
      - name: Create Database
        run: |
          sudo systemctl start mysql
          mysql --user="root" --password="root" -e "CREATE DATABASE \`my-database\` character set UTF8mb4 collate utf8mb4_bin;"
      - name: Install Composer Dependencies
        run: composer install --no-progress --prefer-dist --optimize-autoloader
      - name: Generate Application Key
        run: php artisan key:generate
      - name: Upgrade Chrome Driver
        run: php artisan dusk:chrome-driver --detect
      - name: Start Chrome Driver
        run: ./vendor/laravel/dusk/bin/chromedriver-linux &
      - name: Run Laravel Server
        run: php artisan serve --no-reload &
      - name: Run Dusk Tests
        run: php artisan dusk
      - name: Upload Screenshots
        if: failure()
        uses: actions/upload-artifact@v2
        with:
          name: screenshots
          path: tests/Browser/screenshots
      - name: Upload Console Logs
        if: failure()
        uses: actions/upload-artifact@v2
        with:
          name: console
          path: tests/Browser/console
```

<a name="running-tests-on-chipper-ci"></a>
### Chipper CI

Si estás utilizando [Chipper CI](https://chipperci.com) para ejecutar tus pruebas Dusk, puedes usar el siguiente archivo de configuración como punto de partida. Utilizaremos el servidor integrado de PHP para ejecutar Laravel para que podamos escuchar solicitudes:

```yaml
# file .chipperci.yml
version: 1

environment:
  php: 8.2
  node: 16

# Include Chrome in the build environment
services:
  - dusk

# Build all commits
on:
   push:
      branches: .*

pipeline:
  - name: Setup
    cmd: |
      cp -v .env.example .env
      composer install --no-interaction --prefer-dist --optimize-autoloader
      php artisan key:generate

      # Create a dusk env file, ensuring APP_URL uses BUILD_HOST
      cp -v .env .env.dusk.ci
      sed -i "s@APP_URL=.*@APP_URL=http://$BUILD_HOST:8000@g" .env.dusk.ci

  - name: Compile Assets
    cmd: |
      npm ci --no-audit
      npm run build

  - name: Browser Tests
    cmd: |
      php -S [::0]:8000 -t public 2>server.log &
      sleep 2
      php artisan dusk:chrome-driver $CHROME_DRIVER
      php artisan dusk --env=ci
```

Para aprender más sobre cómo ejecutar pruebas Dusk en Chipper CI, incluyendo cómo usar bases de datos, consulta la [documentación oficial de Chipper CI](https://chipperci.com/docs/testing/laravel-dusk-new/).
```
