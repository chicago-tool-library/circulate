const { environment } = require('@rails/webpacker')

const { CleanWebpackPlugin } = require("clean-webpack-plugin");
environment.plugins.prepend("CleanWebpackPlugin", new CleanWebpackPlugin());

module.exports = environment
