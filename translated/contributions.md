# Guía de Contribución

- [Guía de Contribución](#guía-de-contribución)
  - [Informes de Errores](#informes-de-errores)
  - [Preguntas de Soporte](#preguntas-de-soporte)
  - [Discusión sobre el Desarrollo del Núcleo](#discusión-sobre-el-desarrollo-del-núcleo)
  - [¿Qué Rama?](#qué-rama)
  - [Activos Compilados](#activos-compilados)
  - [Vulnerabilidades de Seguridad](#vulnerabilidades-de-seguridad)
  - [Estilo de Codificación](#estilo-de-codificación)
    - [PHPDoc](#phpdoc)
    - [StyleCI](#styleci)
  - [Código de Conducta](#código-de-conducta)

<a name="bug-reports"></a>
## Informes de Errores

Para fomentar la colaboración activa, Laravel anima encarecidamente a realizar solicitudes de extracción, no solo informes de errores. Las solicitudes de extracción solo se revisarán cuando estén marcadas como "listas para revisión" (no en estado de "borrador") y todas las pruebas para nuevas características estén aprobadas. Las solicitudes de extracción que queden en estado de "borrador" y no estén activas se cerrarán después de unos días.

Sin embargo, si presentas un informe de error, tu problema debe contener un título y una descripción clara del problema. También debes incluir tanta información relevante como sea posible y un ejemplo de código que demuestre el problema. El objetivo de un informe de error es facilitarte a ti - y a otros - la replicación del error y el desarrollo de una solución.

Recuerda, los informes de errores se crean con la esperanza de que otros con el mismo problema puedan colaborar contigo en su solución. No esperes que el informe de error vea automáticamente alguna actividad o que otros se apresuren a solucionarlo. Crear un informe de error sirve para ayudarte a ti y a otros a comenzar en el camino de solucionar el problema. Si deseas contribuir, puedes ayudar solucionando [cualquier error listado en nuestros rastreadores de problemas](https://github.com/issues?q=is%3Aopen+is%3Aissue+label%3Abug+user%3Alaravel). Debes estar autenticado con GitHub para ver todos los problemas de Laravel.

Si notas un DocBlock, advertencias de PHPStan o IDE inapropiados mientras usas Laravel, no crees un problema en GitHub. En su lugar, por favor, envía una solicitud de extracción para solucionar el problema.

El código fuente de Laravel se gestiona en GitHub, y hay repositorios para cada uno de los proyectos de Laravel:

<div class="content-list" markdown="1">

- [Laravel Application](https://github.com/laravel/laravel)
- [Laravel Art](https://github.com/laravel/art)
- [Laravel Documentation](https://github.com/laravel/docs)
- [Laravel Dusk](https://github.com/laravel/dusk)
- [Laravel Cashier Stripe](https://github.com/laravel/cashier)
- [Laravel Cashier Paddle](https://github.com/laravel/cashier-paddle)
- [Laravel Echo](https://github.com/laravel/echo)
- [Laravel Envoy](https://github.com/laravel/envoy)
- [Laravel Folio](https://github.com/laravel/folio)
- [Laravel Framework](https://github.com/laravel/framework)
- [Laravel Homestead](https://github.com/laravel/homestead) ([Build Scripts](https://github.com/laravel/settler))
- [Laravel Horizon](https://github.com/laravel/horizon)
- [Laravel Jetstream](https://github.com/laravel/jetstream)
- [Laravel Passport](https://github.com/laravel/passport)
- [Laravel Pennant](https://github.com/laravel/pennant)
- [Laravel Pint](https://github.com/laravel/pint)
- [Laravel Prompts](https://github.com/laravel/prompts)
- [Laravel Reverb](https://github.com/laravel/reverb)
- [Laravel Sail](https://github.com/laravel/sail)
- [Laravel Sanctum](https://github.com/laravel/sanctum)
- [Laravel Scout](https://github.com/laravel/scout)
- [Laravel Socialite](https://github.com/laravel/socialite)
- [Laravel Telescope](https://github.com/laravel/telescope)
- [Laravel Website](https://github.com/laravel/laravel.com)

</div>

<a name="support-questions"></a>
## Preguntas de Soporte

Los rastreadores de problemas de GitHub de Laravel no están destinados a proporcionar ayuda o soporte para Laravel. En su lugar, utiliza uno de los siguientes canales:

<div class="content-list" markdown="1">

- [GitHub Discussions](https://github.com/laravel/framework/discussions)
- [Laracasts Forums](https://laracasts.com/discuss)
- [Laravel.io Forums](https://laravel.io/forum)
- [StackOverflow](https://stackoverflow.com/questions/tagged/laravel)
- [Discord](https://discord.gg/laravel)
- [Larachat](https://larachat.co)
- [IRC](https://web.libera.chat/?nick=artisan&channels=#laravel)

</div>

<a name="core-development-discussion"></a>
## Discusión sobre el Desarrollo del Núcleo

Puedes proponer nuevas características o mejoras del comportamiento existente de Laravel en el [tablero de discusión de GitHub](https://github.com/laravel/framework/discussions) del repositorio del marco de Laravel. Si propones una nueva característica, por favor, estate dispuesto a implementar al menos parte del código que se necesitaría para completar la característica.

La discusión informal sobre errores, nuevas características e implementación de características existentes tiene lugar en el canal `#internals` del [servidor de Discord de Laravel](https://discord.gg/laravel). Taylor Otwell, el mantenedor de Laravel, suele estar presente en el canal durante los días de semana de 8am a 5pm (UTC-06:00 o America/Chicago), y está presente esporádicamente en el canal en otros momentos.

<a name="which-branch"></a>
## ¿Qué Rama?

**Todas** las correcciones de errores deben enviarse a la última versión que soporte correcciones de errores (actualmente `10.x`). Las correcciones de errores **nunca** deben enviarse a la rama `master` a menos que solucionen características que existan solo en la próxima versión.

**Características menores** que son **totalmente compatibles hacia atrás** con la versión actual pueden enviarse a la última rama estable (actualmente `11.x`).

**Nuevas características** importantes o características con cambios disruptivos siempre deben enviarse a la rama `master`, que contiene la próxima versión.

<a name="compiled-assets"></a>
## Activos Compilados

Si estás enviando un cambio que afectará a un archivo compilado, como la mayoría de los archivos en `resources/css` o `resources/js` del repositorio `laravel/laravel`, no comités los archivos compilados. Debido a su gran tamaño, no pueden ser revisados de manera realista por un mantenedor. Esto podría ser explotado como una forma de inyectar código malicioso en Laravel. Para prevenir esto de manera defensiva, todos los archivos compilados serán generados y comiteados por los mantenedores de Laravel.

<a name="security-vulnerabilities"></a>
## Vulnerabilidades de Seguridad

Si descubres una vulnerabilidad de seguridad dentro de Laravel, por favor envía un correo electrónico a Taylor Otwell a <a href="mailto:taylor@laravel.com">taylor@laravel.com</a>. Todas las vulnerabilidades de seguridad serán atendidas de inmediato.

<a name="coding-style"></a>
## Estilo de Codificación

Laravel sigue el estándar de codificación [PSR-2](https://github.com/php-fig/fig-standards/blob/master/accepted/PSR-2-coding-style-guide.md) y el estándar de autoloading [PSR-4](https://github.com/php-fig/fig-standards/blob/master/accepted/PSR-4-autoloader.md).

<a name="phpdoc"></a>
### PHPDoc

A continuación se muestra un ejemplo de un bloque de documentación válido de Laravel. Ten en cuenta que el atributo `@param` es seguido por dos espacios, el tipo de argumento, dos espacios más y finalmente el nombre de la variable:

    /**
     * Registrar un enlace con el contenedor.
     *
     * @param  string|array  $abstract
     * @param  \Closure|string|null  $concrete
     * @param  bool  $shared
     * @return void
     *
     * @throws \Exception
     */
    public function bind($abstract, $concrete = null, $shared = false)
    {
        // ...
    }

Cuando los atributos `@param` o `@return` son redundantes debido al uso de tipos nativos, pueden ser eliminados:

    /**
     * Ejecutar el trabajo.
     */
    public function handle(AudioProcessor $processor): void
    {
        //
    }

Sin embargo, cuando el tipo nativo es genérico, por favor especifica el tipo genérico mediante el uso de los atributos `@param` o `@return`:

    /**
     * Obtener los adjuntos para el mensaje.
     *
     * @return array<int, \Illuminate\Mail\Mailables\Attachment>
     */
    public function attachments(): array
    {
        return [
            Attachment::fromStorage('/path/to/file'),
        ];
    }

<a name="styleci"></a>
### StyleCI

¡No te preocupes si el estilo de tu código no es perfecto! [StyleCI](https://styleci.io/) fusionará automáticamente cualquier corrección de estilo en el repositorio de Laravel después de que se fusionen las solicitudes de extracción. Esto nos permite centrarnos en el contenido de la contribución y no en el estilo del código.

<a name="code-of-conduct"></a>
## Código de Conducta

El código de conducta de Laravel se deriva del código de conducta de Ruby. Cualquier violación del código de conducta puede ser reportada a Taylor Otwell (taylor@laravel.com):

<div class="content-list" markdown="1">

- Los participantes serán tolerantes con las opiniones opuestas.
- Los participantes deben asegurarse de que su lenguaje y acciones estén libres de ataques personales y comentarios despectivos.
- Al interpretar las palabras y acciones de otros, los participantes siempre deben asumir buenas intenciones.
- El comportamiento que pueda considerarse razonablemente acoso no será tolerado.

</div>
