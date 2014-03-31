require 'octokit'
 
USER='NeuronRobotics'
PROJECT=ENV["GH_PROJECT"]
VERSION=ENV["VERSION"]
 
client = Octokit::Client.new(:access_token => ENV['GH_TOKEN'])
releases = client.releases "#{USER}/#{PROJECT}"
 
target_release = releases.select { |r| r.tag_name == VERSION }[0]
 
client.upload_asset(target_release.url, "#{VERSION}/nrdk-#{VERSION}.exe",
                    :content_type => "application/octet-stream",
                    :name => "Windows-nrdk-#{VERSION}.exe")

client.upload_asset(target_release.url, "#{VERSION}/nrdk-#{VERSION}.zip",
                    :content_type => "application/octet-stream",
                    :name => "OSX-nrdk-#{VERSION}.zip")

client.upload_asset(target_release.url, "#{VERSION}/nr-rdk-java_#{VERSION}-1_all.deb",
                    :content_type => "application/octet-stream",
                    :name => "Ubuntu-nrdk-java_#{VERSION}-1_all.deb")
