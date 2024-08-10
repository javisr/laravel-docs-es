# Precognición

- [Introducción](#introduction)
- [Validación en Vivo](#live-validation)
    - [Usando Vue](#using-vue)
    - [Usando Vue e Inertia](#using-vue-and-inertia)
    - [Usando React](#using-react)
    - [Usando React e Inertia](#using-react-and-inertia)
    - [Usando Alpine y Blade](#using-alpine)
    - [Configurando Axios](#configuring-axios)
- [Personalizando Reglas de Validación](#customizing-validation-rules)
- [Manejando Cargas de Archivos](#handling-file-uploads)
- [Gestionando Efectos Secundarios](#managing-side-effects)
- [Pruebas](#testing)

<a name="introduction"></a>
## Introducción

Laravel Precognición te permite anticipar el resultado de una futura solicitud HTTP. Uno de los principales casos de uso de Precognición es la capacidad de proporcionar validación "en vivo" para tu aplicación JavaScript frontend sin tener que duplicar las reglas de validación del backend de tu aplicación. Precognición se combina especialmente bien con los [kits de inicio](/docs/{{version}}/starter-kits) basados en Inertia de Laravel.

Cuando Laravel recibe una "solicitud precognitiva", ejecutará todos los middlewares de la ruta y resolverá las dependencias del controlador de la ruta, incluyendo la validación de [solicitudes de formulario](/docs/{{version}}/validation#form-request-validation) - pero no ejecutará realmente el método del controlador de la ruta.

<a name="live-validation"></a>
## Validación en Vivo

<a name="using-vue"></a>
### Usando Vue

Usando Laravel Precognición, puedes ofrecer experiencias de validación en vivo a tus usuarios sin tener que duplicar tus reglas de validación en tu aplicación Vue frontend. Para ilustrar cómo funciona, construyamos un formulario para crear nuevos usuarios dentro de nuestra aplicación.

Primero, para habilitar Precognición para una ruta, el middleware `HandlePrecognitiveRequests` debe ser agregado a la definición de la ruta. También debes crear una [solicitud de formulario](/docs/{{version}}/validation#form-request-validation) para albergar las reglas de validación de la ruta:

```php
use App\Http\Requests\StoreUserRequest;
use Illuminate\Foundation\Http\Middleware\HandlePrecognitiveRequests;

Route::post('/users', function (StoreUserRequest $request) {
    // ...
})->middleware([HandlePrecognitiveRequests::class]);
```

A continuación, debes instalar los helpers frontend de Laravel Precognición para Vue a través de NPM:

```shell
npm install laravel-precognition-vue
```

Con el paquete de Laravel Precognición instalado, ahora puedes crear un objeto de formulario usando la función `useForm` de Precognición, proporcionando el método HTTP (`post`), la URL de destino (`/users`), y los datos iniciales del formulario.

Luego, para habilitar la validación en vivo, invoca el método `validate` del formulario en el evento `change` de cada entrada, proporcionando el nombre de la entrada:

```vue
<script setup>
import { useForm } from 'laravel-precognition-vue';

const form = useForm('post', '/users', {
    name: '',
    email: '',
});

const submit = () => form.submit();
</script>

<template>
    <form @submit.prevent="submit">
        <label for="name">Name</label>
        <input
            id="name"
            v-model="form.name"
            @change="form.validate('name')"
        />
        <div v-if="form.invalid('name')">
            {{ form.errors.name }}
        </div>

        <label for="email">Email</label>
        <input
            id="email"
            type="email"
            v-model="form.email"
            @change="form.validate('email')"
        />
        <div v-if="form.invalid('email')">
            {{ form.errors.email }}
        </div>

        <button :disabled="form.processing">
            Create User
        </button>
    </form>
</template>
```

Ahora, a medida que el formulario es completado por el usuario, Precognición proporcionará una salida de validación en vivo impulsada por las reglas de validación en la solicitud de formulario de la ruta. Cuando se cambian las entradas del formulario, se enviará una solicitud de validación "precognitiva" con un debounce a tu aplicación Laravel. Puedes configurar el tiempo de espera del debounce llamando a la función `setValidationTimeout` del formulario:

```js
form.setValidationTimeout(3000);
```

Cuando una solicitud de validación está en curso, la propiedad `validating` del formulario será `true`:

```html
<div v-if="form.validating">
    Validando...
</div>
```

Cualquier error de validación devuelto durante una solicitud de validación o una presentación de formulario llenará automáticamente el objeto `errors` del formulario:

```html
<div v-if="form.invalid('email')">
    {{ form.errors.email }}
</div>
```

Puedes determinar si el formulario tiene errores usando la propiedad `hasErrors` del formulario:

```html
<div v-if="form.hasErrors">
    <!-- ... -->
</div>
```

También puedes determinar si una entrada ha pasado o fallado la validación pasando el nombre de la entrada a las funciones `valid` e `invalid` del formulario, respectivamente:

```html
<span v-if="form.valid('email')">
    ✅
</span>

<span v-else-if="form.invalid('email')">
    ❌
</span>
```

> [!WARNING]  
> Una entrada de formulario solo aparecerá como válida o inválida una vez que haya cambiado y se haya recibido una respuesta de validación.

Si estás validando un subconjunto de las entradas de un formulario con Precognición, puede ser útil limpiar manualmente los errores. Puedes usar la función `forgetError` del formulario para lograr esto:

```html
<input
    id="avatar"
    type="file"
    @change="(e) => {
        form.avatar = e.target.files[0]

        form.forgetError('avatar')
    }"
>
```

Por supuesto, también puedes ejecutar código en reacción a la respuesta de la presentación del formulario. La función `submit` del formulario devuelve una promesa de solicitud de Axios. Esto proporciona una forma conveniente de acceder a la carga útil de la respuesta, restablecer las entradas del formulario en una presentación exitosa, o manejar una solicitud fallida:

```js
const submit = () => form.submit()
    .then(response => {
        form.reset();

        alert('User created.');
    })
    .catch(error => {
        alert('An error occurred.');
    });
```

Puedes determinar si una solicitud de presentación de formulario está en curso inspeccionando la propiedad `processing` del formulario:

```html
<button :disabled="form.processing">
    Enviar
</button>
```

<a name="using-vue-and-inertia"></a>
### Usando Vue e Inertia

> [!NOTE]  
> Si deseas un buen comienzo al desarrollar tu aplicación Laravel con Vue e Inertia, considera usar uno de nuestros [kits de inicio](/docs/{{version}}/starter-kits). Los kits de inicio de Laravel proporcionan andamiaje de autenticación backend y frontend para tu nueva aplicación Laravel.

Antes de usar Precognición con Vue e Inertia, asegúrate de revisar nuestra documentación general sobre [usar Precognición con Vue](#using-vue). Al usar Vue con Inertia, necesitarás instalar la biblioteca de Precognición compatible con Inertia a través de NPM:

```shell
npm install laravel-precognition-vue-inertia
```

Una vez instalada, la función `useForm` de Precognición devolverá un [helper de formulario](https://inertiajs.com/forms#form-helper) de Inertia aumentado con las características de validación discutidas anteriormente.

El método `submit` del helper de formulario ha sido simplificado, eliminando la necesidad de especificar el método HTTP o la URL. En su lugar, puedes pasar las [opciones de visita](https://inertiajs.com/manual-visits) de Inertia como el primer y único argumento. Además, el método `submit` no devuelve una Promesa como se vio en el ejemplo de Vue anterior. En su lugar, puedes proporcionar cualquiera de los [callbacks de eventos](https://inertiajs.com/manual-visits#event-callbacks) soportados por Inertia en las opciones de visita dadas al método `submit`:

```vue
<script setup>
import { useForm } from 'laravel-precognition-vue-inertia';

const form = useForm('post', '/users', {
    name: '',
    email: '',
});

const submit = () => form.submit({
    preserveScroll: true,
    onSuccess: () => form.reset(),
});
</script>
```

<a name="using-react"></a>
### Usando React

Usando Laravel Precognición, puedes ofrecer experiencias de validación en vivo a tus usuarios sin tener que duplicar tus reglas de validación en tu aplicación React frontend. Para ilustrar cómo funciona, construyamos un formulario para crear nuevos usuarios dentro de nuestra aplicación.

Primero, para habilitar Precognición para una ruta, el middleware `HandlePrecognitiveRequests` debe ser agregado a la definición de la ruta. También debes crear una [solicitud de formulario](/docs/{{version}}/validation#form-request-validation) para albergar las reglas de validación de la ruta:

```php
use App\Http\Requests\StoreUserRequest;
use Illuminate\Foundation\Http\Middleware\HandlePrecognitiveRequests;

Route::post('/users', function (StoreUserRequest $request) {
    // ...
})->middleware([HandlePrecognitiveRequests::class]);
```

A continuación, debes instalar los helpers frontend de Laravel Precognición para React a través de NPM:

```shell
npm install laravel-precognition-react
```

Con el paquete de Laravel Precognición instalado, ahora puedes crear un objeto de formulario usando la función `useForm` de Precognición, proporcionando el método HTTP (`post`), la URL de destino (`/users`), y los datos iniciales del formulario.

Para habilitar la validación en vivo, debes escuchar los eventos `change` y `blur` de cada entrada. En el manejador del evento `change`, debes establecer los datos del formulario con la función `setData`, pasando el nombre de la entrada y el nuevo valor. Luego, en el manejador del evento `blur`, invoca el método `validate` del formulario, proporcionando el nombre de la entrada:

```jsx
import { useForm } from 'laravel-precognition-react';

export default function Form() {
    const form = useForm('post', '/users', {
        name: '',
        email: '',
    });

    const submit = (e) => {
        e.preventDefault();

        form.submit();
    };

    return (
        <form onSubmit={submit}>
            <label htmlFor="name">Name</label>
            <input
                id="name"
                value={form.data.name}
                onChange={(e) => form.setData('name', e.target.value)}
                onBlur={() => form.validate('name')}
            />
            {form.invalid('name') && <div>{form.errors.name}</div>}

            <label htmlFor="email">Email</label>
            <input
                id="email"
                value={form.data.email}
                onChange={(e) => form.setData('email', e.target.value)}
                onBlur={() => form.validate('email')}
            />
            {form.invalid('email') && <div>{form.errors.email}</div>}

            <button disabled={form.processing}>
                Create User
            </button>
        </form>
    );
};
```

Ahora, a medida que el formulario es completado por el usuario, Precognición proporcionará una salida de validación en vivo impulsada por las reglas de validación en la solicitud de formulario de la ruta. Cuando se cambian las entradas del formulario, se enviará una solicitud de validación "precognitiva" con un debounce a tu aplicación Laravel. Puedes configurar el tiempo de espera del debounce llamando a la función `setValidationTimeout` del formulario:

```js
form.setValidationTimeout(3000);
```

Cuando una solicitud de validación está en curso, la propiedad `validating` del formulario será `true`:

```jsx
{form.validating && <div>Validando...</div>}
```

Cualquier error de validación devuelto durante una solicitud de validación o una presentación de formulario llenará automáticamente el objeto `errors` del formulario:

```jsx
{form.invalid('email') && <div>{form.errors.email}</div>}
```

Puedes determinar si el formulario tiene errores usando la propiedad `hasErrors` del formulario:

```jsx
{form.hasErrors && <div><!-- ... --></div>}
```

También puedes determinar si una entrada ha pasado o fallado la validación pasando el nombre de la entrada a las funciones `valid` e `invalid` del formulario, respectivamente:

```jsx
{form.valid('email') && <span>✅</span>}

{form.invalid('email') && <span>❌</span>}
```

> [!WARNING]  
> Una entrada de formulario solo aparecerá como válida o inválida una vez que haya cambiado y se haya recibido una respuesta de validación.

Si estás validando un subconjunto de las entradas de un formulario con Precognición, puede ser útil limpiar manualmente los errores. Puedes usar la función `forgetError` del formulario para lograr esto:

```jsx
<input
    id="avatar"
    type="file"
    onChange={(e) =>
        form.setData('avatar', e.target.value);

        form.forgetError('avatar');
    }
>
```

Por supuesto, también puedes ejecutar código en reacción a la respuesta de la presentación del formulario. La función `submit` del formulario devuelve una promesa de solicitud de Axios. Esto proporciona una forma conveniente de acceder a la carga útil de la respuesta, restablecer las entradas del formulario en una presentación exitosa, o manejar una solicitud fallida:

```js
const submit = (e) => {
    e.preventDefault();

    form.submit()
        .then(response => {
            form.reset();

            alert('User created.');
        })
        .catch(error => {
            alert('An error occurred.');
        });
};
```

Puedes determinar si una solicitud de presentación de formulario está en curso inspeccionando la propiedad `processing` del formulario:

```html
<button disabled={form.processing}>
    Enviar
</button>
```

<a name="using-react-and-inertia"></a>
### Usando React e Inertia

> [!NOTE]  
> Si deseas un buen comienzo al desarrollar tu aplicación Laravel con React e Inertia, considera usar uno de nuestros [kits de inicio](/docs/{{version}}/starter-kits). Los kits de inicio de Laravel proporcionan andamiaje de autenticación backend y frontend para tu nueva aplicación Laravel.

Antes de usar Precognición con React e Inertia, asegúrate de revisar nuestra documentación general sobre [usar Precognición con React](#using-react). Al usar React con Inertia, necesitarás instalar la biblioteca de Precognición compatible con Inertia a través de NPM:

```shell
npm install laravel-precognition-react-inertia
```

Una vez instalada, la función `useForm` de Precognición devolverá un [helper de formulario](https://inertiajs.com/forms#form-helper) de Inertia aumentado con las características de validación discutidas anteriormente.

El método `submit` del helper de formulario ha sido simplificado, eliminando la necesidad de especificar el método HTTP o la URL. En su lugar, puedes pasar las [opciones de visita](https://inertiajs.com/manual-visits) de Inertia como el primer y único argumento. Además, el método `submit` no devuelve una Promesa como se vio en el ejemplo de React anterior. En su lugar, puedes proporcionar cualquiera de los [callbacks de eventos](https://inertiajs.com/manual-visits#event-callbacks) soportados por Inertia en las opciones de visita dadas al método `submit`:

```js
import { useForm } from 'laravel-precognition-react-inertia';

const form = useForm('post', '/users', {
    name: '',
    email: '',
});

const submit = (e) => {
    e.preventDefault();

    form.submit({
        preserveScroll: true,
        onSuccess: () => form.reset(),
    });
};
```

<a name="using-alpine"></a>
### Usando Alpine y Blade

Usando Laravel Precognición, puedes ofrecer experiencias de validación en vivo a tus usuarios sin tener que duplicar tus reglas de validación en tu aplicación Alpine frontend. Para ilustrar cómo funciona, construyamos un formulario para crear nuevos usuarios dentro de nuestra aplicación.

Primero, para habilitar Precognición para una ruta, el middleware `HandlePrecognitiveRequests` debe ser agregado a la definición de la ruta. También debes crear una [solicitud de formulario](/docs/{{version}}/validation#form-request-validation) para albergar las reglas de validación de la ruta:

```php
use App\Http\Requests\CreateUserRequest;
use Illuminate\Foundation\Http\Middleware\HandlePrecognitiveRequests;

Route::post('/users', function (CreateUserRequest $request) {
    // ...
})->middleware([HandlePrecognitiveRequests::class]);
```

A continuación, debes instalar los helpers frontend de Laravel Precognición para Alpine a través de NPM:

```shell
npm install laravel-precognition-alpine
```

Luego, registra el plugin de Precognición con Alpine en tu archivo `resources/js/app.js`:

```js
import Alpine from 'alpinejs';
import Precognition from 'laravel-precognition-alpine';

window.Alpine = Alpine;

Alpine.plugin(Precognition);
Alpine.start();
```

Con el paquete de Laravel Precognición instalado y registrado, ahora puedes crear un objeto de formulario usando la "magia" de `$form` de Precognición, proporcionando el método HTTP (`post`), la URL de destino (`/users`), y los datos iniciales del formulario.

Para habilitar la validación en vivo, debes vincular los datos del formulario a su entrada relevante y luego escuchar el evento `change` de cada entrada. En el manejador del evento `change`, debes invocar el método `validate` del formulario, proporcionando el nombre de la entrada:

```html
<form x-data="{
    form: $form('post', '/register', {
        name: '',
        email: '',
    }),
}">
    @csrf
    <label for="name">Name</label>
    <input
        id="name"
        name="name"
        x-model="form.name"
        @change="form.validate('name')"
    />
    <template x-if="form.invalid('name')">
        <div x-text="form.errors.name"></div>
    </template>

    <label for="email">Email</label>
    <input
        id="email"
        name="email"
        x-model="form.email"
        @change="form.validate('email')"
    />
    <template x-if="form.invalid('email')">
        <div x-text="form.errors.email"></div>
    </template>

    <button :disabled="form.processing">
        Create User
    </button>
</form>
```

Ahora, a medida que el formulario es completado por el usuario, Precognición proporcionará una salida de validación en vivo impulsada por las reglas de validación en la solicitud de formulario de la ruta. Cuando se cambian las entradas del formulario, se enviará una solicitud de validación "precognitiva" con un debounce a tu aplicación Laravel. Puedes configurar el tiempo de espera del debounce llamando a la función `setValidationTimeout` del formulario:

```js
form.setValidationTimeout(3000);
```

Cuando una solicitud de validación está en curso, la propiedad `validating` del formulario será `true`:

```html
<template x-if="form.validating">
    <div>Validando...</div>
</template>
```

Cualquier error de validación devuelto durante una solicitud de validación o una presentación de formulario llenará automáticamente el objeto `errors` del formulario:

```html
<template x-if="form.invalid('email')">
    <div x-text="form.errors.email"></div>
</template>
```

Puedes determinar si el formulario tiene errores usando la propiedad `hasErrors` del formulario:

```html
<template x-if="form.hasErrors">
    <div><!-- ... --></div>
</template>
```

También puedes determinar si una entrada ha pasado o fallado la validación pasando el nombre de la entrada a las funciones `valid` e `invalid` del formulario, respectivamente:

```html
<template x-if="form.valid('email')">
    <span>✅</span>
</template>

<template x-if="form.invalid('email')">
    <span>❌</span>
</template>
```

> [!WARNING]  
> Una entrada de formulario solo aparecerá como válida o inválida una vez que haya cambiado y se haya recibido una respuesta de validación.

Puedes determinar si una solicitud de presentación de formulario está en curso inspeccionando la propiedad `processing` del formulario:

```html
<button :disabled="form.processing">
    Enviar
</button>
```

<a name="repopulating-old-form-data"></a>
#### Repoblando Datos Antiguos del Formulario

En el ejemplo de creación de usuario discutido anteriormente, estamos usando Precognición para realizar validación en vivo; sin embargo, estamos realizando una presentación de formulario tradicional del lado del servidor para enviar el formulario. Por lo tanto, el formulario debe ser poblado con cualquier entrada "antigua" y errores de validación devueltos de la presentación del formulario del lado del servidor:

```html
<form x-data="{
    form: $form('post', '/register', {
        name: '{{ old('name') }}',
        email: '{{ old('email') }}',
    }).setErrors({{ Js::from($errors->messages()) }}),
}">
```

Alternativamente, si deseas enviar el formulario a través de XHR, puedes usar la función `submit` del formulario, que devuelve una promesa de solicitud de Axios:

```html
<form
    x-data="{
        form: $form('post', '/register', {
            name: '',
            email: '',
        }),
        submit() {
            this.form.submit()
                .then(response => {
                    form.reset();

                    alert('User created.')
                })
                .catch(error => {
                    alert('An error occurred.');
                });
        },
    }"
    @submit.prevent="submit"
>
```

<a name="configuring-axios"></a>
### Configurando Axios

Las bibliotecas de validación de Precognición utilizan el cliente HTTP [Axios](https://github.com/axios/axios) para enviar solicitudes al backend de tu aplicación. Para conveniencia, la instancia de Axios puede ser personalizada si es necesario por tu aplicación. Por ejemplo, al usar la biblioteca `laravel-precognition-vue`, puedes agregar encabezados de solicitud adicionales a cada solicitud saliente en el archivo `resources/js/app.js` de tu aplicación:

```js
import { client } from 'laravel-precognition-vue';

client.axios().defaults.headers.common['Authorization'] = authToken;
```

O, si ya tienes una instancia de Axios configurada para tu aplicación, puedes indicarle a Precognición que use esa instancia en su lugar:

```js
import Axios from 'axios';
import { client } from 'laravel-precognition-vue';

window.axios = Axios.create()
window.axios.defaults.headers.common['Authorization'] = authToken;

client.use(window.axios)
```

> [!WARNING]  
> Las bibliotecas de Precognición con sabor a Inertia solo utilizarán la instancia de Axios configurada para solicitudes de validación. Las presentaciones de formularios siempre serán enviadas por Inertia.

<a name="customizing-validation-rules"></a>
## Personalizando Reglas de Validación

Es posible personalizar las reglas de validación ejecutadas durante una solicitud precognitiva utilizando el método `isPrecognitive` de la solicitud.

Por ejemplo, en un formulario de creación de usuario, puede que queramos validar que una contraseña esté "no comprometida" solo en la presentación final del formulario. Para las solicitudes de validación precognitiva, simplemente validaremos que la contraseña es requerida y tiene un mínimo de 8 caracteres. Usando el método `isPrecognitive`, podemos personalizar las reglas definidas por nuestra solicitud de formulario:

```php
<?php

namespace App\Http\Requests;

use Illuminate\Foundation\Http\FormRequest;
use Illuminate\Validation\Rules\Password;

class StoreUserRequest extends FormRequest
{
    /**
     * Get the validation rules that apply to the request.
     *
     * @return array
     */
    protected function rules()
    {
        return [
            'password' => [
                'required',
                $this->isPrecognitive()
                    ? Password::min(8)
                    : Password::min(8)->uncompromised(),
            ],
            // ...
        ];
    }
}
```

<a name="handling-file-uploads"></a>
## Manejo de Cargas de Archivos

Por defecto, Laravel Precognition no sube ni valida archivos durante una solicitud de validación precognitiva. Esto asegura que los archivos grandes no se suban innecesariamente múltiples veces.

Debido a este comportamiento, debes asegurarte de que tu aplicación [personalice las reglas de validación de la solicitud de formulario correspondiente](#customizing-validation-rules) para especificar que el campo solo es obligatorio para envíos de formulario completos:

```php
/**
 * Get the validation rules that apply to the request.
 *
 * @return array
 */
protected function rules()
{
    return [
        'avatar' => [
            ...$this->isPrecognitive() ? [] : ['required'],
            'image',
            'mimes:jpg,png',
            'dimensions:ratio=3/2',
        ],
        // ...
    ];
}
```

Si deseas incluir archivos en cada solicitud de validación, puedes invocar la función `validateFiles` en tu instancia de formulario del lado del cliente:

```js
form.validateFiles();
```

<a name="managing-side-effects"></a>
## Manejo de Efectos Secundarios

Al agregar el middleware `HandlePrecognitiveRequests` a una ruta, debes considerar si hay efectos secundarios en _otros_ middlewares que deberían ser omitidos durante una solicitud precognitiva.

Por ejemplo, puedes tener un middleware que incrementa el número total de "interacciones" que cada usuario tiene con tu aplicación, pero puede que no desees que las solicitudes precognitivas se cuenten como una interacción. Para lograr esto, podemos verificar el método `isPrecognitive` de la solicitud antes de incrementar el conteo de interacciones:

```php
<?php

namespace App\Http\Middleware;

use App\Facades\Interaction;
use Closure;
use Illuminate\Http\Request;

class InteractionMiddleware
{
    /**
     * Handle an incoming request.
     */
    public function handle(Request $request, Closure $next): mixed
    {
        if (! $request->isPrecognitive()) {
            Interaction::incrementFor($request->user());
        }

        return $next($request);
    }
}
```

<a name="testing"></a>
## Pruebas

Si deseas realizar solicitudes precognitivas en tus pruebas, el `TestCase` de Laravel incluye un helper `withPrecognition` que añadirá el encabezado de solicitud `Precognition`.

Además, si deseas afirmar que una solicitud precognitiva fue exitosa, es decir, que no devolvió errores de validación, puedes usar el método `assertSuccessfulPrecognition` en la respuesta:

```php tab=Pest
it('validates registration form with precognition', function () {
    $response = $this->withPrecognition()
        ->post('/register', [
            'name' => 'Taylor Otwell',
        ]);

    $response->assertSuccessfulPrecognition();

    expect(User::count())->toBe(0);
});
```

```php tab=PHPUnit
public function test_it_validates_registration_form_with_precognition()
{
    $response = $this->withPrecognition()
        ->post('/register', [
            'name' => 'Taylor Otwell',
        ]);

    $response->assertSuccessfulPrecognition();
    $this->assertSame(0, User::count());
}
```
