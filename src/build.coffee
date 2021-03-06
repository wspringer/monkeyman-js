path = require 'path'
mkdirp = require 'mkdirp'
markdown = require 'metalsmith-markdown'
frontmatter = require 'metalsmith-matters'
layouts = require 'metalsmith-layouts'
watch = require 'metalsmith-watch'
_ = require 'lodash'
appRoot = path.resolve(__dirname, '..')
git = require 'git-rev-sync'
moment = require 'moment'



module.exports = ->
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
      .option 'v',
        alias: 'verbose'
        type: 'boolean'
        describe: 'Print verbose debugging output'
      .coerce ['src', 'dst'], path.resolve
    ), (argv) -> 
      metalsmith = require 'metalsmith'
      mkdirp argv.dst
      base = 
        metalsmith(appRoot)
        .metadata(
          revision: git.short(argv.src)
          date: moment().format('MMMM Do YYYY')
          dirty: git.date(argv.src)
        )
        .source(argv.src)
        .destination(argv.dst)
        .frontmatter(false)
        .use frontmatter(
          namespace: 'page'
        )
        .use (files, metalsmith, callback) ->
          if argv.verbose then console.info files
          callback()
        .use markdown(
          smartypants: true
          gfm: true
        )
        .use layouts(
          pattern: '**/*.html'
          default: 'layout.pug'
          directory: path.resolve(appRoot, 'layout')
        )
        .use(require('metalsmith-sense-sass')())
      if argv.watch 
        base.use watch(
          paths: 
            '${source}/**/*': true
            "#{appRoot}/layout/*": '**/*'
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
