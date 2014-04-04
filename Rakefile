PRODUCT_NAME = "Swizzlean"
SPECS_TARGET_NAME = "Specs"
PRODUCT_TYPE = "project"
CONFIGURATION = "Release"
SIMULATOR_VERSION = "7.0"

PROJECT_ROOT = File.dirname(__FILE__)
BUILD_DIR = File.join(PROJECT_ROOT, "build")

task :default => ["specs"]

desc "Setup Submodules"
task :setup_submodules do
  system_or_exit("git submodule init && git submodule update")
end

desc "Clean all targets"
task :clean do
  system_or_exit "rm -rf #{BUILD_DIR}/*", output_file("clean")
end

desc "Build Swizzlean"
task :build_swizzlean => [:clean, :setup_submodules] do
  build(PRODUCT_NAME)
end

desc "Build Specs"
task :build_specs => [:clean, :setup_submodules] do
  build(SPECS_TARGET_NAME)
end

desc "Run specs"
task :specs => :build_specs do
  require 'tmpdir'
  puts SIMULATOR_VERSION
  puts "Running specs on iOS Simulator -> #{SIMULATOR_VERSION}"

  run_specs
end

#*********************************************************************
# GLOBAL HELPER FUNCTIONS FOR RAKE TASKS
#*********************************************************************

def kill_simulator
  system %Q[killall -m -KILL "gdb"]
  system %Q[killall -m -KILL "otest"]
  system %Q[killall -m -KILL "iPhone Simulator"]
end

def output_file(target)
  output_dir = if ENV['IS_CI_BOX']
                 ENV['CC_BUILD_ARTIFACTS']
               else
                 Dir.mkdir(BUILD_DIR) unless File.exists?(BUILD_DIR)
                 BUILD_DIR
               end

  output_file = File.join(output_dir, "#{target}.output")
  puts "Output: #{output_file}"
  "'#{output_file}'"
end

def system_or_exit(cmd, stdout = nil)
  puts "Executing #{cmd}"
  cmd += " >#{stdout}" if stdout
  system(cmd) or begin
    output = `cat #{stdout}`
    raise <<EOF
******** Build failed ********
#{output}

EOF
  end
end

def with_env_vars(env_vars)
  old_values = {}
  env_vars.each do |key,new_value|
    old_values[key] = ENV[key]
    ENV[key] = new_value
  end

  begin
    yield
  ensure
    env_vars.each_key do |key|
      ENV[key] = old_values[key]
    end
  end
end

def xcode_developer_dir
    `xcode-select -print-path`.strip
end

def sdk_dir
    "#{xcode_developer_dir}/Platforms/iPhoneSimulator.platform/Developer/SDKs/iPhoneSimulator#{SIMULATOR_VERSION}.sdk"
end

def build(target_name)
  kill_simulator
  system_or_exit build_string(target_name), output_file(target_name)
end

def build_dir(effective_platform_name)
    File.join(BUILD_DIR, CONFIGURATION + effective_platform_name)
end

def build_string(target_name)
  "submodules/xctool/xctool.sh -#{PRODUCT_TYPE} #{PRODUCT_NAME}.#{product_file_extension} -scheme #{target_name} -configuration #{CONFIGURATION} -sdk iphonesimulator#{SIMULATOR_VERSION} SYMROOT=#{BUILD_DIR} build"
end

def product_file_extension
  PRODUCT_TYPE == "project" ? "xcodeproj" : "xcworkspace"
end

def run_specs
  env_vars = {
      "DYLD_ROOT_PATH" => sdk_dir,
      "IPHONE_SIMULATOR_ROOT" => sdk_dir,
      "CFFIXED_USER_HOME" => Dir.tmpdir,
      "CEDAR_HEADLESS_SPECS" => "1",
      "CEDAR_REPORTER_CLASS" => "CDRColorizedReporter",
  }
  with_env_vars(env_vars) do
    env_vars.each_pair { |env_var_key, env_var_value| puts "#{env_var_key} => #{env_var_value}" }
    system_or_exit "#{File.join(build_dir("-iphonesimulator"), "#{SPECS_TARGET_NAME}.app", SPECS_TARGET_NAME)} -RegisterForSystemEvents"
  end
end