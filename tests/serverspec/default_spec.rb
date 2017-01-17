require "spec_helper"

config  = "/etc/devfs.rules"

rules = <<'__EOF__'
# Managed by ansible
[devfsrules_jail_with_bpf=100]
add include $devfsrules_hide_all
add include $devfsrules_unhide_basic
add include $devfsrules_unhide_login
add path 'bpf*' unhide
add path 'net*' unhide
add path 'tun*' unhide

[my_rule=999]
add path 'tun*' hide
__EOF__

describe file(config) do
  it { should be_file }
  its(:content) { should match(/#{ Regexp.escape(rules) }/) }
end

describe file("/etc/rc.conf") do
  it { should be_file }
  its(:content) { should match(/^devfs_system_ruleset="my_rule"$/) }
end

describe command("devfs rule -s 999 show") do
  its(:exit_status) { should eq 0 }
  its(:stderr) { should match(/^$/) }
  its(:stdout) { should match(/^100 path tun\* hide$/) }
  its(:stdout) { should match(/^200 path led\/em0 hide$/) }
end

describe file("/dev/led/em0") do
  it { should_not exist }
end
