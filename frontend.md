# Frontend

- [Introducción](#introduction)
- [Usando PHP](#using-php)
  - [PHP y Blade](#php-and-blade)
  - [Livewire](#livewire)
  - [Kits de inicio](#php-starter-kits)
- [Usando Vue / React](#using-vue-react)
  - [Inertia](#inertia)
  - [Kits de inicio](#inertia-starter-kits)
- [Agrupando Assets](#bundling-assets)

<a name="introduction"></a>
## Introducción

Laravel es un framework backend que proporciona todas las características que necesitas para construir aplicaciones web modernas, como [ruteo](/docs/%7B%7Bversion%7D%7D/routing), [validación](/docs/%7B%7Bversion%7D%7D/validation), [caching](/docs/%7B%7Bversion%7D%7D/cache), [colas](/docs/%7B%7Bversion%7D%7D/queues), [almacenamiento de archivos](/docs/%7B%7Bversion%7D%7D/filesystem), y más. Sin embargo, creemos que es importante ofrecer a los desarrolladores una experiencia completa y hermosa, incluyendo enfoques poderosos para construir el frontend de tu aplicación.
Hay dos formas principales de abordar el desarrollo frontend al construir una aplicación con Laravel, y el enfoque que elijas se determina por si deseas construir tu frontend aprovechando PHP o utilizando frameworks de JavaScript como Vue y React. Discutiremos ambas opciones a continuación para que puedas tomar una decisión informada sobre el mejor enfoque para el desarrollo frontend de tu aplicación.

<a name="using-php"></a>
## Usando PHP


<a name="php-and-blade"></a>
### PHP y Blade

En el pasado, la mayoría de las aplicaciones PHP renderizaban HTML en el navegador utilizando plantillas HTML simples intercaladas con declaraciones `echo` de PHP que renderizaban datos que se recuperaban de una base de datos durante la solicitud:


```blade
<div>
    <?php foreach ($users as $user): ?>
        Hello, <?php echo $user->name; ?> <br />
    <?php endforeach; ?>
</div>

```
En Laravel, este enfoque para renderizar HTML aún se puede lograr utilizando [vistas](/docs/%7B%7Bversion%7D%7D/views) y [Blade](/docs/%7B%7Bversion%7D%7D/blade). Blade es un lenguaje de plantillas extremadamente ligero que proporciona una sintaxis conveniente y corta para mostrar datos, iterar sobre datos y más:


```blade
<div>
    @foreach ($users as $user)
        Hello, {{ $user->name }} <br />
    @endforeach
</div>

```
Al construir aplicaciones de esta manera, las envíos de formularios y otras interacciones con la página suelen recibir un documento HTML completamente nuevo del servidor y toda la página es renderizada de nuevo por el navegador. Incluso hoy en día, muchas aplicaciones pueden ser perfectas para construir sus frontends de esta manera utilizando plantillas Blade simples.

<a name="growing-expectations"></a>
#### Creciendo Expectativas

Sin embargo, a medida que las expectativas de los usuarios con respecto a las aplicaciones web han madurado, muchos desarrolladores han encontrado la necesidad de construir frontends más dinámicos con interacciones que se sientan más pulidas. En vista de esto, algunos desarrolladores eligen comenzar a construir el frontend de su aplicación utilizando frameworks de JavaScript como Vue y React.
Otros, prefiriendo mantenerse con el lenguaje backend con el que se sienten cómodos, han desarrollado soluciones que permiten la construcción de interfaces de usuario de aplicaciones web modernas mientras siguen utilizando principalmente su lenguaje backend de elección. Por ejemplo, en el ecosistema de [Rails](https://rubyonrails.org/), esto ha impulsado la creación de bibliotecas como [Turbo](https://turbo.hotwired.dev/) [Hotwire](https://hotwired.dev/) y [Stimulus](https://stimulus.hotwired.dev/).
Dentro del ecosistema de Laravel, la necesidad de crear frontends modernos y dinámicos utilizando principalmente PHP ha llevado a la creación de [Laravel Livewire](https://livewire.laravel.com) y [Alpine.js](https://alpinejs.dev/).

<a name="livewire"></a>
### Livewire

[Laravel Livewire](https://livewire.laravel.com) es un framework para construir frontends impulsados por Laravel que se sienten dinámicos, modernos y vivos, al igual que los frontends construidos con frameworks de JavaScript modernos como Vue y React.
Al utilizar Livewire, crearás "componentes" de Livewire que renderizan una porción discreta de tu interfaz de usuario y exponen métodos y datos que se pueden invocar e interactuar desde el frontend de tu aplicación. Por ejemplo, un simple componente de "Contador" podría verse como lo siguiente:


```php
<?php

namespace App\Http\Livewire;

use Livewire\Component;

class Counter extends Component
{
    public $count = 0;

    public function increment()
    {
        $this->count++;
    }

    public function render()
    {
        return view('livewire.counter');
    }
}

```
Y la plantilla correspondiente para el contador se escribiría así:


```blade
<div>
    <button wire:click="increment">+</button>
    <h1>{{ $count }}</h1>
</div>

```
Como puedes ver, Livewire te permite escribir nuevos atributos HTML como `wire:click` que conectan el frontend y el backend de tu aplicación Laravel. Además, puedes renderizar el estado actual de tu componente utilizando expresiones Blade simples.
Para muchos, Livewire ha revolucionado el desarrollo frontend con Laravel, permitiéndoles mantenerse dentro de la comodidad de Laravel mientras construyen aplicaciones web modernas y dinámicas. Típicamente, los desarrolladores que utilizan Livewire también usarán [Alpine.js](https://alpinejs.dev/) para "esparcir" JavaScript en su frontend solo donde es necesario, como para renderizar una ventana de diálogo.
Si eres nuevo en Laravel, te recomendamos familiarizarte con el uso básico de [vistas](/docs/%7B%7Bversion%7D%7D/views) y [Blade](/docs/%7B%7Bversion%7D%7D/blade). Luego, consulta la [documentación oficial de Laravel Livewire](https://livewire.laravel.com/docs) para aprender cómo llevar tu aplicación al siguiente nivel con componentes interactivos de Livewire.

<a name="php-starter-kits"></a>
Si deseas construir tu frontend utilizando PHP y Livewire, puedes aprovechar nuestros [starter kits](/docs/%7B%7Bversion%7D%7D/starter-kits) Breeze o Jetstream para iniciar el desarrollo de tu aplicación. Ambos starter kits escogen el flujo de autenticación backend y frontend de tu aplicación utilizando [Blade](/docs/%7B%7Bversion%7D%7D/blade) y [Tailwind](https://tailwindcss.com) para que puedas comenzar a construir tu próxima gran idea.

<a name="using-vue-react"></a>
## Usando Vue / React

Aunque es posible construir frontends modernos utilizando Laravel y Livewire, muchos desarrolladores todavía prefieren aprovechar el poder de un framework de JavaScript como Vue o React. Esto permite a los desarrolladores beneficiarse del rico ecosistema de paquetes y herramientas de JavaScript disponibles a través de NPM.
Sin embargo, sin herramientas adicionales, emparejar Laravel con Vue o React nos dejaría con la necesidad de resolver una variedad de problemas complicados, como el enrutamiento del lado del cliente, la hidratación de datos y la autenticación. El enrutamiento del lado del cliente a menudo se simplifica utilizando frameworks opinados de Vue / React como [Nuxt](https://nuxt.com/) y [Next](https://nextjs.org/); sin embargo, la hidratación de datos y la autenticación siguen siendo problemas complicados y engorrosos de resolver al emparejar un framework backend como Laravel con estos frameworks frontend.
Además, los desarrolladores se quedan manteniendo dos repositorios de código separados, a menudo necesitando coordinar el mantenimiento, las versiones y los despliegues entre ambos repositorios. Aunque estos problemas no son insuperables, no creemos que sea una forma productiva o agradable de desarrollar aplicaciones.

<a name="inertia"></a>
### Inertia

Afortunadamente, Laravel ofrece lo mejor de ambos mundos. [Inertia](https://inertiajs.com) cierra la brecha entre tu aplicación Laravel y tu moderno frontend de Vue o React, lo que te permite construir frontends completos y modernos utilizando Vue o React mientras aprovechas las rutas y controladores de Laravel para el enrutamiento, la hidratación de datos y la autenticación, todo dentro de un solo repositorio de código. Con este enfoque, puedes disfrutar del pleno poder tanto de Laravel como de Vue / React sin limitar las capacidades de ninguna de las herramientas.
Después de instalar Inertia en tu aplicación Laravel, escribirás rutas y controladores como de costumbre. Sin embargo, en lugar de devolver una plantilla Blade desde tu controlador, devolverás una página de Inertia:


```php
<?php

namespace App\Http\Controllers;

use App\Http\Controllers\Controller;
use App\Models\User;
use Inertia\Inertia;
use Inertia\Response;

class UserController extends Controller
{
    /**
     * Show the profile for a given user.
     */
    public function show(string $id): Response
    {
        return Inertia::render('Users/Profile', [
            'user' => User::findOrFail($id)
        ]);
    }
}

```
Una página de Inertia corresponde a un componente de Vue o React, típicamente almacenado en el directorio `resources/js/Pages` de tu aplicación. Los datos proporcionados a la página a través del método `Inertia::render` se usarán para hidratar las "props" del componente de la página:


```vue
<script setup>
import Layout from '@/Layouts/Authenticated.vue';
import { Head } from '@inertiajs/vue3';

const props = defineProps(['user']);
</script>

<template>
    <Head title="User Profile" />

    <Layout>
        <template #header>
            <h2 class="font-semibold text-xl text-gray-800 leading-tight">
                Profile
            </h2>
        </template>

        <div class="py-12">
            Hello, {{ user.name }}
        </div>
    </Layout>
</template>

```
Como puedes ver, Inertia te permite aprovechar todo el poder de Vue o React al construir tu frontend, mientras proporciona un puente ligero entre tu backend alimentado por Laravel y tu frontend alimentado por JavaScript.
#### Renderizado del Lado del Servidor (Server-Side Rendering)

Si te preocupa adentrarte en Inertia porque tu aplicación requiere renderizado del lado del servidor, no te preocupes. Inertia ofrece [soporte de renderizado del lado del servidor](https://inertiajs.com/server-side-rendering). Y, al desplegar tu aplicación a través de [Laravel Forge](https://forge.laravel.com), es fácil asegurar que el proceso de renderizado del lado del servidor de Inertia esté siempre en funcionamiento.

<a name="inertia-starter-kits"></a>
### Starter Kits

Si deseas construir tu frontend utilizando Inertia y Vue / React, puedes aprovechar nuestros kits de inicio Breeze o Jetstream [starter kits](/docs/%7B%7Bversion%7D%7D/starter-kits#breeze-and-inertia) para acelerar el desarrollo de tu aplicación. Ambos kits de inicio esbozan el flujo de autenticación backend y frontend de tu aplicación utilizando Inertia, Vue / React, [Tailwind](https://tailwindcss.com) y [Vite](https://vitejs.dev) para que puedas comenzar a construir tu próxima gran idea.

<a name="bundling-assets"></a>
## Agrupando Activos

Independientemente de si eliges desarrollar tu frontend usando Blade y Livewire o Vue / React e Inertia, probablemente necesitarás agrupar el CSS de tu aplicación en activos listos para producción. Por supuesto, si decides construir el frontend de tu aplicación con Vue o React, también necesitarás agrupar tus componentes en activos de JavaScript listos para el navegador.
Por defecto, Laravel utiliza [Vite](https://vitejs.dev) para agrupar tus activos. Vite ofrece tiempos de construcción ultrarrápidos y un Reemplazo de Módulos en Caliente (HMR) casi instantáneo durante el desarrollo local. En todas las nuevas aplicaciones de Laravel, incluidas aquellas que utilizan nuestros [starter kits](/docs/%7B%7Bversion%7D%7D/starter-kits), encontrarás un archivo `vite.config.js` que carga nuestro ligero plugin Laravel Vite, lo que hace que Vite sea un placer usar con aplicaciones Laravel.
La forma más rápida de comenzar con Laravel y Vite es iniciando el desarrollo de tu aplicación utilizando [Laravel Breeze](/docs/%7B%7Bversion%7D%7D/starter-kits#laravel-breeze), nuestro kit de inicio más simple que acelera tu aplicación al proporcionar andamiaje de autenticación frontend y backend.
> [!NOTE]
Para obtener documentación más detallada sobre cómo utilizar Vite con Laravel, consulta nuestra [documentación dedicada sobre la agrupación y compilación de tus recursos](/docs/%7B%7Bversion%7D%7D/vite).