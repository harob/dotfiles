#!/usr/bin/env ruby

DOTDIR = "dotfiles"

Dir.chdir File::expand_path("~")
Dir.foreach(DOTDIR) do |file|
  next unless file =~ /^\.[a-z]+/ && file != ".git"
  if File.directory? "#{DOTDIR}/#{file}"
    dir = file
    unless File.symlink? "#{DOTDIR}/#{dir}"
      `mkdir -p #{dir}`
      Dir.foreach("#{DOTDIR}/#{dir}") do |nested_file|
        next if nested_file == "." || nested_file == ".."
        `rm #{dir}/#{nested_file}`
        cmd = (nested_file =~ /\.pdf$/) ? "cp" : "ln -Fs"
        `#{cmd} ~/#{DOTDIR}/#{dir}/#{nested_file} #{dir}/#{nested_file}`
        puts "#{dir}/#{nested_file} => #{DOTDIR}/#{nested_file}/#{file}"
      end
    end
  else
    `rm #{file}`
    `ln -Fs #{DOTDIR}/#{file} #{file}`
    puts "#{file} => #{DOTDIR}/#{file}"
  end
end

`rm Library/KeyBindings/DefaultKeyBinding.dict`
`cp dotfiles/DefaultKeyBinding.dict Library/KeyBindings/`
