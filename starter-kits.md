# Kits de inicio

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

Para darte un buen inicio en la construcción de tu nueva aplicación Laravel, nos complace ofrecer kits de inicio de autenticación y aplicación. Estos kits configuran automáticamente tu aplicación con las rutas, controladores y vistas que necesitas para registrar y autenticar a los usuarios de tu aplicación.
Aunque puedes usar estos kits de inicio, no son obligatorios. Eres libre de construir tu propia aplicación desde cero simplemente instalando una copia nueva de Laravel. De cualquier manera, sabemos que construirás algo genial.

<a name="laravel-breeze"></a>
## Laravel Breeze

[Laravel Breeze](https://github.com/laravel/breeze) es una implementación mínima y simple de todas las [funciones de autenticación](/docs/%7B%7Bversion%7D%7D/authentication) de Laravel, incluyendo inicio de sesión, registro, restablecimiento de contraseña, verificación de correo electrónico y confirmación de contraseña. Además, Breeze incluye una simple página de "perfil" donde el usuario puede actualizar su nombre, dirección de correo electrónico y contraseña.
La capa de vista predeterminada de Laravel Breeze está compuesta por simples [plantillas Blade](/docs/%7B%7Bversion%7D%7D/blade) estilizadas con [Tailwind CSS](https://tailwindcss.com). Además, Breeze ofrece opciones de scaffolding basadas en [Livewire](https://livewire.laravel.com) o [Inertia](https://inertiajs.com), con la opción de usar Vue o React para el scaffolding basado en Inertia.
<img src="https://laravel.com/img/docs/breeze-register.png">
#### Laravel Bootcamp

Si eres nuevo en Laravel, no dudes en unirte al [Laravel Bootcamp](https://bootcamp.laravel.com). El Laravel Bootcamp te guiará a través de la construcción de tu primera aplicación Laravel utilizando Breeze. Es una excelente manera de obtener un recorrido por todo lo que Laravel y Breeze tienen para ofrecer.

<a name="laravel-breeze-installation"></a>
### Instalación

Primero, deberías [crear una nueva aplicación Laravel](/docs/%7B%7Bversion%7D%7D/installation). Si creas tu aplicación utilizando el [instalador de Laravel](/docs/%7B%7Bversion%7D%7D/installation#creating-a-laravel-project), se te pedirá que instales Laravel Breeze durante el proceso de instalación. De lo contrario, necesitarás seguir las instrucciones de instalación manual a continuación.
Si ya has creado una nueva aplicación Laravel sin un kit de inicio, puedes instalar Laravel Breeze manualmente usando Composer:


```shell
composer require laravel/breeze --dev

```
Después de que Composer haya instalado el paquete Laravel Breeze, deberías ejecutar el comando Artisan `breeze:install`. Este comando publica las vistas de autenticación, rutas, controladores y otros recursos en tu aplicación. Laravel Breeze publica todo su código en tu aplicación para que tengas control y visibilidad total sobre sus características e implementación.
El comando `breeze:install` te pedirá que elijas tu stack frontend y framework de pruebas preferidos:

<a name="breeze-and-blade"></a>
### Breeze y Blade

El "stack" predeterminado de Breeze es el stack de Blade, que utiliza simples [plantillas de Blade](/docs/%7B%7Bversion%7D%7D/blade) para renderizar el frontend de tu aplicación. El stack de Blade se puede instalar invocando el comando `breeze:install` sin otros argumentos adicionales y seleccionando el stack frontend de Blade. Después de que se instale la estructura de Breeze, también deberías compilar los activos frontend de tu aplicación:
> [!NOTA]
Para obtener más información sobre la compilación del CSS y JavaScript de tu aplicación, consulta la [documentación de Vite de Laravel](/docs/%7B%7Bversion%7D%7D/vite#running-vite).

<a name="breeze-and-livewire"></a>
### Breeze y Livewire

Laravel Breeze también ofrece un scaffolding de [Livewire](https://livewire.laravel.com). Livewire es una forma poderosa de construir interfaces de usuario dinámicas y reactivas en el frontend utilizando solo PHP.
Livewire es una excelente opción para equipos que utilizan principalmente plantillas Blade y buscan una alternativa más simple a los frameworks SPA impulsados por JavaScript como Vue y React.
Para utilizar la pila de Livewire, puedes seleccionar la pila frontend de Livewire al ejecutar el comando Artisan `breeze:install`. Después de que se instalen los andamios de Breeze, deberías ejecutar tus migraciones de base de datos:

<a name="breeze-and-inertia"></a>
### Breeze y React / Vue

Laravel Breeze también ofrece scaffolding para React y Vue a través de una implementación frontend de [Inertia](https://inertiajs.com). Inertia te permite construir aplicaciones modernas de una sola página con React y Vue utilizando el enrutamiento y los controladores del lado del servidor clásicos.
Inertia te permite disfrutar del poder del frontend de React y Vue combinado con la increíble productividad del backend de Laravel y la compilación ultrarrápida de [Vite](https://vitejs.dev). Para usar un stack de Inertia, puedes seleccionar los stacks de frontend de Vue o React al ejecutar el comando Artisan `breeze:install`.
Al seleccionar el stack frontend de Vue o React, el instalador de Breeze también te pedirá que determines si te gustaría soporte para [Inertia SSR](https://inertiajs.com/server-side-rendering) o TypeScript. Después de que se instale el scaffolding de Breeze, también deberías compilar los assets del frontend de tu aplicación:


```shell
php artisan breeze:install

php artisan migrate
npm install
npm run dev

```
A continuación, puedes navegar a las URL `/login` o `/register` de tu aplicación en tu navegador web. Todas las rutas de Breeze están definidas dentro del archivo `routes/auth.php`.

<a name="breeze-and-next"></a>
### Breeze y Next.js / API

Laravel Breeze también puede generar una API de autenticación que esté lista para autenticar aplicaciones JavaScript modernas, como las que utilizan [Next](https://nextjs.org), [Nuxt](https://nuxt.com) y otras. Para comenzar, selecciona el stack de API como tu stack deseado al ejecutar el comando Artisan `breeze:install`:


```shell
php artisan breeze:install

php artisan migrate

```
Durante la instalación, Breeze añadirá una variable de entorno `FRONTEND_URL` al archivo `.env` de tu aplicación. Esta URL debe ser la URL de tu aplicación JavaScript. Típicamente, será `http://localhost:3000` durante el desarrollo local. Además, debes asegurarte de que tu `APP_URL` esté configurado en `http://localhost:8000`, que es la URL por defecto utilizada por el comando `serve` de Artisan.

<a name="next-reference-implementation"></a>
#### Implementación de referencia de Next.js

Finalmente, estás listo para emparejar este backend con el frontend de tu elección. Una implementación de referencia de Next del frontend de Breeze está [disponible en GitHub](https://github.com/laravel/breeze-next). Este frontend es mantenido por Laravel y contiene la misma interfaz de usuario que las pilas tradicionales de Blade e Inertia proporcionadas por Breeze.

<a name="laravel-jetstream"></a>
## Laravel Jetstream

Mientras que Laravel Breeze ofrece un punto de partida simple y minimalista para construir una aplicación Laravel, Jetstream aumenta esa funcionalidad con características más robustas y pilas de tecnología frontend adicionales. **Para aquellos que son nuevos en Laravel, recomendamos aprender lo básico con Laravel Breeze antes de avanzar a Laravel Jetstream.**
Jetstream proporciona un andamiaje de aplicación bellamente diseñado para Laravel e incluye inicio de sesión, registro, verificación de correo electrónico, autenticación de dos factores, gestión de sesiones, soporte API a través de Laravel Sanctum y gestión de equipos opcional. Jetstream está diseñado utilizando [Tailwind CSS](https://tailwindcss.com) y ofrece tu elección de andamiaje frontend impulsado por [Livewire](https://livewire.laravel.com) o [Inertia](https://inertiajs.com).
La documentación completa para instalar Laravel Jetstream se puede encontrar en la [documentación oficial de Jetstream](https://jetstream.laravel.com).