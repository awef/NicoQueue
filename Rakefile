SRC = "src"
BUILD = "build"

p_cp = proc do |t|
  sh "cp #{t.prerequisites[0]} #{t.name}"
end

p_coffee = proc do |t|
  sh "cat #{t.prerequisites.join(" ")} | coffee -cbsp > #{t.name}"
end

rule ".png" => "#{SRC}/%{_\\d+x\\d+$,}n.svg" do |t|
  /_(\d+)x(\d+)\.png$/ =~ t.name
  sh "convert\
    -background transparent\
    -resize #{$1}x#{$2}\
    #{t.prerequisites[0]} #{t.name}"
end

task :default => [
  BUILD,
  "#{BUILD}/manifest.json",
  "#{BUILD}/background.html",
  "#{BUILD}/script.js",
  "#{BUILD}/icon_16x16.png",
  "#{BUILD}/icon_19x19.png",
  "#{BUILD}/icon_48x48.png",
  "#{BUILD}/icon_128x128.png",
  "#{BUILD}/qunit.js",
  "#{BUILD}/qunit.css",
  "#{BUILD}/test.html",
  "#{BUILD}/test.js"
]

task :clean do
  sh "rm -rf #{BUILD}"
end

directory BUILD
file "#{BUILD}/manifest.json" => "#{SRC}/manifest.json", &p_cp
file "#{BUILD}/background.html" => "#{SRC}/background.html", &p_cp
file "#{BUILD}/script.js" => "#{SRC}/script.coffee", &p_coffee
file "#{BUILD}/qunit.js" => "#{SRC}/qunit.js", &p_cp
file "#{BUILD}/qunit.css" => "#{SRC}/qunit.css", &p_cp
file "#{BUILD}/test.html" => "#{SRC}/test.html", &p_cp
file "#{BUILD}/test.js" => "#{SRC}/test.coffee", &p_coffee

