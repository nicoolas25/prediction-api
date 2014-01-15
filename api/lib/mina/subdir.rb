# encoding: utf-8

#
# This extension allows you to select a subdirectory instead of a whole repository.
# It is useful when you're fetching a git project and your actual code is in a
# subdirectory.
#

namespace :subdir do
  desc "Select a subdirectory as the root of your project"
  task :select do
    commands = %[
      echo "-----> Using '#{subdirectory!}' as subdirectory" &&
      if [ ! -d "#{subdirectory!}" ]; then
        echo "-----> The directory #{deploy_to}/$build_path/#{subdirectory!} hasn't been found." &&
        exit 1
      else
        #{echo_cmd %[mv #{subdirectory!} #{deploy_to}/tmp/subdirectory]} &&
        #{echo_cmd %[rm -fr ./*]} &&
        #{echo_cmd %[mv #{deploy_to}/tmp/subdirectory/* ./]} &&
        #{echo_cmd %[rmdir #{deploy_to}/tmp/subdirectory]}
      fi
    ]

    queue commands
  end
end
