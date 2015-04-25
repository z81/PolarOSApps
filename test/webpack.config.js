var path = require('path');
var webpack = require('webpack');

var config = {
    context: path.join(__dirname, 'src'),
    entry: {
        index: ['./index.js', "mithril"],
    },
    output: {
        path: path.join(__dirname, 'public'),
        filename: '[name].js'
    },
    plugins: [
    ],
    module: {
        loaders: [
        	{test: /\.jade$/, loader: "jade-loader" },
            {test: /\.css$/, loader: 'style-loader!css-loader'},
            {test: /\.jsx$/, loader: 'es6-loader!msx-loader'},
            {test: /\.js$/,  loader: 'es6-loader!msx-loader'},
            {test: /\.less$/,loader: "style-loader!css-loader!less-loader?strictMath&cleancss"},
            {
                test: /\.(eot|woff|ttf|svg|png|jpg|gif|woff|woff2)$/,
                loader: 'url-loader?limit=30000&name=[name]-[hash].[ext]'
            },
        ]
    }

};

module.exports = config;