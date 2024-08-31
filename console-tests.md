# Pruebas de Consola

- [Introducción](#introduction)
- [Expectativas de Éxito / Fracaso](#success-failure-expectations)
- [Expectativas de Entrada / Salida](#input-output-expectations)
- [Eventos de Consola](#console-events)

<a name="introduction"></a>
## Introducción

Además de simplificar las pruebas HTTP, Laravel ofrece una API simple para probar los [comandos de consola personalizados](/docs/%7B%7Bversion%7D%7D/artisan) de tu aplicación.

<a name="success-failure-expectations"></a>
## Expectativas de Éxito / Fracaso

Para comenzar, exploraremos cómo realizar afirmaciones sobre el código de salida de un comando Artisan. Para lograr esto, utilizaremos el método `artisan` para invocar un comando Artisan desde nuestra prueba. Luego, usaremos el método `assertExitCode` para afirmar que el comando se completó con un código de salida dado:


```php
test('console command', function () {
    $this->artisan('inspire')->assertExitCode(0);
});

```


```php
/**
 * Test a console command.
 */
public function test_console_command(): void
{
    $this->artisan('inspire')->assertExitCode(0);
}

```
Puedes usar el método `assertNotExitCode` para afirmar que el comando no terminó con un código de salida dado:


```php
$this->artisan('inspire')->assertNotExitCode(1);
```
Por supuesto, todos los comandos de terminal típicamente salen con un código de estado `0` cuando tienen éxito y con un código de salida no cero cuando no tienen éxito. Por lo tanto, para mayor comodidad, puedes utilizar las afirmaciones `assertSuccessful` y `assertFailed` para afirmar que un comando dado salió con un código de salida exitoso o no:


```php
$this->artisan('inspire')->assertSuccessful();

$this->artisan('inspire')->assertFailed();
```

<a name="input-output-expectations"></a>
## Expectativas de Entrada / Salida

Laravel te permite "simular" fácilmente la entrada del usuario para tus comandos de consola utilizando el método `expectsQuestion`. Además, puedes especificar el código de salida y el texto que esperas que se muestre como salida del comando de consola utilizando los métodos `assertExitCode` y `expectsOutput`. Por ejemplo, considera el siguiente comando de consola:


```php
Artisan::command('question', function () {
    $name = $this->ask('What is your name?');

    $language = $this->choice('Which language do you prefer?', [
        'PHP',
        'Ruby',
        'Python',
    ]);

    $this->line('Your name is '.$name.' and you prefer '.$language.'.');
});
```
Puedes probar este comando con la siguiente prueba:


```php
test('console command', function () {
    $this->artisan('question')
         ->expectsQuestion('What is your name?', 'Taylor Otwell')
         ->expectsQuestion('Which language do you prefer?', 'PHP')
         ->expectsOutput('Your name is Taylor Otwell and you prefer PHP.')
         ->doesntExpectOutput('Your name is Taylor Otwell and you prefer Ruby.')
         ->assertExitCode(0);
});

```


```php
/**
 * Test a console command.
 */
public function test_console_command(): void
{
    $this->artisan('question')
         ->expectsQuestion('What is your name?', 'Taylor Otwell')
         ->expectsQuestion('Which language do you prefer?', 'PHP')
         ->expectsOutput('Your name is Taylor Otwell and you prefer PHP.')
         ->doesntExpectOutput('Your name is Taylor Otwell and you prefer Ruby.')
         ->assertExitCode(0);
}

```
Si estás utilizando las funciones `search` o `multisearch` proporcionadas por [Laravel Prompts](/docs/%7B%7Bversion%7D%7D/prompts), puedes usar la afirmación `expectsSearch` para simular la entrada del usuario, los resultados de búsqueda y la selección:


```php
test('console command', function () {
    $this->artisan('example')
         ->expectsSearch('What is your name?', search: 'Tay', answers: [
            'Taylor Otwell',
            'Taylor Swift',
            'Darian Taylor'
         ], answer: 'Taylor Otwell')
         ->assertExitCode(0);
});

```


```php
/**
 * Test a console command.
 */
public function test_console_command(): void
{
    $this->artisan('example')
         ->expectsSearch('What is your name?', search: 'Tay', answers: [
            'Taylor Otwell',
            'Taylor Swift',
            'Darian Taylor'
         ], answer: 'Taylor Otwell')
         ->assertExitCode(0);
}

```
También puedes afirmar que un comando de consola no genera ninguna salida utilizando el método `doesntExpectOutput`:


```php
test('console command', function () {
    $this->artisan('example')
         ->doesntExpectOutput()
         ->assertExitCode(0);
});

```


```php
/**
 * Test a console command.
 */
public function test_console_command(): void
{
    $this->artisan('example')
            ->doesntExpectOutput()
            ->assertExitCode(0);
}

```
Los métodos `expectsOutputToContain` y `doesntExpectOutputToContain` se pueden utilizar para hacer afirmaciones sobre una porción de la salida:


```php
test('console command', function () {
    $this->artisan('example')
         ->expectsOutputToContain('Taylor')
         ->assertExitCode(0);
});

```


```php
/**
 * Test a console command.
 */
public function test_console_command(): void
{
    $this->artisan('example')
            ->expectsOutputToContain('Taylor')
            ->assertExitCode(0);
}

```

<a name="confirmation-expectations"></a>
#### Expectativas de Confirmación

Al escribir un comando que espera confirmación en forma de respuesta "sí" o "no", puedes utilizar el método `expectsConfirmation`:


```php
$this->artisan('module:import')
    ->expectsConfirmation('Do you really wish to run this command?', 'no')
    ->assertExitCode(1);
```

<a name="table-expectations"></a>
#### Expectativas de la Tabla

Si tu comando muestra una tabla de información utilizando el método `table` de Artisan, puede ser engorroso escribir las expectativas de salida para toda la tabla. En cambio, puedes usar el método `expectsTable`. Este método acepta los encabezados de la tabla como su primer argumento y los datos de la tabla como su segundo argumento:


```php
$this->artisan('users:all')
    ->expectsTable([
        'ID',
        'Email',
    ], [
        [1, 'taylor@example.com'],
        [2, 'abigail@example.com'],
    ]);
```

<a name="console-events"></a>
## Eventos de Consola

Por defecto, los eventos `Illuminate\Console\Events\CommandStarting` y `Illuminate\Console\Events\CommandFinished` no se despachan mientras se ejecutan las pruebas de tu aplicación. Sin embargo, puedes habilitar estos eventos para una clase de prueba dada añadiendo el trait `Illuminate\Foundation\Testing\WithConsoleEvents` a la clase:


```php
<?php

use Illuminate\Foundation\Testing\WithConsoleEvents;

uses(WithConsoleEvents::class);

// ...

```


```php
<?php

namespace Tests\Feature;

use Illuminate\Foundation\Testing\WithConsoleEvents;
use Tests\TestCase;

class ConsoleEventTest extends TestCase
{
    use WithConsoleEvents;

    // ...
}

```