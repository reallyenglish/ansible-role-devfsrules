require "spec_helper"

mount_point = "/foo/bar"

describe file("/etc/fstab") do
  it { should exist }
  it { should_not match(/^none\s+#{Regexp.escape(mount_point)}\s+devfs\s+/) }
end

describe file("/foo/bar") do
  it { should exist }
  it { should_not be_mounted }
end
