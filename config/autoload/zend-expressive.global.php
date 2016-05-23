<?php

use function Pawon\env;

return [
    'debug' => env('APP_DEBUG', false),

    'config_cache_enabled' => false,
    /**
     * Application timezone and locale, here we can configure our app timezone
     */
    'timezone' => 'Asia/Jakarta',
    'locale' => 'id',
    'fallback_locale' => 'en',
    'lang_dir' => realpath('resources/lang'),
    /**
     * Encryption Key set to random string with length 32 char
     */
    'key' => env('APP_KEY'),

    'cipher' => 'AES-256-CBC',

    'zend-expressive' => [
        'error_handler' => [
            'template_404'   => 'error::404',
            'template_error' => 'error::error',
        ],
    ],

    'cache' => [
        'default' => env('CACHE_DRIVER', 'database'),
        'prefix' => '',
        'stores' => [
            'database' => [
                'driver' => 'database',
                'table'  => 'cache',
                'connection' => null,
            ],
            'memcached' => [
                'driver'  => 'memcached',
                'servers' => [
                    [
                        'host' => '127.0.0.1', 'port' => 11211, 'weight' => 100,
                    ],
                ],
            ],
        ],
    ],

    'commands' => [
        'Pawon\Database\Console\Commands\InstallCommand',
        'Pawon\Database\Console\Commands\MakeMigration',
        'Pawon\Database\Console\Commands\Migrate',
        'Pawon\Queue\Console\Commands\FailedTable',
        'Pawon\Queue\Console\Commands\JobTable',
        'Pawon\Queue\Console\Commands\Listen'
    ]
];
