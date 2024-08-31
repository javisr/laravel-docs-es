# Laravel Dusk

- [Introducción](#introduction)
- [Instalación](#installation)
  - [Gestión de Instalaciones de ChromeDriver](#managing-chromedriver-installations)
  - [Usando Otros Navegadores](#using-other-browsers)
- [Comenzando](#getting-started)
  - [Generando Pruebas](#generating-tests)
  - [Reiniciando la Base de Datos Después de Cada Prueba](#resetting-the-database-after-each-test)
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
  - [Almacenando Salida de la Consola en Disco](#storing-console-output-to-disk)
  - [Almacenando Fuente de la Página en Disco](#storing-page-source-to-disk)
- [Interactuando con Elementos](#interacting-with-elements)
  - [Selectores de Dusk](#dusk-selectors)
  - [Texto, Valores y Atributos](#text-values-and-attributes)
  - [Interactuando con Formularios](#interacting-with-forms)
  - [Adjuntando Archivos](#attaching-files)
  - [Presionando Botones](#pressing-buttons)
  - [Haciendo Clic en Enlaces](#clicking-links)
  - [Usando el Teclado](#using-the-keyboard)
  - [Usando el Ratón](#using-the-mouse)
  - [Diálogos de JavaScript](#javascript-dialogs)
  - [Interactuando con IFrames](#interacting-with-iframes)
  - [Scoping Selectors](#scoping-selectors)
  - [Esperando Elementos](#waiting-for-elements)
  - [Desplazando un Elemento a la Vista](#scrolling-an-element-into-view)
- [Afirmaciones Disponibles](#available-assertions)
- [Páginas](#pages)
  - [Generando Páginas](#generating-pages)
  - [Configurando Páginas](#configuring-pages)
  - [Navegando a Páginas](#navigating-to-pages)
  - [Selectores Cortos](#shorthand-selectors)
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

[Laravel Dusk](https://github.com/laravel/dusk) proporciona una API de automatización y prueba de navegador expresiva y fácil de usar. Por defecto, Dusk no requiere que instales JDK o Selenium en tu computadora local. En su lugar, Dusk utiliza una instalación independiente de [ChromeDriver](https://sites.google.com/chromium.org/driver). Sin embargo, puedes utilizar cualquier otro driver compatible con Selenium que desees.

<a name="installation"></a>
## Instalación

Para comenzar, deberías instalar [Google Chrome](https://www.google.com/chrome) y añadir la dependencia de Composer `laravel/dusk` a tu proyecto:


```shell
composer require laravel/dusk --dev

```
> [!WARNING]
Si estás registrando manualmente el proveedor de servicios de Dusk, **nunca** debes registrarlo en tu entorno de producción, ya que hacerlo podría permitir que usuarios arbitrarios se autentiquen con tu aplicación.
Después de instalar el paquete Dusk, ejecuta el comando Artisan `dusk:install`. El comando `dusk:install` creará un directorio `tests/Browser`, un ejemplo de prueba Dusk, e instalará el binario del Chrome Driver para tu sistema operativo:


```shell
php artisan dusk:install

```
A continuación, establece la variable de entorno `APP_URL` en el archivo `.env` de tu aplicación. Este valor debe coincidir con la URL que utilizas para acceder a tu aplicación en un navegador.
> [!NOTE]
Si estás utilizando [Laravel Sail](/docs/%7B%7Bversion%7D%7D/sail) para gestionar tu entorno de desarrollo local, consulta también la documentación de Sail sobre [configuración y ejecución de pruebas Dusk](/docs/%7B%7Bversion%7D%7D/sail#laravel-dusk).

<a name="managing-chromedriver-installations"></a>
### Gestión de Instalaciones de ChromeDriver

Si deseas instalar una versión diferente de ChromeDriver a la que se instala por Laravel Dusk a través del comando `dusk:install`, puedes usar el comando `dusk:chrome-driver`:


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
Dusk requiere que los binarios de `chromedriver` sean ejecutables. Si tienes problemas para ejecutar Dusk, debes asegurarte de que los binarios sean ejecutables utilizando el siguiente comando: `chmod -R 0755 vendor/laravel/dusk/bin/`.

<a name="using-other-browsers"></a>
### Usando Otros Navegadores

Por defecto, Dusk utiliza Google Chrome y una instalación independiente de [ChromeDriver](https://sites.google.com/chromium.org/driver) para ejecutar tus pruebas de navegador. Sin embargo, puedes iniciar tu propio servidor Selenium y ejecutar tus pruebas en cualquier navegador que desees.
Para empezar, abre tu archivo `tests/DuskTestCase.php`, que es el caso de prueba base de Dusk para tu aplicación. Dentro de este archivo, puedes eliminar la llamada al método `startChromeDriver`. Esto evitará que Dusk inicie automáticamente el ChromeDriver:
A continuación, puedes modificar el método `driver` para conectarte a la URL y el puerto de tu elección. Además, puedes modificar las "capacidades deseadas" que deben pasarse al WebDriver:


```php
use Facebook\WebDriver\Remote\RemoteWebDriver;

/**
 * Create the RemoteWebDriver instance.
 */
protected function driver(): RemoteWebDriver
{
    return RemoteWebDriver::create(
        'http://localhost:4444/wd/hub', DesiredCapabilities::phantomjs()
    );
}
```

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

La mayoría de las pruebas que escribas interactuarán con páginas que recuperan datos de la base de datos de tu aplicación; sin embargo, tus pruebas Dusk nunca deben usar el rasgo `RefreshDatabase`. El rasgo `RefreshDatabase` aprovecha las transacciones de base de datos, que no serán aplicables o disponibles a través de solicitudes HTTP. En su lugar, tienes dos opciones: el rasgo `DatabaseMigrations` y el rasgo `DatabaseTruncation`.

<a name="reset-migrations"></a>
#### Usando Migraciones de Base de Datos

El trait `DatabaseMigrations` ejecutará tus migraciones de base de datos antes de cada prueba. Sin embargo, eliminar y volver a crear tus tablas de base de datos para cada prueba suele ser más lento que truncar las tablas:


```php
<?php

use Illuminate\Foundation\Testing\DatabaseMigrations;
use Laravel\Dusk\Browser;

uses(DatabaseMigrations::class);

//

```


```php
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
Las bases de datos en memoria de SQLite no pueden usarse al ejecutar pruebas de Dusk. Dado que el navegador se ejecuta en su propio proceso, no podrá acceder a las bases de datos en memoria de otros procesos.

<a name="reset-truncation"></a>
#### Uso de Truncamiento de Base de Datos

El trait `DatabaseTruncation` migrará tu base de datos en la primera prueba para asegurarse de que las tablas de tu base de datos se hayan creado correctamente. Sin embargo, en pruebas posteriores, las tablas de la base de datos simplemente se truncarán, lo que proporcionará un aumento de velocidad en comparación con la ejecución de todas tus migraciones de base de datos nuevamente:


```php
<?php

use Illuminate\Foundation\Testing\DatabaseTruncation;
use Laravel\Dusk\Browser;

uses(DatabaseTruncation::class);

//

```


```php
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
Por defecto, este trait truncará todas las tablas excepto la tabla `migrations`. Si deseas personalizar las tablas que se deben truncar, puedes definir una propiedad `$tablesToTruncate` en tu clase de prueba:
> [!NOTA]
Si estás usando Pest, debes definir propiedades o métodos en la clase base `DuskTestCase` o en cualquier clase que tu archivo de prueba extienda.


```php
/**
 * Indicates which tables should be truncated.
 *
 * @var array
 */
protected $tablesToTruncate = ['users'];
```
Alternativamente, puedes definir una propiedad `$exceptTables` en tu clase de prueba para especificar qué tablas deben ser excluidas de la truncación:


```php
/**
 * Indicates which tables should be excluded from truncation.
 *
 * @var array
 */
protected $exceptTables = ['users'];
```
Para especificar las conexiones a la base de datos cuyas tablas deben ser truncadas, puedes definir una propiedad `$connectionsToTruncate` en tu clase de prueba:


```php
/**
 * Indicates which connections should have their tables truncated.
 *
 * @var array
 */
protected $connectionsToTruncate = ['mysql'];
```
Si deseas ejecutar código antes o después de que se realice la truncación de la base de datos, puedes definir los métodos `beforeTruncatingDatabase` o `afterTruncatingDatabase` en tu clase de prueba:


```php
/**
 * Perform any work that should take place before the database has started truncating.
 */
protected function beforeTruncatingDatabase(): void
{
    //
}

/**
 * Perform any work that should take place after the database has finished truncating.
 */
protected function afterTruncatingDatabase(): void
{
    //
}
```

<a name="running-tests"></a>
### Ejecutando Pruebas

Para ejecutar tus pruebas en el navegador, ejecuta el comando Artisan `dusk`:


```shell
php artisan dusk

```
Si tuviste fallos en las pruebas la última vez que ejecutaste el comando `dusk`, puedes ahorrar tiempo volviendo a ejecutar primero las pruebas fallidas utilizando el comando `dusk:fails`:


```shell
php artisan dusk:fails

```
El comando `dusk` acepta cualquier argumento que normalmente sea aceptado por el runner de pruebas Pest / PHPUnit, como permitirte ejecutar solo las pruebas para un [grupo](https://docs.phpunit.de/en/10.5/annotations.html#group) dado:


```shell
php artisan dusk --group=foo

```
> [!NOTA]
Si estás utilizando [Laravel Sail](/docs/%7B%7Bversion%7D%7D/sail) para gestionar tu entorno de desarrollo local, consulta la documentación de Sail sobre [configuración y ejecución de pruebas Dusk](/docs/%7B%7Bversion%7D%7D/sail#laravel-dusk).

<a name="manually-starting-chromedriver"></a>
#### Iniciando ChromeDriver Manualmente

Por defecto, Dusk intentará iniciar ChromeDriver automáticamente. Si esto no funciona para tu sistema en particular, puedes iniciar ChromeDriver manualmente antes de ejecutar el comando `dusk`. Si eliges iniciar ChromeDriver manualmente, deberías comentar la siguiente línea de tu archivo `tests/DuskTestCase.php`:


```php
/**
 * Prepare for Dusk test execution.
 *
 * @beforeClass
 */
public static function prepare(): void
{
    // static::startChromeDriver();
}
```
Además, si inicias ChromeDriver en un puerto diferente al 9515, debes modificar el método `driver` de la misma clase para reflejar el puerto correcto:


```php
use Facebook\WebDriver\Remote\RemoteWebDriver;

/**
 * Create the RemoteWebDriver instance.
 */
protected function driver(): RemoteWebDriver
{
    return RemoteWebDriver::create(
        'http://localhost:9515', DesiredCapabilities::chrome()
    );
}
```

<a name="environment-handling"></a>
### Manejo de Entornos

Para forzar a Dusk a que utilice su propio archivo de entorno al ejecutar pruebas, crea un archivo `.env.dusk.{environment}` en la raíz de tu proyecto. Por ejemplo, si iniciarás el comando `dusk` desde tu entorno `local`, deberías crear un archivo `.env.dusk.local`.
Al ejecutar pruebas, Dusk respaldará tu archivo `.env` y renombrará tu entorno Dusk a `.env`. Una vez que se hayan completado las pruebas, se restaurará tu archivo `.env`.

<a name="browser-basics"></a>
## Conceptos básicos del navegador


<a name="creating-browsers"></a>
### Creando Navegadores

Para empezar, escribamos una prueba que verifique que podemos iniciar sesión en nuestra aplicación. Después de generar una prueba, podemos modificarla para navegar a la página de inicio de sesión, ingresar algunas credenciales y hacer clic en el botón "Iniciar sesión". Para crear una instancia del navegador, puedes llamar al método `browse` desde dentro de tu prueba Dusk:


```php
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


```php
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
Como puedes ver en el ejemplo anterior, el método `browse` acepta una función anónima. Una instancia del navegador se pasará automáticamente a esta función anónima por Dusk y es el objeto principal utilizado para interactuar y hacer afirmaciones sobre tu aplicación.

<a name="creating-multiple-browsers"></a>
#### Creando Múltiples Navegadores

A veces es posible que necesites múltiples navegadores para llevar a cabo una prueba de manera correcta. Por ejemplo, se pueden necesitar múltiples navegadores para probar una pantalla de chat que interactúa con websockets. Para crear múltiples navegadores, simplemente añade más argumentos de navegador a la firma de la función anónima dada al método `browse`:


```php
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
```

<a name="navigation"></a>
### Navegación

El método `visit` se puede utilizar para navegar a una URI dada dentro de tu aplicación:


```php
$browser->visit('/login');
```
Puedes usar el método `visitRoute` para navegar a una [ruta nombrada](/docs/%7B%7Bversion%7D%7D/routing#named-routes):


```php
$browser->visitRoute($routeName, $parameters);
```
Puedes navegar "atrás" y "adelante" utilizando los métodos `back` y `forward`:


```php
$browser->back();

$browser->forward();
```
Puedes usar el método `refresh` para refrescar la página:


```php
$browser->refresh();
```

<a name="resizing-browser-windows"></a>
### Redimensionando Ventanas del Navegador

Puedes usar el método `resize` para ajustar el tamaño de la ventana del navegador:


```php
$browser->resize(1920, 1080);
```
El método `maximize` se puede utilizar para maximizar la ventana del navegador:


```php
$browser->maximize();
```
El método `fitContent` ajustará el tamaño de la ventana del navegador para que coincida con el tamaño de su contenido:


```php
$browser->fitContent();
```
Cuando una prueba falla, Dusk automáticamente cambiará el tamaño del navegador para ajustarse al contenido antes de tomar una captura de pantalla. Puedes desactivar esta función llamando al método `disableFitOnFailure` dentro de tu prueba:


```php
$browser->disableFitOnFailure();
```
Puedes usar el método `move` para mover la ventana del navegador a una posición diferente en tu pantalla:


```php
$browser->move($x = 100, $y = 100);
```

<a name="browser-macros"></a>
### Macros del Navegador

Si deseas definir un método de navegador personalizado que puedas reutilizar en una variedad de tus pruebas, puedes usar el método `macro` en la clase `Browser`. Típicamente, deberías llamar a este método desde el método `boot` de un [proveedor de servicios](/docs/%7B%7Bversion%7D%7D/providers):


```php
<?php

namespace App\Providers;

use Illuminate\Support\ServiceProvider;
use Laravel\Dusk\Browser;

class DuskServiceProvider extends ServiceProvider
{
    /**
     * Register Dusk's browser macros.
     */
    public function boot(): void
    {
        Browser::macro('scrollToElement', function (string $element = null) {
            $this->script("$('html, body').animate({ scrollTop: $('$element').offset().top }, 0);");

            return $this;
        });
    }
}
```
La función `macro` acepta un nombre como su primer argumento y una función anónima como su segundo. La función anónima del macro se ejecutará al llamar al macro como un método en una instancia de `Browser`:


```php
$this->browse(function (Browser $browser) use ($user) {
    $browser->visit('/pay')
            ->scrollToElement('#credit-card-details')
            ->assertSee('Enter Credit Card Details');
});
```

<a name="authentication"></a>
### Autenticación

A menudo, estarás probando páginas que requieren autenticación. Puedes usar el método `loginAs` de Dusk para evitar interactuar con la pantalla de inicio de sesión de tu aplicación durante cada prueba. El método `loginAs` acepta una clave primaria asociada con tu modelo autenticable o una instancia del modelo autenticable:


```php
use App\Models\User;
use Laravel\Dusk\Browser;

$this->browse(function (Browser $browser) {
    $browser->loginAs(User::find(1))
          ->visit('/home');
});
```
> [!WARNING]
Después de usar el método `loginAs`, la sesión del usuario se mantendrá para todas las pruebas dentro del archivo.

<a name="cookies"></a>
### Cookies

Puedes usar el método `cookie` para obtener o establecer el valor de una cookie encriptada. Por defecto, todas las cookies creadas por Laravel están encriptadas:


```php
$browser->cookie('name');

$browser->cookie('name', 'Taylor');
```
Puedes usar el método `plainCookie` para obtener o establecer el valor de una cookie sin encriptar:


```php
$browser->plainCookie('name');

$browser->plainCookie('name', 'Taylor');
```
Puedes usar el método `deleteCookie` para eliminar la cookie dada:


```php
$browser->deleteCookie('name');
```

<a name="executing-javascript"></a>
### Ejecutando JavaScript

Puedes usar el método `script` para ejecutar declaraciones de JavaScript arbitrarias dentro del navegador:


```php
$browser->script('document.documentElement.scrollTop = 0');

$browser->script([
    'document.body.scrollTop = 0',
    'document.documentElement.scrollTop = 0',
]);

$output = $browser->script('return window.location.pathname');
```

<a name="taking-a-screenshot"></a>
### Tomando una Captura de Pantalla

Puedes usar el método `screenshot` para tomar una captura de pantalla y almacenarla con el nombre de archivo dado. Todas las capturas de pantalla se almacenarán en el directorio `tests/Browser/screenshots`:


```php
$browser->screenshot('filename');
```
El método `responsiveScreenshots` se puede utilizar para tomar una serie de capturas de pantalla en varios puntos de interrupción:


```php
$browser->responsiveScreenshots('filename');
```
El método `screenshotElement` se puede utilizar para tomar una captura de pantalla de un elemento específico en la página:


```php
$browser->screenshotElement('#selector', 'filename');
```

<a name="storing-console-output-to-disk"></a>
### Almacenando la Salida de la Consola en el Disco

Puedes usar el método `storeConsoleLog` para escribir la salida de la consola del navegador actual en el disco con el nombre de archivo dado. La salida de la consola se almacenará en el directorio `tests/Browser/console`:


```php
$browser->storeConsoleLog('filename');
```

<a name="storing-page-source-to-disk"></a>
### Almacenando el Código de la Página en Disco

Puedes usar el método `storeSource` para escribir el código fuente de la página actual en el disco con el nombre de archivo dado. El código fuente de la página se almacenará dentro del directorio `tests/Browser/source`:


```php
$browser->storeSource('filename');
```

<a name="interacting-with-elements"></a>
## Interactuando Con Elementos


<a name="dusk-selectors"></a>
### Selectores de Dusk

Elegir buenos selectores CSS para interactuar con elementos es una de las partes más difíciles de escribir pruebas Dusk. Con el tiempo, los cambios en el frontend pueden hacer que selectores CSS como los siguientes rompan tus pruebas:


```php
// HTML...

<button>Login</button>

// Test...

$browser->click('.login-page .container div > button');
```
Los selectores de Dusk te permiten centrarte en escribir pruebas efectivas en lugar de recordar selectores CSS. Para definir un selector, añade un atributo `dusk` a tu elemento HTML. Luego, al interactuar con un navegador Dusk, prefixa el selector con `@` para manipular el elemento adjunto dentro de tu prueba:


```php
// HTML...

<button dusk="login-button">Login</button>

// Test...

$browser->click('@login-button');
```
Si lo deseas, puedes personalizar el atributo HTML que utiliza el selector de Dusk a través del método `selectorHtmlAttribute`. Típicamente, este método debe ser llamado desde el método `boot` del `AppServiceProvider` de tu aplicación:


```php
use Laravel\Dusk\Dusk;

Dusk::selectorHtmlAttribute('data-dusk');
```

<a name="text-values-and-attributes"></a>
### Texto, Valores y Atributos


<a name="retrieving-setting-values"></a>
#### Recuperando y Estableciendo Valores

Dusk proporciona varios métodos para interactuar con el valor actual, el texto de visualización y los atributos de los elementos en la página. Por ejemplo, para obtener el "valor" de un elemento que coincide con un selector CSS o Dusk dado, utiliza el método `value`:


```php
// Retrieve the value...
$value = $browser->value('selector');

// Set the value...
$browser->value('selector', 'value');
```
Puedes usar el método `inputValue` para obtener el "valor" de un elemento de entrada que tiene un nombre de campo dado:


```php
$value = $browser->inputValue('field');
```

<a name="retrieving-text"></a>
#### Recuperando Texto

El método `text` se puede utilizar para recuperar el texto de visualización de un elemento que coincide con el selector dado:


```php
$text = $browser->text('selector');
```

<a name="retrieving-attributes"></a>
#### Recuperando Atributos

Finalmente, se puede usar el método `attribute` para recuperar el valor de un atributo de un elemento que coincide con el selector dado:


```php
$attribute = $browser->attribute('selector', 'value');
```

<a name="interacting-with-forms"></a>
### Interactuando con Formularios


<a name="typing-values"></a>
#### Escribiendo Valores

Dusk proporciona una variedad de métodos para interactuar con formularios y elementos de entrada. Primero, echemos un vistazo a un ejemplo de cómo escribir texto en un campo de entrada:


```php
$browser->type('email', 'taylor@laravel.com');
```
Ten en cuenta que, aunque el método acepta uno si es necesario, no estamos obligados a pasar un selector CSS en el método `type`. Si no se proporciona un selector CSS, Dusk buscará un campo `input` o `textarea` con el atributo `name` dado.
Para añadir texto a un campo sin borrar su contenido, puedes usar el método `append`:


```php
$browser->type('tags', 'foo')
        ->append('tags', ', bar, baz');
```
Puedes limpiar el valor de una entrada utilizando el método `clear`:


```php
$browser->clear('email');
```
Puedes instruir a Dusk para que escriba lentamente utilizando el método `typeSlowly`. Por defecto, Dusk pausará 100 milisegundos entre las pulsaciones de teclas. Para personalizar la cantidad de tiempo entre las pulsaciones de teclas, puedes pasar el número adecuado de milisegundos como el tercer argumento al método:


```php
$browser->typeSlowly('mobile', '+1 (202) 555-5555');

$browser->typeSlowly('mobile', '+1 (202) 555-5555', 300);
```
Puedes usar el método `appendSlowly` para añadir texto de manera gradual:


```php
$browser->type('tags', 'foo')
        ->appendSlowly('tags', ', bar, baz');
```

<a name="dropdowns"></a>
#### Dropdowns

Para seleccionar un valor disponible en un elemento `select`, puedes usar el método `select`. Al igual que el método `type`, el método `select` no requiere un selector CSS completo. Al pasar un valor al método `select`, debes pasar el valor de la opción subyacente en lugar del texto de visualización:


```php
$browser->select('size', 'Large');
```
Puedes seleccionar una opción aleatoria omitiendo el segundo argumento:


```php
$browser->select('size');
```
Al proporcionar un array como segundo argumento al método `select`, puedes instruir al método para que seleccione múltiples opciones:


```php
$browser->select('categories', ['Art', 'Music']);
```

<a name="checkboxes"></a>
#### Casillas de verificación

Para "marcar" una entrada de casilla de verificación, puedes usar el método `check`. Al igual que muchos otros métodos relacionados con la entrada, no se requiere un selector CSS completo. Si no se puede encontrar una coincidencia con un selector CSS, Dusk buscará una casilla de verificación con un atributo `name` coincidente:


```php
$browser->check('terms');
```
El método `uncheck` se puede utilizar para "desmarcar" una entrada de casilla de verificación:


```php
$browser->uncheck('terms');
```

<a name="radio-buttons"></a>
#### Botones de Opción

Para "seleccionar" una opción de entrada `radio`, puedes usar el método `radio`. Al igual que muchos otros métodos relacionados con entradas, no se requiere un selector CSS completo. Si no se puede encontrar una coincidencia con un selector CSS, Dusk buscará una entrada `radio` con atributos `name` y `value` coincidentes:


```php
$browser->radio('size', 'large');
```

<a name="attaching-files"></a>
### Adjuntando Archivos

El método `attach` se puede utilizar para adjuntar un archivo a un elemento de entrada `file`. Al igual que muchos otros métodos relacionados con la entrada, no se requiere un selector CSS completo. Si no se puede encontrar una coincidencia de selector CSS, Dusk buscará una entrada `file` con un atributo `name` que coincida:


```php
$browser->attach('photo', __DIR__.'/photos/mountains.png');
```
> [!WARNING]
La función attach requiere que la extensión `Zip` de PHP esté instalada y habilitada en tu servidor.

<a name="pressing-buttons"></a>
### Presionando Botones

El método `press` se puede utilizar para hacer clic en un elemento de botón en la página. El argumento dado al método `press` puede ser ya sea el texto en pantalla del botón o un selector CSS / Dusk:


```php
$browser->press('Login');
```
Al enviar formularios, muchas aplicaciones desactivan el botón de envío del formulario después de que se presiona y luego vuelven a habilitar el botón cuando se completa la solicitud HTTP de envío del formulario. Para presionar un botón y esperar a que se vuelva a habilitar el botón, puedes usar el método `pressAndWaitFor`:


```php
// Press the button and wait a maximum of 5 seconds for it to be enabled...
$browser->pressAndWaitFor('Save');

// Press the button and wait a maximum of 1 second for it to be enabled...
$browser->pressAndWaitFor('Save', 1);
```

<a name="clicking-links"></a>
### Haciendo clic en enlaces

Para hacer clic en un enlace, puedes usar el método `clickLink` en la instancia del navegador. El método `clickLink` hará clic en el enlace que tiene el texto de visualización dado:


```php
$browser->clickLink($linkText);
```
Puedes usar el método `seeLink` para determinar si un enlace con el texto de visualización dado es visible en la página:


```php
if ($browser->seeLink($linkText)) {
    // ...
}
```
> [!WARNING]
Estos métodos interactúan con jQuery. Si jQuery no está disponible en la página, Dusk lo inyectará automáticamente en la página para que esté disponible durante la duración de la prueba.

<a name="using-the-keyboard"></a>
### Usando el Teclado

El método `keys` te permite proporcionar secuencias de entrada más complejas a un elemento dado de lo que normalmente permite el método `type`. Por ejemplo, puedes instruir a Dusk para que mantenga teclas modificadoras mientras ingresa valores. En este ejemplo, se mantendrá la tecla `shift` mientras se ingresa `taylor` en el elemento que coincide con el selector dado. Después de que se escriba `taylor`, se escribirá `swift` sin ninguna tecla modificadora:


```php
$browser->keys('selector', ['{shift}', 'taylor'], 'swift');
```
Otro caso de uso valioso para el método `keys` es enviar una combinación de "atajos de teclado" al selector CSS principal de tu aplicación:


```php
$browser->keys('.app', ['{command}', 'j']);
```
> [!NOTA]
Todas las teclas modificadoras como `{command}` están envueltas en caracteres `{}` y coinciden con las constantes definidas en la clase `Facebook\WebDriver\WebDriverKeys`, que se puede [encontrar en GitHub](https://github.com/php-webdriver/php-webdriver/blob/master/lib/WebDriverKeys.php).

<a name="fluent-keyboard-interactions"></a>
#### Interacciones de Teclado Fluentes

Dusk también proporciona un método `withKeyboard`, lo que te permite realizar interacciones complejas con el teclado de forma fluida a través de la clase `Laravel\Dusk\Keyboard`. La clase `Keyboard` ofrece métodos `press`, `release`, `type` y `pause`:


```php
use Laravel\Dusk\Keyboard;

$browser->withKeyboard(function (Keyboard $keyboard) {
    $keyboard->press('c')
        ->pause(1000)
        ->release('c')
        ->type(['c', 'e', 'o']);
});
```

<a name="keyboard-macros"></a>
#### Macros de Teclado

Si deseas definir interacciones de teclado personalizadas que puedas reutilizar fácilmente a lo largo de tu suite de pruebas, puedes usar el método `macro` proporcionado por la clase `Keyboard`. Típicamente, deberías llamar a este método desde el método `boot` de un [proveedor de servicios](/docs/%7B%7Bversion%7D%7D/providers):


```php
<?php

namespace App\Providers;

use Facebook\WebDriver\WebDriverKeys;
use Illuminate\Support\ServiceProvider;
use Laravel\Dusk\Keyboard;
use Laravel\Dusk\OperatingSystem;

class DuskServiceProvider extends ServiceProvider
{
    /**
     * Register Dusk's browser macros.
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
```
La función `macro` acepta un nombre como su primer argumento y una `función anónima` como su segundo. La `función anónima` del macro se ejecutará al llamar al macro como un método en una instancia de `Keyboard`:


```php
$browser->click('@textarea')
    ->withKeyboard(fn (Keyboard $keyboard) => $keyboard->copy())
    ->click('@another-textarea')
    ->withKeyboard(fn (Keyboard $keyboard) => $keyboard->paste());
```

<a name="using-the-mouse"></a>
### Usando el Ratón


<a name="clicking-on-elements"></a>
#### Haciendo clic en elementos

El método `click` se puede utilizar para hacer clic en un elemento que coincide con el selector CSS o Dusk dado:


```php
$browser->click('.selector');
```
El método `clickAtXPath` se puede usar para hacer clic en un elemento que coincide con la expresión XPath dada:


```php
$browser->clickAtXPath('//div[@class = "selector"]');
```
El método `clickAtPoint` se puede usar para hacer clic en el elemento más alto en un par de coordenadas dadas en relación con el área visible del navegador:


```php
$browser->clickAtPoint($x = 0, $y = 0);
```
El método `doubleClick` se puede utilizar para simular el doble clic de un ratón:


```php
$browser->doubleClick();

$browser->doubleClick('.selector');
```
El método `rightClick` se puede usar para simular el clic derecho de un ratón:


```php
$browser->rightClick();

$browser->rightClick('.selector');
```
El método `clickAndHold` se puede utilizar para simular un botón del mouse siendo clicado y mantenido presionado. Un llamado posterior al método `releaseMouse` deshará este comportamiento y soltará el botón del mouse:


```php
$browser->clickAndHold('.selector');

$browser->clickAndHold()
        ->pause(1000)
        ->releaseMouse();
```
El método `controlClick` se puede utilizar para simular el evento `ctrl+click` dentro del navegador:


```php
$browser->controlClick();

$browser->controlClick('.selector');
```

<a name="mouseover"></a>
#### Mouseover

El método `mouseover` se puede usar cuando necesitas mover el ratón sobre un elemento que coincide con el selector CSS o Dusk dado:


```php
$browser->mouseover('.selector');
```

<a name="drag-drop"></a>
#### Arrastrar y soltar

El método `drag` se puede usar para arrastrar un elemento que coincide con el selector dado a otro elemento:


```php
$browser->drag('.from-selector', '.to-selector');
```
O bien, puedes arrastrar un elemento en una sola dirección:


```php
$browser->dragLeft('.selector', $pixels = 10);
$browser->dragRight('.selector', $pixels = 10);
$browser->dragUp('.selector', $pixels = 10);
$browser->dragDown('.selector', $pixels = 10);
```
Finalmente, puedes arrastrar un elemento por un desplazamiento dado:


```php
$browser->dragOffset('.selector', $x = 10, $y = 10);
```

<a name="javascript-dialogs"></a>
### Diálogos de JavaScript

Dusk ofrece varios métodos para interactuar con diálogos de JavaScript. Por ejemplo, puedes usar el método `waitForDialog` para esperar a que aparezca un diálogo de JavaScript. Este método acepta un argumento opcional que indica cuántos segundos esperar para que aparezca el diálogo:


```php
$browser->waitForDialog($seconds = null);
```
El método `assertDialogOpened` se puede utilizar para afirmar que se ha mostrado un diálogo y contiene el mensaje dado:


```php
$browser->assertDialogOpened('Dialog message');
```
Si el diálogo de JavaScript contiene un aviso, puedes usar el método `typeInDialog` para escribir un valor en el aviso:


```php
$browser->typeInDialog('Hello World');
```
Para cerrar un diálogo de JavaScript abierto haciendo clic en el botón "OK", puedes invocar el método `acceptDialog`:


```php
$browser->acceptDialog();
```
Para cerrar un diálogo de JavaScript abierto al hacer clic en el botón "Cancelar", puedes invocar el método `dismissDialog`:


```php
$browser->dismissDialog();
```

<a name="interacting-with-iframes"></a>
### Interactuando con Marcos en Línea

Si necesitas interactuar con elementos dentro de un iframe, puedes usar el método `withinFrame`. Todas las interacciones con elementos que tengan lugar dentro de la función anónima proporcionada al método `withinFrame` estarán limitadas al contexto del iframe especificado:


```php
$browser->withinFrame('#credit-card-details', function ($browser) {
    $browser->type('input[name="cardnumber"]', '4242424242424242')
        ->type('input[name="exp-date"]', '1224')
        ->type('input[name="cvc"]', '123')
        ->press('Pay');
});
```

<a name="scoping-selectors"></a>
### Selectores de Alcance

A veces es posible que desees realizar varias operaciones mientras limites todas las operaciones a un selector dado. Por ejemplo, es posible que desees afirmar que algún texto existe solo dentro de una tabla y luego hacer clic en un botón dentro de esa tabla. Puedes usar el método `with` para lograr esto. Todas las operaciones realizadas dentro de la función anónima dada al método `with` estarán limitadas al selector original:


```php
$browser->with('.table', function (Browser $table) {
    $table->assertSee('Hello World')
          ->clickLink('Delete');
});
```
Es posible que ocasionalmente necesites ejecutar afirmaciones fuera del alcance actual. Puedes usar los métodos `elsewhere` y `elsewhereWhenAvailable` para lograr esto:


```php
$browser->with('.table', function (Browser $table) {
    // Current scope is `body .table`...

    $browser->elsewhere('.page-title', function (Browser $title) {
        // Current scope is `body .page-title`...
        $title->assertSee('Hello World');
    });

    $browser->elsewhereWhenAvailable('.page-title', function (Browser $title) {
        // Current scope is `body .page-title`...
        $title->assertSee('Hello World');
    });
 });
```

<a name="waiting-for-elements"></a>
### Esperando Elementos

Al probar aplicaciones que utilizan JavaScript de manera extensiva, a menudo es necesario "esperar" a que ciertos elementos o datos estén disponibles antes de continuar con una prueba. Dusk lo hace muy fácil. Usando una variedad de métodos, puedes esperar a que los elementos se vuelvan visibles en la página o incluso esperar hasta que una expresión JavaScript dada evalúe a `true`.

<a name="waiting"></a>
#### Esperando

Si solo necesitas pausar la prueba durante un número dado de milisegundos, utiliza el método `pause`:


```php
$browser->pause(1000);
```
Si necesitas pausar la prueba solo si una condición dada es `true`, usa el método `pauseIf`:


```php
$browser->pauseIf(App::environment('production'), 1000);
```
Del mismo modo, si necesitas pausar la prueba a menos que una condición dada sea `true`, puedes usar el método `pauseUnless`:


```php
$browser->pauseUnless(App::environment('testing'), 1000);
```

<a name="waiting-for-selectors"></a>
#### Esperando Selectores

El método `waitFor` se puede utilizar para pausar la ejecución de la prueba hasta que el elemento que coincide con el selector CSS o Dusk dado se muestre en la página. Por defecto, esto pausará la prueba por un máximo de cinco segundos antes de lanzar una excepción. Si es necesario, puedes pasar un umbral de tiempo de espera personalizado como segundo argumento al método:


```php
// Wait a maximum of five seconds for the selector...
$browser->waitFor('.selector');

// Wait a maximum of one second for the selector...
$browser->waitFor('.selector', 1);
```
También puedes esperar hasta que el elemento que coincide con el selector dado contenga el texto dado:


```php
// Wait a maximum of five seconds for the selector to contain the given text...
$browser->waitForTextIn('.selector', 'Hello World');

// Wait a maximum of one second for the selector to contain the given text...
$browser->waitForTextIn('.selector', 'Hello World', 1);
```
También puedes esperar hasta que el elemento que coincide con el selector dado esté ausente de la página:


```php
// Wait a maximum of five seconds until the selector is missing...
$browser->waitUntilMissing('.selector');

// Wait a maximum of one second until the selector is missing...
$browser->waitUntilMissing('.selector', 1);
```
O, puedes esperar hasta que el elemento que coincide con el selector dado sea habilitado o deshabilitado:


```php
// Wait a maximum of five seconds until the selector is enabled...
$browser->waitUntilEnabled('.selector');

// Wait a maximum of one second until the selector is enabled...
$browser->waitUntilEnabled('.selector', 1);

// Wait a maximum of five seconds until the selector is disabled...
$browser->waitUntilDisabled('.selector');

// Wait a maximum of one second until the selector is disabled...
$browser->waitUntilDisabled('.selector', 1);
```

<a name="scoping-selectors-when-available"></a>
#### Selectores de Ámbito Cuando Están Disponibles

Ocasionalmente, es posible que desees esperar a que aparezca un elemento que coincida con un selector dado y luego interactuar con el elemento. Por ejemplo, es posible que desees esperar hasta que una ventana modal esté disponible y luego presionar el botón "OK" dentro de la modal. El método `whenAvailable` se puede usar para lograr esto. Todas las operaciones de elementos realizadas dentro de la `función anónima` dada se limitarán al selector original:


```php
$browser->whenAvailable('.modal', function (Browser $modal) {
    $modal->assertSee('Hello World')
          ->press('OK');
});
```

<a name="waiting-for-text"></a>
#### Esperando Texto

El método `waitForText` se puede utilizar para esperar hasta que el texto dado se muestre en la página:


```php
// Wait a maximum of five seconds for the text...
$browser->waitForText('Hello World');

// Wait a maximum of one second for the text...
$browser->waitForText('Hello World', 1);
```
Puedes utilizar el método `waitUntilMissingText` para esperar hasta que el texto mostrado haya sido eliminado de la página:


```php
// Wait a maximum of five seconds for the text to be removed...
$browser->waitUntilMissingText('Hello World');

// Wait a maximum of one second for the text to be removed...
$browser->waitUntilMissingText('Hello World', 1);
```

<a name="waiting-for-links"></a>
#### Esperando Enlaces

El método `waitForLink` se puede utilizar para esperar hasta que el texto del enlace dado se muestre en la página:


```php
// Wait a maximum of five seconds for the link...
$browser->waitForLink('Create');

// Wait a maximum of one second for the link...
$browser->waitForLink('Create', 1);
```

<a name="waiting-for-inputs"></a>
#### Esperando entradas

El método `waitForInput` se puede utilizar para esperar hasta que el campo de entrada dado sea visible en la página:


```php
// Wait a maximum of five seconds for the input...
$browser->waitForInput($field);

// Wait a maximum of one second for the input...
$browser->waitForInput($field, 1);
```

<a name="waiting-on-the-page-location"></a>
#### Esperando la Ubicación de la Página

Al hacer una afirmación de ruta como `$browser->assertPathIs('/home')`, la afirmación puede fallar si `window.location.pathname` se está actualizando de forma asíncrona. Puedes usar el método `waitForLocation` para esperar a que la ubicación sea un valor dado:


```php
$browser->waitForLocation('/secret');
```
El método `waitForLocation` también se puede utilizar para esperar a que la ubicación de la ventana actual sea una URL completamente calificada:


```php
$browser->waitForLocation('https://example.com/path');
```
También puedes esperar la ubicación de una [ruta nombrada](/docs/%7B%7Bversion%7D%7D/routing#named-routes):


```php
$browser->waitForRoute($routeName, $parameters);
```

<a name="waiting-for-page-reloads"></a>
#### Esperando Reinicios de Página

Si necesitas esperar a que una página se recargue después de realizar una acción, utiliza el método `waitForReload`:


```php
use Laravel\Dusk\Browser;

$browser->waitForReload(function (Browser $browser) {
    $browser->press('Submit');
})
->assertSee('Success!');
```
Dado que la necesidad de esperar a que la página se recargue generalmente ocurre después de hacer clic en un botón, puedes usar el método `clickAndWaitForReload` por conveniencia:


```php
$browser->clickAndWaitForReload('.selector')
        ->assertSee('something');
```

<a name="waiting-on-javascript-expressions"></a>
#### Esperando Expresiones de JavaScript

A veces es posible que desees pausar la ejecución de una prueba hasta que una expresión JavaScript dada se evalúe como `true`. Puedes lograr esto fácilmente utilizando el método `waitUntil`. Al pasar una expresión a este método, no necesitas incluir la palabra clave `return` o un punto y coma al final:


```php
// Wait a maximum of five seconds for the expression to be true...
$browser->waitUntil('App.data.servers.length > 0');

// Wait a maximum of one second for the expression to be true...
$browser->waitUntil('App.data.servers.length > 0', 1);
```

<a name="waiting-on-vue-expressions"></a>
#### Esperando Expresiones de Vue

Los métodos `waitUntilVue` y `waitUntilVueIsNot` se pueden utilizar para esperar hasta que un atributo de un [componente Vue](https://vuejs.org) tenga un valor dado:


```php
// Wait until the component attribute contains the given value...
$browser->waitUntilVue('user.name', 'Taylor', '@user');

// Wait until the component attribute doesn't contain the given value...
$browser->waitUntilVueIsNot('user.name', null, '@user');
```

<a name="waiting-for-javascript-events"></a>
#### Esperando Eventos de JavaScript

El método `waitForEvent` se puede usar para pausar la ejecución de una prueba hasta que ocurra un evento de JavaScript:


```php
$browser->waitForEvent('load');
```
El listener de eventos está adjunto al ámbito actual, que es el elemento `body` por defecto. Al usar un selector con alcance, el listener de eventos se adjuntará al elemento que coincida:


```php
$browser->with('iframe', function (Browser $iframe) {
    // Wait for the iframe's load event...
    $iframe->waitForEvent('load');
});
```
También puedes proporcionar un selector como segundo argumento al método `waitForEvent` para adjuntar el listener de eventos a un elemento específico:


```php
$browser->waitForEvent('load', '.selector');
```
También puedes esperar eventos en los objetos `document` y `window`:


```php
// Wait until the document is scrolled...
$browser->waitForEvent('scroll', 'document');

// Wait a maximum of five seconds until the window is resized...
$browser->waitForEvent('resize', 'window', 5);
```

<a name="waiting-with-a-callback"></a>
#### Esperando con una Callback

Muchos de los métodos "wait" en Dusk dependen del método subyacente `waitUsing`. Puedes usar este método directamente para esperar a que una `función anónima` dada devuelva `true`. El método `waitUsing` acepta el número máximo de segundos a esperar, el intervalo en el que se debe evaluar la `función anónima`, la `función anónima` y un mensaje de error opcional:


```php
$browser->waitUsing(10, 1, function () use ($something) {
    return $something->isReady();
}, "Something wasn't ready in time.");
```

<a name="scrolling-an-element-into-view"></a>
### Desplazando un Elemento a la Vista

A veces es posible que no puedas hacer clic en un elemento porque está fuera del área visible del navegador. El método `scrollIntoView` desplazará la ventana del navegador hasta que el elemento en el selector dado esté dentro de la vista:


```php
$browser->scrollIntoView('.selector')
        ->click('.selector');
```

<a name="available-assertions"></a>
## Afirmaciones Disponibles

Dusk ofrece una variedad de afirmaciones que puedes hacer contra tu aplicación. Todas las afirmaciones disponibles están documentadas en la lista a continuación:
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


```php
$browser->assertTitle($title);
```

<a name="assert-title-contains"></a>
#### assertTitleContains

Afirmar que el título de la página contiene el texto dado:


```php
$browser->assertTitleContains($title);
```

<a name="assert-url-is"></a>
#### assertUrlIs

Asegúrate de que la URL actual (sin la cadena de consulta) coincida con la cadena dada:


```php
$browser->assertUrlIs($url);
```

<a name="assert-scheme-is"></a>
#### assertSchemeIs

Asegúrate de que el esquema de URL actual coincida con el esquema dado:


```php
$browser->assertSchemeIs($scheme);
```

<a name="assert-scheme-is-not"></a>
#### assertSchemeIsNot

Asegúrate de que el esquema de URL actual no coincida con el esquema dado:


```php
$browser->assertSchemeIsNot($scheme);
```

<a name="assert-host-is"></a>
#### assertHostIs

Asegúrate de que el host de la URL actual coincida con el host dado:


```php
$browser->assertHostIs($host);
```

<a name="assert-host-is-not"></a>
#### assertHostIsNot

Asegúrate de que el host de la URL actual no coincida con el host dado:


```php
$browser->assertHostIsNot($host);
```

<a name="assert-port-is"></a>
#### assertPortIs

Asegúrate de que el puerto de la URL actual coincida con el puerto dado:


```php
$browser->assertPortIs($port);
```

<a name="assert-port-is-not"></a>
#### assertPortIsNot

Asegúrate de que el puerto de la URL actual no coincida con el puerto dado:


```php
$browser->assertPortIsNot($port);
```

<a name="assert-path-begins-with"></a>
#### assertPathBeginsWith

Afirmar que la ruta de URL actual comienza con la ruta dada:


```php
$browser->assertPathBeginsWith('/home');
```

<a name="assert-path-ends-with"></a>
#### assertPathEndsWith

Afirmar que la ruta de URL actual termina con la ruta dada:


```php
$browser->assertPathEndsWith('/home');
```

<a name="assert-path-contains"></a>
#### assertPathContains

Asegúrate de que la ruta de URL actual contenga la ruta dada:


```php
$browser->assertPathContains('/home');
```

<a name="assert-path-is"></a>
#### assertPathIs

Afirmar que la ruta actual coincide con la ruta dada:


```php
$browser->assertPathIs('/home');
```

<a name="assert-path-is-not"></a>
#### assertPathIsNot

Asegúrate de que la ruta actual no coincide con la ruta dada:


```php
$browser->assertPathIsNot('/home');
```

<a name="assert-route-is"></a>
#### assertRouteIs

Afirmar que la URL actual coincide con la URL de la [ruta nombrada](/docs/%7B%7Bversion%7D%7D/routing#named-routes) dada:


```php
$browser->assertRouteIs($name, $parameters);
```

<a name="assert-query-string-has"></a>
#### assertQueryStringHas

Asegúrate de que el parámetro de cadena de consulta dado esté presente:


```php
$browser->assertQueryStringHas($name);
```
Asegúrate de que el parámetro de cadena de consulta dado esté presente y tenga un valor dado:


```php
$browser->assertQueryStringHas($name, $value);
```

<a name="assert-query-string-missing"></a>
#### assertQueryStringMissing

Asegúrate de que el parámetro de cadena de consulta dado esté ausente:


```php
$browser->assertQueryStringMissing($name);
```

<a name="assert-fragment-is"></a>
#### assertFragmentIs

Afirmar que el fragmento hash actual de la URL coincide con el fragmento dado:


```php
$browser->assertFragmentIs('anchor');
```

<a name="assert-fragment-begins-with"></a>
#### assertFragmentBeginsWith

Asegúrate de que el fragmento hash actual de la URL comience con el fragmento dado:


```php
$browser->assertFragmentBeginsWith('anchor');
```

<a name="assert-fragment-is-not"></a>
#### assertFragmentIsNot

Asegúrate de que el fragmento hash actual de la URL no coincida con el fragmento dado:


```php
$browser->assertFragmentIsNot('anchor');
```

<a name="assert-has-cookie"></a>
#### assertHasCookie

Asegúrate de que la cookie encriptada dada esté presente:


```php
$browser->assertHasCookie($name);
```

<a name="assert-has-plain-cookie"></a>
#### assertHasPlainCookie

Asegúrate de que la cookie no encriptada dada esté presente:


```php
$browser->assertHasPlainCookie($name);
```

<a name="assert-cookie-missing"></a>
#### assertCookieMissing

Asegúrate de que la cookie cifrada dada no esté presente:


```php
$browser->assertCookieMissing($name);
```

<a name="assert-plain-cookie-missing"></a>
#### assertPlainCookieMissing

Asegúrate de que la cookie no encriptada dada no esté presente:


```php
$browser->assertPlainCookieMissing($name);
```

<a name="assert-cookie-value"></a>
#### assertCookieValue

Asegúrate de que una cookie encriptada tenga un valor dado:


```php
$browser->assertCookieValue($name, $value);
```

<a name="assert-plain-cookie-value"></a>
#### assertPlainCookieValue

Afirmar que una cookie no encriptada tiene un valor dado:


```php
$browser->assertPlainCookieValue($name, $value);
```

<a name="assert-see"></a>
#### assertSee

Asegúrate de que el texto dado esté presente en la página:


```php
$browser->assertSee($text);
```

<a name="assert-dont-see"></a>
#### assertDontSee

Asegúrate de que el texto dado no esté presente en la página:


```php
$browser->assertDontSee($text);
```

<a name="assert-see-in"></a>
#### assertSeeIn

Asegúrate de que el texto dado esté presente dentro del selector:


```php
$browser->assertSeeIn($selector, $text);
```

<a name="assert-dont-see-in"></a>
#### assertDontSeeIn

Afirma que el texto dado no está presente dentro del selector:


```php
$browser->assertDontSeeIn($selector, $text);
```

<a name="assert-see-anything-in"></a>
#### assertSeeAnythingIn

Asegúrate de que cualquier texto esté presente dentro del selector:


```php
$browser->assertSeeAnythingIn($selector);
```

<a name="assert-see-nothing-in"></a>
#### assertSeeNothingIn

Asegúrate de que no haya texto presente dentro del selector:


```php
$browser->assertSeeNothingIn($selector);
```

<a name="assert-script"></a>
#### assertScript

Afirmar que la expresión de JavaScript dada evalúa el valor dado:


```php
$browser->assertScript('window.isLoaded')
        ->assertScript('document.readyState', 'complete');
```

<a name="assert-source-has"></a>
#### assertSourceHas

Asegúrate de que el código fuente dado esté presente en la página:


```php
$browser->assertSourceHas($code);
```

<a name="assert-source-missing"></a>
#### assertSourceMissing

Asegúrate de que el código fuente dado no esté presente en la página:


```php
$browser->assertSourceMissing($code);
```

<a name="assert-see-link"></a>
#### assertSeeLink

Asegúrate de que el enlace dado esté presente en la página:


```php
$browser->assertSeeLink($linkText);
```

<a name="assert-dont-see-link"></a>
#### assertDontSeeLink

Afirmar que el enlace dado no está presente en la página:


```php
$browser->assertDontSeeLink($linkText);
```

<a name="assert-input-value"></a>
#### assertInputValue

Afirmar que el campo de entrada dado tiene el valor dado:


```php
$browser->assertInputValue($field, $value);
```

<a name="assert-input-value-is-not"></a>
#### assertInputValueIsNot

Afirmar que el campo de entrada dado no tiene el valor dado:


```php
$browser->assertInputValueIsNot($field, $value);
```

<a name="assert-checked"></a>
#### assertChecked

Afirmar que la casilla de verificación dada está marcada:


```php
$browser->assertChecked($field);
```

<a name="assert-not-checked"></a>
#### assertNotChecked

Asegúrate de que la casilla de verificación dada no esté marcada:


```php
$browser->assertNotChecked($field);
```

<a name="assert-indeterminate"></a>
#### assertIndeterminate

Asegúrate de que la casilla de verificación dada esté en un estado indeterminado:


```php
$browser->assertIndeterminate($field);
```

<a name="assert-radio-selected"></a>
#### assertRadioSelected

Afirmar que el campo de radio dado está seleccionado:


```php
$browser->assertRadioSelected($field, $value);
```

<a name="assert-radio-not-selected"></a>
#### assertRadioNotSelected

Asegúrate de que el campo de radio dado no esté seleccionado:


```php
$browser->assertRadioNotSelected($field, $value);
```

<a name="assert-selected"></a>
#### assertSelected

Afirmar que el dropdown dado tiene el valor dado seleccionado:


```php
$browser->assertSelected($field, $value);
```

<a name="assert-not-selected"></a>
#### assertNotSelected

Asegúrate de que el menú desplegable dado no tiene el valor dado seleccionado:


```php
$browser->assertNotSelected($field, $value);
```

<a name="assert-select-has-options"></a>
#### assertSelectHasOptions

Asegúrate de que laArray de los valores dados estén disponibles para ser seleccionados:


```php
$browser->assertSelectHasOptions($field, $values);
```

<a name="assert-select-missing-options"></a>
#### assertSelectMissingOptions

Asegúrate de que el array dado de valores no esté disponible para ser seleccionado:


```php
$browser->assertSelectMissingOptions($field, $values);
```

<a name="assert-select-has-option"></a>
#### assertSelectHasOption

Asegúrate de que el valor dado esté disponible para ser seleccionado en el campo dado:


```php
$browser->assertSelectHasOption($field, $value);
```

<a name="assert-select-missing-option"></a>
#### assertSelectMissingOption

Asegúrate de que el valor dado no esté disponible para ser seleccionado:


```php
$browser->assertSelectMissingOption($field, $value);
```

<a name="assert-value"></a>
#### assertValue

Asegúrate de que el elemento que coincide con el selector dado tenga el valor dado:


```php
$browser->assertValue($selector, $value);
```

<a name="assert-value-is-not"></a>
#### assertValueIsNot

Afirma que el elemento que coincide con el selector dado no tiene el valor dado:


```php
$browser->assertValueIsNot($selector, $value);
```

<a name="assert-attribute"></a>
#### assertAttribute

Asegúrate de que el elemento que coincide con el selector dado tenga el valor dado en el atributo proporcionado:


```php
$browser->assertAttribute($selector, $attribute, $value);
```

<a name="assert-attribute-contains"></a>
#### assertAttributeContains

Asegúrate de que el elemento que coincide con el selector dado contiene el valor dado en el atributo proporcionado:


```php
$browser->assertAttributeContains($selector, $attribute, $value);
```

<a name="assert-attribute-doesnt-contain"></a>
#### assertAttributeDoesntContain

Asegúrate de que el elemento que coincide con el selector dado no contenga el valor dado en el atributo proporcionado:


```php
$browser->assertAttributeDoesntContain($selector, $attribute, $value);
```

<a name="assert-aria-attribute"></a>
#### assertAriaAttribute

Asegúrate de que el elemento que coincide con el selector dado tiene el valor dado en el atributo aria proporcionado:


```php
$browser->assertAriaAttribute($selector, $attribute, $value);
```
Por ejemplo, dada la marca `<button aria-label="Add"></button>`, puedes hacer una afirmación sobre el atributo `aria-label` de la siguiente manera:


```php
$browser->assertAriaAttribute('button', 'label', 'Add')
```

<a name="assert-data-attribute"></a>
#### assertDataAttribute

Asegúrate de que el elemento que coincide con el selector dado tenga el valor dado en el atributo de datos proporcionado:


```php
$browser->assertDataAttribute($selector, $attribute, $value);
```
Por ejemplo, dado el marcado `<tr id="row-1" data-content="attendees"></tr>`, puedes hacer una afirmación contra el atributo `data-label` de la siguiente manera:


```php
$browser->assertDataAttribute('#row-1', 'content', 'attendees')
```

<a name="assert-visible"></a>
#### assertVisible

Afirmar que el elemento que coincide con el selector dado es visible:


```php
$browser->assertVisible($selector);
```

<a name="assert-present"></a>
#### assertPresent

Asegúrate de que el elemento que coincide con el selector dado esté presente en la fuente:


```php
$browser->assertPresent($selector);
```

<a name="assert-not-present"></a>
#### assertNotPresent

Asegúrate de que el elemento que coincide con el selector dado no esté presente en la fuente:


```php
$browser->assertNotPresent($selector);
```

<a name="assert-missing"></a>
#### assertMissing

Asegúrate de que el elemento que coincide con el selector dado no sea visible:


```php
$browser->assertMissing($selector);
```

<a name="assert-input-present"></a>
#### assertInputPresent

Asegúrate de que un input con el nombre dado esté presente:


```php
$browser->assertInputPresent($name);
```

<a name="assert-input-missing"></a>
#### assertInputMissing

Afirma que una entrada con el nombre dado no está presente en la fuente:


```php
$browser->assertInputMissing($name);
```

<a name="assert-dialog-opened"></a>
#### assertDialogOpened

Asegúrate de que se ha abierto un diálogo de JavaScript con el mensaje dado:


```php
$browser->assertDialogOpened($message);
```

<a name="assert-enabled"></a>
#### assertEnabled

Asegúrate de que el campo dado esté habilitado:


```php
$browser->assertEnabled($field);
```

<a name="assert-disabled"></a>
#### assertDisabled

Asegúrate de que el campo dado esté deshabilitado:


```php
$browser->assertDisabled($field);
```

<a name="assert-button-enabled"></a>
#### assertButtonEnabled

Afirmar que el botón dado está habilitado:


```php
$browser->assertButtonEnabled($button);
```

<a name="assert-button-disabled"></a>
#### assertButtonDisabled

Asegúrate de que el botón dado esté deshabilitado:


```php
$browser->assertButtonDisabled($button);
```

<a name="assert-focused"></a>
#### assertFocused

Asegura que el campo dado esté enfocado:


```php
$browser->assertFocused($field);
```

<a name="assert-not-focused"></a>
#### assertNotFocused

Asegúrate de que el campo dado no esté enfocado:


```php
$browser->assertNotFocused($field);
```

<a name="assert-authenticated"></a>
#### assertAuthenticated

Asegúrate de que el usuario esté autenticado:


```php
$browser->assertAuthenticated();
```

<a name="assert-guest"></a>
#### assertGuest

Asegúrate de que el usuario no esté autenticado:


```php
$browser->assertGuest();
```

<a name="assert-authenticated-as"></a>
#### assertAuthenticatedAs

Asegúrate de que el usuario esté autenticado como el usuario dado:


```php
$browser->assertAuthenticatedAs($user);
```

<a name="assert-vue"></a>
#### assertVue

Dusk incluso te permite hacer afirmaciones sobre el estado de los datos del [componente Vue](https://vuejs.org). Por ejemplo, imagina que tu aplicación contiene el siguiente componente Vue:


```php
// HTML...

<profile dusk="profile-component"></profile>

// Component Definition...

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
```
Puedes afirmar sobre el estado del componente Vue de la siguiente manera:


```php
test('vue', function () {
    $this->browse(function (Browser $browser) {
        $browser->visit('/')
                ->assertVue('user.name', 'Taylor', '@profile-component');
    });
});

```


```php
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

Asegúrate de que una propiedad de datos de componente Vue dada no coincida con el valor dado:


```php
$browser->assertVueIsNot($property, $value, $componentSelector = null);
```

<a name="assert-vue-contains"></a>
#### assertVueContains

Asegúrate de que una propiedad de datos del componente Vue dado sea un array y contenga el valor dado:


```php
$browser->assertVueContains($property, $value, $componentSelector = null);
```

<a name="assert-vue-doesnt-contain"></a>
#### assertVueDoesntContain

Asegúrate de que una propiedad de datos del componente Vue dado sea un array y no contenga el valor dado:


```php
$browser->assertVueDoesntContain($property, $value, $componentSelector = null);
```

<a name="pages"></a>
## Páginas

A veces, las pruebas requieren que se realicen varias acciones complicadas en secuencia. Esto puede hacer que tus pruebas sean más difíciles de leer y entender. Dusk Pages te permiten definir acciones expresivas que luego se pueden realizar en una página dada a través de un solo método. Las Páginas también te permiten definir accesos directos a selectores comunes para tu aplicación o para una sola página.

<a name="generating-pages"></a>
### Generando Páginas

Para generar un objeto de página, ejecuta el comando Artisan `dusk:page`. Todos los objetos de página se colocarán en el directorio `tests/Browser/Pages` de tu aplicación:


```php
php artisan dusk:page Login
```

<a name="configuring-pages"></a>
### Configuración de Páginas

Por defecto, las páginas tienen tres métodos: `url`, `assert` y `elements`. Discutiremos los métodos `url` y `assert` ahora. El método `elements` será [discutido en más detalle a continuación](#shorthand-selectors).

<a name="the-url-method"></a>
#### El Método `url`

El método `url` debería devolver la ruta de la URL que representa la página. Dusk utilizará esta URL al navegar a la página en el navegador:


```php
/**
 * Get the URL for the page.
 */
public function url(): string
{
    return '/login';
}
```

<a name="the-assert-method"></a>
#### El Método `assert`

El método `assert` puede hacer las afirmaciones necesarias para verificar que el navegador esté realmente en la página dada. No es necesario colocar nada dentro de este método; sin embargo, puedes hacer estas afirmaciones si lo deseas. Estas afirmaciones se ejecutarán automáticamente al navegar a la página:


```php
/**
 * Assert that the browser is on the page.
 */
public function assert(Browser $browser): void
{
    $browser->assertPathIs($this->url());
}
```

<a name="navigating-to-pages"></a>
### Navegando a Páginas

Una vez que se ha definido una página, puedes navegar a ella utilizando el método `visit`:


```php
use Tests\Browser\Pages\Login;

$browser->visit(new Login);
```
A veces es posible que ya estés en una página dada y necesites "cargar" los selectores y métodos de la página en el contexto de prueba actual. Esto es común al presionar un botón y ser redirigido a una página dada sin navegar explícitamente a ella. En esta situación, puedes usar el método `on` para cargar la página:


```php
use Tests\Browser\Pages\CreatePlaylist;

$browser->visit('/dashboard')
        ->clickLink('Create Playlist')
        ->on(new CreatePlaylist)
        ->assertSee('@create');
```

<a name="shorthand-selectors"></a>
### Selectores Abreviados

El método `elements` dentro de las clases de página te permite definir atajos rápidos y fáciles de recordar para cualquier selector CSS en tu página. Por ejemplo, definamos un atajo para el campo de entrada "email" de la página de inicio de sesión de la aplicación:


```php
/**
 * Get the element shortcuts for the page.
 *
 * @return array<string, string>
 */
public function elements(): array
{
    return [
        '@email' => 'input[name=email]',
    ];
}
```
Una vez que se ha definido el atajo, puedes usar el selector abreviado en cualquier lugar donde típicamente usarías un selector CSS completo:


```php
$browser->type('@email', 'taylor@laravel.com');
```

<a name="global-shorthand-selectors"></a>
#### Selectores Abreviados Globales

Después de instalar Dusk, se colocará una clase base `Page` en tu directorio `tests/Browser/Pages`. Esta clase contiene un método `siteElements` que se puede usar para definir selectores abreviados globales que deben estar disponibles en cada página a lo largo de tu aplicación:


```php
/**
 * Get the global element shortcuts for the site.
 *
 * @return array<string, string>
 */
public static function siteElements(): array
{
    return [
        '@element' => '#selector',
    ];
}
```

<a name="page-methods"></a>
### Métodos de Página

Además de los métodos predeterminados definidos en las páginas, puedes definir métodos adicionales que se pueden usar a lo largo de tus pruebas. Por ejemplo, imaginemos que estamos construyendo una aplicación de gestión de música. Una acción común para una página de la aplicación podría ser crear una lista de reproducción. En lugar de reescribir la lógica para crear una lista de reproducción en cada prueba, puedes definir un método `createPlaylist` en una clase de página:


```php
<?php

namespace Tests\Browser\Pages;

use Laravel\Dusk\Browser;
use Laravel\Dusk\Page;

class Dashboard extends Page
{
    // Other page methods...

    /**
     * Create a new playlist.
     */
    public function createPlaylist(Browser $browser, string $name): void
    {
        $browser->type('name', $name)
                ->check('share')
                ->press('Create Playlist');
    }
}
```
Una vez que se haya definido el método, puedes usarlo dentro de cualquier prueba que utilice la página. La instancia del navegador será pasada automáticamente como el primer argumento a los métodos de página personalizados:


```php
use Tests\Browser\Pages\Dashboard;

$browser->visit(new Dashboard)
        ->createPlaylist('My Playlist')
        ->assertSee('My Playlist');
```

<a name="components"></a>
## Componentes

Los componentes son similares a los “objetos de página” de Dusk, pero están destinados a piezas de UI y funcionalidad que se utilizan en toda tu aplicación, como una barra de navegación o una ventana de notificación. Como tal, los componentes no están vinculados a URLs específicas.

<a name="generating-components"></a>
### Generando Componentes

Para generar un componente, ejecuta el comando Artisan `dusk:component`. Los nuevos componentes se colocan en el directorio `tests/Browser/Components`:


```php
php artisan dusk:component DatePicker
```
Como se muestra arriba, un "selector de fecha" es un ejemplo de un componente que puede existir en toda tu aplicación en una variedad de páginas. Puede volverse engorroso escribir manualmente la lógica de automatización del navegador para seleccionar una fecha en docenas de pruebas a lo largo de tu suite de pruebas. En su lugar, podemos definir un componente Dusk para representar el selector de fecha, lo que nos permite encapsular esa lógica dentro del componente:


```php
<?php

namespace Tests\Browser\Components;

use Laravel\Dusk\Browser;
use Laravel\Dusk\Component as BaseComponent;

class DatePicker extends BaseComponent
{
    /**
     * Get the root selector for the component.
     */
    public function selector(): string
    {
        return '.date-picker';
    }

    /**
     * Assert that the browser page contains the component.
     */
    public function assert(Browser $browser): void
    {
        $browser->assertVisible($this->selector());
    }

    /**
     * Get the element shortcuts for the component.
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
     * Select the given date.
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
```

<a name="using-components"></a>
### Usando Componentes

Una vez que se ha definido el componente, podemos seleccionar fácilmente una fecha dentro del selector de fechas desde cualquier prueba. Y, si la lógica necesaria para seleccionar una fecha cambia, solo necesitamos actualizar el componente:


```php
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


```php
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
La mayoría de las configuraciones de integración continua de Dusk esperan que tu aplicación Laravel se sirva utilizando el servidor de desarrollo PHP incorporado en el puerto 8000. Por lo tanto, antes de continuar, debes asegurarte de que tu entorno de integración continua tenga un valor de variable de entorno `APP_URL` de `http://127.0.0.1:8000`.

<a name="running-tests-on-heroku-ci"></a>
### Heroku CI

Para ejecutar pruebas Dusk en [Heroku CI](https://www.heroku.com/continuous-integration), añade el siguiente buildpack de Google Chrome y scripts a tu archivo `app.json` de Heroku:


```php
{
  "environments": {
    "test": {
      "buildpacks": [
        { "url": "heroku/php" },
        { "url": "https://github.com/heroku/heroku-buildpack-chrome-for-testing" }
      ],
      "scripts": {
        "test-setup": "cp .env.testing .env",
        "test": "nohup bash -c './vendor/laravel/dusk/bin/chromedriver-linux --port=9515 > /dev/null 2>&1 &' && nohup bash -c 'php artisan serve --no-reload > /dev/null 2>&1 &' && php artisan dusk"
      }
    }
  }
}
```

<a name="running-tests-on-travis-ci"></a>
### Travis CI

Para ejecutar tus pruebas de Dusk en [Travis CI](https://travis-ci.org), utiliza la siguiente configuración de `.travis.yml`. Dado que Travis CI no es un entorno gráfico, necesitaremos tomar algunos pasos adicionales para lanzar un navegador Chrome. Además, utilizaremos `php artisan serve` para iniciar el servidor web integrado de PHP:


```yaml
language: php

php:
  - 8.2

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

Si estás utilizando [GitHub Actions](https://github.com/features/actions) para ejecutar tus pruebas de Dusk, puedes usar el siguiente archivo de configuración como punto de partida. Al igual que TravisCI, utilizaremos el comando `php artisan serve` para iniciar el servidor web incorporado de PHP:


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
        run: ./vendor/laravel/dusk/bin/chromedriver-linux --port=9515 &
      - name: Run Laravel Server
        run: php artisan serve --no-reload &
      - name: Run Dusk Tests
        run: php artisan dusk
      - name: Upload Screenshots
        if: failure()
        uses: actions/upload-artifact@v4
        with:
          name: screenshots
          path: tests/Browser/screenshots
      - name: Upload Console Logs
        if: failure()
        uses: actions/upload-artifact@v4
        with:
          name: console
          path: tests/Browser/console

```

<a name="running-tests-on-chipper-ci"></a>
### Chipper CI

Si estás utilizando [Chipper CI](https://chipperci.com) para ejecutar tus pruebas Dusk, puedes usar el siguiente archivo de configuración como punto de partida. Usaremos el servidor integrado de PHP para ejecutar Laravel, de modo que podamos escuchar las solicitudes:


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
Para obtener más información sobre la ejecución de pruebas Dusk en Chipper CI, incluyendo cómo usar bases de datos, consulta la [documentación oficial de Chipper CI](https://chipperci.com/docs/testing/laravel-dusk-new/).