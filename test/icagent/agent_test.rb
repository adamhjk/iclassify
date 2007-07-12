require File.dirname(__FILE__) + '/../test_helper'
require File.dirname(__FILE__) + '/../../lib/iclassify/agent'

class AgentTest < Test::Unit::TestCase
  UUIDFILE = File.dirname(__FILE__) + '/../tmp/icagent.uuid'
  UUID_REGEX = /^[[:xdigit:]]{8}[:-][[:xdigit:]]{4}[:-][[:xdigit:]]{4}[:-][[:xdigit:]]{4}[:-][[:xdigit:]]{12}$/
  SERVER_URL = "http://localhost:3000"
  
  def setup
    @agent = IClassify::Agent.new(UUIDFILE, SERVER_URL)
  end
  
  def test_uuid
    assert(File.exists?(UUIDFILE), "UUID File Exists")
    IO.read(UUIDFILE) do |line|
      line.chomp!
      assert(line =~ UUID_REGEX)
    end
    a2 = IClassify::Agent.new(UUIDFILE)
    assert(@agent.uuid == a2.uuid, "Agent reads the same uuid")
  end
  
  def test_uri
    assert(@agent.server == URI.parse(SERVER_URL), "Server URL is set")
  end
  
  def test_load_current
    assert(@agent.load_current == false, "Loading the current node should fail")
    
  end
  
  # Replace this with your real tests.
  def test_truth
    assert true
  end
end
