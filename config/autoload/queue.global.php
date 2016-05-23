<?php

use function Pawon\env;

return [
    'dependencies' => [
        'factories' => [
            'Illuminate\Contracts\Queue\Factory' => 'Pawon\Queue\QueueServiceFactory',
            'Illuminate\Contracts\Queue\Queue' => 'Pawon\Queue\QueueServiceFactory',
            'Pawon\Queue\Failed\FailedJobProviderInterface' => 'Pawon\Queue\QueueServiceFactory',
            'Pawon\Queue\Processor\Listener' => 'Pawon\Queue\QueueServiceFactory'
        ]
    ],
    'queue' => [
        'default' => env('QUEUE_DRIVER', 'database'),
        'connections' => [

            'sync' => [
                'driver' => 'sync',
            ],

            'database' => [
                'driver' => 'database',
                'table' => 'jobs',
                'queue' => 'default',
                'expire' => 60,
            ],

            'beanstalkd' => [
                'driver' => 'beanstalkd',
                'host' => 'localhost',
                'queue' => 'default',
                'ttr' => 60,
            ],
        ],

        'failed' => [
            'database' => env('DB_CONNECTION', 'mysql'),
            'table' => 'failed_jobs',
        ],
    ],
];
