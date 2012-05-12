desc "Run Unit Test"
task :test do 
  sh "mocha -r \"coffee-script\" -R spec -G -c test/*.coffee"
end
 
desc "Start development environment"
task :dev => ["dev:mate", "dev:test"] do
end

namespace :dev do
  desc "Run Unit Test in watch mode"
  task :test do
    sh "mocha -r \"coffee-script\" -R spec -G -w -c test/*.coffee"
  end
  
  desc "Open project in TextMate"
  task :mate do
    sh "mate ."
  end
end

namespace :build do
  desc "Build Javscript verison lib"
  task :js do
    sh "coffee -c -o jsLib/ lib"
  end 
end

