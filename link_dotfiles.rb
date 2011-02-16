#!/usr/bin/env ruby

DOTDIR = "dotfiles"
Dir.chdir(File::expand_path("~"))
Dir.foreach(DOTDIR) do |file|
  if file.match(/(\.[a-z]+)/) && file != ".git"
    system("rm #{file}")
    system("ln -Fs #{DOTDIR}/#{file} #{file}")
    puts "#{file} => #{DOTDIR}/#{file}"
  end
end
