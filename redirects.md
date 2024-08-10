# Redirecciones HTTP

- [Creando Redirecciones](#creating-redirects)
- [Redirigiendo A Rutas Nombradas](#redirecting-named-routes)
- [Redirigiendo A Acciones de Controlador](#redirecting-controller-actions)
- [Redirigiendo Con Datos de Sesión Flasheados](#redirecting-with-flashed-session-data)

<a name="creating-redirects"></a>
## Creando Redirecciones

Las respuestas de redirección son instancias de la clase `Illuminate\Http\RedirectResponse`, y contienen los encabezados adecuados necesarios para redirigir al usuario a otra URL. Hay varias formas de generar una instancia de `RedirectResponse`. El método más simple es usar el helper global `redirect`:

    Route::get('/dashboard', function () {
        return redirect('/home/dashboard');
    });

A veces, es posible que desees redirigir al usuario a su ubicación anterior, como cuando un formulario enviado es inválido. Puedes hacerlo utilizando la función helper global `back`. Dado que esta función utiliza la [sesión](/docs/{{version}}/session), asegúrate de que la ruta que llama a la función `back` esté utilizando el grupo de middleware `web` o tenga todos los middleware de sesión aplicados:

    Route::post('/user/profile', function () {
        // Validar la solicitud...

        return back()->withInput();
    });

<a name="redirecting-named-routes"></a>
## Redirigiendo A Rutas Nombradas

Cuando llamas al helper `redirect` sin parámetros, se devuelve una instancia de `Illuminate\Routing\Redirector`, lo que te permite llamar a cualquier método en la instancia de `Redirector`. Por ejemplo, para generar una `RedirectResponse` a una ruta nombrada, puedes usar el método `route`:

    return redirect()->route('login');

Si tu ruta tiene parámetros, puedes pasarlos como el segundo argumento al método `route`:

    // Para una ruta con la siguiente URI: profile/{id}

    return redirect()->route('profile', ['id' => 1]);

Para mayor comodidad, Laravel también ofrece la función global `to_route`:

    return to_route('profile', ['id' => 1]);

<a name="populating-parameters-via-eloquent-models"></a>
#### Población de Parámetros A Través de Modelos Eloquent

Si estás redirigiendo a una ruta con un parámetro "ID" que se está poblando desde un modelo Eloquent, puedes pasar el modelo mismo. El ID se extraerá automáticamente:

    // Para una ruta con la siguiente URI: profile/{id}

    return redirect()->route('profile', [$user]);

Si deseas personalizar el valor que se coloca en el parámetro de la ruta, debes sobrescribir el método `getRouteKey` en tu modelo Eloquent:

    /**
     * Obtener el valor de la clave de ruta del modelo.
     */
    public function getRouteKey(): mixed
    {
        return $this->slug;
    }

<a name="redirecting-controller-actions"></a>
## Redirigiendo A Acciones de Controlador

También puedes generar redirecciones a [acciones de controlador](/docs/{{version}}/controllers). Para hacerlo, pasa el nombre del controlador y la acción al método `action`:

    use App\Http\Controllers\HomeController;

    return redirect()->action([HomeController::class, 'index']);

Si tu ruta de controlador requiere parámetros, puedes pasarlos como el segundo argumento al método `action`:

    return redirect()->action(
        [UserController::class, 'profile'], ['id' => 1]
    );

<a name="redirecting-with-flashed-session-data"></a>
## Redirigiendo Con Datos de Sesión Flasheados

Redirigir a una nueva URL y [flashear datos a la sesión](/docs/{{version}}/session#flash-data) generalmente se hace al mismo tiempo. Típicamente, esto se hace después de realizar con éxito una acción cuando flasheas un mensaje de éxito a la sesión. Para mayor comodidad, puedes crear una instancia de `RedirectResponse` y flashear datos a la sesión en una sola cadena de métodos fluida:

    Route::post('/user/profile', function () {
        // Actualizar el perfil del usuario...

        return redirect('/dashboard')->with('status', '¡Perfil actualizado!');
    });

Puedes usar el método `withInput` proporcionado por la instancia de `RedirectResponse` para flashear los datos de entrada de la solicitud actual a la sesión antes de redirigir al usuario a una nueva ubicación. Una vez que los datos de entrada se han flasheado a la sesión, puedes fácilmente [recuperarlos](/docs/{{version}}/requests#retrieving-old-input) durante la siguiente solicitud:

    return back()->withInput();

Después de que el usuario es redirigido, puedes mostrar el mensaje flasheado desde la [sesión](/docs/{{version}}/session). Por ejemplo, usando [sintaxis Blade](/docs/{{version}}/blade):

    @if (session('status'))
        <div class="alert alert-success">
            {{ session('status') }}
        </div>
    @endif
