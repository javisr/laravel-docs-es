# Pruebas: Introducción

- [Introducción](#introduction)
- [Entorno](#environment)
- [Creando Pruebas](#creating-tests)
- [Ejecutando Pruebas](#running-tests)
  - [Ejecutando Pruebas en Paralelo](#running-tests-in-parallel)
  - [Reportando Cobertura de Pruebas](#reporting-test-coverage)
  - [Perfilando Pruebas](#profiling-tests)

<a name="introduction"></a>
## Introducción

Laravel está construido pensando en las pruebas. De hecho, se incluye soporte para pruebas con [Pest](https://pestphp.com) y [PHPUnit](https://phpunit.de) desde el principio, y ya se ha configurado un archivo `phpunit.xml` para tu aplicación. El framework también viene con métodos auxiliares convenientes que te permiten probar tus aplicaciones de manera expresiva.
Por defecto, el directorio `tests` de tu aplicación contiene dos directorios: `Feature` y `Unit`. Las pruebas unitarias son pruebas que se enfocan en una porción muy pequeña e aislada de tu código. De hecho, la mayoría de las pruebas unitarias probablemente se centren en un solo método. Las pruebas dentro de tu directorio de pruebas "Unit" no inician tu aplicación Laravel y, por lo tanto, no pueden acceder a la base de datos de tu aplicación u otros servicios del framework.
Las pruebas de características pueden probar una porción más grande de tu código, incluyendo cómo varios objetos interactúan entre sí o incluso una solicitud HTTP completa a un endpoint JSON. **En general, la mayoría de tus pruebas deberían ser pruebas de características. Este tipo de pruebas ofrecen la mayor confianza de que tu sistema en su conjunto está funcionando como se esperaba.**
Se proporciona un archivo `ExampleTest.php` en los directorios de pruebas `Feature` y `Unit`. Después de instalar una nueva aplicación Laravel, ejecuta los comandos `vendor/bin/pest`, `vendor/bin/phpunit` o `php artisan test` para ejecutar tus pruebas.

<a name="environment"></a>
## Entorno

Al ejecutar pruebas, Laravel configurará automáticamente el [entorno de configuración](/docs/%7B%7Bversion%7D%7D/configuration#environment-configuration) en `testing` debido a las variables de entorno definidas en el archivo `phpunit.xml`. Laravel también configura automáticamente la sesión y la caché en el driver `array` para que no se persista ningún dato de sesión o de caché mientras se realizan las pruebas.
Puedes definir otros valores de configuración del entorno de prueba según sea necesario. Las variables de entorno `testing` pueden configurarse en el archivo `phpunit.xml` de tu aplicación, ¡pero asegúrate de borrar la caché de configuración utilizando el comando Artisan `config:clear` antes de ejecutar tus pruebas!

<a name="the-env-testing-environment-file"></a>
#### El archivo de entorno `.env.testing`

Además, puedes crear un archivo `.env.testing` en la raíz de tu proyecto. Este archivo se utilizará en lugar del archivo `.env` al ejecutar pruebas con Pest y PHPUnit o al ejecutar comandos Artisan con la opción `--env=testing`.

<a name="creating-tests"></a>
## Creando Pruebas

Para crear un nuevo caso de prueba, utiliza el comando Artisan `make:test`. Por defecto, las pruebas se colocarán en el directorio `tests/Feature`:


```shell
php artisan make:test UserTest

```
Si deseas crear una prueba dentro del directorio `tests/Unit`, puedes usar la opción `--unit` al ejecutar el comando `make:test`:


```shell
php artisan make:test UserTest --unit

```
> [!NOTE]
Los stubs de prueba se pueden personalizar utilizando [la publicación de stubs](/docs/%7B%7Bversion%7D%7D/artisan#stub-customization).
Una vez que se ha generado la prueba, puedes definir la prueba como lo harías normalmente utilizando Pest o PHPUnit. Para ejecutar tus pruebas, ejecuta el comando `vendor/bin/pest`, `vendor/bin/phpunit` o `php artisan test` desde tu terminal:


```php
<?php

test('basic', function () {
    expect(true)->toBeTrue();
});

```


```php
<?php

namespace Tests\Unit;

use PHPUnit\Framework\TestCase;

class ExampleTest extends TestCase
{
    /**
     * A basic test example.
     */
    public function test_basic_test(): void
    {
        $this->assertTrue(true);
    }
}

```
> [!WARNING]
Si defines tus propios métodos `setUp` / `tearDown` dentro de una clase de prueba, asegúrate de llamar a los respectivos métodos `parent::setUp()` / `parent::tearDown()` en la clase padre. Típicamente, deberías invocar `parent::setUp()` al inicio de tu propio método `setUp`, y `parent::tearDown()` al final de tu método `tearDown`.

<a name="running-tests"></a>
## Ejecución de Pruebas

Como se mencionó anteriormente, una vez que hayas escrito las pruebas, puedes ejecutarlas utilizando `pest` o `phpunit`:


```shell
./vendor/bin/pest

```


```shell
./vendor/bin/phpunit

```
Además de los comandos `pest` o `phpunit`, puedes usar el comando Artisan `test` para ejecutar tus pruebas. El runner de pruebas Artisan proporciona informes de prueba verbosos para facilitar el desarrollo y la depuración:


```shell
php artisan test

```
Cualquier argumento que se puede pasar a los comandos `pest` o `phpunit` también se puede pasar al comando Artisan `test`:


```shell
php artisan test --testsuite=Feature --stop-on-failure

```

<a name="running-tests-in-parallel"></a>
### Ejecutando Pruebas en Paralelo

Por defecto, Laravel y Pest / PHPUnit ejecutan tus pruebas de forma secuencial dentro de un solo proceso. Sin embargo, puedes reducir significativamente el tiempo que lleva ejecutar tus pruebas ejecutándolas de forma simultánea a través de múltiples procesos. Para comenzar, debes instalar el paquete `brianium/paratest` de Composer como una dependencia "dev". Luego, incluye la opción `--parallel` al ejecutar el comando Artisan `test`:


```shell
composer require brianium/paratest --dev

php artisan test --parallel

```
Por defecto, Laravel creará tantos procesos como núcleos de CPU estén disponibles en tu máquina. Sin embargo, puedes ajustar el número de procesos utilizando la opción `--processes`:


```shell
php artisan test --parallel --processes=4

```
> [!WARNING]
Cuando se ejecutan pruebas en paralelo, algunas opciones de Pest / PHPUnit (como `--do-not-cache-result`) pueden no estar disponibles.

<a name="parallel-testing-and-databases"></a>
#### Pruebas Paralelas y Bases de Datos

Siempre que hayas configurado una conexión de base de datos primaria, Laravel maneja automáticamente la creación y migración de una base de datos de pruebas para cada proceso paralelo que esté ejecutando tus pruebas. Las bases de datos de prueba se sufijan con un token de proceso que es único por proceso. Por ejemplo, si tienes dos procesos de prueba paralelos, Laravel creará y utilizará las bases de datos de prueba `your_db_test_1` y `your_db_test_2`.
Por defecto, las bases de datos de prueba persisten entre las llamadas al comando Artisan `test` para que puedan ser utilizadas nuevamente en invocaciones posteriores de `test`. Sin embargo, puedes volver a crearlas utilizando la opción `--recreate-databases`:


```shell
php artisan test --parallel --recreate-databases

```

<a name="parallel-testing-hooks"></a>
#### Hooks de Pruebas Paralelas

Occasionalmente, es posible que debas preparar ciertos recursos utilizados por las pruebas de tu aplicación para que puedan ser utilizados de manera segura por múltiples procesos de prueba.
Usando la facade `ParallelTesting`, puedes especificar el código que se ejecutará en el `setUp` y `tearDown` de un proceso o caso de prueba. Las `funciones anónimas` dadas reciben las variables `$token` y `$testCase` que contienen el token del proceso y el caso de prueba actual, respectivamente:


```php
<?php

namespace App\Providers;

use Illuminate\Support\Facades\Artisan;
use Illuminate\Support\Facades\ParallelTesting;
use Illuminate\Support\ServiceProvider;
use PHPUnit\Framework\TestCase;

class AppServiceProvider extends ServiceProvider
{
    /**
     * Bootstrap any application services.
     */
    public function boot(): void
    {
        ParallelTesting::setUpProcess(function (int $token) {
            // ...
        });

        ParallelTesting::setUpTestCase(function (int $token, TestCase $testCase) {
            // ...
        });

        // Executed when a test database is created...
        ParallelTesting::setUpTestDatabase(function (string $database, int $token) {
            Artisan::call('db:seed');
        });

        ParallelTesting::tearDownTestCase(function (int $token, TestCase $testCase) {
            // ...
        });

        ParallelTesting::tearDownProcess(function (int $token) {
            // ...
        });
    }
}
```

<a name="accessing-the-parallel-testing-token"></a>
#### Accediendo al Token de Pruebas Paralelas

Si deseas acceder al "token" del proceso paralelo actual desde cualquier otra ubicación en el código de prueba de tu aplicación, puedes usar el método `token`. Este token es un identificador de cadena único para un proceso de prueba individual y se puede usar para segmentar recursos a través de procesos de prueba paralelos. Por ejemplo, Laravel automáticamente añade este token al final de las bases de datos de prueba creadas por cada proceso de prueba paralelo:


```php
$token = ParallelTesting::token();
```

<a name="reporting-test-coverage"></a>
### Informando la Cobertura de Pruebas

> [!WARNING]
Esta función requiere [Xdebug](https://xdebug.org) o [PCOV](https://pecl.php.net/package/pcov).
Al realizar las pruebas de tu aplicación, es posible que desees determinar si tus casos de prueba están cubriendo realmente el código de la aplicación y cuánta código de la aplicación se utiliza al ejecutar tus pruebas. Para lograr esto, puedes proporcionar la opción `--coverage` al invocar el comando `test`:


```shell
php artisan test --coverage

```

<a name="enforcing-a-minimum-coverage-threshold"></a>
#### Haciendo Cumplir un Umbral Mínimo de Cobertura

Puedes usar la opción `--min` para definir un umbral mínimo de cobertura de pruebas para tu aplicación. El conjunto de pruebas fallará si no se cumple este umbral:


```shell
php artisan test --coverage --min=80.3

```

<a name="profiling-tests"></a>
### Pruebas de Perfilado

El runner de pruebas Artisan también incluye un mecanismo conveniente para listar las pruebas más lentas de tu aplicación. Invoca el comando `test` con la opción `--profile` para que se te presente una lista de tus diez pruebas más lentas, lo que te permitirá investigar fácilmente qué pruebas se pueden mejorar para acelerar tu suite de pruebas:


```shell
php artisan test --profile

```