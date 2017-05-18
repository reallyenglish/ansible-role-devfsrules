require "spec_helper"

class ServiceNotReady < StandardError
end

sleep 10 if ENV["JENKINS_HOME"]

context "after provisioning finished" do
  describe server(:server1) do
    describe "/dev/bpf" do
      it "is readable by user vagrant" do
        result = current_server.ssh_exec("cat /dev/bpf >/dev/null")
        expect(result).not_to match(/Permission denied/)
        expect(result).to match(/Device not configured/)
      end
    end
  end
end
