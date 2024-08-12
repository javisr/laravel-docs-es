# Agrupación de Activos (Vite)

- [Introducción](#introduction)
- [Instalación y Configuración](#installation)
  - [Instalando Node](#installing-node)
  - [Instalando Vite y el Plugin de Laravel](#installing-vite-and-laravel-plugin)
  - [Configurando Vite](#configuring-vite)
  - [Cargando Tus Scripts y Estilos](#loading-your-scripts-and-styles)
- [Ejecutando Vite](#running-vite)
- [Trabajando Con JavaScript](#working-with-scripts)
  - [Alias](#aliases)
  - [Vue](#vue)
  - [React](#react)
  - [Inertia](#inertia)
  - [Procesamiento de URL](#url-processing)
- [Trabajando Con Hojas de Estilo](#working-with-stylesheets)
- [Trabajando Con Blade y Rutas](#working-with-blade-and-routes)
  - [Procesando Activos Estáticos Con Vite](#blade-processing-static-assets)
  - [Refrescando al Guardar](#blade-refreshing-on-save)
  - [Alias](#blade-aliases)
- [URLs Base Personalizadas](#custom-base-urls)
- [Variables de Entorno](#environment-variables)
- [Deshabilitando Vite en Pruebas](#disabling-vite-in-tests)
- [Renderizado del Lado del Servidor (SSR)](#ssr)
- [Atributos de Etiquetas de Script y Estilo](#script-and-style-attributes)
  - [Nonce de Política de Seguridad de Contenido (CSP)](#content-security-policy-csp-nonce)
  - [Integridad de Subrecursos (SRI)](#subresource-integrity-sri)
  - [Atributos Arbitrarios](#arbitrary-attributes)
- [Personalización Avanzada](#advanced-customization)
  - [Corrigiendo URLs del Servidor de Desarrollo](#correcting-dev-server-urls)

<a name="introduction"></a>
## Introducción

[Vite](https://vitejs.dev) es una herramienta moderna de construcción frontend que proporciona un entorno de desarrollo extremadamente rápido y agrupa tu código para producción. Al construir aplicaciones con Laravel, normalmente usarás Vite para agrupar los archivos CSS y JavaScript de tu aplicación en activos listos para producción.

Laravel se integra sin problemas con Vite al proporcionar un plugin oficial y una directiva de Blade para cargar tus activos para desarrollo y producción.

> [!NOTE]  
> ¿Estás usando Laravel Mix? Vite ha reemplazado a Laravel Mix en nuevas instalaciones de Laravel. Para la documentación de Mix, visita el sitio web de [Laravel Mix](https://laravel-mix.com/). Si deseas cambiar a Vite, consulta nuestra [guía de migración](https://github.com/laravel/vite-plugin/blob/main/UPGRADE.md#migrating-from-laravel-mix-to-vite).

<a name="vite-or-mix"></a>
#### Elegir Entre Vite y Laravel Mix

Antes de la transición a Vite, las nuevas aplicaciones de Laravel utilizaban [Mix](https://laravel-mix.com/), que está impulsado por [webpack](https://webpack.js.org/), al agrupar activos. Vite se centra en proporcionar una experiencia más rápida y productiva al construir aplicaciones ricas en JavaScript. Si estás desarrollando una Aplicación de Página Única (SPA), incluidas aquellas desarrolladas con herramientas como [Inertia](https://inertiajs.com), Vite será la opción perfecta.

Vite también funciona bien con aplicaciones tradicionales renderizadas del lado del servidor con "sprinkles" de JavaScript, incluidas aquellas que utilizan [Livewire](https://livewire.laravel.com). Sin embargo, carece de algunas características que soporta Laravel Mix, como la capacidad de copiar activos arbitrarios en la construcción que no están referenciados directamente en tu aplicación JavaScript.

<a name="migrating-back-to-mix"></a>
#### Migrando de Vuelta a Mix

¿Has comenzado una nueva aplicación de Laravel utilizando nuestro andamiaje de Vite pero necesitas volver a Laravel Mix y webpack? No hay problema. Consulta nuestra [guía oficial sobre la migración de Vite a Mix](https://github.com/laravel/vite-plugin/blob/main/UPGRADE.md#migrating-from-vite-to-laravel-mix).

<a name="installation"></a>
## Instalación y Configuración

> [!NOTE]  
> La siguiente documentación discute cómo instalar y configurar manualmente el plugin de Laravel Vite. Sin embargo, los [kits de inicio](/docs/{{version}}/starter-kits) de Laravel ya incluyen todo este andamiaje y son la forma más rápida de comenzar con Laravel y Vite.

<a name="installing-node"></a>
### Instalando Node

Debes asegurarte de que Node.js (16+) y NPM estén instalados antes de ejecutar Vite y el plugin de Laravel:

```sh
node -v
npm -v
```

Puedes instalar fácilmente la última versión de Node y NPM utilizando instaladores gráficos simples desde [el sitio web oficial de Node](https://nodejs.org/en/download/). O, si estás usando [Laravel Sail](docs/{{version}}/sail), puedes invocar Node y NPM a través de Sail:

```sh
./vendor/bin/sail node -v
./vendor/bin/sail npm -v
```

<a name="installing-vite-and-laravel-plugin"></a>
### Instalando Vite y el Plugin de Laravel

Dentro de una instalación fresca de Laravel, encontrarás un archivo `package.json` en la raíz de la estructura de directorios de tu aplicación. El archivo `package.json` predeterminado ya incluye todo lo que necesitas para comenzar a usar Vite y el plugin de Laravel. Puedes instalar las dependencias frontend de tu aplicación a través de NPM:

```sh
npm install
```

<a name="configuring-vite"></a>
### Configurando Vite

Vite se configura a través de un archivo `vite.config.js` en la raíz de tu proyecto. Eres libre de personalizar este archivo según tus necesidades, y también puedes instalar cualquier otro plugin que tu aplicación requiera, como `@vitejs/plugin-vue` o `@vitejs/plugin-react`.

El plugin de Laravel Vite requiere que especifiques los puntos de entrada para tu aplicación. Estos pueden ser archivos JavaScript o CSS, e incluyen lenguajes preprocesados como TypeScript, JSX, TSX y Sass.

```js
import { defineConfig } from 'vite';
import laravel from 'laravel-vite-plugin';

export default defineConfig({
    plugins: [
        laravel([
            'resources/css/app.css',
            'resources/js/app.js',
        ]),
    ],
});
```

Si estás construyendo una SPA, incluidas aplicaciones construidas utilizando Inertia, Vite funciona mejor sin puntos de entrada CSS:

```js
import { defineConfig } from 'vite';
import laravel from 'laravel-vite-plugin';

export default defineConfig({
    plugins: [
        laravel([
            'resources/css/app.css', // [tl! remove]
            'resources/js/app.js',
        ]),
    ],
});
```

En su lugar, deberías importar tu CSS a través de JavaScript. Típicamente, esto se haría en el archivo `resources/js/app.js` de tu aplicación:

```js
import './bootstrap';
import '../css/app.css'; // [tl! add]
```

El plugin de Laravel también soporta múltiples puntos de entrada y opciones de configuración avanzadas como [puntos de entrada SSR](#ssr).

<a name="working-with-a-secure-development-server"></a>
#### Trabajando Con un Servidor de Desarrollo Seguro

Si tu servidor web de desarrollo local está sirviendo tu aplicación a través de HTTPS, puedes encontrar problemas al conectarte al servidor de desarrollo de Vite.

Si estás usando [Laravel Herd](https://herd.laravel.com) y has asegurado el sitio o estás usando [Laravel Valet](/docs/{{version}}/valet) y has ejecutado el [comando seguro](/docs/{{version}}/valet#securing-sites) contra tu aplicación, el plugin de Laravel Vite detectará automáticamente y usará el certificado TLS generado para ti.

Si aseguraste el sitio utilizando un host que no coincide con el nombre del directorio de la aplicación, puedes especificar manualmente el host en el archivo `vite.config.js` de tu aplicación:

```js
import { defineConfig } from 'vite';
import laravel from 'laravel-vite-plugin';

export default defineConfig({
    plugins: [
        laravel({
            // ...
            detectTls: 'my-app.test', // [tl! add]
        }),
    ],
});
```

Al usar otro servidor web, deberías generar un certificado de confianza y configurar manualmente Vite para usar los certificados generados:

```js
// ...
import fs from 'fs'; // [tl! add]

const host = 'my-app.test'; // [tl! add]

export default defineConfig({
    // ...
    server: { // [tl! add]
        host, // [tl! add]
        hmr: { host }, // [tl! add]
        https: { // [tl! add]
            key: fs.readFileSync(`/path/to/${host}.key`), // [tl! add]
            cert: fs.readFileSync(`/path/to/${host}.crt`), // [tl! add]
        }, // [tl! add]
    }, // [tl! add]
});
```

Si no puedes generar un certificado de confianza para tu sistema, puedes instalar y configurar el [`@vitejs/plugin-basic-ssl` plugin](https://github.com/vitejs/vite-plugin-basic-ssl). Al usar certificados no confiables, necesitarás aceptar la advertencia del certificado para el servidor de desarrollo de Vite en tu navegador siguiendo el enlace "Local" en tu consola al ejecutar el comando `npm run dev`.

<a name="configuring-hmr-in-sail-on-wsl2"></a>
#### Ejecutando el Servidor de Desarrollo en Sail en WSL2

Al ejecutar el servidor de desarrollo de Vite dentro de [Laravel Sail](/docs/{{version}}/sail) en Windows Subsystem for Linux 2 (WSL2), deberías agregar la siguiente configuración a tu archivo `vite.config.js` para asegurar que el navegador pueda comunicarse con el servidor de desarrollo:

```js
// ...

export default defineConfig({
    // ...
    server: { // [tl! add:start]
        hmr: {
            host: 'localhost',
        },
    }, // [tl! add:end]
});
```

Si los cambios en tus archivos no se reflejan en el navegador mientras el servidor de desarrollo está en ejecución, también puede que necesites configurar la opción [`server.watch.usePolling`](https://vitejs.dev/config/server-options.html#server-watch) de Vite.

<a name="loading-your-scripts-and-styles"></a>
### Cargando Tus Scripts y Estilos

Con tus puntos de entrada de Vite configurados, ahora puedes referenciarlos en una directiva de Blade `@vite()` que agregas al `<head>` de la plantilla raíz de tu aplicación:

```blade
<!DOCTYPE html>
<head>
    {{-- ... --}}

    @vite(['resources/css/app.css', 'resources/js/app.js'])
</head>
```

Si estás importando tu CSS a través de JavaScript, solo necesitas incluir el punto de entrada de JavaScript:

```blade
<!DOCTYPE html>
<head>
    {{-- ... --}}

    @vite('resources/js/app.js')
</head>
```

La directiva `@vite` detectará automáticamente el servidor de desarrollo de Vite e inyectará el cliente de Vite para habilitar la Reemplazo de Módulos en Caliente. En modo de construcción, la directiva cargará tus activos compilados y versionados, incluidos cualquier CSS importado.

Si es necesario, también puedes especificar la ruta de construcción de tus activos compilados al invocar la directiva `@vite`:

```blade
<!doctype html>
<head>
    {{-- Given build path is relative to public path. --}}

    @vite('resources/js/app.js', 'vendor/courier/build')
</head>
```

<a name="inline-assets"></a>
#### Activos en Línea

A veces puede ser necesario incluir el contenido en bruto de los activos en lugar de vincular a la URL versionada del activo. Por ejemplo, puede que necesites incluir el contenido del activo directamente en tu página al pasar contenido HTML a un generador de PDF. Puedes mostrar el contenido de los activos de Vite utilizando el método `content` proporcionado por el `facade` `Vite`:

```blade
@use('Illuminate\Support\Facades\Vite')

<!doctype html>
<head>
    {{-- ... --}}

    <style>
        {!! Vite::content('resources/css/app.css') !!}
    </style>
    <script>
        {!! Vite::content('resources/js/app.js') !!}
    </script>
</head>
```

<a name="running-vite"></a>
## Ejecutando Vite

Hay dos formas en las que puedes ejecutar Vite. Puedes ejecutar el servidor de desarrollo a través del comando `dev`, que es útil mientras desarrollas localmente. El servidor de desarrollo detectará automáticamente los cambios en tus archivos y los reflejará instantáneamente en cualquier ventana del navegador abierta.

O, ejecutar el comando `build` versionará y agrupará los activos de tu aplicación y los preparará para que los despliegues en producción:

```shell
# Run the Vite development server...
npm run dev

# Build and version the assets for production...
npm run build
```

Si estás ejecutando el servidor de desarrollo en [Sail](/docs/{{version}}/sail) en WSL2, es posible que necesites algunas [opciones de configuración adicionales](#configuring-hmr-in-sail-on-wsl2).

<a name="working-with-scripts"></a>
## Trabajando Con JavaScript

<a name="aliases"></a>
### Alias

Por defecto, el plugin de Laravel proporciona un alias común para ayudarte a comenzar rápidamente y convenientemente importar los activos de tu aplicación:

```js
{
    '@' => '/resources/js'
}
```

Puedes sobrescribir el alias `'@'` agregando el tuyo propio al archivo de configuración `vite.config.js`:

```js
import { defineConfig } from 'vite';
import laravel from 'laravel-vite-plugin';

export default defineConfig({
    plugins: [
        laravel(['resources/ts/app.tsx']),
    ],
    resolve: {
        alias: {
            '@': '/resources/ts',
        },
    },
});
```

<a name="vue"></a>
### Vue

Si deseas construir tu frontend utilizando el framework [Vue](https://vuejs.org/), entonces también necesitarás instalar el plugin `@vitejs/plugin-vue`:

```sh
npm install --save-dev @vitejs/plugin-vue
```

Luego puedes incluir el plugin en tu archivo de configuración `vite.config.js`. Hay algunas opciones adicionales que necesitarás al usar el plugin de Vue con Laravel:

```js
import { defineConfig } from 'vite';
import laravel from 'laravel-vite-plugin';
import vue from '@vitejs/plugin-vue';

export default defineConfig({
    plugins: [
        laravel(['resources/js/app.js']),
        vue({
            template: {
                transformAssetUrls: {
                    // The Vue plugin will re-write asset URLs, when referenced
                    // in Single File Components, to point to the Laravel web
                    // server. Setting this to `null` allows the Laravel plugin
                    // to instead re-write asset URLs to point to the Vite
                    // server instead.
                    base: null,

                    // The Vue plugin will parse absolute URLs and treat them
                    // as absolute paths to files on disk. Setting this to
                    // `false` will leave absolute URLs un-touched so they can
                    // reference assets in the public directory as expected.
                    includeAbsolute: false,
                },
            },
        }),
    ],
});
```

> [!NOTE]  
> Los [kits de inicio](/docs/{{version}}/starter-kits) de Laravel ya incluyen la configuración adecuada de Laravel, Vue y Vite. Consulta [Laravel Breeze](/docs/{{version}}/starter-kits#breeze-and-inertia) para la forma más rápida de comenzar con Laravel, Vue y Vite.

<a name="react"></a>
### React

Si deseas construir tu frontend utilizando el framework [React](https://reactjs.org/), entonces también necesitarás instalar el plugin `@vitejs/plugin-react`:

```sh
npm install --save-dev @vitejs/plugin-react
```

Luego puedes incluir el plugin en tu archivo de configuración `vite.config.js`:

```js
import { defineConfig } from 'vite';
import laravel from 'laravel-vite-plugin';
import react from '@vitejs/plugin-react';

export default defineConfig({
    plugins: [
        laravel(['resources/js/app.jsx']),
        react(),
    ],
});
```

Necesitarás asegurarte de que cualquier archivo que contenga JSX tenga una extensión `.jsx` o `.tsx`, recordando actualizar tu punto de entrada, si es necesario, como [se muestra arriba](#configuring-vite).

También necesitarás incluir la directiva de Blade adicional `@viteReactRefresh` junto con tu directiva `@vite` existente.

```blade
@viteReactRefresh
@vite('resources/js/app.jsx')
```

La directiva `@viteReactRefresh` debe ser llamada antes de la directiva `@vite`.

> [!NOTE]  
> Los [kits de inicio](/docs/{{version}}/starter-kits) de Laravel ya incluyen la configuración adecuada de Laravel, React y Vite. Consulta [Laravel Breeze](/docs/{{version}}/starter-kits#breeze-and-inertia) para la forma más rápida de comenzar con Laravel, React y Vite.

<a name="inertia"></a>
### Inertia

El plugin de Laravel Vite proporciona una conveniente función `resolvePageComponent` para ayudarte a resolver tus componentes de página de Inertia. A continuación se muestra un ejemplo del helper en uso con Vue 3; sin embargo, también puedes utilizar la función en otros frameworks como React:

```js
import { createApp, h } from 'vue';
import { createInertiaApp } from '@inertiajs/vue3';
import { resolvePageComponent } from 'laravel-vite-plugin/inertia-helpers';

createInertiaApp({
  resolve: (name) => resolvePageComponent(`./Pages/${name}.vue`, import.meta.glob('./Pages/**/*.vue')),
  setup({ el, App, props, plugin }) {
    return createApp({ render: () => h(App, props) })
      .use(plugin)
      .mount(el)
  },
});
```

> [!NOTE]  
> Los [kits de inicio](/docs/{{version}}/starter-kits) de Laravel ya incluyen la configuración adecuada de Laravel, Inertia y Vite. Consulta [Laravel Breeze](/docs/{{version}}/starter-kits#breeze-and-inertia) para la forma más rápida de comenzar con Laravel, Inertia y Vite.

<a name="url-processing"></a>
### Procesamiento de URL

Al usar Vite y referenciar activos en el HTML, CSS o JS de tu aplicación, hay un par de advertencias a considerar. Primero, si referencian activos con una ruta absoluta, Vite no incluirá el activo en la construcción; por lo tanto, debes asegurarte de que el activo esté disponible en tu directorio público.

Al referenciar rutas de activos relativas, debes recordar que las rutas son relativas al archivo donde se referencian. Cualquier activo referenciado a través de una ruta relativa será reescrito, versionado y agrupado por Vite.

Considera la siguiente estructura de proyecto:

```nothing
public/
  taylor.png
resources/
  js/
    Pages/
      Welcome.vue
  images/
    abigail.png
```

El siguiente ejemplo demuestra cómo Vite tratará las URLs relativas y absolutas:

```html
<!-- This asset is not handled by Vite and will not be included in the build -->
<img src="/taylor.png">

<!-- This asset will be re-written, versioned, and bundled by Vite -->
<img src="../../images/abigail.png">
```

<a name="working-with-stylesheets"></a>
## Trabajando Con Hojas de Estilo

Puedes aprender más sobre el soporte CSS de Vite dentro de la [documentación de Vite](https://vitejs.dev/guide/features.html#css). Si estás usando plugins de PostCSS como [Tailwind](https://tailwindcss.com), puedes crear un archivo `postcss.config.js` en la raíz de tu proyecto y Vite lo aplicará automáticamente:

```js
export default {
    plugins: {
        tailwindcss: {},
        autoprefixer: {},
    },
};
```

> [!NOTE]  
> Los [kits de inicio](/docs/{{version}}/starter-kits) de Laravel ya incluyen la configuración adecuada de Tailwind, PostCSS y Vite. O, si deseas usar Tailwind y Laravel sin usar uno de nuestros kits de inicio, consulta [la guía de instalación de Tailwind para Laravel](https://tailwindcss.com/docs/guides/laravel).

<a name="working-with-blade-and-routes"></a>
## Trabajando Con Blade y Rutas

<a name="blade-processing-static-assets"></a>
### Procesando Activos Estáticos Con Vite

Al referenciar activos en tu JavaScript o CSS, Vite los procesa y versiona automáticamente. Además, al construir aplicaciones basadas en Blade, Vite también puede procesar y versionar activos estáticos que solo referencias en plantillas de Blade.

Sin embargo, para lograr esto, necesitas hacer que Vite sea consciente de tus activos importando los activos estáticos en el punto de entrada de la aplicación. Por ejemplo, si deseas procesar y versionar todas las imágenes almacenadas en `resources/images` y todas las fuentes almacenadas en `resources/fonts`, deberías agregar lo siguiente en el punto de entrada `resources/js/app.js` de tu aplicación:

```js
import.meta.glob([
  '../images/**',
  '../fonts/**',
]);
```

Estos activos ahora serán procesados por Vite al ejecutar `npm run build`. Luego puedes referenciar estos activos en las plantillas de Blade utilizando el método `Vite::asset`, que devolverá la URL versionada para un activo dado:

```blade
<img src="{{ Vite::asset('resources/images/logo.png') }}">
```

<a name="blade-refreshing-on-save"></a>
### Refrescando al Guardar

Cuando tu aplicación se construye utilizando renderizado tradicional del lado del servidor con Blade, Vite puede mejorar tu flujo de trabajo de desarrollo al refrescar automáticamente el navegador cuando realizas cambios en los archivos de vista de tu aplicación. Para comenzar, simplemente puedes especificar la opción `refresh` como `true`.

```js
import { defineConfig } from 'vite';
import laravel from 'laravel-vite-plugin';

export default defineConfig({
    plugins: [
        laravel({
            // ...
            refresh: true,
        }),
    ],
});
```

Cuando la opción `refresh` es `true`, guardar archivos en los siguientes directorios provocará que el navegador realice una actualización completa de la página mientras ejecutas `npm run dev`:

- `app/View/Components/**`
- `lang/**`
- `resources/lang/**`
- `resources/views/**`
- `routes/**`

Observar el directorio `routes/**` es útil si estás utilizando [Ziggy](https://github.com/tighten/ziggy) para generar enlaces de rutas dentro del frontend de tu aplicación.

Si estas rutas predeterminadas no se adaptan a tus necesidades, puedes especificar tu propia lista de rutas a observar:

```js
import { defineConfig } from 'vite';
import laravel from 'laravel-vite-plugin';

export default defineConfig({
    plugins: [
        laravel({
            // ...
            refresh: ['resources/views/**'],
        }),
    ],
});
```

Bajo el capó, el plugin de Laravel Vite utiliza el paquete [`vite-plugin-full-reload`](https://github.com/ElMassimo/vite-plugin-full-reload), que ofrece algunas opciones de configuración avanzadas para ajustar el comportamiento de esta característica. Si necesitas este nivel de personalización, puedes proporcionar una definición de `config`:

```js
import { defineConfig } from 'vite';
import laravel from 'laravel-vite-plugin';

export default defineConfig({
    plugins: [
        laravel({
            // ...
            refresh: [{
                paths: ['path/to/watch/**'],
                config: { delay: 300 }
            }],
        }),
    ],
});
```

<a name="blade-aliases"></a>
### Alias

Es común en aplicaciones JavaScript [crear alias](#aliases) para directorios referenciados regularmente. Pero también puedes crear alias para usar en Blade utilizando el método `macro` en la clase `Illuminate\Support\Facades\Vite`. Típicamente, los "macros" deben definirse dentro del método `boot` de un [proveedor de servicios](/docs/{{version}}/providers):

    /**
     * Bootstrap any application services.
     */
    public function boot(): void
    {
        Vite::macro('image', fn (string $asset) => $this->asset("resources/images/{$asset}"));
    }

Una vez que se ha definido un macro, se puede invocar dentro de tus plantillas. Por ejemplo, podemos usar el macro `image` definido anteriormente para referenciar un activo ubicado en `resources/images/logo.png`:

```blade
<img src="{{ Vite::image('logo.png') }}" alt="Laravel Logo">
```

<a name="custom-base-urls"></a>
## URLs Base Personalizadas

Si tus activos compilados por Vite se despliegan en un dominio separado de tu aplicación, como a través de un CDN, debes especificar la variable de entorno `ASSET_URL` dentro del archivo `.env` de tu aplicación:

```env
ASSET_URL=https://cdn.example.com
```

Después de configurar la URL del activo, todas las URLs reescritas a tus activos estarán precedidas por el valor configurado:

```nothing
https://cdn.example.com/build/assets/app.9dce8d17.js
```

Recuerda que [las URLs absolutas no son reescritas por Vite](#url-processing), por lo que no estarán precedidas.

<a name="environment-variables"></a>
## Variables de Entorno

Puedes inyectar variables de entorno en tu JavaScript anteponiéndolas con `VITE_` en el archivo `.env` de tu aplicación:

```env
VITE_SENTRY_DSN_PUBLIC=http://example.com
```

Puedes acceder a las variables de entorno inyectadas a través del objeto `import.meta.env`:

```js
import.meta.env.VITE_SENTRY_DSN_PUBLIC
```

<a name="disabling-vite-in-tests"></a>
## Deshabilitar Vite en Pruebas

La integración de Vite en Laravel intentará resolver tus activos mientras ejecutas tus pruebas, lo que requiere que ejecutes el servidor de desarrollo de Vite o que construyas tus activos.

Si prefieres simular Vite durante las pruebas, puedes llamar al método `withoutVite`, que está disponible para cualquier prueba que extienda la clase `TestCase` de Laravel:

```php tab=Pest
test('without vite example', function () {
    $this->withoutVite();

    // ...
});
```

```php tab=PHPUnit
use Tests\TestCase;

class ExampleTest extends TestCase
{
    public function test_without_vite_example(): void
    {
        $this->withoutVite();

        // ...
    }
}
```

Si deseas deshabilitar Vite para todas las pruebas, puedes llamar al método `withoutVite` desde el método `setUp` en tu clase base `TestCase`:

```php
<?php

namespace Tests;

use Illuminate\Foundation\Testing\TestCase as BaseTestCase;

abstract class TestCase extends BaseTestCase
{
    protected function setUp(): void// [tl! add:start]
    {
        parent::setUp();

        $this->withoutVite();
    }// [tl! add:end]
}
```

<a name="ssr"></a>
## Renderizado del Lado del Servidor (SSR)

El plugin de Laravel Vite facilita la configuración del renderizado del lado del servidor con Vite. Para comenzar, crea un punto de entrada SSR en `resources/js/ssr.js` y especifica el punto de entrada pasando una opción de configuración al plugin de Laravel:

```js
import { defineConfig } from 'vite';
import laravel from 'laravel-vite-plugin';

export default defineConfig({
    plugins: [
        laravel({
            input: 'resources/js/app.js',
            ssr: 'resources/js/ssr.js',
        }),
    ],
});
```

Para asegurarte de no olvidar reconstruir el punto de entrada SSR, recomendamos aumentar el script "build" en el `package.json` de tu aplicación para crear tu construcción SSR:

```json
"scripts": {
     "dev": "vite",
     "build": "vite build" // [tl! remove]
     "build": "vite build && vite build --ssr" // [tl! add]
}
```

Luego, para construir e iniciar el servidor SSR, puedes ejecutar los siguientes comandos:

```sh
npm run build
node bootstrap/ssr/ssr.js
```

Si estás utilizando [SSR con Inertia](https://inertiajs.com/server-side-rendering), puedes usar el comando Artisan `inertia:start-ssr` para iniciar el servidor SSR:

```sh
php artisan inertia:start-ssr
```

> [!NOTE]  
> Los [kits de inicio](/docs/{{version}}/starter-kits) de Laravel ya incluyen la configuración adecuada de Laravel, Inertia SSR y Vite. Consulta [Laravel Breeze](/docs/{{version}}/starter-kits#breeze-and-inertia) para la forma más rápida de comenzar con Laravel, Inertia SSR y Vite.

<a name="script-and-style-attributes"></a>
## Atributos de Etiquetas de Script y Estilo

<a name="content-security-policy-csp-nonce"></a>
### Política de Seguridad de Contenidos (CSP) Nonce

Si deseas incluir un atributo [`nonce`](https://developer.mozilla.org/en-US/docs/Web/HTML/Global_attributes/nonce) en tus etiquetas de script y estilo como parte de tu [Política de Seguridad de Contenidos](https://developer.mozilla.org/en-US/docs/Web/HTTP/CSP), puedes generar o especificar un nonce utilizando el método `useCspNonce` dentro de un [middleware](/docs/{{version}}/middleware):

```php
<?php

namespace App\Http\Middleware;

use Closure;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Vite;
use Symfony\Component\HttpFoundation\Response;

class AddContentSecurityPolicyHeaders
{
    /**
     * Handle an incoming request.
     *
     * @param  \Closure(\Illuminate\Http\Request): (\Symfony\Component\HttpFoundation\Response)  $next
     */
    public function handle(Request $request, Closure $next): Response
    {
        Vite::useCspNonce();

        return $next($request)->withHeaders([
            'Content-Security-Policy' => "script-src 'nonce-".Vite::cspNonce()."'",
        ]);
    }
}
```

Después de invocar el método `useCspNonce`, Laravel incluirá automáticamente los atributos `nonce` en todas las etiquetas de script y estilo generadas.

Si necesitas especificar el nonce en otro lugar, incluyendo la directiva [Ziggy `@route`](https://github.com/tighten/ziggy#using-routes-with-a-content-security-policy) incluida con los [kits de inicio](/docs/{{version}}/starter-kits) de Laravel, puedes recuperarlo utilizando el método `cspNonce`:

```blade
@routes(nonce: Vite::cspNonce())
```

Si ya tienes un nonce que deseas que Laravel use, puedes pasar el nonce al método `useCspNonce`:

```php
Vite::useCspNonce($nonce);
```

<a name="subresource-integrity-sri"></a>
### Integridad de Subrecursos (SRI)

Si tu manifiesto de Vite incluye hashes de `integrity` para tus activos, Laravel agregará automáticamente el atributo `integrity` en cualquier etiqueta de script y estilo que genere para hacer cumplir la [Integridad de Subrecursos](https://developer.mozilla.org/en-US/docs/Web/Security/Subresource_Integrity). Por defecto, Vite no incluye el hash de `integrity` en su manifiesto, pero puedes habilitarlo instalando el plugin NPM [`vite-plugin-manifest-sri`](https://www.npmjs.com/package/vite-plugin-manifest-sri):

```shell
npm install --save-dev vite-plugin-manifest-sri
```

Luego, puedes habilitar este plugin en tu archivo `vite.config.js`:

```js
import { defineConfig } from 'vite';
import laravel from 'laravel-vite-plugin';
import manifestSRI from 'vite-plugin-manifest-sri';// [tl! add]

export default defineConfig({
    plugins: [
        laravel({
            // ...
        }),
        manifestSRI(),// [tl! add]
    ],
});
```

Si es necesario, también puedes personalizar la clave del manifiesto donde se puede encontrar el hash de integridad:

```php
use Illuminate\Support\Facades\Vite;

Vite::useIntegrityKey('custom-integrity-key');
```

Si deseas deshabilitar completamente esta detección automática, puedes pasar `false` al método `useIntegrityKey`:

```php
Vite::useIntegrityKey(false);
```

<a name="arbitrary-attributes"></a>
### Atributos Arbitrarios

Si necesitas incluir atributos adicionales en tus etiquetas de script y estilo, como el atributo [`data-turbo-track`](https://turbo.hotwired.dev/handbook/drive#reloading-when-assets-change), puedes especificarlos a través de los métodos `useScriptTagAttributes` y `useStyleTagAttributes`. Típicamente, estos métodos deben invocarse desde un [proveedor de servicios](/docs/{{version}}/providers):

```php
use Illuminate\Support\Facades\Vite;

Vite::useScriptTagAttributes([
    'data-turbo-track' => 'reload', // Specify a value for the attribute...
    'async' => true, // Specify an attribute without a value...
    'integrity' => false, // Exclude an attribute that would otherwise be included...
]);

Vite::useStyleTagAttributes([
    'data-turbo-track' => 'reload',
]);
```

Si necesitas agregar atributos condicionalmente, puedes pasar una función de retorno que recibirá la ruta del activo, su URL, su fragmento de manifiesto y el manifiesto completo:

```php
use Illuminate\Support\Facades\Vite;

Vite::useScriptTagAttributes(fn (string $src, string $url, array|null $chunk, array|null $manifest) => [
    'data-turbo-track' => $src === 'resources/js/app.js' ? 'reload' : false,
]);

Vite::useStyleTagAttributes(fn (string $src, string $url, array|null $chunk, array|null $manifest) => [
    'data-turbo-track' => $chunk && $chunk['isEntry'] ? 'reload' : false,
]);
```

> [!WARNING]  
> Los argumentos `$chunk` y `$manifest` serán `null` mientras se esté ejecutando el servidor de desarrollo de Vite.

<a name="advanced-customization"></a>
## Personalización Avanzada

De forma predeterminada, el plugin de Vite de Laravel utiliza convenciones sensatas que deberían funcionar para la mayoría de las aplicaciones; sin embargo, a veces es posible que necesites personalizar el comportamiento de Vite. Para habilitar opciones de personalización adicionales, ofrecemos los siguientes métodos y opciones que se pueden usar en lugar de la directiva Blade `@vite`:

```blade
<!doctype html>
<head>
    {{-- ... --}}

    {{
        Vite::useHotFile(storage_path('vite.hot')) // Customize the "hot" file...
            ->useBuildDirectory('bundle') // Customize the build directory...
            ->useManifestFilename('assets.json') // Customize the manifest filename...
            ->withEntryPoints(['resources/js/app.js']) // Specify the entry points...
            ->createAssetPathsUsing(function (string $path, ?bool $secure) { // Customize the backend path generation for built assets...
                return "https://cdn.example.com/{$path}";
            })
    }}
</head>
```

Dentro del archivo `vite.config.js`, deberías especificar la misma configuración:

```js
import { defineConfig } from 'vite';
import laravel from 'laravel-vite-plugin';

export default defineConfig({
    plugins: [
        laravel({
            hotFile: 'storage/vite.hot', // Customize the "hot" file...
            buildDirectory: 'bundle', // Customize the build directory...
            input: ['resources/js/app.js'], // Specify the entry points...
        }),
    ],
    build: {
      manifest: 'assets.json', // Customize the manifest filename...
    },
});
```

<a name="correcting-dev-server-urls"></a>
### Corrigiendo URLs del Servidor de Desarrollo

Algunos plugins dentro del ecosistema de Vite asumen que las URLs que comienzan con una barra diagonal siempre apuntarán al servidor de desarrollo de Vite. Sin embargo, debido a la naturaleza de la integración de Laravel, este no es el caso.

Por ejemplo, el plugin `vite-imagetools` genera URLs como la siguiente mientras Vite está sirviendo tus activos:

```html
<img src="/@imagetools/f0b2f404b13f052c604e632f2fb60381bf61a520">
```

El plugin `vite-imagetools` espera que la URL de salida sea interceptada por Vite y que el plugin pueda manejar todas las URLs que comienzan con `/@imagetools`. Si estás utilizando plugins que esperan este comportamiento, necesitarás corregir manualmente las URLs. Puedes hacer esto en tu archivo `vite.config.js` utilizando la opción `transformOnServe`.

En este ejemplo particular, prependemos la URL del servidor de desarrollo a todas las ocurrencias de `/@imagetools` dentro del código generado:

```js
import { defineConfig } from 'vite';
import laravel from 'laravel-vite-plugin';
import { imagetools } from 'vite-imagetools';

export default defineConfig({
    plugins: [
        laravel({
            // ...
            transformOnServe: (code, devServerUrl) => code.replaceAll('/@imagetools', devServerUrl+'/@imagetools'),
        }),
        imagetools(),
    ],
});
```

Ahora, mientras Vite está sirviendo activos, generará URLs que apuntan al servidor de desarrollo de Vite:

```html
- <img src="/@imagetools/f0b2f404b13f052c604e632f2fb60381bf61a520"><!-- [tl! remove] -->
+ <img src="http://[::1]:5173/@imagetools/f0b2f404b13f052c604e632f2fb60381bf61a520"><!-- [tl! add] -->
```
