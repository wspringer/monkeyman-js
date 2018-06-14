path = require 'path'
mkdirp = require 'mkdirp'
markdown = require 'metalsmith-markdown'
frontmatter = require 'metalsmith-matters'
layouts = require 'metalsmith-layouts'
watch = require 'metalsmith-watch'
_ = require 'lodash'

require('yargs')
  .usage '$0 <src> <dst>', 'Produces documentation from a directory of files', ((yargs) ->
    yargs
    .positional 'src',
      describe: 'Source directory'      
    .positional 'dst',
      describe: 'Destination directory'
    .option 'w',
      alias: 'watch'
      type: 'boolean'
      describe: 'Watch the source directory for changes'
    .option 's',
      alias: 'serve'
      type: 'boolean'
      describe: 'Start a server'
    .coerce ['src', 'dst'], path.resolve
  ), (argv) -> 
    metalsmith = require 'metalsmith'
    mkdirp argv.dst
    base = 
      metalsmith(__dirname)
      .source(argv.src)
      .destination(argv.dst)
      .frontmatter(false)
      .use frontmatter(
        namespace: 'page'
      )
      .use (files, metalsmith, callback) ->
        console.info files
        callback()
      .use markdown(
        smartypants: true
        gfm: true
      )
      .use layouts(
        default: 'layout.pug'
        directory: path.resolve(__dirname, 'layout')
      )
      .use(require('metalsmith-sense-sass')())
    if argv.watch 
      base.use watch(
        paths: 
          '${source}/**/*': true
          "#{__dirname}/layout/*": '**/*'
        livereload: true
      )          
    if argv.serve 
      base.use require('metalsmith-serve')(
        port: 8081
      )
    base.build (err) ->
      if err? then console.error err

  .help()
  .argv


# metalsmith = require 'metalsmith'
# serve = require 'metalsmith-serve'
# watch = require 'metalsmith-watch'
# pug = require 'metalsmith-pug'
# joi = require 'joi'

# schema = Joi.object(
#   in: Joi.string().description('The name of the ')
# )

# module.exports = () ->
#   metalsmith()
#   .source(dir)