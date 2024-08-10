# Kits de Inicio

- [Introducción](#introduction)
- [Laravel Breeze](#laravel-breeze)
    - [Instalación](#laravel-breeze-installation)
    - [Breeze y Blade](#breeze-and-blade)
    - [Breeze y Livewire](#breeze-and-livewire)
    - [Breeze y React / Vue](#breeze-and-inertia)
    - [Breeze y Next.js / API](#breeze-and-next)
- [Laravel Jetstream](#laravel-jetstream)

<a name="introduction"></a>
## Introducción

Para darte una ventaja al construir tu nueva aplicación Laravel, estamos felices de ofrecer kits de inicio de autenticación y aplicación. Estos kits generan automáticamente la estructura de tu aplicación con las rutas, controladores y vistas que necesitas para registrar y autenticar a los usuarios de tu aplicación.

Si bien eres bienvenido a usar estos kits de inicio, no son obligatorios. Eres libre de construir tu propia aplicación desde cero simplemente instalando una copia nueva de Laravel. De cualquier manera, sabemos que construirás algo grandioso.

<a name="laravel-breeze"></a>
## Laravel Breeze

[Laravel Breeze](https://github.com/laravel/breeze) es una implementación mínima y simple de todas las [funciones de autenticación](/docs/{{version}}/authentication) de Laravel, incluyendo inicio de sesión, registro, restablecimiento de contraseña, verificación de correo electrónico y confirmación de contraseña. Además, Breeze incluye una simple página de "perfil" donde el usuario puede actualizar su nombre, dirección de correo electrónico y contraseña.

La capa de vista predeterminada de Laravel Breeze está compuesta por simples [plantillas Blade](/docs/{{version}}/blade) estilizadas con [Tailwind CSS](https://tailwindcss.com). Además, Breeze proporciona opciones de scaffolding basadas en [Livewire](https://livewire.laravel.com) o [Inertia](https://inertiajs.com), con la opción de usar Vue o React para el scaffolding basado en Inertia.

<img src="https://laravel.com/img/docs/breeze-register.png">

#### Laravel Bootcamp

Si eres nuevo en Laravel, siéntete libre de unirte al [Laravel Bootcamp](https://bootcamp.laravel.com). El Laravel Bootcamp te guiará a través de la construcción de tu primera aplicación Laravel usando Breeze. Es una excelente manera de obtener un recorrido por todo lo que Laravel y Breeze tienen para ofrecer.

<a name="laravel-breeze-installation"></a>
### Instalación

Primero, debes [crear una nueva aplicación Laravel](/docs/{{version}}/installation). Si creas tu aplicación usando el [instalador de Laravel](/docs/{{version}}/installation#creating-a-laravel-project), se te pedirá que instales Laravel Breeze durante el proceso de instalación. De lo contrario, deberás seguir las instrucciones de instalación manual a continuación.

Si ya has creado una nueva aplicación Laravel sin un kit de inicio, puedes instalar Laravel Breeze manualmente usando Composer:

```shell
composer require laravel/breeze --dev
```

Después de que Composer haya instalado el paquete Laravel Breeze, debes ejecutar el comando Artisan `breeze:install`. Este comando publica las vistas de autenticación, rutas, controladores y otros recursos en tu aplicación. Laravel Breeze publica todo su código en tu aplicación para que tengas control total y visibilidad sobre sus características e implementación.

El comando `breeze:install` te pedirá que elijas tu pila de frontend y marco de pruebas preferidos:

```shell
php artisan breeze:install

php artisan migrate
npm install
npm run dev
```

<a name="breeze-and-blade"></a>
### Breeze y Blade

La "pila" predeterminada de Breeze es la pila Blade, que utiliza simples [plantillas Blade](/docs/{{version}}/blade) para renderizar el frontend de tu aplicación. La pila Blade puede ser instalada invocando el comando `breeze:install` sin otros argumentos adicionales y seleccionando la pila de frontend Blade. Después de que se instale el scaffolding de Breeze, también debes compilar los activos de frontend de tu aplicación:

```shell
php artisan breeze:install

php artisan migrate
npm install
npm run dev
```

A continuación, puedes navegar a las URLs `/login` o `/register` de tu aplicación en tu navegador web. Todas las rutas de Breeze están definidas dentro del archivo `routes/auth.php`.

> [!NOTE]  
> Para aprender más sobre cómo compilar el CSS y JavaScript de tu aplicación, consulta la [documentación de Vite](/docs/{{version}}/vite#running-vite) de Laravel.

<a name="breeze-and-livewire"></a>
### Breeze y Livewire

Laravel Breeze también ofrece scaffolding de [Livewire](https://livewire.laravel.com). Livewire es una forma poderosa de construir UIs dinámicas y reactivas en el frontend usando solo PHP.

Livewire es una excelente opción para equipos que utilizan principalmente plantillas Blade y buscan una alternativa más simple a los frameworks SPA impulsados por JavaScript como Vue y React.

Para usar la pila de Livewire, puedes seleccionar la pila de frontend de Livewire al ejecutar el comando Artisan `breeze:install`. Después de que se instale el scaffolding de Breeze, debes ejecutar tus migraciones de base de datos:

```shell
php artisan breeze:install

php artisan migrate
```

<a name="breeze-and-inertia"></a>
### Breeze y React / Vue

Laravel Breeze también ofrece scaffolding de React y Vue a través de una implementación de frontend de [Inertia](https://inertiajs.com). Inertia te permite construir aplicaciones modernas de una sola página con React y Vue utilizando el enrutamiento y controladores del lado del servidor clásicos.

Inertia te permite disfrutar del poder del frontend de React y Vue combinado con la increíble productividad del backend de Laravel y la compilación ultrarrápida de [Vite](https://vitejs.dev). Para usar una pila de Inertia, puedes seleccionar las pilas de frontend de Vue o React al ejecutar el comando Artisan `breeze:install`.

Al seleccionar la pila de frontend de Vue o React, el instalador de Breeze también te pedirá que determines si deseas soporte para [Inertia SSR](https://inertiajs.com/server-side-rendering) o TypeScript. Después de que se instale el scaffolding de Breeze, también debes compilar los activos de frontend de tu aplicación:

```shell
php artisan breeze:install

php artisan migrate
npm install
npm run dev
```

A continuación, puedes navegar a las URLs `/login` o `/register` de tu aplicación en tu navegador web. Todas las rutas de Breeze están definidas dentro del archivo `routes/auth.php`.

<a name="breeze-and-next"></a>
### Breeze y Next.js / API

Laravel Breeze también puede generar una API de autenticación que esté lista para autenticar aplicaciones modernas de JavaScript, como las impulsadas por [Next](https://nextjs.org), [Nuxt](https://nuxt.com) y otras. Para comenzar, selecciona la pila de API como tu pila deseada al ejecutar el comando Artisan `breeze:install`:

```shell
php artisan breeze:install

php artisan migrate
```

Durante la instalación, Breeze añadirá una variable de entorno `FRONTEND_URL` al archivo `.env` de tu aplicación. Esta URL debe ser la URL de tu aplicación de JavaScript. Esto será típicamente `http://localhost:3000` durante el desarrollo local. Además, debes asegurarte de que tu `APP_URL` esté configurado como `http://localhost:8000`, que es la URL predeterminada utilizada por el comando Artisan `serve`.

<a name="next-reference-implementation"></a>
#### Implementación de Referencia de Next.js

Finalmente, estás listo para emparejar este backend con el frontend de tu elección. Una implementación de referencia de Next del frontend de Breeze está [disponible en GitHub](https://github.com/laravel/breeze-next). Este frontend es mantenido por Laravel y contiene la misma interfaz de usuario que las pilas tradicionales de Blade e Inertia proporcionadas por Breeze.

<a name="laravel-jetstream"></a>
## Laravel Jetstream

Mientras que Laravel Breeze proporciona un punto de partida simple y mínimo para construir una aplicación Laravel, Jetstream complementa esa funcionalidad con características más robustas y pilas de tecnología de frontend adicionales. **Para aquellos que son completamente nuevos en Laravel, recomendamos aprender lo básico con Laravel Breeze antes de pasar a Laravel Jetstream.**

Jetstream proporciona un scaffolding de aplicación bellamente diseñado para Laravel e incluye inicio de sesión, registro, verificación de correo electrónico, autenticación de dos factores, gestión de sesiones, soporte de API a través de Laravel Sanctum y gestión de equipos opcional. Jetstream está diseñado utilizando [Tailwind CSS](https://tailwindcss.com) y ofrece la opción de scaffolding de frontend impulsado por [Livewire](https://livewire.laravel.com) o [Inertia](https://inertiajs.com).

La documentación completa para instalar Laravel Jetstream se puede encontrar en la [documentación oficial de Jetstream](https://jetstream.laravel.com).
