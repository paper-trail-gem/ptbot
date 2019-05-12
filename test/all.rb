# A simple replacement for Rake::TestTask. Assumes that the `test` direcrotry
# is already on the LOAD_PATH.
Dir.glob('test/**/*_test.rb').each do |file|
  require File.join(*file.split(File::SEPARATOR).drop(1))
end
