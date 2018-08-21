let baseConfig = {};
let config = {};
let loader = {};

const path = require('path');
const webpack = require('webpack');
const merge = require('webpack-merge');
const HtmlWebpackPlugin = require('html-webpack-plugin');
const CleanWebpackPlugin = require('clean-webpack-plugin');
const ExtractTextPlugin = require('extract-text-webpack-plugin');

loader.css = [
  {
    loader: 'style-loader',
    options: {
      sourceMap: true
    }
  },
  {
    loader: 'css-loader',
    options: {
      sourceMap: false
    }
  }
];

baseConfig = {
  entry: './src/main.js',
  output: {
    path: path.resolve(__dirname, './public'),
    publicPath: '/'
  },
  module: {
    rules: [
      {
        test: /\.vue$/,
        use: {
          loader: 'vue-loader',
          options: {
            loaders: {
              coffee: loader.coffee,
              stylus: loader.stylus
            }
          }
        }
      },
      {
        test: /\.(png|jpg|gif|svg)$/,
        use: [
          {
            loader: 'file-loader',
            options: {
              name: '[name].[ext]?[hash]'
            }
          }
        ]
      },
      {
        test: /\.(png|woff|woff2|eot|ttf|svg)$/,
        loader: 'url-loader?limit=100000'
      },
      {
        test: /\.css$/,
        use: loader.css
      },
      {
        test: /\.(scss)$/,
        use: [{
          loader: 'style-loader', // inject CSS to page
        }, {
          loader: 'css-loader', // translates CSS into CommonJS modules
        }, {
          loader: 'postcss-loader', // Run post css actions
          options: {
            plugins: function () { // post css plugins, can be exported to postcss.config.js
              return [
                require('precss'),
                require('autoprefixer')
              ];
            }
          }
        }, {
          loader: 'sass-loader' // compiles SASS to CSS
        }]
      },
      {
        test: /\.js$/,
        exclude: /node_modules/,
        loader: 'babel-loader'
      }
    ]
  },
  resolve: {
    alias: {
      '@src': path.resolve(__dirname, 'src'),
      '@components': path.resolve(__dirname, 'src', 'components'),
      '@pages': path.resolve(__dirname, 'src', 'pages'),
      '@assets': path.resolve(__dirname, 'src', 'assets'),
      '@styles': path.resolve(__dirname, 'src', 'styles'),
      '@images': path.resolve(__dirname, 'src', 'images'),
      'vue$': 'vue/dist/vue.esm.js',      
    }
  },
  plugins: [
    new HtmlWebpackPlugin({
      filename: 'app.html',
      favicon: 'src/favicon.ico',
      template: path.resolve(__dirname, 'src', 'app_template.html')
    }),
    new HtmlWebpackPlugin({
      filename: 'index.html',
      favicon: 'src/favicon.ico',
      template: path.resolve(__dirname, 'src', 'login_template.html')
    }),
    new webpack.DefinePlugin({
      'process.env': {
        NODE_ENV: `'${process.env.NODE_ENV}'`
      }
    }),
    new webpack.ProvidePlugin({
      '_': 'lodash',
      'axios': 'axios'
    })
  ]
};

if (process.env.NODE_ENV === 'production') {
  config = merge(baseConfig, {
    output: {
      filename: 'build-[hash].js'
    },
    devtool: '#source-map',
    plugins: [
      new CleanWebpackPlugin(['public']),
      new webpack.LoaderOptionsPlugin({
        minimize: true
      })
    ]
  });
} else {
  config = merge(baseConfig, {
    output: {
      filename: 'build.js'
    },
    devtool: '#eval-source-map',
    devServer: {
      contentBase: 'public',
      historyApiFallback: true,
      // noInfo: true,
      // port: 8080,
      inline: true,
      proxy: {
        "/": {
          target: 'http://localhost:9292',
          changeOrigin: true
        }
      }
    },
    performance: {
      hints: false
    }
  });
}

module.exports = config;
