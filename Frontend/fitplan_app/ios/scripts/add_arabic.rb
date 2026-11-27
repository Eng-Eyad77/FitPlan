# Adds Arabic to the Xcode project (Phase 11): the "ar" region and Runner/ar.lproj/InfoPlist.strings,
# which holds the camera and photo permission texts in Arabic.
#
# Like add_rest_activity.rb, this runs on the macOS build machine right before `flutter build ios`,
# because we have no Xcode on Windows. Running it twice is safe.
#
#   ruby ios/scripts/add_arabic.rb     (needs the xcodeproj gem, which macOS runners have)
require 'xcodeproj'

project_path = File.expand_path('../Runner.xcodeproj', __dir__)
project = Xcodeproj::Project.open(project_path)

project.root_object.known_regions |= ['ar']

runner_group = project.main_group.children.find { |g| g.display_name == 'Runner' } or abort 'Runner group not found'
if runner_group.children.any? { |c| c.display_name == 'InfoPlist.strings' }
  puts 'InfoPlist.strings is already in the project'
  exit 0
end

app = project.targets.find { |t| t.name == 'Runner' } or abort 'Runner target not found'

variant = runner_group.new_variant_group('InfoPlist.strings')
arabic = variant.new_reference('ar.lproj/InfoPlist.strings')
arabic.name = 'ar'
app.resources_build_phase.add_file_reference(variant)

project.save
puts 'Added Arabic: ar region and InfoPlist.strings'
