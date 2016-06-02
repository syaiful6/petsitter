var pickFiles   = require('broccoli-funnel'),
  compileLess = require('broccoli-less-single'),
  mergeTrees  = require('broccoli-merge-trees'),
  babel = require('broccoli-babel-transpiler'),
  es6Modules = require('broccoli-es6modules'),
  uglifyJavaScript = require('broccoli-uglify-js'),
  es3SafeRecast   = require('broccoli-es3-safe-recast'),
  stew            = require('broccoli-stew'),
  findBowerTrees = require('broccoli-bower'),
  env = require('broccoli-env').getEnv(),
  concat = require('broccoli-sourcemap-concat'),
  myth = require('broccoli-myth'),
  path = require('path'),
  escapeChar     = process.platform.match(/^win/) ? '^' : '\\',
  cwd            = process.cwd().replace(/( |\(|\))/g, escapeChar + '$1'),
  extension = env === 'production' ? '.min.js' : '.js';

/**
* our babel options for compiling es6 to es5, that's how javascript developer think
* they write on another language, then compile it to javascript!
*/
var babelOptions = {
  sourceMaps: false,
  modules: 'amdStrict',
  moduleIds: true,
  externalHelpers: true,
  resolveModuleSource: moduleResolve
};

// used by compiler, dunno why this should be written here
function moduleResolve(child, name) {
  if (child.charAt(0) !== '.') { return child; }

  var parts = child.split('/');
  var nameParts = name.split('/');
  var parentBase = nameParts.slice(0, -1);

  for (var i = 0, l = parts.length; i < l; i++) {
    var part = parts[i];

    if (part === '..') {
      if (parentBase.length === 0) {
        throw new Error('Cannot access parent module of root');
      }
      parentBase.pop();
    } else if (part === '.') {

      continue;
    } else { parentBase.push(part); }
  }

  return parentBase.join('/');
}

function merge(original) {
  return function (updates) {
    if (!updates || typeof updates !== 'object') {
      return original;
    }
    var props = Object.keys(updates);
    var prop;
    var length = props.length;

    for (var i = 0; i < length; i++) {
      prop = props[i];
      original[prop] = updates[prop];
    }

    return original;
  };
}

var mergeBabelOption = merge(babelOptions);

var app = pickFiles('resources/static', {
  srcDir:  '/',
  destDir: '/'
});

var less = compileLess(app, 'less/app.less', 'css/app.css', {
  paths: ['.', 'node_modules/bootstrap-less/bootstrap']
});

var jsApp = babel(pickFiles('resources/static/js/app', {
  srcDir: '/',
  destDir: 'petsitter'
}), mergeBabelOption({jsxPragma: 'm', optional: ['es7.decorators']}));

jsApp = es3SafeRecast(jsApp);

var specs = babel(pickFiles('resources/static/js/specs', {
  src: '/',
  destDir: 'petsitter/specs'
}), babelOptions);

var vendor = pickFiles('resources/static/js/libs', {
  src: '/',
  destDir: 'libs'
});

var sourceTree = [jsApp, vendor];

if (env !== 'production') {
  sourceTree.push(specs);
}

sourceTree = mergeTrees(sourceTree);

var appJs = concat(sourceTree, {
  inputFiles: ['petsitter/**/*.js'],
  outputFile: 'petsitter.js',
  sourceMapConfig: { enabled: env !== 'production' },
  headerFiles: ['libs/shim.js']
});

if (env === 'production') {
  // minify js
  appJs = uglifyJavaScript(appJs, {
    // mangle: false,
    // compress: false
  })
}

var bower = 'bower_components';
bower = pickFiles(bower, {
  srcDir: '/',
  destDir: 'bower'
});

var babelPath = require.resolve('broccoli-babel-transpiler');
babelPath = babelPath.split(path.sep);
babelPath.pop();
babelPath = babelPath.join('/')
babelPath +='/node_modules/babel-core';

var browserPolyfill = pickFiles(babelPath, {
  files: ['browser-polyfill.js', 'external-helpers.js']
});

var vendorTree = mergeTrees([browserPolyfill, bower]);

var vendorTree = concat(vendorTree, {
  inputFiles: [
    'external-helpers.js',
    'browser-polyfill.js',
    'bower/loader.js/loader.js',
    'bower/mithril/mithril' + extension
  ],
  sourceMapConfig: { enabled: env !== 'production' },
  outputFile: 'vendor.js'
});

if (env === 'production') {
  vendorTree = uglifyJavaScript(vendorTree, {

  });
}

module.exports = mergeTrees([less, appJs, vendorTree]);
