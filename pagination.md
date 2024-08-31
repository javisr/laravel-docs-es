# Base de datos: Paginación

- [Introducción](#introduction)
- [Uso Básico](#basic-usage)
  - [Paginar Resultados del Constructor de Consultas](#paginating-query-builder-results)
  - [Paginar Resultados de Eloquent](#paginating-eloquent-results)
  - [Paginación con Cursor](#cursor-pagination)
  - [Crear un Paginador Manualmente](#manually-creating-a-paginator)
  - [Personalizar URLs de Paginación](#customizing-pagination-urls)
- [Mostrar Resultados de Paginación](#displaying-pagination-results)
  - [Ajustar la Ventana de Enlaces de Paginación](#adjusting-the-pagination-link-window)
  - [Convertir Resultados a JSON](#converting-results-to-json)
- [Personalizar la Vista de Paginación](#customizing-the-pagination-view)
  - [Usando Bootstrap](#using-bootstrap)
- [Métodos de Instancia de Paginator y LengthAwarePaginator](#paginator-instance-methods)
- [Métodos de Instancia de Cursor Paginator](#cursor-paginator-instance-methods)

<a name="introduction"></a>
## Introducción

En otros frameworks, la paginación puede ser muy dolorosa. Esperamos que el enfoque de Laravel para la paginación sea un soplo de aire fresco. El paginador de Laravel está integrado con el [constructor de consultas](/docs/%7B%7Bversion%7D%7D/queries) y [Eloquent ORM](/docs/%7B%7Bversion%7D%7D/eloquent) y proporciona una paginación conveniente y fácil de usar de registros de base de datos con cero configuración.
Por defecto, el HTML generado por el paginador es compatible con el [framework Tailwind CSS](https://tailwindcss.com/); sin embargo, también está disponible el soporte de paginación de Bootstrap.

<a name="tailwind-jit"></a>
#### Tailwind JIT

Si estás utilizando las vistas de paginación de Tailwind predeterminadas de Laravel y el motor JIT de Tailwind, debes asegurarte de que la clave `content` del archivo `tailwind.config.js` de tu aplicación haga referencia a las vistas de paginación de Laravel para que sus clases de Tailwind no sean eliminadas:


```js
content: [
    './resources/**/*.blade.php',
    './resources/**/*.js',
    './resources/**/*.vue',
    './vendor/laravel/framework/src/Illuminate/Pagination/resources/views/*.blade.php',
],

```

<a name="basic-usage"></a>
## Uso Básico


<a name="paginating-query-builder-results"></a>
### Paginando Resultados del Constructor de Consultas

Hay varias formas de paginar elementos. La más sencilla es utilizando el método `paginate` en el [constructor de consultas](/docs/%7B%7Bversion%7D%7D/queries) o en una [consulta Eloquent](/docs/%7B%7Bversion%7D%7D/eloquent). El método `paginate` se encarga automáticamente de establecer el "límite" y el "desplazamiento" de la consulta en función de la página actual que está viendo el usuario. Por defecto, la página actual se detecta por el valor del argumento de cadena de consulta `page` en la solicitud HTTP. Este valor es detectado automáticamente por Laravel, y también se inserta automáticamente en los enlaces generados por el paginador.
En este ejemplo, el único argumento pasado al método `paginate` es el número de elementos que te gustaría mostrar "por página". En este caso, especificamos que nos gustaría mostrar `15` elementos por página:


```php
<?php

namespace App\Http\Controllers;

use App\Http\Controllers\Controller;
use Illuminate\Support\Facades\DB;
use Illuminate\View\View;

class UserController extends Controller
{
    /**
     * Show all application users.
     */
    public function index(): View
    {
        return view('user.index', [
            'users' => DB::table('users')->paginate(15)
        ]);
    }
}
```

<a name="simple-pagination"></a>
#### Paginación Simple

El método `paginate` cuenta el número total de registros coincidentes con la consulta antes de recuperar los registros de la base de datos. Esto se hace para que el paginador sepa cuántas páginas de registros hay en total. Sin embargo, si no planeas mostrar el número total de páginas en la interfaz de usuario de tu aplicación, entonces la consulta de conteo de registros es innecesaria.
Por lo tanto, si solo necesitas mostrar enlaces simples de "Siguiente" y "Anterior" en la UI de tu aplicación, puedes usar el método `simplePaginate` para realizar una sola consulta eficiente:


```php
$users = DB::table('users')->simplePaginate(15);
```

<a name="paginating-eloquent-results"></a>
### Paginando Resultados de Eloquent

También puedes paginar consultas de [Eloquent](/docs/%7B%7Bversion%7D%7D/eloquent). En este ejemplo, paginaremos el modelo `App\Models\User` e indicaremos que planeamos mostrar 15 registros por página. Como puedes ver, la sintaxis es casi idéntica a la de paginar resultados del generador de consultas:


```php
use App\Models\User;

$users = User::paginate(15);
```
Por supuesto, puedes llamar al método `paginate` después de establecer otras restricciones en la consulta, como las cláusulas `where`:


```php
$users = User::where('votes', '>', 100)->paginate(15);
```
También puedes usar el método `simplePaginate` al paginar modelos Eloquent:


```php
$users = User::where('votes', '>', 100)->simplePaginate(15);
```
Del mismo modo, puedes usar el método `cursorPaginate` para paginar modelos Eloquent con cursor:


```php
$users = User::where('votes', '>', 100)->cursorPaginate(15);
```

<a name="multiple-paginator-instances-per-page"></a>
#### Múltiples Instancias de Paginador por Página

A veces es posible que necesites renderizar dos paginadores separados en una sola pantalla que sea renderizada por tu aplicación. Sin embargo, si ambas instancias del paginador utilizan el parámetro de cadena de consulta `page` para almacenar la página actual, los dos paginadores entrarán en conflicto. Para resolver este conflicto, puedes pasar el nombre del parámetro de cadena de consulta que deseas usar para almacenar la página actual del paginador a través del tercer argumento proporcionado a los métodos `paginate`, `simplePaginate` y `cursorPaginate`:


```php
use App\Models\User;

$users = User::where('votes', '>', 100)->paginate(
    $perPage = 15, $columns = ['*'], $pageName = 'users'
);
```

<a name="cursor-pagination"></a>
### Paginación por Cursor

Mientras que `paginate` y `simplePaginate` crean consultas utilizando la cláusula "offset" de SQL, la paginación por cursor funciona construyendo cláusulas "where" que comparan los valores de las columnas ordenadas contenidas en la consulta, proporcionando el mejor rendimiento de base de datos disponible entre todos los métodos de paginación de Laravel. Este método de paginación es particularmente adecuado para conjuntos de datos grandes y interfaces de usuario de desplazamiento "infinito".
A diferencia de la paginación basada en desplazamiento, que incluye un número de página en la cadena de consulta de las URL generadas por el paginador, la paginación basada en cursor coloca una cadena de "cursor" en la cadena de consulta. El cursor es una cadena codificada que contiene la ubicación desde donde debería comenzar la próxima consulta paginada y la dirección en la que debe paginar:


```nothing
http://localhost/users?cursor=eyJpZCI6MTUsIl9wb2ludHNUb05leHRJdGVtcyI6dHJ1ZX0

```
Puedes crear una instancia de paginador basada en cursor a través del método `cursorPaginate` que ofrece el generador de consultas. Este método devuelve una instancia de `Illuminate\Pagination\CursorPaginator`:


```php
$users = DB::table('users')->orderBy('id')->cursorPaginate(15);
```
Una vez que hayas recuperado una instancia de un paginador por cursor, puedes [mostrar los resultados de la paginación](#displaying-pagination-results) como lo harías típicamente al usar los métodos `paginate` y `simplePaginate`. Para obtener más información sobre los métodos de instancia ofrecidos por el paginador por cursor, consulta la [documentación de métodos de instancia del paginador por cursor](#cursor-paginator-instance-methods).
> [!WARNING]
Tu consulta debe contener una cláusula "order by" para poder aprovechar la paginación por cursor. Además, las columnas por las que se ordena la consulta deben pertenecer a la tabla que estás paginando.

<a name="cursor-vs-offset-pagination"></a>
#### Paginación por Cursor vs. Offset

Para ilustrar las diferencias entre la paginación por desplazamiento y la paginación por cursor, examinemos algunas consultas SQL de ejemplo. Ambas consultas a continuación mostrarán la "segunda página" de resultados para una tabla `users` ordenada por `id`:


```sql
# Offset Pagination...
select * from users order by id asc limit 15 offset 15;

# Cursor Pagination...
select * from users where id > 15 order by id asc limit 15;

```
La consulta de paginación por cursor ofrece las siguientes ventajas sobre la paginación por offset:
- Para conjuntos de datos grandes, la paginación por cursor ofrecerá un mejor rendimiento si las columnas "order by" están indexadas. Esto se debe a que la cláusula "offset" escanea a través de todos los datos coincidentes previamente.
- Para conjuntos de datos con escrituras frecuentes, la paginación por offset puede omitir registros o mostrar duplicados si los resultados se han añadido o eliminado recientemente de la página que un usuario está viendo actualmente.
Sin embargo, la paginación por cursor tiene las siguientes limitaciones:
- Al igual que `simplePaginate`, la paginación por cursor solo se puede usar para mostrar enlaces de "Siguiente" y "Anterior" y no admite la generación de enlaces con números de página.
- Requiere que el ordenamiento se base en al menos una columna única o una combinación de columnas que sean únicas. No se admiten columnas con valores `null`.
- Las expresiones de consulta en las cláusulas "order by" solo se admiten si tienen un alias y se añaden a la cláusula "select" también.
- No se admiten expresiones de consulta con parámetros.

<a name="manually-creating-a-paginator"></a>
### Creando un Paginador Manualmente

A veces es posible que desees crear una instancia de paginación manualmente, pasando un array de elementos que ya tienes en memoria. Puedes hacerlo creando una instancia de `Illuminate\Pagination\Paginator`, `Illuminate\Pagination\LengthAwarePaginator` o `Illuminate\Pagination\CursorPaginator`, dependiendo de tus necesidades.
Las clases `Paginator` y `CursorPaginator` no necesitan conocer el número total de elementos en el conjunto de resultados; sin embargo, debido a esto, estas clases no tienen métodos para recuperar el índice de la última página. El `LengthAwarePaginator` acepta casi los mismos argumentos que el `Paginator`; sin embargo, requiere un conteo del número total de elementos en el conjunto de resultados.
En otras palabras, el `Paginator` corresponde al método `simplePaginate` en el constructor de consultas, el `CursorPaginator` corresponde al método `cursorPaginate`, y el `LengthAwarePaginator` corresponde al método `paginate`.
> [!WARNING]
Al crear manualmente una instancia de paginador, debes "cortar" manualmente el array de resultados que pasas al paginador. Si no estás seguro de cómo hacer esto, consulta la función [array_slice](https://secure.php.net/manual/en/function.array-slice.php) de PHP.

<a name="customizing-pagination-urls"></a>
### Personalizando las URL de Paginación

Por defecto, los enlaces generados por el paginador coincidirán con la URI de la solicitud actual. Sin embargo, el método `withPath` del paginador te permite personalizar la URI que utiliza el paginador al generar enlaces. Por ejemplo, si deseas que el paginador genere enlaces como `http://example.com/admin/users?page=N`, debes pasar `/admin/users` al método `withPath`:


```php
use App\Models\User;

Route::get('/users', function () {
    $users = User::paginate(15);

    $users->withPath('/admin/users');

    // ...
});
```

<a name="appending-query-string-values"></a>
#### Agregando Valores de Cadena de Consulta

Puedes añadir a la cadena de consulta de los enlaces de paginación utilizando el método `appends`. Por ejemplo, para añadir `sort=votes` a cada enlace de paginación, deberías hacer la siguiente llamada a `appends`:


```php
use App\Models\User;

Route::get('/users', function () {
    $users = User::paginate(15);

    $users->appends(['sort' => 'votes']);

    // ...
});
```
Puedes usar el método `withQueryString` si deseas añadir todos los valores de la cadena de consulta de la solicitud actual a los enlaces de paginación:


```php
$users = User::paginate(15)->withQueryString();
```

<a name="appending-hash-fragments"></a>
#### Añadiendo Fragmentos de Hash

Si necesitas añadir un "fragmento hash" a las URL generadas por el paginador, puedes usar el método `fragment`. Por ejemplo, para añadir `#users` al final de cada enlace de paginación, debes invocar el método `fragment` de la siguiente manera:


```php
$users = User::paginate(15)->fragment('users');
```

<a name="displaying-pagination-results"></a>
## Mostrando Resultados de Paginación

Al llamar al método `paginate`, recibirás una instancia de `Illuminate\Pagination\LengthAwarePaginator`, mientras que llamar al método `simplePaginate` devuelve una instancia de `Illuminate\Pagination\Paginator`. Y, finalmente, llamar al método `cursorPaginate` devuelve una instancia de `Illuminate\Pagination\CursorPaginator`.
Estos objetos proporcionan varios métodos que describen el conjunto de resultados. Además de estos métodos de ayuda, las instancias del paginador son iteradores y se pueden recorrer como un array. Así que, una vez que hayas recuperado los resultados, puedes mostrar los resultados y renderizar los enlaces de la página utilizando [Blade](/docs/%7B%7Bversion%7D%7D/blade):


```blade
<div class="container">
    @foreach ($users as $user)
        {{ $user->name }}
    @endforeach
</div>

{{ $users->links() }}

```
El método `links` renderizará los enlaces a las demás páginas en el conjunto de resultados. Cada uno de estos enlaces ya contendrá el variable de cadena de consulta `page` adecuada. Recuerda que el HTML generado por el método `links` es compatible con el [framework Tailwind CSS](https://tailwindcss.com).

<a name="adjusting-the-pagination-link-window"></a>
### Ajustando la Ventana de Enlaces de Paginación

Cuando el paginador muestra enlaces de paginación, se muestra el número de la página actual, así como enlaces para las tres páginas antes y después de la página actual. Usando el método `onEachSide`, puedes controlar cuántos enlaces adicionales se muestran a cada lado de la página actual dentro de la ventana deslizante media de enlaces generados por el paginador:


```blade
{{ $users->onEachSide(5)->links() }}

```

<a name="converting-results-to-json"></a>
### Convirtiendo Resultados a JSON

Las clases de paginación de Laravel implementan el contrato de la interfaz `Illuminate\Contracts\Support\Jsonable` y exponen el método `toJson`, por lo que es muy fácil convertir tus resultados de paginación a JSON. También puedes convertir una instancia de paginador a JSON devolviéndola desde una ruta o acción del controlador:


```php
use App\Models\User;

Route::get('/users', function () {
    return User::paginate();
});
```
El JSON del paginador incluirá información meta como `total`, `current_page`, `last_page`, y más. Los registros de resultado están disponibles a través de la clave `data` en el array JSON. Aquí hay un ejemplo del JSON creado al devolver una instancia de paginador desde una ruta:


```php
{
   "total": 50,
   "per_page": 15,
   "current_page": 1,
   "last_page": 4,
   "first_page_url": "http://laravel.app?page=1",
   "last_page_url": "http://laravel.app?page=4",
   "next_page_url": "http://laravel.app?page=2",
   "prev_page_url": null,
   "path": "http://laravel.app",
   "from": 1,
   "to": 15,
   "data":[
        {
            // Record...
        },
        {
            // Record...
        }
   ]
}
```

<a name="customizing-the-pagination-view"></a>
## Personalizando la Vista de Paginación

Por defecto, las vistas renderizadas para mostrar los enlaces de paginación son compatibles con el framework [Tailwind CSS](https://tailwindcss.com). Sin embargo, si no estás utilizando Tailwind, puedes definir tus propias vistas para renderizar estos enlaces. Al llamar al método `links` en una instancia de paginador, puedes pasar el nombre de la vista como el primer argumento al método:


```blade
{{ $paginator->links('view.name') }}

<!-- Passing additional data to the view... -->
{{ $paginator->links('view.name', ['foo' => 'bar']) }}

```
Sin embargo, la forma más fácil de personalizar las vistas de paginación es exportándolas a tu directorio `resources/views/vendor` utilizando el comando `vendor:publish`:


```shell
php artisan vendor:publish --tag=laravel-pagination

```
Este comando colocará las vistas en el directorio `resources/views/vendor/pagination` de tu aplicación. El archivo `tailwind.blade.php` dentro de este directorio corresponde a la vista de paginación predeterminada. Puedes editar este archivo para modificar el HTML de la paginación.
Si deseas designar un archivo diferente como la vista de paginación predeterminada, puedes invocar los métodos `defaultView` y `defaultSimpleView` del paginador dentro del método `boot` de tu clase `App\Providers\AppServiceProvider`:


```php
<?php

namespace App\Providers;

use Illuminate\Pagination\Paginator;
use Illuminate\Support\ServiceProvider;

class AppServiceProvider extends ServiceProvider
{
    /**
     * Bootstrap any application services.
     */
    public function boot(): void
    {
        Paginator::defaultView('view-name');

        Paginator::defaultSimpleView('view-name');
    }
}
```

<a name="using-bootstrap"></a>
### Usando Bootstrap

Laravel incluye vistas de paginación construidas con [Bootstrap CSS](https://getbootstrap.com/). Para usar estas vistas en lugar de las vistas predeterminadas de Tailwind, puedes llamar a los métodos `useBootstrapFour` o `useBootstrapFive` del paginador dentro del método `boot` de tu clase `App\Providers\AppServiceProvider`:


```php
use Illuminate\Pagination\Paginator;

/**
 * Bootstrap any application services.
 */
public function boot(): void
{
    Paginator::useBootstrapFive();
    Paginator::useBootstrapFour();
}
```

<a name="paginator-instance-methods"></a>
## Métodos de Instancia de Paginator / LengthAwarePaginator

Cada instancia de paginador proporciona información de paginación adicional a través de los siguientes métodos:
<div class="overflow-auto">

| Método | Descripción |
| --- | --- |
| `$paginator->count()` | Obtén el número de elementos para la página actual. |
| `$paginator->currentPage()` | Obtén el número de la página actual. |
| `$paginator->firstItem()` | Obtén el número del resultado del primer elemento en los resultados. |
| `$paginator->getOptions()` | Obtén las opciones del paginador. |
| `$paginator->getUrlRange($start, $end)` | Crea un rango de URL de paginación. |
| `$paginator->hasPages()` | Determina si hay suficientes elementos para dividir en múltiples páginas. |
| `$paginator->hasMorePages()` | Determina si hay más elementos en el almacén de datos. |
| `$paginator->items()` | Obtén los elementos para la página actual. |
| `$paginator->lastItem()` | Obtén el número del resultado del último elemento en los resultados. |
| `$paginator->lastPage()` | Obtén el número de la página de la última página disponible. (No disponible al usar `simplePaginate`). |
| `$paginator->nextPageUrl()` | Obtén la URL para la siguiente página. |
| `$paginator->onFirstPage()` | Determina si el paginador está en la primera página. |
| `$paginator->perPage()` | El número de elementos que se mostrarán por página. |
| `$paginator->previousPageUrl()` | Obtén la URL para la página anterior. |
| `$paginator->total()` | Determina el número total de elementos que coinciden en el almacén de datos. (No disponible al usar `simplePaginate`). |
| `$paginator->url($page)` | Obtén la URL para un número de página dado. |
| `$paginator->getPageName()` | Obtén la variable de cadena de consulta utilizada para almacenar la página. |
| `$paginator->setPageName($name)` | Establece la variable de cadena de consulta utilizada para almacenar la página. |
| `$paginator->through($callback)` | Transforma cada elemento utilizando un callback. |
</div>

<a name="cursor-paginator-instance-methods"></a>
## Métodos de Instancia del Paginador de Cursor

Cada instancia del paginador de cursor proporciona información de paginación adicional a través de los siguientes métodos:
<div class="overflow-auto">

| Método                          | Descripción                                                       |
| ------------------------------- | ----------------------------------------------------------------- |
| `$paginator->count()`           | Obtiene el número de elementos para la página actual.              |
| `$paginator->cursor()`          | Obtiene la instancia del cursor actual.                           |
| `$paginator->getOptions()`      | Obtiene las opciones del paginador.                              |
| `$paginator->hasPages()`        | Determina si hay suficientes elementos para dividir en varias páginas. |
| `$paginator->hasMorePages()`    | Determina si hay más elementos en el almacén de datos.            |
| `$paginator->getCursorName()`   | Obtiene la variable de cadena de consulta utilizada para almacenar el cursor. |
| `$paginator->items()`           | Obtiene los elementos para la página actual.                      |
| `$paginator->nextCursor()`      | Obtiene la instancia del cursor para el siguiente conjunto de elementos. |
| `$paginator->nextPageUrl()`     | Obtiene la URL para la siguiente página.                          |
| `$paginator->onFirstPage()`     | Determina si el paginador está en la primera página.              |
| `$paginator->onLastPage()`      | Determina si el paginador está en la última página.               |
| `$paginator->perPage()`         | El número de elementos que se mostrarán por página.               |
| `$paginator->previousCursor()`  | Obtiene la instancia del cursor para el conjunto anterior de elementos. |
| `$paginator->previousPageUrl()` | Obtiene la URL para la página anterior.                            |
| `$paginator->setCursorName()`   | Establece la variable de cadena de consulta utilizada para almacenar el cursor. |
| `$paginator->url($cursor)`      | Obtiene la URL para una instancia de cursor dada.                 |
</div>