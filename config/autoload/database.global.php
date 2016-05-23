<?php

use function Pawon\env;

use Pawon\Database;

return [
    'dependencies' => [
        'invokables' => [
            'Pawon\Database\MigrationCreator' => 'Pawon\Database\MigrationCreator',
            'Illuminate\Contracts\Queue\EntityResolver' =>
                'Illuminate\Database\Eloquent\QueueEntityResolver'
        ],

        'factories' => [
            Illuminate\Database\ConnectionResolverInterface::class =>
                Database\ConnectionResolverFactory::class,
            Illuminate\Database\ConnectionInterface::class =>
                Database\ConnectionResolverFactory::class,
            'Illuminate\Database\Migrations\MigrationRepositoryInterface' =>
                'Pawon\Database\DatabaseMigrationRepositoryFactory',
            'Pawon\Database\Migrator' => 'Pawon\Database\MigratorFactory',
            'Pawon\Database\Console\Commands\InstallCommand' =>
                'Pawon\Database\Console\ConsoleFactory',
            'Pawon\Database\Console\Commands\MakeMigration' =>
                'Pawon\Database\Console\ConsoleFactory',
            'Pawon\Database\Console\Commands\Migrate' =>
                'Pawon\Database\Console\ConsoleFactory',
        ]
    ],

    'database' => [

        'fetch' => PDO::FETCH_CLASS,

        'default' => 'sqlite',

        'migrations' => 'migrations',

        'connections' => [

            'sqlite' => [
                'driver' => 'sqlite',
                'database' => realpath('database/skellie.db'),
                'prefix' => '',
            ],

            'mysql' => [
                'driver' => 'mysql',
                'host'   => env('DB_HOST', 'localhost'),
                'port'   => env('DB_PORT', '3306'),
                'database' => env('DB_DATABASE', 'forge'),
                'username' => env('DB_USERNAME', 'forge'),
                'password' => env('DB_PASSWORD', ''),
                'prefix' => '',
                'strict' => false,
                'engine' => null,
            ],

            'pgsql' => [
                'driver' => 'pgsql',
                'host' => env('DB_HOST', 'localhost'),
                'port' => env('DB_PORT', '3306'),
                'database' => env('DB_DATABASE', 'forge'),
                'username' => env('DB_USERNAME', 'forge'),
                'password' => env('DB_PASSWORD', ''),
                'charset' => 'utf8',
                'prefix' => '',
                'schema' => 'public',
            ],

        ],
    ]
];
