desc "Run Unit Test"
task :test do 
  sh "mocha -r \"coffee-script\" -R spec -G -c test/*.coffee"
end

namespace :dev do

  desc "Run Unit Test in watch mode"
  task :test do
    sh "mocha -r \"coffee-script\" -R spec -G -w -c test/*.coffee"
  end

end