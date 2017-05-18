require "spec_helper"

describe file("/etc/rc.conf") do
  it { should be_file }
  it { should be_owned_by "root" }
  it { should be_grouped_into "wheel" }
  it { should be_mode 644 }
  its(:content) { should_not match(/devfs_system_ruleset=/) }
end
