#!/usr/bin/env ruby

# This is the command to use:
# composite -gravity center icons/badge_visionary.png background/badge_lvl1.png  result.png

bg_images = Dir['background/*.png']
fg_images = Dir['icons/*.png']

cmds = []
bg_images.each_with_index do |bg_image, level|
  bg_name = File.basename(bg_image)
  cmds << "composite -gravity center badge_flare.png #{bg_image} tmp/#{bg_name}"

  fg_images.each do |fg_image|
    File.basename(fg_image) =~ /^(.*)\.png$/
    target = "results/#{$1}_lvl#{level}.png"
    cmds << "composite -gravity center #{fg_image} tmp/#{bg_name} #{target}"
  end
end

exec(cmds.join(" && "))
