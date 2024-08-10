# Laravel Mix

- [Introducción](#introduction)

<a name="introduction"></a>
## Introducción

[Laravel Mix](https://github.com/laravel-mix/laravel-mix), un paquete desarrollado por el creador de [Laracasts](https://laracasts.com), Jeffrey Way, proporciona una API fluida para definir los pasos de construcción de [webpack](https://webpack.js.org) para tu aplicación Laravel utilizando varios preprocesadores comunes de CSS y JavaScript.

En otras palabras, Mix facilita la compilación y minificación de los archivos CSS y JavaScript de tu aplicación. A través de una simple cadena de métodos, puedes definir de manera fluida tu canalización de activos. Por ejemplo:

```js
mix.js('resources/js/app.js', 'public/js')
    .postCss('resources/css/app.css', 'public/css');
```

Si alguna vez te has sentido confundido y abrumado al comenzar con webpack y la compilación de activos, te encantará Laravel Mix. Sin embargo, no estás obligado a usarlo mientras desarrollas tu aplicación; eres libre de usar cualquier herramienta de canalización de activos que desees, o incluso ninguna en absoluto.

> [!NOTE]  
> Vite ha reemplazado a Laravel Mix en nuevas instalaciones de Laravel. Para la documentación de Mix, visita el sitio web de [Laravel Mix oficial](https://laravel-mix.com/). Si deseas cambiar a Vite, consulta nuestra [guía de migración a Vite](https://github.com/laravel/vite-plugin/blob/main/UPGRADE.md#migrating-from-laravel-mix-to-vite).
