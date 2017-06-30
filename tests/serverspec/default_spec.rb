require "spec_helper"

config = "/etc/devfs.rules"

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
  its(:content) { should match(/^devfs_set_rulesets="#{Regexp.escape("/chroot1/dev=chroot /chroot2/dev=chroot")} "/) }
end

describe command("devfs rule -s 999 show") do
  its(:exit_status) { should eq 0 }
  its(:stderr) { should match(/^$/) }
  its(:stdout) { should match(/^100 path tun\* hide$/) }
  its(:stdout) { should match(%r{^200 path led/em0 hide$}) }
  its(:stdout) { should match(/^300 path bpf user root$/) }
  its(:stdout) { should match(/^400 path bpf group network$/) }
  its(:stdout) { should match(/^500 path bpf mode 660$/) }
end

describe command("devfs rule -s 200 show") do
  its(:exit_status) { should eq 0 }
  its(:stderr) { should eq "" }
  its(:stdout) { should match(/^100 include 1$/) }
  its(:stdout) { should match(/^200 include 2$/) }
  its(:stdout) { should match(/^300 path random unhide$/) }
  its(:stdout) { should match(/^400 path urandom unhide$/) }
end

describe file("/dev/led/em0") do
  it { should_not exist }
end

describe file("/dev/bpf") do
  it { should be_mode 660 }
  it { should be_owned_by "root" }
  it { should be_grouped_into "network" }
end

1.upto(2).each do |i|
  describe file("/chroot#{i}/dev") do
    it { should exist }
    it { should be_mounted }
    it { should be_mounted.with(type: "devfs") }
    it do
      pending "does not work with specinfra 2.68.1"
      should be_mounted.with(options: { rw: true })
    end
  end

  %w(
    null
    random
    zero
  ).each do |f|
    describe file("/chroot#{i}/dev/#{f}") do
      it { should exist }
      it { should be_character_device }
      it { should be_mode 666 }
    end
  end
  describe file("/chroot#{i}/dev/urandom") do
    it { should exist }
    it { should be_symlink }
  end
end

describe file("/foo/bar") do
  it { should_not exist }
  it { should_not be_mounted }
end
