task :default => :run_all_specs

desc "Clean all targets"
task :clean_all_targets do
  clean_all_targets
end

desc "Clean target"
task :clean, :target do |task, args|
  clean args.target
end

desc "Build Swizzlean"
task :build_swizzlean do
  Rake::Task[:clean].invoke "Swizzlean"
  build "Swizzlean"
end

desc "Run Specs"
task :specs do
  Rake::Task[:clean].invoke "Specs"
  run_tests "Specs"
end

desc "Run Integration Specs"
task :integration_specs do
  Rake::Task[:clean].invoke "IntegrationSpecs"
  run_tests "IntegrationSpecs"
end

desc "Run all Specs"
task :run_all_specs do
  Rake::Task[:specs].invoke
  Rake::Task[:integration_specs].invoke
end

private

def clean(target_name)
  sh "xcodebuild -target #{target_name} clean"
end

def clean_all_targets
  sh "xcodebuild -alltargets clean"
end

def build(target_name)
  execute_xcodebuild target_name
end

def run_tests(test_target_name)
  execute_xcodebuild test_target_name, "test"
  tests_failed test_target_name unless $?.success?
end

def execute_xcodebuild(target_name, build_action = "build")
  sh "xcodebuild -workspace Swizzlean.xcworkspace -scheme '#{target_name}' -sdk iphonesimulator -configuration Release #{build_action} | xcpretty -tc ; exit ${PIPESTATUS[0]}" rescue nil
end

def tests_failed(test_target_name)
  puts red "#{test_target_name} failed"
  exit $?.exitstatus
end

def red(string)
  "\033[0;31m! #{string}"
end

