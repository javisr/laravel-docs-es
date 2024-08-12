# Laravel Mix

- [Introducción](#introduction)

<a name="introduction"></a>
## Introducción

[Laravel Mix](https://github.com/laravel-mix/laravel-mix), un paquete desarrollado por el creador de [Laracasts](https://laracasts.com) Jeffrey Way, proporciona una API fluida para definir los pasos de construcción de [webpack](https://webpack.js.org) para tu aplicación Laravel usando varios pre-procesadores CSS y JavaScript comunes.

En otras palabras, Mix hace que sea muy fácil compilar y minificar los archivos CSS y JavaScript de tu aplicación. A través de un simple encadenamiento de métodos, puedes definir con fluidez tu pipeline de assets. Por ejemplo:

```js
mix.js('resources/js/app.js', 'public/js')
    .postCss('resources/css/app.css', 'public/css');
```

Si alguna vez has estado confundido y abrumado sobre cómo empezar con webpack y la compilación de activos, te encantará Laravel Mix. Sin embargo, no estás obligado a usarlo mientras desarrollas tu aplicación; eres libre de usar cualquier herramienta de asset pipeline que desees, o incluso ninguna.

> **Nota**  
> Vite ha sustituido a Laravel Mix en las nuevas instalaciones de Laravel. Para la documentación de Mix, por favor visite el sitio web [oficial de Laravel Mix](https://laravel-mix.com/). Si desea cambiar a Vite, consulte nuestra [guía de migración a Vite](https://github.com/laravel/vite-plugin/blob/main/UPGRADE.md#migrating-from-laravel-mix-to-vite).
