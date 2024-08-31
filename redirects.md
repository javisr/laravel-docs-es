# Redireccionamientos HTTP

- [Creando Redirecciones](#creating-redirects)
- [Redirigiendo a Rutas Nombradas](#redirecting-named-routes)
- [Redirigiendo a Acciones de Controlador](#redirecting-controller-actions)
- [Redirigiendo con Datos de Sesión Flasheados](#redirecting-with-flashed-session-data)

<a name="creating-redirects"></a>
## Creando Redireccionamientos

Las respuestas de redirección son instancias de la clase `Illuminate\Http\RedirectResponse`, y contienen los encabezados adecuados necesarios para redirigir al usuario a otra URL. Hay varias formas de generar una instancia de `RedirectResponse`. El método más simple es usar el helper global `redirect`:


```php
Route::get('/dashboard', function () {
    return redirect('/home/dashboard');
});
```
A veces es posible que desees redirigir al usuario a su ubicación anterior, como cuando un formulario enviado no es válido. Puedes hacerlo utilizando la función auxiliar global `back`. Dado que esta función utiliza la [sesión](/docs/%7B%7Bversion%7D%7D/session), asegúrate de que la ruta que llama a la función `back` esté utilizando el grupo de middleware `web` o tenga aplicados todos los middleware de sesión:


```php
Route::post('/user/profile', function () {
    // Validate the request...

    return back()->withInput();
});
```

<a name="redirecting-named-routes"></a>
## Redirigiendo a Rutas Nombradas

Cuando llamas al helper `redirect` sin parámetros, se devuelve una instancia de `Illuminate\Routing\Redirector`, lo que te permite llamar a cualquier método en la instancia de `Redirector`. Por ejemplo, para generar una `RedirectResponse` a una ruta nombrada, puedes usar el método `route`:


```php
return redirect()->route('login');
```
Si tu ruta tiene parámetros, puedes pasarlos como segundo argumento al método `route`:


```php
// For a route with the following URI: profile/{id}

return redirect()->route('profile', ['id' => 1]);
```
Para mayor comodidad, Laravel también ofrece la función global `to_route`:


```php
return to_route('profile', ['id' => 1]);
```

<a name="populating-parameters-via-eloquent-models"></a>
#### Poblando Parámetros a través de Modelos Eloquent

Si rediriges a una ruta con un parámetro "ID" que se está llenando desde un modelo Eloquent, puedes pasar el modelo mismo. El ID se extraerá automáticamente:


```php
// For a route with the following URI: profile/{id}

return redirect()->route('profile', [$user]);
```
Si deseas personalizar el valor que se coloca en el parámetro de ruta, debes anular el método `getRouteKey` en tu modelo Eloquent:


```php
/**
 * Get the value of the model's route key.
 */
public function getRouteKey(): mixed
{
    return $this->slug;
}
```

<a name="redirecting-controller-actions"></a>
## Redireccionando a Acciones del Controlador

También puedes generar redireccionamientos a [acciones del controlador](/docs/%7B%7Bversion%7D%7D/controllers). Para hacerlo, pasa el nombre del controlador y de la acción al método `action`:


```php
use App\Http\Controllers\HomeController;

return redirect()->action([HomeController::class, 'index']);
```
Si la ruta de tu controlador requiere parámetros, puedes pasarlos como el segundo argumento al método `action`:


```php
return redirect()->action(
    [UserController::class, 'profile'], ['id' => 1]
);
```

<a name="redirecting-with-flashed-session-data"></a>
## Redirigiendo con Datos de Sesión Flasheados

Redirigir a una nueva URL y [flashear datos a la sesión](/docs/%7B%7Bversion%7D%7D/session#flash-data) suelen hacerse al mismo tiempo. Típicamente, esto se hace después de realizar una acción con éxito cuando flasheas un mensaje de éxito a la sesión. Para mayor comodidad, puedes crear una instancia de `RedirectResponse` y flashear datos a la sesión en una sola cadena de métodos fluentes:


```php
Route::post('/user/profile', function () {
    // Update the user's profile...

    return redirect('/dashboard')->with('status', 'Profile updated!');
});
```
Puedes usar el método `withInput` proporcionado por la instancia de `RedirectResponse` para almacenar los datos de entrada de la solicitud actual en la sesión antes de redirigir al usuario a una nueva ubicación. Una vez que los datos de entrada se han almacenado en la sesión, puedes [recuperarlos](/docs/%7B%7Bversion%7D%7D/requests#retrieving-old-input) durante la siguiente solicitud:


```php
return back()->withInput();
```
Después de que el usuario sea redirigido, puedes mostrar el mensaje flașeado de la [sesión](/docs/%7B%7Bversion%7D%7D/session). Por ejemplo, utilizando [sintaxis de Blade](/docs/%7B%7Bversion%7D%7D/blade):


```php
@if (session('status'))
    <div class="alert alert-success">
        {{ session('status') }}
    </div>
@endif
```