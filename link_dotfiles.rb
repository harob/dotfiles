#!/usr/bin/env ruby

DOTDIR = "dotfiles"

Dir.chdir File::expand_path("~")
Dir.foreach(DOTDIR) do |file|
  if file =~ /^\.[a-z]+/ && file != ".git"
    if File.directory? file
      # TODO(harry) Recursively create directories and symlinks, eg for .lein/profiles.clj
    else
      `rm #{file}`
      `ln -Fs #{DOTDIR}/#{file} #{file}`
      puts "#{file} => #{DOTDIR}/#{file}"
    end
  end
end

# TODO(harry) Hack for current nested files:
`rm .lein/profiles.clj`
`ln -Fs ../#{DOTDIR}/.lein/profiles.clj .lein/profiles.clj`

`rm Library/KeyBindings/DefaultKeyBinding.dict`
`cp dotfiles/DefaultKeyBinding.dict Library/KeyBindings/`
