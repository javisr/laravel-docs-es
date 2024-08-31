# Plantillas Blade

- [Introducción](#introduction)
  - [Potenciando Blade con Livewire](#supercharging-blade-with-livewire)
- [Mostrando Datos](#displaying-data)
  - [Codificación de Entidades HTML](#html-entity-encoding)
  - [Blade y Frameworks JavaScript](#blade-and-javascript-frameworks)
- [Directivas de Blade](#blade-directives)
  - [Sentencias If](#if-statements)
  - [Sentencias Switch](#switch-statements)
  - [Bucles](#loops)
  - [La Variable de Bucle](#the-loop-variable)
  - [Clases Condicionales](#conditional-classes)
  - [Atributos Adicionales](#additional-attributes)
  - [Incluyendo Subvistas](#including-subviews)
  - [La Directiva `@once`](#the-once-directive)
  - [PHP en Crudo](#raw-php)
  - [Comentarios](#comments)
- [Componentes](#components)
  - [Renderizando Componentes](#rendering-components)
  - [Pasando Datos a Componentes](#passing-data-to-components)
  - [Atributos del Componente](#component-attributes)
  - [Palabras Clave Reservadas](#reserved-keywords)
  - [Slots](#slots)
  - [Vistas de Componentes en Línea](#inline-component-views)
  - [Componentes Dinámicos](#dynamic-components)
  - [Registrando Componentes Manualmente](#manually-registering-components)
- [Componentes Anónimos](#anonymous-components)
  - [Componentes de Índice Anónimos](#anonymous-index-components)
  - [Propiedades / Atributos de Datos](#data-properties-attributes)
  - [Accediendo a Datos de Padres](#accessing-parent-data)
  - [Rutas de Componentes Anónimos](#anonymous-component-paths)
- [Construyendo Diseños](#building-layouts)
  - [Diseños Usando Componentes](#layouts-using-components)
  - [Diseños Usando Herencia de Plantillas](#layouts-using-template-inheritance)
- [Formularios](#forms)
  - [Campo CSRF](#csrf-field)
  - [Campo de Método](#method-field)
  - [Errores de Validación](#validation-errors)
- [Pilas](#stacks)
- [Inyección de Servicios](#service-injection)
- [Renderizando Plantillas Blade en Línea](#rendering-inline-blade-templates)
- [Renderizando Fragmentos Blade](#rendering-blade-fragments)
- [Extendiendo Blade](#extending-blade)
  - [Manejadores de Eco Personalizados](#custom-echo-handlers)
  - [Sentencias If Personalizadas](#custom-if-statements)

<a name="introduction"></a>
## Introducción

Blade es el motor de plantillas simple pero poderoso que se incluye con Laravel. A diferencia de algunos motores de plantillas PHP, Blade no te restringe de usar código PHP en tus plantillas. De hecho, todas las plantillas de Blade se compilan en código PHP puro y se almacenan en caché hasta que sean modificadas, lo que significa que Blade añade esencialmente cero sobrecarga a tu aplicación. Los archivos de plantilla Blade utilizan la extensión de archivo `.blade.php` y se almacenan típicamente en el directorio `resources/views`.
Las vistas de Blade pueden ser devueltas desde rutas o controladores utilizando el helper global `view`. Por supuesto, como se menciona en la documentación sobre [vistas](/docs/%7B%7Bversion%7D%7D/views), se pueden pasar datos a la vista de Blade utilizando el segundo argumento del helper `view`:


```php
Route::get('/', function () {
    return view('greeting', ['name' => 'Finn']);
});
```

<a name="supercharging-blade-with-livewire"></a>
### Potenciando Blade con Livewire

¿Quieres llevar tus plantillas Blade al siguiente nivel y construir interfaces dinámicas con facilidad? Echa un vistazo a [Laravel Livewire](https://livewire.laravel.com). Livewire te permite escribir componentes Blade que están potenciados con funcionalidades dinámicas que típicamente solo serían posibles a través de frameworks frontend como React o Vue, proporcionando un gran enfoque para construir frontends modernos y reactivos sin las complejidades, el renderizado del lado del cliente o los pasos de construcción de muchos frameworks de JavaScript.

<a name="displaying-data"></a>
## Mostrando Datos

Puedes mostrar los datos que se pasan a tus vistas Blade envolviendo la variable en llaves. Por ejemplo, dada la siguiente ruta:


```php
Route::get('/', function () {
    return view('welcome', ['name' => 'Samantha']);
});
```
Puedes mostrar el contenido de la variable `name` de la siguiente manera:


```blade
Hello, {{ $name }}.

```
> [!NOTA]
Las declaraciones de eco `{{ }}` de Blade se envían automáticamente a través de la función `htmlspecialchars` de PHP para prevenir ataques XSS.
No estás limitado a mostrar solo el contenido de las variables pasadas a la vista. También puedes mostrar los resultados de cualquier función PHP. De hecho, puedes colocar cualquier código PHP que desees dentro de una declaración de eco de Blade:


```blade
The current UNIX timestamp is {{ time() }}.

```

<a name="html-entity-encoding"></a>
### Codificación de Entidades HTML

Por defecto, Blade (y la función `e` de Laravel) codificarán las entidades HTML de forma doble. Si deseas desactivar la codificación doble, llama al método `Blade::withoutDoubleEncoding` desde el método `boot` de tu `AppServiceProvider`:


```php
<?php

namespace App\Providers;

use Illuminate\Support\Facades\Blade;
use Illuminate\Support\ServiceProvider;

class AppServiceProvider extends ServiceProvider
{
    /**
     * Bootstrap any application services.
     */
    public function boot(): void
    {
        Blade::withoutDoubleEncoding();
    }
}
```

<a name="displaying-unescaped-data"></a>
#### Mostrando Datos No Escapados

Por defecto, las instrucciones Blade `{{ }}` se envían automáticamente a través de la función `htmlspecialchars` de PHP para prevenir ataques XSS. Si no deseas que tus datos sean escapados, puedes usar la siguiente sintaxis:


```blade
Hello, {!! $name !!}.

```
> [!WARNING]
Ten mucho cuidado al mostrar contenido que es proporcionado por los usuarios de tu aplicación. Debes utilizar típicamente la sintaxis de llaves dobles escapadas para prevenir ataques XSS al mostrar datos proporcionados por el usuario.

<a name="blade-and-javascript-frameworks"></a>
### Blade y Frameworks de JavaScript

Dado que muchos frameworks de JavaScript también usan llaves "curly" para indicar que una expresión dada debe mostrarse en el navegador, puedes usar el símbolo `@` para informar al motor de renderizado Blade que una expresión debe permanecer sin cambios. Por ejemplo:


```blade
<h1>Laravel</h1>

Hello, @{{ name }}.

```
En este ejemplo, el símbolo `@` será eliminado por Blade; sin embargo, la expresión `{{ name }}` permanecerá intacta por el motor Blade, lo que permitirá que sea renderizada por tu framework de JavaScript.
El símbolo `@` también se puede usar para escapar directivas de Blade:


```blade
{{-- Blade template --}}
@@if()

<!-- HTML output -->
@if()

```

<a name="rendering-json"></a>
#### Renderizando JSON

A veces puedes pasar un array a tu vista con la intención de renderizarlo como JSON para inicializar una variable de JavaScript. Por ejemplo:


```blade
<script>
    var app = <?php echo json_encode($array); ?>;
</script>

```
Sin embargo, en lugar de llamar manualmente a `json_encode`, puedes usar el método directo `Illuminate\Support\Js::from`. El método `from` acepta los mismos argumentos que la función `json_encode` de PHP; sin embargo, se asegurará de que el JSON resultante esté escapado correctamente para su inclusión dentro de comillas HTML. El método `from` devolverá una cadena con la declaración `JSON.parse` de JavaScript que convertirá el objeto o array dado en un objeto JavaScript válido:


```blade
<script>
    var app = {{ Illuminate\Support\Js::from($array) }};
</script>

```
Las últimas versiones del esqueleto de la aplicación Laravel incluyen un facade `Js`, que proporciona un acceso conveniente a esta funcionalidad dentro de tus plantillas Blade:


```blade
<script>
    var app = {{ Js::from($array) }};
</script>

```
> [!WARNING]
Debes usar el método `Js::from` solo para representar variables existentes como JSON. La plantilla Blade se basa en expresiones regulares y intentar pasar una expresión compleja a la directiva puede causar fallos inesperados.

<a name="the-at-verbatim-directive"></a>
#### La Directiva `@verbatim`

Si estás mostrando variables de JavaScript en una gran parte de tu plantilla, puedes envolver el HTML en la directiva `@verbatim` para que no tengas que prefijar cada declaración de eco de Blade con un símbolo `@`:


```blade
@verbatim
    <div class="container">
        Hello, {{ name }}.
    </div>
@endverbatim

```

<a name="blade-directives"></a>
## Directivas de Blade

Además de la herencia de plantillas y la visualización de datos, Blade también ofrece atajos convenientes para estructuras de control PHP comunes, como declaraciones condicionales y bucles. Estos atajos proporcionan una forma muy limpia y concisa de trabajar con estructuras de control PHP, al mismo tiempo que permanecen familiares para sus contrapartes en PHP.

<a name="if-statements"></a>
### Sentencias If

Puedes construir declaraciones `if` utilizando las directivas `@if`, `@elseif`, `@else` y `@endif`. Estas directivas funcionan de manera idéntica a sus contrapartes en PHP:


```blade
@if (count($records) === 1)
    I have one record!
@elseif (count($records) > 1)
    I have multiple records!
@else
    I don't have any records!
@endif

```
Por conveniencia, Blade también proporciona una directiva `@unless`:


```blade
@unless (Auth::check())
    You are not signed in.
@endunless

```
Además de las directivas condicionales ya discutidas, se pueden usar las directivas `@isset` y `@empty` como atajos convenientes para sus respectivas funciones PHP:


```blade
@isset($records)
    // $records is defined and is not null...
@endisset

@empty($records)
    // $records is "empty"...
@endempty

```

<a name="authentication-directives"></a>
#### Directivas de Autenticación

Las directivas `@auth` y `@guest` se pueden usar para determinar rápidamente si el usuario actual está [autenticado](/docs/%7B%7Bversion%7D%7D/authentication) o es un invitado:


```blade
@auth
    // The user is authenticated...
@endauth

@guest
    // The user is not authenticated...
@endguest

```
Si es necesario, puedes especificar el guardia de autenticación que se debe comprobar al usar las directivas `@auth` y `@guest`:


```blade
@auth('admin')
    // The user is authenticated...
@endauth

@guest('admin')
    // The user is not authenticated...
@endguest

```

<a name="environment-directives"></a>
#### Directivas de Entorno

Puedes verificar si la aplicación se está ejecutando en el entorno de producción utilizando la directiva `@production`:


```blade
@production
    // Production specific content...
@endproduction

```
O, puedes determinar si la aplicación se está ejecutando en un entorno específico utilizando la directiva `@env`:


```blade
@env('staging')
    // The application is running in "staging"...
@endenv

@env(['staging', 'production'])
    // The application is running in "staging" or "production"...
@endenv

```

<a name="section-directives"></a>
#### Directivas de Sección

Puedes determinar si una sección de herencia de plantilla tiene contenido utilizando la directiva `@hasSection`:


```blade
@hasSection('navigation')
    <div class="pull-right">
        @yield('navigation')
    </div>

    <div class="clearfix"></div>
@endif

```
Puedes usar la directiva `sectionMissing` para determinar si una sección no tiene contenido:


```blade
@sectionMissing('navigation')
    <div class="pull-right">
        @include('default-navigation')
    </div>
@endif

```

<a name="session-directives"></a>
#### Directivas de Sesión

La directiva `@session` se puede usar para determinar si existe un valor de [sesión](/docs/%7B%7Bversion%7D%7D/session). Si el valor de la sesión existe, el contenido de la plantilla dentro de las directivas `@session` y `@endsession` se evaluará. Dentro del contenido de la directiva `@session`, puedes usar la variable `$value` para mostrar el valor de la sesión:


```blade
@session('status')
    <div class="p-4 bg-green-100">
        {{ $value }}
    </div>
@endsession

```

<a name="switch-statements"></a>
### Declaraciones Switch

Las declarativas de Switch se pueden construir utilizando las directivas `@switch`, `@case`, `@break`, `@default` y `@endswitch`:


```blade
@switch($i)
    @case(1)
        First case...
        @break

    @case(2)
        Second case...
        @break

    @default
        Default case...
@endswitch

```

<a name="loops"></a>
### Bucles

Además de las declaraciones condicionales, Blade proporciona directivas simples para trabajar con las estructuras de bucle de PHP. Nuevamente, cada una de estas directivas funciona de manera idéntica a sus contrapartes de PHP:


```blade
@for ($i = 0; $i < 10; $i++)
    The current value is {{ $i }}
@endfor

@foreach ($users as $user)
    <p>This is user {{ $user->id }}</p>
@endforeach

@forelse ($users as $user)
    <li>{{ $user->name }}</li>
@empty
    <p>No users</p>
@endforelse

@while (true)
    <p>I'm looping forever.</p>
@endwhile

```
> [!NOTA]
Mientras iteras a través de un bucle `foreach`, puedes usar la [variable de bucle](#the-loop-variable) para obtener información valiosa sobre el bucle, como si estás en la primera o la última iteración del bucle.
Al usar bucles, también puedes omitir la iteración actual o finalizar el bucle utilizando las directivas `@continue` y `@break`:


```blade
@foreach ($users as $user)
    @if ($user->type == 1)
        @continue
    @endif

    <li>{{ $user->name }}</li>

    @if ($user->number == 5)
        @break
    @endif
@endforeach

```
También puedes incluir la condición de continuación o de ruptura dentro de la declaración de la directiva:


```blade
@foreach ($users as $user)
    @continue($user->type == 1)

    <li>{{ $user->name }}</li>

    @break($user->number == 5)
@endforeach

```

<a name="the-loop-variable"></a>
### La Variable de Bucle

Mientras iteras a través de un bucle `foreach`, una variable `$loop` estará disponible dentro de tu bucle. Esta variable proporciona acceso a algunos bits útiles de información, como el índice actual del bucle y si esta es la primera o última iteración a través del bucle:


```blade
@foreach ($users as $user)
    @if ($loop->first)
        This is the first iteration.
    @endif

    @if ($loop->last)
        This is the last iteration.
    @endif

    <p>This is user {{ $user->id }}</p>
@endforeach

```
Si te encuentras en un bucle anidado, puedes acceder a la variable `$loop` del bucle padre a través de la propiedad `parent`:


```blade
@foreach ($users as $user)
    @foreach ($user->posts as $post)
        @if ($loop->parent->first)
            This is the first iteration of the parent loop.
        @endif
    @endforeach
@endforeach

```
La variable `$loop` también contiene una variedad de otras propiedades útiles:
<div class="overflow-auto">

| Propiedad           | Descripción                                           |
| -------------------- | ----------------------------------------------------- |
| `$loop->index`      | El índice de la iteración actual del bucle (comienza en 0). |
| `$loop->iteration`  | La iteración actual del bucle (comienza en 1).             |
| `$loop->remaining`  | Las iteraciones restantes en el bucle.                 |
| `$loop->count`      | El número total de elementos en el array que se está iterando. |
| `$loop->first`      | Si esta es la primera iteración a través del bucle.   |
| `$loop->last`       | Si esta es la última iteración a través del bucle.    |
| `$loop->even`       | Si esta es una iteración par a través del bucle.      |
| `$loop->odd`        | Si esta es una iteración impar a través del bucle.     |
| `$loop->depth`      | El nivel de anidación del bucle actual.               |
| `$loop->parent`     | Cuando se está en un bucle anidado, la variable del bucle del padre. |
</div>

<a name="conditional-classes"></a>
### Clases y Estilos Condicionales

La directiva `@class` compila condicionalmente una cadena de clases CSS. La directiva acepta un array de clases donde la clave del array contiene la clase o las clases que deseas añadir, mientras que el valor es una expresión booleana. Si el elemento del array tiene una clave numérica, siempre será incluido en la lista de clases renderizadas:


```blade
@php
    $isActive = false;
    $hasError = true;
@endphp

<span @class([
    'p-4',
    'font-bold' => $isActive,
    'text-gray-500' => ! $isActive,
    'bg-red' => $hasError,
])></span>

<span class="p-4 text-gray-500 bg-red"></span>

```
Del mismo modo, se puede utilizar la directiva `@style` para añadir condicionalmente estilos CSS en línea a un elemento HTML:


```blade
@php
    $isActive = true;
@endphp

<span @style([
    'background-color: red',
    'font-weight: bold' => $isActive,
])></span>

<span style="background-color: red; font-weight: bold;"></span>

```

<a name="additional-attributes"></a>
### Atributos Adicionales

Para mayor comodidad, puedes usar la directiva `@checked` para indicar fácilmente si una entrada de casilla de verificación HTML dada está "marcada". Esta directiva devolverá `checked` si la condición proporcionada evalúa a `true`:


```blade
<input type="checkbox"
        name="active"
        value="active"
        @checked(old('active', $user->active)) />

```
Del mismo modo, se puede usar la directiva `@selected` para indicar si una opción de selección dada debe estar "seleccionada":


```blade
<select name="version">
    @foreach ($product->versions as $version)
        <option value="{{ $version }}" @selected(old('version') == $version)>
            {{ $version }}
        </option>
    @endforeach
</select>

```
Además, se puede usar la directiva `@disabled` para indicar si un elemento dado debería estar "deshabilitado":


```blade
<button type="submit" @disabled($errors->isNotEmpty())>Submit</button>

```
Además, la directiva `@readonly` se puede utilizar para indicar si un elemento dado debe ser "solo lectura":


```blade
<input type="email"
        name="email"
        value="email@laravel.com"
        @readonly($user->isNotAdmin()) />

```
Además, se puede usar la directiva `@required` para indicar si un elemento dado debe ser "requerido":


```blade
<input type="text"
        name="title"
        value="title"
        @required($user->isAdmin()) />

```

<a name="including-subviews"></a>
### Incluyendo Subvistas

> [!NOTA]
Aunque puedes usar la directiva `@include`, los [componentes](#components) de Blade ofrecen una funcionalidad similar y presentan varios beneficios sobre la directiva `@include`, como la vinculación de datos y atributos.
La directiva `@include` de Blade te permite incluir una vista de Blade desde otra vista. Todas las variables que están disponibles para la vista padre estarán disponibles para la vista incluida:


```blade
<div>
    @include('shared.errors')

    <form>
        <!-- Form Contents -->
    </form>
</div>

```
Aunque la vista incluida heredará todos los datos disponibles en la vista padre, también puedes pasar un array de datos adicionales que deberían estar disponibles para la vista incluida:


```blade
@include('view.name', ['status' => 'complete'])

```
Si intentas `@include` una vista que no existe, Laravel lanzará un error. Si deseas incluir una vista que puede o no estar presente, debes usar la directiva `@includeIf`:


```blade
@includeIf('view.name', ['status' => 'complete'])

```
Si deseas `@include` una vista si una expresión booleana dada evalúa a `true` o `false`, puedes usar las directivas `@includeWhen` y `@includeUnless`:


```blade
@includeWhen($boolean, 'view.name', ['status' => 'complete'])

@includeUnless($boolean, 'view.name', ['status' => 'complete'])

```
Para incluir la primera vista que existe a partir de un array dado de vistas, puedes usar la directiva `includeFirst`:


```blade
@includeFirst(['custom.admin', 'admin'], ['status' => 'complete'])

```
> [!WARNING]
Debes evitar usar las constantes `__DIR__` y `__FILE__` en tus vistas Blade, ya que se referirán a la ubicación de la vista compilada en caché.

<a name="rendering-views-for-collections"></a>
#### Renderizando Vistas para Colecciones

Puedes combinar bucles e inclusiones en una sola línea con el directorio `@each` de Blade:


```blade
@each('view.name', $jobs, 'job')

```
El primer argumento de laDirectiva `@each` es la vista que se renderizará para cada elemento en el array o la colección. El segundo argumento es el array o la colección que deseas iterar, mientras que el tercer argumento es el nombre de la variable que se asignará a la iteración actual dentro de la vista. Así que, por ejemplo, si estás iterando sobre un array de `jobs`, típicamente querrás acceder a cada trabajo como una variable `job` dentro de la vista. La clave del array para la iteración actual estará disponible como la variable `key` dentro de la vista.
También puedes pasar un cuarto argumento a la directiva `@each`. Este argumento determina la vista que se renderizará si el array dado está vacío.


```blade
@each('view.name', $jobs, 'job', 'view.empty')

```
> [!WARNING]
Las vistas renderizadas a través de `@each` no heredan las variables de la vista padre. Si la vista hija requiere estas variables, debes usar las directivas `@foreach` y `@include` en su lugar.

<a name="the-once-directive"></a>
### La Directiva `@once`

La directiva `@once` te permite definir una porción de la plantilla que solo se evaluará una vez por ciclo de renderizado. Esto puede ser útil para insertar una pieza dada de JavaScript en el encabezado de la página usando [stacks](#stacks). Por ejemplo, si estás renderizando un [componente](#components) dado dentro de un bucle, es posible que desees insertar el JavaScript en el encabezado solo la primera vez que se renderiza el componente:


```blade
@once
    @push('scripts')
        <script>
            // Your custom JavaScript...
        </script>
    @endpush
@endonce

```
Dado que la directiva `@once` se utiliza a menudo junto con las directivas `@push` o `@prepend`, las directivas `@pushOnce` y `@prependOnce` están disponibles para tu conveniencia:


```blade
@pushOnce('scripts')
    <script>
        // Your custom JavaScript...
    </script>
@endPushOnce

```

<a name="raw-php"></a>
### PHP en Raw

En algunas situaciones, es útil incrustar código PHP en tus vistas. Puedes usar la directiva `@php` de Blade para ejecutar un bloque de PHP puro dentro de tu plantilla:


```blade
@php
    $counter = 1;
@endphp

```
O, si solo necesitas usar PHP para importar una clase, puedes usar la directiva `@use`:


```blade
@use('App\Models\Flight')

```
Se puede proporcionar un segundo argumento a laDirectiva `@use` para alias la clase importada:


```php
@use('App\Models\Flight', 'FlightModel')

```

<a name="comments"></a>
### Comentarios

Blade también te permite definir comentarios en tus vistas. Sin embargo, a diferencia de los comentarios HTML, los comentarios de Blade no se incluyen en el HTML devuelto por tu aplicación:


```blade
{{-- This comment will not be present in the rendered HTML --}}

```

<a name="components"></a>
## Componentes

Los componentes y slots proporcionan beneficios similares a secciones, diseños e inclusiones; sin embargo, algunos pueden encontrar el modelo mental de componentes y slots más fácil de entender. Hay dos enfoques para escribir componentes: componentes basados en clases y componentes anónimos.
Para crear un componente basado en una clase, puedes usar el comando Artisan `make:component`. Para ilustrar cómo usar componentes, crearemos un simple componente `Alert`. El comando `make:component` colocará el componente en el directorio `app/View/Components`:


```shell
php artisan make:component Alert

```
El comando `make:component` también creará una plantilla de vista para el componente. La vista se colocará en el directorio `resources/views/components`. Al escribir componentes para tu propia aplicación, los componentes se descubren automáticamente dentro del directorio `app/View/Components` y el directorio `resources/views/components`, por lo que normalmente no se requiere un registro adicional de componentes.
También puedes crear componentes dentro de subdirectorios:


```shell
php artisan make:component Forms/Input

```
El comando anterior creará un componente `Input` en el directorio `app/View/Components/Forms` y la vista se colocará en el directorio `resources/views/components/forms`.
Si deseas crear un componente anónimo (un componente con solo una plantilla Blade y sin clase), puedes usar la opción `--view` al invocar el comando `make:component`:


```shell
php artisan make:component forms.input --view

```
El comando anterior creará un archivo Blade en `resources/views/components/forms/input.blade.php`, que se puede renderizar como un componente a través de `<x-forms.input />`.

<a name="manually-registering-package-components"></a>
#### Registrando Componentes del Paquete Manualmente

Sin embargo, si estás construyendo un paquete que utiliza componentes Blade, necesitarás registrar manualmente tu clase de componente y su alias de etiqueta HTML. Típicamente, debes registrar tus componentes en el método `boot` del proveedor de servicios de tu paquete:


```php
use Illuminate\Support\Facades\Blade;

/**
 * Bootstrap your package's services.
 */
public function boot(): void
{
    Blade::component('package-alert', Alert::class);
}
```

<a name="rendering-components"></a>
### Renderizando Componentes

Para mostrar un componente, puedes usar una etiqueta de componente Blade dentro de una de tus plantillas Blade. Las etiquetas de componente Blade comienzan con la cadena `x-` seguida del nombre en kebab case de la clase del componente:


```blade
<x-alert/>

<x-user-profile/>

```
Si la clase del componente está anidada más profundamente dentro del directorio `app/View/Components`, puedes usar el carácter `.` para indicar la anidación de directorios. Por ejemplo, si asumimos que un componente se encuentra en `app/View/Components/Inputs/Button.php`, podemos renderizarlo de la siguiente manera:
Si deseas renderizar tu componente de manera condicional, puedes definir un método `shouldRender` en la clase de tu componente. Si el método `shouldRender` devuelve `false`, el componente no será renderizado:


```php
use Illuminate\Support\Str;

/**
 * Whether the component should be rendered
 */
public function shouldRender(): bool
{
    return Str::length($this->message) > 0;
}
```

<a name="passing-data-to-components"></a>
### Pasando Datos a Componentes

Puedes pasar datos a componentes Blade utilizando atributos HTML. Los valores primitivos fijos pueden pasarse al componente utilizando cadenas de atributos HTML simples. Las expresiones y variables de PHP deben pasarse al componente a través de atributos que usen el carácter `:` como prefijo:


```blade
<x-alert type="error" :message="$message"/>

```
Debes definir todos los atributos de datos del componente en su constructor de clase. Todas las propiedades públicas en un componente estarán disponibles automáticamente para la vista del componente. No es necesario pasar los datos a la vista desde el método `render` del componente:


```php
<?php

namespace App\View\Components;

use Illuminate\View\Component;
use Illuminate\View\View;

class Alert extends Component
{
    /**
     * Create the component instance.
     */
    public function __construct(
        public string $type,
        public string $message,
    ) {}

    /**
     * Get the view / contents that represent the component.
     */
    public function render(): View
    {
        return view('components.alert');
    }
}
```
Cuando se renderiza tu componente, puedes mostrar el contenido de las variables públicas de tu componente haciendo eco de las variables por nombre:


```blade
<div class="alert alert-{{ $type }}">
    {{ $message }}
</div>

```

<a name="casing"></a>
#### Mayúsculas y minúsculas

Los argumentos del constructor del componente deben especificarse utilizando `camelCase`, mientras que se debe usar `kebab-case` al referirse a los nombres de los argumentos en tus atributos HTML. Por ejemplo, dado el siguiente constructor de componente:


```php
/**
 * Create the component instance.
 */
public function __construct(
    public string $alertType,
) {}
```
El argumento `$alertType` puede proporcionarse al componente de la siguiente manera:


```blade
<x-alert alert-type="danger" />

```

<a name="short-attribute-syntax"></a>
#### Sintaxis de Atributo Corto

Al pasar atributos a los componentes, también puedes usar una sintaxis de "atributo corto". Esto es a menudo conveniente ya que los nombres de los atributos a menudo coinciden con los nombres de las variables a las que corresponden:


```blade
{{-- Short attribute syntax... --}}
<x-profile :$userId :$name />

{{-- Is equivalent to... --}}
<x-profile :user-id="$userId" :name="$name" />

```

<a name="escaping-attribute-rendering"></a>
#### Escapeando la Renderización de Atributos

Dado que algunos frameworks de JavaScript como Alpine.js también utilizan atributos con prefijo de dos puntos, puedes usar un prefijo de doble dos puntos (`::`) para informar a Blade que el atributo no es una expresión PHP. Por ejemplo, dado el siguiente componente:


```blade
<x-button ::class="{ danger: isDeleting }">
    Submit
</x-button>

```
El siguiente HTML será renderizado por Blade:


```blade
<button :class="{ danger: isDeleting }">
    Submit
</button>

```

<a name="component-methods"></a>
#### Métodos de Componente

Además de que las variables públicas estén disponibles en la plantilla de tu componente, se pueden invocar cualquier método público en el componente. Por ejemplo, imagina un componente que tiene un método `isSelected`:


```php
/**
 * Determine if the given option is the currently selected option.
 */
public function isSelected(string $option): bool
{
    return $option === $this->selected;
}
```
Puedes ejecutar este método desde la plantilla de tu componente invocando la variable que coincide con el nombre del método:


```blade
<option {{ $isSelected($value) ? 'selected' : '' }} value="{{ $value }}">
    {{ $label }}
</option>

```

<a name="using-attributes-slots-within-component-class"></a>
#### Accediendo a Atributos y Slots Dentro de Clases de Componentes

Los componentes Blade también te permiten acceder al nombre del componente, los atributos y el slot dentro del método render de la clase. Sin embargo, para acceder a estos datos, debes devolver una función anónima desde el método `render` de tu componente:


```php
use Closure;

/**
 * Get the view / contents that represent the component.
 */
public function render(): Closure
{
    return function () {
        return '<div {{ $attributes }}>Components content</div>';
    };
}
```
La función anónima devuelta por el método `render` de tu componente también puede recibir un array `$data` como su único argumento. Este array contendrá varios elementos que proporcionan información sobre el componente:


```php
return function (array $data) {
    // $data['componentName'];
    // $data['attributes'];
    // $data['slot'];

    return '<div {{ $attributes }}>Components content</div>';
}
```
> [!WARNING]
Los elementos en el array `$data` nunca deben ser incrustados directamente en la cadena Blade devuelta por tu método `render`, ya que hacerlo podría permitir la ejecución remota de código a través del contenido de atributos maliciosos.
El `componentName` es igual al nombre utilizado en la etiqueta HTML después del prefijo `x-`. Así que el `componentName` de `<x-alert />` será `alert`. El elemento `attributes` contendrá todos los atributos que estaban presentes en la etiqueta HTML. El elemento `slot` es una instancia de `Illuminate\Support\HtmlString` con el contenido de la ranura del componente.
La función anónima debe devolver una cadena. Si la cadena devuelta corresponde a una vista existente, esa vista se renderizará; de lo contrario, la cadena devuelta se evaluará como una vista Blade en línea.

<a name="additional-dependencies"></a>
#### Dependencias Adicionales

Si tu componente requiere dependencias del [contenedor de servicios](/docs/%7B%7Bversion%7D%7D/container) de Laravel, puedes listarlas antes de cualquiera de los atributos de datos del componente y serán inyectadas automáticamente por el contenedor:


```php
use App\Services\AlertCreator;

/**
 * Create the component instance.
 */
public function __construct(
    public AlertCreator $creator,
    public string $type,
    public string $message,
) {}

```

<a name="hiding-attributes-and-methods"></a>
#### Ocultando Atributos / Métodos

Si deseas evitar que algunos métodos o propiedades públicas se expongan como variables a la plantilla de tu componente, puedes añadirlos a un array de propiedad `$except` en tu componente:


```php
<?php

namespace App\View\Components;

use Illuminate\View\Component;

class Alert extends Component
{
    /**
     * The properties / methods that should not be exposed to the component template.
     *
     * @var array
     */
    protected $except = ['type'];

    /**
     * Create the component instance.
     */
    public function __construct(
        public string $type,
    ) {}
}
```

<a name="component-attributes"></a>
### Atributos de Componente

Ya hemos examinado cómo pasar atributos de datos a un componente; sin embargo, a veces es posible que necesites especificar atributos HTML adicionales, como `class`, que no son parte de los datos requeridos para que un componente funcione. Típicamente, deseas pasar estos atributos adicionales al elemento raíz de la plantilla del componente. Por ejemplo, imagina que queremos renderizar un componente de `alerta` así:


```blade
<x-alert type="error" :message="$message" class="mt-4"/>

```
Todos los atributos que no son parte del constructor del componente se añadirán automáticamente al "atributo bag" del componente. Este atributo bag se pone a disposición del componente mediante la variable `$attributes`. Todos los atributos pueden ser renderizados dentro del componente al echo de esta variable:


```blade
<div {{ $attributes }}>
    <!-- Component content -->
</div>

```
> [!WARNING]
Usar directivas como `@env` dentro de etiquetas de componente no es compatible en este momento. Por ejemplo, `<x-alert :live="@env('production')"/>` no será compilado.

<a name="default-merged-attributes"></a>
#### Atributos Predeterminados / Combinados

A veces es posible que necesites especificar valores predeterminados para atributos o fusionar valores adicionales en algunos de los atributos del componente. Para lograr esto, puedes usar el método `merge` de la bolsa de atributos. Este método es especialmente útil para definir un conjunto de clases CSS predeterminadas que deben aplicarse siempre a un componente:


```blade
<div {{ $attributes->merge(['class' => 'alert alert-'.$type]) }}>
    {{ $message }}
</div>

```
Si asumimos que este componente se utiliza de la siguiente manera:
El HTML final renderizado del componente aparecerá como el siguiente:


```blade
<div class="alert alert-error mb-4">
    <!-- Contents of the $message variable -->
</div>

```

<a name="conditionally-merge-classes"></a>
#### Merging Clases de Forma Condicional

A veces es posible que desees combinar clases si una condición dada es `true`. Puedes lograr esto a través del método `class`, que acepta un array de clases donde la clave del array contiene la clase o las clases que deseas agregar, mientras que el valor es una expresión booleana. Si el elemento del array tiene una clave numérica, siempre se incluirá en la lista de clases renderizadas:


```blade
<div {{ $attributes->class(['p-4', 'bg-red' => $hasError]) }}>
    {{ $message }}
</div>

```
Si necesitas combinar otros atributos en tu componente, puedes encadenar el método `merge` al método `class`:


```blade
<button {{ $attributes->class(['p-4'])->merge(['type' => 'button']) }}>
    {{ $slot }}
</button>

```
> [!NOTA]
Si necesitas compilar clases de forma condicional en otros elementos HTML que no deberían recibir atributos combinados, puedes usar la directiva [`@class`](#conditional-classes).

<a name="non-class-attribute-merging"></a>
#### Fusión de Atributos No de Clase

Al fusionar atributos que no son atributos `class`, los valores proporcionados al método `merge` se considerarán los "valores predeterminados" del atributo. Sin embargo, a diferencia del atributo `class`, estos atributos no se fusionarán con los valores de atributo inyectados. En su lugar, serán sobrescritos. Por ejemplo, la implementación de un componente `button` puede verse como la siguiente:


```blade
<button {{ $attributes->merge(['type' => 'button']) }}>
    {{ $slot }}
</button>

```
Para renderizar el componente de botón con un `type` personalizado, se puede especificar al consumir el componente. Si no se especifica ningún tipo, se utilizará el tipo `button`:


```blade
<x-button type="submit">
    Submit
</x-button>

```
El HTML renderizado del componente `button` en este ejemplo sería:


```blade
<button type="submit">
    Submit
</button>

```
Si deseas que un atributo diferente de `class` tenga su valor predeterminado y los valores inyectados juntos, puedes usar el método `prepends`. En este ejemplo, el atributo `data-controller` siempre comenzará con `profile-controller` y cualquier valor `data-controller` inyectado adicional se colocará después de este valor predeterminado:


```blade
<div {{ $attributes->merge(['data-controller' => $attributes->prepends('profile-controller')]) }}>
    {{ $slot }}
</div>

```

<a name="filtering-attributes"></a>
#### Recuperando y Filtrando Atributos

Puedes filtrar atributos utilizando el método `filter`. Este método acepta una función anónima que debe devolver `true` si deseas mantener el atributo en la bolsa de atributos:


```blade
{{ $attributes->filter(fn (string $value, string $key) => $key == 'foo') }}

```
Para conveniencia, puedes usar el método `whereStartsWith` para recuperar todos los atributos cuyas claves comienzan con una cadena dada:


```blade
{{ $attributes->whereStartsWith('wire:model') }}

```
Por el contrario, el método `whereDoesntStartWith` se puede utilizar para excluir todos los atributos cuyos keys comiencen con una cadena dada:


```blade
{{ $attributes->whereDoesntStartWith('wire:model') }}

```
Usando el método `first`, puedes renderizar el primer atributo en un paquete de atributos dado:


```blade
{{ $attributes->whereStartsWith('wire:model')->first() }}

```
Si deseas verificar si un atributo está presente en el componente, puedes usar el método `has`. Este método acepta el nombre del atributo como su único argumento y devuelve un booleano que indica si el atributo está presente o no:


```blade
@if ($attributes->has('class'))
    <div>Class attribute is present</div>
@endif

```
Si se pasa un array al método `has`, el método determinará si todos los atributos dados están presentes en el componente:


```blade
@if ($attributes->has(['name', 'class']))
    <div>All of the attributes are present</div>
@endif

```
El método `hasAny` se puede utilizar para determinar si cualquiera de los atributos dados está presente en el componente:


```blade
@if ($attributes->hasAny(['href', ':href', 'v-bind:href']))
    <div>One of the attributes is present</div>
@endif

```
Puedes recuperar el valor de un atributo específico utilizando el método `get`:


```blade
{{ $attributes->get('class') }}

```

<a name="reserved-keywords"></a>
### Palabras Clave Reservadas

Por defecto, algunas palabras clave están reservadas para el uso interno de Blade con el fin de renderizar componentes. Las siguientes palabras clave no pueden definirse como propiedades públicas o nombres de métodos dentro de tus componentes:
<div class="content-list" markdown="1">

- `data`
- `render`
- `resolveView`
- `shouldRender`
- `view`
- `withAttributes`
- `withName`
</div>

<a name="slots"></a>
### Slots

A menudo necesitarás pasar contenido adicional a tu componente a través de "slots". Los slots del componente se renderizan mediante la variable `$slot`. Para explorar este concepto, imaginemos que un componente `alert` tiene el siguiente marcado:


```blade
<!-- /resources/views/components/alert.blade.php -->

<div class="alert alert-danger">
    {{ $slot }}
</div>

```
Podemos pasar contenido al `slot` inyectando contenido en el componente:


```blade
<x-alert>
    <strong>Whoops!</strong> Something went wrong!
</x-alert>

```
A veces un componente puede necesitar renderizar múltiples ranuras diferentes en diferentes ubicaciones dentro del componente. Modifiquemos nuestro componente de alerta para permitir la inyección de una ranura de "título":


```blade
<!-- /resources/views/components/alert.blade.php -->

<span class="alert-title">{{ $title }}</span>

<div class="alert alert-danger">
    {{ $slot }}
</div>

```
Puedes definir el contenido del slot nombrado utilizando la etiqueta `x-slot`. Cualquier contenido que no esté dentro de una etiqueta `x-slot` explícita se pasará al componente en la variable `$slot`:


```xml
<x-alert>
    <x-slot:title>
        Server Error
    </x-slot>

    <strong>Whoops!</strong> Something went wrong!
</x-alert>

```
Puedes invocar el método `isEmpty` de un slot para determinar si el slot contiene contenido:


```blade
<span class="alert-title">{{ $title }}</span>

<div class="alert alert-danger">
    @if ($slot->isEmpty())
        This is default content if the slot is empty.
    @else
        {{ $slot }}
    @endif
</div>

```
Además, se puede usar el método `hasActualContent` para determinar si el espacio contiene algún contenido "real" que no sea un comentario HTML:


```blade
@if ($slot->hasActualContent())
    The scope has non-comment content.
@endif

```

<a name="scoped-slots"></a>
#### Slots Con Alcance

Si has utilizado un framework de JavaScript como Vue, es posible que estés familiarizado con los "scoped slots", que te permiten acceder a datos o métodos del componente dentro de tu slot. Puedes lograr un comportamiento similar en Laravel definiendo métodos o propiedades públicos en tu componente y accediendo al componente dentro de tu slot a través de la variable `$component`. En este ejemplo, asumiremos que el componente `x-alert` tiene un método público `formatAlert` definido en su clase de componente:


```blade
<x-alert>
    <x-slot:title>
        {{ $component->formatAlert('Server Error') }}
    </x-slot>

    <strong>Whoops!</strong> Something went wrong!
</x-alert>

```

<a name="slot-attributes"></a>
#### Atributos de Slot

Al igual que con los componentes Blade, puedes asignar [atributos](#component-attributes) adicionales a los slots, como nombres de clases CSS:


```xml
<x-card class="shadow-sm">
    <x-slot:heading class="font-bold">
        Heading
    </x-slot>

    Content

    <x-slot:footer class="text-sm">
        Footer
    </x-slot>
</x-card>

```
Para interactuar con los atributos del slot, puedes acceder a la propiedad `attributes` de la variable del slot. Para obtener más información sobre cómo interactuar con los atributos, consulta la documentación sobre [atributos de componente](#component-attributes):


```blade
@props([
    'heading',
    'footer',
])

<div {{ $attributes->class(['border']) }}>
    <h1 {{ $heading->attributes->class(['text-lg']) }}>
        {{ $heading }}
    </h1>

    {{ $slot }}

    <footer {{ $footer->attributes->class(['text-gray-700']) }}>
        {{ $footer }}
    </footer>
</div>

```

<a name="inline-component-views"></a>
### Vistas de Componente en Línea

Para componentes muy pequeños, puede resultar engorroso gestionar tanto la clase del componente como la plantilla de vista del componente. Por esta razón, puedes devolver el marcado del componente directamente desde el método `render`:


```php
/**
 * Get the view / contents that represent the component.
 */
public function render(): string
{
    return <<<'blade'
        <div class="alert alert-danger">
            {{ $slot }}
        </div>
    blade;
}
```

<a name="generating-inline-view-components"></a>
#### Generando Componentes de Vista En línea

Para crear un componente que renderice una vista en línea, puedes usar la opción `inline` al ejecutar el comando `make:component`:


```shell
php artisan make:component Alert --inline

```

<a name="dynamic-components"></a>
### Componentes Dinámicos

A veces puede que necesites renderizar un componente pero no sepas qué componente debe ser renderizado hasta el tiempo de ejecución. En esta situación, puedes usar el componente `dynamic-component` incorporado de Laravel para renderizar el componente en función de un valor o variable en tiempo de ejecución:


```blade
// $componentName = "secondary-button";

<x-dynamic-component :component="$componentName" class="mt-4" />

```

<a name="manually-registering-components"></a>
### Registrando Componentes Manualmente

> [!WARNING]
La siguiente documentación sobre el registro manual de componentes se aplica principalmente a aquellos que están escribiendo paquetes Laravel que incluyen componentes de vista. Si no estás escribiendo un paquete, esta parte de la documentación del componente puede no ser relevante para ti.
Al escribir componentes para tu propia aplicación, los componentes se descubren automáticamente en el directorio `app/View/Components` y en el directorio `resources/views/components`.
Sin embargo, si estás creando un paquete que utiliza componentes Blade o colocando componentes en directorios no convencionales, necesitarás registrar manualmente tu clase de componente y su alias de etiqueta HTML para que Laravel sepa dónde encontrar el componente. Normalmente, deberías registrar tus componentes en el método `boot` del proveedor de servicios de tu paquete:


```php
use Illuminate\Support\Facades\Blade;
use VendorPackage\View\Components\AlertComponent;

/**
 * Bootstrap your package's services.
 */
public function boot(): void
{
    Blade::component('package-alert', AlertComponent::class);
}
```
Una vez que tu componente haya sido registrado, puede ser renderizado utilizando su alias de etiqueta:


```blade
<x-package-alert/>

```
#### Autoloading Package Components

Alternativamente, puedes usar el método `componentNamespace` para autoload de clases de componentes por convención. Por ejemplo, un paquete `Nightshade` podría tener componentes `Calendar` y `ColorPicker` que residen dentro del espacio de nombres `Package\Views\Components`:


```php
use Illuminate\Support\Facades\Blade;

/**
 * Bootstrap your package's services.
 */
public function boot(): void
{
    Blade::componentNamespace('Nightshade\\Views\\Components', 'nightshade');
}
```
Esto permitirá el uso de componentes del paquete por su espacio de nombres de vendedor utilizando la sintaxis `package-name::`:


```blade
<x-nightshade::calendar />
<x-nightshade::color-picker />

```
Blade detectará automáticamente la clase que está vinculada a este componente utilizando la notación Pascal para el nombre del componente. También se admiten subdirectorios utilizando la notación de "punto".

<a name="anonymous-components"></a>
## Componentes Anónimos

Similar a los componentes en línea, los componentes anónimos proporcionan un mecanismo para gestionar un componente a través de un solo archivo. Sin embargo, los componentes anónimos utilizan un solo archivo de vista y no tienen una clase asociada. Para definir un componente anónimo, solo necesitas colocar una plantilla Blade dentro de tu directorio `resources/views/components`. Por ejemplo, suponiendo que has definido un componente en `resources/views/components/alert.blade.php`, puedes renderizarlo de la siguiente manera:


```blade
<x-alert/>

```
Puedes usar el carácter `.` para indicar si un componente está anidado más profundamente dentro del directorio `components`. Por ejemplo, asumiendo que el componente se define en `resources/views/components/inputs/button.blade.php`, puedes renderizarlo así:


```blade
<x-inputs.button/>

```

<a name="anonymous-index-components"></a>
### Componentes de Índice Anónimos

A veces, cuando un componente se compone de muchas plantillas Blade, es posible que desees agrupar las plantillas del componente dado dentro de un solo directorio. Por ejemplo, imagina un componente "accordion" con la siguiente estructura de directorio:


```none
/resources/views/components/accordion.blade.php
/resources/views/components/accordion/item.blade.php

```
Esta estructura de directorios te permite renderizar el componente de acordeón y su elemento así:


```blade
<x-accordion>
    <x-accordion.item>
        ...
    </x-accordion.item>
</x-accordion>

```
Sin embargo, para poder renderizar el componente de acordeón a través de `x-accordion`, nos vimos obligados a colocar la plantilla del componente de acordeón "index" en el directorio `resources/views/components` en lugar de anidrarla dentro del directorio `accordion` con las otras plantillas relacionadas con el acordeón.
Afortunadamente, Blade te permite colocar un archivo `index.blade.php` dentro del directorio de plantillas de un componente. Cuando existe una plantilla `index.blade.php` para el componente, se renderizará como el nodo "root" del componente. Así que podemos continuar utilizando la misma sintaxis de Blade dada en el ejemplo anterior; sin embargo, ajustaremos nuestra estructura de directorios de la siguiente manera:


```none
/resources/views/components/accordion/index.blade.php
/resources/views/components/accordion/item.blade.php

```

<a name="data-properties-attributes"></a>
### Propiedades / Atributos de Datos

Dado que los componentes anónimos no tienen ninguna clase asociada, es posible que te preguntes cómo puedes diferenciar qué datos deben pasarse al componente como variables y qué atributos deben colocarse en la [bolsa de atributos](#component-attributes) del componente.
Puedes especificar qué atributos deben considerarse variables de datos utilizando la directiva `@props` en la parte superior de la plantilla Blade de tu componente. Todos los demás atributos del componente estarán disponibles a través de la bolsa de atributos del componente. Si deseas dar a una variable de datos un valor predeterminado, puedes especificar el nombre de la variable como la clave del array y el valor predeterminado como el valor del array:


```blade
<!-- /resources/views/components/alert.blade.php -->

@props(['type' => 'info', 'message'])

<div {{ $attributes->merge(['class' => 'alert alert-'.$type]) }}>
    {{ $message }}
</div>

```
Dada la definición del componente anterior, podemos renderizar el componente de la siguiente manera:


```blade
<x-alert type="error" :message="$message" class="mb-4"/>

```

<a name="accessing-parent-data"></a>
### Accediendo a los Datos del Padre

A veces es posible que desees acceder a datos de un componente padre dentro de un componente hijo. En estos casos, puedes usar la directiva `@aware`. Por ejemplo, imagina que estamos construyendo un componente de menú complejo que consiste en un padre `<x-menu>` y un hijo `<x-menu.item>`:


```blade
<x-menu color="purple">
    <x-menu.item>...</x-menu.item>
    <x-menu.item>...</x-menu.item>
</x-menu>

```
El componente `<x-menu>` puede tener una implementación como la siguiente:


```blade
<!-- /resources/views/components/menu/index.blade.php -->

@props(['color' => 'gray'])

<ul {{ $attributes->merge(['class' => 'bg-'.$color.'-200']) }}>
    {{ $slot }}
</ul>

```
Debido a que la prop `color` solo se pasó al padre (`<x-menu>`), no estará disponible dentro de `<x-menu.item>`. Sin embargo, si usamos la directiva `@aware`, podemos hacer que esté disponible dentro de `<x-menu.item>` también:


```blade
<!-- /resources/views/components/menu/item.blade.php -->

@aware(['color' => 'gray'])

<li {{ $attributes->merge(['class' => 'text-'.$color.'-800']) }}>
    {{ $slot }}
</li>

```
> [!WARNING]
La directiva `@aware` no puede acceder a los datos del padre que no se pasan explícitamente al componente padre a través de atributos HTML. Los valores predeterminados `@props` que no se pasan explícitamente al componente padre no pueden ser accesibles por la directiva `@aware`.

<a name="anonymous-component-paths"></a>
### Rutas de Componentes Anónimos

Como se discutió anteriormente, los componentes anónimos suelen definirse colocando una plantilla Blade dentro de tu directorio `resources/views/components`. Sin embargo, es posible que desees registrar ocasionalmente otras rutas de componentes anónimos con Laravel además de la ruta predeterminada.
El método `anonymousComponentPath` acepta la "ruta" a la ubicación del componente anónimo como su primer argumento y un "espacio de nombres" opcional bajo el cual se deben colocar los componentes como su segundo argumento. Típicamente, este método debe ser llamado desde el método `boot` de uno de los [proveedores de servicios](/docs/%7B%7Bversion%7D%7D/providers) de tu aplicación:


```php
/**
 * Bootstrap any application services.
 */
public function boot(): void
{
    Blade::anonymousComponentPath(__DIR__.'/../components');
}
```
Cuando las rutas de componentes se registran sin un prefijo especificado, como en el ejemplo anterior, se pueden renderizar en tus componentes Blade sin un prefijo correspondiente también. Por ejemplo, si existe un componente `panel.blade.php` en la ruta registrada arriba, se puede renderizar así:


```blade
<x-panel />

```
El prefijo "namespaces" puede proporcionarse como segundo argumento al método `anonymousComponentPath`:


```php
Blade::anonymousComponentPath(__DIR__.'/../components', 'dashboard');
```
Cuando se proporciona un prefijo, los componentes dentro de ese "espacio de nombres" pueden ser renderizados añadiendo el espacio de nombres del componente al nombre del componente cuando se renderiza el componente:


```blade
<x-dashboard::panel />

```

<a name="building-layouts"></a>
## Construyendo Diseños


<a name="layouts-using-components"></a>
### Diseños Usando Componentes

La mayoría de las aplicaciones web mantienen el mismo diseño general en varias páginas. Sería increíblemente engorroso y difícil de mantener nuestra aplicación si tuviéramos que repetir todo el HTML del diseño en cada vista que creamos. Afortunadamente, es conveniente definir este diseño como un solo [componente Blade](#components) y luego usarlo en toda nuestra aplicación.

<a name="defining-the-layout-component"></a>
#### Definiendo el Componente de Layout

Por ejemplo, imagina que estamos construyendo una aplicación de lista de "tareas". Podríamos definir un componente `layout` que se vea de la siguiente manera:


```blade
<!-- resources/views/components/layout.blade.php -->

<html>
    <head>
        <title>{{ $title ?? 'Todo Manager' }}</title>
    </head>
    <body>
        <h1>Todos</h1>
        <hr/>
        {{ $slot }}
    </body>
</html>

```

<a name="applying-the-layout-component"></a>
#### Aplicando el Componente de Layout

Una vez que se ha definido el componente `layout`, podemos crear una vista Blade que utilice el componente. En este ejemplo, definiremos una vista simple que muestra nuestra lista de tareas:


```blade
<!-- resources/views/tasks.blade.php -->

<x-layout>
    @foreach ($tasks as $task)
        <div>{{ $task }}</div>
    @endforeach
</x-layout>

```
Recuerda que el contenido que se inyecta en un componente se suministrará a la variable `$slot` predeterminada dentro de nuestro componente `layout`. Como habrás notado, nuestro `layout` también respeta un slot `$title` si se proporciona uno; de lo contrario, se muestra un título predeterminado. Podemos inyectar un título personalizado desde nuestra vista de lista de tareas utilizando la sintaxis de slot estándar discutida en la [documentación de componentes](#components):


```blade
<!-- resources/views/tasks.blade.php -->

<x-layout>
    <x-slot:title>
        Custom Title
    </x-slot>

    @foreach ($tasks as $task)
        <div>{{ $task }}</div>
    @endforeach
</x-layout>

```
Ahora que hemos definido nuestras vistas de diseño y lista de tareas, solo necesitamos devolver la vista `task` desde una ruta:


```php
use App\Models\Task;

Route::get('/tasks', function () {
    return view('tasks', ['tasks' => Task::all()]);
});
```

<a name="layouts-using-template-inheritance"></a>
### Diseños Usando Herencia de Plantillas


<a name="defining-a-layout"></a>
#### Definiendo un Layout

Los layouts también pueden ser creados a través de "herencia de plantillas". Esta fue la principal forma de construir aplicaciones antes de la introducción de [componentes](#components).
Para empezar, echemos un vistazo a un ejemplo simple. Primero, examinaremos un diseño de página. Dado que la mayoría de las aplicaciones web mantienen el mismo diseño general en varias páginas, es conveniente definir este diseño como una sola vista de Blade:


```blade
<!-- resources/views/layouts/app.blade.php -->

<html>
    <head>
        <title>App Name - @yield('title')</title>
    </head>
    <body>
        @section('sidebar')
            This is the master sidebar.
        @show

        <div class="container">
            @yield('content')
        </div>
    </body>
</html>

```
Como puedes ver, este archivo contiene un marcado HTML típico. Sin embargo, toma nota de las directivas `@section` y `@yield`. La directiva `@section`, como su nombre indica, define una sección de contenido, mientras que la directiva `@yield` se utiliza para mostrar el contenido de una sección dada.
Ahora que hemos definido un diseño para nuestra aplicación, definamos una página hija que herede el diseño.

<a name="extending-a-layout"></a>
#### Extendiendo un Layout

Al definir una vista hija, utiliza la directiva `@extends` de Blade para especificar qué diseño debería "heredar" la vista hija. Las vistas que extienden un diseño Blade pueden inyectar contenido en las secciones del diseño utilizando directivas `@section`. Recuerda que, como se vio en el ejemplo anterior, el contenido de estas secciones se mostrará en el diseño utilizando `@yield`:


```blade
<!-- resources/views/child.blade.php -->

@extends('layouts.app')

@section('title', 'Page Title')

@section('sidebar')
    @@parent

    <p>This is appended to the master sidebar.</p>
@endsection

@section('content')
    <p>This is my body content.</p>
@endsection

```
En este ejemplo, la sección `sidebar` está utilizando la directiva `@@parent` para añadir (en lugar de sobrescribir) contenido a la barra lateral del diseño. La directiva `@@parent` será reemplazada por el contenido del diseño cuando se renderice la vista.
> [!NOTA]
A diferencia del ejemplo anterior, esta sección `sidebar` termina con `@endsection` en lugar de `@show`. La directiva `@endsection` solo definirá una sección, mientras que `@show` definirá y **cederá inmediatamente** la sección.
La directiva `@yield` también acepta un valor predeterminado como su segundo parámetro. Este valor se renderizará si la sección que se está cediendo es indefinida:


```blade
@yield('content', 'Default content')

```

<a name="forms"></a>
## Formularios


<a name="csrf-field"></a>
### Campo CSRF

Siempre que definas un formulario HTML en tu aplicación, debes incluir un campo de token CSRF oculto en el formulario para que el middleware [de protección CSRF](/docs/%7B%7Bversion%7D%7D/csrf) pueda validar la solicitud. Puedes usar la directiva `@csrf` de Blade para generar el campo de token:


```blade
<form method="POST" action="/profile">
    @csrf

    ...
</form>

```

<a name="method-field"></a>
### Campo de Método

Dado que los formularios HTML no pueden hacer solicitudes `PUT`, `PATCH` o `DELETE`, necesitarás añadir un campo oculto `_method` para simular estos verbos HTTP. La directiva `@method` de Blade puede crear este campo por ti:


```blade
<form action="/foo/bar" method="POST">
    @method('PUT')

    ...
</form>

```

<a name="validation-errors"></a>
### Errores de Validación

La directiva `@error` se puede usar para verificar rápidamente si existen [mensajes de error de validación](/docs/%7B%7Bversion%7D%7D/validation#quick-displaying-the-validation-errors) para un atributo dado. Dentro de una directiva `@error`, puedes mostrar la variable `$message` para mostrar el mensaje de error:


```blade
<!-- /resources/views/post/create.blade.php -->

<label for="title">Post Title</label>

<input id="title"
    type="text"
    class="@error('title') is-invalid @enderror">

@error('title')
    <div class="alert alert-danger">{{ $message }}</div>
@enderror

```
Dado que la directiva `@error` se compila a una declaración "if", puedes usar la directiva `@else` para renderizar contenido cuando no hay un error para un atributo:


```blade
<!-- /resources/views/auth.blade.php -->

<label for="email">Email address</label>

<input id="email"
    type="email"
    class="@error('email') is-invalid @else is-valid @enderror">

```
Puedes pasar [el nombre de un grupo de errores específico](/docs/%7B%7Bversion%7D%7D/validation#named-error-bags) como segundo parámetro a la directiva `@error` para recuperar mensajes de error de validación en páginas que contienen múltiples formularios:


```blade
<!-- /resources/views/auth.blade.php -->

<label for="email">Email address</label>

<input id="email"
    type="email"
    class="@error('email', 'login') is-invalid @enderror">

@error('email', 'login')
    <div class="alert alert-danger">{{ $message }}</div>
@enderror

```

<a name="stacks"></a>
## Pilas

Blade te permite añadir a pilas nombradas que pueden ser renderizadas en otra vista o diseño. Esto puede ser particularmente útil para especificar cualquier biblioteca de JavaScript requerida por tus vistas secundarias:


```blade
@push('scripts')
    <script src="/example.js"></script>
@endpush

```
Si deseas `@push` contenido si una expresión booleana dada evalúa a `true`, puedes usar la directiva `@pushIf`:


```blade
@pushIf($shouldPush, 'scripts')
    <script src="/example.js"></script>
@endPushIf

```
Puedes apilar tantas veces como sea necesario. Para renderizar el contenido completo de la pila, pasa el nombre de la pila a la directiva `@stack`:


```blade
<head>
    <!-- Head Contents -->

    @stack('scripts')
</head>

```
Si deseas añadir contenido al inicio de una pila, debes usar la directiva `@prepend`:


```blade
@push('scripts')
    This will be second...
@endpush

// Later...

@prepend('scripts')
    This will be first...
@endprepend

```

<a name="service-injection"></a>
## Inyección de Servicio

La directiva `@inject` se puede usar para recuperar un servicio del [contenedor de servicios](/docs/%7B%7Bversion%7D%7D/container) de Laravel. El primer argumento pasado a `@inject` es el nombre de la variable en la que se colocará el servicio, mientras que el segundo argumento es el nombre de la clase o la interfaz del servicio que deseas resolver:


```blade
@inject('metrics', 'App\Services\MetricsService')

<div>
    Monthly Revenue: {{ $metrics->monthlyRevenue() }}.
</div>

```

<a name="rendering-inline-blade-templates"></a>
## Renderizando Plantillas Blade en Línea

A veces puede que necesites transformar una cadena de plantilla Blade sin procesar en HTML válido. Puedes lograr esto usando el método `render` proporcionado por la fachada `Blade`. El método `render` acepta la cadena de plantilla Blade y un array opcional de datos para proporcionar a la plantilla:


```php
use Illuminate\Support\Facades\Blade;

return Blade::render('Hello, {{ $name }}', ['name' => 'Julian Bashir']);

```
Laravel renderiza plantillas Blade en línea escribiéndolas en el directorio `storage/framework/views`. Si deseas que Laravel elimine estos archivos temporales después de renderizar la plantilla Blade, puedes proporcionar el argumento `deleteCachedView` al método:


```php
return Blade::render(
    'Hello, {{ $name }}',
    ['name' => 'Julian Bashir'],
    deleteCachedView: true
);

```

<a name="rendering-blade-fragments"></a>
## Renderizando Fragmentos de Blade

Al utilizar frameworks frontend como [Turbo](https://turbo.hotwired.dev/) y [htmx](https://htmx.org/), es posible que en ocasiones necesites devolver solo una porción de una plantilla Blade dentro de tu respuesta HTTP. Los "fragmentos" de Blade te permiten hacer exactamente eso. Para comenzar, coloca una porción de tu plantilla Blade dentro de las directivas `@fragment` y `@endfragment`:


```blade
@fragment('user-list')
    <ul>
        @foreach ($users as $user)
            <li>{{ $user->name }}</li>
        @endforeach
    </ul>
@endfragment

```
Entonces, al renderizar la vista que utiliza esta plantilla, puedes invocar el método `fragment` para especificar que solo el fragmento especificado debe incluirse en la respuesta HTTP saliente:


```php
return view('dashboard', ['users' => $users])->fragment('user-list');

```
El método `fragmentIf` te permite devolver condicionalmente un fragmento de una vista basado en una condición dada. De lo contrario, se devolverá la vista completa:


```php
return view('dashboard', ['users' => $users])
    ->fragmentIf($request->hasHeader('HX-Request'), 'user-list');

```
Los métodos `fragments` y `fragmentsIf` te permiten devolver múltiples fragmentos de vista en la respuesta. Los fragmentos se concatenarán:


```php
view('dashboard', ['users' => $users])
    ->fragments(['user-list', 'comment-list']);

view('dashboard', ['users' => $users])
    ->fragmentsIf(
        $request->hasHeader('HX-Request'),
        ['user-list', 'comment-list']
    );

```

<a name="extending-blade"></a>
## Extendiendo Blade

Blade te permite definir tus propias directivas personalizadas utilizando el método `directive`. Cuando el compilador de Blade encuentra la directiva personalizada, llamará a la devolución de llamada proporcionada con la expresión que contiene la directiva.
El siguiente ejemplo crea un directive `@datetime($var)` que formatea un `$var` dado, que debe ser una instancia de `DateTime`:


```php
<?php

namespace App\Providers;

use Illuminate\Support\Facades\Blade;
use Illuminate\Support\ServiceProvider;

class AppServiceProvider extends ServiceProvider
{
    /**
     * Register any application services.
     */
    public function register(): void
    {
        // ...
    }

    /**
     * Bootstrap any application services.
     */
    public function boot(): void
    {
        Blade::directive('datetime', function (string $expression) {
            return "<?php echo ($expression)->format('m/d/Y H:i'); ?>";
        });
    }
}
```
Como puedes ver, encadenaremos el método `format` a cualquier expresión que se pase a la directiva. Así que, en este ejemplo, el PHP final generado por esta directiva será:


```php
<?php echo ($var)->format('m/d/Y H:i'); ?>
```
> [!WARNING]
Después de actualizar la lógica de un directivo de Blade, necesitarás eliminar todas las vistas de Blade en caché. Las vistas de Blade en caché pueden ser eliminadas utilizando el comando Artisan `view:clear`.

<a name="custom-echo-handlers"></a>
### Controladores Echo Personalizados

Si intentas "echo" un objeto utilizando Blade, se invocará el método `__toString` del objeto. El método [`__toString`](https://www.php.net/manual/en/language.oop5.magic.php#object.tostring) es uno de los "métodos mágicos" integrados de PHP. Sin embargo, a veces puede que no tengas control sobre el método `__toString` de una clase dada, como cuando la clase con la que estás interactuando pertenece a una biblioteca de terceros.
En estos casos, Blade te permite registrar un manejador de eco personalizado para ese tipo particular de objeto. Para lograr esto, debes invocar el método `stringable` de Blade. El método `stringable` acepta una función anónima. Esta función anónima debe indicar el tipo de objeto que es responsable de renderizar. Típicamente, el método `stringable` debe invocarse dentro del método `boot` de la clase `AppServiceProvider` de tu aplicación:


```php
use Illuminate\Support\Facades\Blade;
use Money\Money;

/**
 * Bootstrap any application services.
 */
public function boot(): void
{
    Blade::stringable(function (Money $money) {
        return $money->formatTo('en_GB');
    });
}
```
Una vez que tu manejador de eco personalizado haya sido definido, simplemente puedes hacer eco del objeto en tu plantilla Blade:


```blade
Cost: {{ $money }}

```

<a name="custom-if-statements"></a>
### Declaraciones If Personalizadas

Programar una directiva personalizada a veces es más complejo de lo necesario al definir declaraciones condicionales personalizadas simples. Por esa razón, Blade ofrece un método `Blade::if` que te permite definir rápidamente directivas condicionales personalizadas utilizando `funciones anónimas`. Por ejemplo, definamos una condicional personalizada que verifique el "disk" predeterminado configurado para la aplicación. Podemos hacer esto en el método `boot` de nuestro `AppServiceProvider`:


```php
use Illuminate\Support\Facades\Blade;

/**
 * Bootstrap any application services.
 */
public function boot(): void
{
    Blade::if('disk', function (string $value) {
        return config('filesystems.default') === $value;
    });
}
```
Una vez que se haya definido la condición personalizada, puedes usarla dentro de tus plantillas:


```blade
@disk('local')
    <!-- The application is using the local disk... -->
@elsedisk('s3')
    <!-- The application is using the s3 disk... -->
@else
    <!-- The application is using some other disk... -->
@enddisk

@unlessdisk('local')
    <!-- The application is not using the local disk... -->
@enddisk

```