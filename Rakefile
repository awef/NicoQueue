task :default => [
  "build",
  "build/manifest.json",
  "build/script.js",
  "build/icon_16x16.png",
  "build/icon_19x19.png",
  "build/icon_48x48.png",
  "build/icon_128x128.png",
  "build/qunit.js",
  "build/qunit.css",
  "build/test.html",
  "build/test.js"
]

task :clean do
  sh "rm -rf build"
end

task :test do
  sh "google-chrome chrome-extension://#{debug_id}/test.html"
end

def debug_id
  require "digest"
  hash = Digest::SHA256.hexdigest(File.absolute_path("build"))
  hash[0...32].tr("0-9a-f", "a-p")
end

def coffee(src, output)
  if src.is_a? Array
    src = src.join(" ")
  end

  sh "coffee -cbj #{output} #{src}"
end

def file_copy(target, src)
  file target => src do
    sh "cp #{src} #{target}"
  end
end

rule ".js" => "%{^build/,src/}X.coffee" do |t|
  coffee(t.prerequisites, t.name)
end

rule ".png" => "src/%{_\\d+x\\d+$,}n.svg" do |t|
  /_(\d+)x(\d+)\.png$/ =~ t.name
  sh "convert\
    -background transparent\
    -resize #{$1}x#{$2}\
    #{t.prerequisites[0]} #{t.name}"
end

directory "build"
file_copy "build/manifest.json", "src/manifest.json"
file_copy "build/qunit.js", "lib/qunit/qunit/qunit.js"
file_copy "build/qunit.css", "lib/qunit/qunit/qunit.css"
file_copy "build/test.html", "src/test.html"
