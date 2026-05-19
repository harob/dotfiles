#!/usr/bin/env ruby

DOTDIR = "dotfiles"

def sh(cmd); system(cmd, exception: true); end

Dir.chdir File::expand_path("~")
Dir.foreach(DOTDIR) do |file|
  next unless (file =~ /^\.[a-z]+/ && file != ".git" && file != ".claude")
  if File.directory? "#{DOTDIR}/#{file}"
    dir = file
    unless File.symlink? "#{DOTDIR}/#{dir}"
      sh "mkdir -p #{dir}"
      Dir.foreach("#{DOTDIR}/#{dir}") do |nested_file|
        next if nested_file == "." || nested_file == ".."
        cmd = (nested_file =~ /\.pdf$/) ? "cp" : "ln -Fs"
        sh "#{cmd} ~/#{DOTDIR}/#{dir}/#{nested_file} #{dir}/#{nested_file}"
        puts "#{dir}/#{nested_file} => #{DOTDIR}/#{nested_file}/#{file}"
      end
    end
  else
    sh "ln -Fs #{DOTDIR}/#{file} #{file}"
    puts "#{file} => #{DOTDIR}/#{file}"
  end
end

sh "cp #{DOTDIR}/karabiner.json .config/karabiner/"
sh "ln -Fs ~/#{DOTDIR}/karabiner.edn .config/karabiner.edn"
if system("command -v goku >/dev/null 2>&1")
  sh "goku"
else
  warn "WARNING: goku not found on PATH; karabiner.edn was linked but not applied. Install with `brew install yqrashawn/goku/goku`."
end

sh "mkdir -p .config/ghostty"
sh "ln -Fs ~/#{DOTDIR}/ghostty-config .config/ghostty/config"

sh "mkdir -p .config/enchant"
sh "ln -Fs ~/Dropbox/config/enchant/en_US.dic ~/.config/enchant/"

sh "mkdir -p .config/direnv"
sh "ln -Fs ~/#{DOTDIR}/direnv.toml .config/direnv/direnv.toml"

sh "cp #{DOTDIR}/harry.gitnote.plist Library/LaunchAgents/harry.gitnote.plist"
sh "launchctl unload Library/LaunchAgents/harry.gitnote.plist || true"
sh "launchctl load Library/LaunchAgents/harry.gitnote.plist"
