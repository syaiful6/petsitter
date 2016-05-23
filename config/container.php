<?php

use Zend\ServiceManager\Config;
use Zend\ServiceManager\ServiceManager;
use Pawon\Core\ServiceManagerProxy;
// Load configuration
$config = require __DIR__ . '/config.php';
//file_put_contents(__DIR__.'/test.res', var_export($config['dependencies'], true));
// Build container
$container = new ServiceManager();
(new Config($config['dependencies']))->configureServiceManager($container);

// Inject config
$container->setService('config', $config);

// we proxy the container
$container = new ServiceManagerProxy($container);
return $container;
