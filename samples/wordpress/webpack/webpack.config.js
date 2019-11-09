'use strict';

const webpack = require('webpack');
const autoprefixer = require('autoprefixer');
const AssetsPlugin = require('assets-webpack-plugin');
const BrowserSyncPlugin = require('browser-sync-webpack-plugin');
const MiniCssExtractPlugin = require("mini-css-extract-plugin");
const CleanWebpackPlugin = require('clean-webpack-plugin');
const TerserPlugin = require('terser-webpack-plugin');
const FriendlyErrorsPlugin = require('friendly-errors-webpack-plugin');
const OptimizeCSSAssetsPlugin = require("optimize-css-assets-webpack-plugin");
const path = require('path');
const fs = require('fs');

// Make sure any symlinks in the project folder are resolved:
// https://github.com/facebookincubator/create-react-app/issues/637
const appDirectory = fs.realpathSync(process.cwd());

function resolveApp(relativePath) {
  return path.resolve(appDirectory, relativePath);
}

const paths = [
  'theme',
  'plugin'
];


// /**
//  * Theme assets
//  */
// add_action('wp_enqueue_scripts', function () {
// 	$manifest = json_decode(file_get_contents('_build/assets.json', true));
// 	$main = $manifest->main;
// 	wp_enqueue_style('theme-css', get_template_directory_uri() . "/_build/" . $main->css,  false, null);
// 	wp_enqueue_script('theme-js', get_template_directory_uri() . "/_build/" . $main->js, [], null, true);
// }, 10);


// /**
//  * Plugin assets
//  */
// add_action('wp_enqueue_scripts', function () {
// 	$manifest = json_decode(file_get_contents('_build/assets.json', true));
// 	$main = $manifest->main;
// 	wp_enqueue_style('plugin-css', plugin_dir_url( __FILE__ ) . "_build/" . $main->css,  false, null);
// 	wp_enqueue_script('plugin-js', plugin_dir_url( __FILE__ ) . "_build/" . $main->js, [], null, true);
// }, 100);


const DEV = process.env.NODE_ENV === 'development';

const config = {
  bail: !DEV,
  mode: DEV ? 'development' : 'production',
  // We generate sourcemaps in production. This is slow but gives good results.
  // You can exclude the *.map files from the build during deployment.
  target: 'web',
  devtool: DEV ? 'cheap-eval-source-map' : 'source-map',
  output: {
    filename: DEV ? 'bundle.js' : 'bundle.[hash:8].js'
  },
  module: {
    rules: [
      // Transform ES6 with Babel
      {
        test: /\.js?$/,
        loader: 'babel-loader',
      },
      {
        test: /.scss$/,
        use: [
          MiniCssExtractPlugin.loader,
          {
            loader: "css-loader",
          },
          {
            loader: "postcss-loader",
            options: {
              ident: "postcss", // https://webpack.js.org/guides/migrating/#complex-options
              plugins: () => [
                autoprefixer({
                  overrideBrowserslist: [
                    ">1%",
                    "last 4 versions",
                    "Firefox ESR",
                    "not ie < 9" // React doesn't support IE8 anyway
                  ]
                })
              ]
            }
          },
          "sass-loader"
          ],
        },
      // Disable require.ensure as it's not a standard language feature.
      { parser: { requireEnsure: false } },
    ],
  },
  optimization: {
    minimize: !DEV,
    minimizer: [
      new OptimizeCSSAssetsPlugin({
        cssProcessorOptions: {
          map: {
            inline: false,
            annotation: true,
          }
        }
      }),
      new TerserPlugin({
        terserOptions: {
          compress: {
            warnings: false
          },
          output: {
            comments: false
          }
        },
        sourceMap: true
      })
    ]
  },
  plugins: [
    new MiniCssExtractPlugin({
      filename: DEV ? 'bundle.css' : 'bundle.[hash:8].css'
    }),
    new webpack.EnvironmentPlugin({
      NODE_ENV: 'development', // use 'development' unless process.env.NODE_ENV is defined
      DEBUG: false,
    }),
    DEV &&
      new FriendlyErrorsPlugin({
        clearConsole: false,
      }),
    DEV &&
      new BrowserSyncPlugin({
        notify: false,
        host: 'localhost',
        port: 3000,
        logLevel: 'silent',
        files: ['./*.php'],
        proxy: 'http://localhost:8000/',
      }),
  ].filter(Boolean),
};


const pathConfigs = paths.map(path => {
  const paths = {
    src: resolveApp(`${path}/assets`),
    build: resolveApp(`${path}/_build`),
    indexJs: resolveApp(`${path}/assets/index.js`),
    nodeModules: resolveApp('node_modules'),
  };

  const pathConfig = Object.assign({}, config, {
    name: path,
    entry: [paths.indexJs],
  });

  pathConfig.output = Object.assign({}, pathConfig.output, {
    path: paths.build
  });

  pathConfig.module.rules[0] = Object.assign({}, pathConfig.module.rules[0], {
    include: paths.src
  })

  pathConfig.plugins = [
    new AssetsPlugin({
      path: paths.build,
      filename: 'assets.json',
    }),
    new CleanWebpackPlugin(['_build'], {
      root: process.cwd() + `/${path}`
    }),
    ...pathConfig.plugins,
  ].filter(Boolean)

  return pathConfig
})


module.exports = pathConfigs
