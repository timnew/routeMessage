desc "Run Unit Test"
task :test do 
  sh "mocha -r \"coffee-script\" -R spec -G -c test/*.coffee"
end
 
desc "Start development environment"
task :dev => ["dev:mate", "dev:test"] do
end

desc "Start development environment"
task :dev => ["dev:mate", "dev:test"] do
end

namespace :build do
  desc "Build Javscript verison lib"
  task :js do
    sh "coffee -c -o jsLib/ lib"
  end 
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

namespace :new do
  desc "Create a new mocha BDD testcase"
  task :test, :name do |n, args|
    mkdir_p "test"
    args.with_defaults(:name => 'new')
    className = args.name
    filename = "test/#{className}Facts.coffee"
    puts "Creating new test case #{filename}..."
    if File.exist?(filename)
      abort("Test Case is already existed!") if ask("#{filename} already exists. Do you want to overwrite?", ['y', 'n']) == 'n'
    end
    open(filename, 'w') do |file|
      file.puts "require 'coffee-script'"
      file.puts "require('chai').should()"
      file.puts ""
      file.puts "describe \"#{className}\", ->"
      file.puts "	#{className} = require '../lib/#{className}.coffee'"
    end
  end
  
  desc "Create a new class"
  task :class, [:name] => ["new:test"] do |n, args|
    mkdir_p "lib"
    args.with_defaults(:name => 'new')
    className = args.name
    filename = "lib/#{className}.coffee"
    puts "Creating new class #{filename}..."
    if File.exist?(filename)
      abort("Source file is already existed!") if ask("#{filename} already exists. Do you want to overwrite?", ['y', 'n']) == 'n'
    end
    open(filename, 'w') do |file|
      file.puts "require 'coffee-script'"
      file.puts ""
      file.puts "class #{className}"
      file.puts ""
      file.puts ""
      file.puts "exports = module.exports = #{className}"
    end
  end
end

def ok_failed(condition)
  if (condition)
    puts "OK"
  else
    puts "FAILED"
  end
end

def get_stdin(message)
  print message
  STDIN.gets.chomp
end

def ask(message, valid_options)
  if valid_options
    answer = get_stdin("#{message} #{valid_options.to_s.gsub(/"/, '').gsub(/, /,'/')} ") while !valid_options.include?(answer)
  else
    answer = get_stdin(message)
  end
  answer
end
