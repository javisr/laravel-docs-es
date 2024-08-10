# Laravel Pint

- [Introducción](#introduction)
- [Instalación](#installation)
- [Ejecutando Pint](#running-pint)
- [Configurando Pint](#configuring-pint)
    - [Presets](#presets)
    - [Reglas](#rules)
    - [Excluyendo Archivos / Carpetas](#excluding-files-or-folders)
- [Integración Continua](#continuous-integration)
    - [GitHub Actions](#running-tests-on-github-actions)

<a name="introduction"></a>
## Introducción

[Laravel Pint](https://github.com/laravel/pint) es un fijador de estilo de código PHP con opiniones para minimalistas. Pint está construido sobre PHP-CS-Fixer y facilita asegurar que el estilo de tu código se mantenga limpio y consistente.

Pint se instala automáticamente con todas las nuevas aplicaciones de Laravel, por lo que puedes comenzar a usarlo de inmediato. Por defecto, Pint no requiere ninguna configuración y solucionará los problemas de estilo de código en tu código siguiendo el estilo de codificación opinado de Laravel.

<a name="installation"></a>
## Instalación

Pint está incluido en las versiones recientes del framework Laravel, por lo que la instalación suele ser innecesaria. Sin embargo, para aplicaciones más antiguas, puedes instalar Laravel Pint a través de Composer:

```shell
composer require laravel/pint --dev
```

<a name="running-pint"></a>
## Ejecutando Pint

Puedes instruir a Pint para que solucione problemas de estilo de código invocando el binario `pint` que está disponible en el directorio `vendor/bin` de tu proyecto:

```shell
./vendor/bin/pint
```

También puedes ejecutar Pint en archivos o directorios específicos:

```shell
./vendor/bin/pint app/Models

./vendor/bin/pint app/Models/User.php
```

Pint mostrará una lista exhaustiva de todos los archivos que actualiza. Puedes ver aún más detalles sobre los cambios de Pint proporcionando la opción `-v` al invocar Pint:

```shell
./vendor/bin/pint -v
```

Si deseas que Pint simplemente inspeccione tu código en busca de errores de estilo sin cambiar realmente los archivos, puedes usar la opción `--test`. Pint devolverá un código de salida distinto de cero si se encuentran errores de estilo de código:

```shell
./vendor/bin/pint --test
```

Si deseas que Pint solo modifique los archivos que tienen cambios no confirmados según Git, puedes usar la opción `--dirty`:

```shell
./vendor/bin/pint --dirty
```

Si deseas que Pint solucione cualquier archivo con errores de estilo de código pero también salga con un código de salida distinto de cero si se corrigieron errores, puedes usar la opción `--repair`:

```shell
./vendor/bin/pint --repair
```

<a name="configuring-pint"></a>
## Configurando Pint

Como se mencionó anteriormente, Pint no requiere ninguna configuración. Sin embargo, si deseas personalizar los presets, reglas o carpetas inspeccionadas, puedes hacerlo creando un archivo `pint.json` en el directorio raíz de tu proyecto:

```json
{
    "preset": "laravel"
}
```

Además, si deseas usar un `pint.json` de un directorio específico, puedes proporcionar la opción `--config` al invocar Pint:

```shell
pint --config vendor/my-company/coding-style/pint.json
```

<a name="presets"></a>
### Presets

Los presets definen un conjunto de reglas que se pueden usar para solucionar problemas de estilo de código en tu código. Por defecto, Pint utiliza el preset `laravel`, que soluciona problemas siguiendo el estilo de codificación opinado de Laravel. Sin embargo, puedes especificar un preset diferente proporcionando la opción `--preset` a Pint:

```shell
pint --preset psr12
```

Si lo deseas, también puedes establecer el preset en el archivo `pint.json` de tu proyecto:

```json
{
    "preset": "psr12"
}
```

Los presets actualmente soportados por Pint son: `laravel`, `per`, `psr12`, `symfony`, y `empty`.

<a name="rules"></a>
### Reglas

Las reglas son pautas de estilo que Pint utilizará para solucionar problemas de estilo de código en tu código. Como se mencionó anteriormente, los presets son grupos predefinidos de reglas que deberían ser perfectos para la mayoría de los proyectos PHP, por lo que normalmente no necesitarás preocuparte por las reglas individuales que contienen.

Sin embargo, si lo deseas, puedes habilitar o deshabilitar reglas específicas en tu archivo `pint.json` o usar el preset `empty` y definir las reglas desde cero:

```json
{
    "preset": "laravel",
    "rules": {
        "simplified_null_return": true,
        "braces": false,
        "new_with_braces": {
            "anonymous_class": false,
            "named_class": false
        }
    }
}
```

Pint está construido sobre [PHP-CS-Fixer](https://github.com/FriendsOfPHP/PHP-CS-Fixer). Por lo tanto, puedes usar cualquiera de sus reglas para solucionar problemas de estilo de código en tu proyecto: [PHP-CS-Fixer Configurator](https://mlocati.github.io/php-cs-fixer-configurator).

<a name="excluding-files-or-folders"></a>
### Excluyendo Archivos / Carpetas

Por defecto, Pint inspeccionará todos los archivos `.php` en tu proyecto, excepto aquellos en el directorio `vendor`. Si deseas excluir más carpetas, puedes hacerlo utilizando la opción de configuración `exclude`:

```json
{
    "exclude": [
        "my-specific/folder"
    ]
}
```

Si deseas excluir todos los archivos que contengan un patrón de nombre dado, puedes hacerlo utilizando la opción de configuración `notName`:

```json
{
    "notName": [
        "*-my-file.php"
    ]
}
```

Si deseas excluir un archivo proporcionando una ruta exacta al archivo, puedes hacerlo utilizando la opción de configuración `notPath`:

```json
{
    "notPath": [
        "path/to/excluded-file.php"
    ]
}
```

<a name="continuous-integration"></a>
## Integración Continua

<a name="running-tests-on-github-actions"></a>
### GitHub Actions

Para automatizar la verificación de tu proyecto con Laravel Pint, puedes configurar [GitHub Actions](https://github.com/features/actions) para ejecutar Pint cada vez que se envíe nuevo código a GitHub. Primero, asegúrate de otorgar "Permisos de lectura y escritura" a los flujos de trabajo dentro de GitHub en **Configuración > Acciones > General > Permisos del flujo de trabajo**. Luego, crea un archivo `.github/workflows/lint.yml` con el siguiente contenido:

```yaml
name: Fix Code Style

on: [push]

jobs:
  lint:
    runs-on: ubuntu-latest
    strategy:
      fail-fast: true
      matrix:
        php: [8.3]

    steps:
      - name: Checkout code
        uses: actions/checkout@v4

      - name: Setup PHP
        uses: shivammathur/setup-php@v2
        with:
          php-version: ${{ matrix.php }}
          extensions: json, dom, curl, libxml, mbstring
          coverage: none

      - name: Install Pint
        run: composer global require laravel/pint

      - name: Run Pint
        run: pint

      - name: Commit linted files
        uses: stefanzweifel/git-auto-commit-action@v5
        with:
          commit_message: "Fixes coding style"
```
