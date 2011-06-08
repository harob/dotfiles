#!/usr/bin/env ruby

DOTDIR = "dotfiles"

Dir.chdir File::expand_path("~")
Dir.foreach(DOTDIR) do |file|
  if file =~ /^\.[a-z]+/ && file != ".git"
    `rm #{file}`
    `ln -Fs #{DOTDIR}/#{file} #{file}`
    puts "#{file} => #{DOTDIR}/#{file}"
  end
end
