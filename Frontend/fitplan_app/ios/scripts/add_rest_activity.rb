# Adds the rest Live Activity (Phase 9C/9D) to the Xcode project: a widget extension target
# "RestActivityExtension" embedded in Runner, plus the app-side Swift files.
#
# We build on Windows without Xcode, so the project is changed here, on the macOS build machine,
# right before `flutter build ios` (see .github/workflows/ios-test.yml). Running it twice is safe.
#
#   ruby ios/scripts/add_rest_activity.rb     (needs the xcodeproj gem, which macOS runners have)
require 'xcodeproj'

project_path = File.expand_path('../Runner.xcodeproj', __dir__)
project = Xcodeproj::Project.open(project_path)
name = 'RestActivityExtension'

if project.targets.any? { |t| t.name == name }
  puts "#{name} is already in the project"
  exit 0
end

app = project.targets.find { |t| t.name == 'Runner' } or abort 'Runner target not found'

# --- files ---------------------------------------------------------------------------------
group = project.main_group.new_group('RestActivity', 'RestActivity')
widget_file = group.new_reference('RestActivityWidget.swift')
attributes_file = group.new_reference('RestActivityAttributes.swift')
intents_file = group.new_reference('RestActivityIntents.swift')
logo_file = group.new_reference('rest_logo.png')
group.new_reference('Info.plist') # listed only, not compiled or copied

runner_group = project.main_group.children.find { |g| g.display_name == 'Runner' } or abort 'Runner group not found'
channel_file = runner_group.new_reference('RestLiveActivity.swift')

# --- the extension target ------------------------------------------------------------------
ext = project.new_target(:app_extension, name, :ios, '16.1', nil, :swift)
ext.add_file_references([widget_file, attributes_file, intents_file])
ext.add_resources([logo_file])
%w[WidgetKit SwiftUI ActivityKit AppIntents].each { |framework| ext.add_system_framework(framework) }

# the app starts and updates the activity, so it needs the same attributes; the button intents
# run in the app's process, so the app needs them too
app.add_file_references([attributes_file, intents_file, channel_file])

# ActivityKit and AppIntents don't exist on iOS 15 (the app's minimum): linked weakly, so older
# iPhones still open the app and just don't get the Lock Screen countdown
app.build_configurations.each do |config|
  flags = Array(config.build_settings['OTHER_LDFLAGS'] || '$(inherited)')
  # pairs: "-weak_framework" before each name (no uniq, which would drop the second flag)
  %w[ActivityKit AppIntents].each do |framework|
    next if flags.each_cons(2).include?(['-weak_framework', framework])
    flags += ['-weak_framework', framework]
  end
  config.build_settings['OTHER_LDFLAGS'] = flags
end

# Runner has Debug, Profile and Release; the extension needs the same three
unless ext.build_configurations.any? { |c| c.name == 'Profile' }
  ext.add_build_configuration('Profile', :release)
end

flutter_group = project.main_group.children.find { |g| g.display_name == 'Flutter' }
xcconfig = lambda do |file|
  flutter_group&.files&.find { |f| f.display_name == file }
end

ext.build_configurations.each do |config|
  s = config.build_settings
  s['PRODUCT_NAME'] = name
  s['PRODUCT_BUNDLE_IDENTIFIER'] = 'com.fitplanapp.fitplan.RestActivity'
  s['INFOPLIST_FILE'] = 'RestActivity/Info.plist'
  s['GENERATE_INFOPLIST_FILE'] = 'NO'
  s['SWIFT_VERSION'] = '5.0'
  s['IPHONEOS_DEPLOYMENT_TARGET'] = '16.1'
  s['TARGETED_DEVICE_FAMILY'] = '1'
  s['SKIP_INSTALL'] = 'YES'
  s['APPLICATION_EXTENSION_API_ONLY'] = 'YES'
  s['LD_RUNPATH_SEARCH_PATHS'] = ['$(inherited)', '@executable_path/Frameworks', '@executable_path/../../Frameworks']
  s['ENABLE_BITCODE'] = 'NO'
  # FLUTTER_BUILD_NAME and FLUTTER_BUILD_NUMBER, so the extension's version matches the app's
  base = xcconfig.call(config.name == 'Debug' ? 'Debug.xcconfig' : 'Release.xcconfig')
  config.base_configuration_reference = base if base
end

# --- embed it in the app -------------------------------------------------------------------
app.add_dependency(ext)
embed = app.copy_files_build_phases.find { |p| p.name == 'Embed Foundation Extensions' } ||
        app.new_copy_files_build_phase('Embed Foundation Extensions')
embed.symbol_dst_subfolder_spec = :plug_ins
build_file = embed.add_file_reference(ext.product_reference, true)
build_file.settings = { 'ATTRIBUTES' => ['RemoveHeadersOnCopy'] }

# Before Flutter's "Thin Binary" script, otherwise Xcode reports a dependency cycle.
thin = app.build_phases.find { |p| p.respond_to?(:name) && p.name == 'Thin Binary' }
if thin
  app.build_phases.delete(embed)
  app.build_phases.insert(app.build_phases.index(thin), embed)
end

project.save
puts "Added #{name} to #{project_path}"
